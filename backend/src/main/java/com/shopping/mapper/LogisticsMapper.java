package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Logistics;
import org.apache.ibatis.annotations.Param;

/**
 * 物流信息Mapper接口
 */
public interface LogisticsMapper extends BaseMapper<Logistics> {
    /**
     * 根据订单ID获取物流信息
     * @param orderId 订单ID
     * @return 物流信息
     */
    Logistics selectByOrderId(@Param("orderId") Long orderId);
}