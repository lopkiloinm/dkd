<template>
  <TopBar title="Home" />
  <view class="layout-container">
    <view class="header-section">
      <view class="welcome-box">
        <text class="title">DiKeDe</text>
        <text class="subtitle">Overview and quick access</text>
      </view>
    </view>
    
    <!-- Work Order Stats -->
    <view class="stats-card work-order-stats">
      <view class="stats-header">
        <text class="stats-title">Work Order Stats</text>
        <text class="stats-subtitle">{{ dateRange }}</text>
      </view>
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-num">{{ totalOrders }}</text>
          <text class="stat-label">Total Orders</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ completedOrders }}</text>
          <text class="stat-label">Completed</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ inProgressOrders }}</text>
          <text class="stat-label">In Progress</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ cancelledOrders }}</text>
          <text class="stat-label">Cancelled</text>
        </view>
      </view>
    </view>

    <!-- Sales Stats -->
    <view class="stats-card sales-stats">
      <view class="stats-header">
        <text class="stats-title">Sales Stats</text>
        <text class="stats-subtitle">{{ dateRange }}</text>
      </view>
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-num">{{ orderCount }}</text>
          <text class="stat-label">Order Count</text>
        </view>
        <view class="stat-item">
          <text class="stat-num">{{ salesAmount }}</text>
          <text class="stat-label">Sales Amount</text>
        </view>
      </view>
    </view>

    <!-- Dashboard Cards -->
    <view class="section-title">Management</view>
    <view class="dashboard-grid">
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/node/index')">
        <image class="card-icon" src="/static/icons/node.svg"></image>
        <text class="card-value">{{ nodeCount }}</text>
        <text class="card-label">Nodes</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/vm/index')">
        <image class="card-icon" src="/static/icons/device.svg"></image>
        <text class="card-value">{{ deviceCount }}</text>
        <text class="card-label">Devices</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/emp/index')">
        <image class="card-icon" src="/static/icons/employee.svg"></image>
        <text class="card-value">{{ empCount }}</text>
        <text class="card-label">Employees</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/region/index')">
        <image class="card-icon" src="/static/icons/region.svg"></image>
        <text class="card-value">{{ regionCount }}</text>
        <text class="card-label">Regions</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/partner/index')">
        <image class="card-icon" src="/static/icons/partner.svg"></image>
        <text class="card-value">{{ partnerCount }}</text>
        <text class="card-label">Partners</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/vmType/index')">
        <image class="card-icon" src="/static/icons/vmtype.svg"></image>
        <text class="card-value">{{ vmTypeCount }}</text>
        <text class="card-label">VM Types</text>
      </view>
    </view>

    <!-- Hot Products Ranking -->
    <view class="section-title">Hot Products</view>
    <view class="ranking-card">
      <view class="ranking-item" v-for="(item, index) in hotProducts" :key="index">
        <view class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</view>
        <text class="product-name">{{ item.skuName }}</text>
        <text class="product-count">{{ item.count }} orders</text>
      </view>
    </view>

    <!-- Abnormal Equipment -->
    <view class="section-title">Abnormal Equipment</view>
    <view class="equipment-list">
      <view class="equipment-item" v-for="(item, index) in abnormalEquipment" :key="index" @click="goTo('/pages/manage/vm/index')">
        <text class="equipment-time">{{ item.updateTime }}</text>
        <text class="equipment-addr">{{ item.addr }}</text>
        <text class="equipment-code">{{ item.innerCode }}</text>
      </view>
      <view class="empty-state" v-if="abnormalEquipment.length === 0">
        <text class="empty-text">No abnormal equipment</text>
      </view>
    </view>
  </view>
  <BottomBar />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import BottomBar from '@/components/BottomBar/index.vue'
import useUserStore from '@/store/modules/user'
import { listNode } from '@/api/manage/node'
import { listVm } from '@/api/manage/vm'
import { listEmp } from '@/api/manage/emp'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { listVmType } from '@/api/manage/vmType'

const userStore = useUserStore()

// Dashboard counts
const nodeCount = ref(0)
const deviceCount = ref(0)
const empCount = ref(0)
const regionCount = ref(0)
const partnerCount = ref(0)
const vmTypeCount = ref(0)

// Work order stats
const totalOrders = ref(12)
const completedOrders = ref(8)
const inProgressOrders = ref(3)
const cancelledOrders = ref(1)

// Sales stats
const orderCount = ref(7358)
const salesAmount = ref('7351')

// Hot products
const hotProducts = ref([
  { skuName: 'Jasmine Tea', count: 820 },
  { skuName: 'Starbucks', count: 762 },
  { skuName: 'Coca-Cola', count: 749 },
  { skuName: 'Nongfu Spring', count: 742 },
  { skuName: '100% Orange Juice', count: 718 }
])

// Abnormal equipment
const abnormalEquipment = ref([
  { updateTime: '2024-05-14 09:21', addr: 'Shunyi Olympic Water Park', innerCode: 'A1000001' },
  { updateTime: '2024-05-14 09:22', addr: 'Xizhimen North Street, Haidian', innerCode: 'Ut548Hpf' }
])

