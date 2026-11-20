package com.zerok.orderservice.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.zerok.orderservice.dto.CreateOrderRequest;
import com.zerok.orderservice.dto.OrderResponse;
import com.zerok.orderservice.entity.OrdItem;
import com.zerok.orderservice.entity.OrdOrder;
import com.zerok.orderservice.entity.OrderIdempotencyRecord;
import com.zerok.orderservice.entity.OrderStatus;
import com.zerok.orderservice.mapper.OrderMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Owns local order transactions and the durable state used to resume idempotent stock workflows.
 */
@Service
@RequiredArgsConstructor
public class OrderPersistenceService {

    private static final String SERVICE_NAME = "order-service";
    private static final String CREATE_OPERATION_PREFIX = "create-order:";
    private static final BigDecimal ZERO_AMOUNT = new BigDecimal("0.00");
    private static final BigDecimal MAX_ORDER_AMOUNT = new BigDecimal("9999999999.99");
    private static final int ORDER_EXPIRY_MINUTES = 30;

    private final OrderMapper orderMapper;
    private final ObjectMapper objectMapper;

    /**
     * Returns an existing request state or creates the order and its immutable product snapshots.
     */
    @Transactional
    public OrderWorkflowSnapshot createOrResume(long userId,
                                                String idempotencyKey,
                                                String requestDigest,
                                                CreateOrderRequest request,
                                                Map<Long, ProductSkuSnapshot> products) {
        String operation = operation(userId);
        orderMapper.acquireIdempotency(SERVICE_NAME, operation, idempotencyKey, requestDigest,
                LocalDateTime.now().plusDays(1));
        OrderIdempotencyRecord record = orderMapper.findIdempotencyForUpdate(
                SERVICE_NAME, operation, idempotencyKey);
        verifyDigest(record, requestDigest);
        rejectTerminalFailure(record);

        OrderPointer pointer = readPointer(record.responseBody());
        if (pointer == null) {
            OrdOrder order = createHeader(userId, request);
            orderMapper.insertOrder(order);
            List<OrdItem> items = createItems(order, request, products);
            orderMapper.insertItems(items);
            pointer = new OrderPointer(order.getId(), order.getOrderNo(), null, null);
            orderMapper.saveOrderPointer(record.id(), writePointer(pointer));
            record = new OrderIdempotencyRecord(record.id(), record.requestDigest(), record.status(),
                    "ORDER_CREATED", writePointer(pointer));
            return new OrderWorkflowSnapshot(record, order, items);
        }

        OrdOrder order = requireOrder(pointer.orderNo(), userId);
        return new OrderWorkflowSnapshot(record, order, orderMapper.findItemsByOrderId(order.getId()));
    }

    /**
     * Looks up an existing idempotency key before calling Product, preserving the original price snapshot.
     */
    @Transactional(readOnly = true)
    public OrderWorkflowSnapshot findExisting(long userId, String idempotencyKey, String requestDigest) {
        OrderIdempotencyRecord record = orderMapper.findIdempotency(
                SERVICE_NAME, operation(userId), idempotencyKey);
        if (record == null) {
            return null;
        }
        verifyDigest(record, requestDigest);
        rejectTerminalFailure(record);
        OrderPointer pointer = readPointer(record.responseBody());
        if (pointer == null) {
            return null;
        }
        OrdOrder order = requireOrder(pointer.orderNo(), userId);
        return new OrderWorkflowSnapshot(record, order, orderMapper.findItemsByOrderId(order.getId()));
    }

    /**
     * Marks the stock reservation workflow complete after Stock confirms the idempotent reserve request.
     */
    @Transactional
    public void completeCreation(OrderWorkflowSnapshot snapshot) {
        if (snapshot.idempotency().status() == 0) {
            orderMapper.completeIdempotency(snapshot.idempotency().id());
        }
    }

    /**
     * Closes an order after a terminal stock rejection and stores the failure for same-key replays.
     */
    @Transactional
    public void failCreation(OrderWorkflowSnapshot snapshot, HttpStatus status, String message) {
        orderMapper.closePendingOrder(snapshot.order().getId(), snapshot.order().getAuthUserId(),
                message, LocalDateTime.now());
        OrderPointer pointer = new OrderPointer(snapshot.order().getId(), snapshot.order().getOrderNo(),
                status.value(), message);
        orderMapper.failIdempotency(snapshot.idempotency().id(), String.valueOf(status.value()), writePointer(pointer));
    }

    /**
     * Reads only an order whose create request finished reserving stock, and enforces owner isolation.
     */
    @Transactional(readOnly = true)
    public OrderWorkflowSnapshot findVisibleOrder(long userId, String orderNo) {
        if (!orderMapper.isCreationComplete(orderNo, userId)) {
            throw new OrderBusinessException(HttpStatus.NOT_FOUND, "Order not found");
        }
        OrdOrder order = requireOrder(orderNo, userId);
        return new OrderWorkflowSnapshot(null, order, orderMapper.findItemsByOrderId(order.getId()));
    }

    /**
     * Closes a pending-payment order after Stock has successfully released its reservation.
     */
    @Transactional
    public OrderWorkflowSnapshot markCancelled(long userId, String orderNo) {
        OrderWorkflowSnapshot current = findVisibleOrder(userId, orderNo);
        if (current.order().getOrderStatus() != OrderStatus.PENDING_PAYMENT.code()) {
            throw new OrderBusinessException(HttpStatus.CONFLICT, "Only pending orders can be cancelled");
        }
        int updated = orderMapper.closePendingOrder(current.order().getId(), userId,
                "Cancelled by customer", LocalDateTime.now());
        if (updated != 1) {
            throw new OrderBusinessException(HttpStatus.CONFLICT, "Order state changed; reload and retry");
        }
        current.order().setOrderStatus(OrderStatus.CLOSED.code());
        return current;
    }

