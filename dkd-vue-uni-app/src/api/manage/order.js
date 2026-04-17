import request from '@/utils/request'

// List orders (paged, filterable)
export function listOrder(query) {
  return request({
    url: '/manage/order/list',
    method: 'get',
    params: query
  })
}

// Order detail by id
export function getOrder(id) {
  return request({
    url: `/manage/order/${id}`,
    method: 'get'
  })
}

// Order detail by order number
export function getOrderByNo(orderNo) {
  return request({
    url: `/manage/order/no/${orderNo}`,
    method: 'get'
  })
}
