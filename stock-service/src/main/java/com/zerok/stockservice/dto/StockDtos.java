package com.zerok.stockservice.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public final class StockDtos {
    private StockDtos() {}
    public record StockResponse(long skuId,BigDecimal totalQuantity,BigDecimal reservedQuantity,BigDecimal availableQuantity) {}
    public record ReservationRequest(@Positive long orderId,@NotBlank String orderNo,@NotEmpty List<@Valid ReservationLine> items) {}
    public record ReservationLine(@Positive long skuId,@DecimalMin(value="0.001") BigDecimal quantity) {}
    public record ReservationResponse(String reservationNo,long skuId,long warehouseId,BigDecimal quantity,int status,LocalDateTime expiresAt) {}
    public record ReservationResponses(List<ReservationResponse> reservations) {}
    public record ReservationResult(String orderNo,int updatedReservations) {}
}
