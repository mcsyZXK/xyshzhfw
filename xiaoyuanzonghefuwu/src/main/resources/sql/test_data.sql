-- ============================================
-- 校园生活综合服务系统 - 测试数据脚本
-- 版本：2.0
-- 日期：2026-03-05
-- 说明：密码采用明文存储，用于测试接口功能
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- ============================================
-- 1. 用户测试数据
-- ============================================

-- 管理员账号
DELETE FROM `users`;
INSERT INTO `users` (`username`, `password`, `role`) VALUES 
('admin', 'admin123', '管理员'),
('admin2', 'admin123', '管理员');

-- 普通用户账号
DELETE FROM `yonghu`;
INSERT INTO `yonghu` (`username`, `password`, `yonghu_name`, `yonghu_phone`, `yonghu_email`, `sex_types`, `role`) VALUES 
('user1', 'user123', '张三', '13800138001', 'zhangsan@example.com', 1, '用户'),
('user2', 'user123', '李四', '13800138002', 'lisi@example.com', 2, '用户'),
('user3', 'user123', '王五', '13800138003', 'wangwu@example.com', 1, '用户'),
('user4', 'user123', '赵六', '13800138004', 'zhaoliu@example.com', 2, '用户'),
('user5', 'user123', '钱七', '13800138005', 'qianqi@example.com', 1, '用户');

-- 心理咨询师账号
DELETE FROM `xinlizixunshi`;
INSERT INTO `xinlizixunshi` (`username`, `password`, `xinlizixunshi_name`, `xinlizixunshi_phone`, `xinlizixunshi_email`, `xinlizixunshi_zhiye`, `xinlizixunshi_content`, `sex_types`, `role`) VALUES 
('zixun1', 'zixun123', '王老师', '13900139001', 'wanglaoshi@example.com', '国家二级心理咨询师', '从事心理咨询工作 10 年，擅长处理学习压力、人际关系等问题。', 2, '心理咨询师'),
('zixun2', 'zixun123', '李老师', '13900139002', 'lilaoshi@example.com', '国家三级心理咨询师', '从事心理咨询工作 5 年，擅长处理情感问题、职业规划等。', 1, '心理咨询师');

-- ============================================
-- 2. 字典表测试数据
-- ============================================

DELETE FROM `dictionary`;

-- 性别
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES 
('sex', '性别', 1, '男', NOW()),
('sex', '性别', 2, '女', NOW());

-- 活动类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES 
('huodong', '活动类型', 1, '学术讲座', NOW()),
('huodong', '活动类型', 2, '文体活动', NOW()),
('huodong', '活动类型', 3, '社团活动', NOW()),
('huodong', '活动类型', 4, '志愿服务', NOW()),
('huodong', '活动类型', 5, '就业指导', NOW());

-- 物品类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES 
('wupin', '物品类型', 1, '书籍教材', NOW()),
('wupin', '物品类型', 2, '电子产品', NOW()),
('wupin', '物品类型', 3, '生活用品', NOW()),
('wupin', '物品类型', 4, '运动器材', NOW()),
('wupin', '物品类型', 5, '其他', NOW());

-- 寻物类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES 
('xunwu', '寻物类型', 1, '寻物', NOW()),
('xunwu', '寻物类型', 2, '招领', NOW());

-- 帖子类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES 
('forum', '帖子类型', 1, '普通帖子', NOW()),
('forum', '帖子类型', 2, '咨询帖子', NOW()),
('forum', '帖子类型', 3, '分享帖子', NOW());

-- ============================================
-- 3. 活动测试数据
-- ============================================

