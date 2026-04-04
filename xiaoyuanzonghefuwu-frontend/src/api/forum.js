import request from './request'

// 帖子列表
export function getForumList(params) {
  return request({
    url: '/forum/page',
    method: 'get',
    params
  })
}

// 帖子详情
export function getForumInfo(id) {
  return request({
    url: `/forum/info/${id}`,
    method: 'get'
  })
}

// 保存帖子
export function saveForum(data) {
  return request({
    url: '/forum/save',
    method: 'post',
    data
  })
}

// 更新帖子
export function updateForum(data) {
  return request({
    url: '/forum/update',
    method: 'post',
    data
  })
}

// 删除帖子
export function deleteForum(ids) {
  return request({
    url: '/forum/delete',
    method: 'post',
    data: ids
  })
}