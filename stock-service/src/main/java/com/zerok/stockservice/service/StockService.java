package com.zerok.stockservice.service;

import com.zerok.stockservice.dto.StockDtos;
import com.zerok.stockservice.mapper.StockMapper;
import com.zerok.stockservice.mapper.StockMapper.LedgerRow;
import com.zerok.stockservice.mapper.StockMapper.ReservationRow;
import com.zerok.stockservice.mapper.StockMapper.StockRow;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;

@Service
public class StockService {
    private static final int RESERVATION_MINUTES = 30;
    private final StockMapper mapper;

    public StockService(StockMapper mapper) { this.mapper = mapper; }

    @Transactional(readOnly = true)
    public StockDtos.StockResponse findBySkuId(long skuId) {
        StockRow row = mapper.findBySkuId(skuId);
        if (row == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "SKU stock not found");
        return new StockDtos.StockResponse(skuId,row.totalQuantity(),row.reservedQuantity(),row.availableQuantity());
    }

    @Transactional
    public List<StockDtos.ReservationResponse> reserve(StockDtos.ReservationRequest request) {
        Set<Long> skuIds = new HashSet<>();
        for (StockDtos.ReservationLine item : request.items()) {
            if (!skuIds.add(item.skuId())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Duplicate SKU");
        }
        return request.items().stream().map(item -> reserveOne(request,item)).toList();
    }

    private StockDtos.ReservationResponse reserveOne(StockDtos.ReservationRequest request, StockDtos.ReservationLine item) {
        List<StockRow> stocks = mapper.lockStocksForSku(item.skuId());
        ReservationRow existing = mapper.findReservation(request.orderNo(),item.skuId());
        if (existing != null) {
            if (existing.quantity().compareTo(item.quantity()) != 0 || existing.status() != 0)
                throw new ResponseStatusException(HttpStatus.CONFLICT,"Reservation already exists with a different state");
            return response(existing);
        }
        for (StockRow stock : stocks) {
            if (stock.availableQuantity().compareTo(item.quantity()) < 0) continue;
            if (mapper.reserve(stock.id(),item.quantity()) == 1) return createReservation(request,item,stock);
        }
        throw new ResponseStatusException(HttpStatus.CONFLICT,"Insufficient stock for SKU " + item.skuId());
    }

    private StockDtos.ReservationResponse createReservation(StockDtos.ReservationRequest request,
                                                             StockDtos.ReservationLine item, StockRow stock) {
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(RESERVATION_MINUTES);
        String reservationNo = reservationNo(request.orderNo(),item.skuId());
        mapper.insertReservation(new ReservationRow(null,reservationNo,request.orderId(),request.orderNo(),
                item.skuId(),stock.warehouseId(),item.quantity(),0,expiresAt));
        StockRow after = mapper.lockStock(item.skuId(),stock.warehouseId());
        mapper.insertLedger(new LedgerRow(item.skuId(),stock.warehouseId(),3,reservationNo,BigDecimal.ZERO,
                after.totalQuantity(),after.reservedQuantity()));
        return new StockDtos.ReservationResponse(reservationNo,item.skuId(),stock.warehouseId(),item.quantity(),0,expiresAt);
    }

    @Transactional
    public StockDtos.ReservationResult confirm(String orderNo) { return transition(orderNo,true); }

    @Transactional
    public StockDtos.ReservationResult release(String orderNo) { return transition(orderNo,false); }

    private StockDtos.ReservationResult transition(String orderNo,boolean confirm) {
        List<ReservationRow> rows = mapper.findActiveReservations(orderNo);
        int updated=0;
        for (ReservationRow reservation : rows) {
            StockRow stock=mapper.lockStock(reservation.skuId(),reservation.warehouseId());
            if (stock==null) throw new ResponseStatusException(HttpStatus.CONFLICT,"Stock record missing");
            int changed=confirm ? mapper.confirm(stock.id(),reservation.quantity()) : mapper.release(stock.id(),reservation.quantity());
            if (changed!=1 || mapper.updateReservationStatus(reservation.id(),confirm?1:2)!=1)
                throw new ResponseStatusException(HttpStatus.CONFLICT,"Reservation state changed concurrently");
            StockRow after=mapper.lockStock(reservation.skuId(),reservation.warehouseId());
            mapper.insertLedger(new LedgerRow(reservation.skuId(),reservation.warehouseId(),confirm?2:4,
                    (confirm?"CONFIRM-":"RELEASE-")+reservation.reservationNo(),
                    confirm?reservation.quantity().negate():BigDecimal.ZERO,after.totalQuantity(),after.reservedQuantity()));
            updated++;
        }
        return new StockDtos.ReservationResult(orderNo,updated);
    }

    private static StockDtos.ReservationResponse response(ReservationRow row) {
        return new StockDtos.ReservationResponse(row.reservationNo(),row.skuId(),row.warehouseId(),row.quantity(),row.status(),row.expireAt());
    }

    private static String reservationNo(String orderNo,long skuId) {
        try {
            byte[] digest=MessageDigest.getInstance("SHA-256").digest((orderNo+":"+skuId).getBytes(StandardCharsets.UTF_8));
            return "RSV-"+HexFormat.of().formatHex(digest,0,24);
        } catch (NoSuchAlgorithmException e) { throw new IllegalStateException("SHA-256 unavailable",e); }
    }
}
