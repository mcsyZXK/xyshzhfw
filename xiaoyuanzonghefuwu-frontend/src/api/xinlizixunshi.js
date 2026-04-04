import request from './request'

// 咨询师列表
export function getXinlizixunshiList(params) {
  return request({
    url: '/xinlizixunshi/page',
    method: 'get',
    params
  })
}

// 咨询师列表（别名）
export function getCounselorList(params) {
  return request({
    url: '/xinlizixunshi/page',
    method: 'get',
    params
  })
}

// 咨询师详情（通过 ID）
export function getXinlizixunshiInfoById(id) {
  return request({
    url: `/xinlizixunshi/info/${id}`,
    method: 'get'
  })
}

// 咨询师登录
export function xinlizixunshiLogin(data) {
  return request({
    url: '/xinlizixunshi/login',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  })
}

// 咨询师注册
export function registerCounselor(data) {
  return request({
    url: '/xinlizixunshi/register',
    method: 'post',
    data
  })
}

// 删除咨询师
export function deleteCounselor(id) {
  return request({
    url: `/xinlizixunshi/delete`,
    method: 'post',
    params: { ids: id }
  })
}

// 更新咨询师信息
export function updateCounselor(data) {
  return request({
    url: '/xinlizixunshi/update',
    method: 'post',
    data
  })
}

// 更新咨询师信息（别名）
export function updateXinlizixunshi(data) {
  return request({
    url: '/xinlizixunshi/update',
    method: 'post',
    data
  })
}

// 保存咨询师
export function saveCounselor(data) {
  return request({
    url: '/xinlizixunshi/save',
    method: 'post',
    data
  })
}

// 获取当前咨询师信息（通过 token）
export function getCurrentXinlizixunshiInfo() {
  return request({
    url: '/xinlizixunshi/session',
    method: 'get'
  })
}

// 获取咨询师信息（别名，与 getCurrentXinlizixunshiInfo 相同）
export function getXinlizixunshiInfo() {
  return request({
    url: '/xinlizixunshi/session',
    method: 'get'
  })
}

// 获取咨询师留言列表
export function getXinlizixunshiLiuyanList(params) {
  return request({
    url: '/xinlizixunshiLiuyan/page',
    method: 'get',
    params
  })
}

// 更新咨询师留言
export function updateXinlizixunshiLiuyan(data) {
  return request({
    url: '/xinlizixunshiLiuyan/update',
    method: 'post',
    data
  })
}

// 获取咨询师收藏列表
export function getXinlizixunshiCollectionList(params) {
  return request({
    url: '/xinlizixunshiCollection/page',
    method: 'get',
    params
  })
}

// 删除咨询师收藏
export function deleteXinlizixunshiCollection(id) {
  return request({
    url: '/xinlizixunshiCollection/delete',
    method: 'post',
    params: { ids: id }
  })
}

// 获取聊天列表（咨询师端）
export function getCounselorChatList(params) {
  return request({
    url: '/chat/page',
    method: 'get',
    params
  })
}

// 发送聊天消息
export function saveChat(data) {
  return request({
    url: '/chat/save',
    method: 'post',
    data
  })
}
