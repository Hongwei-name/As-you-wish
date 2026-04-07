package com.shopping.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.Result;
import com.shopping.dto.OrderCreateDTO;
import com.shopping.service.OrderService;
import com.shopping.vo.OrderVO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 订单控制器
 * 提供订单相关的REST API接口
 * 
 * @author 陈洪伟
 */
@RestController
@RequestMapping("/api/order")
public class OrderController {

    @Autowired
    private OrderService orderService;

    /**
     * 创建订单
     * 从购物车创建订单，扣减库存，清空购物车
     * 
     * @param request HTTP请求对象
     * @param createDTO 创建订单DTO
     * @return 订单信息
     */
    @PostMapping("/create")
    public Result<OrderVO> createOrder(HttpServletRequest request, @Valid @RequestBody OrderCreateDTO createDTO) {
        Long userId = (Long) request.getAttribute("userId");
        OrderVO orderVO = orderService.createOrder(userId, createDTO);
        return Result.success(orderVO);
    }

    /**
     * 获取订单详情
     * 
     * @param request HTTP请求对象
     * @param id 订单ID
     * @return 订单详情
     */
    @GetMapping("/{id}")
    public Result<OrderVO> getOrderById(HttpServletRequest request, @PathVariable Long id) {
        Long userId = (Long) request.getAttribute("userId");
        OrderVO orderVO = orderService.getOrderById(userId, id);
        return Result.success(orderVO);
    }

    /**
     * 获取订单列表
     * 支持状态筛选和分页
     * 
     * @param request HTTP请求对象
     * @param status 订单状态（可选）
     * @param page 页码
     * @param size 每页大小
     * @return 订单分页列表
     */
    @GetMapping("/list")
    public Result<Page<OrderVO>> getOrderList(HttpServletRequest request,
                                               @RequestParam(required = false) Integer status,
                                               @RequestParam(defaultValue = "1") Integer page,
                                               @RequestParam(defaultValue = "10") Integer size) {
        Long userId = (Long) request.getAttribute("userId");
        Page<OrderVO> orderPage = orderService.getOrderList(userId, status, page, size);
        return Result.success(orderPage);
    }

    /**
     * 取消订单
     * 
     * @param request HTTP请求对象
     * @param id 订单ID
     * @return 操作结果
     */
    @PutMapping("/cancel/{id}")
    public Result<Void> cancelOrder(HttpServletRequest request, @PathVariable Long id) {
        Long userId = (Long) request.getAttribute("userId");
        orderService.cancelOrder(userId, id);
        return Result.success();
    }

    /**
     * 确认收货
     * 
     * @param request HTTP请求对象
     * @param id 订单ID
     * @return 操作结果
     */
    @PutMapping("/receive/{id}")
    public Result<Void> confirmReceive(HttpServletRequest request, @PathVariable Long id) {
        Long userId = (Long) request.getAttribute("userId");
        orderService.confirmReceive(userId, id);
        return Result.success();
    }

    /**
     * 删除订单
     * 
     * @param request HTTP请求对象
     * @param id 订单ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteOrder(HttpServletRequest request, @PathVariable Long id) {
        Long userId = (Long) request.getAttribute("userId");
        orderService.deleteOrder(userId, id);
        return Result.success();
    }

}
