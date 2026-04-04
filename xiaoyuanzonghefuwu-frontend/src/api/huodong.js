import request from './request'

// 活动列表
export function getHuodongList(params) {
  return request({
    url: '/huodong/page',
    method: 'get',
    params
  })
}

// 活动详情
export function getHuodongInfo(id) {
  return request({
    url: `/huodong/info/${id}`,
    method: 'get'
  })
}

// 保存活动
export function saveHuodong(data) {
  return request({
    url: '/huodong/save',
    method: 'post',
    data
  })
}

// 更新活动
export function updateHuodong(data) {
  return request({
    url: '/huodong/update',
    method: 'post',
    data
  })
}

// 删除活动
export function deleteHuodong(ids) {
  return request({
    url: '/huodong/delete',
    method: 'post',
    data: ids
  })
}

// 活动留言列表
export function getHuodongLiuyanList(params) {
  return request({
    url: '/huodongLiuyan/page',
    method: 'get',
    params
  })
}

// 发表活动留言
export function saveHuodongLiuyan(data) {
  return request({
    url: '/huodongLiuyan/save',
    method: 'post',
    data
  })
}
