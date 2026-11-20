package com.asyouwish.contract.stock;

/**
 * 库存服务对某个订单执行确认或释放后的汇总结果。
 */
public record StockTransitionResult(String orderNo, int updatedReservations) {
}
