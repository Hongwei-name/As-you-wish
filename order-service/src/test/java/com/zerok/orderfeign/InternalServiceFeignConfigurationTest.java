package com.zerok.orderfeign;

import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;

/**
 * Verifies internal Feign calls carry only the dedicated service credential.
 */
class InternalServiceFeignConfigurationTest {

    @Test
    void addsTheInternalCredentialWithoutSettingUserAuthorization() {
        RequestInterceptor interceptor =
                new InternalServiceFeignConfiguration().internalServiceTokenInterceptor("service-secret");
        RequestTemplate request = new RequestTemplate();

        interceptor.apply(request);

        assertEquals("service-secret", request.headers().get("X-Internal-Service-Token").iterator().next());
        assertFalse(request.headers().containsKey("Authorization"));
    }

    @Test
    void refusesToSendARequestWithoutConfiguredCredential() {
        RequestInterceptor interceptor =
                new InternalServiceFeignConfiguration().internalServiceTokenInterceptor("");

        assertThrows(IllegalStateException.class, () -> interceptor.apply(new RequestTemplate()));
    }
}
