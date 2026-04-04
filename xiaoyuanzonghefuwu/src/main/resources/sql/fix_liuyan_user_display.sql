-- ============================================
-- 留言模块用户显示修复脚本
-- 作用：
-- 1) 修复 yonghu 表中姓名为空的数据，避免前端“用户”列空白
-- 2) 补齐 xinlizixunshi_liuyan 引用但 yonghu 表不存在的用户
-- ============================================

USE `xiaoyuanzonghefuwu`;

-- 1. 把用户名为空的记录回填为账号（username）
UPDATE `yonghu`
SET `yonghu_name` = `username`
WHERE (`yonghu_name` IS NULL OR TRIM(`yonghu_name`) = '')
  AND `username` IS NOT NULL
  AND TRIM(`username`) <> '';

-- 2. 对留言表里引用到但 yonghu 表不存在的用户，自动补一条用户数据
-- 注意：会保留原 yonghu_id，便于和历史留言对应
INSERT INTO `yonghu` (`id`, `username`, `password`, `yonghu_name`, `role`, `create_time`)
SELECT
  refs.`yonghu_id` AS `id`,
  CONCAT('repair_user_', refs.`yonghu_id`) AS `username`,
  'user123' AS `password`,
  CONCAT('用户', refs.`yonghu_id`) AS `yonghu_name`,
  '用户' AS `role`,
  NOW() AS `create_time`
FROM (
  SELECT DISTINCT `yonghu_id`
  FROM `xinlizixunshi_liuyan`
  WHERE `yonghu_id` IS NOT NULL
) refs
LEFT JOIN `yonghu` y ON y.`id` = refs.`yonghu_id`
WHERE y.`id` IS NULL;

-- 3. 再兜底一次姓名，确保新插入或历史数据都可展示
UPDATE `yonghu`
SET `yonghu_name` = CONCAT('用户', `id`)
WHERE `yonghu_name` IS NULL OR TRIM(`yonghu_name`) = '';

-- 4. 可选检查：查看仍然无法关联用户名的留言（正常应为 0 条）
SELECT
  l.`id`,
  l.`yonghu_id`,
  y.`username`,
  y.`yonghu_name`,
  l.`xinlizixunshi_liuyan_text`
FROM `xinlizixunshi_liuyan` l
LEFT JOIN `yonghu` y ON y.`id` = l.`yonghu_id`
WHERE y.`id` IS NULL
   OR y.`yonghu_name` IS NULL
   OR TRIM(y.`yonghu_name`) = '';
