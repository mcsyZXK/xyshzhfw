# 校园生活综合服务系统 - API 接口测试指南

## 测试数据说明

本测试数据脚本包含完整的测试场景，覆盖所有功能模块。

---

## 一、测试账号

### 管理员账号
| 账号 | 密码 | 说明 |
|------|------|------|
| admin | admin123 | 主管理员 |
| admin2 | admin123 | 备用管理员 |

### 普通用户账号
| 账号 | 密码 | 姓名 | 性别 |
|------|------|------|------|
| user1 | user123 | 张三 | 男 |
| user2 | user123 | 李四 | 女 |
| user3 | user123 | 王五 | 男 |
| user4 | user123 | 赵六 | 女 |
| user5 | user123 | 钱七 | 男 |

### 心理咨询师账号
| 账号 | 密码 | 姓名 | 职业资格 |
|------|------|------|----------|
| zixun1 | zixun123 | 王老师 | 国家二级心理咨询师 |
| zixun2 | zixun123 | 李老师 | 国家三级心理咨询师 |

---

## 二、初始化测试数据

### 方法一：使用 MySQL 命令行
```bash
mysql -u root -p < test_data.sql
```

### 方法二：使用 Navicat/Workbench
1. 打开 SQL 文件
2. 运行全部 SQL 语句
3. 检查数据是否导入成功

### 方法三：在项目中自动加载
将 test_data.sql 放在 resources/sql/ 目录下，手动执行

---

## 三、接口测试流程

### 3.1 登录测试

#### 管理员登录
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/users/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin123"
```

**预期响应：**
```json
{
    "code": 0,
    "msg": "success",
    "token": "xxx",
    "role": "管理员",
    "userId": 1
}
```

#### 普通用户登录
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/yonghu/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=user1&password=user123"
```

**预期响应：**
```json
{
    "code": 0,
    "msg": "success",
    "token": "xxx",
    "role": "用户",
    "userId": 1,
    "username": "张三",
    "tableName": "yonghu"
}
```

#### 心理咨询师登录
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/xinlizixunshi/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=zixun1&password=zixun123"
```

---

### 3.2 活动模块测试

#### 获取活动列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/huodong/page?page=1&limit=10&orderBy=id"
```

#### 获取活动详情
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/huodong/info/1
```

#### 保存活动（需要管理员权限）
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

#### 修改活动
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/huodong/update \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "huodongName": "2026 春季校园招聘会（更新）"
  }'
```

#### 删除活动
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/huodong/delete \
  -H "Content-Type: application/json" \
  -d '[5]'
```

---

### 3.3 活动报名测试

#### 获取报名列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/huodongorder/page?page=1&limit=10&orderBy=id"
```

#### 保存报名
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/huodongorder/save \
  -H "Content-Type: application/json" \
  -d '{
    "huodongId": 1,
    "huodongOrderText": "我要报名参加"
  }'
```

---

### 3.4 二手物品模块测试

#### 获取物品列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/wupin/page?page=1&limit=10&orderBy=id"
```

#### 获取物品详情
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/wupin/info/1
```

#### 保存物品
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/wupin/save \
  -H "Content-Type: application/json" \
  -d '{
    "wupinName": "二手笔记本电脑",
    "wupinTypes": 2,
    "wupinAddress": "学生宿舍",
    "lianxirenName": "张三",
    "lianxirenPhone": "13800138001",
    "wupinOldMoney": 5000.00,
    "wupinNewMoney": 2500.00,
    "wupinContent": "九成新，配置良好"
  }'
```

---

### 3.5 失物招领模块测试

#### 获取寻物列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/xunwu/page?page=1&limit=10&orderBy=id"
```

#### 获取寻物详情
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/xunwu/info/1
```

#### 保存寻物
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/xunwu/save \
  -H "Content-Type: application/json" \
  -d '{
    "xunwuName": "丢失的钥匙",
    "xunwuTypes": 1,
    "xunwuZhuangtaiTypes": 0,
    "diushiTime": "2026-03-05 10:00:00",
    "diushiAddress": "图书馆",
    "diushiTezheng": "一串钥匙，有门禁卡",
    "xunwuContent": "在图书馆自习时丢失"
  }'
```

#### 修改寻物状态（标记为已找到）
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/xunwu/update \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "xunwuZhuangtaiTypes": 1
  }'
```

---

### 3.6 论坛模块测试

#### 获取帖子列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/forum/page?page=1&limit=10&orderBy=insert_time"
```

#### 获取帖子详情
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/forum/info/1
```

#### 保存帖子
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/forum/save \
  -H "Content-Type: application/json" \
  -d '{
    "forumName": "新学期学习计划",
    "forumTypes": 1,
    "forumContent": "大家新学期有什么学习计划？一起来分享吧！"
  }'
