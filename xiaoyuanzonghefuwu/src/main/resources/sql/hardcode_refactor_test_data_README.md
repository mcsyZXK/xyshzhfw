# 去硬编码改造测试数据说明

## 1. 文件位置

- 测试数据 SQL：
  `src/main/resources/sql/hardcode_refactor_test_data.sql`

## 2. 导入方式

```bash
mysql -uroot -p xiaoyuanzonghefuwu < hardcode_refactor_test_data.sql
```

在 `src/main/resources/sql` 目录执行即可。

## 3. 本批测试数据覆盖范围

- 管理端首页：
  用户总数、活动总数、二手总数、寻物总数、论坛总数、咨询师总数、活动报名总数
- 管理端首页热榜：
  热门活动（按 `huodong_clicknum`）
  热门帖子（按回复数）
- 管理端首页趋势：
  最近 7 天用户增长
  最近 7 天活动报名
- 论坛详情页：
  主贴与回复（`super_ids` 关联）
- 聊天页：
  用户提问和咨询师回复（`chat_issue`/`chat_reply`）
- 活动/二手/寻物详情页：
  留言与回复（`*_liuyan`）

## 4. 测试账号

- 用户账号：`hc_user01` ~ `hc_user08`
- 用户密码：`123456`
- 咨询师账号：`hc_counselor01`
- 咨询师密码：`123456`

## 5. 快速校验

SQL 文件末尾自带 `Quick check` 统计查询。

执行完成后，结果应至少满足：

- `HC users` = 8
- `HC counselors` = 1
- `HC activities` = 5
- `HC orders` = 11
- `HC forum rows` = 10
- `HC chat rows` = 6
- `HC huodong comments` = 3
- `HC wupin comments` = 3
- `HC xunwu comments` = 3

## 6. 可重复执行说明

- 数据以 `[HC]` 前缀和 `hc_user%`、`hc_counselor%` 标识。
- 每次执行会先清理同标识旧数据，再重新插入。
