package com.shopping.service;

import com.shopping.dto.PaymentCreateDTO;
import com.shopping.entity.Payment;

/**
 * 支付服务接口
 * 提供支付相关的业务逻辑
 * 
 * @author 陈洪伟
 */
public interface PaymentService {

    /**
     * 创建支付记录
     * 
     * @param userId 用户ID
     * @param createDTO 创建支付DTO
     * @return 支付记录
     */
    Payment createPayment(Long userId, PaymentCreateDTO createDTO);

    /**
     * 模拟支付
     * 直接返回支付成功
     * 
     * @param userId 用户ID
     * @param paymentId 支付ID
     * @return 支付结果
     */
    Payment pay(Long userId, Long paymentId);

    /**
     * 查询支付状态
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     * @return 支付记录
     */
    Payment getPaymentStatus(Long userId, Long orderId);

    /**
     * 支付成功回调
     * 更新订单状态
     * 
     * @param paymentNo 支付流水号
     * @return 操作结果
     */
    boolean paySuccessCallback(String paymentNo);

}
