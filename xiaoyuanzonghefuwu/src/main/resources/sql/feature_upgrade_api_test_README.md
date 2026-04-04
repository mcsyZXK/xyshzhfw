# 功能改造接口测试说明

## 1. 覆盖范围

- 删除在线咨询后的主流程不受影响（登录、论坛、二手）
- 二手模块：发布商品 + 图片上传 + 列表图片字段回读
- 校园论坛：主贴图文发布 + 回复图文发布 + 详情图文回读

## 2. 测试数据

- SQL：`feature_upgrade_test_data.sql`
- 测试账号：`fg_user01 / 123456`

## 3. 执行方式

在 `src/main/resources/sql` 目录执行：

```powershell
pwsh ./feature_upgrade_api_test.ps1
```

如服务端口不是 `8084`：

```powershell
pwsh ./feature_upgrade_api_test.ps1 -BaseUrl "http://127.0.0.1:8085/xiaoyuanzonghefuwu"
```

只跑接口，不导入 SQL：

```powershell
pwsh ./feature_upgrade_api_test.ps1 -SkipSqlSeed
```
