package com.shopping.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.shopping.mapper.CouponUserMapper;
import com.shopping.mapper.CouponMapper;
import com.shopping.entity.CouponUser;
import com.shopping.service.CouponUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 优惠券领取记录Service实现类
 */
@Service
public class CouponUserServiceImpl extends ServiceImpl<CouponUserMapper, CouponUser> implements CouponUserService {
    
    @Autowired
    private CouponUserMapper couponUserMapper;
    
    @Autowired
    private CouponMapper couponMapper;
    
    @Override
    public List<CouponUser> getUserCoupons(Long userId) {
        return couponUserMapper.selectByUserId(userId);
    }
    
    @Override
    @Transactional
    public boolean receiveCoupon(Long userId, Long couponId) {
        // 检查用户是否已领取该优惠券
        if (hasReceivedCoupon(userId, couponId)) {
            return false;
        }
        
        // 减少优惠券剩余数量
        int result = couponMapper.decreaseRemainingQuantity(couponId);
        if (result == 0) {
            return false;
        }
        
        // 创建优惠券领取记录
        CouponUser couponUser = new CouponUser();
        couponUser.setUserId(userId);
        couponUser.setCouponId(couponId);
        couponUser.setStatus(1); // 1-未使用
        couponUser.setReceiveTime(LocalDateTime.now());
        
        return save(couponUser);
    }
    
    @Override
    public boolean useCoupon(Long id) {
        CouponUser couponUser = getById(id);
        if (couponUser == null || couponUser.getStatus() != 1) {
            return false;
        }
        
        couponUser.setStatus(2); // 2-已使用
        couponUser.setUseTime(LocalDateTime.now());
        
        return updateById(couponUser);
    }
    
    @Override
    public boolean hasReceivedCoupon(Long userId, Long couponId) {
        int count = couponUserMapper.countByUserIdAndCouponId(userId, couponId);
        return count > 0;
    }
}