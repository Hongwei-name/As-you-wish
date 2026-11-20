package com.zerok.orderservice.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单对外视图，金额和商品信息来自订单快照而非实时商品表。
 */
public record OrderResponse(long orderId,
                            String orderNo,
                            int status,
                            BigDecimal totalAmount,
                            BigDecimal payAmount,
                            String receiverName,
                            String receiverPhone,
                            String receiverAddress,
                            List<OrderLineResponse> items,
                            LocalDateTime createdAt) {

    /**
     * 订单商品行快照视图。
     */
    public record OrderLineResponse(long skuId,
                                    String skuCode,
                                    String productName,
                                    String skuName,
                                    String specJson,
                                    String imageUrl,
                                    BigDecimal unitPrice,
                                    BigDecimal quantity,
                                    BigDecimal lineAmount) {
    }
}
