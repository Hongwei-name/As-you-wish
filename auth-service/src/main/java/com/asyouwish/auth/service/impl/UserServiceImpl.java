package com.asyouwish.auth.service.impl;

import cloud.tianai.captcha.application.ImageCaptchaApplication;
import cloud.tianai.captcha.common.constant.CaptchaTypeConstant;
import cloud.tianai.captcha.common.response.ApiResponse;
import com.asyouwish.auth.dto.CaptchaCheckDTO;
import com.asyouwish.auth.dto.ChangePasswordDTO;
import com.asyouwish.auth.dto.PasswordLoginDTO;
import com.asyouwish.auth.dto.PasswordResetDTO;
import com.asyouwish.auth.dto.SendSmsDTO;
import com.asyouwish.auth.dto.SmsLoginDTO;
import com.asyouwish.auth.dto.SmsRegisterDTO;
import com.asyouwish.auth.dto.UpdateProfileDTO;
import com.asyouwish.auth.dto.UserInfoVO;
import com.asyouwish.auth.entity.AuthUser;
import com.asyouwish.auth.mapper.AuthUserMapper;
import com.asyouwish.auth.service.AliyunPnvsProperties;
import com.asyouwish.auth.service.SmsCodeService;
import com.asyouwish.auth.service.SmsScene;
import com.asyouwish.auth.service.TokenBlacklistService;
import com.asyouwish.auth.service.UserService;
import com.asyouwish.auth.util.BusinessException;
import com.asyouwish.auth.util.JwtUtil;
import com.asyouwish.auth.util.MinioUtil;
import com.asyouwish.auth.util.ResultCode;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.concurrent.TimeUnit;

