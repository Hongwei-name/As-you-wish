package com.shopping.controller;

import com.shopping.entity.Promotion;
import com.shopping.entity.PromotionProduct;
import com.shopping.service.PromotionService;
import com.shopping.service.PromotionProductService;
import com.shopping.common.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

/**
 * 促销活动控制器
 */
@RestController
@RequestMapping("/api/promotion")
public class PromotionController {
    
    @Autowired
    private PromotionService promotionService;
    
    @Autowired
    private PromotionProductService promotionProductService;
    
    /**
     * 获取进行中的促销活动列表
     */
    @GetMapping("/active")
    public Result<List<Promotion>> getActivePromotions() {
        List<Promotion> promotions = promotionService.getActivePromotions();
        return Result.success(promotions);
    }
    
    /**
     * 根据促销活动ID获取商品列表
     */
    @GetMapping("/products/{promotionId}")
    public Result<List<PromotionProduct>> getPromotionProducts(@PathVariable Long promotionId) {
        List<PromotionProduct> products = promotionProductService.getByPromotionId(promotionId);
        return Result.success(products);
    }
    
    /**
     * 根据商品ID获取促销信息
     */
    @GetMapping("/product/{productId}")
    public Result<PromotionProduct> getProductPromotion(@PathVariable Long productId) {
        PromotionProduct promotion = promotionProductService.getByProductId(productId);
        return Result.success(promotion);
    }
    
    /**
     * 创建促销活动（管理员）
     */
    @PostMapping("/create")
    public Result<Boolean> createPromotion(@RequestBody Promotion promotion) {
        boolean result = promotionService.createPromotion(promotion);
        if (result) {
            return Result.success("创建成功", true);
        } else {
            return Result.error("创建失败");
        }
    }
    
    /**
     * 更新促销活动（管理员）
     */
    @PutMapping("/update")
    public Result<Boolean> updatePromotion(@RequestBody Promotion promotion) {
        boolean result = promotionService.updatePromotion(promotion);
        if (result) {
            return Result.success("更新成功", true);
        } else {
            return Result.error("更新失败");
        }
    }
    
    /**
     * 删除促销活动（管理员）
     */
    @DeleteMapping("/delete/{id}")
    public Result<Boolean> deletePromotion(@PathVariable Long id) {
        boolean result = promotionService.deletePromotion(id);
        if (result) {
            return Result.success("删除成功", true);
        } else {
            return Result.error("删除失败");
        }
    }
    
    /**
     * 添加促销商品（管理员）
     */
    @PostMapping("/product/add")
    public Result<Boolean> addPromotionProduct(@RequestBody PromotionProduct promotionProduct) {
        boolean result = promotionProductService.addPromotionProduct(promotionProduct);
        if (result) {
            return Result.success("添加成功", true);
        } else {
            return Result.error("添加失败");
        }
    }
    
    /**
     * 更新促销商品（管理员）
     */
    @PutMapping("/product/update")
    public Result<Boolean> updatePromotionProduct(@RequestBody PromotionProduct promotionProduct) {
        boolean result = promotionProductService.updatePromotionProduct(promotionProduct);
        if (result) {
            return Result.success("更新成功", true);
        } else {
            return Result.error("更新失败");
        }
    }
    
    /**
     * 删除促销商品（管理员）
     */
    @DeleteMapping("/product/delete/{id}")
    public Result<Boolean> deletePromotionProduct(@PathVariable Long id) {
        boolean result = promotionProductService.deletePromotionProduct(id);
        if (result) {
            return Result.success("删除成功", true);
        } else {
            return Result.error("删除失败");
        }
    }
    
    /**
     * 获取所有促销活动（管理员）
     */
    @GetMapping("/list")
    public Result<List<Promotion>> getAllPromotions() {
        List<Promotion> promotions = promotionService.list();
        return Result.success(promotions);
    }
}