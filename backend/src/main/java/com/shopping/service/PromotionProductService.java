package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.PromotionProduct;
import java.util.List;

/**
 * 促销活动商品Service接口
 */
public interface PromotionProductService extends IService<PromotionProduct> {
    /**
     * 根据促销活动ID获取商品列表
     * @param promotionId 促销活动ID
     * @return 商品列表
     */
    List<PromotionProduct> getByPromotionId(Long promotionId);
    
    /**
     * 根据商品ID获取促销信息
     * @param productId 商品ID
     * @return 促销信息
     */
    PromotionProduct getByProductId(Long productId);
    
    /**
     * 减少促销商品库存
     * @param id 促销商品ID
     * @param quantity 减少数量
     * @return 是否成功
     */
    boolean decreaseStock(Long id, Integer quantity);
    
    /**
     * 添加促销商品
     * @param promotionProduct 促销商品信息
     * @return 是否添加成功
     */
    boolean addPromotionProduct(PromotionProduct promotionProduct);
    
    /**
     * 更新促销商品
     * @param promotionProduct 促销商品信息
     * @return 是否更新成功
     */
    boolean updatePromotionProduct(PromotionProduct promotionProduct);
    
    /**
     * 删除促销商品
     * @param id 促销商品ID
     * @return 是否删除成功
     */
    boolean deletePromotionProduct(Long id);
}