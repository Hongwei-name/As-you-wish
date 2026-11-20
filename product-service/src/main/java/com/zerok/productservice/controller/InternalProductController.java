package com.zerok.productservice.controller;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.product.ProductSkuQuery;
import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.zerok.productservice.service.ProductCatalogService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 内部商品 API，为下游提供下单时使用的批量可售 SKU 快照。
 */
@RestController
@RequestMapping("/internal/products")
@RequiredArgsConstructor
public class InternalProductController {

    private final ProductCatalogService productCatalogService;

    /**
     * 返回有效 SKU；无效 SKU 被省略，由调用方据此拒绝订单。
     */
    @PostMapping("/skus:batch")
    public ApiResponse<List<ProductSkuSnapshot>> findSellableSkus(@Valid @RequestBody ProductSkuQuery query) {
        return ApiResponse.success(productCatalogService.findSellableSkus(query.skuIds()));
    }
}
