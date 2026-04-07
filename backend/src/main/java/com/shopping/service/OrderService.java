package com.shopping.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.dto.OrderCreateDTO;
import com.shopping.vo.OrderVO;

/**
 * 订单服务接口
 * 定义订单相关的业务逻辑方法
 * 
 * @author 陈洪伟
 */
public interface OrderService {

    /**
     * 创建订单
     * 从购物车创建订单，扣减库存，清空购物车
     * 
     * @param userId 用户ID
     * @param createDTO 创建订单DTO
     * @return 订单信息
     */
    OrderVO createOrder(Long userId, OrderCreateDTO createDTO);

    /**
     * 根据ID查询订单详情
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     * @return 订单详情
     */
    OrderVO getOrderById(Long userId, Long orderId);

    /**
     * 根据ID查询订单实体
     * 
     * @param orderId 订单ID
     * @return 订单实体
     */
    com.shopping.entity.Order getOrderEntityById(Long orderId);

    /**
     * 查询用户订单列表
     * 支持状态筛选和分页
     * 
     * @param userId 用户ID
     * @param status 订单状态（可选）
     * @param page 页码
     * @param size 每页大小
     * @return 订单分页列表
     */
    Page<OrderVO> getOrderList(Long userId, Integer status, Integer page, Integer size);

    /**
     * 取消订单
     * 恢复库存
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    void cancelOrder(Long userId, Long orderId);

    /**
     * 确认收货
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    void confirmReceive(Long userId, Long orderId);

    /**
     * 删除订单
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    void deleteOrder(Long userId, Long orderId);

    /**
     * 更新订单状态
     * 
     * @param orderId 订单ID
     * @param status 订单状态
     */
    void updateOrderStatus(Long orderId, Integer status);

    /**
     * 管理端获取订单列表
     * 
     * @param page 页码
     * @param size 每页数量
     * @param status 订单状态
     * @param keyword 关键词
     * @return 订单分页列表
     */
    Page<OrderVO> getOrderListAdmin(Integer page, Integer size, Integer status, String keyword);

    /**
     * 管理端获取订单详情
     * 
     * @param orderId 订单ID
     * @return 订单详情
     */
    OrderVO getOrderByIdAdmin(Long orderId);

    /**
     * 管理端更新订单状态
     * 
     * @param orderId 订单ID
     * @param status 订单状态
     */
    void updateOrderStatusAdmin(Long orderId, Integer status);

    /**
     * 获取销售统计
     * 
     * @return 统计数据
     */
    java.util.Map<String, Object> getSalesStats();

}
