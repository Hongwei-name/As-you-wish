package com.zerok.orderservice.dto;

import java.math.BigDecimal;
import java.util.List;

public record StockReservation(long orderId,String orderNo,List<Item> items) {
    public record Item(long skuId,BigDecimal quantity) {}
}
