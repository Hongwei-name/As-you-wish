package com.zerok.stockservice.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface StockMapper {
    @Select("SELECT s.id,s.sku_id AS skuId,s.warehouse_id AS warehouseId,s.total_quantity AS totalQuantity," +
            "s.reserved_quantity AS reservedQuantity,s.available_quantity AS availableQuantity FROM wms_stock s " +
            "JOIN wms_warehouse w ON w.id=s.warehouse_id WHERE s.sku_id=#{skuId} AND w.status=1 " +
            "ORDER BY s.available_quantity DESC,s.id LIMIT 1")
    StockRow findBySkuId(@Param("skuId") long skuId);

    @Select("SELECT id,warehouse_id AS warehouseId,sku_id AS skuId,total_quantity AS totalQuantity," +
            "reserved_quantity AS reservedQuantity,available_quantity AS availableQuantity FROM wms_stock " +
            "WHERE sku_id=#{skuId} ORDER BY available_quantity DESC,warehouse_id,id FOR UPDATE")
    List<StockRow> lockStocksForSku(@Param("skuId") long skuId);

    @Select("SELECT id,sku_id AS skuId,warehouse_id AS warehouseId,total_quantity AS totalQuantity," +
            "reserved_quantity AS reservedQuantity,available_quantity AS availableQuantity FROM wms_stock " +
            "WHERE sku_id=#{skuId} AND warehouse_id=#{warehouseId} FOR UPDATE")
    StockRow lockStock(@Param("skuId") long skuId, @Param("warehouseId") long warehouseId);

    @Update("UPDATE wms_stock SET reserved_quantity=reserved_quantity+#{quantity},version=version+1 WHERE id=#{id} AND available_quantity>=#{quantity}")
    int reserve(@Param("id") long id, @Param("quantity") BigDecimal quantity);

    @Update("UPDATE wms_stock SET total_quantity=total_quantity-#{quantity},reserved_quantity=reserved_quantity-#{quantity},version=version+1 WHERE id=#{id} AND total_quantity>=#{quantity} AND reserved_quantity>=#{quantity}")
    int confirm(@Param("id") long id, @Param("quantity") BigDecimal quantity);

    @Update("UPDATE wms_stock SET reserved_quantity=reserved_quantity-#{quantity},version=version+1 WHERE id=#{id} AND reserved_quantity>=#{quantity}")
    int release(@Param("id") long id, @Param("quantity") BigDecimal quantity);

    @Insert("INSERT INTO wms_reservation (reservation_no,order_id,order_no,sku_id,warehouse_id,quantity,status,expire_at) VALUES (#{reservationNo},#{orderId},#{orderNo},#{skuId},#{warehouseId},#{quantity},0,#{expireAt})")
    int insertReservation(ReservationRow row);

    @Select("SELECT id,reservation_no AS reservationNo,order_id AS orderId,order_no AS orderNo,sku_id AS skuId,warehouse_id AS warehouseId,quantity,status,expire_at AS expireAt FROM wms_reservation WHERE order_no=#{orderNo} AND sku_id=#{skuId} ORDER BY warehouse_id LIMIT 1 FOR UPDATE")
    ReservationRow findReservation(@Param("orderNo") String orderNo, @Param("skuId") long skuId);

    @Select("SELECT id,reservation_no AS reservationNo,order_id AS orderId,order_no AS orderNo,sku_id AS skuId,warehouse_id AS warehouseId,quantity,status,expire_at AS expireAt FROM wms_reservation WHERE order_no=#{orderNo} AND status=0 ORDER BY sku_id FOR UPDATE")
    List<ReservationRow> findActiveReservations(@Param("orderNo") String orderNo);

    @Update("UPDATE wms_reservation SET status=#{status} WHERE id=#{id} AND status=0")
    int updateReservationStatus(@Param("id") long id, @Param("status") int status);

    @Insert("INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) VALUES (#{skuId},#{warehouseId},#{type},#{businessNo},#{delta},#{total},#{reserved})")
    int insertLedger(LedgerRow row);

    record StockRow(long id,long skuId,long warehouseId,BigDecimal totalQuantity,BigDecimal reservedQuantity,
                    BigDecimal availableQuantity) {}
    record ReservationRow(Long id,String reservationNo,long orderId,String orderNo,long skuId,long warehouseId,
                          BigDecimal quantity,int status,LocalDateTime expireAt) {}
    record LedgerRow(long skuId,long warehouseId,int type,String businessNo,BigDecimal delta,
                     BigDecimal total,BigDecimal reserved) {}
}
