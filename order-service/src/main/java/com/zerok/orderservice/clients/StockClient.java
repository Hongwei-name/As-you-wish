package com.zerok.orderservice.clients;

import com.zerok.orderservice.dto.Stock;
import com.zerok.orderservice.dto.StockReservation;
import com.zerok.orderservice.dto.StockReservationResult;
import com.zerok.orderservice.dto.StockTransitionResult;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name="stock-service")
public interface StockClient {
    @GetMapping("/stock/sku/{skuId}")
    Stock findById(@PathVariable("skuId") long skuId);

    @PostMapping("/stock/reservations")
    StockReservationResult.ReservationResponses reserve(@RequestBody StockReservation request);

    @PostMapping("/stock/reservations/{orderNo}/confirm")
    StockTransitionResult confirm(@PathVariable("orderNo") String orderNo);

    @PostMapping("/stock/reservations/{orderNo}/release")
    StockTransitionResult release(@PathVariable("orderNo") String orderNo);
}
