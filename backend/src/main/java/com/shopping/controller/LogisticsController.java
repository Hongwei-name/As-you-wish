package com.shopping.controller;

import com.shopping.service.LogisticsService;
import com.shopping.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import java.util.List;

/**
 * 物流控制器
 */
@RestController
@RequestMapping("/api/logistics")
public class LogisticsController {
    
    @Autowired
    private LogisticsService logisticsService;
    
    /**
     * 获取订单的物流信息
     */
    @GetMapping("/order/{orderId}")
    public Result<?> getLogisticsByOrderId(@PathVariable Long orderId) {
        return Result.success(logisticsService.getByOrderId(orderId));
    }
    
    /**
     * 获取物流轨迹
     */
    @GetMapping("/tracks/{logisticsId}")
    public Result<List<?>> getLogisticsTracks(@PathVariable Long logisticsId) {
        return Result.success(logisticsService.getLogisticsTracks(logisticsId));
    }
    
    /**
     * 发货（管理员）
     */
    @PostMapping("/ship")
    public Result<Boolean> shipOrder(
            @RequestParam Long orderId,
            @RequestParam String logisticsCompany,
            @RequestParam String logisticsNo) {
        boolean result = logisticsService.shipOrder(orderId, logisticsCompany, logisticsNo);
        if (result) {
            return Result.success("发货成功", true);
        } else {
            return Result.error("发货失败");
        }
    }
    
    /**
     * 更新物流状态（管理员）
     */
    @PostMapping("/updateStatus")
    public Result<Boolean> updateLogisticsStatus(
            @RequestParam Long orderId,
            @RequestParam Integer status,
            @RequestParam String description,
            @RequestParam String location) {
        boolean result = logisticsService.updateLogisticsStatus(orderId, status, description, location);
        if (result) {
            return Result.success("更新物流状态成功", true);
        } else {
            return Result.error("更新物流状态失败");
        }
    }
}