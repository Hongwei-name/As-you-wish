package com.zerok.orderservice.service;

import org.springframework.http.HttpStatus;

/**
 * Represents a validated order-domain failure with a stable HTTP response status.
 */
public class OrderBusinessException extends RuntimeException {

    private final HttpStatus status;

    public OrderBusinessException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus status() {
        return status;
    }
}
