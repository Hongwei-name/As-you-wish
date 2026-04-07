package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Promotion;
import java.util.List;

/**
 * 促销活动Mapper接口
 */
public interface PromotionMapper extends BaseMapper<Promotion> {
    /**
     * 获取进行中的促销活动列表
     * @return 进行中的促销活动列表
     */
    List<Promotion> selectActivePromotions();
}