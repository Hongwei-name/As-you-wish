package com.shopping.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.shopping.entity.Coupon;
import java.util.List;

/**
 * 优惠券Service接口
 */
public interface CouponService extends IService<Coupon> {
    /**
     * 获取可用的优惠券列表
     * @return 可用优惠券列表
     */
    List<Coupon> getAvailableCoupons();
    
    /**
     * 创建优惠券
     * @param coupon 优惠券信息
     * @return 是否创建成功
     */
    boolean createCoupon(Coupon coupon);
    
    /**
     * 更新优惠券
     * @param coupon 优惠券信息
     * @return 是否更新成功
     */
    boolean updateCoupon(Coupon coupon);
    
    /**
     * 删除优惠券
     * @param id 优惠券ID
     * @return 是否删除成功
     */
    boolean deleteCoupon(Long id);
}