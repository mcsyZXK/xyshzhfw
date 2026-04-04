-- ============================================================
-- Hardcode Refactor Test Data
-- Purpose:
-- 1) Admin dashboard real API data (stats/rank/trend)
-- 2) Forum detail replies via API
-- 3) Chat page messages via API
-- 4) Huodong/Wupin/Xunwu comment APIs
-- ============================================================

USE `xiaoyuanzonghefuwu`;

-- ------------------------------------------------------------
-- Schema compatibility for chat (older dbs may miss these cols)
-- ------------------------------------------------------------
SET @db_name := DATABASE();

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'xinlizixunshi_id');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `xinlizixunshi_id` int(11) DEFAULT NULL COMMENT ''心理咨询师 ID'' AFTER `users_id`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'chat_issue');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `chat_issue` text COMMENT ''用户问题'' AFTER `xinlizixunshi_id`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'issue_time');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `issue_time` datetime DEFAULT NULL COMMENT ''问题时间'' AFTER `chat_issue`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'chat_reply');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `chat_reply` text COMMENT ''回复内容'' AFTER `issue_time`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'reply_time');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `reply_time` datetime DEFAULT NULL COMMENT ''回复时间'' AFTER `chat_reply`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'zhuangtai_types');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `zhuangtai_types` int(11) DEFAULT 0 COMMENT ''状态'' AFTER `reply_time`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = @db_name AND TABLE_NAME = 'chat' AND COLUMN_NAME = 'chat_types');
SET @sql := IF(@exist_col = 0,
  'ALTER TABLE `chat` ADD COLUMN `chat_types` int(11) DEFAULT 0 COMMENT ''聊天类型'' AFTER `zhuangtai_types`',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

START TRANSACTION;

-- ------------------------------------------------------------
-- 0) Cleanup old HC test data (re-runnable)
-- ------------------------------------------------------------
DELETE FROM `huodong_liuyan` WHERE `huodong_liuyan_text` LIKE '[HC]%' OR `reply_text` LIKE '[HC]%';
DELETE FROM `wupin_liuyan`   WHERE `wupin_liuyan_text`   LIKE '[HC]%' OR `reply_text` LIKE '[HC]%';
DELETE FROM `xunwu_liuyan`   WHERE `xunwu_liuyan_text`   LIKE '[HC]%' OR `reply_text` LIKE '[HC]%';

DELETE FROM `huodong_order` WHERE `huodong_order_text` LIKE '[HC]%';

DELETE FROM `forum` WHERE `forum_name` LIKE '[HC]%' OR `forum_content` LIKE '[HC]%';
DELETE FROM `chat`  WHERE `chat_issue` LIKE '[HC]%' OR `chat_reply` LIKE '[HC]%';

DELETE FROM `huodong` WHERE `huodong_uuid_number` LIKE 'HC-HD-%';
DELETE FROM `wupin`   WHERE `wupin_name` LIKE '[HC]%';
DELETE FROM `xunwu`   WHERE `xunwu_name` LIKE '[HC]%';

DELETE FROM `yonghu`         WHERE `username` LIKE 'hc_user%';
DELETE FROM `xinlizixunshi`  WHERE `username` LIKE 'hc_counselor%';

