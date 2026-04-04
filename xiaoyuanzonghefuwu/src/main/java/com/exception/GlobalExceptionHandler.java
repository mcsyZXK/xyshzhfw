package com.exception;

import com.common.R;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * 全局异常处理器
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger logger = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 处理所有未捕获的异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.OK)
    public R handleException(Exception e) {
        logger.error("系统异常：", e);
        return R.error("系统异常，请联系管理员");
    }

    /**
     * 处理业务异常
     */
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.OK)
    public R handleRuntimeException(RuntimeException e) {
        logger.error("业务异常：", e);
        return R.error(e.getMessage());
    }

    /**
     * 处理数据库主键冲突异常
     */
    @ExceptionHandler(DuplicateKeyException.class)
    @ResponseStatus(HttpStatus.OK)
    public R handleDuplicateKeyException(DuplicateKeyException e) {
        logger.error("数据库主键冲突：", e);
        return R.error("数据已存在，请勿重复添加");
    }

    /**
     * 处理参数校验异常
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public R handleValidationException(MethodArgumentNotValidException e) {
        String errorMsg = e.getBindingResult().getFieldErrors().stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .findFirst()
                .orElse("参数校验失败");
        logger.warn("参数校验失败：{}", errorMsg);
        return R.error(400, errorMsg);
    }

    /**
     * 处理自定义异常
     */
    @ExceptionHandler(com.entity.EIException.class)
    @ResponseStatus(HttpStatus.OK)
    public R handleEIException(com.entity.EIException e) {
        logger.warn("自定义异常：{}", e.getMessage());
        return R.error(e.getCode(), e.getMsg());
    }
}