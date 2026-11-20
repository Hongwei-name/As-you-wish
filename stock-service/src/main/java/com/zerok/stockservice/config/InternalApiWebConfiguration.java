package com.zerok.stockservice.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Applies internal service authentication to stock APIs that are not public storefront endpoints.
 */
@Configuration
@RequiredArgsConstructor
public class InternalApiWebConfiguration implements WebMvcConfigurer {

    private final InternalServiceTokenInterceptor tokenInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(tokenInterceptor).addPathPatterns("/stock/**");
    }
}
