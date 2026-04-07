package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import java.time.LocalDateTime;
import lombok.Data;

/**
 * 用户积分汇总实体类
 */
@Data
@TableName("t_user_point")
public class UserPoint {
    /**
     * 用户ID
     */
    private Long userId;
    
    /**
     * 积分余额
     */
    private Integer balance;
    
    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;
}