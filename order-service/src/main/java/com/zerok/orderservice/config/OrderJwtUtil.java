package com.zerok.orderservice.config;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;

/**
 * Verifies Auth-issued HS256 tokens locally using the shared secret and token format.
 */
@Component
public class OrderJwtUtil {

    private final Key signingKey;

    public OrderJwtUtil(Environment environment) {
        String secret = environment.getRequiredProperty("jwt.secret");
        if (secret.isBlank()) {
            throw new IllegalArgumentException("JWT_SECRET must be configured");
        }
        signingKey = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Parses a signed token and returns its validated claims.
     */
    public Claims parseToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(signingKey)
                .build()
                .parseClaimsJws(token)
                .getBody();
    }
}
