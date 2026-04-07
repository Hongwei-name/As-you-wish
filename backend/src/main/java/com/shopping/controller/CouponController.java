package com.shopping.controller;

import com.shopping.entity.Coupon;
import com.shopping.service.CouponService;
import com.shopping.service.CouponUserService;
import com.shopping.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import jakarta.servlet.http.HttpServletRequest;

/**
 * 优惠券控制器
 */
@RestController
@RequestMapping("/api/coupon")
public class CouponController {
    
    @Autowired
    private CouponService couponService;
    
    @Autowired
    private CouponUserService couponUserService;
    
    /**
     * 获取可用的优惠券列表
     */
    @GetMapping("/available")
    public Result<List<Coupon>> getAvailableCoupons() {
        List<Coupon> coupons = couponService.getAvailableCoupons();
        return Result.success(coupons);
    }
    
    /**
     * 获取用户的优惠券列表
     */
    @GetMapping("/user")
    public Result<List<?>> getUserCoupons(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<?> coupons = couponUserService.getUserCoupons(userId);
        return Result.success(coupons);
    }
    
    /**
     * 领取优惠券
     */
    @PostMapping("/receive/{couponId}")
    public Result<Boolean> receiveCoupon(@PathVariable Long couponId, HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        boolean result = couponUserService.receiveCoupon(userId, couponId);
        if (result) {
            return Result.success("领取成功", true);
        } else {
            return Result.error("领取失败，可能已领取或优惠券已用完");
        }
    }
    
    /**
     * 创建优惠券（管理员）
     */
    @PostMapping("/create")
    public Result<Boolean> createCoupon(@RequestBody Coupon coupon) {
        boolean result = couponService.createCoupon(coupon);
        if (result) {
            return Result.success("创建成功", true);
        } else {
            return Result.error("创建失败");
        }
    }
    
    /**
     * 更新优惠券（管理员）
     */
    @PutMapping("/update")
    public Result<Boolean> updateCoupon(@RequestBody Coupon coupon) {
        boolean result = couponService.updateCoupon(coupon);
        if (result) {
            return Result.success("更新成功", true);
        } else {
            return Result.error("更新失败");
        }
    }
    
    /**
     * 删除优惠券（管理员）
     */
    @DeleteMapping("/delete/{id}")
    public Result<Boolean> deleteCoupon(@PathVariable Long id) {
        boolean result = couponService.deleteCoupon(id);
        if (result) {
            return Result.success("删除成功", true);
        } else {
            return Result.error("删除失败");
        }
    }
    
    /**
     * 获取所有优惠券（管理员）
     */
    @GetMapping("/list")
    public Result<List<Coupon>> getAllCoupons() {
        List<Coupon> coupons = couponService.list();
        return Result.success(coupons);
    }
}