// Date range
const dateRange = ref('')

const setDateRange = () => {
  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth(), 1)
  const end = now
  dateRange.value = `${formatDate(start)} ~ ${formatDate(end)}`
}

const formatDate = (date) => {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}.${month}.${day}`
}

const fetchDashboardCounts = async () => {
  try {
    const [nodes, devices, emps, regions, partners, vmTypes] = await Promise.all([
      listNode({ pageNum: 1, pageSize: 1 }),
      listVm({ pageNum: 1, pageSize: 1 }),
      listEmp({ pageNum: 1, pageSize: 1 }),
      listRegion({ pageNum: 1, pageSize: 1 }),
      listPartner({ pageNum: 1, pageSize: 1 }),
      listVmType({ pageNum: 1, pageSize: 1 })
    ])
    
    nodeCount.value = nodes.total || 0
    deviceCount.value = devices.total || 0
    empCount.value = emps.total || 0
    regionCount.value = regions.total || 0
    partnerCount.value = partners.total || 0
    vmTypeCount.value = vmTypes.total || 0
  } catch (error) {
    console.error('Failed to fetch dashboard counts', error)
  }
}

onMounted(() => {
  setDateRange()
  fetchDashboardCounts()
})

onShow(() => {
  if (!userStore.token) {
    uni.reLaunch({ url: '/pages/login/index' })
  }
})

const goTo = (url) => {
  uni.navigateTo({ url })
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  min-height: 100vh;
  padding: 60px 16px 16px 16px;
  box-sizing: border-box;
  padding-bottom: 66px;
}

.header-section {
  margin-bottom: 28px;
  padding-top: 16px;
}

.welcome-box {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 15px;
  color: $apple-text-secondary;
}

.stats-card {
  @include glass-panel;
  padding: 20px;
  margin-bottom: 20px;
}

.work-order-stats {
  background: linear-gradient(135deg, rgba(233, 243, 255, 0.8) 0%, rgba(233, 243, 255, 0.4) 100%);
}

.sales-stats {
  background: linear-gradient(135deg, rgba(251, 239, 232, 0.8) 0%, rgba(251, 239, 232, 0.4) 100%);
}

.stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.stats-title {
  font-size: 18px;
  font-weight: 700;
  color: #072074;
  letter-spacing: -0.5px;
}

.stats-subtitle {
  font-size: 12px;
  color: #91a7dc;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 8px;
}

.stat-num {
  font-size: 24px;
  font-weight: 700;
  color: #072074;
  margin-bottom: 4px;
  letter-spacing: -0.5px;
}

.sales-stats .stat-num {
  color: #ff5757;
}

.stat-label {
  font-size: 12px;
  color: #91a7dc;
  font-weight: 500;
  text-align: center;
}

.sales-stats .stat-label {
  color: #de9690;
}

.section-title {
  font-size: 17px;
  font-weight: 600;
  color: $apple-text-primary;
  margin-bottom: 14px;
  padding-left: 4px;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 32px;
}

.n-card {
  @include glass-panel;
  padding: 24px 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.n-card-hover {
  background-color: rgba(255, 255, 255, 0.8);
  transform: scale(0.97);
}

.card-icon {
  width: 44px;
  height: 44px;
  margin-bottom: 14px;
}

.card-value {
  font-size: 26px;
  font-weight: 700;
  color: $apple-text-primary;
  margin-bottom: 4px;
  letter-spacing: -0.5px;
}

.card-label {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.ranking-card {
  @include glass-panel;
  padding: 16px;
  margin-bottom: 20px;
}

.ranking-item {
  display: flex;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.ranking-item:last-child {
  border-bottom: none;
}

.rank-badge {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  color: #999;
  margin-right: 12px;
  background-color: rgba(0, 0, 0, 0.05);
}

.rank-1 {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
  color: white;
}

.rank-2 {
  background: linear-gradient(135deg, #C0C0C0 0%, #A8A8A8 100%);
  color: white;
}

.rank-3 {
  background: linear-gradient(135deg, #CD7F32 0%, #B87333 100%);
  color: white;
}

.product-name {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
  color: $apple-text-primary;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.product-count {
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.equipment-list {
  @include glass-panel;
  padding: 16px;
  margin-bottom: 20px;
}

.equipment-item {
  display: flex;
  flex-direction: column;
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  transition: background-color 0.2s;
}

.equipment-item:active {
  background-color: rgba(0, 0, 0, 0.05);
}

.equipment-item:last-child {
  border-bottom: none;
}

.equipment-time {
  font-size: 12px;
  color: $apple-text-secondary;
  margin-bottom: 4px;
}

.equipment-addr {
  font-size: 14px;
  font-weight: 500;
  color: $apple-text-primary;
  margin-bottom: 4px;
}

.equipment-code {
  font-size: 13px;
  color: #ff3b30;
  font-weight: 600;
}

.empty-state {
  padding: 40px 0;
  text-align: center;
}

.empty-text {
  color: $apple-text-secondary;
  font-size: 15px;
}
</style>
