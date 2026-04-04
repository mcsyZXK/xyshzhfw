-- ============================================
-- 校园生活综合服务系统 - 数据库重构脚本
-- 版本：2.0
-- 日期：2026-03-05
-- 说明：密码采用明文存储，不使用 JWT 校验
-- ============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `xiaoyuanzonghefuwu` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `xiaoyuanzonghefuwu`;

-- ============================================
-- 1. 用户相关表
-- ============================================

-- 用户表
DROP TABLE IF EXISTS `yonghu`;
CREATE TABLE `yonghu` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '账号',
  `password` varchar(100) NOT NULL COMMENT '密码（明文）',
  `yonghu_name` varchar(50) DEFAULT NULL COMMENT '用户姓名',
  `yonghu_phone` varchar(20) DEFAULT NULL COMMENT '用户手机号',
  `yonghu_id_number` varchar(20) DEFAULT NULL COMMENT '用户身份证号',
  `yonghu_photo` varchar(255) DEFAULT NULL COMMENT '用户头像',
  `sex_types` int(11) DEFAULT '0' COMMENT '性别 (0:未知 1:男 2:女)',
  `yonghu_email` varchar(100) DEFAULT NULL COMMENT '电子邮箱',
  `role` varchar(20) DEFAULT '用户' COMMENT '角色',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 管理员表 (Users)
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '账号',
  `password` varchar(100) NOT NULL COMMENT '密码（明文）',
  `role` varchar(20) DEFAULT '管理员' COMMENT '角色',
  `addtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='管理员表';

-- Token 表（保留用于会话管理，但不使用 JWT）
DROP TABLE IF EXISTS `token`;
CREATE TABLE `token` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `userid` bigint(20) NOT NULL COMMENT '用户 ID',
  `username` varchar(100) NOT NULL COMMENT '账号',
  `tablename` varchar(50) DEFAULT NULL COMMENT '表名',
  `role` varchar(20) DEFAULT NULL COMMENT '角色',
  `token` varchar(200) NOT NULL COMMENT '令牌',
  `expiratedtime` datetime DEFAULT NULL COMMENT '过期时间',
  `addtime` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Token 表';

-- ============================================
-- 2. 字典表
-- ============================================

DROP TABLE IF EXISTS `dictionary`;
CREATE TABLE `dictionary` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dic_code` varchar(50) NOT NULL COMMENT '字段',
  `dic_name` varchar(100) NOT NULL COMMENT '字段名',
  `code_index` int(11) NOT NULL COMMENT '编码',
  `index_name` varchar(50) NOT NULL COMMENT '编码名字',
  `super_id` int(11) DEFAULT '0' COMMENT '父字段 id',
  `beizhu` varchar(100) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典表';

-- ============================================
-- 3. 活动管理模块
-- ============================================

DROP TABLE IF EXISTS `huodong`;
CREATE TABLE `huodong` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `huodong_uuid_number` varchar(50) NOT NULL COMMENT '活动编号',
  `huodong_name` varchar(100) NOT NULL COMMENT '活动名称',
  `huodong_photo` varchar(255) DEFAULT NULL COMMENT '活动照片',
  `huodong_types` int(11) DEFAULT '0' COMMENT '活动类型',
  `kaishi_time` datetime DEFAULT NULL COMMENT '活动开始日期',
  `jieshu_time` datetime DEFAULT NULL COMMENT '活动结束日期',
  `huodong_clicknum` int(11) DEFAULT '0' COMMENT '热度',
  `huodong_content` text COMMENT '活动介绍',
  `huodong_delete` int(11) DEFAULT '1' COMMENT '逻辑删除 (1:存在 2:删除)',
  `insert_time` datetime DEFAULT NULL COMMENT '发布时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `huodong_uuid_number` (`huodong_uuid_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动表';

-- 活动报名表
DROP TABLE IF EXISTS `huodong_order`;
CREATE TABLE `huodong_order` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `huodong_id` int(11) NOT NULL COMMENT '活动 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `huodong_order_text` varchar(255) DEFAULT NULL COMMENT '备注',
  `insert_time` datetime DEFAULT NULL COMMENT '报名时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `huodong_id` (`huodong_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动报名表';

-- 活动收藏表
DROP TABLE IF EXISTS `huodong_collection`;
CREATE TABLE `huodong_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `huodong_id` int(11) NOT NULL COMMENT '活动 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `insert_time` datetime DEFAULT NULL COMMENT '收藏时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `huodong_id` (`huodong_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动收藏表';

