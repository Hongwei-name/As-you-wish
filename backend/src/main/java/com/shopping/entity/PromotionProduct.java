package com.shopping.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import java.math.BigDecimal;
import lombok.Data;

/**
 * 促销活动商品实体类
 */
@Data
@TableName("t_promotion_product")
public class PromotionProduct {
    /**
     * 记录ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;
    
    /**
     * 促销活动ID
     */
    private Long promotionId;
    
    /**
     * 商品ID
     */
    private Long productId;
    
    /**
     * 折扣率（如0.8表示8折）
     */
    private BigDecimal discount;
    
    /**
     * 促销价格
     */
    private BigDecimal price;
    
    /**
     * 促销库存
     */
    private Integer stock;
}