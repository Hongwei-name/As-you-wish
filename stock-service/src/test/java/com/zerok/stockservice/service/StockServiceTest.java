package com.zerok.stockservice.service;

import com.zerok.stockservice.dto.StockDtos;
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

class StockServiceTest {
    private final StockMapper mapper=mock(StockMapper.class);
    private final StockService service=new StockService(mapper);

    @Test
    void reservesAvailableDatabaseStockAndWritesLedger() {
        when(mapper.lockStocksForSku(8)).thenReturn(List.of(stock(10,7,8,2),stock(11,9,8,4)));
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
        when(mapper.lockStocksForSku(8)).thenReturn(List.of(stock(10,7,8,9,1)));
        when(mapper.findReservation("ORD-5",8)).thenReturn(null);
        assertThrows(ResponseStatusException.class,()->service.reserve(request()));
        verify(mapper,never()).reserve(anyLong(),any());
        verify(mapper,never()).insertLedger(any(LedgerRow.class));
    }

    @Test
    void returnsExistingReservationOnRetry() {
        when(mapper.lockStocksForSku(8)).thenReturn(List.of(stock(10,7,8,2,0)));
        when(mapper.findReservation("ORD-5",8)).thenReturn(new ReservationRow(4L,"RSV-4",5,"ORD-5",8,7,
                new BigDecimal("2.000"),0,LocalDateTime.now().plusMinutes(10)));
        var result=service.reserve(request());
        assertEquals("RSV-4",result.get(0).reservationNo());
        verify(mapper,never()).reserve(anyLong(),any());
        verify(mapper,never()).insertLedger(any(LedgerRow.class));
    }

    private static StockDtos.ReservationRequest request() {
        return new StockDtos.ReservationRequest(5,"ORD-5",List.of(new StockDtos.ReservationLine(8,new BigDecimal("2.000"))));
    }

    private static StockRow stock(long id,long warehouseId,long skuId,int total,int reserved) {
        BigDecimal t=BigDecimal.valueOf(total),r=BigDecimal.valueOf(reserved);
        return new StockRow(id,skuId,warehouseId,t,r,t.subtract(r));
    }
}
