import request from '@/utils/request'

// Global search across all entities
export function search(query) {
  return request({
    url: '/search',
    method: 'get',
    params: { query }
  })
}

// Search machines
export function searchMachines(query) {
  return request({
    url: '/manage/vm/search',
    method: 'get',
    params: { query }
  })
}

// Search tasks
export function searchTasks(query) {
  return request({
    url: '/manage/task/search',
    method: 'get',
    params: { query }
  })
}

// Search products/inventory
export function searchProducts(query) {
  return request({
    url: '/product/search',
    method: 'get',
    params: { query }
  })
}
