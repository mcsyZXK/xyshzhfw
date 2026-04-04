param(
  [string]$BaseUrl = "http://127.0.0.1:8084/xiaoyuanzonghefuwu",
  [string]$DbUser = "root",
  [string]$DbPassword = "123456",
  [string]$DbName = "xiaoyuanzonghefuwu",
  [switch]$SkipSqlSeed
)

$ErrorActionPreference = "Stop"

function Assert-Ok {
  param(
    [Parameter(Mandatory = $true)]$Resp,
    [Parameter(Mandatory = $true)][string]$Name
  )
  if ($null -eq $Resp) {
    throw "$Name 失败：响应为空"
  }
  if ($Resp.code -ne 0 -and $Resp.code -ne 200) {
    throw "$Name 失败：code=$($Resp.code), msg=$($Resp.msg)"
  }
}

function New-TestImage {
  param([Parameter(Mandatory = $true)][string]$Path)
  $base64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2W0fUAAAAASUVORK5CYII="
  [IO.File]::WriteAllBytes($Path, [Convert]::FromBase64String($base64))
}

if (-not $SkipSqlSeed) {
  $scriptPath = Join-Path $PSScriptRoot "feature_upgrade_test_data.sql"
  Write-Host "导入测试数据: $scriptPath"
  $seedCmd = "SOURCE `"$scriptPath`";"
  & mysql -u$DbUser -p$DbPassword $DbName -e $seedCmd | Out-Host
}

Write-Host "1) 登录测试账号"
$login = Invoke-RestMethod -Method Post -Uri "$BaseUrl/yonghu/login" -Body @{
  username = "fg_user01"
  password = "123456"
}
Assert-Ok -Resp $login -Name "登录"
$token = $login.token
if ([string]::IsNullOrWhiteSpace($token)) {
  throw "登录失败：未返回 token"
}

$headers = @{
  token = $token
}
$jsonHeaders = @{
  token = $token
  "Content-Type" = "application/json"
}

Write-Host "2) 上传图片"
$tempImage = Join-Path $env:TEMP "feature-upgrade-test.png"
New-TestImage -Path $tempImage
$upload = Invoke-RestMethod -Method Post -Uri "$BaseUrl/file/upload" -Headers $headers -Form @{
  file = Get-Item $tempImage
}
Assert-Ok -Resp $upload -Name "上传图片"
$uploadPath = "/upload/$($upload.file)"

Write-Host "3) 二手发布"
$wupinName = "[FG] API发布物品-" + (Get-Date -Format "yyyyMMddHHmmss")
$wupinSave = Invoke-RestMethod -Method Post -Uri "$BaseUrl/wupin/save" -Headers $jsonHeaders -Body (@{
  wupinName       = $wupinName
  wupinPhoto      = $uploadPath
  wupinAddress    = "图书馆东门"
  lianxirenName   = "功能测试用户"
  lianxirenPhone  = "13800138001"
  wupinTypes      = 2
  wupinNumber     = 1
  wupinMaichuTypes = 1
  wupinOldMoney   = 399.00
  wupinNewMoney   = 189.00
  wupinContent    = "API 自动化：验证二手发布与图片展示"
} | ConvertTo-Json -Depth 6)
Assert-Ok -Resp $wupinSave -Name "二手发布"

Write-Host "4) 二手列表查询"
$wupinList = Invoke-RestMethod -Method Get -Uri "$BaseUrl/wupin/list?page=1&limit=5&wupinName=$([Uri]::EscapeDataString($wupinName))"
Assert-Ok -Resp $wupinList -Name "二手列表查询"
$wupinRow = $wupinList.data.list | Select-Object -First 1
if ($null -eq $wupinRow) {
  throw "二手列表查询失败：未查到刚发布数据"
}
if ([string]::IsNullOrWhiteSpace($wupinRow.wupinPhoto)) {
  throw "二手列表查询失败：图片字段为空"
}

Write-Host "5) 论坛发图文主贴"
$forumTypeRes = Invoke-RestMethod -Method Get -Uri "$BaseUrl/dictionary/page?dicCode=forum&page=1&limit=20"
Assert-Ok -Resp $forumTypeRes -Name "论坛类型获取"
$forumType = 1
if ($forumTypeRes.data.list.Count -gt 0) {
  $forumType = [int]$forumTypeRes.data.list[0].codeIndex
}

$forumName = "[FG] API主贴-" + (Get-Date -Format "yyyyMMddHHmmss")
$forumContent = "API 主贴内容`n[img]$uploadPath"
$forumSave = Invoke-RestMethod -Method Post -Uri "$BaseUrl/forum/save" -Headers $jsonHeaders -Body (@{
  forumName       = $forumName
  forumContent    = $forumContent
  superIds        = 0
  forumTypes      = $forumType
  forumStateTypes = 0
} | ConvertTo-Json -Depth 6)
Assert-Ok -Resp $forumSave -Name "论坛主贴发布"

Write-Host "6) 查询主贴并发布图文回复"
$forumList = Invoke-RestMethod -Method Get -Uri "$BaseUrl/forum/list?page=1&limit=5&forumName=$([Uri]::EscapeDataString($forumName))&superIds=0"
Assert-Ok -Resp $forumList -Name "论坛主贴查询"
$forumRow = $forumList.data.list | Select-Object -First 1
if ($null -eq $forumRow) {
  throw "论坛主贴查询失败：未查到刚发布主贴"
}
$forumId = [int]$forumRow.id

$replySave = Invoke-RestMethod -Method Post -Uri "$BaseUrl/forum/save" -Headers $jsonHeaders -Body (@{
  forumName       = "回复:$forumName"
  forumContent    = "API 回复内容`n[img]$uploadPath"
  superIds        = $forumId
  forumTypes      = $forumType
  forumStateTypes = 0
} | ConvertTo-Json -Depth 6)
Assert-Ok -Resp $replySave -Name "论坛回复发布"

Write-Host "7) 论坛详情与回复查询"
$forumDetail = Invoke-RestMethod -Method Get -Uri "$BaseUrl/forum/detail/$forumId"
Assert-Ok -Resp $forumDetail -Name "论坛详情查询"
if ($forumDetail.data.forumContent -notmatch "\[img\]") {
  throw "论坛详情查询失败：主贴未包含图片 token"
}

$replyList = Invoke-RestMethod -Method Get -Uri "$BaseUrl/forum/list?page=1&limit=20&superIds=$forumId"
Assert-Ok -Resp $replyList -Name "论坛回复查询"
if (($replyList.data.list | Measure-Object).Count -lt 1) {
  throw "论坛回复查询失败：未查到回复"
}

$result = [ordered]@{
  login = "PASS"
  upload = "PASS"
  wupinSave = "PASS"
  wupinListWithImage = "PASS"
  forumSave = "PASS"
  forumReply = "PASS"
  forumDetailWithImageToken = "PASS"
  forumReplyList = "PASS"
}

Write-Host ""
Write-Host "测试通过："
$result.GetEnumerator() | ForEach-Object { Write-Host ("- {0}: {1}" -f $_.Key, $_.Value) }
