package com.zerok.stockservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("wms_reservation")
public class WmsReservation {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String reservationNo;
    private Long orderId;
    private String orderNo;
    private Long skuId;
    private Long warehouseId;
    private BigDecimal quantity;
    private Integer status;
    private LocalDateTime expireAt;
}
