package com.shopping.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serializable;

/**
 * 更新购物车数据传输对象
 * 用于接收更新购物车商品数量的请求参数
 * 
 * @author 陈洪伟
 */
@Data
public class CartUpdateDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 购物车ID
     */
    @NotNull(message = "购物车ID不能为空")
    private Long id;

    /**
     * 商品数量
     */
    @NotNull(message = "商品数量不能为空")
    @Min(value = 1, message = "商品数量至少为1")
    private Integer quantity;

}
