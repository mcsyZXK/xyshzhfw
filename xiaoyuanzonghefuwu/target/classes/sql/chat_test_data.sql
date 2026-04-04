-- 咨询记录管理 API 测试数据
-- 用于测试咨询师端的咨询记录管理功能
-- 注意：执行此脚本前请确保已运行 add_xinlizixunshi_id_to_chat.sql 添加 xinlizixunshi_id 字段

-- 1. 清理旧数据
DELETE FROM chat;

-- 2. 插入测试咨询记录
-- 用户 1 向咨询师 1（张老师）咨询学习压力问题
-- chat_issue 存储用户问题内容，chat_reply 存储回复内容
INSERT INTO chat (yonghu_id, xinlizixunshi_id, chat_issue, chat_reply, zhuangtai_types, chat_types, insert_time, create_time)
VALUES
(1, 1, '老师您好，我最近学习压力很大，每天都很焦虑，晚上也睡不好觉。', '', 0, 1, NOW(), NOW()),
(1, 1, '理解你的感受，能具体说说是什么让你感到压力最大吗？', '', 1, 2, DATE_ADD(NOW(), INTERVAL 5 MINUTE), NOW()),
(1, 1, '主要是期末考试快到了，我还有很多内容没复习完，担心考不好。', '', 0, 1, DATE_ADD(NOW(), INTERVAL 10 MINUTE), NOW()),
(1, 1, '建议你制定一个合理的复习计划，每天完成一部分，不要给自己太大压力。', '', 1, 2, DATE_ADD(NOW(), INTERVAL 15 MINUTE), NOW());

-- 用户 2 向咨询师 1（张老师）咨询人际关系问题
INSERT INTO chat (yonghu_id, xinlizixunshi_id, chat_issue, chat_reply, zhuangtai_types, chat_types, insert_time, create_time)
VALUES
(2, 1, '老师，我和室友关系不太好，不知道该怎么相处。', '', 0, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), NOW()),
(2, 1, '能和我说说具体发生了什么事情吗？', '', 1, 2, DATE_ADD(NOW(), INTERVAL 1 DAY, 5 MINUTE), NOW()),
(2, 1, '她们经常在我休息的时候大声说话，我说了几次也没用。', '', 0, 1, DATE_ADD(NOW(), INTERVAL 1 DAY, 10 MINUTE), NOW());

-- 用户 3 向咨询师 2（李老师）咨询职业规划问题
INSERT INTO chat (yonghu_id, xinlizixunshi_id, chat_issue, chat_reply, zhuangtai_types, chat_types, insert_time, create_time)
VALUES
(3, 2, '李老师，我对未来的职业规划很迷茫，不知道毕业后该做什么。', '', 0, 1, DATE_ADD(NOW(), INTERVAL 2 DAY), NOW()),
(3, 2, '你对什么专业方向比较感兴趣呢？', '', 1, 2, DATE_ADD(NOW(), INTERVAL 2 DAY, 5 MINUTE), NOW());

-- 用户 4 向咨询师 3（王老师）咨询失恋问题
INSERT INTO chat (yonghu_id, xinlizixunshi_id, chat_issue, chat_reply, zhuangtai_types, chat_types, insert_time, create_time)
VALUES
(4, 3, '张老师，我最近失恋了，心情很低落，做什么都提不起兴趣。', '', 0, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), NOW()),
(4, 3, '失恋确实很难受，允许自己悲伤是正常的。但也要慢慢调整心态。', '', 1, 2, DATE_ADD(NOW(), INTERVAL 3 DAY, 5 MINUTE), NOW()),
(4, 3, '可是我真的很难走出来，总是会想起以前的事情。', '', 0, 1, DATE_ADD(NOW(), INTERVAL 3 DAY, 10 MINUTE), NOW());

-- 3. 验证数据
SELECT '插入的咨询记录：' as info;
SELECT id, yonghu_id, xinlizixunshi_id, LEFT(chat_issue, 30) as issue_preview, zhuangtai_types, chat_types, insert_time
FROM chat ORDER BY insert_time DESC;