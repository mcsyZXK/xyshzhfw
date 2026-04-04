import request from './request'

// 聊天记录列表
export function getChatList(params) {
  return request({
    url: '/chat/page',
    method: 'get',
    params
  })
}

// 发送消息
export function saveChat(data) {
  return request({
    url: '/chat/save',
    method: 'post',
    data
  })
}

// 用户端发送咨询（前台接口）
export function addChat(data) {
  return request({
    url: '/chat/add',
    method: 'post',
    data
  })
}

// 删除聊天记录
export function deleteChat(ids) {
  return request({
    url: '/chat/delete',
    method: 'post',
    data: ids
  })
}

// 更新聊天记录（回复、标记状态等）
export function updateChat(data) {
  return request({
    url: '/chat/update',
    method: 'post',
    data
  })
}
