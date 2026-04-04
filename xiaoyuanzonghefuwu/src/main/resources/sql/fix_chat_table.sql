-- ============================================
-- Chat 表结构修复脚本
-- 用于修复咨询记录管理功能的数据显示问题
-- 执行顺序：先执行此脚本，再执行 chat_test_data.sql
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- 1. 检查并添加 xinlizixunshi_id 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'xinlizixunshi_id');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `xinlizixunshi_id` int(11) DEFAULT NULL COMMENT ''心理咨询师 ID'' AFTER `users_id`',
    'SELECT ''xinlizixunshi_id column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. 检查并添加 chat_issue 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'chat_issue');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `chat_issue` text COMMENT ''用户问题'' AFTER `xinlizixunshi_id`',
    'SELECT ''chat_issue column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. 检查并添加 issue_time 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'issue_time');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `issue_time` datetime DEFAULT NULL COMMENT ''问题时间'' AFTER `chat_issue`',
    'SELECT ''issue_time column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. 检查并添加 chat_reply 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'chat_reply');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `chat_reply` text COMMENT ''回复内容'' AFTER `issue_time`',
    'SELECT ''chat_reply column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 5. 检查并添加 reply_time 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'reply_time');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `reply_time` datetime DEFAULT NULL COMMENT ''回复时间'' AFTER `chat_reply`',
    'SELECT ''reply_time column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 6. 检查并添加 zhuangtai_types 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'zhuangtai_types');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `zhuangtai_types` int(11) DEFAULT 0 COMMENT ''状态 (0:待回复 1:已回复)'' AFTER `reply_time`',
    'SELECT ''zhuangtai_types column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 7. 检查并添加 chat_types 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'chat_types');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `chat_types` int(11) DEFAULT 0 COMMENT ''数据类型 (1:用户发送 2:管理员/咨询师回复)'' AFTER `zhuangtai_types`',
    'SELECT ''chat_types column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 8. 检查并添加 insert_time 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'insert_time');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `insert_time` datetime DEFAULT NULL COMMENT ''聊天时间'' AFTER `chat_types`',
    'SELECT ''insert_time column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 9. 检查并添加 create_time 列（如果不存在）
SET @exist_col := (SELECT COUNT(*) FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND COLUMN_NAME = 'create_time');

SET @sql := IF(@exist_col = 0,
    'ALTER TABLE `chat` ADD COLUMN `create_time` datetime DEFAULT NULL COMMENT ''创建时间'' AFTER `insert_time`',
    'SELECT ''create_time column already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 10. 添加 xinlizixunshi_id 索引（如果不存在）
SET @exist_idx := (SELECT COUNT(*) FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = 'xiaoyuanzonghefuwu'
    AND TABLE_NAME = 'chat'
    AND INDEX_NAME = 'xinlizixunshi_id');

SET @sql := IF(@exist_idx = 0,
    'ALTER TABLE `chat` ADD INDEX `xinlizixunshi_id` (`xinlizixunshi_id`)',
    'SELECT ''xinlizixunshi_id index already exists''');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 11. 显示修复后的表结构
SELECT 'Chat 表结构修复完成，当前结构：' as info;
DESCRIBE chat;

-- 12. 显示当前数据量
SELECT CONCAT('当前 chat 表共有 ', COUNT(*), ' 条记录') as info FROM chat;