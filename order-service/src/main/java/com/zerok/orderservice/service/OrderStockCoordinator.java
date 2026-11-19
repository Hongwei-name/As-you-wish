package com.zerok.orderservice.service;

import com.zerok.orderservice.clients.StockClient;
import com.zerok.orderservice.dto.StockReservation;
import com.zerok.orderservice.dto.StockReservationResult;
import com.zerok.orderservice.dto.StockTransitionResult;
import org.springframework.stereotype.Service;

@Service
public class OrderStockCoordinator {
    private final StockClient stockClient;

    public OrderStockCoordinator(StockClient stockClient) { this.stockClient = stockClient; }

    public StockReservationResult.ReservationResponses reserve(StockReservation request) {
        return stockClient.reserve(request);
    }

    public StockTransitionResult confirmAfterPayment(String orderNo) {
        return stockClient.confirm(orderNo);
    }

    public StockTransitionResult releaseAfterCancellation(String orderNo) {
        return stockClient.release(orderNo);
    }
}
