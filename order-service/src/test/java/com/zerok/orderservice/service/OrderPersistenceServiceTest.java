package com.zerok.orderservice.service;

import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zerok.orderservice.dto.CreateOrderRequest;
import com.zerok.orderservice.entity.OrdItem;
import com.zerok.orderservice.entity.OrdOrder;
import com.zerok.orderservice.entity.OrderIdempotencyRecord;
import com.zerok.orderservice.mapper.OrderMapper;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Verifies transactional order snapshot creation and durable idempotency pointers.
 */
class OrderPersistenceServiceTest {

    private final OrderMapper mapper = mock(OrderMapper.class);
    private final OrderPersistenceService service = new OrderPersistenceService(mapper, new ObjectMapper());

    @Test
    void createsPricedOrderLinesAndStoresARecoveryPointer() {
        when(mapper.acquireIdempotency(anyString(), anyString(), anyString(), anyString(), any())).thenReturn(1);
        when(mapper.findIdempotencyForUpdate(anyString(), anyString(), anyString()))
                .thenReturn(new OrderIdempotencyRecord(41, "digest", 0, null, null));
        when(mapper.insertOrder(any(OrdOrder.class))).thenAnswer(invocation -> {
            OrdOrder order = invocation.getArgument(0);
            order.setId(501L);
            return 1;
        });
        when(mapper.insertItems(any())).thenReturn(1);
        when(mapper.saveOrderPointer(eq(41L), anyString())).thenReturn(1);

        OrderWorkflowSnapshot result = service.createOrResume(7L, "key-1", "digest", request(),
                Map.of(8L, product()));

        assertTrue(result.order().getOrderNo().startsWith("ORD"));
        assertEquals(new BigDecimal("25.00"), result.order().getTotalAmount());
        assertEquals(new BigDecimal("25.00"), result.order().getPayAmount());
        assertEquals(501L, result.order().getId());
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<OrdItem>> itemsCaptor =
                (ArgumentCaptor<List<OrdItem>>) (ArgumentCaptor<?>) ArgumentCaptor.forClass(List.class);
        verify(mapper).insertItems(itemsCaptor.capture());
        assertEquals(new BigDecimal("12.50"), itemsCaptor.getValue().get(0).getUnitPrice());
        assertEquals(new BigDecimal("2.000"), itemsCaptor.getValue().get(0).getQuantity());
        ArgumentCaptor<String> pointerCaptor = ArgumentCaptor.forClass(String.class);
        verify(mapper).saveOrderPointer(eq(41L), pointerCaptor.capture());
        assertNotNull(pointerCaptor.getValue());
        assertEquals("ORDER_CREATED", result.idempotency().responseCode());
    }

    @Test
    void resumesExistingOrderWithoutRecreatingItsSnapshots() {
        when(mapper.findIdempotency(anyString(), anyString(), anyString()))
                .thenReturn(new OrderIdempotencyRecord(41, "digest", 1, "200",
                        "{\"orderId\":501,\"orderNo\":\"ORD-501\",\"failureStatus\":null,\"failureMessage\":null}"));
        when(mapper.findOrderByNoAndUser("ORD-501", 7L)).thenReturn(order(501L, "ORD-501"));
        when(mapper.findItemsByOrderId(501L)).thenReturn(List.of());

        OrderWorkflowSnapshot existing = service.findExisting(7L, "key-1", "digest");

        assertNotNull(existing);
        assertEquals("ORD-501", existing.order().getOrderNo());
        assertTrue(existing.isCreationComplete());
        verify(mapper, org.mockito.Mockito.never()).insertOrder(any());
    }

    private CreateOrderRequest request() {
        return new CreateOrderRequest("用户", "13812345678", "收货地址", null,
                List.of(new CreateOrderRequest.OrderLineRequest(8, new BigDecimal("2.000"))));
    }

    private ProductSkuSnapshot product() {
        return new ProductSkuSnapshot(8, 3, "SKU-8", "商品", "蓝色",
                "{\"color\":\"blue\"}", null, new BigDecimal("12.50"));
    }

    private OrdOrder order(long id, String orderNo) {
        OrdOrder order = new OrdOrder();
        order.setId(id);
        order.setOrderNo(orderNo);
        order.setAuthUserId(7L);
        order.setOrderStatus(0);
        return order;
    }
}
