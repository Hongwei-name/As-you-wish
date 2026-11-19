package com.zerok.stockservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;

@Data
@TableName("wms_stock")
public class WmsStock {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long warehouseId;
    private Long skuId;
    private BigDecimal totalQuantity;
    private BigDecimal reservedQuantity;
    @TableField(insertStrategy = com.baomidou.mybatisplus.annotation.FieldStrategy.NEVER,
            updateStrategy = com.baomidou.mybatisplus.annotation.FieldStrategy.NEVER)
    private BigDecimal availableQuantity;
    private Long version;
}
