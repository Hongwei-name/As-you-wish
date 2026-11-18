package com.zerok.aiservice.util;

import lombok.Getter;

/**
 * 业务可预期异常，由 GlobalExceptionHandler 转换为统一响应。
 */
@Getter
public class BusinessException extends RuntimeException {

    private final Integer code;

    public BusinessException(String message) {
        this(ResultCode.FAILED.getCode(), message);
    }

    public BusinessException(Integer code, String message) {
        super(message);
        this.code = code;
    }
}