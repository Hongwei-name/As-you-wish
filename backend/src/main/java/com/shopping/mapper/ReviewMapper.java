package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Review;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

/**
 * 商品评价Mapper
 */
@Mapper
public interface ReviewMapper extends BaseMapper<Review> {
    /**
     * 根据商品ID获取评价列表
     */
    List<Review> getReviewsByProductId(@Param("productId") Long productId);
    
    /**
     * 获取商品的平均评分
     */
    Double getAverageRatingByProductId(@Param("productId") Long productId);
    
    /**
     * 统计商品各星级的评价数量
     */
    List<Map<String, Object>> getRatingDistributionByProductId(@Param("productId") Long productId);
}