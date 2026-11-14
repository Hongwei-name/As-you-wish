package com.asyouwish.auth.config;

import com.asyouwish.auth.util.Result;
import com.asyouwish.auth.util.ResultCode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@Configuration
@EnableWebSecurity // 开启 Web 安全支持
public class SecurityConfig {

    /**
     * Argon2id 参数说明
     * 1. salt长度：16字节
     * 2. hash输出长度：32字节
     * 3. 并行度：1（线程数，服务器多核可以调大）
     * 4. 内存消耗：16384 KB = 16MB，越高越抗GPU破解
     * 5. 迭代次数：2轮
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new Argon2PasswordEncoder(16, 32, 1, 16384, 2);
    }

    /**
     * 禁止 Spring Boot 把 JWT 过滤器自动注册为普通 Servlet Filter。
     * 它必须只由 SecurityFilterChain 执行，否则会在 Security 上下文初始化前运行并丢失认证信息。
     */
    @Bean
    public FilterRegistrationBean<JwtAuthenticationFilter> jwtFilterRegistration(
            JwtAuthenticationFilter jwtAuthenticationFilter) {
        FilterRegistrationBean<JwtAuthenticationFilter> registration =
                new FilterRegistrationBean<>(jwtAuthenticationFilter);
        registration.setEnabled(false);
        return registration;
    }

    /**
     * 配置安全过滤链
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http,
                                           JwtAuthenticationFilter jwtAuthenticationFilter) throws Exception {
        // 引入 Jackson 对象，用于将 Result 对象转为 JSON 输出到前端
        ObjectMapper objectMapper = new ObjectMapper();

        http
                // 1. 前后端分离项目，关闭 CSRF 跨站请求伪造防护
                .csrf(csrf -> csrf.disable())
                // 2. 关闭默认的表单登录
                .formLogin(form -> form.disable())
                // 3. 关闭 HTTP Basic 认证（关闭弹窗）
                .httpBasic(basic -> basic.disable())
                // 4. 因为使用 JWT，所以禁用 Session
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // 5. 配置请求拦截规则
                .authorizeHttpRequests(auth -> auth
                        // 放行 Knife4j 接口文档相关的资源路径
                        .requestMatchers("/doc.html", "/webjars/**", "/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                        // 放行登录、注册、发送验证码、密码重置接口
                        .requestMatchers("/auth/sms/send", "/auth/register/**", "/auth/login/**",
                                "/auth/captcha/**", "/auth/password/**").permitAll()

                        // 其他所有请求都需要认证
                        .anyRequest().authenticated()
                )
                // JWT 过滤器：解析 Bearer Token 并写入 SecurityContext
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                // 6. 自定义异常处理（未登录或无权限时，返回统一的 JSON 格式，而不是 HTML 页面）
                .exceptionHandling(exception -> exception
                        // 未登录（没有 Token 或 Token 无效）时的处理
                        .authenticationEntryPoint((request, response, authException) -> {
                            writeJson(response, objectMapper, HttpServletResponse.SC_UNAUTHORIZED, Result.failed(ResultCode.UNAUTHORIZED));
                        })
                        // 已登录但没有权限访问时的处理
                        .accessDeniedHandler((request, response, accessDeniedException) -> {
                            writeJson(response, objectMapper, HttpServletResponse.SC_FORBIDDEN, Result.failed(ResultCode.FORBIDDEN));
                        })
                );

        return http.build();
    }

    /**
     * 抽取一个公共方法，用于向 HttpServletResponse 写入 JSON 数据
     */
    private void writeJson(HttpServletResponse response, ObjectMapper objectMapper, int status, Result<?> result) throws IOException {
        // 设置响应状态码
        response.setStatus(status);
        // 设置字符集和内容类型
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        // 将 Result 对象序列化为 JSON 字符串，并写入响应流
        try (PrintWriter writer = response.getWriter()) {
            writer.write(objectMapper.writeValueAsString(result));
            writer.flush();
        }
    }
}