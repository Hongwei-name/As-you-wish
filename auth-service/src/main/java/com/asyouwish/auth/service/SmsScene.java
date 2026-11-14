package com.asyouwish.auth.service;

import com.asyouwish.auth.util.BusinessException;
import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * 短信验证码业务场景。场景同时用于独立限流、模板选择和 PNVS 方案名隔离。
 */
@Getter
@RequiredArgsConstructor
public enum SmsScene {

    REGISTER("register"),
    LOGIN("login"),
    RESET_PASSWORD("reset-password");

    private final String code;

    public static SmsScene fromCode(String code) {
        for (SmsScene scene : values()) {
            if (scene.code.equals(code)) {
                return scene;
            }
        }
        throw new BusinessException("短信场景不合法");
    }
}
