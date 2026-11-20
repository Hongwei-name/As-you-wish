package com.asyouwish.contract.stock;

import java.math.BigDecimal;

/**
 * 库存服务返回的 SKU 库存摘要。
 */
public record StockSnapshot(long skuId,
                            BigDecimal totalQuantity,
                            BigDecimal reservedQuantity,
                            BigDecimal availableQuantity) {
}
