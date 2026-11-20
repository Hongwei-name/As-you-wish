package com.zerok.orderservice.config;

import com.asyouwish.contract.ApiResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import java.io.IOException;

/**
 * Configures stateless JWT authorization for user-owned order endpoints.
 */
@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class OrderSecurityConfiguration {

    private final ObjectMapper objectMapper;

    @Bean
    public FilterRegistrationBean<OrderJwtAuthenticationFilter> jwtFilterRegistration(
            OrderJwtAuthenticationFilter filter) {
        FilterRegistrationBean<OrderJwtAuthenticationFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    public SecurityFilterChain orderSecurityFilterChain(HttpSecurity http,
                                                        OrderJwtAuthenticationFilter jwtFilter) throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .formLogin(form -> form.disable())
                .httpBasic(basic -> basic.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/error").permitAll()
                        .anyRequest().authenticated())
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class)
                .exceptionHandling(exception -> exception
                        .authenticationEntryPoint((request, response, error) ->
                                writeFailure(response, HttpStatus.UNAUTHORIZED))
                        .accessDeniedHandler((request, response, error) ->
                                writeFailure(response, HttpStatus.FORBIDDEN)))
                .build();
    }

    private void writeFailure(HttpServletResponse response, HttpStatus status) throws IOException {
        response.setStatus(status.value());
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        objectMapper.writeValue(response.getOutputStream(),
                ApiResponse.failure(status.value(), status == HttpStatus.UNAUTHORIZED ? "Unauthorized" : "Forbidden"));
    }
}