DELETE FROM `huodong`;
INSERT INTO `huodong` (`huodong_uuid_number`, `huodong_name`, `huodong_photo`, `huodong_types`, `kaishi_time`, `jieshu_time`, `huodong_clicknum`, `huodong_content`, `huodong_delete`, `insert_time`, `create_time`) VALUES 
('HD001', '2026 春季校园招聘会', '/upload/huodong1.jpg', 5, '2026-03-15 09:00:00', '2026-03-15 17:00:00', 156, '一年一度的春季校园招聘会，届时将有超过 100 家企业参加，提供各类岗位 5000+。地点：学校体育馆。', 1, NOW(), NOW()),
('HD002', '校园歌手大赛', '/upload/huodong2.jpg', 2, '2026-03-20 19:00:00', '2026-03-20 22:00:00', 289, '校园歌手大赛决赛之夜，欢迎同学们前来观看！地点：学生活动中心大礼堂。', 1, NOW(), NOW()),
('HD003', 'Python 编程入门讲座', '/upload/huodong3.jpg', 1, '2026-03-18 14:00:00', '2026-03-18 16:00:00', 78, '计算机学院教授主讲，适合零基础上手。地点：计算机楼 301 教室。', 1, NOW(), NOW()),
('HD004', '篮球友谊赛', '/upload/huodong4.jpg', 2, '2026-03-22 15:00:00', '2026-03-22 17:00:00', 120, '我校篮球队 vs 邻校篮球队，欢迎前来加油助威！地点：学校篮球场。', 1, NOW(), NOW()),
('HD005', '环保志愿活动', '/upload/huodong5.jpg', 4, '2026-03-25 08:00:00', '2026-03-25 12:00:00', 45, '校园周边环境清理活动，欢迎有环保意识的同学参加。集合地点：学校南门。', 1, NOW(), NOW());

-- ============================================
-- 4. 活动报名测试数据
-- ============================================

DELETE FROM `huodong_order`;
INSERT INTO `huodong_order` (`huodong_id`, `yonghu_id`, `huodong_order_text`, `insert_time`, `create_time`) VALUES 
(1, 1, '期待参加招聘会', NOW(), NOW()),
(1, 2, '已报名', NOW(), NOW()),
(2, 1, '我是参赛选手', NOW(), NOW()),
(2, 3, '观众报名', NOW(), NOW()),
(3, 4, '想学习 Python', NOW(), NOW()),
(4, 5, '篮球爱好者', NOW(), NOW());

-- ============================================
-- 5. 活动收藏测试数据
-- ============================================

DELETE FROM `huodong_collection`;
INSERT INTO `huodong_collection` (`huodong_id`, `yonghu_id`, `insert_time`, `create_time`) VALUES 
(1, 1, NOW(), NOW()),
(2, 2, NOW(), NOW()),
(3, 3, NOW(), NOW());

-- ============================================
-- 6. 活动留言测试数据
-- ============================================

DELETE FROM `huodong_liuyan`;
INSERT INTO `huodong_liuyan` (`huodong_id`, `yonghu_id`, `huodong_liuyan_text`, `reply_text`, `insert_time`, `create_time`) VALUES 
(1, 1, '这个活动很有意义，期待参加！', '欢迎参加！', NOW(), NOW()),
(2, 2, '歌手大赛加油！', '谢谢支持！', NOW(), NOW()),
(3, 3, '请问有基础可以吗？', '可以的，欢迎！', NOW(), NOW());

-- ============================================
-- 7. 二手物品测试数据
-- ============================================

DELETE FROM `wupin`;
INSERT INTO `wupin` (`yonghu_id`, `wupin_name`, `wupin_photo`, `wupin_address`, `lianxiren_name`, `lianxiren_phone`, `wupin_types`, `wupin_number`, `wupin_maichu_types`, `wupin_old_money`, `wupin_new_money`, `wupin_content`, `wupin_delete`, `insert_time`, `create_time`) VALUES 
(1, 'Java 编程思想（第 4 版）', '/upload/wupin1.jpg', '图书馆门口', '张三', '13800138001', 1, 1, 1, 89.00, 45.00, '九成新，有少量笔记，不影响阅读。', 1, NOW(), NOW()),
(2, 'iPhone 12 二手', '/upload/wupin2.jpg', '学生宿舍 A 栋', '李四', '13800138002', 2, 1, 1, 6999.00, 3500.00, '128G 黑色，电池健康度 85%，无拆无修。', 1, NOW(), NOW()),
(3, '自行车', '/upload/wupin3.jpg', '食堂门口', '王五', '13800138003', 5, 1, 1, 500.00, 200.00, '普通山地车，骑了半年，车况良好。', 1, NOW(), NOW()),
(4, '台灯', '/upload/wupin4.jpg', '教学楼 B 栋', '赵六', '13800138004', 3, 1, 1, 99.00, 30.00, 'LED 台灯，三档调光，宿舍必备。', 1, NOW(), NOW()),
(5, '篮球', '/upload/wupin5.jpg', '篮球场', '钱七', '13800138005', 4, 1, 1, 150.00, 80.00, '斯伯丁篮球，室外水泥地打过几次，有磨损。', 1, NOW(), NOW());

