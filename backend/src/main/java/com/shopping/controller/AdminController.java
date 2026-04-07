package com.shopping.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.common.Result;
import com.shopping.dto.UserLoginDTO;
import com.shopping.entity.Category;
import com.shopping.entity.Order;
import com.shopping.entity.Product;
import com.shopping.entity.User;
import com.shopping.service.CategoryService;
import com.shopping.service.OrderService;
import com.shopping.service.ProductService;
import com.shopping.service.UserService;
import com.shopping.service.BannerService;
import com.shopping.entity.Banner;
import com.shopping.utils.JwtUtil;
import com.shopping.vo.OrderVO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 后台管理控制器
 * 提供管理员相关的REST API接口
 * 
 * @author 陈洪伟
 */
@Slf4j
@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private ProductService productService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private BannerService bannerService;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 管理员登录接口
     * 
     * @param loginDTO 登录信息
     * @return JWT Token
     */
    @PostMapping("/login")
    public Result<Map<String, Object>> adminLogin(@Valid @RequestBody UserLoginDTO loginDTO) {
        log.info("管理员登录请求，用户名：{}", loginDTO.getUsername());
        
        User user = userService.getUserByUsername(loginDTO.getUsername());
        if (user == null) {
            return Result.error("用户名或密码错误");
        }
        
        // 检查是否是管理员
        if (user.getRole() != 1) {
            return Result.error("无管理员权限");
        }
        
        // 验证密码
        if (!userService.checkPassword(loginDTO.getPassword(), user.getPassword())) {
            return Result.error("用户名或密码错误");
        }
        
        // 生成JWT token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
        
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("user", user);
        
        return Result.success("登录成功", data);
    }

    // ==================== 用户管理 ====================

    /**
     * 获取用户列表
     * 
     * @param page 页码
     * @param size 每页数量
     * @param keyword 关键词
     * @return 用户分页列表
     */
    @GetMapping("/user/list")
    public Result<Page<User>> getUserList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword) {
        Page<User> userPage = userService.getUserList(page, size, keyword);
        return Result.success(userPage);
    }

    /**
     * 获取用户详情
     * 
     * @param id 用户ID
     * @return 用户详情
     */
    @GetMapping("/user/{id}")
    public Result<User> getUserById(@PathVariable Long id) {
        User user = userService.getUserById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        return Result.success(user);
    }

    /**
     * 更新用户状态
     * 
     * @param id 用户ID
     * @param status 状态
     * @return 操作结果
     */
    @PutMapping("/user/status/{id}")
    public Result<String> updateUserStatus(@PathVariable Long id, @RequestParam Integer status) {
        userService.updateUserStatus(id, status);
        return Result.success("操作成功");
    }

    // ==================== 商品管理 ====================

    /**
     * 获取商品列表
     * 
     * @param page 页码
     * @param size 每页数量
     * @param categoryId 分类ID
     * @param keyword 关键词
     * @param status 状态
     * @return 商品分页列表
     */
    @GetMapping("/product/list")
    public Result<Page<Product>> getProductList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Integer status) {
        Page<Product> productPage = productService.getProductList(page, size, categoryId, keyword, status);
        return Result.success(productPage);
    }

    /**
     * 新增商品
     * 
     * @param product 商品信息
     * @return 操作结果
     */
    @PostMapping("/product/add")
    public Result<Product> addProduct(@RequestBody Product product) {
        Product savedProduct = productService.saveProduct(product);
        return Result.success("添加成功", savedProduct);
    }

    /**
     * 更新商品
     * 
     * @param product 商品信息
     * @return 操作结果
     */
    @PutMapping("/product/update")
    public Result<Product> updateProduct(@RequestBody Product product) {
        Product updatedProduct = productService.updateProduct(product);
        return Result.success("更新成功", updatedProduct);
    }

    /**
     * 删除商品
     * 
     * @param id 商品ID
     * @return 操作结果
     */
    @DeleteMapping("/product/{id}")
    public Result<String> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return Result.success("删除成功");
    }

    /**
     * 更新商品状态
     * 
     * @param id 商品ID
     * @param status 状态
     * @return 操作结果
     */
    @PutMapping("/product/status/{id}")
    public Result<String> updateProductStatus(@PathVariable Long id, @RequestParam Integer status) {
        productService.updateProductStatus(id, status);
        return Result.success("操作成功");
    }

    // ==================== 分类管理 ====================

    /**
     * 获取分类列表
     * 
     * @return 分类列表
     */
    @GetMapping("/category/list")
    public Result<List<Category>> getCategoryList() {
        List<Category> categories = categoryService.getCategoryList();
        return Result.success(categories);
    }

    /**
     * 新增分类
     * 
     * @param category 分类信息
     * @return 操作结果
     */
    @PostMapping("/category/add")
    public Result<Category> addCategory(@RequestBody Category category) {
        Category savedCategory = categoryService.saveCategory(category);
        return Result.success("添加成功", savedCategory);
    }

    /**
     * 更新分类
     * 
     * @param category 分类信息
     * @return 操作结果
     */
    @PutMapping("/category/update")
    public Result<Category> updateCategory(@RequestBody Category category) {
        Category updatedCategory = categoryService.updateCategory(category);
        return Result.success("更新成功", updatedCategory);
    }

    /**
     * 删除分类
     * 
     * @param id 分类ID
     * @return 操作结果
     */
    @DeleteMapping("/category/{id}")
    public Result<String> deleteCategory(@PathVariable Long id) {
        categoryService.deleteCategory(id);
        return Result.success("删除成功");
    }

    // ==================== 订单管理 ====================

    /**
     * 获取订单列表
     * 
     * @param page 页码
     * @param size 每页数量
     * @param status 订单状态
     * @param keyword 关键词
     * @return 订单分页列表
     */
    @GetMapping("/order/list")
    public Result<Page<OrderVO>> getOrderList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Integer status,
            @RequestParam(required = false) String keyword) {
        Page<OrderVO> orderPage = orderService.getOrderListAdmin(page, size, status, keyword);
        return Result.success(orderPage);
    }

    /**
     * 获取订单详情
     * 
     * @param id 订单ID
     * @return 订单详情
     */
    @GetMapping("/order/{id}")
    public Result<OrderVO> getOrderById(@PathVariable Long id) {
        OrderVO orderVO = orderService.getOrderByIdAdmin(id);
        if (orderVO == null) {
            return Result.error("订单不存在");
        }
        return Result.success(orderVO);
    }

    /**
     * 更新订单状态
     * 
     * @param id 订单ID
     * @param status 状态
     * @return 操作结果
     */
    @PutMapping("/order/status/{id}")
    public Result<String> updateOrderStatus(@PathVariable Long id, @RequestParam Integer status) {
        orderService.updateOrderStatusAdmin(id, status);
        return Result.success("操作成功");
    }

    // ==================== 数据统计 ====================

    /**
     * 获取销售统计
     * 
     * @return 销售统计数据
     */
    @GetMapping("/stats/sales")
    public Result<Map<String, Object>> getSalesStats() {
        Map<String, Object> stats = orderService.getSalesStats();
        return Result.success(stats);
    }

    /**
     * 获取用户统计
     * 
     * @return 用户统计数据
     */
    @GetMapping("/stats/users")
    public Result<Map<String, Object>> getUserStats() {
        Map<String, Object> stats = userService.getUserStats();
        return Result.success(stats);
    }

    /**
     * 获取商品统计
     * 
     * @return 商品统计数据
     */
    @GetMapping("/stats/products")
    public Result<Map<String, Object>> getProductStats() {
        Map<String, Object> stats = productService.getProductStats();
        return Result.success(stats);
    }

    /**
     * 获取统计数据
     * 
     * @param dateRange 日期范围
     * @return 统计数据
     */
    @GetMapping("/stats")
    public Result<Map<String, Object>> getStatistics(@RequestParam String dateRange) {
        Map<String, Object> stats = new HashMap<>();
        
        // 获取销售统计
        Map<String, Object> salesStats = orderService.getSalesStats();
        stats.put("totalSales", salesStats.get("totalSales"));
        stats.put("totalOrders", salesStats.get("totalOrders"));
        
        // 获取用户统计
        Map<String, Object> userStats = userService.getUserStats();
        stats.put("totalUsers", userStats.get("totalUsers"));
        
        // 获取商品统计
        Map<String, Object> productStats = productService.getProductStats();
        stats.put("totalProducts", productStats.get("totalProducts"));
        
        // 模拟变化率
        stats.put("salesChange", 12.5);
        stats.put("orderChange", 8.3);
        stats.put("userChange", 5.2);
        stats.put("productChange", 3.1);
        
        return Result.success(stats);
    }

    // ==================== 轮播图管理 ====================

    /**
     * 获取轮播图列表
     * 
     * @return 轮播图列表
     */
    @GetMapping("/banner/list")
    public Result<List<Banner>> getBannerList() {
        List<Banner> banners = bannerService.getAllBanners();
        return Result.success(banners);
    }

    /**
     * 添加轮播图
     * 
     * @param banner 轮播图信息
     * @return 操作结果
     */
    @PostMapping("/banner/add")
    public Result<Banner> addBanner(@RequestBody Banner banner) {
        Banner savedBanner = bannerService.saveBanner(banner);
        return Result.success("添加成功", savedBanner);
    }

    /**
     * 更新轮播图
     * 
     * @param banner 轮播图信息
     * @return 操作结果
     */
    @PutMapping("/banner/update")
    public Result<Banner> updateBanner(@RequestBody Banner banner) {
        Banner updatedBanner = bannerService.updateBanner(banner);
        return Result.success("更新成功", updatedBanner);
    }

    /**
     * 删除轮播图
     * 
     * @param id 轮播图ID
     * @return 操作结果
     */
    @DeleteMapping("/banner/{id}")
    public Result<String> deleteBanner(@PathVariable Long id) {
        bannerService.deleteBanner(id);
        return Result.success("删除成功");
    }

    /**
     * 更新轮播图状态
     * 
     * @param id 轮播图ID
     * @param status 状态
     * @return 操作结果
     */
    @PutMapping("/banner/status/{id}")
    public Result<String> updateBannerStatus(@PathVariable Long id, @RequestParam Integer status) {
        bannerService.updateBannerStatus(id, status);
        return Result.success("操作成功");
    }

}