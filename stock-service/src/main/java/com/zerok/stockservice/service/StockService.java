package com.zerok.stockservice.service;

import com.asyouwish.contract.stock.StockReservation;
import com.asyouwish.contract.stock.StockReservationRequest;
import com.asyouwish.contract.stock.StockSnapshot;
import com.asyouwish.contract.stock.StockTransitionResult;
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

/**
 * 库存域业务服务，使用行锁保证预占安全并将每次变更写入库存流水。
 */
@Service
public class StockService {
    private static final int RESERVATION_MINUTES = 30;
    private final StockMapper mapper;

    public StockService(StockMapper mapper) { this.mapper = mapper; }

    @Transactional(readOnly = true)
    public StockSnapshot findBySkuId(long skuId) {
        StockRow row = mapper.findBySkuId(skuId);
        if (row == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "SKU stock not found");
        return new StockSnapshot(skuId, row.totalQuantity(), row.reservedQuantity(), row.availableQuantity());
    }

    @Transactional
    public List<StockReservation> reserve(StockReservationRequest request) {
        Set<Long> skuIds = new HashSet<>();
        for (StockReservationRequest.ReservationLine item : request.items()) {
            if (!skuIds.add(item.skuId())) throw new ResponseStatusException(HttpStatus.BAD_REQUEST,"Duplicate SKU");
        }
        List<ReservationRow> existingReservations = mapper.findReservations(request.orderNo());
        if (!existingReservations.isEmpty()) {
            return replayReservationRequest(request, existingReservations);
        }
        return request.items().stream().map(item -> reserveOne(request,item)).toList();
    }

    private List<StockReservation> replayReservationRequest(StockReservationRequest request,
                                                            List<ReservationRow> existingReservations) {
        if (existingReservations.size() != request.items().size()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Reservation request does not match existing order");
        }
        for (ReservationRow existing : existingReservations) {
            StockReservationRequest.ReservationLine requested = request.items().stream()
                    .filter(item -> item.skuId() == existing.skuId())
                    .findFirst()
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.CONFLICT, "Reservation request does not match existing order"));
            if (existing.orderId() != request.orderId()
                    || existing.status() != 0
                    || existing.quantity().compareTo(requested.quantity()) != 0) {
                throw new ResponseStatusException(HttpStatus.CONFLICT,
                        "Reservation request does not match existing order");
            }
        }
        return request.items().stream()
                .map(item -> existingReservations.stream()
                        .filter(reservation -> reservation.skuId() == item.skuId())
                        .findFirst()
                        .map(StockService::response)
                        .orElseThrow(() -> new ResponseStatusException(
                                HttpStatus.CONFLICT, "Reservation request does not match existing order")))
                .toList();
    }

    private StockReservation reserveOne(StockReservationRequest request, StockReservationRequest.ReservationLine item) {
        List<StockRow> stocks = mapper.lockStocksForSku(item.skuId());
        ReservationRow existing = mapper.findReservation(request.orderNo(),item.skuId());
        if (existing != null) {
            if (existing.orderId() != request.orderId())
                throw new ResponseStatusException(HttpStatus.CONFLICT,"Order identity does not match reservation");
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

    private StockReservation createReservation(StockReservationRequest request,
                                               StockReservationRequest.ReservationLine item, StockRow stock) {
        LocalDateTime expiresAt = LocalDateTime.now().plusMinutes(RESERVATION_MINUTES);
        String reservationNo = reservationNo(request.orderNo(),item.skuId());
        mapper.insertReservation(new ReservationRow(null,reservationNo,request.orderId(),request.orderNo(),
                item.skuId(),stock.warehouseId(),item.quantity(),0,expiresAt));
        StockRow after = mapper.lockStock(item.skuId(),stock.warehouseId());
        mapper.insertLedger(new LedgerRow(item.skuId(),stock.warehouseId(),3,reservationNo,BigDecimal.ZERO,
                after.totalQuantity(),after.reservedQuantity()));
        return new StockReservation(reservationNo,item.skuId(),stock.warehouseId(),item.quantity(),0,expiresAt);
    }

    @Transactional
    public StockTransitionResult confirm(String orderNo) { return transition(orderNo, true); }

    @Transactional
    public StockTransitionResult release(String orderNo) { return transition(orderNo, false); }

    private StockTransitionResult transition(String orderNo, boolean confirm) {
        List<ReservationRow> rows = mapper.findActiveReservations(orderNo);
        if (rows.isEmpty()) return replayOrRejectTransition(orderNo, confirm);
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
        return new StockTransitionResult(orderNo,updated);
    }

    private StockTransitionResult replayOrRejectTransition(String orderNo, boolean confirm) {
        List<ReservationRow> reservations = mapper.findReservations(orderNo);
        if (reservations.isEmpty())
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Reservation not found");
        int expectedStatus = confirm ? 1 : 2;
        if (reservations.stream().allMatch(row -> row.status() == expectedStatus))
            return new StockTransitionResult(orderNo, 0);
        throw new ResponseStatusException(HttpStatus.CONFLICT, "Reservation already completed with a different state");
    }

    private static StockReservation response(ReservationRow row) {
        return new StockReservation(row.reservationNo(),row.skuId(),row.warehouseId(),row.quantity(),row.status(),row.expireAt());
    }

    private static String reservationNo(String orderNo,long skuId) {
        try {
            byte[] digest=MessageDigest.getInstance("SHA-256").digest((orderNo+":"+skuId).getBytes(StandardCharsets.UTF_8));
            return "RSV-"+HexFormat.of().formatHex(digest,0,24);
        } catch (NoSuchAlgorithmException e) { throw new IllegalStateException("SHA-256 unavailable",e); }
    }
}
