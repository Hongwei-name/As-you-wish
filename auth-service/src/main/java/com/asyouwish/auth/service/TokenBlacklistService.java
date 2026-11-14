package com.asyouwish.auth.service;

import io.jsonwebtoken.Claims;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.concurrent.TimeUnit;

/**
 * JWT 黑名单：退出登录后让 Token 在剩余有效期内立即失效。
 */
@Service
@RequiredArgsConstructor
public class TokenBlacklistService {

    private static final String BLACKLIST_PREFIX = "auth:jwt:blacklist:";

    private final StringRedisTemplate redisTemplate;

    public void blacklist(Claims claims) {
        if (claims == null || claims.getId() == null || claims.getId().isBlank()) {
            return;
        }
        Date expiration = claims.getExpiration();
        long ttl = expiration == null ? 0 : expiration.getTime() - System.currentTimeMillis();
        if (ttl > 0) {
            redisTemplate.opsForValue()
                    .set(BLACKLIST_PREFIX + claims.getId(), "1", ttl, TimeUnit.MILLISECONDS);
        }
    }

    public boolean isBlacklisted(String tokenId) {
        return tokenId != null && Boolean.TRUE.equals(redisTemplate.hasKey(BLACKLIST_PREFIX + tokenId));
    }
}
