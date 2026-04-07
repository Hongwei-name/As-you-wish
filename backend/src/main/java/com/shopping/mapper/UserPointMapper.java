package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.UserPoint;

/**
 * 用户积分汇总Mapper接口
 */
public interface UserPointMapper extends BaseMapper<UserPoint> {
    /**
     * 根据用户ID获取积分余额
     * @param userId 用户ID
     * @return 积分余额
     */
    Integer selectBalanceByUserId(Long userId);
    
    /**
     * 增加用户积分
     * @param userId 用户ID
     * @param amount 增加数量
     * @return 影响行数
     */
    int increaseBalance(Long userId, Integer amount);
    
    /**
     * 减少用户积分
     * @param userId 用户ID
     * @param amount 减少数量
     * @return 影响行数
     */
    int decreaseBalance(Long userId, Integer amount);
}