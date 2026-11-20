package com.zerok.productservice.service;

import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.zerok.productservice.mapper.ProductSkuMapper;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;

/**
 * 提供订单和其他内部消费者使用的商品目录查询能力。
 */
@Service
public class ProductCatalogService {

    private final ProductSkuMapper productSkuMapper;

    public ProductCatalogService(ProductSkuMapper productSkuMapper) {
        this.productSkuMapper = productSkuMapper;
    }

    /**
     * 按请求顺序返回仍处于可售状态的 SKU；失效或不存在的 ID 不会被返回。
     */
    public List<ProductSkuSnapshot> findSellableSkus(List<Long> skuIds) {
        List<Long> uniqueIds = skuIds.stream().distinct().toList();
        LinkedHashMap<Long, ProductSkuSnapshot> snapshots = new LinkedHashMap<>();
        productSkuMapper.findSellableSkus(uniqueIds).forEach(sku -> snapshots.put(sku.skuId(), sku));
        return uniqueIds.stream().map(snapshots::get).filter(java.util.Objects::nonNull).toList();
    }
}
