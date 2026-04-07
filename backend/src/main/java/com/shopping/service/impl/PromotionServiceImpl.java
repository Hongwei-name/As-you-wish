package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.PromotionMapper;
import com.shopping.entity.Promotion;
import com.shopping.service.PromotionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 促销活动Service实现类
 */
@Service
public class PromotionServiceImpl extends ServiceImpl<PromotionMapper, Promotion> implements PromotionService {
    
    @Autowired
    private PromotionMapper promotionMapper;
    
    @Override
    public List<Promotion> getActivePromotions() {
        return promotionMapper.selectActivePromotions();
    }
    
    @Override
    public boolean createPromotion(Promotion promotion) {
        return save(promotion);
    }
    
    @Override
    public boolean updatePromotion(Promotion promotion) {
        return updateById(promotion);
    }
    
    @Override
    public boolean deletePromotion(Long id) {
        return removeById(id);
    }
}