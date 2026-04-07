package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.entity.Product;
import com.shopping.mapper.ProductMapper;
import com.shopping.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 商品服务实现类
 * 实现商品相关的业务逻辑
 * 
 * @author 陈洪伟
 */
@Service
public class ProductServiceImpl implements ProductService {

    @Autowired
    private ProductMapper productMapper;

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
    @Override
    public Page<Product> getProductList(Integer page, Integer size, Long categoryId, String keyword, String sort, Double minPrice, Double maxPrice) {
        Page<Product> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Product> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Product::getStatus, 1);
        if (categoryId != null) {
            queryWrapper.eq(Product::getCategoryId, categoryId);
        }
        if (StringUtils.hasText(keyword)) {
            // 扩展搜索字段，包括商品名称和描述
            queryWrapper.and(wrapper -> wrapper
                .like(Product::getName, keyword)
                .or()
                .like(Product::getDescription, keyword)
            );
        }
        if (minPrice != null) {
            queryWrapper.ge(Product::getPrice, minPrice);
        }
        if (maxPrice != null) {
            queryWrapper.le(Product::getPrice, maxPrice);
        }
        // 排序
        if (StringUtils.hasText(sort)) {
            switch (sort) {
                case "price_asc":
                    queryWrapper.orderByAsc(Product::getPrice);
                    break;
                case "price_desc":
                    queryWrapper.orderByDesc(Product::getPrice);
                    break;
                case "sales_desc":
                    queryWrapper.orderByDesc(Product::getSales);
                    break;
                case "rating_desc":
                    // 按评分降序排序，使用子查询获取平均评分
                    queryWrapper.last("LEFT JOIN (SELECT product_id, AVG(rating) as avg_rating FROM t_review GROUP BY product_id) r ON t_product.id = r.product_id ORDER BY r.avg_rating DESC NULLS LAST");
                    break;
                case "created_desc":
                    queryWrapper.orderByDesc(Product::getCreatedAt);
                    break;
                default:
                    queryWrapper.orderByDesc(Product::getCreatedAt);
                    break;
            }
        } else {
            queryWrapper.orderByDesc(Product::getCreatedAt);
        }
        return productMapper.selectPage(pageParam, queryWrapper);
    }

    /**
     * 根据ID查询商品详情
     * 
     * @param id 商品ID
     * @return 商品详情
     */
    @Override
    public Product getProductById(Long id) {
        return productMapper.selectById(id);
    }

    /**
     * 查询热门商品
     * 
     * @param limit 数量限制
     * @return 热门商品列表
     */
    @Override
    public List<Product> getHotProducts(Integer limit) {
        LambdaQueryWrapper<Product> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Product::getStatus, 1)
                .orderByDesc(Product::getSales)
                .last("LIMIT " + limit);
        return productMapper.selectList(queryWrapper);
    }

    /**
     * 查询推荐商品
     * 
     * @param limit 数量限制
     * @return 推荐商品列表
     */
    @Override
    public List<Product> getRecommendProducts(Integer limit) {
        LambdaQueryWrapper<Product> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Product::getStatus, 1)
                .orderByDesc(Product::getCreatedAt)
                .last("LIMIT " + limit);
        return productMapper.selectList(queryWrapper);
    }

    @Override
    public Product saveProduct(Product product) {
        productMapper.insert(product);
        return product;
    }

    @Override
    public Product updateProduct(Product product) {
        productMapper.updateById(product);
        return product;
    }

    @Override
    public boolean deleteProduct(Long id) {
        productMapper.deleteById(id);
        return true;
    }

    @Override
    public boolean updateProductStatus(Long id, Integer status) {
        Product product = productMapper.selectById(id);
        if (product == null) {
            throw new RuntimeException("商品不存在");
        }
        product.setStatus(status);
        productMapper.updateById(product);
        return true;
    }

    @Override
    public Page<Product> getProductList(Integer page, Integer size, Long categoryId, String keyword, Integer status) {
        Page<Product> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Product> queryWrapper = new LambdaQueryWrapper<>();
        
        if (categoryId != null) {
            queryWrapper.eq(Product::getCategoryId, categoryId);
        }
        if (StringUtils.hasText(keyword)) {
            // 扩展搜索字段，包括商品名称和描述
            queryWrapper.and(wrapper -> wrapper
                .like(Product::getName, keyword)
                .or()
                .like(Product::getDescription, keyword)
            );
        }
        if (status != null) {
            queryWrapper.eq(Product::getStatus, status);
        }
        queryWrapper.orderByDesc(Product::getCreatedAt);
        return productMapper.selectPage(pageParam, queryWrapper);
    }

    @Override
    public java.util.Map<String, Object> getProductStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        
        // 总商品数
        long totalProducts = productMapper.selectCount(null);
        stats.put("totalProducts", totalProducts);
        
        // 上架商品数
        LambdaQueryWrapper<Product> onlineQuery = new LambdaQueryWrapper<>();
        onlineQuery.eq(Product::getStatus, 1);
        long onlineCount = productMapper.selectCount(onlineQuery);
        stats.put("onlineCount", onlineCount);
        
        // 下架商品数
        stats.put("offlineCount", totalProducts - onlineCount);
        
        return stats;
    }

}
