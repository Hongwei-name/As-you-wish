package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.CouponUser;
import java.util.List;

/**
 * 优惠券领取记录Service接口
 */
public interface CouponUserService extends IService<CouponUser> {
    /**
     * 获取用户的优惠券列表
     * @param userId 用户ID
     * @return 优惠券列表
     */
    List<CouponUser> getUserCoupons(Long userId);
    
    /**
     * 用户领取优惠券
     * @param userId 用户ID
     * @param couponId 优惠券ID
     * @return 是否领取成功
     */
    boolean receiveCoupon(Long userId, Long couponId);
    
    /**
     * 使用优惠券
     * @param id 优惠券领取记录ID
     * @return 是否使用成功
     */
    boolean useCoupon(Long id);
    
    /**
     * 检查用户是否已领取该优惠券
     * @param userId 用户ID
     * @param couponId 优惠券ID
     * @return 是否已领取
     */
    boolean hasReceivedCoupon(Long userId, Long couponId);
}