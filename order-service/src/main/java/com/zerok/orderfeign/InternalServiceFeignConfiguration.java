package com.zerok.orderfeign;

import com.zerok.orderservice.clients.OrderFeignErrorDecoder;
import feign.RequestInterceptor;
import feign.codec.ErrorDecoder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Feign-only configuration kept outside Order's component scan to avoid affecting unrelated beans.
 */
@Configuration
public class InternalServiceFeignConfiguration {

    @Bean
    public ErrorDecoder orderFeignErrorDecoder() {
        return new OrderFeignErrorDecoder();
    }

    /**
     * Supplies an internal credential without forwarding the end user's JWT.
     */
    @Bean
    public RequestInterceptor internalServiceTokenInterceptor(
            @Value("${service-auth.internal-token:}") String internalToken) {
        return template -> {
            if (internalToken == null || internalToken.isBlank()) {
                throw new IllegalStateException("INTERNAL_SERVICE_TOKEN must be configured for service calls");
            }
            template.header("X-Internal-Service-Token", internalToken);
        };
    }
}
