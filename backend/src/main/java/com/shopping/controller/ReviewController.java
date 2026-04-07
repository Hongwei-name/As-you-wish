package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.entity.Review;
import com.shopping.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

/**
 * 商品评价控制器
 */
@RestController
@RequestMapping("/api/review")
public class ReviewController {
    
    @Autowired
    private ReviewService reviewService;
    
    /**
     * 获取HttpServletRequest
     */
    private HttpServletRequest getRequest() {
        return ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
    }
    
    /**
     * 添加商品评价
     */
    @PostMapping("/add")
    public Result addReview(@RequestBody Review review) {
        // 从请求中获取用户ID
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        review.setUserId(userId);
        
        // 检查用户是否已评价
        if (reviewService.hasUserReviewedProduct(userId, review.getProductId())) {
            return Result.error("您已经评价过该商品");
        }
        
        boolean success = reviewService.addReview(review);
        if (success) {
            return Result.success("评价成功");
        } else {
            return Result.error("评价失败");
        }
    }
    
    /**
     * 获取商品评价列表
     */
    @GetMapping("/list/{productId}")
    public Result getReviewsByProductId(@PathVariable Long productId) {
        List<Review> reviews = reviewService.getReviewsByProductId(productId);
        return Result.success(reviews);
    }
    
    /**
     * 获取商品评分信息
     */
    @GetMapping("/rating/{productId}")
    public Result getProductRatingInfo(@PathVariable Long productId) {
        Double averageRating = reviewService.getAverageRatingByProductId(productId);
        List<Map<String, Object>> ratingDistribution = reviewService.getRatingDistributionByProductId(productId);
        
        return Result.success(Map.of(
            "averageRating", averageRating,
            "ratingDistribution", ratingDistribution
        ));
    }
    
    /**
     * 检查用户是否已评价商品
     */
    @GetMapping("/check/{productId}")
    public Result checkUserReviewed(@PathVariable Long productId) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        boolean hasReviewed = reviewService.hasUserReviewedProduct(userId, productId);
        return Result.success(Map.of("hasReviewed", hasReviewed));
    }
}