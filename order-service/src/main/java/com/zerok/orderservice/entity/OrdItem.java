package com.zerok.orderservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Order-owned purchase snapshot mapped to the ord_item detail table.
 */
@Data
@NoArgsConstructor
@TableName("ord_item")
public class OrdItem {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long orderId;
    private String orderNo;
    private Long skuId;
    private Long spuId;
    private String skuCode;
    private String productName;
    private String skuName;
    private String specJson;
    private String imageUrl;
    private BigDecimal unitPrice;
    private BigDecimal quantity;
    private BigDecimal lineAmount;
    private BigDecimal discountAmount;
    private BigDecimal payAmount;
    private BigDecimal afterSaleQuantity;
    private LocalDateTime createdAt;
}
