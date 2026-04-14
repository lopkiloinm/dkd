import request from '@/utils/request'

// 查询售货机货道列表
export function listChannel(query) {
  return request({
    url: '/manage/channel/list',
    method: 'get',
    params: query
  })
}
