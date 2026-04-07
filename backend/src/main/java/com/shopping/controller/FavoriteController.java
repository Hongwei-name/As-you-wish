package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 商品收藏控制器
 */
@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {
    
    @Autowired
    private FavoriteService favoriteService;
    
    /**
     * 获取HttpServletRequest
     */
    private HttpServletRequest getRequest() {
        return ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
    }
    
    /**
     * 添加商品收藏
     */
    @PostMapping("/add/{productId}")
    public Result addFavorite(@PathVariable Long productId) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        boolean success = favoriteService.addFavorite(userId, productId);
        if (success) {
            return Result.success("收藏成功");
        } else {
            return Result.error("收藏失败");
        }
    }
    
    /**
     * 取消商品收藏
     */
    @PostMapping("/remove/{productId}")
    public Result removeFavorite(@PathVariable Long productId) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        boolean success = favoriteService.removeFavorite(userId, productId);
        if (success) {
            return Result.success("取消收藏成功");
        } else {
            return Result.error("取消收藏失败");
        }
    }
    
    /**
     * 获取用户收藏列表
     */
    @GetMapping("/list")
    public Result getFavorites() {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        return Result.success(favoriteService.getFavoritesByUserId(userId));
    }
    
    /**
     * 检查商品是否已收藏
     */
    @GetMapping("/check/{productId}")
    public Result checkFavorite(@PathVariable Long productId) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        boolean isFavorite = favoriteService.isFavorite(userId, productId);
        return Result.success("isFavorite", isFavorite);
    }
}