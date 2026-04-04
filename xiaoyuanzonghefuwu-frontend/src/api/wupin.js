import request from './request'

// 物品列表
export function getWupinList(params) {
  return request({
    url: '/wupin/page',
    method: 'get',
    params
  })
}

// 物品详情
export function getWupinInfo(id) {
  return request({
    url: `/wupin/info/${id}`,
    method: 'get'
  })
}

// 保存物品
export function saveWupin(data) {
  return request({
    url: '/wupin/save',
    method: 'post',
    data
  })
}

// 更新物品
export function updateWupin(data) {
  return request({
    url: '/wupin/update',
    method: 'post',
    data
  })
}

// 删除物品
export function deleteWupin(ids) {
  return request({
    url: '/wupin/delete',
    method: 'post',
    data: ids
  })
}

// 物品留言列表
export function getWupinLiuyanList(params) {
  return request({
    url: '/wupinLiuyan/page',
    method: 'get',
    params
  })
}

// 发表物品留言
export function saveWupinLiuyan(data) {
  return request({
    url: '/wupinLiuyan/save',
    method: 'post',
    data
  })
}
