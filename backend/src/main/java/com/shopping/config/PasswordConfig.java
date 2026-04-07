package com.shopping.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/**
 * 密码加密配置类
 * 配置 BCrypt 密码加密器
 * 
 * @author 陈洪伟
 */
@Configuration
public class PasswordConfig {

    /**
     * 创建 BCrypt 密码加密器 Bean
     * 
     * @return BCryptPasswordEncoder 密码加密器
     */
    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}
