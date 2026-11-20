package com.zerok.orderservice.config;

import com.asyouwish.contract.ApiResponse;
import com.zerok.orderservice.service.DownstreamServiceException;
import com.zerok.orderservice.service.OrderBusinessException;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

/**
 * Converts request, order-domain, and downstream failures to the shared API response shape.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleInvalidBody(MethodArgumentNotValidException exception) {
        return failure(HttpStatus.BAD_REQUEST, "Invalid request parameters");
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ResponseEntity<ApiResponse<Void>> handleConstraintViolation(ConstraintViolationException exception) {
        return failure(HttpStatus.BAD_REQUEST, "Invalid request parameters");
    }

    @ExceptionHandler(OrderBusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(OrderBusinessException exception) {
        return failure(exception.status(), exception.getMessage());
    }

    @ExceptionHandler(DownstreamServiceException.class)
    public ResponseEntity<ApiResponse<Void>> handleDownstreamException(DownstreamServiceException exception) {
        return failure(exception.status(), exception.getMessage());
    }

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<ApiResponse<Void>> handleStatusException(ResponseStatusException exception) {
        HttpStatus status = HttpStatus.valueOf(exception.getStatusCode().value());
        return failure(status, exception.getReason() == null ? status.getReasonPhrase() : exception.getReason());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleUnexpectedException(Exception exception) {
        log.error("Order request failed with {}", exception.getClass().getSimpleName());
        return failure(HttpStatus.INTERNAL_SERVER_ERROR, "Order service could not complete the request");
    }

    private ResponseEntity<ApiResponse<Void>> failure(HttpStatus status, String message) {
        return ResponseEntity.status(status).body(ApiResponse.failure(status.value(), message));
    }
}
