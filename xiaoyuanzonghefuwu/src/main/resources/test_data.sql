-- ============================================
-- 校园生活综合服务系统 - 测试数据
-- 用于测试重构后的后端接口
-- ============================================

-- 1. 用户表测试数据
INSERT INTO `yonghu` (`username`, `password`, `vip_level`, `phone`, `email`, `create_time`) 
VALUES 
('test_user1', '123456', 1, '13800138001', 'test1@example.com', NOW()),
('test_user2', '123456', 2, '13800138002', 'test2@example.com', NOW()),
('test_user3', '123456', 1, '13800138003', 'test3@example.com', NOW());

-- 2. 心理咨询师表测试数据
INSERT INTO `xinlizixunshi` (`xinlizixunshi_account`, `xinlizixunshi_name`, `sex`, `phone`, `email`, `create_time`) 
VALUES 
('counselor1', '123456', '男', '13900139001', 'counselor1@example.com', NOW()),
('counselor2', '123456', '女', '13900139002', 'counselor2@example.com', NOW());

-- 3. 活动表测试数据
INSERT INTO `huodong` (`huodong_name`, `huodong_leixing`, `huodong_time`, `huodong_didian`, `huodong_jieshao`, `huodong_zhuangtai`, `click_time`, `create_time`) 
VALUES 
('校园文化节', '文化活动', '2024-05-01 09:00:00', '学校大礼堂', '一年一度的校园文化节，包含各种文艺表演和展览', '已发布', NOW(), NOW()),
('篮球友谊赛', '体育竞赛', '2024-05-15 14:00:00', '学校篮球场', '与兄弟院校的篮球友谊赛', '已发布', NOW(), NOW()),
('学术讲座', '学术活动', '2024-05-20 19:00:00', '图书馆报告厅', '邀请知名教授进行学术讲座', '已发布', NOW(), NOW());

-- 4. 活动报名表测试数据
INSERT INTO `huodong_order` (`huodong_id`, `huodong_name`, `yonghu_id`, `yonghu_name`, `yonghu_phone`, `huodong_time`, `create_time`) 
VALUES 
(1, '校园文化节', 1, 'test_user1', '13800138001', '2024-05-01 09:00:00', NOW()),
(2, '篮球友谊赛', 2, 'test_user2', '13800138002', '2024-05-15 14:00:00', NOW());

-- 5. 二手物品表测试数据
INSERT INTO `wupin` (`wupin_name`, `wupin_leixing`, `wupin_chengse`, `wupin_jiage`, `wupin_miaoshu`, `wupin_zhuangtai`, `yonghu_id`, `yonghu_name`, `yonghu_phone`, `create_time`) 
VALUES 
('二手教材', '书籍', '9 成新', 30.00, '计算机专业教材，几乎全新', '在售', 1, 'test_user1', '13800138001', NOW()),
('自行车', '交通工具', '8 成新', 200.00, '普通自行车，可正常骑行', '在售', 2, 'test_user2', '13800138002', NOW()),
('台灯', '生活用品', '95 成新', 50.00, 'LED 护眼台灯', '在售', 3, 'test_user3', '13800138003', NOW());

-- 6. 失物招领表测试数据
INSERT INTO `xunwu` (`wupin_name`, `wupin_leixing`, `wupin_yanse`, `wupin_didian`, `wupin_miaoshu`, `wupin_zhuangtai`, `yonghu_id`, `yonghu_name`, `yonghu_phone`, `create_time`) 
VALUES 
('黑色钱包', '证件财物', '黑色', '食堂一楼', '内有身份证和银行卡', '未认领', 1, 'test_user1', '13800138001', NOW()),
('蓝色雨伞', '生活用品', '蓝色', '图书馆门口', '折叠雨伞，蓝色格子图案', '未认领', 2, 'test_user2', '13800138002', NOW());

