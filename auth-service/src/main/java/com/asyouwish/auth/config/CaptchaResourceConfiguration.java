package com.asyouwish.auth.config;

import cloud.tianai.captcha.common.constant.CaptchaTypeConstant;
import cloud.tianai.captcha.resource.CrudResourceStore;
import cloud.tianai.captcha.resource.ResourceStore;
import cloud.tianai.captcha.resource.common.model.dto.Resource;
import cloud.tianai.captcha.spring.plugins.RedisResourceStore;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.StringRedisTemplate;

@Configuration
public class CaptchaResourceConfiguration {

    private static final String DEFAULT_TAG = "default";

    /**
     * TianAI 1.5.6 的自动配置仅在已有 ResourceStore 时才创建验证码应用，
     * 不会自行注册资源存储实现。复用 Starter 提供的 Redis 实现，保证多实例共享资源配置。
     */
    @Bean
    @ConditionalOnMissingBean(ResourceStore.class)
    public CrudResourceStore captchaResourceStore(StringRedisTemplate redisTemplate) {
        return new RedisResourceStore(redisTemplate);
    }

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
