package com.shopping.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.entity.Product;

import java.util.List;

/**
 * 商品服务接口
 * 提供商品相关的业务逻辑
 * 
 * @author 陈洪伟
 */
public interface ProductService {

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
    Page<Product> getProductList(Integer page, Integer size, Long categoryId, String keyword, String sort, Double minPrice, Double maxPrice);

    /**
     * 根据ID查询商品详情
     * 
     * @param id 商品ID
     * @return 商品详情
     */
    Product getProductById(Long id);

    /**
     * 查询热门商品
     * 
     * @param limit 数量限制
     * @return 热门商品列表
     */
    List<Product> getHotProducts(Integer limit);

    /**
     * 查询推荐商品
     * 
     * @param limit 数量限制
     * @return 推荐商品列表
     */
    List<Product> getRecommendProducts(Integer limit);

    /**
     * 保存商品
     * 
     * @param product 商品信息
     * @return 保存后的商品
     */
    Product saveProduct(Product product);

    /**
     * 更新商品
     * 
     * @param product 商品信息
     * @return 更新后的商品
     */
    Product updateProduct(Product product);

    /**
     * 删除商品
     * 
     * @param id 商品ID
     * @return 是否成功
     */
    boolean deleteProduct(Long id);

    /**
     * 更新商品状态
     * 
     * @param id 商品ID
     * @param status 状态
     * @return 是否成功
     */
    boolean updateProductStatus(Long id, Integer status);

    /**
     * 分页查询商品列表（管理端）
     * 
     * @param page 页码
     * @param size 每页数量
     * @param categoryId 分类ID（可选）
     * @param keyword 关键词（可选）
     * @param status 状态（可选）
     * @return 商品分页数据
     */
    Page<Product> getProductList(Integer page, Integer size, Long categoryId, String keyword, Integer status);

    /**
     * 获取商品统计
     * 
     * @return 统计数据
     */
    java.util.Map<String, Object> getProductStats();

}
