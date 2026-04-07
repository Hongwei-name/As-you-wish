package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.service.BrowseHistoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;

/**
 * 浏览历史控制器
 */
@RestController
@RequestMapping("/api/browse-history")
public class BrowseHistoryController {
    
    @Autowired
    private BrowseHistoryService browseHistoryService;
    
    /**
     * 获取HttpServletRequest
     */
    private HttpServletRequest getRequest() {
        return ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
    }
    
    /**
     * 记录浏览历史
     */
    @PostMapping("/record/{productId}")
    public Result recordBrowseHistory(@PathVariable Long productId) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        browseHistoryService.recordBrowseHistory(userId, productId);
        return Result.success("记录浏览历史成功");
    }
    
    /**
     * 获取最近浏览的商品ID列表
     */
    @GetMapping("/recent")
    public Result getRecentBrowseHistory(@RequestParam(defaultValue = "10") Integer limit) {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        return Result.success(browseHistoryService.getRecentProductIdsByUserId(userId, limit));
    }
    
    /**
     * 清除浏览历史
     */
    @PostMapping("/clear")
    public Result clearBrowseHistory() {
        HttpServletRequest request = getRequest();
        Long userId = (Long) request.getAttribute("userId");
        
        browseHistoryService.clearBrowseHistory(userId);
        return Result.success("清除浏览历史成功");
    }
}