package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.shopping.dto.OrderCreateDTO;
import com.shopping.entity.Address;
import com.shopping.entity.Cart;
import com.shopping.entity.Order;
import com.shopping.entity.OrderItem;
import com.shopping.entity.Product;
import com.shopping.mapper.AddressMapper;
import com.shopping.mapper.CartMapper;
import com.shopping.mapper.OrderItemMapper;
import com.shopping.mapper.OrderMapper;
import com.shopping.mapper.ProductMapper;
import com.shopping.service.OrderService;
import com.shopping.vo.CartVO;
import com.shopping.vo.OrderVO;
import com.shopping.service.UserPointService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * 订单服务实现类
 * 实现订单相关的业务逻辑
 * 
 * @author 陈洪伟
 */
@Slf4j
@Service
public class OrderServiceImpl implements OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private OrderItemMapper orderItemMapper;

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private ProductMapper productMapper;

    @Autowired
    private AddressMapper addressMapper;
    
    @Autowired
    private UserPointService userPointService;

    /**
     * 创建订单
     * 从购物车创建订单，扣减库存，清空购物车
     * 
     * @param userId 用户ID
     * @param createDTO 创建订单DTO
     * @return 订单信息
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public OrderVO createOrder(Long userId, OrderCreateDTO createDTO) {
        Address address = addressMapper.selectById(createDTO.getAddressId());
        if (address == null) {
            throw new RuntimeException("收货地址不存在");
        }
        if (!address.getUserId().equals(userId)) {
            throw new RuntimeException("无权限使用此地址");
        }

        List<CartVO> cartList = cartMapper.selectCartListByUserId(userId);
        if (cartList == null || cartList.isEmpty()) {
            throw new RuntimeException("购物车为空，无法创建订单");
        }

        List<CartVO> selectedCartList = new ArrayList<>();
        for (CartVO cartVO : cartList) {
            if (cartVO.getSelected() != null && cartVO.getSelected() == 1) {
                selectedCartList.add(cartVO);
            }
        }
        if (selectedCartList.isEmpty()) {
            throw new RuntimeException("请选择要购买的商品");
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        for (CartVO cartVO : selectedCartList) {
            Product product = productMapper.selectById(cartVO.getProductId());
            if (product == null) {
                throw new RuntimeException("商品不存在：" + cartVO.getProductName());
            }
            if (product.getStatus() != 1) {
                throw new RuntimeException("商品已下架：" + product.getName());
            }
            if (product.getStock() < cartVO.getQuantity()) {
                throw new RuntimeException("商品库存不足：" + product.getName());
            }
            BigDecimal subtotal = product.getPrice().multiply(new BigDecimal(cartVO.getQuantity()));
            totalAmount = totalAmount.add(subtotal);
        }

        BigDecimal freightAmount = BigDecimal.ZERO;
        BigDecimal payAmount = totalAmount.add(freightAmount);

        Order order = new Order();
        order.setOrderNo(generateOrderNo());
        order.setUserId(userId);
        order.setAddressId(createDTO.getAddressId());
        order.setTotalAmount(totalAmount);
        order.setPayAmount(payAmount);
        order.setFreightAmount(freightAmount);
        order.setStatus(0);
        orderMapper.insert(order);

        for (CartVO cartVO : selectedCartList) {
            Product product = productMapper.selectById(cartVO.getProductId());
            
            OrderItem orderItem = new OrderItem();
            orderItem.setOrderId(order.getId());
            orderItem.setProductId(cartVO.getProductId());
            orderItem.setProductName(product.getName());
            orderItem.setProductImage(product.getImage());
            orderItem.setPrice(product.getPrice());
            orderItem.setQuantity(cartVO.getQuantity());
            orderItem.setTotalAmount(product.getPrice().multiply(new BigDecimal(cartVO.getQuantity())));
            orderItemMapper.insert(orderItem);

            product.setStock(product.getStock() - cartVO.getQuantity());
            product.setSales(product.getSales() + cartVO.getQuantity());
            productMapper.updateById(product);
        }

        LambdaQueryWrapper<Cart> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Cart::getUserId, userId)
                .eq(Cart::getSelected, 1);
        cartMapper.delete(queryWrapper);

        return getOrderById(userId, order.getId());
    }

    /**
     * 根据ID查询订单详情
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     * @return 订单详情
     */
    @Override
    public OrderVO getOrderById(Long userId, Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权限查看此订单");
        }

        OrderVO orderVO = new OrderVO();
        BeanUtils.copyProperties(order, orderVO);
        orderVO.setStatusDesc(getStatusDesc(order.getStatus()));

        Address address = addressMapper.selectById(order.getAddressId());
        if (address != null) {
            orderVO.setReceiver(address.getReceiver());
            orderVO.setPhone(address.getPhone());
            orderVO.setAddress(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetail());
        }

        List<OrderItem> orderItems = orderItemMapper.selectByOrderId(orderId);
        List<OrderVO.OrderItemVO> itemVOList = new ArrayList<>();
        for (OrderItem orderItem : orderItems) {
            OrderVO.OrderItemVO itemVO = new OrderVO.OrderItemVO();
            BeanUtils.copyProperties(orderItem, itemVO);
            itemVOList.add(itemVO);
        }
        orderVO.setOrderItems(itemVOList);

        return orderVO;
    }

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
    @Override
    public Page<OrderVO> getOrderList(Long userId, Integer status, Integer page, Integer size) {
        Page<Order> orderPage = new Page<>(page, size);
        LambdaQueryWrapper<Order> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Order::getUserId, userId);
        if (status != null) {
            queryWrapper.eq(Order::getStatus, status);
        }
        queryWrapper.orderByDesc(Order::getCreatedAt);
        orderMapper.selectPage(orderPage, queryWrapper);

        Page<OrderVO> voPage = new Page<>(page, size);
        voPage.setTotal(orderPage.getTotal());
        voPage.setPages(orderPage.getPages());

        List<OrderVO> voList = new ArrayList<>();
        for (Order order : orderPage.getRecords()) {
            OrderVO orderVO = new OrderVO();
            BeanUtils.copyProperties(order, orderVO);
            orderVO.setStatusDesc(getStatusDesc(order.getStatus()));

            Address address = addressMapper.selectById(order.getAddressId());
            if (address != null) {
                orderVO.setReceiver(address.getReceiver());
                orderVO.setPhone(address.getPhone());
                orderVO.setAddress(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetail());
            }

            List<OrderItem> orderItems = orderItemMapper.selectByOrderId(order.getId());
            List<OrderVO.OrderItemVO> itemVOList = new ArrayList<>();
            for (OrderItem orderItem : orderItems) {
                OrderVO.OrderItemVO itemVO = new OrderVO.OrderItemVO();
                BeanUtils.copyProperties(orderItem, itemVO);
                itemVOList.add(itemVO);
            }
            orderVO.setOrderItems(itemVOList);

            voList.add(orderVO);
        }
        voPage.setRecords(voList);

        return voPage;
    }

    /**
     * 取消订单
     * 恢复库存
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelOrder(Long userId, Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此订单");
        }
        if (order.getStatus() != 0) {
            throw new RuntimeException("只有待支付的订单可以取消");
        }

        List<OrderItem> orderItems = orderItemMapper.selectByOrderId(orderId);
        for (OrderItem orderItem : orderItems) {
            Product product = productMapper.selectById(orderItem.getProductId());
            if (product != null) {
                product.setStock(product.getStock() + orderItem.getQuantity());
                product.setSales(product.getSales() - orderItem.getQuantity());
                productMapper.updateById(product);
            }
        }

        order.setStatus(4);
        orderMapper.updateById(order);
    }

    /**
     * 确认收货
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    @Override
    public void confirmReceive(Long userId, Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此订单");
        }
        if (order.getStatus() != 2) {
            throw new RuntimeException("只有待收货的订单可以确认收货");
        }

        order.setStatus(3);
        order.setReceiveTime(LocalDateTime.now());
        orderMapper.updateById(order);
        
        // 订单完成后增加积分，按照订单金额的1%计算积分
        int points = order.getPayAmount().multiply(new BigDecimal(100)).intValue() / 100;
        if (points > 0) {
            userPointService.addPoints(userId, points, 1, orderId, "购物获得积分");
        }
    }

    /**
     * 删除订单
     * 
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    @Override
    public void deleteOrder(Long userId, Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        if (!order.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此订单");
        }
        if (order.getStatus() != 3 && order.getStatus() != 4) {
            throw new RuntimeException("只有已完成或已取消的订单可以删除");
        }

        LambdaQueryWrapper<OrderItem> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(OrderItem::getOrderId, orderId);
        orderItemMapper.delete(queryWrapper);

        orderMapper.deleteById(orderId);
    }

    /**
     * 生成订单号
     * 格式：时间戳+随机数
     * 
     * @return 订单号
     */
    private String generateOrderNo() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        Random random = new Random();
        int randomNum = random.nextInt(900000) + 100000;
        return timestamp + randomNum;
    }

    /**
     * 获取订单状态描述
     * 
     * @param status 订单状态
     * @return 状态描述
     */
    private String getStatusDesc(Integer status) {
        if (status == null) {
            return "未知";
        }
        switch (status) {
            case 0:
                return "待支付";
            case 1:
                return "待发货";
            case 2:
                return "待收货";
            case 3:
                return "已完成";
            case 4:
                return "已取消";
            case 5:
                return "已退款";
            default:
                return "未知";
        }
    }

    /**
     * 更新订单状态
     * 
     * @param orderId 订单ID
     * @param status 订单状态
     */
    @Override
    public void updateOrderStatus(Long orderId, Integer status) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        
        order.setStatus(status);
        orderMapper.updateById(order);
    }

    /**
     * 根据ID查询订单实体
     * 
     * @param orderId 订单ID
     * @return 订单实体
     */
    @Override
    public Order getOrderEntityById(Long orderId) {
        return orderMapper.selectById(orderId);
    }

    @Override
    public Page<OrderVO> getOrderListAdmin(Integer page, Integer size, Integer status, String keyword) {
        Page<Order> orderPage = new Page<>(page, size);
        LambdaQueryWrapper<Order> queryWrapper = new LambdaQueryWrapper<>();
        
        if (status != null) {
            queryWrapper.eq(Order::getStatus, status);
        }
        if (keyword != null) {
            queryWrapper.like(Order::getOrderNo, keyword);
        }
        queryWrapper.orderByDesc(Order::getCreatedAt);
        orderMapper.selectPage(orderPage, queryWrapper);

        Page<OrderVO> voPage = new Page<>(page, size);
        voPage.setTotal(orderPage.getTotal());
        voPage.setPages(orderPage.getPages());

        List<OrderVO> voList = new ArrayList<>();
        for (Order order : orderPage.getRecords()) {
            OrderVO orderVO = new OrderVO();
            BeanUtils.copyProperties(order, orderVO);
            orderVO.setStatusDesc(getStatusDesc(order.getStatus()));

            Address address = addressMapper.selectById(order.getAddressId());
            if (address != null) {
                orderVO.setReceiver(address.getReceiver());
                orderVO.setPhone(address.getPhone());
                orderVO.setAddress(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetail());
            }

            List<OrderItem> orderItems = orderItemMapper.selectByOrderId(order.getId());
            List<OrderVO.OrderItemVO> itemVOList = new ArrayList<>();
            for (OrderItem orderItem : orderItems) {
                OrderVO.OrderItemVO itemVO = new OrderVO.OrderItemVO();
                BeanUtils.copyProperties(orderItem, itemVO);
                itemVOList.add(itemVO);
            }
            orderVO.setOrderItems(itemVOList);

            voList.add(orderVO);
        }
        voPage.setRecords(voList);

        return voPage;
    }

    @Override
    public OrderVO getOrderByIdAdmin(Long orderId) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        OrderVO orderVO = new OrderVO();
        BeanUtils.copyProperties(order, orderVO);
        orderVO.setStatusDesc(getStatusDesc(order.getStatus()));

        Address address = addressMapper.selectById(order.getAddressId());
        if (address != null) {
            orderVO.setReceiver(address.getReceiver());
            orderVO.setPhone(address.getPhone());
            orderVO.setAddress(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetail());
        }

        List<OrderItem> orderItems = orderItemMapper.selectByOrderId(orderId);
        List<OrderVO.OrderItemVO> itemVOList = new ArrayList<>();
        for (OrderItem orderItem : orderItems) {
            OrderVO.OrderItemVO itemVO = new OrderVO.OrderItemVO();
            BeanUtils.copyProperties(orderItem, itemVO);
            itemVOList.add(itemVO);
        }
        orderVO.setOrderItems(itemVOList);

        return orderVO;
    }

    @Override
    public void updateOrderStatusAdmin(Long orderId, Integer status) {
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }
        
        order.setStatus(status);
        if (status == 1) {
            order.setPaymentTime(LocalDateTime.now());
        } else if (status == 2) {
            order.setDeliveryTime(LocalDateTime.now());
        } else if (status == 3) {
            order.setReceiveTime(LocalDateTime.now());
        }
        orderMapper.updateById(order);
    }

    @Override
    public java.util.Map<String, Object> getSalesStats() {
        java.util.Map<String, Object> stats = new java.util.HashMap<>();
        
        // 总订单数
        long totalOrders = orderMapper.selectCount(null);
        stats.put("totalOrders", totalOrders);
        
        // 已完成订单数
        LambdaQueryWrapper<Order> completedQuery = new LambdaQueryWrapper<>();
        completedQuery.eq(Order::getStatus, 3);
        long completedCount = orderMapper.selectCount(completedQuery);
        stats.put("completedCount", completedCount);
        
        // 总销售额
        List<Order> orders = orderMapper.selectList(completedQuery);
        BigDecimal totalSales = BigDecimal.ZERO;
        for (Order order : orders) {
            totalSales = totalSales.add(order.getPayAmount());
        }
        stats.put("totalSales", totalSales);
        
        // 今日订单数
        LocalDateTime today = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        LambdaQueryWrapper<Order> todayQuery = new LambdaQueryWrapper<>();
        todayQuery.ge(Order::getCreatedAt, today);
        long todayOrders = orderMapper.selectCount(todayQuery);
        stats.put("todayOrders", todayOrders);
        
        // 今日销售额
        LambdaQueryWrapper<Order> todayCompletedQuery = new LambdaQueryWrapper<>();
        todayCompletedQuery.ge(Order::getCreatedAt, today)
                .eq(Order::getStatus, 3);
        List<Order> todayCompletedOrders = orderMapper.selectList(todayCompletedQuery);
        BigDecimal todaySales = BigDecimal.ZERO;
        for (Order order : todayCompletedOrders) {
            todaySales = todaySales.add(order.getPayAmount());
        }
        stats.put("todaySales", todaySales);
        
        return stats;
    }

}
