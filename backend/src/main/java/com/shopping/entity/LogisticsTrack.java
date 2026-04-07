package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import lombok.Data;

/**
 * 物流轨迹实体类
 */
@Data
@TableName("t_logistics_track")
public class LogisticsTrack {
    /**
     * 轨迹ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 物流ID
     */
    private Long logisticsId;
    
    /**
     * 状态：0-待发货，1-已发货，2-运输中，3-已送达
     */
    private Integer status;
    
    /**
     * 描述
     */
    private String description;
    
    /**
     * 地点
     */
    private String location;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}