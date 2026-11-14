package com.asyouwish.auth.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;

import java.security.Key;
import java.util.Date;
import java.util.UUID;

/**
 * JWT 工具类 (基于 jjwt 0.11.5 版本)
 */
@Component
public class JwtUtil {

    private final Key key;
    private final long expireMillis;

    public JwtUtil(@Value("${jwt.secret}") String secret,
                   @Value("${jwt.expire-millis:604800000}") long expireMillis) {
        if (secret == null || secret.isBlank()) {
            throw new IllegalArgumentException("JWT_SECRET must be configured");
        }
        if (expireMillis <= 0) {
            throw new IllegalArgumentException("JWT_EXPIRE_MILLIS must be positive");
        }
        // Keys 同时验证 HS256 密钥至少包含 32 字节；禁止使用源码内默认密钥。
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.expireMillis = expireMillis;
    }

    /**
     * 生成 Token
     *
     * @param userId 用户 ID
     * @param phone  手机号
     * @return JWT 字符串
     */
    public String generateToken(Long userId, String phone) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + expireMillis);

        return Jwts.builder()
                // 设置主题 (通常放用户唯一标识 ID)
                .setSubject(String.valueOf(userId))
                // 唯一标识，用于退出登录黑名单
                .setId(UUID.randomUUID().toString())
                // 自定义载荷，放入手机号等非敏感信息
                .claim("phone", phone)
                // 签发时间
                .setIssuedAt(now)
                // 过期时间
                .setExpiration(expiration)
                // 签名算法和密钥
                .signWith(key, SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * 解析 Token 获取 Payload (Claims)
     *
     * @param token JWT 字符串
     * @return Claims 对象
     */
    public Claims parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * 从 Token 中解析出用户 ID
     *
     * @param token JWT 字符串
     * @return 用户 ID
     */
    public Long getUserIdFromToken(String token) {
        Claims claims = parseToken(token);
        return Long.valueOf(claims.getSubject());
    }

    /**
     * 校验 Token 是否合法 (是否过期、签名是否正确)
     *
     * @param token JWT 字符串
     * @return true 表示有效，false 表示无效或已过期
     */
    public boolean validateToken(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception e) {
            // 捕获异常（如 ExpiredJwtException, SignatureException 等）
            // 实际项目中可以在这里打印日志
            return false;
        }
    }
}