package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.service.RecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 推荐控制器
 */
@RestController
@RequestMapping("/api/recommendation")
public class RecommendationController {
    
    @Autowired
    private RecommendationService recommendationService;
    
    /**
     * 获取HttpServletRequest
     */
    private HttpServletRequest getRequest() {
        return ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
    }
    
    /**
     * 获取推荐商品列表
     */
    @GetMapping("/recommended")
    public Result getRecommendedProducts(@RequestParam(defaultValue = "10") Integer limit) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        return Result.success(recommendationService.getRecommendedProducts(userId, limit));
    }
    
    /**
     * 获取相关推荐商品列表
     */
    @GetMapping("/related/{productId}")
    public Result getRelatedProducts(@PathVariable Long productId, @RequestParam(defaultValue = "6") Integer limit) {
        return Result.success(recommendationService.getRelatedProducts(productId, limit));
    }
}