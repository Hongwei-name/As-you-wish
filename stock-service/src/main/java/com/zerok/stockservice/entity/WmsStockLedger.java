package com.zerok.stockservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("wms_stock_ledger")
public class WmsStockLedger {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long skuId;
    private Long warehouseId;
    private Integer businessType;
    private String businessNo;
    private BigDecimal quantityDelta;
    private BigDecimal totalAfter;
    private BigDecimal reservedAfter;
}
