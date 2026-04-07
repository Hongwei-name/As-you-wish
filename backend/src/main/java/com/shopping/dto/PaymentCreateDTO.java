package com.shopping.dto;

import lombok.Data;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 创建支付DTO
 * 
 * @author 陈洪伟
 */
@Data
public class PaymentCreateDTO {

    /**
     * 订单ID
     */
    @NotNull(message = "订单ID不能为空")
    private Long orderId;

    /**
     * 支付金额
     */
    @NotNull(message = "支付金额不能为空")
    private BigDecimal amount;

    /**
     * 支付类型：1-支付宝, 2-微信支付, 3-银行卡
     */
    @NotNull(message = "支付类型不能为空")
    private Integer paymentType;

}
