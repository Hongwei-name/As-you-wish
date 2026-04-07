package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.time.LocalDateTime;
import lombok.Data;

/**
 * 积分记录实体类
 */
@Data
@TableName("t_point_record")
public class PointRecord {
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
     * 类型：1-购物获得，2-使用积分，3-其他
     */
    private Integer type;
    
    /**
     * 积分数量：正数为增加，负数为减少
     */
    private Integer amount;
    
    /**
     * 操作后余额
     */
    private Integer balance;
    
    /**
     * 相关ID：如订单ID
     */
    private Long relatedId;
    
    /**
     * 描述
     */
    private String description;
    
    /**
     * 创建时间
     */
    private LocalDateTime createdAt;
}