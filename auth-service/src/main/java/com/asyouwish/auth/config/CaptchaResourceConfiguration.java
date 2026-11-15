package com.asyouwish.auth.config;

import cloud.tianai.captcha.common.constant.CaptchaTypeConstant;
import cloud.tianai.captcha.resource.CrudResourceStore;
import cloud.tianai.captcha.resource.common.model.dto.Resource;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;

@Configuration
public class CaptchaResourceConfiguration {

    private static final String DEFAULT_TAG = "default";

    @Bean
    public ApplicationRunner captchaResourceInitializer(CrudResourceStore resourceStore) {
        return args -> {
            if (!resourceStore.listResourcesByTypeAndTag(CaptchaTypeConstant.SLIDER, DEFAULT_TAG).isEmpty()) {
                return;
            }
            resourceStore.addResource(CaptchaTypeConstant.SLIDER,
                    new Resource("classpath", "META-INF/cut-image/resource/1.jpg", DEFAULT_TAG));
        };
    }
}