/**
 * 认证业务实现：PNVS 短信发送/核验、注册/登录、JWT 签发、账号状态、限流与密码重置。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<AuthUserMapper, AuthUser> implements UserService {

    private static final String PNVS_LIMIT_PREFIX = "auth:pnvs:limit:";
    private static final String PNVS_IP_MINUTE_PREFIX = "auth:pnvs:ip:minute:";
    private static final String PNVS_DAY_PHONE_PREFIX = "auth:pnvs:day:phone:";
    private static final String PNVS_DAY_IP_PREFIX = "auth:pnvs:day:ip:";
    private static final String PNVS_CHECK_ATTEMPT_PREFIX = "auth:pnvs:check:attempt:";
    private static final String SLIDER_CAPTCHA_PREFIX = "auth:captcha:slider:";
    private static final String LOGIN_FAIL_PREFIX = "auth:login:fail:";
    private static final int MAX_CHECK_ATTEMPTS = 5;
    private static final long CHECK_ATTEMPT_MINUTES = 5;
    private static final int MAX_LOGIN_FAILS = 5;
    private static final long LOGIN_LOCK_MINUTES = 15;

    private final StringRedisTemplate redisTemplate;
    private final ImageCaptchaApplication captchaApplication;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final SmsCodeService smsCodeService;
    private final AliyunPnvsProperties pnvsProperties;
    private final TokenBlacklistService tokenBlacklistService;
    private final MinioUtil minioUtil;

    @Override
    public AuthUser getUserByPhone(String phone) {
        return this.getOne(new LambdaQueryWrapper<AuthUser>()
                .eq(AuthUser::getPhone, phone));
    }

    @Override
    public ApiResponse<?> getSliderCaptcha() {
        ApiResponse<?> response = captchaApplication.generateCaptcha(CaptchaTypeConstant.SLIDER);
        if (!response.isSuccess()) {
            throw new BusinessException("验证码生成失败");
        }
        return response;
    }

    @Override
    public ApiResponse<?> verifySliderCaptcha(CaptchaCheckDTO dto) {
        if (dto == null || !StringUtils.hasText(dto.getId()) || dto.getData() == null) {
            throw new BusinessException("验证码参数不完整");
        }
        ApiResponse<?> response = captchaApplication.matching(dto.getId(), dto.getData());
        if (response.isSuccess()) {
            redisTemplate.opsForValue().set(SLIDER_CAPTCHA_PREFIX + dto.getId(), "1", 2, TimeUnit.MINUTES);
        }
        return response;
    }

    @Override
    public void sendSmsCode(SendSmsDTO dto, String ip) {
        if (dto == null || !StringUtils.hasText(dto.getCaptchaId())) {
            throw new BusinessException("请先完成滑块验证");
        }
        SmsScene scene = SmsScene.fromCode(dto.getScene());
        String clientIp = normalizeIp(ip);

        // 三个场景使用不同的 Redis 维度，互不占用额度。
        incrementIpMinuteCounter(scene, clientIp);
        checkDailyLimits(scene, dto.getPhone(), clientIp);
        String phoneLimitKey = phoneLimitKey(scene, dto.getPhone());
        if (redisTemplate.hasKey(phoneLimitKey)) {
            throw new BusinessException("验证码发送过于频繁，请稍后再试");
        }

        String captchaKey = SLIDER_CAPTCHA_PREFIX + dto.getCaptchaId();
        if (!redisTemplate.delete(captchaKey)) {
            throw new BusinessException("滑块验证已过期，请重新验证");
        }

        long interval = pnvsProperties.getInterval() == null ? 60L : pnvsProperties.getInterval();
        Boolean acquired = redisTemplate.opsForValue()
                .setIfAbsent(phoneLimitKey, "1", Math.max(1L, interval), TimeUnit.SECONDS);
        if (!Boolean.TRUE.equals(acquired)) {
            throw new BusinessException("验证码发送过于频繁，请稍后再试");
        }

        // PNVS/控制台实现由当前 profile 决定；生产走 PNVS，测试只打印验证码。
        smsCodeService.send(scene, dto.getPhone());
        incrementDailyCounter(PNVS_DAY_PHONE_PREFIX + scene.getCode() + ":" + dto.getPhone());
        incrementDailyCounter(PNVS_DAY_IP_PREFIX + scene.getCode() + ":" + clientIp);
        redisTemplate.delete(checkAttemptKey(scene, dto.getPhone()));
    }

    private void incrementIpMinuteCounter(SmsScene scene, String ip) {
        String key = PNVS_IP_MINUTE_PREFIX + scene.getCode() + ":" + ip;
        Long count = redisTemplate.opsForValue().increment(key);
        if (count != null && count == 1L) {
            redisTemplate.expire(key, 60, TimeUnit.SECONDS);
        }
        int limit = pnvsProperties.getRateLimit().getIpPerMinute();
        if (count != null && count > limit) {
            throw new BusinessException("当前网络请求过于频繁，请稍后再试");
        }
    }

    private void checkDailyLimits(SmsScene scene, String phone, String ip) {
        int phoneDaily = pnvsProperties.getRateLimit().getPhoneDaily();
        int ipDaily = pnvsProperties.getRateLimit().getIpDaily();
        if (readCounter(PNVS_DAY_PHONE_PREFIX + scene.getCode() + ":" + phone) >= phoneDaily) {
            throw new BusinessException("该手机号今日发送次数已达上限");
        }
        if (readCounter(PNVS_DAY_IP_PREFIX + scene.getCode() + ":" + ip) >= ipDaily) {
            throw new BusinessException("当前网络环境今日发送次数已达上限");
        }
    }

    private String phoneLimitKey(SmsScene scene, String phone) {
        return PNVS_LIMIT_PREFIX + scene.getCode() + ":" + phone;
    }

    private String checkAttemptKey(SmsScene scene, String phone) {
        return PNVS_CHECK_ATTEMPT_PREFIX + scene.getCode() + ":" + phone;
    }

    private int readCounter(String key) {
        String value = redisTemplate.opsForValue().get(key);
        if (!StringUtils.hasText(value)) {
            return 0;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            return 0;
        }
    }

    private void incrementDailyCounter(String key) {
        Long count = redisTemplate.opsForValue().increment(key);
        if (count != null && count == 1L) {
            redisTemplate.expire(key, 24, TimeUnit.HOURS);
        }
    }

    @Override
    @Transactional
    public String registerBySms(SmsRegisterDTO dto) {
        verifySmsCode(SmsScene.REGISTER, dto.getPhone(), dto.getCode());
        if (getUserByPhone(dto.getPhone()) != null) {
            throw new BusinessException(ResultCode.PHONE_ALREADY_EXISTS);
        }
        AuthUser user = new AuthUser();
        user.setPhone(dto.getPhone());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setUsername("用户_" + dto.getPhone());
        user.setNickname("用户_" + dto.getPhone());
        user.setStatus(1);
        user.setCreateTime(LocalDateTime.now());
        user.setUpdateTime(LocalDateTime.now());
        try {
            this.save(user);
        } catch (DuplicateKeyException exception) {
            throw new BusinessException(ResultCode.PHONE_ALREADY_EXISTS);
        }
        return jwtUtil.generateToken(user.getId(), user.getPhone());
    }

    @Override
    public String loginBySms(SmsLoginDTO dto, String ip) {
        verifySmsCode(SmsScene.LOGIN, dto.getPhone(), dto.getCode());
        AuthUser user = getUserByPhone(dto.getPhone());
        if (user == null) {
            throw new BusinessException(ResultCode.PHONE_NOT_EXISTS);
        }
        checkUserStatus(user);
        updateLoginInfo(user, ip);
        return jwtUtil.generateToken(user.getId(), user.getPhone());
    }

    @Override
    public String loginByPassword(PasswordLoginDTO dto, String ip) {
        ensureLoginAllowed(dto.getPhone());
        AuthUser user = getUserByPhone(dto.getPhone());
        boolean passwordMatched = user != null
                && StringUtils.hasText(user.getPassword())
                && passwordEncoder.matches(dto.getPassword(), user.getPassword());
        if (!passwordMatched) {
            recordLoginFailure(dto.getPhone());
            throw new BusinessException(ResultCode.PASSWORD_ERROR);
        }
        checkUserStatus(user);
        clearLoginFailures(dto.getPhone());
        updateLoginInfo(user, ip);
        return jwtUtil.generateToken(user.getId(), user.getPhone());
    }

    @Override
    public UserInfoVO getUserInfo(Long userId) {
        AuthUser user = this.getById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        checkUserStatus(user);
        return new UserInfoVO(user.getId(), user.getPhone(), user.getNickname(), user.getAvatar());
    }

    @Override
    @Transactional
    public UserInfoVO updateProfile(Long userId, UpdateProfileDTO dto) {
        AuthUser user = this.getById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        checkUserStatus(user);

        AuthUser update = new AuthUser();
        update.setId(userId);
        update.setUpdateTime(LocalDateTime.now());
        boolean changed = false;

        if (dto.getNickname() != null) {
            String nickname = dto.getNickname().trim();
            if (nickname.isEmpty()) {
                throw new BusinessException("昵称不能为空");
            }
            if (!nickname.equals(user.getNickname())) {
                update.setNickname(nickname);
                changed = true;
            }
        }

        if (dto.getAvatar() != null) {
            String avatar = dto.getAvatar().trim();
            if (!avatar.isEmpty() && !avatar.equals(user.getAvatar())) {
                update.setAvatar(avatar);
                changed = true;
            }
        }

        if (changed) {
            this.updateById(update);
            user = this.getById(userId);
        }
        return new UserInfoVO(user.getId(), user.getPhone(), user.getNickname(), user.getAvatar());
    }

    @Override
    @Transactional
    public UserInfoVO uploadAvatar(Long userId, MultipartFile file) {
        AuthUser user = this.getById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        checkUserStatus(user);
        validateAvatar(file);

        String objectName = minioUtil.upload(file, "avatar");
        String avatarUrl = minioUtil.getObjectUrl(objectName);

        AuthUser update = new AuthUser();
        update.setId(userId);
        update.setAvatar(avatarUrl);
        update.setUpdateTime(LocalDateTime.now());
        this.updateById(update);

        return new UserInfoVO(user.getId(), user.getPhone(), user.getNickname(), avatarUrl);
    }

    private void validateAvatar(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("请选择头像图片");
        }
        String name = file.getOriginalFilename();
        String lower = name == null ? "" : name.toLowerCase();
        boolean allowed = lower.endsWith(".jpg") || lower.endsWith(".jpeg")
                || lower.endsWith(".png") || lower.endsWith(".webp");
        if (!allowed) {
            throw new BusinessException("只允许 jpg / png / webp / jpeg 图片");
        }
    }

    @Override
    public void logout(String token) {
        if (!StringUtils.hasText(token)) {
            return;
        }
        try {
            Claims claims = jwtUtil.parseToken(token);
            tokenBlacklistService.blacklist(claims);
        } catch (Exception exception) {
            log.debug("退出登录 Token 已失效，无需加入黑名单");
        }
    }

    @Override
    @Transactional
    public void resetPassword(PasswordResetDTO dto) {
        verifySmsCode(SmsScene.RESET_PASSWORD, dto.getPhone(), dto.getCode());
        AuthUser user = getUserByPhone(dto.getPhone());
        if (user == null) {
            throw new BusinessException(ResultCode.PHONE_NOT_EXISTS);
        }
        checkUserStatus(user);
        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        user.setUpdateTime(LocalDateTime.now());
        this.updateById(user);
        clearLoginFailures(dto.getPhone());
    }

    @Override
    @Transactional
    public void changePassword(Long userId, ChangePasswordDTO dto) {
        AuthUser user = this.getById(userId);
        if (user == null) {
            throw new BusinessException(ResultCode.UNAUTHORIZED);
        }
        checkUserStatus(user);
        boolean oldMatched = StringUtils.hasText(user.getPassword())
                && passwordEncoder.matches(dto.getOldPassword(), user.getPassword());
        if (!oldMatched) {
            throw new BusinessException(ResultCode.OLD_PASSWORD_ERROR);
        }
        if (passwordEncoder.matches(dto.getNewPassword(), user.getPassword())) {
            throw new BusinessException("新密码不能与原密码相同");
        }
        user.setPassword(passwordEncoder.encode(dto.getNewPassword()));
        user.setUpdateTime(LocalDateTime.now());
        this.updateById(user);
    }

    private void verifySmsCode(SmsScene scene, String phone, String inputCode) {
        if (!StringUtils.hasText(phone) || !StringUtils.hasText(inputCode)) {
            throw new BusinessException("手机号或验证码不能为空");
        }
        String attemptKey = checkAttemptKey(scene, phone);
        Long attempts = redisTemplate.opsForValue().increment(attemptKey);
        if (attempts != null && attempts == 1L) {
            redisTemplate.expire(attemptKey, CHECK_ATTEMPT_MINUTES, TimeUnit.MINUTES);
        }
        if (attempts != null && attempts > MAX_CHECK_ATTEMPTS) {
            throw new BusinessException("验证码尝试次数过多，请重新获取");
        }

        boolean passed = smsCodeService.verify(scene, phone, inputCode);
        if (!passed) {
            throw new BusinessException(ResultCode.SMS_CODE_ERROR);
        }
        redisTemplate.delete(attemptKey);
    }

    private void ensureLoginAllowed(String phone) {
        String key = LOGIN_FAIL_PREFIX + phone;
        if (readCounter(key) >= MAX_LOGIN_FAILS) {
            throw new BusinessException("登录尝试次数过多，请 15 分钟后再试");
        }
    }

    private void recordLoginFailure(String phone) {
        String key = LOGIN_FAIL_PREFIX + phone;
        Long count = redisTemplate.opsForValue().increment(key);
        if (count != null && count == 1L) {
            redisTemplate.expire(key, LOGIN_LOCK_MINUTES, TimeUnit.MINUTES);
        }
    }

    private void clearLoginFailures(String phone) {
        redisTemplate.delete(LOGIN_FAIL_PREFIX + phone);
    }

    private void checkUserStatus(AuthUser user) {
        if (user.getStatus() != null && user.getStatus() != 1) {
            throw new BusinessException("账号已被禁用或锁定，请联系客服");
        }
    }

    private void updateLoginInfo(AuthUser user, String ip) {
        AuthUser update = new AuthUser();
        update.setId(user.getId());
        update.setLastLoginIp(normalizeIp(ip));
        update.setLastLoginTime(LocalDateTime.now());
        this.updateById(update);
    }

    private String normalizeIp(String ip) {
        return StringUtils.hasText(ip) ? ip : "unknown";
    }
}
