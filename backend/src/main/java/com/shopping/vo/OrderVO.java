package com.shopping.vo;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单VO类
 * 用于返回订单详情信息
 * 
 * @author 陈洪伟
 */
@Data
public class OrderVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 订单ID
     */
    private Long id;

    /**
     * 订单号
     */
    private String orderNo;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 收货地址ID
     */
    private Long addressId;

    /**
     * 收货人姓名
     */
    private String receiver;

    /**
     * 联系电话
     */
    private String phone;

    /**
     * 完整地址
     */
    private String address;

    /**
     * 订单总金额
     */
    private BigDecimal totalAmount;

    /**
     * 实付金额
     */
    private BigDecimal payAmount;

    /**
     * 运费金额
     */
    private BigDecimal freightAmount;

    /**
     * 订单状态：0-待支付 1-待发货 2-待收货 3-已完成 4-已取消 5-已退款
     */
    private Integer status;

    /**
     * 订单状态描述
     */
    private String statusDesc;

    /**
     * 支付时间
     */
    private LocalDateTime paymentTime;

    /**
     * 发货时间
     */
    private LocalDateTime deliveryTime;

    /**
     * 收货时间
     */
    private LocalDateTime receiveTime;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

    /**
     * 订单项列表
     */
    private List<OrderItemVO> orderItems;

    /**
     * 订单项VO内部类
     */
    @Data
    public static class OrderItemVO implements Serializable {

        private static final long serialVersionUID = 1L;

        /**
         * 订单项ID
         */
        private Long id;

        /**
         * 订单ID
         */
        private Long orderId;

        /**
         * 商品ID
         */
        private Long productId;

        /**
         * 商品名称
         */
        private String productName;

        /**
         * 商品图片
         */
        private String productImage;

        /**
         * 商品单价
         */
        private BigDecimal price;

        /**
         * 商品数量
         */
        private Integer quantity;

        /**
         * 小计金额
         */
        private BigDecimal totalAmount;

        /**
         * 创建时间
         */
        private LocalDateTime createdAt;

    }

}
