package com.asyouwish.contract.product;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;

/**
 * 订单服务批量查询可售 SKU 时使用的请求契约。
 */
public record ProductSkuQuery(
        @NotEmpty @Size(max = 100) List<@Positive Long> skuIds
) {
}