-- ------------------------------------------------------------
-- 1) Users and counselor (for count + 7-day user trend + relations)
-- ------------------------------------------------------------
INSERT INTO `yonghu` (
  `username`, `password`, `yonghu_name`, `yonghu_phone`, `yonghu_email`, `role`, `create_time`
) VALUES
('hc_user01', '123456', '硬测用户01', '13800010001', 'hc01@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY), '09:00:00')),
('hc_user02', '123456', '硬测用户02', '13800010002', 'hc02@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY), '10:00:00')),
('hc_user03', '123456', '硬测用户03', '13800010003', 'hc03@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY), '15:00:00')),
('hc_user04', '123456', '硬测用户04', '13800010004', 'hc04@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY), '11:00:00')),
('hc_user05', '123456', '硬测用户05', '13800010005', 'hc05@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '14:00:00')),
('hc_user06', '123456', '硬测用户06', '13800010006', 'hc06@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '16:00:00')),
('hc_user07', '123456', '硬测用户07', '13800010007', 'hc07@example.com', '用户', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '13:00:00')),
('hc_user08', '123456', '硬测用户08', '13800010008', 'hc08@example.com', '用户', TIMESTAMP(CURDATE(), '08:30:00'));

INSERT INTO `xinlizixunshi` (
  `username`, `password`, `xinlizixunshi_name`, `xinlizixunshi_phone`, `xinlizixunshi_email`, `role`, `create_time`
) VALUES
('hc_counselor01', '123456', '硬测咨询师01', '13900010001', 'hc_c01@example.com', '心理咨询师', NOW());

SET @u1 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user01' LIMIT 1);
SET @u2 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user02' LIMIT 1);
SET @u3 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user03' LIMIT 1);
SET @u4 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user04' LIMIT 1);
SET @u5 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user05' LIMIT 1);
SET @u6 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user06' LIMIT 1);
SET @u7 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user07' LIMIT 1);
SET @u8 := (SELECT `id` FROM `yonghu` WHERE `username`='hc_user08' LIMIT 1);
SET @c1 := (SELECT `id` FROM `xinlizixunshi` WHERE `username`='hc_counselor01' LIMIT 1);

-- ------------------------------------------------------------
-- 2) Huodong + huodong_order (for stats/hot rank/7-day order trend)
-- ------------------------------------------------------------
INSERT INTO `huodong` (
  `huodong_uuid_number`, `huodong_name`, `huodong_photo`, `huodong_types`,
  `kaishi_time`, `jieshu_time`, `huodong_clicknum`, `huodong_content`,
  `huodong_delete`, `insert_time`, `create_time`
) VALUES
('HC-HD-001', '[HC] 春季简历急救夜', '/upload/hc_hd_1.jpg', 4, DATE_ADD(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR, 520, '[HC] 就业中心现场改简历。', 1, NOW(), NOW()),
('HC-HD-002', '[HC] 期中自救复盘会', '/upload/hc_hd_2.jpg', 1, DATE_ADD(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 3 DAY) + INTERVAL 2 HOUR, 410, '[HC] 学长分享提分打法。', 1, NOW(), NOW()),
('HC-HD-003', '[HC] 宿舍厨艺翻车赛', '/upload/hc_hd_3.jpg', 2, DATE_ADD(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL 4 DAY) + INTERVAL 3 HOUR, 280, '[HC] 允许失败，禁止浪费。', 1, NOW(), NOW()),
('HC-HD-004', '[HC] 清晨操场打卡跑', '/upload/hc_hd_4.jpg', 4, DATE_ADD(NOW(), INTERVAL 1 DAY), DATE_ADD(NOW(), INTERVAL 1 DAY) + INTERVAL 1 HOUR, 190, '[HC] 连续 7 天签到挑战。', 1, NOW(), NOW()),
('HC-HD-005', '[HC] 图书馆摸鱼互助群', '/upload/hc_hd_5.jpg', 3, DATE_ADD(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL 5 DAY) + INTERVAL 2 HOUR, 95, '[HC] 一起自习互相监督。', 1, NOW(), NOW());

SET @hd1 := (SELECT `id` FROM `huodong` WHERE `huodong_uuid_number`='HC-HD-001' LIMIT 1);
SET @hd2 := (SELECT `id` FROM `huodong` WHERE `huodong_uuid_number`='HC-HD-002' LIMIT 1);
SET @hd3 := (SELECT `id` FROM `huodong` WHERE `huodong_uuid_number`='HC-HD-003' LIMIT 1);
SET @hd4 := (SELECT `id` FROM `huodong` WHERE `huodong_uuid_number`='HC-HD-004' LIMIT 1);
SET @hd5 := (SELECT `id` FROM `huodong` WHERE `huodong_uuid_number`='HC-HD-005' LIMIT 1);

INSERT INTO `huodong_order` (`huodong_id`, `yonghu_id`, `huodong_order_text`, `insert_time`, `create_time`) VALUES
(@hd1, @u1, '[HC] D-6 报名', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY), '09:10:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY), '09:10:00')),
(@hd2, @u2, '[HC] D-5 报名-A', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY), '10:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY), '10:00:00')),
(@hd2, @u3, '[HC] D-5 报名-B', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY), '20:30:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY), '20:30:00')),
(@hd3, @u4, '[HC] D-4 报名', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY), '15:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY), '15:00:00')),
(@hd1, @u5, '[HC] D-3 报名-A', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '11:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '11:00:00')),
(@hd4, @u6, '[HC] D-3 报名-B', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '13:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '13:00:00')),
(@hd4, @u7, '[HC] D-3 报名-C', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '18:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY), '18:00:00')),
(@hd1, @u8, '[HC] D-2 报名', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:20:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:20:00')),
(@hd5, @u1, '[HC] D-1 报名-A', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '16:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '16:00:00')),
(@hd5, @u2, '[HC] D-1 报名-B', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '20:00:00'), TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '20:00:00')),
(@hd3, @u3, '[HC] D-0 报名', TIMESTAMP(CURDATE(), '10:10:00'), TIMESTAMP(CURDATE(), '10:10:00'));

-- ------------------------------------------------------------
-- 3) Wupin + Xunwu (for stats and detail pages)
-- ------------------------------------------------------------
INSERT INTO `wupin` (
  `yonghu_id`, `wupin_name`, `wupin_photo`, `wupin_address`, `lianxiren_name`, `lianxiren_phone`,
  `wupin_types`, `wupin_number`, `wupin_maichu_types`, `wupin_old_money`, `wupin_new_money`,
  `wupin_content`, `wupin_delete`, `insert_time`, `create_time`
) VALUES
(@u1, '[HC] 二手线代教材', '/upload/hc_wp_1.jpg', '一食门口', '硬测用户01', '13800010001', 1, 1, 1, 56.00, 22.00, '[HC] 轻微划线。', 1, NOW(), NOW()),
(@u2, '[HC] 机械键盘 87 键', '/upload/hc_wp_2.jpg', '图书馆南门', '硬测用户02', '13800010002', 2, 1, 1, 249.00, 139.00, '[HC] 青轴，正常使用。', 1, NOW(), NOW()),
(@u3, '[HC] 羽毛球拍套装', '/upload/hc_wp_3.jpg', '体育馆旁', '硬测用户03', '13800010003', 4, 1, 1, 199.00, 88.00, '[HC] 含拍套和 6 个球。', 1, NOW(), NOW());

INSERT INTO `xunwu` (
  `yonghu_id`, `xunwu_name`, `xunwu_photo`, `lianxiren_name`, `lianxiren_phone`,
  `xunwu_types`, `xunwu_zhuangtai_types`, `diushi_time`, `diushi_address`, `diushi_tezheng`,
  `xunwu_content`, `xunwu_delete`, `insert_time`, `create_time`
) VALUES
(@u4, '[HC] 黑色工牌卡套', '/upload/hc_xw_1.jpg', '硬测用户04', '13800010004', 1, 0, DATE_SUB(NOW(), INTERVAL 2 DAY), '教学楼 A', '卡套边角磨损', '[HC] 工牌和门禁卡一起丢了。', 1, NOW(), NOW()),
(@u5, '[HC] 银色保温杯', '/upload/hc_xw_2.jpg', '硬测用户05', '13800010005', 2, 0, DATE_SUB(NOW(), INTERVAL 1 DAY), '图书馆二楼', '杯底贴着名字缩写', '[HC] 捡到保温杯，认领请私聊。', 1, NOW(), NOW()),
(@u6, '[HC] 无线耳机充电盒', '/upload/hc_xw_3.jpg', '硬测用户06', '13800010006', 1, 0, DATE_SUB(NOW(), INTERVAL 3 DAY), '操场看台', '白色壳体有裂纹', '[HC] 只有充电盒，没有耳机本体。', 1, NOW(), NOW());

SET @wp1 := (SELECT `id` FROM `wupin` WHERE `wupin_name`='[HC] 二手线代教材' LIMIT 1);
SET @wp2 := (SELECT `id` FROM `wupin` WHERE `wupin_name`='[HC] 机械键盘 87 键' LIMIT 1);
SET @wp3 := (SELECT `id` FROM `wupin` WHERE `wupin_name`='[HC] 羽毛球拍套装' LIMIT 1);

SET @xw1 := (SELECT `id` FROM `xunwu` WHERE `xunwu_name`='[HC] 黑色工牌卡套' LIMIT 1);
SET @xw2 := (SELECT `id` FROM `xunwu` WHERE `xunwu_name`='[HC] 银色保温杯' LIMIT 1);
SET @xw3 := (SELECT `id` FROM `xunwu` WHERE `xunwu_name`='[HC] 无线耳机充电盒' LIMIT 1);

-- ------------------------------------------------------------
-- 4) Forum posts + replies (for rank + forum detail reply API)
-- ------------------------------------------------------------
INSERT INTO `forum` (
  `forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`, `forum_content`,
  `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `create_time`
) VALUES
('[HC] 求助：复习周怎么排课', @u1, NULL, NULL, '[HC] 三门课都快考试了，谁有排期模板？', 0, 1, 0, NOW(), NOW()),
('[HC] 吐槽：食堂夜宵排队太久', @u2, NULL, NULL, '[HC] 昨晚排了 40 分钟，差点错过门禁。', 0, 1, 0, NOW(), NOW()),
('[HC] 分享：一周自习打卡表', @u3, NULL, NULL, '[HC] 我做了个轻量打卡表，欢迎抄作业。', 0, 1, 0, NOW(), NOW());

SET @fp1 := (SELECT `id` FROM `forum` WHERE `forum_name`='[HC] 求助：复习周怎么排课' LIMIT 1);
SET @fp2 := (SELECT `id` FROM `forum` WHERE `forum_name`='[HC] 吐槽：食堂夜宵排队太久' LIMIT 1);
SET @fp3 := (SELECT `id` FROM `forum` WHERE `forum_name`='[HC] 分享：一周自习打卡表' LIMIT 1);

INSERT INTO `forum` (
  `forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`, `forum_content`,
  `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `create_time`
) VALUES
('[HC] Re: 复习周排课-A', @u4, NULL, NULL, '[HC] 先做最怕的那门课，晚上回顾错题。', @fp1, 1, 0, NOW(), NOW()),
('[HC] Re: 复习周排课-B', @u5, NULL, NULL, '[HC] 我用 50/10 节奏，效率稳定。', @fp1, 1, 0, NOW(), NOW()),
('[HC] Re: 复习周排课-C', @u6, NULL, NULL, '[HC] 早起背书，下午刷题，晚上总结。', @fp1, 1, 0, NOW(), NOW()),
('[HC] Re: 复习周排课-D', NULL, @c1, NULL, '[HC] 焦虑时先降目标，保证睡眠优先。', @fp1, 1, 0, NOW(), NOW()),
('[HC] Re: 夜宵排队-A', @u7, NULL, NULL, '[HC] 22:10 去会快很多。', @fp2, 1, 0, NOW(), NOW()),
('[HC] Re: 夜宵排队-B', @u8, NULL, NULL, '[HC] 可以拼单外卖，节省时间。', @fp2, 1, 0, NOW(), NOW()),
('[HC] Re: 自习打卡表-A', @u2, NULL, NULL, '[HC] 模板收到，已开搞。', @fp3, 1, 0, NOW(), NOW());

-- ------------------------------------------------------------
-- 5) Liuyan data for detail pages (API list/save)
-- ------------------------------------------------------------
INSERT INTO `huodong_liuyan` (
  `huodong_id`, `yonghu_id`, `huodong_liuyan_text`, `reply_text`, `insert_time`, `create_time`
) VALUES
(@hd1, @u2, '[HC] 这场活动需要自带简历吗？', '[HC] 建议带 3 份纸质简历。', NOW(), NOW()),
(@hd1, @u3, '[HC] 可以现场改简历吗？', '[HC] 可以，现场有老师。', NOW(), NOW()),
(@hd2, @u4, '[HC] 讲座会发回放吗？', '[HC] 会在群里发摘要。', NOW(), NOW());

INSERT INTO `wupin_liuyan` (
  `wupin_id`, `yonghu_id`, `wupin_liuyan_text`, `reply_text`, `insert_time`, `create_time`
) VALUES
(@wp1, @u4, '[HC] 教材有缺页吗？', '[HC] 没有缺页。', NOW(), NOW()),
(@wp2, @u5, '[HC] 键帽全套都在吗？', '[HC] 全套都在。', NOW(), NOW()),
(@wp3, @u6, '[HC] 可以当面试拍吗？', '[HC] 可以，晚饭后都行。', NOW(), NOW());

INSERT INTO `xunwu_liuyan` (
  `xunwu_id`, `yonghu_id`, `xunwu_liuyan_text`, `reply_text`, `insert_time`, `create_time`
) VALUES
(@xw1, @u7, '[HC] 我在 B 栋看到过类似卡套。', '[HC] 收到，我去找找。', NOW(), NOW()),
(@xw2, @u8, '[HC] 我可能知道失主班级。', '[HC] 太感谢了，私聊我。', NOW(), NOW()),
(@xw3, @u1, '[HC] 充电盒有刻字吗？', '[HC] 没有刻字。', NOW(), NOW());

-- ------------------------------------------------------------
-- 6) Chat data (API read/send)
-- ------------------------------------------------------------
INSERT INTO `chat` (
  `yonghu_id`, `users_id`, `xinlizixunshi_id`,
  `chat_issue`, `issue_time`,
  `chat_reply`, `reply_time`,
  `zhuangtai_types`, `chat_types`, `insert_time`, `create_time`
) VALUES
(@u1, NULL, @c1, '[HC] 老师，我最近总是拖延。', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:00:00'), NULL, NULL, 0, 1, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:00:00'), NOW()),
(@u1, NULL, @c1, NULL, NULL, '[HC] 先把任务切到 15 分钟一段。', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:06:00'), 1, 2, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:06:00'), NOW()),
(@u1, NULL, @c1, '[HC] 我怕坚持不了。', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:12:00'), NULL, NULL, 0, 1, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:12:00'), NOW()),
(@u1, NULL, @c1, NULL, NULL, '[HC] 先坚持 3 天，再谈长期。', TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:18:00'), 1, 2, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY), '09:18:00'), NOW()),
(@u2, NULL, @c1, '[HC] 期中前失眠怎么办？', TIMESTAMP(CURDATE(), '08:40:00'), NULL, NULL, 0, 1, TIMESTAMP(CURDATE(), '08:40:00'), NOW()),
(@u2, NULL, @c1, NULL, NULL, '[HC] 睡前 1 小时别刷屏，做 5 分钟呼吸。', TIMESTAMP(CURDATE(), '08:45:00'), 1, 2, TIMESTAMP(CURDATE(), '08:45:00'), NOW());

COMMIT;

-- ------------------------------------------------------------
-- 7) Quick check
-- ------------------------------------------------------------
SELECT 'HC users' AS `item`, COUNT(*) AS `cnt` FROM `yonghu` WHERE `username` LIKE 'hc_user%'
UNION ALL SELECT 'HC counselors', COUNT(*) FROM `xinlizixunshi` WHERE `username` LIKE 'hc_counselor%'
UNION ALL SELECT 'HC activities', COUNT(*) FROM `huodong` WHERE `huodong_uuid_number` LIKE 'HC-HD-%'
UNION ALL SELECT 'HC orders', COUNT(*) FROM `huodong_order` WHERE `huodong_order_text` LIKE '[HC]%'
UNION ALL SELECT 'HC forum rows', COUNT(*) FROM `forum` WHERE `forum_name` LIKE '[HC]%'
UNION ALL SELECT 'HC chat rows', COUNT(*) FROM `chat` WHERE `chat_issue` LIKE '[HC]%' OR `chat_reply` LIKE '[HC]%'
UNION ALL SELECT 'HC huodong comments', COUNT(*) FROM `huodong_liuyan` WHERE `huodong_liuyan_text` LIKE '[HC]%'
UNION ALL SELECT 'HC wupin comments', COUNT(*) FROM `wupin_liuyan` WHERE `wupin_liuyan_text` LIKE '[HC]%'
UNION ALL SELECT 'HC xunwu comments', COUNT(*) FROM `xunwu_liuyan` WHERE `xunwu_liuyan_text` LIKE '[HC]%';
