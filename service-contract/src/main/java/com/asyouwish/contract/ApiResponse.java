package com.asyouwish.contract;

/**
 * 稳定的服务间 HTTP 响应结构；HTTP 状态码仍表达传输和业务结果类别。
 */
public record ApiResponse<T>(int code, String message, T data) {

    /**
     * 创建成功响应。
     */
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(200, "OK", data);
    }

    /**
     * 创建错误响应，错误码与 HTTP 状态码保持一致。
     */
    public static ApiResponse<Void> failure(int code, String message) {
        return new ApiResponse<>(code, message, null);
    }
}