```

---

### 3.7 心理咨询师模块测试

#### 获取咨询师列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/xinlizixunshi/page?page=1&limit=10&orderBy=id"
```

#### 获取咨询师详情
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/xinlizixunshi/info/1
```

---

### 3.8 聊天模块测试

#### 获取聊天记录
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/chat/page?page=1&limit=20&orderBy=insert_time"
```

#### 发送消息
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/chat/save \
  -H "Content-Type: application/json" \
  -d '{
    "chatContent": "你好，我想咨询一下问题",
    "chatTypes": 1
  }'
```

---

### 3.9 字典表测试

#### 获取字典列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/dictionary/page?page=1&limit=20&orderBy=id"
```

#### 根据类型获取字典
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/dictionary/list?dicCode=huodong"
```

---

### 3.10 用户管理测试

#### 获取用户列表
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/yonghu/page?page=1&limit=10&orderBy=id"
```

#### 获取用户详情
```bash
curl -X GET http://localhost:8080/xiaoyuanzonghefuwu/yonghu/info/1
```

#### 保存用户
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/yonghu/save \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "123456",
    "yonghuName": "测试用户",
    "yonghuPhone": "13800138000",
    "yonghuEmail": "test@example.com",
    "sexTypes": 1
  }'
```

#### 修改用户
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/yonghu/update \
  -H "Content-Type: application/json" \
  -d '{
    "id": 1,
    "yonghuName": "张三丰",
    "yonghuPhone": "13800138001"
  }'
```

#### 删除用户
```bash
curl -X POST http://localhost:8080/xiaoyuanzonghefuwu/yonghu/delete \
  -H "Content-Type: application/json" \
  -d '[5]'
```

#### 重置密码
```bash
curl -X GET "http://localhost:8080/xiaoyuanzonghefuwu/yonghu/resetPassword?id=1"
```

---

## 四、Postman 测试集合

### 环境变量设置
```
baseUrl = http://localhost:8080/xiaoyuanzonghefuwu
```

### 请求 Header 设置
```
Content-Type: application/json
Token: {登录后获取的 token}
```

---

## 五、测试检查清单

### 用户模块
- [ ] 管理员登录成功
- [ ] 普通用户登录成功
- [ ] 心理咨询师登录成功
- [ ] 用户注册成功
- [ ] 退出登录成功
- [ ] 获取用户列表成功
- [ ] 获取用户详情成功
- [ ] 保存用户成功
- [ ] 修改用户成功
- [ ] 删除用户成功
- [ ] 重置密码成功

### 活动模块
- [ ] 获取活动列表成功
- [ ] 获取活动详情成功
- [ ] 保存活动成功
- [ ] 修改活动成功
- [ ] 删除活动成功

### 活动报名模块
- [ ] 获取报名列表成功
- [ ] 获取报名详情成功
- [ ] 保存报名成功
- [ ] 删除报名成功

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

### 心理咨询师模块
- [ ] 获取咨询师列表成功
- [ ] 获取咨询师详情成功

### 聊天模块
- [ ] 获取聊天记录成功
- [ ] 发送消息成功

### 字典表模块
- [ ] 获取字典列表成功
- [ ] 根据类型获取字典成功

---

## 六、常见问题

### 1. 返回 401 错误
**原因**: 未登录或 Session 过期  
**解决**: 重新调用登录接口获取 token

### 2. 返回 500 错误
**原因**: 服务器内部错误  
**解决**: 检查服务器日志，查看具体错误信息

### 3. 跨域问题
**原因**: 浏览器安全策略  
**解决**: 后端已配置 CORS，确保请求头包含必要字段

### 4. 数据重复插入
**原因**: 测试数据未清理  
**解决**: 测试前先执行 DELETE 语句或使用本脚本中的 DELETE+INSERT 组合

---

## 七、数据关系说明

```
用户 (yonghu)
├── 活动报名 (huodong_order)
├── 活动收藏 (huodong_collection)
├── 活动留言 (huodong_liuyan)
├── 二手物品 (wupin)
│   ├── 物品收藏 (wupin_collection)
│   └── 物品留言 (wupin_liuyan)
├── 失物招领 (xunwu)
│   ├── 招领收藏 (xunwu_collection)
│   └── 招领留言 (xunwu_liuyan)
├── 论坛帖子 (forum)
├── 心理咨询师收藏 (xinlizixunshi_collection)
├── 心理咨询师留言 (xinlizixunshi_liuyan)
└── 聊天 (chat)
```

---

*文档版本：1.0*  
*最后更新：2026 年 3 月 5 日*