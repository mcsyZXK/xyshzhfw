-- ============================================
-- 校园生活综合服务系统 - 管理员后台 API 测试数据
-- 版本：2.0
-- 日期：2026-03-05
-- 说明：用于测试管理员后台所有接口功能
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- ============================================
-- 第一部分：基础数据准备
-- ============================================

-- 1. 清空并重置管理员账号
DELETE FROM `users`;
INSERT INTO `users` (`username`, `password`, `role`) VALUES 
('admin', 'admin123', '管理员'),
('admin2', 'admin123', '管理员');

-- 2. 清空并重置普通用户账号
DELETE FROM `yonghu`;
INSERT INTO `yonghu` (`username`, `password`, `yonghu_name`, `yonghu_phone`, `yonghu_email`, `sex_types`, `role`) VALUES 
('user1', 'user123', '张三', '13800138001', 'zhangsan@example.com', 1, '用户'),
('user2', 'user123', '李四', '13800138002', 'lisi@example.com', 2, '用户'),
('user3', 'user123', '王五', '13800138003', 'wangwu@example.com', 1, '用户'),
('user4', 'user123', '赵六', '13800138004', 'zhaoliu@example.com', 2, '用户'),
('user5', 'user123', '钱七', '13800138005', 'qianqi@example.com', 1, '用户');

-- 3. 清空并重置心理咨询师账号
DELETE FROM `xinlizixunshi`;
INSERT INTO `xinlizixunshi` (`username`, `password`, `xinlizixunshi_name`, `xinlizixunshi_phone`, `xinlizixunshi_email`, `xinlizixunshi_zhiye`, `xinlizixunshi_content`, `sex_types`, `role`) VALUES 
('zixun1', 'zixun123', '王老师', '13900139001', 'wanglaoshi@example.com', '国家二级心理咨询师', '从事心理咨询工作 10 年，擅长处理学习压力、人际关系等问题。', 2, '心理咨询师'),
('zixun2', 'zixun123', '李老师', '13900139002', 'lilaoshi@example.com', '国家三级心理咨询师', '从事心理咨询工作 5 年，擅长处理情感问题、职业规划等。', 1, '心理咨询师');

-- 4. 字典表数据
DELETE FROM `dictionary`;
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES 
('sex', '性别', 1, '男', NOW()),
('sex', '性别', 2, '女', NOW()),
('huodong', '活动类型', 1, '学术讲座', NOW()),
('huodong', '活动类型', 2, '文体活动', NOW()),
('huodong', '活动类型', 3, '社团活动', NOW()),
('huodong', '活动类型', 4, '志愿服务', NOW()),
('wupin', '物品类型', 1, '书籍教材', NOW()),
('wupin', '物品类型', 2, '电子产品', NOW()),
('wupin', '物品类型', 3, '生活用品', NOW()),
('xunwu', '寻物类型', 1, '寻物', NOW()),
('xunwu', '寻物类型', 2, '招领', NOW()),
('forum', '帖子类型', 1, '普通帖子', NOW()),
('forum', '帖子类型', 2, '咨询帖子', NOW());

-- 5. 配置表数据
DELETE FROM `config`;
INSERT INTO `config` (`name`, `value`) VALUES 
('site_name', '校园生活综合服务系统'),
('site_logo', '/img/logo.jpg'),
('welcome_message', '欢迎来到校园生活服务平台！');

-- ============================================
-- 第二部分：业务数据
-- ============================================

