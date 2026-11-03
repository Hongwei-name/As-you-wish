package com.asyouwish.auth.service.impl;

import com.asyouwish.auth.dto.PasswordLoginDTO;
import com.asyouwish.auth.dto.SendSmsDTO;
import com.asyouwish.auth.dto.SmsLoginDTO;
import com.asyouwish.auth.dto.SmsRegisterDTO;
import com.asyouwish.auth.entity.AuthUser;
import com.asyouwish.auth.mapper.AuthUserMapper;
import com.asyouwish.auth.service.UserService;
import com.asyouwish.auth.util.BusinessException;
import com.asyouwish.auth.util.IpUtil;
import com.asyouwish.auth.util.JwtUtil;
import com.asyouwish.auth.util.SliderCaptchaUtil; // 新增导入
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<AuthUserMapper, AuthUser> implements UserService {

    private final StringRedisTemplate redisTemplate;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // 常量统一管理
    private static final String SMS_CODE_PREFIX = "auth:sms:code:";
    private static final String SMS_LIMIT_PREFIX = "auth:sms:limit:";
    private static final String SLIDER_CAPTCHA_PREFIX = "auth:captcha:slider:"; // 新增滑块前缀
    private static final long SMS_CODE_EXPIRE_MINUTES = 5;

    @Override
    public AuthUser getUserByPhone(String phone) {
        return this.getOne(new LambdaQueryWrapper<AuthUser>()
                .eq(AuthUser::getPhone, phone));
    }

    @Override
    public Map<String, String> getSliderCaptcha() {
        try {
            Map<String, Object> captchaData = SliderCaptchaUtil.createCaptcha();
            Integer correctX = (Integer) captchaData.get("x");
            String uuid = UUID.randomUUID().toString();

            redisTemplate.opsForValue().set(SLIDER_CAPTCHA_PREFIX + uuid, String.valueOf(correctX), 2, TimeUnit.MINUTES);

            Map<String, String> result = new HashMap<>();
            result.put("uuid", uuid);
            result.put("bgBase64", (String) captchaData.get("bgBase64"));
            result.put("sliderBase64", (String) captchaData.get("sliderBase64"));
            return result;
        } catch (Exception e) {
            log.error("生成滑块验证码失败", e);
            throw new BusinessException("验证码生成失败");
        }
    }

    @Override
    public void verifySliderAndSendSms(SendSmsDTO dto) {
        // 1. 校验滑块
        String cacheKey = SLIDER_CAPTCHA_PREFIX + dto.getCaptchaUuid();
        String cacheCorrectX = redisTemplate.opsForValue().get(cacheKey);

        if (cacheCorrectX == null) {
            throw new BusinessException("验证码已过期，请刷新页面重试");
        }
        // 无论成功失败，先删除，防止同一个验证码被重复使用
        redisTemplate.delete(cacheKey);

        // 允许的误差范围 (正负 5 像素)
        int tolerance = 5;
        int correctX = Integer.parseInt(cacheCorrectX);
        if (dto.getSliderX() == null || Math.abs(dto.getSliderX() - correctX) > tolerance) {
            throw new BusinessException("滑块验证失败，请重试");
        }

        // 2. 滑块通过，执行发短信逻辑 (这里把原来的 sendSmsCode 改名为了 doSendSmsCode 避免接口冲突)
        doSendSmsCode(dto.getPhone());
    }

    /**
     * 真正的发短信逻辑（抽离为私有方法，不暴露在接口外）
     */
    private void doSendSmsCode(String phone) {
        // 1. 60秒防刷校验
        String limitKey = SMS_LIMIT_PREFIX + phone;
        if (redisTemplate.hasKey(limitKey)) {
            throw new BusinessException("验证码发送过于频繁，请稍后再试");
        }

        // 2. 单手机号每日上限
        String dayPhoneKey = "auth:sms:day:phone:" + phone;
        String phoneCountStr = redisTemplate.opsForValue().get(dayPhoneKey);
        int phoneCount = phoneCountStr == null ? 0 : Integer.parseInt(phoneCountStr);
        if (phoneCount >= 10) {
            throw new BusinessException("该手机号今日发送次数已达上限");
        }

        // 3. 单 IP 每日上限
        String ip = IpUtil.getClientIp();
        String dayIpKey = "auth:sms:day:ip:" + ip;
        String ipCountStr = redisTemplate.opsForValue().get(dayIpKey);
        int ipCount = ipCountStr == null ? 0 : Integer.parseInt(ipCountStr);
        if (ipCount >= 20) {
            throw new BusinessException("当前网络环境异常，请更换网络或明日再试");
        }

        // 4. 生成 6 位随机验证码
        String code = String.valueOf(ThreadLocalRandom.current().nextInt(100000, 1000000));
        log.info("给手机号 {} (IP: {}) 发送验证码: {}", phone, ip, code);

        // 5. TODO: 调用云厂商短信服务 API 发送短信
        // smsService.sendSms(phone, code);

        // 6. 存入 Redis 并设置过期时间
        redisTemplate.opsForValue().set(SMS_CODE_PREFIX + phone, code, SMS_CODE_EXPIRE_MINUTES, TimeUnit.MINUTES);
        redisTemplate.opsForValue().set(limitKey, "1", 60, TimeUnit.SECONDS);

        // 7. 成功发送后，限流计数+1
        redisTemplate.opsForValue().increment(dayPhoneKey);
        redisTemplate.expire(dayPhoneKey, 24, TimeUnit.HOURS);
        redisTemplate.opsForValue().increment(dayIpKey);
        redisTemplate.expire(dayIpKey, 24, TimeUnit.HOURS);
    }

    // ======== 下方其他方法 (注册/登录等) 保持你原来的代码不变即可 ========

    @Override
    public String registerBySms(SmsRegisterDTO dto) {
        verifySmsCode(dto.getPhone(), dto.getCode());
        if (getUserByPhone(dto.getPhone()) != null) {
            throw new BusinessException("该手机号已注册，请直接登录");
        }
        AuthUser user = new AuthUser();
        user.setPhone(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setUsername("用户_" + dto.getPhone());
        this.save(user);
        return jwtUtil.generateToken(user.getId(), user.getPhone());
    }

    @Override
    public String loginBySms(SmsLoginDTO dto) {
        verifySmsCode(dto.getPhone(), dto.getCode());
        AuthUser user = getUserByPhone(dto.getPhone());
        if (user == null) {
            throw new BusinessException("该手机号未注册，请先注册");
        }
        return jwtUtil.generateToken(user.getId(), user.getPhone());
    }

    @Override
    public String loginByPassword(PasswordLoginDTO dto) {
        AuthUser user = getUserByPhone(dto.getPhone());
        if (user == null || !passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new BusinessException("账号或密码错误");
        }
        return jwtUtil.generateToken(user.getId(), user.getPhone());
    }

    private void verifySmsCode(String phone, String inputCode) {
        String cacheKey = SMS_CODE_PREFIX + phone;
        String cacheCode = redisTemplate.opsForValue().get(cacheKey);

        if (!StringUtils.hasText(cacheCode)) {
            throw new BusinessException("验证码已过期，请重新获取");
        }
        redisTemplate.delete(cacheKey);
        if (!cacheCode.equals(inputCode)) {
            throw new BusinessException("验证码错误");
        }
    }
}