package com.shopping.controller;

import com.shopping.service.CsSessionService;
import com.shopping.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * 客服控制器
 */
@RestController
@RequestMapping("/api/cs")
public class CustomerServiceController {
    
    @Autowired
    private CsSessionService csSessionService;
    
    /**
     * 获取用户的会话列表
     */
    @GetMapping("/sessions")
    public Result<List<?>> getUserSessions(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(csSessionService.getUserSessions(userId));
    }
    
    /**
     * 获取未结束的会话
     */
    @GetMapping("/session/unfinished")
    public Result<?> getUnfinishedSession(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(csSessionService.getUnfinishedSession(userId));
    }
    
    /**
     * 创建会话
     */
    @PostMapping("/session/create")
    public Result<?> createSession(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        return Result.success(csSessionService.createSession(userId));
    }
    
    /**
     * 结束会话
     */
    @PostMapping("/session/end/{sessionId}")
    public Result<Boolean> endSession(@PathVariable Long sessionId) {
        boolean result = csSessionService.endSession(sessionId);
        if (result) {
            return Result.success("结束会话成功", true);
        } else {
            return Result.error("结束会话失败");
        }
    }
    
    /**
     * 发送消息
     */
    @PostMapping("/message/send")
    public Result<Long> sendMessage(
            @RequestParam Long sessionId,
            @RequestParam Integer senderType,
            @RequestParam String content) {
        Long messageId = csSessionService.sendMessage(sessionId, senderType, content);
        if (messageId != null) {
            return Result.success("发送消息成功", messageId);
        } else {
            return Result.error("发送消息失败");
        }
    }
    
    /**
     * 获取会话消息
     */
    @GetMapping("/messages/{sessionId}")
    public Result<List<?>> getSessionMessages(@PathVariable Long sessionId, @RequestParam(defaultValue = "50") Integer limit) {
        return Result.success(csSessionService.getSessionMessages(sessionId, limit));
    }
}