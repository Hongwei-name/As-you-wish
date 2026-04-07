package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.CouponMapper;
import com.shopping.entity.Coupon;
import com.shopping.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

/**
 * 优惠券Service实现类
 */
@Service
public class CouponServiceImpl extends ServiceImpl<CouponMapper, Coupon> implements CouponService {
    
    @Autowired
    private CouponMapper couponMapper;
    
    @Override
    public List<Coupon> getAvailableCoupons() {
        return couponMapper.selectAvailableCoupons();
    }
    
    @Override
    public boolean createCoupon(Coupon coupon) {
        // 初始化剩余数量为总数量
        coupon.setRemainingQuantity(coupon.getTotalQuantity());
        return save(coupon);
    }
    
    @Override
    public boolean updateCoupon(Coupon coupon) {
        return updateById(coupon);
    }
    
    @Override
    public boolean deleteCoupon(Long id) {
        return removeById(id);
    }
}