package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.dto.PaymentCreateDTO;
import com.shopping.entity.Payment;
import com.shopping.service.PaymentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 支付控制器
 * 提供支付相关的REST API接口
 * 
 * @author 陈洪伟
 */
@RestController
@RequestMapping("/api/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    /**
     * 创建支付记录
     * 
     * @param request HTTP请求对象
     * @param createDTO 创建支付DTO
     * @return 支付记录
     */
    @PostMapping("/create")
    public Result<Payment> createPayment(HttpServletRequest request, @Valid @RequestBody PaymentCreateDTO createDTO) {
        Long userId = (Long) request.getAttribute("userId");
        Payment payment = paymentService.createPayment(userId, createDTO);
        return Result.success(payment);
    }

    /**
     * 模拟支付
     * 
     * @param request HTTP请求对象
     * @param paymentId 支付ID
     * @return 支付结果
     */
    @PostMapping("/pay")
    public Result<Payment> pay(HttpServletRequest request, @RequestParam Long paymentId) {
        Long userId = (Long) request.getAttribute("userId");
        Payment payment = paymentService.pay(userId, paymentId);
        return Result.success(payment);
    }

    /**
     * 查询支付状态
     * 
     * @param request HTTP请求对象
     * @param orderId 订单ID
     * @return 支付记录
     */
    @GetMapping("/status/{orderId}")
    public Result<Payment> getPaymentStatus(HttpServletRequest request, @PathVariable Long orderId) {
        Long userId = (Long) request.getAttribute("userId");
        Payment payment = paymentService.getPaymentStatus(userId, orderId);
        return Result.success(payment);
    }

    /**
     * 支付成功回调
     * 
     * @param paymentNo 支付流水号
     * @return 操作结果
     */
    @PostMapping("/callback")
    public Result<Boolean> paySuccessCallback(@RequestParam String paymentNo) {
        boolean result = paymentService.paySuccessCallback(paymentNo);
        return Result.success(result);
    }

}
