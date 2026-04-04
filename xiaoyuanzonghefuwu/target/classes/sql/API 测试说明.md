# 校园生活综合服务系统 - API 接口测试说明

## 版本信息
- 版本：2.0
- 日期：2026-03-05
- 说明：密码采用明文存储，使用 Session 进行身份验证

---

## 基础信息

### 服务地址
- 本地开发：`http://localhost:8080/xiaoyuanzonghefuwu/`

### 认证方式
- 登录后将用户信息存储在 Session 中
- 后续请求通过 Session 自动识别用户身份
- 部分接口支持跨域请求（CORS）

### 统一响应格式
```json
{
    "code": 200,        // 状态码：200 成功，500 错误，401 未登录
    "msg": "success",   // 消息
    "data": {}          // 数据
}
```

---

## 测试账号

| 角色 | 账号 | 密码 | 说明 |
|------|------|------|------|
| 管理员 | admin | admin123 | 系统管理员 |
| 普通用户 | user1 | user123 | 张三 |
| 普通用户 | user2 | user123 | 李四 |
| 心理咨询师 | zixun1 | zixun123 | 王老师 |

---

## 接口列表

### 1. 管理员登录接口

#### 1.1 登录
```
POST /users/login
Content-Type: application/x-www-form-urlencoded

参数:
- username: 账号
- password: 密码

响应示例:
{
    "code": 0,
    "msg": "success",
    "token": "abc123...",
    "role": "管理员",
    "userId": 1
}
```

#### 1.2 退出登录
```
GET /users/logout
```

#### 1.3 获取当前用户信息
```
GET /users/session
```

#### 1.4 密码重置
```
POST /users/resetPass
Content-Type: application/x-www-form-urlencoded

参数:
- username: 账号
```

---

### 2. 用户模块接口

#### 2.1 用户登录
```
POST /yonghu/login
Content-Type: application/x-www-form-urlencoded

参数:
- username: 账号
- password: 密码

响应示例:
{
    "code": 0,
    "msg": "success",
    "token": "abc123...",
    "role": "用户",
    "userId": 1,
    "username": "张三",
    "tableName": "yonghu"
}
```

#### 2.2 用户注册
```
POST /yonghu/register
Content-Type: application/json

{
    "username": "newuser",
    "password": "123456",
    "yonghuName": "新用户",
    "yonghuPhone": "13800138000",
    "yonghuEmail": "newuser@example.com"
}
```

#### 2.3 获取用户列表
```
GET /yonghu/page?orderBy=id
```

#### 2.4 获取用户详情
```
GET /yonghu/info/{id}
```

#### 2.5 保存用户
```
POST /yonghu/save
Content-Type: application/json

{
    "username": "testuser",
    "yonghuName": "测试用户",
    "yonghuPhone": "13800138000"
}
```

#### 2.6 修改用户
```
POST /yonghu/update
Content-Type: application/json

{
    "id": 1,
    "yonghuName": "张三丰",
    "yonghuPhone": "13800138001"
}
```

#### 2.7 删除用户
```
POST /yonghu/delete
Content-Type: application/json

[1, 2, 3]
```

#### 2.8 重置密码
```
GET /yonghu/resetPassword?id=1
```

---

### 3. 活动模块接口

#### 3.1 获取活动列表
```
GET /huodong/page?orderBy=id
```

#### 3.2 获取活动详情
```
GET /huodong/info/{id}
```

#### 3.3 保存活动
```
POST /huodong/save
Content-Type: application/json

{
    "huodongUuidNumber": "HD006",
    "huodongName": "新技术分享会",
    "huodongTypes": 1,
    "kaishiTime": "2026-03-28 14:00:00",
    "jieshuTime": "2026-03-28 17:00:00",
    "huodongContent": "分享最新的技术趋势"
}
```

#### 3.4 修改活动
```
POST /huodong/update
Content-Type: application/json

{
    "id": 1,
    "huodongName": "2026 春季校园招聘会（更新）"
}
```

#### 3.5 删除活动
```
POST /huodong/delete
Content-Type: application/json

[1, 2, 3]
```

---

### 4. 活动报名接口

#### 4.1 获取报名列表
```
GET /huodongorder/page?orderBy=id
```

#### 4.2 获取报名详情
```
GET /huodongorder/info/{id}
```

#### 4.3 保存报名
```
POST /huodongorder/save
Content-Type: application/json

{
    "huodongId": 1,
    "yonghuId": 1,
    "huodongOrderText": "报名参加"
}
```

#### 4.4 删除报名
```
POST /huodongorder/delete
Content-Type: application/json

[1, 2, 3]
```

---

### 5. 二手物品接口

#### 5.1 获取物品列表
```
GET /wupin/page?orderBy=id
```

#### 5.2 获取物品详情
```
GET /wupin/info/{id}
```

#### 5.3 保存物品
```
POST /wupin/save
Content-Type: application/json

{
    "yonghuId": 1,
    "wupinName": "二手教材",
    "wupinTypes": 1,
    "wupinNewMoney": 30.00,
    "wupinContent": "九成新"
}
```

