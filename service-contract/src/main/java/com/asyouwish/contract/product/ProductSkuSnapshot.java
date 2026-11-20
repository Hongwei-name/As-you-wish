package com.asyouwish.contract.product;

import java.math.BigDecimal;

/**
 * 商品服务提供给订单服务的可信 SKU 下单快照，不包含持久化实体。
 */
public record ProductSkuSnapshot(
        long skuId,
        long spuId,
        String skuCode,
        String productName,
        String skuName,
        String specJson,
        String imageUrl,
        BigDecimal salePrice
) {
}
