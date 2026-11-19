package com.zerok.orderservice.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public record StockReservationResult(List<Reservation> reservations) {
    public record Reservation(String reservationNo,long skuId,long warehouseId,BigDecimal quantity,int status,LocalDateTime expiresAt) {}
    public record ReservationResponses(List<Reservation> reservations) {}
}
