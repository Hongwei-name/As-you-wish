package com.asyouwish.auth.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

/**
 * JWT 工具类 (基于 jjwt 0.11.5 版本)
 */
@Component
public class JwtUtil {

    /**
     * 签名密钥 (生产环境建议配置在 application.yml 中)
     * 注意：0.11.5 版本中，使用 HS256 算法，密钥长度必须大于等于 32 个字符。
     */
    private static final String SECRET_KEY = "AsYouWish_Auth_Service_SecretKey_2024_MustBeLongEnough!";

    /**
     * Token 过期时间 (单位：毫秒)
     * 这里设置为 7 天 (7 * 24 * 60 * 60 * 1000)
     */
    private static final long EXPIRE_TIME = 604800000L;

    /**
     * 生成签名密钥
     */
    private final Key key = Keys.hmacShaKeyFor(SECRET_KEY.getBytes());

    /**
     * 生成 Token
     *
     * @param userId 用户 ID
     * @param phone  手机号
     * @return JWT 字符串
     */
    public String generateToken(Long userId, String phone) {
        Date now = new Date();
        Date expiration = new Date(now.getTime() + EXPIRE_TIME);

        return Jwts.builder()
                // 设置主题 (通常放用户唯一标识 ID)
                .setSubject(String.valueOf(userId))
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