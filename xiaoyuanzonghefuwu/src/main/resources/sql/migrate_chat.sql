-- ============================================
-- Chat 表结构迁移脚本
-- 用于添加缺失的列
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- 添加 chat_issue 列
ALTER TABLE `chat` ADD COLUMN `chat_issue` text COMMENT '用户问题' AFTER `users_id`;

-- 添加 issue_time 列
ALTER TABLE `chat` ADD COLUMN `issue_time` datetime DEFAULT NULL COMMENT '问题时间' AFTER `chat_issue`;

-- 添加 chat_reply 列
ALTER TABLE `chat` ADD COLUMN `chat_reply` text COMMENT '回复内容' AFTER `issue_time`;

-- 添加 reply_time 列
ALTER TABLE `chat` ADD COLUMN `reply_time` datetime DEFAULT NULL COMMENT '回复时间' AFTER `chat_reply`;

-- 添加 zhuangtai_types 列
ALTER TABLE `chat` ADD COLUMN `zhuangtai_types` int(11) DEFAULT '0' COMMENT '状态 (0:待回复 1:已回复 2:已处理)' AFTER `chat_reply`;