package com.shopping.service;

import com.shopping.entity.BrowseHistory;

import java.util.List;

/**
 * 浏览历史服务
 */
public interface BrowseHistoryService {
    /**
     * 记录浏览历史
     */
    void recordBrowseHistory(Long userId, Long productId);
    
    /**
     * 根据用户ID获取最近浏览的商品ID列表
     */
    List<Long> getRecentProductIdsByUserId(Long userId, Integer limit);
    
    /**
     * 清除用户的浏览历史
     */
    void clearBrowseHistory(Long userId);
}