-- 活动留言表
DROP TABLE IF EXISTS `huodong_liuyan`;
CREATE TABLE `huodong_liuyan` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `huodong_id` int(11) NOT NULL COMMENT '活动 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `huodong_liuyan_text` text NOT NULL COMMENT '留言内容',
  `reply_text` varchar(255) DEFAULT NULL COMMENT '回复内容',
  `insert_time` datetime DEFAULT NULL COMMENT '留言时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `huodong_id` (`huodong_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动留言表';

-- ============================================
-- 4. 二手物品交易模块
-- ============================================

DROP TABLE IF EXISTS `wupin`;
CREATE TABLE `wupin` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `wupin_name` varchar(100) NOT NULL COMMENT '物品名称',
  `wupin_photo` varchar(255) DEFAULT NULL COMMENT '物品照片',
  `wupin_address` varchar(255) DEFAULT NULL COMMENT '交易地点',
  `lianxiren_name` varchar(50) DEFAULT NULL COMMENT '联系人',
  `lianxiren_phone` varchar(20) DEFAULT NULL COMMENT '联系人电话',
  `wupin_types` int(11) DEFAULT '0' COMMENT '物品类型',
  `wupin_number` int(11) DEFAULT '1' COMMENT '物品数量',
  `wupin_maichu_types` int(11) DEFAULT '1' COMMENT '物品状态 (1:在售 2:已售)',
  `wupin_old_money` decimal(10,2) DEFAULT NULL COMMENT '物品购买价格',
  `wupin_new_money` decimal(10,2) DEFAULT NULL COMMENT '出售价格',
  `wupin_content` text COMMENT '物品介绍',
  `wupin_delete` int(11) DEFAULT '1' COMMENT '逻辑删除 (1:存在 2:删除)',
  `insert_time` datetime DEFAULT NULL COMMENT '发布时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二手物品表';

-- 二手物品收藏表
DROP TABLE IF EXISTS `wupin_collection`;
CREATE TABLE `wupin_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `wupin_id` int(11) NOT NULL COMMENT '物品 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `insert_time` datetime DEFAULT NULL COMMENT '收藏时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `wupin_id` (`wupin_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二手物品收藏表';

-- 二手物品留言表
DROP TABLE IF EXISTS `wupin_liuyan`;
CREATE TABLE `wupin_liuyan` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `wupin_id` int(11) NOT NULL COMMENT '物品 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `wupin_liuyan_text` text NOT NULL COMMENT '留言内容',
  `reply_text` varchar(255) DEFAULT NULL COMMENT '回复内容',
  `insert_time` datetime DEFAULT NULL COMMENT '留言时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `wupin_id` (`wupin_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二手物品留言表';

-- ============================================
-- 5. 失物招领模块
-- ============================================

DROP TABLE IF EXISTS `xunwu`;
CREATE TABLE `xunwu` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `xunwu_name` varchar(100) NOT NULL COMMENT '寻物名称',
  `xunwu_photo` varchar(255) DEFAULT NULL COMMENT '寻物照片',
  `lianxiren_name` varchar(50) DEFAULT NULL COMMENT '联系人',
  `lianxiren_phone` varchar(20) DEFAULT NULL COMMENT '联系人手机号',
  `xunwu_types` int(11) DEFAULT '0' COMMENT '寻物类型 (1:寻物 2:招领)',
  `xunwu_zhuangtai_types` int(11) DEFAULT '0' COMMENT '寻物状态 (0:未找到 1:已找到)',
  `diushi_time` datetime DEFAULT NULL COMMENT '丢失时间',
  `diushi_address` varchar(255) DEFAULT NULL COMMENT '丢失地点',
  `diushi_tezheng` varchar(255) DEFAULT NULL COMMENT '特征',
  `xunwu_content` text COMMENT '寻物详情',
  `xunwu_delete` int(11) DEFAULT '1' COMMENT '逻辑删除 (1:存在 2:删除)',
  `insert_time` datetime DEFAULT NULL COMMENT '发布时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='寻物表';

-- 失物招领收藏表
DROP TABLE IF EXISTS `xunwu_collection`;
CREATE TABLE `xunwu_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `xunwu_id` int(11) NOT NULL COMMENT '寻物 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `insert_time` datetime DEFAULT NULL COMMENT '收藏时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `xunwu_id` (`xunwu_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='失物招领收藏表';

