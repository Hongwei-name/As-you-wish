package com.shopping.service;

import com.shopping.entity.Review;

import java.util.List;
import java.util.Map;

/**
 * 商品评价服务
 */
public interface ReviewService {
    /**
     * 添加商品评价
     */
    boolean addReview(Review review);
    
    /**
     * 根据商品ID获取评价列表
     */
    List<Review> getReviewsByProductId(Long productId);
    
    /**
     * 获取商品的平均评分
     */
    Double getAverageRatingByProductId(Long productId);
    
    /**
     * 统计商品各星级的评价数量
     */
    List<Map<String, Object>> getRatingDistributionByProductId(Long productId);
    
    /**
     * 检查用户是否已对商品评价
     */
    boolean hasUserReviewedProduct(Long userId, Long productId);
}