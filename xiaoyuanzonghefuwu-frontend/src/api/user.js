import request from './request'

// 用户登录
export function login(data) {
  return request({
    url: '/users/login',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  })
}

// 用户登出
export function logout() {
  return request({
    url: '/users/logout',
    method: 'get'
  })
}

// 获取当前用户信息
export function getSession() {
  return request({
    url: '/users/session',
    method: 'get'
  })
}

// 密码重置
export function resetPass(username) {
  return request({
    url: '/users/resetPass',
    method: 'post',
    data: { username },
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  })
}

// 用户列表
export function getUserList(params) {
  return request({
    url: '/yonghu/page',
    method: 'get',
    params
  })
}

// 用户详情
export function getUserInfo(id) {
  return request({
    url: `/yonghu/info/${id}`,
    method: 'get'
  })
}

// 保存用户
export function saveUser(data) {
  return request({
    url: '/yonghu/save',
    method: 'post',
    data
  })
}

// 更新用户
export function updateUser(data) {
  return request({
    url: '/yonghu/update',
    method: 'post',
    data
  })
}

// 删除用户
export function deleteUser(ids) {
  return request({
    url: '/yonghu/delete',
    method: 'post',
    data: ids
  })
}

// 重置用户密码
export function resetUserPassword(id) {
  return request({
    url: `/yonghu/resetPassword?id=${id}`,
    method: 'get'
  })
}

// 用户注册
export function registerUser(data) {
  return request({
    url: '/yonghu/register',
    method: 'post',
    data
  })
}

// 用户登录（普通用户）
export function yonghuLogin(data) {
  return request({
    url: '/yonghu/login',
    method: 'post',
    data,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  })
}

// 获取当前普通用户信息
export function getYonghuSession() {
  return request({
    url: '/yonghu/session',
    method: 'get'
  })
}

// 普通用户修改密码
export function changeYonghuPassword(data) {
  return request({
    url: '/yonghu/changePassword',
    method: 'post',
    data
  })
}
