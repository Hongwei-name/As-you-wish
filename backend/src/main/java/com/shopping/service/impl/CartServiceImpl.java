package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.shopping.common.ResultCode;
import com.shopping.dto.CartAddDTO;
import com.shopping.dto.CartUpdateDTO;
import com.shopping.entity.Cart;
import com.shopping.entity.Product;
import com.shopping.mapper.CartMapper;
import com.shopping.mapper.ProductMapper;
import com.shopping.service.CartService;
import com.shopping.vo.CartVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

/**
 * 购物车服务实现类
 * 实现购物车相关的业务逻辑
 * 
 * @author 陈洪伟
 */
@Slf4j
@Service
public class CartServiceImpl implements CartService {

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private ProductMapper productMapper;

    /**
     * 添加商品到购物车
     * 如果商品已存在则增加数量
     * 
     * @param userId 用户ID
     * @param addDTO 添加购物车DTO
     * @return 购物车信息
     */
    @Override
    public CartVO addToCart(Long userId, CartAddDTO addDTO) {
        Product product = productMapper.selectById(addDTO.getProductId());
        if (product == null) {
            throw new RuntimeException(ResultCode.PRODUCT_NOT_EXISTS.getMessage());
        }
        if (product.getStatus() != 1) {
            throw new RuntimeException("商品已下架");
        }
        Cart existCart = cartMapper.selectByUserIdAndProductId(userId, addDTO.getProductId());
        if (existCart != null) {
            int newQuantity = existCart.getQuantity() + addDTO.getQuantity();
            if (newQuantity > product.getStock()) {
                throw new RuntimeException(ResultCode.STOCK_NOT_ENOUGH.getMessage());
            }
            existCart.setQuantity(newQuantity);
            cartMapper.updateById(existCart);
        } else {
            if (addDTO.getQuantity() > product.getStock()) {
                throw new RuntimeException(ResultCode.STOCK_NOT_ENOUGH.getMessage());
            }
            Cart cart = new Cart();
            cart.setUserId(userId);
            cart.setProductId(addDTO.getProductId());
            cart.setQuantity(addDTO.getQuantity());
            cart.setSelected(1);
            cartMapper.insert(cart);
        }
        List<CartVO> cartList = cartMapper.selectCartListByUserId(userId);
        return cartList.stream()
                .filter(c -> c.getProductId().equals(addDTO.getProductId()))
                .findFirst()
                .orElse(null);
    }

    /**
     * 获取用户购物车列表
     * 
     * @param userId 用户ID
     * @return 购物车列表
     */
    @Override
    public List<CartVO> getCartList(Long userId) {
        List<CartVO> cartList = cartMapper.selectCartListByUserId(userId);
        for (CartVO cartVO : cartList) {
            if (cartVO.getProductPrice() != null && cartVO.getQuantity() != null) {
                BigDecimal subtotal = cartVO.getProductPrice().multiply(new BigDecimal(cartVO.getQuantity()));
                cartVO.setSubtotal(subtotal);
            }
        }
        return cartList;
    }

    /**
     * 更新购物车商品数量
     * 
     * @param userId 用户ID
     * @param updateDTO 更新购物车DTO
     * @return 购物车信息
     */
    @Override
    public CartVO updateQuantity(Long userId, CartUpdateDTO updateDTO) {
        Cart cart = cartMapper.selectById(updateDTO.getId());
        if (cart == null) {
            throw new RuntimeException("购物车记录不存在");
        }
        if (!cart.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此购物车记录");
        }
        Product product = productMapper.selectById(cart.getProductId());
        if (product == null) {
            throw new RuntimeException(ResultCode.PRODUCT_NOT_EXISTS.getMessage());
        }
        if (updateDTO.getQuantity() > product.getStock()) {
            throw new RuntimeException(ResultCode.STOCK_NOT_ENOUGH.getMessage());
        }
        cart.setQuantity(updateDTO.getQuantity());
        cartMapper.updateById(cart);
        List<CartVO> cartList = cartMapper.selectCartListByUserId(userId);
        return cartList.stream()
                .filter(c -> c.getId().equals(updateDTO.getId()))
                .findFirst()
                .orElse(null);
    }

    /**
     * 删除购物车商品
     * 
     * @param userId 用户ID
     * @param id 购物车ID
     */
    @Override
    public void deleteCartItem(Long userId, Long id) {
        Cart cart = cartMapper.selectById(id);
        if (cart == null) {
            throw new RuntimeException("购物车记录不存在");
        }
        if (!cart.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此购物车记录");
        }
        cartMapper.deleteById(id);
    }

    /**
     * 清空购物车
     * 
     * @param userId 用户ID
     */
    @Override
    public void clearCart(Long userId) {
        LambdaQueryWrapper<Cart> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Cart::getUserId, userId);
        cartMapper.delete(queryWrapper);
    }

    /**
     * 选择/取消选择商品
     * 
     * @param userId 用户ID
     * @param id 购物车ID
     * @param selected 是否选中：0-否 1-是
     * @return 购物车信息
     */
    @Override
    public CartVO selectCartItem(Long userId, Long id, Integer selected) {
        Cart cart = cartMapper.selectById(id);
        if (cart == null) {
            throw new RuntimeException("购物车记录不存在");
        }
        if (!cart.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作此购物车记录");
        }
        cart.setSelected(selected);
        cartMapper.updateById(cart);
        List<CartVO> cartList = cartMapper.selectCartListByUserId(userId);
        return cartList.stream()
                .filter(c -> c.getId().equals(id))
                .findFirst()
                .orElse(null);
    }

    /**
     * 全选/取消全选
     * 
     * @param userId 用户ID
     * @param selected 是否选中：0-否 1-是
     */
    @Override
    public void selectAll(Long userId, Integer selected) {
        LambdaUpdateWrapper<Cart> updateWrapper = new LambdaUpdateWrapper<>();
        updateWrapper.eq(Cart::getUserId, userId)
                .set(Cart::getSelected, selected);
        cartMapper.update(null, updateWrapper);
    }

    /**
     * 获取购物车商品数量
     * 
     * @param userId 用户ID
     * @return 商品数量
     */
    @Override
    public Integer getCartCount(Long userId) {
        return cartMapper.countByUserId(userId);
    }

}