#### 5.4 修改物品
```
POST /wupin/update
Content-Type: application/json

{
    "id": 1,
    "wupinNewMoney": 40.00
}
```

#### 5.5 删除物品
```
POST /wupin/delete
Content-Type: application/json

[1, 2, 3]
```

---

### 6. 失物招领接口

#### 6.1 获取寻物列表
```
GET /xunwu/page?orderBy=id
```

#### 6.2 获取寻物详情
```
GET /xunwu/info/{id}
```

#### 6.3 保存寻物
```
POST /xunwu/save
Content-Type: application/json

{
    "yonghuId": 1,
    "xunwuName": "丢失的钱包",
    "xunwuTypes": 1,
    "diushiAddress": "食堂",
    "xunwuContent": "黑色钱包，内有重要证件"
}
```

#### 6.4 修改寻物
```
POST /xunwu/update
Content-Type: application/json

{
    "id": 1,
    "xunwuZhuangtaiTypes": 1
}
```

#### 6.5 删除寻物
```
POST /xunwu/delete
Content-Type: application/json

[1, 2, 3]
```

---

### 7. 论坛接口

#### 7.1 获取帖子列表
```
GET /forum/page?orderBy=id
```

#### 7.2 获取帖子详情
```
GET /forum/info/{id}
```

#### 7.3 保存帖子
```
POST /forum/save
Content-Type: application/json

{
    "forumName": "新帖子标题",
    "forumContent": "帖子内容",
    "forumTypes": 1
}
```

#### 7.4 修改帖子
```
POST /forum/update
Content-Type: application/json

{
    "id": 1,
    "forumName": "更新后的标题"
}
```

#### 7.5 删除帖子
```
POST /forum/delete
Content-Type: application/json

[1, 2, 3]
```

---

### 8. 心理咨询师接口

#### 8.1 获取咨询师列表
```
GET /xinlizixunshi/page?orderBy=id
```

#### 8.2 获取咨询师详情
```
GET /xinlizixunshi/info/{id}
```

#### 8.3 咨询师登录
```
POST /xinlizixunshi/login
Content-Type: application/x-www-form-urlencoded

参数:
- username: 账号
- password: 密码
```

---

### 9. 字典表接口

#### 9.1 获取字典列表
```
GET /dictionary/page?orderBy=id
```

#### 9.2 获取字典详情
```
GET /dictionary/info/{id}
```

---

### 10. 聊天接口

#### 10.1 获取聊天记录
```
GET /chat/page?orderBy=insert_time
```

#### 10.2 发送消息
```
POST /chat/save
Content-Type: application/json

{
    "yonghuId": 1,
    "chatContent": "你好，我想咨询...",
    "chatTypes": 1
}
```

---

## 使用 Postman 测试

### 1. 导入测试集合
1. 打开 Postman
2. 点击 Import
3. 选择测试集合文件（如有）

### 2. 设置环境变量
- `baseUrl`: `http://localhost:8080/xiaoyuanzonghefuwu`

### 3. 测试流程
1. 先调用登录接口获取 token
2. 将 token 添加到 Header: `Token: {token}`
3. 调用其他需要认证的接口

---

## 使用 cURL 测试

### 登录示例
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/users/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

### 获取活动列表示例
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/huodong/page?orderBy=id
```

### 保存活动示例
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/huodong/save \
  -H "Content-Type: application/json" \
  -d '{
    "huodongUuidNumber": "HD006",
    "huodongName": "新技术分享会",
    "huodongTypes": 1,
    "kaishiTime": "2026-03-28 14:00:00",
    "jieshuTime": "2026-03-28 17:00:00",
    "huodongContent": "分享最新的技术趋势"
  }'
```

---

## 测试检查清单

### 用户模块
- [ ] 管理员登录成功
- [ ] 普通用户登录成功
- [ ] 用户注册成功
- [ ] 退出登录成功
- [ ] 获取用户列表成功
- [ ] 获取用户详情成功

### 活动模块
- [ ] 获取活动列表成功
- [ ] 获取活动详情成功
- [ ] 保存活动成功
- [ ] 修改活动成功
- [ ] 删除活动成功

### 二手物品模块
- [ ] 获取物品列表成功
- [ ] 获取物品详情成功
- [ ] 保存物品成功
- [ ] 修改物品成功
- [ ] 删除物品成功

### 失物招领模块
- [ ] 获取寻物列表成功
- [ ] 获取寻物详情成功
- [ ] 保存寻物成功
- [ ] 修改寻物成功
- [ ] 删除寻物成功

### 论坛模块
- [ ] 获取帖子列表成功
- [ ] 获取帖子详情成功
- [ ] 保存帖子成功
- [ ] 修改帖子成功
- [ ] 删除帖子成功

---

## 常见问题

### 1. 返回 401 错误
**原因**: 未登录或 Session 过期
**解决**: 重新调用登录接口

### 2. 返回 500 错误
**原因**: 服务器内部错误
**解决**: 检查服务器日志

### 3. 跨域问题
**原因**: 浏览器安全策略
**解决**: 后端已配置 CORS，确保请求头包含必要字段

---

*文档版本：1.0*
*最后更新：2026 年 3 月 5 日*