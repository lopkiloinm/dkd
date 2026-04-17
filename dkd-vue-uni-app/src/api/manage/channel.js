import request from '@/utils/request'

// 查询售货机货道列表
export function listChannel(query) {
  return request({
    url: '/manage/channel/list',
    method: 'get',
    params: query
  })
}

export function getChannel(id) {
  return request({
    url: `/manage/channel/${id}`,
    method: 'get'
  })
}

export function addChannel(data) {
  return request({
    url: '/manage/channel',
    method: 'post',
    data
  })
}

export function updateChannel(data) {
  return request({
    url: '/manage/channel',
    method: 'put',
    data
  })
}

export function delChannel(ids) {
  return request({
    url: `/manage/channel/${ids}`,
    method: 'delete'
  })
}