-- ============================================
-- 8. 二手物品收藏测试数据
-- ============================================

DELETE FROM `wupin_collection`;
INSERT INTO `wupin_collection` (`wupin_id`, `yonghu_id`, `insert_time`, `create_time`) VALUES 
(1, 2, NOW(), NOW()),
(2, 3, NOW(), NOW()),
(3, 4, NOW(), NOW());

-- ============================================
-- 9. 二手物品留言测试数据
-- ============================================

DELETE FROM `wupin_liuyan`;
INSERT INTO `wupin_liuyan` (`wupin_id`, `yonghu_id`, `wupin_liuyan_text`, `reply_text`, `insert_time`, `create_time`) VALUES 
(1, 2, '书还在吗？', '在的', NOW(), NOW()),
(2, 3, '可以小刀吗？', '可以商量', NOW(), NOW()),
(3, 4, '车子能骑吗？', '没问题', NOW(), NOW());

-- ============================================
-- 10. 失物招领测试数据
-- ============================================

DELETE FROM `xunwu`;
INSERT INTO `xunwu` (`yonghu_id`, `xunwu_name`, `xunwu_photo`, `lianxiren_name`, `lianxiren_phone`, `xunwu_types`, `xunwu_zhuangtai_types`, `diushi_time`, `diushi_address`, `diushi_tezheng`, `xunwu_content`, `xunwu_delete`, `insert_time`, `create_time`) VALUES 
(1, '黑色钱包', '/upload/xunwu1.jpg', '张三', '13800138001', 1, 0, '2026-03-01 12:00:00', '食堂二楼', '内有身份证、银行卡', '在食堂吃饭时不小心遗落，里面有重要证件，请拾到的同学联系我，必有重谢！', 1, NOW(), NOW()),
(2, '校园卡', '/upload/xunwu2.jpg', '李四', '13800138002', 1, 1, '2026-03-02 10:00:00', '图书馆', '卡号 2023001', '在图书馆自习时丢失，已被好心同学捡到并归还，感谢！', 1, NOW(), NOW()),
(3, '蓝色雨伞', '/upload/xunwu3.jpg', '王五', '13800138003', 2, 0, '2026-03-03 18:00:00', '教学楼门口', '折叠伞，蓝色格子图案', '在教学楼门口捡到一把雨伞，请失主前来认领。', 1, NOW(), NOW()),
(4, '耳机', '/upload/xunwu4.jpg', '赵六', '13800138004', 1, 0, '2026-03-04 15:00:00', '操场', 'AirPods 二代', '在操场跑步时丢失，白色充电盒，请拾到的同学联系我。', 1, NOW(), NOW());

-- ============================================
-- 11. 失物招领收藏测试数据
-- ============================================

DELETE FROM `xunwu_collection`;
INSERT INTO `xunwu_collection` (`xunwu_id`, `yonghu_id`, `insert_time`, `create_time`) VALUES 
(1, 3, NOW(), NOW()),
(4, 5, NOW(), NOW());

-- ============================================
-- 12. 失物招领留言测试数据
-- ============================================

DELETE FROM `xunwu_liuyan`;
INSERT INTO `xunwu_liuyan` (`xunwu_id`, `yonghu_id`, `xunwu_liuyan_text`, `reply_text`, `insert_time`, `create_time`) VALUES 
(1, 3, '我好像看到有人捡到了', '请问在哪里？', NOW(), NOW()),
(3, 4, '这把伞是我的！', '请描述一下特征', NOW(), NOW());

-- ============================================
-- 13. 论坛帖子测试数据
-- ============================================

