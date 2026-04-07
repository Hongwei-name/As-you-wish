package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import lombok.Data;

/**
 * 促销活动实体类
 */
@Data
@TableName("t_promotion")
public class Promotion {
    /**
     * 促销活动ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 活动名称
     */
    private String name;
    
    /**
     * 活动类型：1-限时折扣，2-满减活动，3-秒杀活动
     */
    private Integer type;
    
    /**
     * 活动描述
     */
    private String description;
    
    /**
     * 开始时间
     */
    private LocalDateTime startTime;
    
    /**
     * 结束时间
     */
    private LocalDateTime endTime;
    
    /**
     * 状态：1-进行中，0-已结束
     */
    private Integer status;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}