    /**
     * Maps stored order snapshots into the service API response.
     */
    public OrderResponse toResponse(OrderWorkflowSnapshot snapshot) {
        OrdOrder order = snapshot.order();
        List<OrderResponse.OrderLineResponse> lines = snapshot.items().stream()
                .map(item -> new OrderResponse.OrderLineResponse(item.getSkuId(), item.getSkuCode(),
                        item.getProductName(), item.getSkuName(), item.getSpecJson(), item.getImageUrl(),
                        item.getUnitPrice(), item.getQuantity(), item.getLineAmount()))
                .toList();
        return new OrderResponse(order.getId(), order.getOrderNo(), order.getOrderStatus(),
                order.getTotalAmount(), order.getPayAmount(), order.getReceiverName(), order.getReceiverPhone(),
                order.getReceiverAddress(), lines, order.getCreateTime());
    }

    private OrdOrder createHeader(long userId, CreateOrderRequest request) {
        LocalDateTime now = LocalDateTime.now();
        OrdOrder order = new OrdOrder();
        order.setOrderNo("ORD" + UUID.randomUUID().toString().replace("-", ""));
        order.setAuthUserId(userId);
        order.setOrderType(1);
        order.setTotalAmount(ZERO_AMOUNT);
        order.setPayAmount(ZERO_AMOUNT);
        order.setDiscountAmount(ZERO_AMOUNT);
        order.setFreightAmount(ZERO_AMOUNT);
        order.setOrderStatus(OrderStatus.PENDING_PAYMENT.code());
        order.setRefundStatus(0);
        order.setReceiverName(request.receiverName());
        order.setReceiverPhone(request.receiverPhone());
        order.setReceiverAddress(request.receiverAddress());
        order.setNote(request.note());
        order.setExpireTime(now.plusMinutes(ORDER_EXPIRY_MINUTES));
        order.setCreateTime(now);
        order.setUpdateTime(now);
        order.setCreateBy(userId);
        order.setUpdateBy(userId);
        return order;
    }

    private List<OrdItem> createItems(OrdOrder order,
                                      CreateOrderRequest request,
                                      Map<Long, ProductSkuSnapshot> products) {
        List<OrdItem> items = request.items().stream().map(line -> {
            ProductSkuSnapshot product = products.get(line.skuId());
            BigDecimal lineAmount = product.salePrice().multiply(line.quantity()).setScale(2, RoundingMode.HALF_UP);
            OrdItem item = new OrdItem();
            item.setOrderId(order.getId());
            item.setOrderNo(order.getOrderNo());
            item.setSkuId(product.skuId());
            item.setSpuId(product.spuId());
            item.setSkuCode(product.skuCode());
            item.setProductName(product.productName());
            item.setSkuName(product.skuName());
            item.setSpecJson(product.specJson());
            item.setImageUrl(product.imageUrl());
            item.setUnitPrice(product.salePrice());
            item.setQuantity(line.quantity());
            item.setLineAmount(lineAmount);
            item.setDiscountAmount(ZERO_AMOUNT);
            item.setPayAmount(lineAmount);
            item.setAfterSaleQuantity(BigDecimal.ZERO.setScale(3));
            item.setCreatedAt(order.getCreateTime());
            return item;
        }).toList();
        BigDecimal totalAmount = items.stream().map(OrdItem::getLineAmount)
                .reduce(ZERO_AMOUNT, BigDecimal::add).setScale(2, RoundingMode.UNNECESSARY);
        if (totalAmount.compareTo(MAX_ORDER_AMOUNT) > 0) {
            throw new OrderBusinessException(HttpStatus.BAD_REQUEST, "Order amount exceeds supported limit");
        }
        order.setTotalAmount(totalAmount);
        order.setPayAmount(totalAmount);
        return items;
    }

    private OrdOrder requireOrder(String orderNo, long userId) {
        OrdOrder order = orderMapper.findOrderByNoAndUser(orderNo, userId);
        if (order == null) {
            throw new OrderBusinessException(HttpStatus.NOT_FOUND, "Order not found");
        }
        return order;
    }

    private void verifyDigest(OrderIdempotencyRecord record, String requestDigest) {
        if (!record.requestDigest().equals(requestDigest)) {
            throw new OrderBusinessException(HttpStatus.CONFLICT,
                    "Idempotency key was already used with a different request");
        }
    }

    private void rejectTerminalFailure(OrderIdempotencyRecord record) {
        if (record.status() == 2) {
            OrderPointer pointer = readPointer(record.responseBody());
            int status = pointer != null && pointer.failureStatus() != null ? pointer.failureStatus() : 409;
            String message = pointer != null && pointer.failureMessage() != null
                    ? pointer.failureMessage() : "Order creation failed; use a new idempotency key to retry";
            throw new OrderBusinessException(HttpStatus.valueOf(status), message);
        }
    }

    private OrderPointer readPointer(String responseBody) {
        if (responseBody == null || responseBody.isBlank()) {
            return null;
        }
        try {
            return objectMapper.readValue(responseBody, OrderPointer.class);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Stored order idempotency response is invalid", exception);
        }
    }

    private String writePointer(OrderPointer pointer) {
        try {
            return objectMapper.writeValueAsString(pointer);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Could not serialize order idempotency state", exception);
        }
    }

    private String operation(long userId) {
        return CREATE_OPERATION_PREFIX + userId;
    }

    /**
     * Small durable pointer stored in the idempotency JSON column.
     */
    private record OrderPointer(long orderId, String orderNo, Integer failureStatus, String failureMessage) {
    }
}
