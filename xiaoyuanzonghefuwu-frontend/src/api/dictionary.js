import request from './request'

// 字典列表
export function getDictionaryList(params) {
  return request({
    url: '/dictionary/page',
    method: 'get',
    params
  })
}

// 字典详情
export function getDictionaryInfo(id) {
  return request({
    url: `/dictionary/info/${id}`,
    method: 'get'
  })
}

// 根据类型获取字典
export function getDictionaryByType(type) {
  return request({
    url: `/dictionary/page?dicCode=${type}`,
    method: 'get'
  })
}

// 删除字典
export function deleteDictionary(id) {
  return request({
    url: `/dictionary/delete`,
    method: 'post',
    params: { ids: id }
  })
}

// 保存字典
export function saveDictionary(data) {
  return request({
    url: '/dictionary/save',
    method: 'post',
    data
  })
}

// 更新字典
export function updateDictionary(data) {
  return request({
    url: '/dictionary/update',
    method: 'post',
    data
  })
}

// 配置列表（别名）
export function getConfigList(params) {
  return request({
    url: '/config/page',
    method: 'get',
    params
  })
}

// 保存配置
export function saveConfig(data) {
  return request({
    url: '/config/save',
    method: 'post',
    data
  })
}

// 更新配置
export function updateConfig(data) {
  return request({
    url: '/config/update',
    method: 'post',
    data
  })
}

// 删除配置
export function deleteConfig(id) {
  return request({
    url: `/config/delete`,
    method: 'post',
    params: { ids: id }
  })
}
