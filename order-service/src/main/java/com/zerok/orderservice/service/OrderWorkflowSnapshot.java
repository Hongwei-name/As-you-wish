package com.zerok.orderservice.service;

import com.zerok.orderservice.entity.OrdItem;
import com.zerok.orderservice.entity.OrdOrder;
import com.zerok.orderservice.entity.OrderIdempotencyRecord;

import java.util.List;

/**
 * Order header, line snapshots, and idempotency state loaded for one workflow step.
 */
public record OrderWorkflowSnapshot(OrderIdempotencyRecord idempotency,
                                    OrdOrder order,
                                    List<OrdItem> items) {

    /**
     * Indicates whether the remote stock reservation completed and the create request is replayable.
     */
    public boolean isCreationComplete() {
        return idempotency.status() == 1;
    }
}
