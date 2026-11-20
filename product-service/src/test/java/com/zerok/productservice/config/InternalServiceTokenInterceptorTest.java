package com.zerok.productservice.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Verifies fail-closed authentication for Product's internal endpoints.
 */
class InternalServiceTokenInterceptorTest {

    @Test
    void acceptsTheConfiguredServiceCredential() throws Exception {
        InternalServiceTokenInterceptor interceptor =
                new InternalServiceTokenInterceptor("service-secret", new ObjectMapper());
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("X-Internal-Service-Token", "service-secret");

        assertTrue(interceptor.preHandle(request, new MockHttpServletResponse(), new Object()));
    }

    @Test
    void rejectsMissingCredentialsAndFailsWhenNoCredentialIsConfigured() throws Exception {
        InternalServiceTokenInterceptor interceptor =
                new InternalServiceTokenInterceptor("service-secret", new ObjectMapper());
        MockHttpServletResponse unauthorized = new MockHttpServletResponse();
        assertFalse(interceptor.preHandle(new MockHttpServletRequest(), unauthorized, new Object()));
        assertTrue(unauthorized.getStatus() == 401);

        InternalServiceTokenInterceptor unconfigured =
                new InternalServiceTokenInterceptor("", new ObjectMapper());
        MockHttpServletResponse unavailable = new MockHttpServletResponse();
        assertFalse(unconfigured.preHandle(new MockHttpServletRequest(), unavailable, new Object()));
        assertTrue(unavailable.getStatus() == 503);
    }
}
