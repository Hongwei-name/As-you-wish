package com.zerok.orderservice.clients;

import com.asyouwish.contract.product.ProductSkuQuery;
import com.zerok.orderservice.service.DownstreamServiceException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.HttpStatus;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Opt-in live Nacos check for Product and Stock Feign discovery, authentication, and error mapping.
 */
@SpringBootTest
@EnabledIfSystemProperty(named = "service.integration.enabled", matches = "true")
class OrderFeignDiscoveryIntegrationTest {

    @Autowired
    private ProductClient productClient;

    @Autowired
    private StockClient stockClient;

    @Test
    void discoversProductAndStockByServiceNameWithoutWritingBusinessData() {
        var products = productClient.findSellableSkus(new ProductSkuQuery(List.of(Long.MAX_VALUE)));

        assertEquals(200, products.code());
        assertNotNull(products.data());
        assertTrue(products.data().isEmpty());

        DownstreamServiceException missingStock = assertThrows(DownstreamServiceException.class,
                () -> stockClient.findById(Long.MAX_VALUE));
        assertEquals(HttpStatus.BAD_GATEWAY, missingStock.status());
    }
}
