package com.asyouwish.auth.service;

import com.asyouwish.auth.service.SmsCodeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

/**
 * test/非生产环境的短信实现：不调用阿里云，只在控制台打印验证码。
 * 生产 profile 不会加载本类。
 */
@Slf4j
@Service
@Profile("!prod")
@RequiredArgsConstructor
public class ConsoleSmsCodeService implements SmsCodeService {

    private static final String CODE_PREFIX = "auth:sms:console:code:";
    private static final long EXPIRE_MINUTES = 5;

    private final StringRedisTemplate redisTemplate;

    @Override
    public void send(SmsScene scene, String phone) {
        String code = String.valueOf(ThreadLocalRandom.current().nextInt(100000, 1000000));
        redisTemplate.opsForValue().set(codeKey(scene, phone), code, EXPIRE_MINUTES, TimeUnit.MINUTES);
        // 仅 test/非 prod profile 生效，方便本地联调；生产走 PNVS，不会打印验证码。
        log.warn("【TEST 短信验证码】scene={} phone={} code={}",
                scene.getCode(), maskPhone(phone), code);
    }

    @Override
    public boolean verify(SmsScene scene, String phone, String code) {
        String key = codeKey(scene, phone);
        String expected = redisTemplate.opsForValue().get(key);
        if (!StringUtils.hasText(expected) || !StringUtils.hasText(code)) {
            return false;
        }
        boolean matched = MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                code.getBytes(StandardCharsets.UTF_8));
        if (matched) {
            redisTemplate.delete(key);
        }
        return matched;
    }

    private String codeKey(SmsScene scene, String phone) {
        return CODE_PREFIX + scene.getCode() + ":" + phone;
    }

    private String maskPhone(String phone) {
        if (phone == null || phone.length() < 7) {
            return "***";
        }
        return phone.substring(0, 3) + "****" + phone.substring(phone.length() - 4);
    }
}
