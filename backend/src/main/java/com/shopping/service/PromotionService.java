package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.Promotion;
import java.util.List;

/**
 * 促销活动Service接口
 */
public interface PromotionService extends IService<Promotion> {
    /**
     * 获取进行中的促销活动列表
     * @return 进行中的促销活动列表
     */
    List<Promotion> getActivePromotions();
    
    /**
     * 创建促销活动
     * @param promotion 促销活动信息
     * @return 是否创建成功
     */
    boolean createPromotion(Promotion promotion);
    
    /**
     * 更新促销活动
     * @param promotion 促销活动信息
     * @return 是否更新成功
     */
    boolean updatePromotion(Promotion promotion);
    
    /**
     * 删除促销活动
     * @param id 促销活动ID
     * @return 是否删除成功
     */
    boolean deletePromotion(Long id);
}