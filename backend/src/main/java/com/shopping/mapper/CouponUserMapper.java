package com.shopping.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.shopping.entity.CouponUser;
import java.util.List;
import org.apache.ibatis.annotations.Param;

/**
 * 优惠券领取记录Mapper接口
 */
public interface CouponUserMapper extends BaseMapper<CouponUser> {
    /**
     * 获取用户的优惠券列表
     * @param userId 用户ID
     * @return 优惠券列表
     */
    List<CouponUser> selectByUserId(@Param("userId") Long userId);
    
    /**
     * 检查用户是否已领取该优惠券
     * @param userId 用户ID
     * @param couponId 优惠券ID
     * @return 领取记录数量
     */
    int countByUserIdAndCouponId(@Param("userId") Long userId, @Param("couponId") Long couponId);
}