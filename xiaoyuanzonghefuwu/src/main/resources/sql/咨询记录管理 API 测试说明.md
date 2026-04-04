# 咨询记录管理 API 测试说明

## 概述

本文档用于测试咨询师端的咨询记录管理功能，包括查询、修改、删除等接口。

## 测试环境

- 后端地址：http://localhost:8083/xiaoyuanzonghefuwu
- 数据库：xiaoyuanzonghefuwu

## 测试账号

### 咨询师账号

| 用户名 | 密码 | 咨询师姓名 | ID |
|--------|------|-----------|-----|
| zixun0 | zixun123 | 张老师 | 1 |
| zixun1 | zixun123 | 王老师 | 2 |
| zixun2 | zixun123 | 李老师 | 3 |

## 测试数据

运行 `chat_test_data.sql` 文件插入测试数据：

```bash
mysql -u root -p123456 xiaoyuanzonghefuwu < chat_test_data.sql
```

## API 接口测试

### 1. 登录接口

**请求：**
```http
POST /xinlizixunshi/login?username=zixun0&password=zixun123
```

**响应示例：**
```json
{
  "code": 0,
  "role": "心理咨询师",
  "userId": 1,
  "token": "644xgj5sm6sobwoilzil5e8wyw5noj4r",
  "username": "张老师",
  "tableName": "xinlizixunshi"
}
```

### 2. 咨询记录列表接口

**请求：**
```http
GET /chat/page?page=1&limit=10&orderBy=insert_time&order=desc
Token: 644xgj5sm6sobwoilzil5e8wyw5noj4r
```

**响应示例：**
```json
{
  "code": 0,
  "data": {
    "total": 12,
    "pageSize": 10,
    "totalPage": 2,
    "currPage": 1,
    "list": [
      {
        "id": 5,
        "yonghuId": 1,
        "xinlizixunshiId": 1,
        "chatIssue": "学习压力",
        "chatReply": "",
        "zhuangtaiTypes": 0,
        "chatTypes": 1,
        "insertTime": "2026-03-06 01:16:00"
      }
    ]
  }
}
```

### 3. 咨询记录详情接口

**请求：**
```http
GET /chat/info/5
Token: 644xgj5sm6sobwoilzil5e8wyw5noj4r
```

**响应示例：**
```json
{
  "code": 0,
  "data": {
    "id": 5,
    "yonghuId": 1,
    "xinlizixunshiId": 1,
    "chatContent": "老师您好，我最近学习压力很大...",
    "chatIssue": "学习压力",
    "chatReply": "",
    "zhuangtaiTypes": 0,
    "chatTypes": 1,
    "insertTime": "2026-03-06 01:16:00"
  }
}
```

### 4. 修改咨询记录接口

**请求：**
```http
PUT /chat/update
Content-Type: application/json
Token: 644xgj5sm6sobwoilzil5e8wyw5noj4r

{
  "id": 5,
  "chatReply": "建议你制定一个合理的复习计划",
  "zhuangtaiTypes": 1
}
```

**响应示例：**
```json
{
  "code": 0,
  "msg": "修改成功"
}
```

### 5. 删除咨询记录接口

**请求：**
```http
DELETE /chat
Content-Type: application/json
Token: 644xgj5sm6sobwoilzil5e8wyw5noj4r

[5, 6, 7]
```

**响应示例：**
```json
{
  "code": 0,
  "msg": "删除成功"
}
```

## 前端页面测试

### 咨询师端咨询记录管理页面

访问地址：http://localhost:5173/counselor/chat

测试步骤：
1. 使用咨询师账号登录（zixun0/zixun123）
2. 进入咨询记录管理页面
3. 查看咨询记录列表
4. 查看咨询记录详情
5. 修改咨询记录
6. 删除咨询记录

## 数据字典

### 状态类型 (zhuangtai_types)
- 0: 待回复
- 1: 已回复

### 数据类型 (chat_types)
- 1: 用户提问
- 2: 咨询师回复

## 常见问题

### 1. 接口返回 511 错误
表示未登录，请先登录获取 token。

### 2. 查询不到数据
检查当前登录的咨询师账号是否有对应的咨询记录。

### 3. 字段名不一致
前端使用 `chatContent`（驼峰），数据库使用 `chat_content`（下划线），MyBatis-Plus 会自动转换。