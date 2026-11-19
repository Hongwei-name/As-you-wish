package com.zerok.orderservice.clients;

import com.zerok.orderservice.dto.Stock;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "stock-service")
public interface StockClient {

    @GetMapping("/stock/{id}")
    Stock findById(@PathVariable("id") long id);
}
