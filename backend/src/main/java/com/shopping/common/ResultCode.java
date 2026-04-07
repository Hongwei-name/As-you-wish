package com.shopping.common;

import lombok.Getter;

/**
 * 响应状态码枚举类
 * 定义所有接口响应状态码
 * 
 * @author 陈洪伟
 */
@Getter
public enum ResultCode {

    /**
     * 操作成功
     */
    SUCCESS(200, "操作成功"),

    /**
     * 操作失败
     */
    ERROR(500, "操作失败"),

    /**
     * 参数错误
     */
    PARAM_ERROR(400, "参数错误"),

    /**
     * 未授权
     */
    UNAUTHORIZED(401, "未授权，请先登录"),

    /**
     * 禁止访问
     */
    FORBIDDEN(403, "禁止访问"),

    /**
     * 资源不存在
     */
    NOT_FOUND(404, "资源不存在"),

    /**
     * 用户名或密码错误
     */
    LOGIN_ERROR(4001, "用户名或密码错误"),

    /**
     * Token无效
     */
    TOKEN_INVALID(4002, "Token无效或已过期"),

    /**
     * 用户已存在
     */
    USER_EXISTS(4003, "用户已存在"),

    /**
     * 用户不存在
     */
    USER_NOT_EXISTS(4004, "用户不存在"),

    /**
     * 商品不存在
     */
    PRODUCT_NOT_EXISTS(5001, "商品不存在"),

    /**
     * 库存不足
     */
    STOCK_NOT_ENOUGH(5002, "库存不足"),

    /**
     * 订单不存在
     */
    ORDER_NOT_EXISTS(6001, "订单不存在"),

    /**
     * 订单状态错误
     */
    ORDER_STATUS_ERROR(6002, "订单状态错误");

    /**
     * 状态码
     */
    private final Integer code;

    /**
     * 状态消息
     */
    private final String message;

    /**
     * 构造函数
     * 
     * @param code 状态码
     * @param message 状态消息
     */
    ResultCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

}
