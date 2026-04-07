package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.shopping.entity.Review;
import com.shopping.mapper.ReviewMapper;
import com.shopping.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

/**
 * 商品评价服务实现
 */
@Service
public class ReviewServiceImpl implements ReviewService {
    
    @Autowired
    private ReviewMapper reviewMapper;
    
    @Override
    public boolean addReview(Review review) {
        return reviewMapper.insert(review) > 0;
    }
    
    @Override
    public List<Review> getReviewsByProductId(Long productId) {
        return reviewMapper.getReviewsByProductId(productId);
    }
    
    @Override
    public Double getAverageRatingByProductId(Long productId) {
        return reviewMapper.getAverageRatingByProductId(productId);
    }
    
    @Override
    public List<Map<String, Object>> getRatingDistributionByProductId(Long productId) {
        return reviewMapper.getRatingDistributionByProductId(productId);
    }
    
    @Override
    public boolean hasUserReviewedProduct(Long userId, Long productId) {
        QueryWrapper<Review> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("product_id", productId);
        return reviewMapper.selectCount(wrapper) > 0;
    }
}