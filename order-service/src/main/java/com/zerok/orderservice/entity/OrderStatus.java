package com.zerok.orderservice.entity;

/**
 * Status values defined by the existing ord_order.order_status column.
 */
public enum OrderStatus {
    PENDING_PAYMENT(0),
    PAID(1),
    SHIPPED(2),
    COMPLETED(3),
    CLOSED(4),
    REFUNDED(5);

    private final int code;

    OrderStatus(int code) {
        this.code = code;
    }

    public int code() {
        return code;
    }
}
