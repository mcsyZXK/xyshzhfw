-- ============================================
-- 心理咨询师端测试数据脚本
-- 版本：1.0
-- 日期：2026-03-05
-- 说明：用于测试咨询师端接口功能
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- ============================================
-- 1. 心理咨询师测试账号
-- ============================================

DELETE FROM `xinlizixunshi`;
INSERT INTO `xinlizixunshi` (`username`, `password`, `xinlizixunshi_name`, `xinlizixunshi_phone`, `xinlizixunshi_email`, `xinlizixunshi_zhiye`, `xinlizixunshi_content`, `sex_types`, `role`, `xinlizixunshi_photo`) VALUES 
('zixun1', 'zixun123', '王老师', '13900139001', 'wanglaoshi@example.com', '国家二级心理咨询师', '从事心理咨询工作 10 年，擅长处理学习压力、人际关系等问题。', 2, '心理咨询师', '/upload/counselor1.jpg'),
('zixun2', 'zixun123', '李老师', '13900139002', 'lilaoshi@example.com', '国家三级心理咨询师', '从事心理咨询工作 5 年，擅长处理情感问题、职业规划等。', 1, '心理咨询师', '/upload/counselor2.jpg'),
('zixun3', 'zixun123', '张老师', '13900139003', 'zhanglaoshi@example.com', '注册心理师', '心理学博士，擅长认知行为疗法、家庭治疗等。', 1, '心理咨询师', '/upload/counselor3.jpg');

-- ============================================
-- 2. 咨询师收藏测试数据
-- ============================================

DELETE FROM `xinlizixunshi_collection`;
INSERT INTO `xinlizixunshi_collection` (`xinlizixunshi_id`, `yonghu_id`, `insert_time`, `create_time`) VALUES 
(1, 1, NOW(), NOW()),
(1, 2, NOW(), NOW()),
(2, 3, NOW(), NOW()),
(3, 4, NOW(), NOW());

-- ============================================
-- 3. 咨询师留言测试数据
-- ============================================

DELETE FROM `xinlizixunshi_liuyan`;
INSERT INTO `xinlizixunshi_liuyan` (`xinlizixunshi_id`, `yonghu_id`, `xinlizixunshi_liuyan_text`, `reply_text`, `insert_time`, `create_time`) VALUES 
(1, 1, '王老师，我想预约咨询时间。', '好的，请问你什么时间方便？', NOW(), NOW()),
(1, 2, '老师，最近学习压力很大。', '可以来咨询室聊聊，我们一起想办法。', NOW(), NOW()),
(2, 3, '李老师，我想咨询职业规划。', '没问题，周三下午我有空。', NOW(), NOW()),
(3, 4, '张老师，我对未来很迷茫。', '可以预约一次咨询，我们详细聊聊。', NOW(), NOW()),
(1, 5, '老师，我最近情绪不太好。', '别担心，来咨询室坐坐吧。', NOW(), NOW());

-- ============================================
-- 4. 聊天测试数据（包含咨询师）
-- ============================================

DELETE FROM `chat`;
INSERT INTO `chat` (`yonghu_id`, `xinlizixunshi_id`, `users_id`, `chat_content`, `chat_types`, `insert_time`, `create_time`) VALUES 
(1, 1, NULL, '老师您好，我想咨询一下学习压力的问题。', 1, NOW(), NOW()),
(1, 1, NULL, '你好，请具体说说你的情况。', 2, NOW(), NOW()),
(1, 1, NULL, '最近课程很多，感觉时间不够用。', 1, NOW(), NOW()),
(1, 1, NULL, '理解你的感受，建议做好时间管理。', 2, NOW(), NOW()),
(2, 1, NULL, '老师，我晚上睡不着觉。', 1, NOW(), NOW()),
(2, 1, NULL, '睡前可以试试冥想放松。', 2, NOW(), NOW()),
(3, 2, NULL, '李老师，我想咨询职业规划。', 1, NOW(), NOW()),
(3, 2, NULL, '好的，你对未来有什么想法？', 2, NOW(), NOW()),
(4, 3, NULL, '张老师，我对人际关系很困惑。', 1, NOW(), NOW()),
(4, 3, NULL, '人际关系确实很重要，具体说说。', 2, NOW(), NOW());

-- ============================================
-- 5. 论坛帖子（咨询师发布）
-- ============================================

DELETE FROM `forum`;
INSERT INTO `forum` (`forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`, `forum_content`, `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `update_time`, `create_time`) VALUES 
('心理健康小知识：如何应对压力', NULL, 1, NULL, '压力是现代生活中不可避免的一部分。以下是一些应对压力的小技巧：\n1. 深呼吸放松\n2. 适当运动\n3. 与朋友交流\n4. 保证充足睡眠\n5. 学会说"不"', 0, 1, 0, NOW(), NOW(), NOW()),
('情绪管理的重要性', NULL, 2, NULL, '情绪管理是指通过调节和控制情绪，使其适应环境的过程。良好的情绪管理能力有助于：\n- 提高学习效率\n- 改善人际关系\n- 增强心理韧性', 0, 1, 0, NOW(), NOW(), NOW()),
('回复：如何高效学习？', NULL, 1, NULL, '除了做好时间管理，还要注意劳逸结合。适当的休息可以提高学习效率。', 2, 2, 0, NOW(), NOW(), NOW()),
('考试焦虑应对指南', NULL, 3, NULL, '考试焦虑是一种常见的心理问题。以下是一些应对方法：\n1. 充分准备\n2. 调整心态\n3. 放松训练\n4. 寻求支持', 0, 1, 0, NOW(), NOW(), NOW());

-- ============================================
-- 6. 配置表（咨询师相关）
-- ============================================

DELETE FROM `config`;
INSERT INTO `config` (`name`, `value`) VALUES 
('counselor_office', '学生活动中心 3 楼 301 室'),
('counselor_phone', '010-12345678'),
('counselor_email', 'counselor@school.edu.cn'),
('counselor_hours', '周一至周五 9:00-17:00');

-- ============================================
-- 测试账号说明
-- ============================================
-- 心理咨询师账号：
-- zixun1 / zixun123 - 王老师
-- zixun2 / zixun123 - 李老师
-- zixun3 / zixun123 - 张老师
--
-- 测试接口建议顺序:
-- 1. 咨询师登录 (xinlizixunshi/login)
-- 2. 获取咨询师信息 (xinlizixunshi/info)
-- 3. 获取咨询列表 (chat/page)
-- 4. 获取留言列表 (xinlizixunshiLiuyan/page)
-- 5. 回复留言 (xinlizixunshiLiuyan/update)
-- 6. 发布帖子 (forum/save)
-- 7. 更新个人信息 (xinlizixunshi/update)
-- ============================================