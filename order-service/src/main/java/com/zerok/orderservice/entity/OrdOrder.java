package com.zerok.orderservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Existing ord_order table mapping; legacy column names are preserved explicitly in the mapper.
 */
@Data
@NoArgsConstructor
@TableName("ord_order")
public class OrdOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String orderNo;
    private Long authUserId;
    private Integer orderType;
    private BigDecimal totalAmount;
    private BigDecimal payAmount;
    private BigDecimal discountAmount;
    private BigDecimal freightAmount;
    private Integer payType;
    private LocalDateTime payTime;
    private String outTradeNo;
    private Integer orderStatus;
    private Integer refundStatus;
    private BigDecimal refundAmount;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String note;
    private String cancelReason;
    private String refundReason;
    private LocalDateTime expireTime;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Long createBy;
    private Long updateBy;
}
