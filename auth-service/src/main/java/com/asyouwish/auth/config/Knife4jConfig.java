package com.asyouwish.auth.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Knife4jConfig {

    @Bean
    public OpenAPI authOpenApi() {
        return new OpenAPI().info(new Info()
                .title("认证服务接口文档")
                .description("auth-service 登录注册接口")
                .version("1.0"));
    }

    @Bean
    public GroupedOpenApi defaultApi() {
        return GroupedOpenApi.builder()
                .group("auth")
                .packagesToScan("com.asyouwish.auth.controller")
                .pathsToMatch("/auth/**")
                .build();
    }
}