-- 失物招领留言表
DROP TABLE IF EXISTS `xunwu_liuyan`;
CREATE TABLE `xunwu_liuyan` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `xunwu_id` int(11) NOT NULL COMMENT '寻物 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `xunwu_liuyan_text` text NOT NULL COMMENT '留言内容',
  `reply_text` varchar(255) DEFAULT NULL COMMENT '回复内容',
  `insert_time` datetime DEFAULT NULL COMMENT '留言时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `xunwu_id` (`xunwu_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='失物招领留言表';

-- ============================================
-- 6. 论坛模块
-- ============================================

DROP TABLE IF EXISTS `forum`;
CREATE TABLE `forum` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `forum_name` varchar(100) NOT NULL COMMENT '帖子标题',
  `yonghu_id` int(11) DEFAULT NULL COMMENT '用户 ID',
  `xinlizixunshi_id` int(11) DEFAULT NULL COMMENT '心理咨询师 ID',
  `users_id` int(11) DEFAULT NULL COMMENT '管理员 ID',
  `forum_content` text NOT NULL COMMENT '发布内容',
  `super_ids` int(11) DEFAULT '0' COMMENT '父帖子 ID（用于回复）',
  `forum_types` int(11) DEFAULT '0' COMMENT '帖子类型',
  `forum_state_types` int(11) DEFAULT '0' COMMENT '帖子状态 (0:公开 1:隐藏)',
  `insert_time` datetime DEFAULT NULL COMMENT '发帖时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `yonghu_id` (`yonghu_id`),
  KEY `xinlizixunshi_id` (`xinlizixunshi_id`),
  KEY `users_id` (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='论坛表';

-- ============================================
-- 7. 心理咨询师模块
-- ============================================

DROP TABLE IF EXISTS `xinlizixunshi`;
CREATE TABLE `xinlizixunshi` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '账号',
  `password` varchar(100) NOT NULL COMMENT '密码（明文）',
  `xinlizixunshi_name` varchar(50) DEFAULT NULL COMMENT '咨询师姓名',
  `xinlizixunshi_phone` varchar(20) DEFAULT NULL COMMENT '咨询师手机号',
  `xinlizixunshi_id_number` varchar(20) DEFAULT NULL COMMENT '咨询师身份证号',
  `xinlizixunshi_photo` varchar(255) DEFAULT NULL COMMENT '咨询师头像',
  `sex_types` int(11) DEFAULT '0' COMMENT '性别 (0:未知 1:男 2:女)',
  `xinlizixunshi_email` varchar(100) DEFAULT NULL COMMENT '电子邮箱',
  `xinlizixunshi_zhiye` varchar(100) DEFAULT NULL COMMENT '职业资格',
  `xinlizixunshi_content` text COMMENT '咨询师介绍',
  `role` varchar(20) DEFAULT '心理咨询师' COMMENT '角色',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='心理咨询师表';

-- 心理咨询师收藏表
DROP TABLE IF EXISTS `xinlizixunshi_collection`;
CREATE TABLE `xinlizixunshi_collection` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `xinlizixunshi_id` int(11) NOT NULL COMMENT '咨询师 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `insert_time` datetime DEFAULT NULL COMMENT '收藏时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `xinlizixunshi_id` (`xinlizixunshi_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='心理咨询师收藏表';

-- 心理咨询师留言表
DROP TABLE IF EXISTS `xinlizixunshi_liuyan`;
CREATE TABLE `xinlizixunshi_liuyan` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `xinlizixunshi_id` int(11) NOT NULL COMMENT '咨询师 ID',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `xinlizixunshi_liuyan_text` text NOT NULL COMMENT '留言内容',
  `reply_text` varchar(255) DEFAULT NULL COMMENT '回复内容',
  `insert_time` datetime DEFAULT NULL COMMENT '留言时间',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `xinlizixunshi_id` (`xinlizixunshi_id`),
  KEY `yonghu_id` (`yonghu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='心理咨询师留言表';

-- ============================================
-- 8. 聊天模块
-- ============================================

DROP TABLE IF EXISTS `chat`;
CREATE TABLE `chat` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `yonghu_id` int(11) NOT NULL COMMENT '用户 ID',
  `users_id` int(11) DEFAULT NULL COMMENT '管理员 ID',
  `chat_issue` text COMMENT '用户问题',
  `issue_time` datetime DEFAULT NULL COMMENT '问题时间',
  `chat_reply` text COMMENT '回复内容',
  `reply_time` datetime DEFAULT NULL COMMENT '回复时间',
  `zhuangtai_types` int(11) DEFAULT '0' COMMENT '状态 (0:待回复 1:已回复 2:已处理)',
  `chat_types` int(11) DEFAULT '0' COMMENT '聊天类型',
  `insert_time` datetime DEFAULT NULL COMMENT '聊天时间',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `yonghu_id` (`yonghu_id`),
  KEY `users_id` (`users_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天表';

-- ============================================
-- 9. 配置表
-- ============================================

DROP TABLE IF EXISTS `config`;
CREATE TABLE `config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '配置名称',
  `value` varchar(255) DEFAULT NULL COMMENT '配置值',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='配置表';

-- ============================================
-- 初始化数据
-- ============================================

-- 管理员账号（密码明文：admin123）
INSERT INTO `users` (`username`, `password`, `role`) VALUES ('admin', 'admin123', '管理员');

-- 普通用户账号（密码明文：user123）
INSERT INTO `yonghu` (`username`, `password`, `yonghu_name`, `role`) VALUES ('user1', 'user123', '张三', '用户');
INSERT INTO `yonghu` (`username`, `password`, `yonghu_name`, `role`) VALUES ('user2', 'user123', '李四', '用户');

-- 心理咨询师账号（密码明文：zixun123）
INSERT INTO `xinlizixunshi` (`username`, `password`, `xinlizixunshi_name`, `role`) VALUES ('zixun1', 'zixun123', '王老师', '心理咨询师');

-- 字典表数据 - 性别
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('sex', '性别', 1, '男', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('sex', '性别', 2, '女', NOW());

-- 字典表数据 - 活动类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('huodong', '活动类型', 1, '学术讲座', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('huodong', '活动类型', 2, '文体活动', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('huodong', '活动类型', 3, '社团活动', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('huodong', '活动类型', 4, '志愿服务', NOW());

-- 字典表数据 - 物品类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('wupin', '物品类型', 1, '书籍教材', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('wupin', '物品类型', 2, '电子产品', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('wupin', '物品类型', 3, '生活用品', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('wupin', '物品类型', 4, '运动器材', NOW());

-- 字典表数据 - 寻物类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('xunwu', '寻物类型', 1, '寻物', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('xunwu', '寻物类型', 2, '招领', NOW());

-- 字典表数据 - 帖子类型
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('forum', '帖子类型', 1, '普通帖子', NOW());
INSERT INTO `dictionary` (`dic_code`, `dic_name`, `code_index`, `index_name`, `create_time`) VALUES ('forum', '帖子类型', 2, '咨询帖子', NOW());

-- ============================================
-- 视图创建（用于多表联查）
-- ============================================

-- 活动视图
DROP VIEW IF EXISTS `huodong_view`;
CREATE VIEW `huodong_view` AS
SELECT 
    h.*,
    d1.index_name as huodong_type_name
FROM huodong h
LEFT JOIN dictionary d1 ON h.huodong_types = d1.code_index AND d1.dic_code = 'huodong'
WHERE h.huodong_delete = 1;

-- 二手物品视图
DROP VIEW IF EXISTS `wupin_view`;
CREATE VIEW `wupin_view` AS
SELECT 
    w.*,
    y.yonghu_name,
    y.yonghu_phone,
    d1.index_name as wupin_type_name
FROM wupin w
LEFT JOIN yonghu y ON w.yonghu_id = y.id
LEFT JOIN dictionary d1 ON w.wupin_types = d1.code_index AND d1.dic_code = 'wupin'
WHERE w.wupin_delete = 1;

-- 寻物视图
DROP VIEW IF EXISTS `xunwu_view`;
CREATE VIEW `xunwu_view` AS
SELECT 
    x.*,
    y.yonghu_name,
    d1.index_name as xunwu_type_name,
    d2.index_name as xunwu_zhuangtai_name
FROM xunwu x
LEFT JOIN yonghu y ON x.yonghu_id = y.id
LEFT JOIN dictionary d1 ON x.xunwu_types = d1.code_index AND d1.dic_code = 'xunwu'
LEFT JOIN dictionary d2 ON x.xunwu_zhuangtai_types = d2.code_index AND d2.dic_code = 'xunwu_zhuangtai'
WHERE x.xunwu_delete = 1;

-- ============================================
-- 结束
-- ============================================