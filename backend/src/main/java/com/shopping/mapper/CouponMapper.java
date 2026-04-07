package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.Coupon;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 优惠券Mapper接口
 */
public interface CouponMapper extends BaseMapper<Coupon> {
    /**
     * 获取可用的优惠券列表
     * @return 可用优惠券列表
     */
    List<Coupon> selectAvailableCoupons();
    
    /**
     * 减少优惠券剩余数量
     * @param couponId 优惠券ID
     * @return 影响行数
     */
    int decreaseRemainingQuantity(@Param("couponId") Long couponId);
}