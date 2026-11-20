package com.zerok.productservice.service;

import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.zerok.productservice.mapper.ProductSkuMapper;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Unit tests for Product's sellable SKU query behavior.
 */
class ProductCatalogServiceTest {

    private final ProductSkuMapper mapper = mock(ProductSkuMapper.class);
    private final ProductCatalogService service = new ProductCatalogService(mapper);

    @Test
    void returnsSellableSnapshotsInRequestOrderAndDeduplicatesIds() {
        ProductSkuSnapshot first = snapshot(8);
        ProductSkuSnapshot second = snapshot(3);
        when(mapper.findSellableSkus(List.of(8L, 3L))).thenReturn(List.of(second, first));

        List<ProductSkuSnapshot> result = service.findSellableSkus(List.of(8L, 3L, 8L));

        assertEquals(List.of(8L, 3L), result.stream().map(ProductSkuSnapshot::skuId).toList());
        verify(mapper).findSellableSkus(List.of(8L, 3L));
    }

    private ProductSkuSnapshot snapshot(long skuId) {
        return new ProductSkuSnapshot(skuId, 2, "SKU-" + skuId, "商品", "规格",
                "{\"color\":\"blue\"}", null, new BigDecimal("12.50"));
    }
}
