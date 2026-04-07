package com.shopping.service;

import com.shopping.entity.Favorite;

import java.util.List;

/**
 * 商品收藏服务
 */
public interface FavoriteService {
    /**
     * 添加商品收藏
     */
    boolean addFavorite(Long userId, Long productId);
    
    /**
     * 取消商品收藏
     */
    boolean removeFavorite(Long userId, Long productId);
    
    /**
     * 根据用户ID获取收藏列表
     */
    List<Favorite> getFavoritesByUserId(Long userId);
    
    /**
     * 检查用户是否已收藏商品
     */
    boolean isFavorite(Long userId, Long productId);
}