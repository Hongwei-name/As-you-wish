package com.zerok.orderservice.clients;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.product.ProductSkuQuery;
import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.zerok.orderfeign.InternalServiceFeignConfiguration;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

/**
 * Feign 契约客户端，按 Nacos 服务名调用商品服务获取可信下单快照。
 */
@FeignClient(name = "product-service", configuration = InternalServiceFeignConfiguration.class)
public interface ProductClient {

    /**
     * 批量读取仍可售的 SKU；返回结果可能不包含无效 SKU。
     */
    @PostMapping("/internal/products/skus:batch")
    ApiResponse<List<ProductSkuSnapshot>> findSellableSkus(@RequestBody ProductSkuQuery query);
}
