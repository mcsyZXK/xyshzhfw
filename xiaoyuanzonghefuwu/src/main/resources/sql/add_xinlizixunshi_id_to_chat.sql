-- ============================================
-- Chat 表添加心理咨询师 ID 字段
-- 用于支持心理咨询师查看咨询记录
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- 添加 xinlizixunshi_id 列
ALTER TABLE `chat` ADD COLUMN `xinlizixunshi_id` int(11) DEFAULT NULL COMMENT '心理咨询师 ID' AFTER `users_id`;

-- 添加索引
ALTER TABLE `chat` ADD INDEX `xinlizixunshi_id` (`xinlizixunshi_id`);

-- 添加外键约束（可选）
-- ALTER TABLE `chat` ADD CONSTRAINT `chat_xinlizixunshi_fk` FOREIGN KEY (`xinlizixunshi_id`) REFERENCES `xinlizixunshi`(`id`);