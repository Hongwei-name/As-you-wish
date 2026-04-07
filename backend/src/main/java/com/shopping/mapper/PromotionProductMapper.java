package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.PromotionProduct;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 促销活动商品Mapper接口
 */
public interface PromotionProductMapper extends BaseMapper<PromotionProduct> {
    /**
     * 根据促销活动ID获取商品列表
     * @param promotionId 促销活动ID
     * @return 商品列表
     */
    List<PromotionProduct> selectByPromotionId(@Param("promotionId") Long promotionId);
    
    /**
     * 根据商品ID获取促销信息
     * @param productId 商品ID
     * @return 促销信息
     */
    PromotionProduct selectByProductId(@Param("productId") Long productId);
    
    /**
     * 减少促销商品库存
     * @param id 促销商品ID
     * @param quantity 减少数量
     * @return 影响行数
     */
    int decreaseStock(@Param("id") Long id, @Param("quantity") Integer quantity);
}