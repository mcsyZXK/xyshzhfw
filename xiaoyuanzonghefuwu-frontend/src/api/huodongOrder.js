import request from './request'

// 报名列表
export function getHuodongOrderList(params) {
  return request({
    url: '/huodongOrder/page',
    method: 'get',
    params
  })
}

// 报名详情
export function getHuodongOrderInfo(id) {
  return request({
    url: `/huodongOrder/info/${id}`,
    method: 'get'
  })
}

// 保存报名
export function saveHuodongOrder(data) {
  return request({
    url: '/huodongOrder/save',
    method: 'post',
    data
  })
}

// 前端报名（带重复校验）
export function addHuodongOrder(data) {
  return request({
    url: '/huodongOrder/add',
    method: 'post',
    data
  })
}

// 删除报名
export function deleteHuodongOrder(ids) {
  return request({
    url: '/huodongOrder/delete',
    method: 'post',
    data: Array.isArray(ids) ? ids : [ids]
  })
}