-- 6. 活动数据
DELETE FROM `huodong`;
INSERT INTO `huodong` (`huodong_uuid_number`, `huodong_name`, `huodong_photo`, `huodong_types`, `kaishi_time`, `jieshu_time`, `huodong_clicknum`, `huodong_content`, `huodong_delete`, `insert_time`, `create_time`) VALUES 
('HD001', '2026 春季校园招聘会', '/upload/huodong1.jpg', 1, '2026-03-15 09:00:00', '2026-03-15 17:00:00', 156, '一年一度的春季校园招聘会', 1, NOW(), NOW()),
('HD002', '校园歌手大赛', '/upload/huodong2.jpg', 2, '2026-03-20 19:00:00', '2026-03-20 22:00:00', 289, '校园歌手大赛决赛之夜', 1, NOW(), NOW()),
('HD003', 'Python 编程入门讲座', '/upload/huodong3.jpg', 1, '2026-03-18 14:00:00', '2026-03-18 16:00:00', 78, '计算机学院教授主讲', 1, NOW(), NOW());

-- 7. 活动报名数据
DELETE FROM `huodong_order`;
INSERT INTO `huodong_order` (`huodong_id`, `yonghu_id`, `huodong_order_text`, `insert_time`, `create_time`) VALUES 
(1, 1, '期待参加招聘会', NOW(), NOW()),
(1, 2, '已报名', NOW(), NOW()),
(2, 1, '我是参赛选手', NOW(), NOW()),
(3, 3, '想学习 Python', NOW(), NOW());

-- 8. 二手物品数据
DELETE FROM `wupin`;
INSERT INTO `wupin` (`yonghu_id`, `wupin_name`, `wupin_photo`, `wupin_address`, `lianxiren_name`, `lianxiren_phone`, `wupin_types`, `wupin_number`, `wupin_maichu_types`, `wupin_old_money`, `wupin_new_money`, `wupin_content`, `wupin_delete`, `insert_time`, `create_time`) VALUES 
(1, 'Java 编程思想（第 4 版）', '/upload/wupin1.jpg', '图书馆门口', '张三', '13800138001', 1, 1, 1, 89.00, 45.00, '九成新，有少量笔记', 1, NOW(), NOW()),
(2, 'iPhone 12 二手', '/upload/wupin2.jpg', '学生宿舍 A 栋', '李四', '13800138002', 2, 1, 1, 6999.00, 3500.00, '128G 黑色，电池健康度 85%', 1, NOW(), NOW()),
(3, '自行车', '/upload/wupin3.jpg', '学生宿舍', '王五', '13800138003', 3, 1, 1, 500.00, 200.00, '普通山地车', 1, NOW(), NOW());

-- 9. 失物招领数据
DELETE FROM `xunwu`;
INSERT INTO `xunwu` (`yonghu_id`, `xunwu_name`, `xunwu_photo`, `lianxiren_name`, `lianxiren_phone`, `xunwu_types`, `xunwu_zhuangtai_types`, `diushi_time`, `diushi_address`, `diushi_tezheng`, `xunwu_content`, `xunwu_delete`, `insert_time`, `create_time`) VALUES 
(1, '黑色钱包', '/upload/xunwu1.jpg', '张三', '13800138001', 1, 0, '2026-03-01 12:00:00', '食堂二楼', '内有身份证、银行卡', '在食堂吃饭时不小心遗落', 1, NOW(), NOW()),
(2, '校园卡', '/upload/xunwu2.jpg', '李四', '13800138002', 2, 1, '2026-03-02 10:00:00', '图书馆', '卡号 2023001', '在图书馆自习时丢失', 1, NOW(), NOW()),
(3, '蓝色雨伞', '/upload/xunwu3.jpg', '王五', '13800138003', 2, 0, '2026-03-03 18:00:00', '教学楼门口', '折叠伞，蓝色格子图案', '在教学楼门口捡到', 1, NOW(), NOW());

