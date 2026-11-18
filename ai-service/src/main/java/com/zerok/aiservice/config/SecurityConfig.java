package com.zerok.aiservice.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.zerok.aiservice.util.Result;
import com.zerok.aiservice.util.ResultCode;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * ai-service 安全配置：所有 /assistant 接口要求 Bearer Token，未认证返回统一 JSON。
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * 禁止 Spring Boot 把 JWT 过滤器自动注册为普通 Servlet Filter，
     * 只允许由 SecurityFilterChain 在正确时机执行。
     */
    @Bean
    public FilterRegistrationBean<JwtAuthenticationFilter> jwtFilterRegistration(JwtAuthenticationFilter filter) {
        FilterRegistrationBean<JwtAuthenticationFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http,
                                           JwtAuthenticationFilter jwtAuthenticationFilter) throws Exception {
        ObjectMapper objectMapper = new ObjectMapper();
        http
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 放行错误转发，避免异常时 /error 再次被拦截导致 “response already committed”。
                        .requestMatchers("/error").permitAll()
                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint((request, response, authException) ->
                                writeJson(response, objectMapper,
                                        HttpServletResponse.SC_UNAUTHORIZED, Result.failed(ResultCode.UNAUTHORIZED)))
                        .accessDeniedHandler((request, response, deniedException) ->
                                writeJson(response, objectMapper,
                                        HttpServletResponse.SC_FORBIDDEN, Result.failed(ResultCode.FORBIDDEN))));
        return http.build();
    }

    private void writeJson(HttpServletResponse response, ObjectMapper objectMapper,
                           int status, Result<?> result) throws IOException {
        response.setStatus(status);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter writer = response.getWriter()) {
            writer.write(objectMapper.writeValueAsString(result));
            writer.flush();
        }
    }
}