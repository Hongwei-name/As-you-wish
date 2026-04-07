package com.shopping.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * JWT 配置类
 * 从配置文件读取 JWT 相关配置
 * 
 * @author 陈洪伟
 */
@Data
@Component
@ConfigurationProperties(prefix = "jwt")
public class JwtConfig {

    /**
     * JWT 密钥
     */
    private String secret;

    /**
     * JWT 过期时间（毫秒）
     */
    private Long expiration;

    /**
     * JWT 请求头名称
     */
    private String header;

    /**
     * JWT Token 前缀
     */
    private String prefix;

}
