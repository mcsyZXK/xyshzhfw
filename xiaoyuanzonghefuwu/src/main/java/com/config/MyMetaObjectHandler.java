package com.config;

import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.util.Date;

/**
 * MyBatis-Plus 自动填充处理器
 */
@Component
public class MyMetaObjectHandler {

    /**
     * 插入时自动填充
     */
    public void insertFill(MetaObject metaObject) {
        try {
            // 插入时自动填充 createTime 和 updateTime
            this.strictInsertFill(metaObject, "createTime", Date.class, new Date());
            this.strictInsertFill(metaObject, "updateTime", Date.class, new Date());
        } catch (Exception e) {
            // 如果字段不存在，忽略异常
        }
    }

    /**
     * 更新时自动填充
     */
    public void updateFill(MetaObject metaObject) {
        try {
            // 更新时自动填充 updateTime
            this.strictUpdateFill(metaObject, "updateTime", Date.class, new Date());
        } catch (Exception e) {
            // 如果字段不存在，忽略异常
        }
    }

    /**
     * 严格填充 - 插入
     */
    private void strictInsertFill(MetaObject metaObject, String fieldName, Class<?> fieldType, Object fieldVal) {
        if (metaObject.hasSetter(fieldName)) {
            Object value = metaObject.getValue(fieldName);
            if (value == null) {
                metaObject.setValue(fieldName, fieldVal);
            }
        }
    }

    /**
     * 严格填充 - 更新
     */
    private void strictUpdateFill(MetaObject metaObject, String fieldName, Class<?> fieldType, Object fieldVal) {
        if (metaObject.hasSetter(fieldName)) {
            metaObject.setValue(fieldName, fieldVal);
        }
    }
}