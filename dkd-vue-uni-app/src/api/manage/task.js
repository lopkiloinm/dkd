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
