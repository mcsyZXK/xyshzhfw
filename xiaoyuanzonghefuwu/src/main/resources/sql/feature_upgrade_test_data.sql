-- ============================================================
-- Feature Upgrade Test Data
-- Scope:
-- 1) Second-hand item publish + image display
-- 2) Forum post/reply with image tokens
-- ============================================================

USE `xiaoyuanzonghefuwu`;

START TRANSACTION;

-- Clean old feature-test data (re-runnable)
DELETE FROM `forum` WHERE `forum_name` LIKE '[FG]%' OR `forum_content` LIKE '[FG]%';
DELETE FROM `wupin` WHERE `wupin_name` LIKE '[FG]%';
DELETE FROM `token` WHERE `username` = 'fg_user01';
DELETE FROM `yonghu` WHERE `username` = 'fg_user01';

-- Seed one test user
INSERT INTO `yonghu` (
  `username`, `password`, `yonghu_name`, `yonghu_phone`, `yonghu_id_number`,
  `sex_types`, `yonghu_email`, `role`, `create_time`
) VALUES (
  'fg_user01', '123456', '功能测试用户', '13800138001', '320101199901010011',
  1, 'fg_user01@example.com', '用户', NOW()
);

SET @fg_uid := (SELECT `id` FROM `yonghu` WHERE `username`='fg_user01' LIMIT 1);

-- Seed one second-hand item with image
INSERT INTO `wupin` (
  `yonghu_id`, `wupin_name`, `wupin_photo`, `wupin_address`, `lianxiren_name`, `lianxiren_phone`,
  `wupin_types`, `wupin_number`, `wupin_maichu_types`,
  `wupin_old_money`, `wupin_new_money`, `wupin_content`, `wupin_delete`, `insert_time`, `create_time`
) VALUES (
  @fg_uid, '[FG] 种子物品-测试键盘', '/upload/fg_seed_wupin.jpg', '二食堂门口', '功能测试用户', '13800138001',
  2, 1, 1,
  299.00, 129.00, '[FG] 用于验证图片展示链路', 1, NOW(), NOW()
);

-- Seed one forum top post with two image tokens
INSERT INTO `forum` (
  `forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`,
  `forum_content`, `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `create_time`
) VALUES (
  '[FG] 图文主贴-期中复习',
  @fg_uid, NULL, NULL,
  '[FG] 这周冲刺计划\n[img]/upload/fg_seed_forum_1.jpg\n[img]/upload/fg_seed_forum_2.jpg',
  0, 1, 0, NOW(), NOW()
);

SET @fg_forum_id := (SELECT `id` FROM `forum` WHERE `forum_name`='[FG] 图文主贴-期中复习' LIMIT 1);

-- Seed one reply with image token
INSERT INTO `forum` (
  `forum_name`, `yonghu_id`, `xinlizixunshi_id`, `users_id`,
  `forum_content`, `super_ids`, `forum_types`, `forum_state_types`, `insert_time`, `create_time`
) VALUES (
  '[FG] 图文回复-学习法',
  @fg_uid, NULL, NULL,
  '[FG] 我用番茄钟\n[img]/upload/fg_seed_reply_1.jpg',
  @fg_forum_id, 1, 0, NOW(), NOW()
);

COMMIT;

-- Quick check
SELECT 'FG users' AS `item`, COUNT(*) AS `cnt` FROM `yonghu` WHERE `username`='fg_user01'
UNION ALL SELECT 'FG wupin', COUNT(*) FROM `wupin` WHERE `wupin_name` LIKE '[FG]%'
UNION ALL SELECT 'FG forum rows', COUNT(*) FROM `forum` WHERE `forum_name` LIKE '[FG]%';
