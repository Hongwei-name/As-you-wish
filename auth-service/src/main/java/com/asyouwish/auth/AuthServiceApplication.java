package com.asyouwish.auth;

import com.asyouwish.auth.config.MinioConfig;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;


import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
@MapperScan("com.asyouwish.auth.mapper")
@EnableConfigurationProperties(MinioConfig.class)
public class AuthServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(AuthServiceApplication.class, args);
    }
}
