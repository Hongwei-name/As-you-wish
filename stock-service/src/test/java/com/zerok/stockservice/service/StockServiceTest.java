package com.zerok.stockservice.service;

import com.asyouwish.contract.stock.StockReservationRequest;
import com.zerok.stockservice.mapper.StockMapper;
import com.zerok.stockservice.mapper.StockMapper.LedgerRow;
import com.zerok.stockservice.mapper.StockMapper.ReservationRow;
import com.zerok.stockservice.mapper.StockMapper.StockRow;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Covers inventory reservation, conflict, and idempotent replay behavior.
 */
class StockServiceTest {
    private final StockMapper mapper=mock(StockMapper.class);
    private final StockService service=new StockService(mapper);

    @Test
    void reservesAvailableDatabaseStockAndWritesLedger() {
        when(mapper.findReservations("ORD-5")).thenReturn(List.of());
        when(mapper.lockStocksForSku(8)).thenReturn(List.of(stock(10,7,8,2,0),stock(11,9,8,4,0)));
        when(mapper.lockStock(8,7)).thenReturn(stock(10,7,8,2,2));
        when(mapper.reserve(10,new BigDecimal("2.000"))).thenReturn(1);
        when(mapper.findReservation("ORD-5",8)).thenReturn(null);
        when(mapper.insertReservation(any())).thenReturn(1);
        when(mapper.insertLedger(any(LedgerRow.class))).thenReturn(1);

        var result=service.reserve(request());

        assertEquals(1,result.size());
        assertEquals(0,result.get(0).status());
        verify(mapper).reserve(10,new BigDecimal("2.000"));
        verify(mapper).insertLedger(any(LedgerRow.class));
    }

    @Test
    void rejectsInsufficientStock() {
        when(mapper.findReservations("ORD-5")).thenReturn(List.of());
        when(mapper.lockStocksForSku(8)).thenReturn(List.of(stock(10,7,8,1,0)));
        when(mapper.findReservation("ORD-5",8)).thenReturn(null);
        assertThrows(ResponseStatusException.class,()->service.reserve(request()));
        verify(mapper,never()).reserve(anyLong(),any());
        verify(mapper,never()).insertLedger(any(LedgerRow.class));
    }

    @Test
    void returnsExistingReservationOnRetry() {
        when(mapper.findReservations("ORD-5")).thenReturn(List.of(
                new ReservationRow(4L,"RSV-4",5,"ORD-5",8,7,new BigDecimal("2.000"),0,
                        LocalDateTime.now().plusMinutes(10))));
        when(mapper.lockStocksForSku(8)).thenReturn(List.of(stock(10,7,8,2,0)));
        when(mapper.findReservation("ORD-5",8)).thenReturn(new ReservationRow(4L,"RSV-4",5,"ORD-5",8,7,
                new BigDecimal("2.000"),0,LocalDateTime.now().plusMinutes(10)));
        var result=service.reserve(request());
        assertEquals("RSV-4",result.get(0).reservationNo());
        verify(mapper,never()).reserve(anyLong(),any());
        verify(mapper,never()).insertLedger(any(LedgerRow.class));
    }

    @Test
    void rejectsRetryWhenSkuSetDiffersFromExistingReservations() {
        when(mapper.findReservations("ORD-5")).thenReturn(List.of(
                new ReservationRow(4L,"RSV-4",5,"ORD-5",8,7,new BigDecimal("2.000"),0,
                        LocalDateTime.now().plusMinutes(10))));
        StockReservationRequest changedRequest = new StockReservationRequest(5, "ORD-5", List.of(
                new StockReservationRequest.ReservationLine(9, new BigDecimal("2.000"))));

        assertThrows(ResponseStatusException.class, () -> service.reserve(changedRequest));
        verify(mapper, never()).reserve(anyLong(), any());
    }

    private static StockReservationRequest request() {
        return new StockReservationRequest(5,"ORD-5",List.of(new StockReservationRequest.ReservationLine(8,new BigDecimal("2.000"))));
    }

    private static StockRow stock(long id,long warehouseId,long skuId,int total,int reserved) {
        BigDecimal t=BigDecimal.valueOf(total),r=BigDecimal.valueOf(reserved);
        return new StockRow(id,skuId,warehouseId,t,r,t.subtract(r));
    }

    @Test
    void replaysAnAlreadyReleasedReservationWithoutChangingStockAgain() {
        when(mapper.findActiveReservations("ORD-5")).thenReturn(List.of());
        when(mapper.findReservations("ORD-5")).thenReturn(List.of(
                new ReservationRow(4L,"RSV-4",5,"ORD-5",8,7,new BigDecimal("2.000"),2,
                        LocalDateTime.now().minusMinutes(1))));

        var result = service.release("ORD-5");

        assertEquals("ORD-5", result.orderNo());
        assertEquals(0, result.updatedReservations());
        verify(mapper, never()).release(anyLong(), any());
    }

    @Test
    void rejectsConfirmingAReservationThatWasReleased() {
        when(mapper.findActiveReservations("ORD-5")).thenReturn(List.of());
        when(mapper.findReservations("ORD-5")).thenReturn(List.of(
                new ReservationRow(4L,"RSV-4",5,"ORD-5",8,7,new BigDecimal("2.000"),2,
                        LocalDateTime.now().minusMinutes(1))));

        assertThrows(ResponseStatusException.class, () -> service.confirm("ORD-5"));
        verify(mapper, never()).confirm(anyLong(), any());
    }
}