-- 7. 论坛帖子表测试数据
INSERT INTO `forum` (`forum_name`, `yonghu_id`, `yonghu_name`, `forum_content`, `forum_state`, `create_time`) 
VALUES 
('新生报到指南', 1, 'test_user1', '各位新生大家好，这里是一份详细的报到指南...', '公开', NOW()),
('图书馆占座问题', 2, 'test_user2', '最近图书馆占座现象严重，希望学校能加强管理...', '公开', NOW()),
('食堂菜品建议', 3, 'test_user3', '希望食堂能增加一些清淡的菜品选择...', '公开', NOW());

-- 8. 收藏表测试数据（活动收藏）
INSERT INTO `huodong_collection` (`huodong_id`, `yonghu_id`, `type`, `create_time`) 
VALUES 
(1, 1, 1, NOW()),
(2, 2, 1, NOW());

-- 9. 收藏表测试数据（物品收藏）
INSERT INTO `wupin_collection` (`wupin_id`, `yonghu_id`, `type`, `create_time`) 
VALUES 
(1, 1, 1, NOW()),
(2, 2, 1, NOW());

-- 10. 收藏表测试数据（心理咨询师收藏）
INSERT INTO `xinlizixunshi_collection` (`xinlizixunshi_id`, `yonghu_id`, `type`, `create_time`) 
VALUES 
(1, 1, 1, NOW());

-- 11. 收藏表测试数据（失物招领收藏）
INSERT INTO `xunwu_collection` (`xunwu_id`, `yonghu_id`, `type`, `create_time`) 
VALUES 
(1, 1, 1, NOW());

-- 12. 留言表测试数据（活动留言）
INSERT INTO `huodong_liuyan` (`huodong_id`, `yonghu_id`, `yonghu_name`, `liuyan_content`, `reply_content`, `create_time`) 
VALUES 
(1, 1, 'test_user1', '活动很精彩，期待参加！', '感谢您的支持！', NOW());

-- 13. 留言表测试数据（物品留言）
INSERT INTO `wupin_liuyan` (`wupin_id`, `yonghu_id`, `yonghu_name`, `liuyan_content`, `reply_content`, `create_time`) 
VALUES 
(1, 2, 'test_user2', '这个教材还在吗？想要购买。', '在的，可以联系我。', NOW());

-- 14. 留言表测试数据（心理咨询师留言）
INSERT INTO `xinlizixunshi_liuyan` (`xinlizixunshi_id`, `yonghu_id`, `yonghu_name`, `liuyan_content`, `reply_content`, `create_time`) 
VALUES 
(1, 1, 'test_user1', '老师您好，想预约咨询时间。', '您好，请添加微信详细沟通。', NOW());

-- 15. 留言表测试数据（失物招领留言）
INSERT INTO `xunwu_liuyan` (`xunwu_id`, `yonghu_id`, `yonghu_name`, `liuyan_content`, `reply_content`, `create_time`) 
VALUES 
(1, 2, 'test_user2', '这个钱包我好像看到了，在食堂门口。', '谢谢您的线索！', NOW());

-- 16. 聊天记录表测试数据
INSERT INTO `chat` (`yonghu_id`, `xinlizixunshi_id`, `content`, `is_reply`, `create_time`) 
VALUES 
(1, 1, '老师您好，我最近压力很大。', 0, NOW()),
(1, 1, '您好，请详细说说您的情况。', 1, NOW());

-- 17. 字典表测试数据
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `codeword`, `super_id`, `create_time`) 
VALUES 
('huodong_leixing', '活动类型', 'whhd', 0, NOW()),
('huodong_leixing', '活动类型', 'tyjs', 0, NOW()),
('huodong_leixing', '活动类型', 'xshd', 0, NOW()),
('wupin_leixing', '物品类型', 'sjyj', 0, NOW()),
('wupin_leixing', '物品类型', 'shyj', 0, NOW()),
('wupin_leixing', '物品类型', 'dqcj', 0, NOW()),
('sex', '性别', 'nan', 0, NOW()),
('sex', '性别', 'nv', 0, NOW());

-- ============================================
-- 测试数据插入完成
-- ============================================