package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.shopping.entity.Product;
import com.shopping.mapper.ProductMapper;
import com.shopping.service.BrowseHistoryService;
import com.shopping.service.RecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 推荐服务实现
 */
@Service
public class RecommendationServiceImpl implements RecommendationService {
    
    @Autowired
    private BrowseHistoryService browseHistoryService;
    
    @Autowired
    private ProductMapper productMapper;
    
    @Override
    public List<Product> getRecommendedProducts(Long userId, Integer limit) {
        // 获取用户最近浏览的商品ID列表
        List<Long> recentProductIds = browseHistoryService.getRecentProductIdsByUserId(userId, 5);
        
        if (recentProductIds.isEmpty()) {
            // 如果没有浏览历史，返回热门商品
            return getHotProducts(limit);
        }
        
        // 获取浏览商品的分类ID
        List<Long> categoryIds = productMapper.selectBatchIds(recentProductIds).stream()
                .map(Product::getCategoryId)
                .distinct()
                .collect(Collectors.toList());
        
        if (categoryIds.isEmpty()) {
            // 如果没有分类信息，返回热门商品
            return getHotProducts(limit);
        }
        
        // 查询相同分类的商品
        QueryWrapper<Product> wrapper = new QueryWrapper<>();
        wrapper.in("category_id", categoryIds)
                .notIn("id", recentProductIds)
                .orderByDesc("sales")
                .last("LIMIT " + limit);
        
        List<Product> recommendedProducts = productMapper.selectList(wrapper);
        
        if (recommendedProducts.size() < limit) {
            // 如果推荐商品不足，补充热门商品
            int remaining = limit - recommendedProducts.size();
            List<Product> hotProducts = getHotProducts(remaining);
            // 过滤掉已经推荐的商品
            hotProducts = hotProducts.stream()
                    .filter(p -> !recommendedProducts.contains(p))
                    .collect(Collectors.toList());
            recommendedProducts.addAll(hotProducts);
        }
        
        return recommendedProducts;
    }
    
    @Override
    public List<Product> getRelatedProducts(Long productId, Integer limit) {
        // 获取当前商品信息
        Product currentProduct = productMapper.selectById(productId);
        if (currentProduct == null) {
            return getHotProducts(limit);
        }
        
        // 查询相同分类的商品
        QueryWrapper<Product> wrapper = new QueryWrapper<>();
        wrapper.eq("category_id", currentProduct.getCategoryId())
                .ne("id", productId)
                .orderByDesc("sales")
                .last("LIMIT " + limit);
        
        List<Product> relatedProducts = productMapper.selectList(wrapper);
        
        if (relatedProducts.size() < limit) {
            // 如果相关商品不足，补充热门商品
            int remaining = limit - relatedProducts.size();
            List<Product> hotProducts = getHotProducts(remaining);
            // 过滤掉已经推荐的商品
            hotProducts = hotProducts.stream()
                    .filter(p -> !relatedProducts.contains(p))
                    .collect(Collectors.toList());
            relatedProducts.addAll(hotProducts);
        }
        
        return relatedProducts;
    }
    
    /**
     * 获取热门商品
     */
    private List<Product> getHotProducts(Integer limit) {
        QueryWrapper<Product> wrapper = new QueryWrapper<>();
        wrapper.orderByDesc("sales")
                .last("LIMIT " + limit);
        return productMapper.selectList(wrapper);
    }
}