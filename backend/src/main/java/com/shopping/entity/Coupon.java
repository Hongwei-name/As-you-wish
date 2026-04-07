package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import java.math.BigDecimal;
import lombok.Data;

/**
 * 优惠券实体类
 */
@Data
@TableName("t_coupon")
public class Coupon {
    /**
     * 优惠券ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 优惠券名称
     */
    private String name;
    
    /**
     * 优惠券类型：1-满减券，2-折扣券
     */
    private Integer type;
    
    /**
     * 优惠券价值：满减券为金额，折扣券为折扣率（如0.8表示8折）
     */
    private BigDecimal value;
    
    /**
     * 最低使用金额
     */
    private BigDecimal minAmount;
    
    /**
     * 开始时间
     */
    private LocalDateTime startTime;
    
    /**
     * 结束时间
     */
    private LocalDateTime endTime;
    
    /**
     * 总数量
     */
    private Integer totalQuantity;
    
    /**
     * 剩余数量
     */
    private Integer remainingQuantity;
    
    /**
     * 状态：1-有效，0-无效
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