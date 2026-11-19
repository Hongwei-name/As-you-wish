package com.zerok.orderservice.dto;

/**
 * 库存服务查询响应。订单服务只消费此契约，不依赖库存服务的持久化实体。
 */
public record Stock(long id, long availableQuantity) {
}
