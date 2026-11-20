package com.zerok.orderservice.controller;

import com.asyouwish.contract.ApiResponse;
import com.zerok.orderservice.dto.CreateOrderRequest;
import com.zerok.orderservice.dto.OrderResponse;
import com.zerok.orderservice.service.OrderApplicationService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Authenticated order API; user ownership always comes from the verified JWT principal.
 */
@Validated
@RestController
@RequiredArgsConstructor
@RequestMapping("/orders")
public class OrderController {

    private final OrderApplicationService orderApplicationService;

    /**
     * Creates an order from server-priced product snapshots and reserves its stock.
     */
    @PostMapping
    public ApiResponse<OrderResponse> createOrder(
            @AuthenticationPrincipal Long userId,
            @RequestHeader("Idempotency-Key") @NotBlank @Size(max = 128) String idempotencyKey,
            @Valid @RequestBody CreateOrderRequest request) {
        return ApiResponse.success(orderApplicationService.createOrder(userId, idempotencyKey, request));
    }

    /**
     * Reads an order only when it belongs to the authenticated user.
     */
    @GetMapping("/{orderNo}")
    public ApiResponse<OrderResponse> findOrder(@AuthenticationPrincipal Long userId,
                                                @PathVariable @NotBlank @Size(max = 64) String orderNo) {
        return ApiResponse.success(orderApplicationService.findOrder(userId, orderNo));
    }

    /**
     * Releases the order's inventory reservation before marking a pending order closed.
     */
    @PostMapping("/{orderNo}/cancel")
    public ApiResponse<OrderResponse> cancelOrder(@AuthenticationPrincipal Long userId,
                                                  @PathVariable @NotBlank @Size(max = 64) String orderNo) {
        return ApiResponse.success(orderApplicationService.cancelOrder(userId, orderNo));
    }
}
