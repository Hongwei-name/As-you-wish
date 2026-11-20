package com.asyouwish.contract.stock;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.util.List;

/**
 * 订单服务请求库存服务预占库存的契约。
 */
public record StockReservationRequest(
        @Positive long orderId,
        @NotBlank String orderNo,
        @NotEmpty List<@Valid ReservationLine> items
) {
    /**
     * 单个 SKU 的预占数量。
     */
    public record ReservationLine(@Positive long skuId,
                                  @DecimalMin(value = "0.001")
                                  @Digits(integer = 9, fraction = 3)
                                  BigDecimal quantity) {
    }
}
