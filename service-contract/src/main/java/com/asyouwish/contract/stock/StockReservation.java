package com.asyouwish.contract.stock;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 库存服务确认或释放后的预占记录摘要。
 */
public record StockReservation(String reservationNo,
                               long skuId,
                               long warehouseId,
                               BigDecimal quantity,
                               int status,
                               LocalDateTime expiresAt) {
}
