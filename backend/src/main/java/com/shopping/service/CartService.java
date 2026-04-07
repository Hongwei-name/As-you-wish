package com.shopping.service;

import com.shopping.dto.CartAddDTO;
import com.shopping.dto.CartUpdateDTO;
import com.shopping.vo.CartVO;

import java.util.List;

/**
 * 购物车服务接口
 * 提供购物车相关的业务逻辑
 * 
 * @author 陈洪伟
 */
public interface CartService {

    /**
     * 添加商品到购物车
     * 如果商品已存在则增加数量
     * 
     * @param userId 用户ID
     * @param addDTO 添加购物车DTO
     * @return 购物车信息
     */
    CartVO addToCart(Long userId, CartAddDTO addDTO);

    /**
     * 获取用户购物车列表
     * 
     * @param userId 用户ID
     * @return 购物车列表
     */
    List<CartVO> getCartList(Long userId);

    /**
     * 更新购物车商品数量
     * 
     * @param userId 用户ID
     * @param updateDTO 更新购物车DTO
     * @return 购物车信息
     */
    CartVO updateQuantity(Long userId, CartUpdateDTO updateDTO);

    /**
     * 删除购物车商品
     * 
     * @param userId 用户ID
     * @param id 购物车ID
     */
    void deleteCartItem(Long userId, Long id);

    /**
     * 清空购物车
     * 
     * @param userId 用户ID
     */
    void clearCart(Long userId);

    /**
     * 选择/取消选择商品
     * 
     * @param userId 用户ID
     * @param id 购物车ID
     * @param selected 是否选中：0-否 1-是
     * @return 购物车信息
     */
    CartVO selectCartItem(Long userId, Long id, Integer selected);

    /**
     * 全选/取消全选
     * 
     * @param userId 用户ID
     * @param selected 是否选中：0-否 1-是
     */
    void selectAll(Long userId, Integer selected);

    /**
     * 获取购物车商品数量
     * 
     * @param userId 用户ID
     * @return 商品数量
     */
    Integer getCartCount(Long userId);

}
