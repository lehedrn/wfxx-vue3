import request from '@/utils/request'

// 查询区划管理列表
export function listArea(query) {
  return request({
    url: '/system/area/list',
    method: 'get',
    params: query
  })
}

// 懒加载子节点数据
export function listAreaTree(parentCode) {
  return request({
    url: '/system/area/listTree/' + parentCode,
    method: 'get'
  })
}

// 查询区划管理详细
export function getArea(id) {
  return request({
    url: '/system/area/' + id,
    method: 'get'
  })
}

// 根据区划编码查询区划信息
export function getAreaByCode(code) {
  return request({
    url: '/system/area/code/' + code,
    method: 'get'
  })
}

// 新增区划管理
export function addArea(data) {
  return request({
    url: '/system/area',
    method: 'post',
    data: data
  })
}

// 修改区划管理
export function updateArea(data) {
  return request({
    url: '/system/area',
    method: 'put',
    data: data
  })
}

// 删除区划管理
export function delArea(id) {
  return request({
    url: '/system/area/' + id,
    method: 'delete'
  })
}
