package com.asyouwish.auth.config;

import com.asyouwish.auth.service.PnvsException;
import com.asyouwish.auth.util.BusinessException;
import com.asyouwish.auth.util.Result;
import jakarta.validation.ConstraintViolationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 * 使用 @RestControllerAdvice 拦截所有 Controller 抛出的异常
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 拦截我们自定义的业务异常
     */
    @ExceptionHandler(BusinessException.class)
    public Result<?> handleBusinessException(BusinessException e) {
        log.warn("业务异常: {}", e.getMessage());
        return Result.failed(e.getCode(), e.getMessage());
    }

    /**
     * 拦截参数校验异常 (比如 @NotBlank 失败时会触发)
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result<?> handleValidException(MethodArgumentNotValidException e) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "参数校验失败";
        log.warn("参数校验异常: {}", message);
        return Result.failed(400, message);
    }

    @ExceptionHandler(BindException.class)
    public Result<?> handleBindException(BindException e) {
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "参数绑定失败";
        log.warn("参数绑定异常: {}", message);
        return Result.failed(400, message);
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public Result<?> handleConstraintViolation(ConstraintViolationException e) {
        log.warn("参数约束异常: {}", e.getMessage());
        return Result.failed(400, "参数校验失败");
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public Result<?> handleUnreadableBody(HttpMessageNotReadableException e) {
        log.warn("请求体解析失败: {}", e.getMessage());
        return Result.failed(400, "请求参数格式不正确");
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    public Result<?> handleMissingParameter(MissingServletRequestParameterException e) {
        log.warn("缺少请求参数: {}", e.getParameterName());
        return Result.failed(400, "缺少必要参数");
    }

    @ExceptionHandler(PnvsException.class)
    public Result<?> handlePnvsException(PnvsException e) {
        if (e.isBusiness()) {
            log.warn("PNVS 业务错误: code={}, message={}", e.getProviderCode(), e.getMessage());
            return Result.failed(400, e.getMessage());
        }
        log.error("PNVS 系统错误: code={}", e.getProviderCode(), e);
        return Result.failed(500, e.getMessage());
    }

    /**
     * 拦截所有未捕获的异常 (作为兜底)
     */
    @ExceptionHandler(Exception.class)
    public Result<?> handleException(Exception e) {
        // 系统的未知异常，需要打印完整堆栈信息方便排查
        log.error("系统异常: ", e);
        return Result.failed("系统繁忙，请稍后重试");
    }
}