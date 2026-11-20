package com.zerok.orderservice.service;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.product.ProductSkuQuery;
import com.asyouwish.contract.product.ProductSkuSnapshot;
import com.asyouwish.contract.stock.StockReservationRequest;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zerok.orderservice.clients.ProductClient;
import com.zerok.orderservice.dto.CreateOrderRequest;
import com.zerok.orderservice.dto.OrderResponse;
import com.zerok.orderservice.entity.OrdItem;
import com.zerok.orderservice.entity.OrderStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Orchestrates order creation, trusted product lookup, and idempotent stock reservation.
 */
@Service
@RequiredArgsConstructor
public class OrderApplicationService {

    private final ProductClient productClient;
    private final OrderStockCoordinator stockCoordinator;
    private final OrderPersistenceService orderPersistenceService;
    private final ObjectMapper objectMapper;

    /**
     * Creates or resumes an order using a client-supplied idempotency key scoped to the user.
     */
    public OrderResponse createOrder(long userId, String idempotencyKey, CreateOrderRequest request) {
        validateIdempotencyKey(idempotencyKey);
        validateUniqueSkuLines(request);
        String digest = requestDigest(userId, request);

        OrderWorkflowSnapshot existing = orderPersistenceService.findExisting(userId, idempotencyKey, digest);
        if (existing != null) {
            if (existing.isCreationComplete()) {
                return orderPersistenceService.toResponse(existing);
            }
            return reserveAndComplete(existing);
        }

        Map<Long, ProductSkuSnapshot> products = findProducts(request);
        OrderWorkflowSnapshot workflow = orderPersistenceService.createOrResume(
                userId, idempotencyKey, digest, request, products);
        if (workflow.isCreationComplete()) {
            return orderPersistenceService.toResponse(workflow);
        }
        return reserveAndComplete(workflow);
    }

    /**
     * Returns the authenticated user's completed order and stored item snapshots.
     */
    public OrderResponse findOrder(long userId, String orderNo) {
        return orderPersistenceService.toResponse(orderPersistenceService.findVisibleOrder(userId, orderNo));
    }

    /**
     * Releases stock before closing the order, so a failed release never reports cancellation as complete.
     */
    public OrderResponse cancelOrder(long userId, String orderNo) {
        OrderWorkflowSnapshot current = orderPersistenceService.findVisibleOrder(userId, orderNo);
        if (current.order().getOrderStatus() != OrderStatus.PENDING_PAYMENT.code()) {
            throw new OrderBusinessException(HttpStatus.CONFLICT, "Only pending orders can be cancelled");
        }
        stockCoordinator.releaseAfterCancellation(orderNo);
        return orderPersistenceService.toResponse(orderPersistenceService.markCancelled(userId, orderNo));
    }

    private Map<Long, ProductSkuSnapshot> findProducts(CreateOrderRequest request) {
        List<Long> skuIds = request.items().stream().map(CreateOrderRequest.OrderLineRequest::skuId)
                .distinct().toList();
        ApiResponse<List<ProductSkuSnapshot>> response;
        try {
            response = productClient.findSellableSkus(new ProductSkuQuery(skuIds));
        } catch (DownstreamServiceException exception) {
            throw exception;
        } catch (RuntimeException exception) {
            throw new DownstreamServiceException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Product service is temporarily unavailable");
        }
        if (response == null || response.code() != HttpStatus.OK.value() || response.data() == null) {
            throw new DownstreamServiceException(HttpStatus.BAD_GATEWAY,
                    "Product service returned an invalid response");
        }

        Map<Long, ProductSkuSnapshot> products = new LinkedHashMap<>();
        response.data().forEach(product -> products.put(product.skuId(), product));
        Set<Long> missingSkuIds = new LinkedHashSet<>(skuIds);
        missingSkuIds.removeAll(products.keySet());
        if (!missingSkuIds.isEmpty()) {
            throw new OrderBusinessException(HttpStatus.CONFLICT,
                    "One or more products are unavailable for purchase");
        }
        return products;
    }

    private OrderResponse reserveAndComplete(OrderWorkflowSnapshot workflow) {
        StockReservationRequest reservationRequest = new StockReservationRequest(
                workflow.order().getId(),
                workflow.order().getOrderNo(),
                workflow.items().stream()
                        .map(item -> new StockReservationRequest.ReservationLine(item.getSkuId(), item.getQuantity()))
                        .toList());
        try {
            stockCoordinator.reserve(reservationRequest);
        } catch (DownstreamServiceException exception) {
            if (exception.status().is4xxClientError() && exception.status() != HttpStatus.BAD_GATEWAY) {
                orderPersistenceService.failCreation(workflow, exception.status(), exception.getMessage());
            }
            throw exception;
        } catch (RuntimeException exception) {
            throw new DownstreamServiceException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Stock service is temporarily unavailable");
        }
        orderPersistenceService.completeCreation(workflow);
        return orderPersistenceService.toResponse(workflow);
    }

    private void validateIdempotencyKey(String idempotencyKey) {
        if (idempotencyKey == null || idempotencyKey.isBlank() || idempotencyKey.length() > 128) {
            throw new OrderBusinessException(HttpStatus.BAD_REQUEST, "A valid Idempotency-Key is required");
        }
    }

    private void validateUniqueSkuLines(CreateOrderRequest request) {
        Set<Long> skuIds = new LinkedHashSet<>();
        for (CreateOrderRequest.OrderLineRequest item : request.items()) {
            if (!skuIds.add(item.skuId())) {
                throw new OrderBusinessException(HttpStatus.BAD_REQUEST,
                        "Each SKU must appear only once in an order");
            }
        }
    }

    private String requestDigest(long userId, CreateOrderRequest request) {
        try {
            byte[] canonicalRequest = objectMapper.writeValueAsBytes(new DigestInput(userId, request));
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(canonicalRequest);
            return HexFormat.of().formatHex(digest);
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Could not serialize order request for idempotency", exception);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    /**
     * Includes the authenticated owner in the idempotency digest so keys cannot cross users.
     */
    private record DigestInput(long userId, CreateOrderRequest request) {
    }
}
