package com.asyouwish.auth.service;

import com.aliyun.tea.TeaException;
import org.springframework.util.StringUtils;

/**
 * 将阿里云 PNVS 错误码转换为安全、可展示的业务提示。
 * 原始 code/message 只进入服务端日志，不直接返回给前端。
 */
public final class PnvsErrorMapper {

    private PnvsErrorMapper() {
    }

    public static PnvsException fromProvider(String code, String message) {
        return map(code, message, null);
    }

    public static PnvsException fromProvider(String code, String message, Throwable cause) {
        return map(code, message, cause);
    }

    public static PnvsException fromException(TeaException exception) {
        return map(exception.getCode(), exception.getMessage(), exception);
    }

    private static PnvsException map(String code, String message, Throwable cause) {
        String normalized = code == null ? "" : code;
        String upper = normalized.toUpperCase();

        if (contains(normalized, "AMOUNT_NOT_ENOUGH")) {
            return PnvsException.system("短信认证套餐余量不足，请联系管理员", normalized, cause);
        }
        if (contains(normalized, "OUT_OF_SERVICE")
                || contains(normalized, "PRODUCT_UN_SUBSCRIPT")
                || contains(normalized, "PRODUCT_UNSUBSCRIBE")) {
            return PnvsException.system("短信认证服务未开通或已停用，请联系管理员", normalized, cause);
        }
        if (contains(normalized, "SMS_TEMPLATE_ILLEGAL")
                || contains(normalized, "SMS_SIGNATURE_ILLEGAL")
                || contains(normalized, "SMS_CONTENT_ILLEGAL")
                || contains(normalized, "SMS_SERVICE_NOT_SUPPORT")
                || contains(normalized, "PARAM_LENGTH_LIMIT")) {
            return PnvsException.system("短信服务配置异常，请联系管理员", normalized, cause);
        }
        if (contains(normalized, "RAM_PERMISSION_DENY")
                || contains(normalized, "InvalidAccessKeyId")
                || contains(normalized, "SignatureDoesNotMatch")
                || contains(normalized, "Forbidden")
                || contains(normalized, "NoPermission")) {
            return PnvsException.system("短信服务鉴权失败，请联系管理员", normalized, cause);
        }
        if (contains(normalized, "BUSINESS_LIMIT_CONTROL")) {
            return PnvsException.business("发送过于频繁，请稍后再试", normalized);
        }
        if (contains(normalized, "DAY_LIMIT_CONTROL")) {
            return PnvsException.business("今日发送次数已达上限，请明日再试", normalized);
        }
        if (contains(normalized, "BLACK_KEY_CONTROL_LIMIT")) {
            return PnvsException.business("当前号码或网络触发风控，请稍后再试", normalized);
        }
        if (contains(normalized, "MOBILE_NUMBER_ILLEGAL")) {
            return PnvsException.business("手机号格式不正确", normalized);
        }
        if (contains(normalized, "SMS_CODE_EXPIRED")
                || contains(normalized, "SMS_CODE_ERROR")
                || contains(normalized, "SMS_CODE_USED")
                || contains(normalized, "SMS_CODE_NOT_EXIST")) {
            return PnvsException.business("验证码错误或已失效", normalized);
        }
        if (contains(normalized, "INVALID_PARAMETERS")) {
            return PnvsException.business("请求参数不合法", normalized);
        }
        if (contains(normalized, "Throttling")
                || contains(normalized, "ServiceUnavailable")
                || contains(normalized, "InternalError")
                || contains(normalized, "RequestTimeout")
                || contains(normalized, "UnknownError")
                || contains(normalized, "UnknownServerError")) {
            return PnvsException.system("短信服务暂时不可用，请稍后重试", normalized, cause);
        }
        if (upper.startsWith("ISV.")) {
            return PnvsException.business("短信发送失败，请稍后重试", normalized);
        }
        return PnvsException.system("短信服务暂时不可用，请稍后重试", normalized, cause);
    }

    private static boolean contains(String value, String keyword) {
        return StringUtils.hasText(value) && value.toLowerCase().contains(keyword.toLowerCase());
    }
}
