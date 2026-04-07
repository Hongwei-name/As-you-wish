package com.shopping.service;

import com.shopping.entity.Product;

import java.util.List;

/**
 * 推荐服务
 */
public interface RecommendationService {
    /**
     * 根据用户ID获取推荐商品列表
     */
    List<Product> getRecommendedProducts(Long userId, Integer limit);
    
    /**
     * 根据商品ID获取相关推荐商品列表
     */
    List<Product> getRelatedProducts(Long productId, Integer limit);
}