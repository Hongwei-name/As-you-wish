package com.zerok.stockservice.controller;

import com.zerok.stockservice.dto.StockDtos;
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

@Validated
@RestController
@RequestMapping("/stock")
public class StockController {
    private final StockService service;
    public StockController(StockService service) { this.service=service; }

    @GetMapping("/sku/{skuId}")
    public StockDtos.StockResponse findBySkuId(@PathVariable @Positive long skuId) {
        return service.findBySkuId(skuId);
    }

    @PostMapping("/reservations")
    public StockDtos.ReservationResponses reserve(@Valid @RequestBody StockDtos.ReservationRequest request) {
        return new StockDtos.ReservationResponses(service.reserve(request));
    }

    @PostMapping("/reservations/{orderNo}/confirm")
    public StockDtos.ReservationResult confirm(@PathVariable String orderNo) { return service.confirm(orderNo); }

    @PostMapping("/reservations/{orderNo}/release")
    public StockDtos.ReservationResult release(@PathVariable String orderNo) { return service.release(orderNo); }
}
