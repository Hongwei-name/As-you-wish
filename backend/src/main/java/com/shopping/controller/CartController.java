package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.dto.CartAddDTO;
import com.shopping.dto.CartUpdateDTO;
import com.shopping.service.CartService;
import com.shopping.vo.CartVO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 购物车控制器
 * 提供购物车相关的REST API接口
 * 
 * @author 陈洪伟
 */
@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private CartService cartService;

    /**
     * 添加商品到购物车
     * 
     * @param request HTTP请求对象
     * @param addDTO 添加购物车DTO
     * @return 购物车信息
     */
    @PostMapping("/add")
    public Result<CartVO> addToCart(HttpServletRequest request, @Valid @RequestBody CartAddDTO addDTO) {
        Long userId = (Long) request.getAttribute("userId");
        CartVO cartVO = cartService.addToCart(userId, addDTO);
        return Result.success(cartVO);
    }

    /**
     * 获取购物车列表
     * 
     * @param request HTTP请求对象
     * @return 购物车列表
     */
    @GetMapping("/list")
    public Result<Map<String, Object>> getCartList(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        List<CartVO> cartList = cartService.getCartList(userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", cartList);
        result.put("totalCount", cartList.size());
        
        return Result.success(result);
    }

    /**
     * 更新购物车商品数量
     * 
     * @param request HTTP请求对象
     * @param updateDTO 更新购物车DTO
     * @return 购物车信息
     */
    @PutMapping("/quantity")
    public Result<CartVO> updateQuantity(HttpServletRequest request, @Valid @RequestBody CartUpdateDTO updateDTO) {
        Long userId = (Long) request.getAttribute("userId");
        CartVO cartVO = cartService.updateQuantity(userId, updateDTO);
        return Result.success(cartVO);
    }

    /**
     * 删除购物车商品
     * 
     * @param request HTTP请求对象
     * @param id 购物车ID
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public Result<Void> deleteCartItem(HttpServletRequest request, @PathVariable Long id) {
        Long userId = (Long) request.getAttribute("userId");
        cartService.deleteCartItem(userId, id);
        return Result.success();
    }

    /**
     * 清空购物车
     * 
     * @param request HTTP请求对象
     * @return 操作结果
     */
    @DeleteMapping("/clear")
    public Result<Void> clearCart(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        cartService.clearCart(userId);
        return Result.success();
    }

    /**
     * 选择/取消选择商品
     * 
     * @param request HTTP请求对象
     * @param id 购物车ID
     * @param selected 是否选中：0-否 1-是
     * @return 购物车信息
     */
    @PutMapping("/select/{id}")
    public Result<CartVO> selectCartItem(HttpServletRequest request, @PathVariable Long id, @RequestParam Integer selected) {
        Long userId = (Long) request.getAttribute("userId");
        CartVO cartVO = cartService.selectCartItem(userId, id, selected);
        return Result.success(cartVO);
    }

    /**
     * 全选/取消全选
     * 
     * @param request HTTP请求对象
     * @param selected 是否选中：0-否 1-是
     * @return 操作结果
     */
    @PutMapping("/selectAll")
    public Result<Void> selectAll(HttpServletRequest request, @RequestParam Integer selected) {
        Long userId = (Long) request.getAttribute("userId");
        cartService.selectAll(userId, selected);
        return Result.success();
    }

    /**
     * 获取购物车商品数量
     * 
     * @param request HTTP请求对象
     * @return 商品数量
     */
    @GetMapping("/count")
    public Result<Integer> getCartCount(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Integer count = cartService.getCartCount(userId);
        return Result.success(count);
    }

}
