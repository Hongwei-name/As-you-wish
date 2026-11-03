package com.asyouwish.auth.config;

import com.asyouwish.auth.util.BusinessException;
import com.asyouwish.auth.util.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
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
        // 获取第一个字段的校验错误信息
        FieldError fieldError = e.getBindingResult().getFieldError();
        String message = fieldError != null ? fieldError.getDefaultMessage() : "参数校验失败";
        log.warn("参数校验异常: {}", message);
        return Result.failed(400, message);
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