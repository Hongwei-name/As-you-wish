package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.dto.PaymentCreateDTO;
import com.shopping.entity.Order;
import com.shopping.entity.Payment;
import com.shopping.mapper.PaymentMapper;
import com.shopping.service.OrderService;
import com.shopping.service.PaymentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Random;

/**
 * 支付服务实现类
 * 
 * @author 陈洪伟
 */
@Slf4j
@Service
public class PaymentServiceImpl implements PaymentService {

    @Autowired
    private PaymentMapper paymentMapper;

    @Autowired
    private OrderService orderService;

    /**
     * 生成支付流水号
     * 格式：PAY+时间戳+6位随机数
     * 
     * @return 支付流水号
     */
    private String generatePaymentNo() {
        StringBuilder sb = new StringBuilder();
        sb.append("PAY");
        sb.append(System.currentTimeMillis());
        sb.append(new Random().nextInt(100000, 999999));
        return sb.toString();
    }

    @Override
    public Payment createPayment(Long userId, PaymentCreateDTO createDTO) {
        // 验证订单归属
        com.shopping.entity.Order order = orderService.getOrderEntityById(createDTO.getOrderId());
        if (order == null || !order.getUserId().equals(userId)) {
            throw new RuntimeException("订单不存在或无权限");
        }

        // 检查订单状态
        if (order.getStatus() != 0) {
            throw new RuntimeException("订单状态不正确，无法支付");
        }

        // 创建支付记录
        Payment payment = new Payment();
        payment.setOrderId(createDTO.getOrderId());
        payment.setPaymentNo(generatePaymentNo());
        payment.setAmount(createDTO.getAmount());
        payment.setPaymentType(createDTO.getPaymentType());
        payment.setStatus(0); // 待支付
        payment.setCreatedAt(LocalDateTime.now());

        paymentMapper.insert(payment);
        log.info("创建支付记录成功：{}", payment.getPaymentNo());
        return payment;
    }

    @Transactional
    @Override
    public Payment pay(Long userId, Long paymentId) {
        // 查询支付记录
        Payment payment = paymentMapper.selectById(paymentId);
        if (payment == null) {
            throw new RuntimeException("支付记录不存在");
        }

        // 验证订单归属
        com.shopping.entity.Order order = orderService.getOrderEntityById(payment.getOrderId());
        if (order == null || !order.getUserId().equals(userId)) {
            throw new RuntimeException("订单不存在或无权限");
        }

        // 检查支付状态
        if (payment.getStatus() != 0) {
            throw new RuntimeException("支付状态不正确");
        }

        // 模拟支付成功
        payment.setStatus(1); // 支付成功
        paymentMapper.updateById(payment);

        // 更新订单状态
        orderService.updateOrderStatus(payment.getOrderId(), 1); // 待发货

        log.info("支付成功：{}", payment.getPaymentNo());
        return payment;
    }

    @Override
    public Payment getPaymentStatus(Long userId, Long orderId) {
        // 验证订单归属
        com.shopping.entity.Order order = orderService.getOrderEntityById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw new RuntimeException("订单不存在或无权限");
        }

        // 查询支付记录
        Payment payment = paymentMapper.selectByOrderId(orderId);
        if (payment == null) {
            throw new RuntimeException("支付记录不存在");
        }

        return payment;
    }

    @Transactional
    @Override
    public boolean paySuccessCallback(String paymentNo) {
        // 查询支付记录
        Payment payment = paymentMapper.selectOne(new LambdaQueryWrapper<Payment>()
                .eq(Payment::getPaymentNo, paymentNo));

        if (payment == null) {
            log.error("支付回调：支付记录不存在，paymentNo={}", paymentNo);
            return false;
        }

        if (payment.getStatus() == 1) {
            log.info("支付回调：支付已处理，paymentNo={}", paymentNo);
            return true;
        }

        // 更新支付状态
        payment.setStatus(1); // 支付成功
        paymentMapper.updateById(payment);

        // 更新订单状态
        orderService.updateOrderStatus(payment.getOrderId(), 1); // 待发货

        log.info("支付回调成功：{}", paymentNo);
        return true;
    }

}
