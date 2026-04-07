package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.shopping.entity.Favorite;
import com.shopping.mapper.FavoriteMapper;
import com.shopping.service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 商品收藏服务实现
 */
@Service
public class FavoriteServiceImpl implements FavoriteService {
    
    @Autowired
    private FavoriteMapper favoriteMapper;
    
    @Override
    public boolean addFavorite(Long userId, Long productId) {
        Favorite favorite = new Favorite();
        favorite.setUserId(userId);
        favorite.setProductId(productId);
        return favoriteMapper.insert(favorite) > 0;
    }
    
    @Override
    public boolean removeFavorite(Long userId, Long productId) {
        QueryWrapper<Favorite> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("product_id", productId);
        return favoriteMapper.delete(wrapper) > 0;
    }
    
    @Override
    public List<Favorite> getFavoritesByUserId(Long userId) {
        return favoriteMapper.getFavoritesByUserId(userId);
    }
    
    @Override
    public boolean isFavorite(Long userId, Long productId) {
        Integer count = favoriteMapper.checkFavorite(userId, productId);
        return count != null && count > 0;
    }
}