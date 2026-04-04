# 心理咨询师端 API 测试说明

## 测试账号

| 账号 | 密码 | 角色 |
|------|------|------|
| zixun1 | zixun123 | 王老师 |
| zixun2 | zixun123 | 李老师 |
| zixun3 | zixun123 | 张老师 |

## 接口列表

### 1. 登录接口

**接口地址**: `POST /xinlizixunshi/login`

**请求参数**:
```json
{
  "username": "zixun1",
  "password": "zixun123"
}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "登录成功",
  "data": {
    "id": 1,
    "username": "zixun1",
    "xinlizixunshi_name": "王老师",
    "xinlizixunshi_phone": "13900139001",
    "xinlizixunshi_email": "wanglaoshi@example.com",
    "role": "心理咨询师"
  },
  "token": "token_xxx"
}
```

---

### 2. 获取当前咨询师信息

**接口地址**: `GET /xinlizixunshi/info`

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "id": 1,
    "username": "zixun1",
    "xinlizixunshi_name": "王老师",
    "xinlizixunshi_photo": "/upload/counselor1.jpg",
    "xinlizixunshi_phone": "13900139001",
    "xinlizixunshi_email": "wanglaoshi@example.com",
    "xinlizixunshi_zhiye": "国家二级心理咨询师",
    "xinlizixunshi_content": "从事心理咨询工作 10 年...",
    "role": "心理咨询师"
  }
}
```

---

### 3. 更新咨询师信息

**接口地址**: `POST /xinlizixunshi/update`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "id": 1,
  "xinlizixunshi_name": "王老师",
  "xinlizixunshi_phone": "13900139001",
  "xinlizixunshi_email": "wanglaoshi@example.com",
  "xinlizixunshi_zhiye": "国家二级心理咨询师",
  "xinlizixunshi_content": "更新后的个人介绍..."
}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "更新成功"
}
```

---

### 4. 获取咨询列表（聊天）

**接口地址**: `GET /chat/page`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| limit | int | 否 | 每页数量，默认 10 |
| xinlizixunshiId | int | 否 | 咨询师 ID |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": 1,
        "yonghu_id": 1,
        "xinlizixunshi_id": 1,
        "chat_content": "老师您好，我想咨询...",
        "chat_types": 1,
        "insert_time": "2026-03-05 10:00:00"
      }
    ],
    "total": 10
  }
}
```

---

### 5. 发送咨询消息

**接口地址**: `POST /chat/save`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "yonghu_id": 1,
  "xinlizixunshi_id": 1,
  "chat_content": "这是回复内容",
  "chat_types": 2
}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "发送成功"
}
```

---

### 6. 获取留言列表

**接口地址**: `GET /xinlizixunshiLiuyan/page`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| limit | int | 否 | 每页数量，默认 10 |
| xinlizixunshiId | int | 否 | 咨询师 ID |
| liuyanContent | string | 否 | 留言内容模糊搜索 |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": 1,
        "xinlizixunshi_id": 1,
        "yonghu_id": 1,
        "xinlizixunshi_liuyan_text": "王老师，我想预约咨询时间。",
        "reply_text": "好的，请问你什么时间方便？",
        "insert_time": "2026-03-05 10:00:00"
      }
    ],
    "total": 5
  }
}
```

---

### 7. 回复留言

**接口地址**: `POST /xinlizixunshiLiuyan/update`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "id": 1,
  "reply_text": "好的，请问你什么时间方便？"
}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "回复成功"
}
```

---

### 8. 获取帖子列表

**接口地址**: `GET /forum/page`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认 1 |
| limit | int | 否 | 每页数量，默认 10 |
| forumName | string | 否 | 帖子标题模糊搜索 |
| xinlizixunshiId | int | 否 | 咨询师 ID |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": 1,
        "forum_name": "心理健康小知识：如何应对压力",
        "xinlizixunshi_id": 1,
        "forum_content": "压力是现代生活中...",
        "forum_types": 1,
        "insert_time": "2026-03-05 10:00:00"
      }
    ],
    "total": 4
  }
}
```

---

### 9. 发布帖子

**接口地址**: `POST /forum/save`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "forum_name": "新发布的帖子标题",
  "xinlizixunshi_id": 1,
  "forum_content": "帖子内容...",
  "forum_types": 1
}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "发布成功"
}
```

---

### 10. 删除帖子

**接口地址**: `POST /forum/delete`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
```json
{
  "id": 1
}
```

**响应示例**:
```json
{
  "code": 0,
  "msg": "删除成功"
}
```

---

### 11. 获取字典列表

**接口地址**: `GET /dictionary/page`

**请求头**: `Authorization: Bearer {token}`

**请求参数**:
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| dicCode | string | 否 | 字典类型（如 forum） |

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "list": [
      {
        "id": 1,
        "dic_code": "forum",
        "code_index": 1,
        "index_name": "普通帖子"
      }
    ]
  }
}
```

---

### 12. 获取配置信息

**接口地址**: `GET /config/info`

**请求头**: `Authorization: Bearer {token}`

**响应示例**:
```json
{
  "code": 0,
  "data": {
    "counselor_office": "学生活动中心 3 楼 301 室",
    "counselor_phone": "010-12345678",
    "counselor_email": "counselor@school.edu.cn",
    "counselor_hours": "周一至周五 9:00-17:00"
  }
}
```

---

## 测试流程

### 完整测试流程

1. **登录**
   ```bash
   curl -X POST http://localhost:8080/xinlizixunshi/login \
     -H "Content-Type: application/json" \
     -d '{"username":"zixun1","password":"zixun123"}'
   ```

2. **获取个人信息**
   ```bash
   curl -X GET http://localhost:8080/xinlizixunshi/info \
     -H "Authorization: Bearer {token}"
   ```

3. **查看咨询列表**
   ```bash
   curl -X GET "http://localhost:8080/chat/page?page=1&limit=10&xinlizixunshiId=1" \
     -H "Authorization: Bearer {token}"
   ```

4. **查看留言列表**
   ```bash
   curl -X GET "http://localhost:8080/xinlizixunshiLiuyan/page?page=1&limit=10" \
     -H "Authorization: Bearer {token}"
   ```

5. **回复留言**
   ```bash
   curl -X POST http://localhost:8080/xinlizixunshiLiuyan/update \
     -H "Authorization: Bearer {token}" \
     -H "Content-Type: application/json" \
     -d '{"id":1,"reply_text":"好的，欢迎你来咨询"}'
   ```

6. **发布帖子**
   ```bash
   curl -X POST http://localhost:8080/forum/save \
     -H "Authorization: Bearer {token}" \
     -H "Content-Type: application/json" \
     -d '{"forum_name":"新帖子","xinlizixunshi_id":1,"forum_content":"内容","forum_types":1}'
   ```

---

## 错误码说明

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 200 | 请求成功 |
| 400 | 参数错误 |
| 401 | 未授权/登录过期 |
| 403 | 权限不足 |
| 500 | 服务器内部错误 |

---

## 注意事项

1. 所有需要登录的接口都需要在请求头中携带 `Authorization` token
2. token 格式：`Authorization: Bearer {token}`
3. 密码采用明文存储，仅用于测试
4. 测试前请先执行 `counselor_test_data.sql` 导入测试数据