package com.lab.items.exception;

import com.lab.items.dto.R;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.BindException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 处理业务异常
     */
    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public R<Void> handleIllegalArgumentException(IllegalArgumentException e) {
        log.error("业务异常：{}", e.getMessage());
        return R.error(400, e.getMessage());
    }

    /**
     * 处理认证异常
     */
    @ExceptionHandler(BadCredentialsException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public R<Void> handleBadCredentialsException(BadCredentialsException e) {
        log.error("认证失败：{}", e.getMessage());
        return R.error(401, "用户名或密码错误");
    }

    /**
     * 处理权限不足异常
     */
    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public R<Void> handleAccessDeniedException(AccessDeniedException e) {
        log.error("权限不足：{}", e.getMessage());
        return R.error(403, "权限不足");
    }

    /**
     * 处理参数验证异常
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public R<Void> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {
        StringBuilder message = new StringBuilder();
        e.getBindingResult().getFieldErrors().forEach(error -> 
            message.append(error.getField()).append(": ").append(error.getDefaultMessage()).append("; ")
        );
        log.error("参数验证失败：{}", message);
        return R.error(400, message.toString());
    }

    /**
     * 处理绑定异常
     */
    @ExceptionHandler(BindException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public R<Void> handleBindException(BindException e) {
        StringBuilder message = new StringBuilder();
        e.getBindingResult().getFieldErrors().forEach(error -> 
            message.append(error.getField()).append(": ").append(error.getDefaultMessage()).append("; ")
        );
        log.error("参数绑定失败：{}", message);
        return R.error(400, message.toString());
    }

    /**
     * 处理请求方法不支持异常
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    @ResponseStatus(HttpStatus.METHOD_NOT_ALLOWED)
    public R<Void> handleHttpRequestMethodNotSupportedException(
            HttpRequestMethodNotSupportedException e) {
        log.error("请求方法不支持：{}", e.getMessage());
        return R.error(405, "请求方法不支持");
    }

    /**
     * 处理其他未捕获的异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public R<Void> handleException(Exception e) {
        log.error("系统内部异常：", e);
        return R.error(500, "系统内部错误：" + e.getMessage());
    }
}
