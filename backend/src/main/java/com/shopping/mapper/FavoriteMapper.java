package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Favorite;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 商品收藏Mapper
 */
@Mapper
public interface FavoriteMapper extends BaseMapper<Favorite> {
    /**
     * 根据用户ID获取收藏列表
     */
    List<Favorite> getFavoritesByUserId(@Param("userId") Long userId);
    
    /**
     * 检查用户是否已收藏商品
     */
    Integer checkFavorite(@Param("userId") Long userId, @Param("productId") Long productId);
}