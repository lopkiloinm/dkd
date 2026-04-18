import request from '@/utils/request'

// 查询工单列表
export function listTask(query) {
  return request({
    url: '/manage/task/list',
    method: 'get',
    params: query
  })
}

// 新增工单
export function addTask(data) {
  return request({
    url: '/manage/task',
    method: 'post',
    data: data
  })
}

// 修改工单
export function updateTask(data) {
  return request({
    url: '/manage/task',
    method: 'put',
    data: data
  })
}

// 删除工单
export function delTask(taskId) {
  return request({
    url: `/manage/task/${taskId}`,
    method: 'delete'
  })
}

// 获取工单详细信息
export function getTask(taskId) {
  return request({
    url: `/manage/task/${taskId}`,
    method: 'get'
  })
}

// 完成工单
export function completeTask(taskId) {
  return request({
    url: `/manage/task/${taskId}/complete`,
    method: 'put'
  })
}

// Accept a pending task (status 1 -> 2)
export function acceptTask(taskId) {
  return request({
    url: `/manage/task/${taskId}/accept`,
    method: 'put'
  })
}

// Reject a task with an optional reason
export function rejectTask(taskId, reason) {
  return request({
    url: `/manage/task/${taskId}/reject`,
    method: 'put',
    params: reason ? { reason } : {}
  })
}
