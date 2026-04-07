package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import lombok.Data;

/**
 * 优惠券领取记录实体类
 */
@Data
@TableName("t_coupon_user")
public class CouponUser {
    /**
     * 记录ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 优惠券ID
     */
    private Long couponId;
    
    /**
     * 状态：1-未使用，2-已使用，3-已过期
     */
    private Integer status;
    
    /**
     * 领取时间
     */
    private LocalDateTime receiveTime;
    
    /**
     * 使用时间
     */
    private LocalDateTime useTime;
}