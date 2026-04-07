package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.BrowseHistory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 浏览历史Mapper
 */
@Mapper
public interface BrowseHistoryMapper extends BaseMapper<BrowseHistory> {
    /**
     * 根据用户ID获取最近浏览的商品ID列表
     */
    List<Long> getRecentProductIdsByUserId(@Param("userId") Long userId, @Param("limit") Integer limit);
    
    /**
     * 根据用户ID和商品ID获取最新的浏览记录
     */
    BrowseHistory getLatestByUserIdAndProductId(@Param("userId") Long userId, @Param("productId") Long productId);
}