DELETE FROM `forum`;
INSERT INTO `forum` (`forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`, `forum_content`, `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `update_time`, `create_time`) VALUES 
('欢迎来到校园论坛！', NULL, NULL, 1, '这是官方论坛，欢迎大家发帖交流！', 0, 1, 0, NOW(), NOW(), NOW()),
('求助：如何高效学习？', 1, NULL, NULL, '大一新生，感觉课程很多，时间不够用，请问学长学姐们有什么好的学习方法？', 0, 2, 0, NOW(), NOW(), NOW()),
('回复：如何高效学习？', 2, NULL, NULL, '建议做好时间管理，使用番茄工作法，另外要多做笔记。', 2, 2, 0, NOW(), NOW(), NOW()),
('分享：校园美食推荐', 3, NULL, NULL, '学校食堂二楼的麻辣烫很好吃，推荐给大家！', 0, 3, 0, NOW(), NOW(), NOW()),
('心理咨询：考试焦虑怎么办？', 4, 1, NULL, '马上要期末考试了，感觉很紧张，晚上睡不好觉，请问老师有什么建议？', 0, 2, 0, NOW(), NOW(), NOW()),
('回复：考试焦虑', NULL, 1, NULL, '考试焦虑是正常现象，建议你制定合理的复习计划，保证充足睡眠，适当运动放松。', 5, 2, 0, NOW(), NOW(), NOW());

-- ============================================
-- 14. 聊天测试数据
-- ============================================

DELETE FROM `chat`;
INSERT INTO `chat` (`yonghu_id`, `users_id`, `chat_content`, `chat_types`, `insert_time`, `create_time`) VALUES 
(1, 1, '老师您好，我想咨询一下活动报名的事情。', 1, NOW(), NOW()),
(1, 1, '你好，请问有什么问题？', 2, NOW(), NOW()),
(1, 1, '我想取消之前的报名。', 1, NOW(), NOW()),
(1, 1, '好的，请告诉我你的报名信息。', 2, NOW(), NOW());

-- ============================================
-- 15. 心理咨询师收藏测试数据
-- ============================================

DELETE FROM `xinlizixunshi_collection`;
INSERT INTO `xinlizixunshi_collection` (`xinlizixunshi_id`, `yonghu_id`, `insert_time`, `create_time`) VALUES 
(1, 1, NOW(), NOW()),
(1, 2, NOW(), NOW()),
(2, 3, NOW(), NOW());

-- ============================================
-- 16. 心理咨询师留言测试数据
-- ============================================

DELETE FROM `xinlizixunshi_liuyan`;
INSERT INTO `xinlizixunshi_liuyan` (`xinlizixunshi_id`, `yonghu_id`, `xinlizixunshi_liuyan_text`, `reply_text`, `insert_time`, `create_time`) VALUES 
(1, 1, '王老师，我想预约咨询时间。', '好的，请问你什么时间方便？', NOW(), NOW()),
(1, 2, '老师，最近学习压力很大。', '可以来咨询室聊聊，我们一起想办法。', NOW(), NOW()),
(2, 3, '李老师，我想咨询职业规划。', '没问题，周三下午我有空。', NOW(), NOW());

-- ============================================
-- 17. 配置表测试数据
-- ============================================

DELETE FROM `config`;
INSERT INTO `config` (`name`, `value`) VALUES 
('site_name', '校园生活综合服务系统'),
('site_logo', '/img/logo.jpg'),
('welcome_message', '欢迎来到校园生活服务平台！'),
('notice', '系统维护时间：每周日凌晨 2:00-4:00');

-- ============================================
-- 测试数据说明
-- ============================================
-- 管理员账号：admin / admin123
-- 普通用户：user1~user5 / user123
-- 心理咨询师：zixun1~zixun2 / zixun123
--
-- 测试接口建议顺序:
-- 1. 登录接口 (users/login 或 yonghu/login)
-- 2. 获取列表接口 (xxx/page)
-- 3. 获取详情接口 (xxx/info/{id})
-- 4. 保存接口 (xxx/save)
-- 5. 修改接口 (xxx/update)
-- 6. 删除接口 (xxx/delete)
-- ============================================