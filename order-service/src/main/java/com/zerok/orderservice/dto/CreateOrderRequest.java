package com.zerok.orderservice.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.util.List;

/**
 * 下单请求只携带 SKU、数量和收货快照，不接收客户端价格或用户 ID。
 */
public record CreateOrderRequest(
        @NotBlank @Size(max = 50) String receiverName,
        @NotBlank @Pattern(regexp = "^1[3-9]\\d{9}$") String receiverPhone,
        @NotBlank @Size(max = 255) String receiverAddress,
        @Size(max = 500) String note,
        @NotEmpty @Size(max = 100) List<@Valid OrderLineRequest> items
) {
    /**
     * 请求购买的 SKU 与数量。
     */
    public record OrderLineRequest(
            @Positive long skuId,
            @NotNull @Positive @Digits(integer = 9, fraction = 3) BigDecimal quantity
    ) {
    }
}
