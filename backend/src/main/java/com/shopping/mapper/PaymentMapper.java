package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Payment;
import org.apache.ibatis.annotations.Param;

/**
 * 支付记录Mapper接口
 * 
 * @author 陈洪伟
 */
public interface PaymentMapper extends BaseMapper<Payment> {

    /**
     * 根据订单ID查询支付记录
     * 
     * @param orderId 订单ID
     * @return 支付记录
     */
    Payment selectByOrderId(@Param("orderId") Long orderId);

}
