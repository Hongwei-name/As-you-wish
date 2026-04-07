package com.shopping.controller;

import com.shopping.service.UserPointService;
import com.shopping.service.PointRecordService;
import com.shopping.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * 积分控制器
 */
@RestController
@RequestMapping("/api/point")
public class PointController {
    
    @Autowired
    private UserPointService userPointService;
    
    @Autowired
    private PointRecordService pointRecordService;
    
    /**
     * 获取用户积分余额
     */
    @GetMapping("/balance")
    public Result<Integer> getPointBalance(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Integer balance = userPointService.getPointBalance(userId);
        return Result.success(balance);
    }
    
    /**
     * 获取用户积分记录
     */
    @GetMapping("/records")
    public Result<List<?>> getPointRecords(HttpServletRequest request, @RequestParam(defaultValue = "20") Integer limit) {
        Long userId = (Long) request.getAttribute("userId");
        List<?> records = pointRecordService.getUserPointRecords(userId, limit);
        return Result.success(records);
    }
    
    /**
     * 增加用户积分（管理员）
     */
    @PostMapping("/add")
    public Result<Boolean> addPoints(
            @RequestParam Long userId,
            @RequestParam Integer amount,
            @RequestParam Integer type,
            @RequestParam(required = false) Long relatedId,
            @RequestParam(required = false) String description) {
        boolean result = userPointService.addPoints(userId, amount, type, relatedId, description);
        if (result) {
            return Result.success("增加积分成功", true);
        } else {
            return Result.error("增加积分失败");
        }
    }
    
    /**
     * 减少用户积分（管理员）
     */
    @PostMapping("/deduct")
    public Result<Boolean> deductPoints(
            @RequestParam Long userId,
            @RequestParam Integer amount,
            @RequestParam Integer type,
            @RequestParam(required = false) Long relatedId,
            @RequestParam(required = false) String description) {
        boolean result = userPointService.deductPoints(userId, amount, type, relatedId, description);
        if (result) {
            return Result.success("减少积分成功", true);
        } else {
            return Result.error("减少积分失败，积分不足");
        }
    }
}