package com.zerok.stockservice.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("wms_warehouse")
public class WmsWarehouse {
    @TableId(type = IdType.AUTO)
    private Long id;
    private String warehouseCode;
    private String name;
    private Integer status;
}
