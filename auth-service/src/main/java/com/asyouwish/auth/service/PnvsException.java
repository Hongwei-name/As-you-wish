package com.asyouwish.auth.service;

import lombok.Getter;

/**
 * PNVS 调用异常。business=true 表示用户可处理的业务错误；false 表示供应商/系统错误。
 */
@Getter
public class PnvsException extends RuntimeException {

    private final boolean business;
    private final String providerCode;

    public PnvsException(boolean business, String message, String providerCode, Throwable cause) {
        super(message, cause);
        this.business = business;
        this.providerCode = providerCode;
    }

    public static PnvsException business(String message, String providerCode) {
        return new PnvsException(true, message, providerCode, null);
    }

    public static PnvsException system(String message, String providerCode, Throwable cause) {
        return new PnvsException(false, message, providerCode, cause);
    }
}
