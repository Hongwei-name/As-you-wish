package com.shopping.vo;

import lombok.Data;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 购物车VO类
 * 用于返回购物车详情信息
 * 
 * @author 陈洪伟
 */
@Data
public class CartVO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 购物车ID
     */
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 商品ID
     */
    private Long productId;

    /**
     * 商品名称
     */
    private String productName;

    /**
     * 商品价格
     */
    private BigDecimal productPrice;

    /**
     * 商品原价
     */
    private BigDecimal originalPrice;

    /**
     * 商品图片
     */
    private String productImage;

    /**
     * 商品库存
     */
    private Integer productStock;

    /**
     * 商品数量
     */
    private Integer quantity;

    /**
     * 是否选中：0-否 1-是
     */
    private Integer selected;

    /**
     * 小计金额
     */
    private BigDecimal subtotal;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;

}
