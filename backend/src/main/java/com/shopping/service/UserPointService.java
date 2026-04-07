package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.UserPoint;

/**
 * 用户积分Service接口
 */
public interface UserPointService extends IService<UserPoint> {
    /**
     * 获取用户积分余额
     * @param userId 用户ID
     * @return 积分余额
     */
    Integer getPointBalance(Long userId);
    
    /**
     * 增加用户积分
     * @param userId 用户ID
     * @param amount 增加数量
     * @param type 类型：1-购物获得，2-使用积分，3-其他
     * @param relatedId 相关ID：如订单ID
     * @param description 描述
     * @return 是否增加成功
     */
    boolean addPoints(Long userId, Integer amount, Integer type, Long relatedId, String description);
    
    /**
     * 减少用户积分
     * @param userId 用户ID
     * @param amount 减少数量
     * @param type 类型：1-购物获得，2-使用积分，3-其他
     * @param relatedId 相关ID：如订单ID
     * @param description 描述
     * @return 是否减少成功
     */
    boolean deductPoints(Long userId, Integer amount, Integer type, Long relatedId, String description);
}