package com.zerok.productservice.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * 将内部服务身份校验应用到商品服务的内部 API 路径。
 */
@Configuration
@RequiredArgsConstructor
public class InternalApiWebConfiguration implements WebMvcConfigurer {

    private final InternalServiceTokenInterceptor tokenInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(tokenInterceptor).addPathPatterns("/internal/**");
    }
}
