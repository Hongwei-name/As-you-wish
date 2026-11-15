package com.asyouwish.auth.util;

import lombok.Getter;

/**
 * 统一返回状态码枚举
 */
@Getter // 加上这个注解，下面就不用写 get 方法了
public enum ResultCode {

    SUCCESS(200, "操作成功"),
    FAILED(500, "操作失败"),
    VALIDATE_FAILED(400, "参数检验失败"),
    UNAUTHORIZED(401, "暂未登录或token已经过期"),
    FORBIDDEN(403, "没有相关权限"),

    // 业务自定义错误码
    SMS_CODE_EXPIRED(1001, "验证码已过期"),
    SMS_CODE_ERROR(1002, "验证码错误"),
    PHONE_ALREADY_EXISTS(1003, "手机号已注册"),
    PHONE_NOT_EXISTS(1004, "手机号未注册"),
    PASSWORD_ERROR(1005, "账号或密码错误"),
    SMS_LIMIT(1006, "发送过于频繁，请稍后再试"),
    OLD_PASSWORD_ERROR(1007, "原密码不正确");

    private final Integer code;
    private final String message;

    ResultCode(Integer code, String message) {
        this.code = code;
        this.message = message;
    }
}