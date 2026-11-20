package com.zerok.orderservice.entity;

/**
 * The locked idempotency row used to resume or replay an order creation request.
 */
public record OrderIdempotencyRecord(long id,
                                     String requestDigest,
                                     int status,
                                     String responseCode,
                                     String responseBody) {
}
