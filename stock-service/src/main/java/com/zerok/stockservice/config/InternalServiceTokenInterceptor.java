package com.zerok.stockservice.config;

import com.asyouwish.contract.ApiResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/**
 * Protects stock reads and mutations with a dedicated service-to-service credential.
 */
@Component
public class InternalServiceTokenInterceptor implements HandlerInterceptor {

    private static final String TOKEN_HEADER = "X-Internal-Service-Token";

    private final String expectedToken;
    private final ObjectMapper objectMapper;

    public InternalServiceTokenInterceptor(
            @Value("${service-auth.internal-token:}") String expectedToken,
            ObjectMapper objectMapper) {
        this.expectedToken = expectedToken;
        this.objectMapper = objectMapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws IOException {
        if (expectedToken == null || expectedToken.isBlank()) {
            writeFailure(response, HttpServletResponse.SC_SERVICE_UNAVAILABLE, "Internal service credential is not configured");
            return false;
        }
        String presentedToken = request.getHeader(TOKEN_HEADER);
        if (presentedToken == null || !MessageDigest.isEqual(
                expectedToken.getBytes(StandardCharsets.UTF_8), presentedToken.getBytes(StandardCharsets.UTF_8))) {
            writeFailure(response, HttpServletResponse.SC_UNAUTHORIZED, "Invalid internal service credential");
            return false;
        }
        return true;
    }

    private void writeFailure(HttpServletResponse response, int status, String message) throws IOException {
        response.setStatus(status);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setContentType("application/json;charset=UTF-8");
        objectMapper.writeValue(response.getOutputStream(), ApiResponse.failure(status, message));
    }
}
