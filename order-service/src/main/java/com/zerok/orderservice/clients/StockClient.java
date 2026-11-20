package com.zerok.orderservice.clients;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.stock.StockReservation;
import com.asyouwish.contract.stock.StockReservationRequest;
import com.asyouwish.contract.stock.StockSnapshot;
import com.asyouwish.contract.stock.StockTransitionResult;
import com.zerok.orderfeign.InternalServiceFeignConfiguration;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

/**
 * Feign 契约客户端，调用库存服务完成库存查询和订单库存状态流转。
 */
@FeignClient(name = "stock-service", configuration = InternalServiceFeignConfiguration.class)
public interface StockClient {

    /**
     * 查询单个 SKU 的库存摘要。
     */
    @GetMapping("/stock/sku/{skuId}")
    ApiResponse<StockSnapshot> findById(@PathVariable("skuId") long skuId);

    /**
     * 为订单预占库存。
     */
    @PostMapping("/stock/reservations")
    ApiResponse<List<StockReservation>> reserve(@RequestBody StockReservationRequest request);

    /**
     * 支付成功后确认库存预占。
     */
    @PostMapping("/stock/reservations/{orderNo}/confirm")
    ApiResponse<StockTransitionResult> confirm(@PathVariable("orderNo") String orderNo);

    /**
     * 订单取消后释放库存预占。
     */
    @PostMapping("/stock/reservations/{orderNo}/release")
    ApiResponse<StockTransitionResult> release(@PathVariable("orderNo") String orderNo);
}
