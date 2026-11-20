package com.zerok.orderservice.service;

import com.asyouwish.contract.ApiResponse;
import com.asyouwish.contract.stock.StockReservation;
import com.asyouwish.contract.stock.StockReservationRequest;
import com.asyouwish.contract.stock.StockSnapshot;
import com.asyouwish.contract.stock.StockTransitionResult;
import com.zerok.orderservice.clients.StockClient;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Coordinates the Order-to-Stock API boundary and validates shared response envelopes.
 */
@Service
@RequiredArgsConstructor
public class OrderStockCoordinator {

    private final StockClient stockClient;

    /**
     * Reserves every line in an order using the caller's stable order identity.
     */
    public List<StockReservation> reserve(StockReservationRequest request) {
        return requireData(stockClient.reserve(request), "Stock reservation did not return a result");
    }

    /**
     * Returns the current inventory summary for a SKU.
     */
    public StockSnapshot findBySku(long skuId) {
        return requireData(stockClient.findById(skuId), "Stock query did not return a result");
    }

    /**
     * Confirms an existing reservation after the payment domain reports success.
     */
    public StockTransitionResult confirmAfterPayment(String orderNo) {
        return requireData(stockClient.confirm(orderNo), "Stock confirmation did not return a result");
    }

    /**
     * Releases an existing reservation after a pending order is cancelled.
     */
    public StockTransitionResult releaseAfterCancellation(String orderNo) {
        return requireData(stockClient.release(orderNo), "Stock release did not return a result");
    }

    private <T> T requireData(ApiResponse<T> response, String failureMessage) {
        if (response == null || response.code() != HttpStatus.OK.value() || response.data() == null) {
            throw new DownstreamServiceException(HttpStatus.BAD_GATEWAY, failureMessage);
        }
        return response.data();
    }
}