-- 10. 论坛帖子数据
DELETE FROM `forum`;
INSERT INTO `forum` (`forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`, `forum_content`, `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `update_time`, `create_time`) VALUES 
('欢迎来到校园论坛！', NULL, NULL, 1, '这是官方论坛，欢迎大家发帖交流！', 0, 1, 0, NOW(), NOW(), NOW()),
('求助：如何高效学习？', 1, NULL, NULL, '大一新生，感觉课程很多，时间不够用', 0, 2, 0, NOW(), NOW(), NOW()),
('分享：校园美食推荐', 3, NULL, NULL, '学校食堂二楼的麻辣烫很好吃', 0, 1, 0, NOW(), NOW(), NOW()),
('心理咨询：考试焦虑怎么办？', 4, 1, NULL, '马上要期末考试了，感觉很紧张', 0, 2, 0, NOW(), NOW(), NOW());

-- 11. 聊天记录数据
DELETE FROM `chat`;
INSERT INTO `chat` (`yonghu_id`, `users_id`, `chat_content`, `chat_types`, `insert_time`, `create_time`) VALUES 
(1, 1, '老师您好，我想咨询一下活动报名的事情。', 1, NOW(), NOW()),
(1, 1, '你好，请问有什么问题？', 2, NOW(), NOW()),
(2, 1, '老师，我想问一下失物招领怎么发布？', 1, NOW(), NOW()),
(2, 1, '在失物招领页面点击发布按钮即可。', 2, NOW(), NOW());

-- ============================================
-- 第三部分：API 测试用例（注释形式）
-- ============================================

/*
-- 测试说明：
-- 1. 先执行本脚本初始化数据
-- 2. 使用 Postman 或其他工具测试以下接口
-- 3. 基础 URL: http://localhost:8080/xiaoyuanzonghefuwu/

-- ============================================
-- 管理员登录测试
-- ============================================

-- 1. 管理员登录
POST /users/login
Content-Type: application/x-www-form-urlencoded
username=admin&password=admin123

预期响应:
{
    "code": 0,
    "msg": "success",
    "token": "xxx",
    "role": "管理员",
    "userId": 1
}

-- 2. 获取管理员 session 信息
GET /users/session

-- 3. 管理员退出
GET /users/logout

-- ============================================
-- 用户管理接口测试
-- ============================================

-- 4. 获取用户列表
GET /yonghu/page?page=1&limit=10&orderBy=id

-- 5. 获取用户详情
GET /yonghu/info/1

-- 6. 添加用户
POST /yonghu/save
Content-Type: application/json
{
    "username": "testuser",
    "password": "123456",
    "yonghuName": "测试用户",
    "yonghuPhone": "13800138000",
    "yonghuEmail": "test@example.com",
    "sexTypes": 1
}

-- 7. 修改用户
POST /yonghu/update
Content-Type: application/json
{
    "id": 1,
    "yonghuName": "张三丰",
    "yonghuPhone": "13800138001"
}

-- 8. 删除用户
POST /yonghu/delete
Content-Type: application/json
[5]

-- 9. 重置用户密码
GET /yonghu/resetPassword?id=1

-- ============================================
-- 心理咨询师管理接口测试
-- ============================================

-- 10. 获取咨询师列表
GET /xinlizixunshi/page?page=1&limit=10&orderBy=id

-- 11. 获取咨询师详情
GET /xinlizixunshi/info/1

-- 12. 添加咨询师
POST /xinlizixunshi/save
Content-Type: application/json
{
    "username": "zixun3",
    "password": "zixun123",
    "xinlizixunshiName": "陈老师",
    "xinlizixunshiPhone": "13900139003",
    "xinlizixunshiEmail": "chenlaoshi@example.com",
    "xinlizixunshiZhiye": "国家一级心理咨询师",
    "xinlizixunshiContent": "从事心理咨询工作 15 年",
    "sexTypes": 1
}

-- 13. 修改咨询师
POST /xinlizixunshi/update
Content-Type: application/json
{
    "id": 1,
    "xinlizixunshiName": "王老师（更新）",
    "xinlizixunshiPhone": "13900139001"
}

-- 14. 删除咨询师
POST /xinlizixunshi/delete
Content-Type: application/json
[2]

-- ============================================
-- 活动管理接口测试
-- ============================================

-- 15. 获取活动列表
GET /huodong/page?page=1&limit=10&orderBy=id

-- 16. 获取活动详情
GET /huodong/info/1

-- 17. 添加活动
POST /huodong/save
Content-Type: application/json
{
    "huodongUuidNumber": "HD004",
    "huodongName": "新技术分享会",
    "huodongTypes": 1,
    "kaishiTime": "2026-03-28 14:00:00",
    "jieshuTime": "2026-03-28 17:00:00",
    "huodongContent": "分享最新的技术趋势"
}

-- 18. 修改活动
POST /huodong/update
Content-Type: application/json
{
    "id": 1,
    "huodongName": "2026 春季校园招聘会（更新）"
}

-- 19. 删除活动
POST /huodong/delete
Content-Type: application/json
[3]

-- ============================================
-- 活动报名管理接口测试
-- ============================================

-- 20. 获取报名列表
GET /huodongorder/page?page=1&limit=10&orderBy=id

-- 21. 获取报名详情
GET /huodongorder/info/1

-- 22. 添加报名
POST /huodongorder/save
Content-Type: application/json
{
    "huodongId": 1,
    "yonghuId": 3,
    "huodongOrderText": "报名参加"
}

-- 23. 删除报名
POST /huodongorder/delete
Content-Type: application/json
[4]

-- ============================================
-- 二手物品管理接口测试
-- ============================================

-- 24. 获取物品列表
GET /wupin/page?page=1&limit=10&orderBy=id

-- 25. 获取物品详情
GET /wupin/info/1

-- 26. 添加物品
POST /wupin/save
Content-Type: application/json
{
    "yonghuId": 1,
    "wupinName": "二手教材",
    "wupinTypes": 1,
    "wupinAddress": "图书馆门口",
    "lianxirenName": "张三",
    "lianxirenPhone": "13800138001",
    "wupinNumber": 1,
    "wupinMaichuTypes": 1,
    "wupinOldMoney": 50.00,
    "wupinNewMoney": 25.00,
    "wupinContent": "九成新"
}

-- 27. 修改物品
POST /wupin/update
Content-Type: application/json
{
    "id": 1,
    "wupinNewMoney": 40.00
}

-- 28. 删除物品
POST /wupin/delete
Content-Type: application/json
[3]

-- ============================================
-- 失物招领管理接口测试
-- ============================================

-- 29. 获取寻物列表
GET /xunwu/page?page=1&limit=10&orderBy=id

-- 30. 获取寻物详情
GET /xunwu/info/1

-- 31. 添加寻物
POST /xunwu/save
Content-Type: application/json
{
    "yonghuId": 1,
    "xunwuName": "丢失的钱包",
    "xunwuTypes": 1,
    "lianxirenName": "张三",
    "lianxirenPhone": "13800138001",
    "diushiTime": "2026-03-05 12:00:00",
    "diushiAddress": "食堂",
    "diushiTezheng": "黑色，内有证件",
    "xunwuContent": "黑色钱包，内有重要证件"
}

-- 32. 修改寻物
POST /xunwu/update
Content-Type: application/json
{
    "id": 1,
    "xunwuZhuangtaiTypes": 1
}

-- 33. 删除寻物
POST /xunwu/delete
Content-Type: application/json
[3]

-- ============================================
-- 论坛管理接口测试
-- ============================================

-- 34. 获取帖子列表
GET /forum/page?page=1&limit=10&orderBy=id

-- 35. 获取帖子详情
GET /forum/info/1

-- 36. 添加帖子
POST /forum/save
Content-Type: application/json
{
    "forumName": "新帖子标题",
    "forumContent": "帖子内容",
    "forumTypes": 1
}

-- 37. 修改帖子
POST /forum/update
Content-Type: application/json
{
    "id": 1,
    "forumName": "更新后的标题"
}

-- 38. 删除帖子
POST /forum/delete
Content-Type: application/json
[4]

-- ============================================
-- 咨询记录管理接口测试
-- ============================================

-- 39. 获取聊天记录列表
GET /chat/page?page=1&limit=10&orderBy=insert_time

-- 40. 获取聊天详情
GET /chat/info/1

-- 41. 发送消息
POST /chat/save
Content-Type: application/json
{
    "yonghuId": 1,
    "chatContent": "你好，我想咨询...",
    "chatTypes": 1
}

-- 42. 删除聊天
POST /chat/delete
Content-Type: application/json
[4]

-- ============================================
-- 字典管理接口测试
-- ============================================

-- 43. 获取字典列表
GET /dictionary/page?page=1&limit=10&orderBy=id

-- 44. 获取字典详情
GET /dictionary/info/1

-- 45. 添加字典
POST /dictionary/save
Content-Type: application/json
{
    "dicCode": "test",
    "dicName": "测试字典",
    "codeIndex": 99,
    "indexName": "测试项",
    "superId": 0,
    "beizhu": "测试备注"
}

-- 46. 修改字典
POST /dictionary/update
Content-Type: application/json
{
    "id": 1,
    "indexName": "男（更新）"
}

-- 47. 删除字典
POST /dictionary/delete
Content-Type: application/json
[10]

-- ============================================
-- 配置管理接口测试
-- ============================================

-- 48. 获取配置列表
GET /config/page?page=1&limit=10&orderBy=id

-- 49. 获取配置详情
GET /config/info/1

-- 50. 添加配置
POST /config/save
Content-Type: application/json
{
    "name": "test_config",
    "value": "测试配置值"
}

-- 51. 修改配置
POST /config/update
Content-Type: application/json
{
    "id": 1,
    "value": "更新后的配置值"
}

-- 52. 删除配置
POST /config/delete
Content-Type: application/json
[4]

-- ============================================
-- 通用接口测试
-- ============================================

-- 53. 获取字典类型列表（根据编码获取）
GET /dictionary/list?dicCode=sex

-- 54. 获取所有字典
GET /dictionary/list

-- 55. 文件上传（如有需要）
POST /file/upload
Content-Type: multipart/form-data
file: [选择文件]

*/

-- ============================================
-- 测试完成检查清单
-- ============================================

/*
管理员后台接口测试检查清单：

□ 1. 管理员登录成功
□ 2. 获取用户列表成功
□ 3. 添加用户成功
□ 4. 修改用户成功
□ 5. 删除用户成功
□ 6. 获取咨询师列表成功
□ 7. 添加咨询师成功
□ 8. 修改咨询师成功
□ 9. 删除咨询师成功
□ 10. 获取活动列表成功
□ 11. 添加活动成功
□ 12. 修改活动成功
□ 13. 删除活动成功
□ 14. 获取报名列表成功
□ 15. 删除报名成功
□ 16. 获取物品列表成功
□ 17. 添加物品成功
□ 18. 修改物品成功
□ 19. 删除物品成功
□ 20. 获取寻物列表成功
□ 21. 添加寻物成功
□ 22. 修改寻物成功
□ 23. 删除寻物成功
□ 24. 获取帖子列表成功
□ 25. 添加帖子成功
□ 26. 修改帖子成功
□ 27. 删除帖子成功
□ 28. 获取聊天记录成功
□ 29. 发送消息成功
□ 30. 删除聊天成功
□ 31. 获取字典列表成功
□ 32. 添加字典成功
□ 33. 修改字典成功
□ 34. 删除字典成功
□ 35. 获取配置列表成功
□ 36. 添加配置成功
□ 37. 修改配置成功
□ 38. 删除配置成功

测试账号：
- 管理员：admin / admin123
- 用户：user1 / user123
- 咨询师：zixun1 / zixun123
*/

-- ============================================
-- 结束
-- ============================================