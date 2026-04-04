import request from './request'

// 寻物列表
export function getXunwuList(params) {
  return request({
    url: '/xunwu/page',
    method: 'get',
    params
  })
}

// 寻物详情
export function getXunwuInfo(id) {
  return request({
    url: `/xunwu/info/${id}`,
    method: 'get'
  })
}

// 保存寻物
export function saveXunwu(data) {
  return request({
    url: '/xunwu/save',
    method: 'post',
    data
  })
}

// 更新寻物
export function updateXunwu(data) {
  return request({
    url: '/xunwu/update',
    method: 'post',
    data
  })
}

// 删除寻物
export function deleteXunwu(ids) {
  return request({
    url: '/xunwu/delete',
    method: 'post',
    data: ids
  })
}

// 寻物留言列表
export function getXunwuLiuyanList(params) {
  return request({
    url: '/xunwuLiuyan/page',
    method: 'get',
    params
  })
}

// 发表寻物留言
export function saveXunwuLiuyan(data) {
  return request({
    url: '/xunwuLiuyan/save',
    method: 'post',
    data
  })
}
