package com.zerok.orderservice.service;

import org.springframework.http.HttpStatus;

/**
 * Represents a sanitized downstream failure and the HTTP status exposed by Order API.
 */
public class DownstreamServiceException extends RuntimeException {

    private final HttpStatus status;

    public DownstreamServiceException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus status() {
        return status;
    }
}
