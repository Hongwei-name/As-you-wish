package com.shopping.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.Result;
import com.shopping.entity.Product;
import com.shopping.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 商品控制器
 * 提供商品相关的接口
 * 
 * @author 陈洪伟
 */
@RestController
@RequestMapping("/api/product")
public class ProductController {

    @Autowired
    private ProductService productService;

    /**
     * 分页查询商品列表
     * 
     * @param page 页码
     * @param size 每页数量
     * @param categoryId 分类ID（可选）
     * @param keyword 关键词（可选）
     * @param sort 排序方式（可选）
     * @param minPrice 最低价格（可选）
     * @param maxPrice 最高价格（可选）
     * @return 商品分页数据
     */
    @GetMapping("/list")
    public Result<Page<Product>> getProductList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String sort,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice) {
        Page<Product> productPage = productService.getProductList(page, size, categoryId, keyword, sort, minPrice, maxPrice);
        return Result.success(productPage);
    }

    /**
     * 获取商品详情
     * 
     * @param id 商品ID
     * @return 商品详情
     */
    @GetMapping("/{id}")
    public Result<Product> getProductById(@PathVariable Long id) {
        Product product = productService.getProductById(id);
        if (product == null) {
            return Result.error("商品不存在");
        }
        return Result.success(product);
    }

    /**
     * 获取热门商品
     * 
     * @param limit 数量限制
     * @return 热门商品列表
     */
    @GetMapping("/hot")
    public Result<List<Product>> getHotProducts(@RequestParam(defaultValue = "10") Integer limit) {
        List<Product> hotProducts = productService.getHotProducts(limit);
        return Result.success(hotProducts);
    }

    /**
     * 获取推荐商品
     * 
     * @param limit 数量限制
     * @return 推荐商品列表
     */
    @GetMapping("/recommend")
    public Result<List<Product>> getRecommendProducts(@RequestParam(defaultValue = "10") Integer limit) {
        List<Product> recommendProducts = productService.getRecommendProducts(limit);
        return Result.success(recommendProducts);
    }

}
