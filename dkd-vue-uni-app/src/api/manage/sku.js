import request from '@/utils/request'

// List SKUs
export function listSku(query) {
  return request({
    url: '/manage/sku/list',
    method: 'get',
    params: query
  })
}

// Get SKU by id
export function getSku(skuId) {
  return request({
    url: '/manage/sku/' + skuId,
    method: 'get'
  })
}

// Add SKU
export function addSku(data) {
  return request({
    url: '/manage/sku',
    method: 'post',
    data: data
  })
}

// Update SKU
export function updateSku(data) {
  return request({
    url: '/manage/sku',
    method: 'put',
    data: data
  })
}

// Delete SKU
export function delSku(skuId) {
  return request({
    url: '/manage/sku/' + skuId,
    method: 'delete'
  })
}

// SKU Class list
export function listSkuClass(query) {
  return request({
    url: '/manage/skuClass/list',
    method: 'get',
    params: query
  })
}
