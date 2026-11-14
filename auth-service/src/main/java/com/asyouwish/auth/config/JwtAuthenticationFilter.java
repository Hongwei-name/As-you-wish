package com.asyouwish.auth.config;

import com.asyouwish.auth.entity.AuthUser;
import com.asyouwish.auth.mapper.AuthUserMapper;
import com.asyouwish.auth.service.TokenBlacklistService;
import com.asyouwish.auth.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * JWT 认证过滤器：解析 Authorization: Bearer，校验签名/过期/黑名单/账号状态，
 * 成功后把用户 ID 写入 SecurityContext，供受保护接口使用。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtUtil jwtUtil;
    private final AuthUserMapper authUserMapper;
    private final TokenBlacklistService tokenBlacklistService;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith(BEARER_PREFIX)) {
            String token = authorization.substring(BEARER_PREFIX.length()).trim();
            try {
                Claims claims = jwtUtil.parseToken(token);
                boolean blacklisted = tokenBlacklistService.isBlacklisted(claims.getId());
                if (!blacklisted && claims.getSubject() != null) {
                    Long userId = Long.valueOf(claims.getSubject());
                    AuthUser user = authUserMapper.selectById(userId);
                    if (user != null && (user.getStatus() == null || user.getStatus() == 1)) {
                        UsernamePasswordAuthenticationToken authentication =
                                new UsernamePasswordAuthenticationToken(
                                        userId, null, List.of(new SimpleGrantedAuthority("ROLE_USER")));
                        authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                        SecurityContextHolder.getContext().setAuthentication(authentication);
                    }
                }
            } catch (Exception exception) {
                SecurityContextHolder.clearContext();
                log.debug("JWT 认证失败: {}", exception.getClass().getSimpleName());
            }
        }
        filterChain.doFilter(request, response);
    }
}
