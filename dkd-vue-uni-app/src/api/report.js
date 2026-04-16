import request from '@/utils/request'

// 获取仪表盘统计数据
export function getDashboardStats() {
  return request({
    url: '/report/dashboard/stats',
    method: 'get'
  })
}

// 获取热销商品统计
export function getHotProducts() {
  return request({
    url: '/report/hotProducts',
    method: 'get'
  })
}

// 获取异常设备统计
export function getAbnormalEquipment() {
  return request({
    url: '/report/abnormalEquipment',
    method: 'get'
  })
}

// 获取工单统计
export function getTaskStats() {
  return request({
    url: '/report/taskStats',
    method: 'get'
  })
}

// 获取商品库存统计
export function getProductStats() {
  return request({
    url: '/report/productStats',
    method: 'get'
  })
}

// Admin dashboard new API functions

// 获取设备状态统计
export function getMachineStatusStats() {
  return request({
    url: '/report/machineStatusStats',
    method: 'get'
  })
}

// 获取实时告警列表
export function getRealTimeAlerts() {
  return request({
    url: '/report/realTimeAlerts',
    method: 'get'
  })
}

// 获取最近任务列表
export function getRecentTasks() {
  return request({
    url: '/report/recentTasks',
    method: 'get'
  })
}

// 获取库存水平列表
export function getInventoryLevels() {
  return request({
    url: '/report/inventoryLevels',
    method: 'get'
  })
}

// 获取团队工作负载
export function getTeamWorkload() {
  return request({
    url: '/report/teamWorkload',
    method: 'get'
  })
}

// 获取财务指标
export function getFinancialMetrics() {
  return request({
    url: '/report/financialMetrics',
    method: 'get'
  })
}

// 获取成本明细
export function getCostBreakdown() {
  return request({
    url: '/report/costBreakdown',
    method: 'get'
  })
}

// 获取按位置的收入
export function getRevenueByLocation() {
  return request({
    url: '/report/revenueByLocation',
    method: 'get'
  })
}

// 获取合作伙伴业绩
export function getPartnerPerformance() {
  return request({
    url: '/report/partnerPerformance',
    method: 'get'
  })
}

// 获取性能KPI
export function getPerformanceKPIs() {
  return request({
    url: '/report/performanceKPIs',
    method: 'get'
  })
}
