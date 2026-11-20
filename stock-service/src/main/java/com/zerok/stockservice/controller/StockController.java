package com.zerok.stockservice.controller;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.stock.StockReservation;
import com.asyouwish.contract.stock.StockReservationRequest;
import com.asyouwish.contract.stock.StockSnapshot;
import com.asyouwish.contract.stock.StockTransitionResult;
import com.zerok.stockservice.service.StockService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 库存服务 HTTP API，负责校验请求并将库存领域能力暴露给授权服务调用方。
 */
@Validated
@RestController
@RequestMapping("/stock")
public class StockController {
    private final StockService service;
    public StockController(StockService service) { this.service = service; }

    @GetMapping("/sku/{skuId}")
    public ApiResponse<StockSnapshot> findBySkuId(@PathVariable @Positive long skuId) {
        return ApiResponse.success(service.findBySkuId(skuId));
    }

    @PostMapping("/reservations")
    public ApiResponse<List<StockReservation>> reserve(@Valid @RequestBody StockReservationRequest request) {
        return ApiResponse.success(service.reserve(request));
    }

    @PostMapping("/reservations/{orderNo}/confirm")
    public ApiResponse<StockTransitionResult> confirm(@PathVariable String orderNo) {
        return ApiResponse.success(service.confirm(orderNo));
    }

    @PostMapping("/reservations/{orderNo}/release")
    public ApiResponse<StockTransitionResult> release(@PathVariable String orderNo) {
        return ApiResponse.success(service.release(orderNo));
    }
}
