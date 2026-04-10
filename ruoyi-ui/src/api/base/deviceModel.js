import request from '@/utils/request'

// 查询设备型号管理列表
export function listDeviceModel(query) {
  return request({
    url: '/base/deviceModel/list',
    method: 'get',
    params: query
  })
}

// 查询设备型号管理详细
export function getDeviceModel(id) {
  return request({
    url: '/base/deviceModel/' + id,
    method: 'get'
  })
}

// 新增设备型号管理
export function addDeviceModel(data) {
  return request({
    url: '/base/deviceModel',
    method: 'post',
    data: data
  })
}

// 修改设备型号管理
export function updateDeviceModel(data) {
  return request({
    url: '/base/deviceModel',
    method: 'put',
    data: data
  })
}

// 删除设备型号管理
export function delDeviceModel(id) {
  return request({
    url: '/base/deviceModel/' + id,
    method: 'delete'
  })
}
