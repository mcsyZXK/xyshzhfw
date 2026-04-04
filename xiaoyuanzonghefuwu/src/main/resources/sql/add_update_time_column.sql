-- ============================================
-- 修复心理咨询师留言表 - 添加 update_time 字段
-- 日期：2026-03-05
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- 直接添加 update_time 字段（忽略已存在的情况）
ALTER TABLE `xinlizixunshi_liuyan` ADD COLUMN `update_time` datetime DEFAULT NULL COMMENT '修改时间' AFTER `insert_time`;

ALTER TABLE `huodong_liuyan` ADD COLUMN `update_time` datetime DEFAULT NULL COMMENT '修改时间' AFTER `insert_time`;

ALTER TABLE `wupin_liuyan` ADD COLUMN `update_time` datetime DEFAULT NULL COMMENT '修改时间' AFTER `insert_time`;

ALTER TABLE `xunwu_liuyan` ADD COLUMN `update_time` datetime DEFAULT NULL COMMENT '修改时间' AFTER `insert_time`;