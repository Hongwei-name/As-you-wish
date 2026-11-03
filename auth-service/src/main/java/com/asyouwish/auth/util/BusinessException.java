package com.asyouwish.auth.util;

import lombok.Getter;

/**
 * 业务异常类
 */
@Getter // 使用 lombok 生成 getter
public class BusinessException extends RuntimeException {

    /**
     * 错误状态码
     */
    private final Integer code;

    /**
     * 直接传错误信息，默认状态码 500
     */
    public BusinessException(String message) {
        super(message);
        this.code = ResultCode.FAILED.getCode();
    }

    /**
     * 传入错误枚举
     */
    public BusinessException(ResultCode resultCode) {
        super(resultCode.getMessage());
        this.code = resultCode.getCode();
    }

    /**
     * 自定义状态码和错误信息
     */
    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }
}