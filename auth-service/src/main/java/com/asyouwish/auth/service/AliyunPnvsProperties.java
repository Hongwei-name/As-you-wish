package com.asyouwish.auth.service;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 阿里云 PNVS（号码认证-短信认证）配置。
 * 测试/生产通过 application-test.yml / application-prod.yml 引用不同环境变量。
 */
@Data
@Component
@ConfigurationProperties(prefix = "aliyun.pnvs")
public class AliyunPnvsProperties {

    private String accessKeyId;
    private String accessKeySecret;
    private String endpoint = "dypnsapi.aliyuncs.com";
    private String signName;
    private String countryCode = "86";
    private Long codeLength = 6L;
    private Long codeType = 1L;
    private Long validTime = 300L;
    private Long interval = 60L;
    private Long duplicatePolicy = 1L;
    private String templateParam = "{\"code\":\"##code##\",\"min\":\"5\"}";
    private String templateCode;
    private String registerTemplateCode;
    private String loginTemplateCode;
    private String resetPasswordTemplateCode;
    private String registerSchemeName;
    private String loginSchemeName;
    private String resetPasswordSchemeName;
    private RateLimit rateLimit = new RateLimit();

    public String templateCodeFor(SmsScene scene) {
        String code = switch (scene) {
            case REGISTER -> registerTemplateCode;
            case LOGIN -> loginTemplateCode;
            case RESET_PASSWORD -> resetPasswordTemplateCode;
        };
        return StringUtils.hasText(code) ? code : templateCode;
    }

    public String schemeNameFor(SmsScene scene) {
        String name = switch (scene) {
            case REGISTER -> registerSchemeName;
            case LOGIN -> loginSchemeName;
            case RESET_PASSWORD -> resetPasswordSchemeName;
        };
        return StringUtils.hasText(name) ? name : null;
    }

    @Data
    public static class RateLimit {
        private int ipPerMinute = 10;
        private int phoneDaily = 10;
        private int ipDaily = 20;
    }
}
