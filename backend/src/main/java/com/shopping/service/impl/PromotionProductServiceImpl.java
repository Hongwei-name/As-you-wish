package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.PromotionProductMapper;
import com.shopping.entity.PromotionProduct;
import com.shopping.service.PromotionProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 促销活动商品Service实现类
 */
@Service
public class PromotionProductServiceImpl extends ServiceImpl<PromotionProductMapper, PromotionProduct> implements PromotionProductService {
    
    @Autowired
    private PromotionProductMapper promotionProductMapper;
    
    @Override
    public List<PromotionProduct> getByPromotionId(Long promotionId) {
        return promotionProductMapper.selectByPromotionId(promotionId);
    }
    
    @Override
    public PromotionProduct getByProductId(Long productId) {
        return promotionProductMapper.selectByProductId(productId);
    }
    
    @Override
    public boolean decreaseStock(Long id, Integer quantity) {
        int result = promotionProductMapper.decreaseStock(id, quantity);
        return result > 0;
    }
    
    @Override
    public boolean addPromotionProduct(PromotionProduct promotionProduct) {
        return save(promotionProduct);
    }
    
    @Override
    public boolean updatePromotionProduct(PromotionProduct promotionProduct) {
        return updateById(promotionProduct);
    }
    
    @Override
    public boolean deletePromotionProduct(Long id) {
        return removeById(id);
    }
}