package com.zerok.orderservice.service;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.asyouwish.contract.stock.StockReservation;
import com.zerok.orderservice.clients.ProductClient;
import com.zerok.orderservice.dto.CreateOrderRequest;
import com.zerok.orderservice.dto.OrderResponse;
import com.zerok.orderservice.entity.OrdItem;
import com.zerok.orderservice.entity.OrdOrder;
import com.zerok.orderservice.entity.OrderIdempotencyRecord;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Tests order orchestration at the Product, idempotency, and Stock service boundaries.
 */
class OrderApplicationServiceTest {

    private final ProductClient productClient = mock(ProductClient.class);
    private final OrderStockCoordinator stockCoordinator = mock(OrderStockCoordinator.class);
    private final OrderPersistenceService persistenceService = mock(OrderPersistenceService.class);
    private final OrderApplicationService service =
            new OrderApplicationService(productClient, stockCoordinator, persistenceService,
                    new com.fasterxml.jackson.databind.ObjectMapper());

    @Test
    void createsFromProductPriceAndReservesStock() {
        CreateOrderRequest request = request();
        OrderWorkflowSnapshot workflow = workflow(0);
        OrderResponse response = response();
        when(persistenceService.findExisting(eq(7L), eq("key-1"), anyString())).thenReturn(null);
        when(productClient.findSellableSkus(any()))
                .thenReturn(ApiResponse.success(List.of(product())));
        when(persistenceService.createOrResume(eq(7L), eq("key-1"), anyString(), eq(request), anyMap()))
                .thenReturn(workflow);
        when(stockCoordinator.reserve(any())).thenReturn(List.of(
                new StockReservation("RSV-1", 8, 2, new BigDecimal("2.000"), 0,
                        LocalDateTime.now().plusMinutes(30))));
        when(persistenceService.toResponse(workflow)).thenReturn(response);

        OrderResponse result = service.createOrder(7L, "key-1", request);

        assertEquals("ORD-1", result.orderNo());
        verify(stockCoordinator).reserve(any());
        verify(persistenceService).completeCreation(workflow);
    }

    @Test
    void replaysCompletedOrderWithoutCallingProductOrStock() {
        OrderWorkflowSnapshot completed = workflow(1);
        OrderResponse response = response();
        when(persistenceService.findExisting(eq(7L), eq("key-1"), anyString())).thenReturn(completed);
        when(persistenceService.toResponse(completed)).thenReturn(response);

        OrderResponse result = service.createOrder(7L, "key-1", request());

        assertEquals("ORD-1", result.orderNo());
        verify(productClient, never()).findSellableSkus(any());
        verify(stockCoordinator, never()).reserve(any());
    }

    @Test
    void rejectsUnavailableSkuBeforePersistingAnOrder() {
        when(persistenceService.findExisting(eq(7L), eq("key-1"), anyString())).thenReturn(null);
        when(productClient.findSellableSkus(any())).thenReturn(ApiResponse.success(List.of()));

        assertThrows(OrderBusinessException.class, () -> service.createOrder(7L, "key-1", request()));
        verify(persistenceService, never()).createOrResume(anyLong(), anyString(),
                anyString(), any(), anyMap());
    }

    @Test
    void closesOrderAndPersistsTerminalStockConflictForSameKeyReplay() {
        CreateOrderRequest request = request();
        OrderWorkflowSnapshot workflow = workflow(0);
        when(persistenceService.findExisting(eq(7L), eq("key-1"), anyString())).thenReturn(null);
        when(productClient.findSellableSkus(any()))
                .thenReturn(ApiResponse.success(List.of(product())));
        when(persistenceService.createOrResume(eq(7L), eq("key-1"), anyString(), eq(request), anyMap()))
                .thenReturn(workflow);
        doThrow(new DownstreamServiceException(HttpStatus.CONFLICT, "Stock reservation conflicted"))
                .when(stockCoordinator).reserve(any());

        assertThrows(DownstreamServiceException.class, () -> service.createOrder(7L, "key-1", request));
        verify(persistenceService).failCreation(workflow, HttpStatus.CONFLICT, "Stock reservation conflicted");
    }

    private CreateOrderRequest request() {
        return new CreateOrderRequest("用户", "13812345678", "收货地址", null,
                List.of(new CreateOrderRequest.OrderLineRequest(8, new BigDecimal("2.000"))));
    }

    private ProductSkuSnapshot product() {
        return new ProductSkuSnapshot(8, 3, "SKU-8", "商品", "蓝色",
                "{\"color\":\"blue\"}", "https://example.test/image.jpg", new BigDecimal("12.50"));
    }

    private OrderWorkflowSnapshot workflow(int idempotencyStatus) {
        OrderIdempotencyRecord record = new OrderIdempotencyRecord(10, "digest", idempotencyStatus,
                "ORDER_CREATED", "{\"orderId\":11,\"orderNo\":\"ORD-1\"}");
        OrdOrder order = new OrdOrder();
        order.setId(11L);
        order.setOrderNo("ORD-1");
        order.setAuthUserId(7L);
        order.setOrderStatus(0);
        order.setTotalAmount(new BigDecimal("25.00"));
        order.setPayAmount(new BigDecimal("25.00"));
        order.setReceiverName("用户");
        order.setReceiverPhone("13812345678");
        order.setReceiverAddress("收货地址");
        order.setCreateTime(LocalDateTime.now());
        OrdItem item = new OrdItem();
        item.setOrderId(11L);
        item.setOrderNo("ORD-1");
        item.setSkuId(8L);
        item.setQuantity(new BigDecimal("2.000"));
        item.setUnitPrice(new BigDecimal("12.50"));
        item.setLineAmount(new BigDecimal("25.00"));
        return new OrderWorkflowSnapshot(record, order, List.of(item));
    }

    private OrderResponse response() {
        return new OrderResponse(11, "ORD-1", 0, new BigDecimal("25.00"), new BigDecimal("25.00"),
                "用户", "13812345678", "收货地址", List.of(), LocalDateTime.now());
    }
}
