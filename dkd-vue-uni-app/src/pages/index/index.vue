<template>
  <AppTopBar
    :unread-count="unreadCount"
    :profile-picture="profilePicture"
    :user-name="userName"
    @search="handleSearch"
    @notification="handleNotification"
  />
  <view class="layout-container layout-container--bottom-tabs">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <!-- Weekly revenue bar chart -->
        <Motion preset="fade-up" :index="0">
          <Card
            title="Weekly Revenue"
            accent="primary"
            icon="chart-bar"
            padding="md"
            interactive
            class="week-revenue-card"
            @click="goTo('/pages/analytics/index')"
          >
            <view class="week-bar-chart">
              <view v-for="d in weeklyRevenueByDay" :key="d.weekday" class="week-bar-col">
                <text class="week-bar-value">{{ formatWeekRevenue(d.revenue) }}</text>
                <view class="week-bar-track">
                  <view
                    class="week-bar-fill"
                    :class="{ 'week-bar-fill--has-value': d.revenue > 0 }"
                    :style="{ height: weekBarHeightPct(d.revenue) + '%' }"
                  />
                </view>
                <text class="week-bar-label">{{ d.label }}</text>
              </view>
            </view>
          </Card>
        </Motion>

        <!-- 1. Operations Overview -->
        <Motion preset="fade-up" :index="1">
          <text class="section-title">Operations Overview</text>
          <view class="quick-stats">
            <Grid :columns="2" :gap="16">
              <view class="stat-card-link" @click="goTo('/pages/manage/vm/index')">
                <StatCard
                  label="Total Machines"
                  :value="totalMachines"
                  trend="95% Online"
                  trend-direction="neutral"
                  variant="primary"
                />
              </view>
              <view class="stat-card-link" @click="goTo('/pages/manage/task/index')">
                <StatCard
                  label="Tasks Pending"
                  :value="pendingTasks"
                  trend="12 Urgent"
                  trend-direction="up"
                  variant="warning"
                />
              </view>
              <view class="stat-card-link" @click="goTo('/pages/inventory/index')">
                <StatCard
                  label="Low Stock Items"
                  :value="lowStockCount"
                  trend="5 Critical"
                  trend-direction="down"
                  variant="error"
                />
              </view>
              <view class="stat-card-link" @click="goTo('/pages/manage/emp/index')">
                <StatCard
                  label="Team Members"
                  :value="teamCount"
                  trend="8 Active"
                  trend-direction="neutral"
                  variant="success"
                />
              </view>
            </Grid>
          </view>
        </Motion>

        <!-- 2. Abnormal Equipment (urgent, actionable) -->
        <Motion preset="fade-up" :index="2">
          <Card
            title="Abnormal Equipment"
            accent="error"
            icon="alert-triangle"
            padding="none"
            class="abnormal-section"
          >
            <view
              v-for="(item, index) in abnormalEquipment"
              :key="index"
              class="equipment-item"
              @click="goTo('/pages/manage/vm/index')"
            >
              <text class="equipment-time">{{ item.updateTime }}</text>
              <text class="equipment-addr">{{ item.addr }}</text>
              <text class="equipment-code">{{ item.innerCode }}</text>
            </view>
            <view v-if="abnormalEquipment.length === 0" class="empty-state">
              <text class="empty-text">No abnormal equipment</text>
            </view>
            <view v-if="abnormalEquipment.length > 0" class="see-all-row" @click="goTo('/pages/manage/vm/index')">
              <text class="see-all-label">See all machines</text>
              <Icon name="chevron-right" size="16" />
            </view>
          </Card>
        </Motion>

        <!-- 3. Quick Actions -->
        <Motion preset="fade-up" :index="3">
          <text class="section-title">Quick Actions</text>
          <view class="quick-actions">
            <Grid :columns="3" :gap="16">
              <view class="quick-action-tile" @click="handleBulkAssign">
                <view class="icon-tile icon-tile--primary">
                  <Icon name="tasks" size="20" color="currentColor" />
                </view>
                <text class="quick-action-label">Assign</text>
              </view>
              <view class="quick-action-tile" @click="handleMachineStatus">
                <view class="icon-tile icon-tile--success">
                  <Icon name="machines" size="20" color="currentColor" />
                </view>
                <text class="quick-action-label">Status</text>
              </view>
              <view class="quick-action-tile" @click="handleInventoryUpdate">
                <view class="icon-tile icon-tile--warning">
                  <Icon name="inventory" size="20" color="currentColor" />
                </view>
                <text class="quick-action-label">Stock</text>
              </view>
            </Grid>
          </view>
        </Motion>

        <!-- 4. Task Queue -->
        <Motion preset="fade-up" :index="4">
          <Card title="Task Queue" accent="primary" icon="tasks" padding="none">
            <view class="task-queue">
              <view class="task-item" v-for="task in recentTasks" :key="task.taskId">
                <view class="task-info">
                  <text class="task-title">{{ task.taskCode }}</text>
                  <text class="task-assignee">
                    {{ getTaskTypeText(task.productTypeId) }} · {{ task.userName || 'Unassigned' }}
                  </text>
                </view>
                <Badge :variant="getTaskStatusVariant(task.taskStatus)">
                  {{ getTaskStatusText(task.taskStatus) }}
                </Badge>
              </view>
              <view v-if="recentTasks.length === 0" class="empty-state">
                <text class="empty-text">No recent tasks</text>
              </view>
              <view class="see-all-row" @click="goTo('/pages/manage/task/index')">
                <text class="see-all-label">See all tasks</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </view>
          </Card>
        </Motion>

        <!-- 5. Machine Status -->
        <Motion preset="fade-up" :index="5">
          <Card title="Machine Status" accent="success" icon="machines" padding="none">
            <view class="machine-status-overview">
              <view class="status-item">
                <view class="status-indicator online"></view>
                <text class="status-label">Online</text>
                <text class="status-count">{{ onlineMachines }}</text>
              </view>
              <view class="status-item">
                <view class="status-indicator offline"></view>
                <text class="status-label">Offline</text>
                <text class="status-count">{{ offlineMachines }}</text>
              </view>
              <view class="status-item">
                <view class="status-indicator maintenance"></view>
                <text class="status-label">Maintenance</text>
                <text class="status-count">{{ maintenanceMachines }}</text>
              </view>
              <view class="status-item">
                <view class="status-indicator error"></view>
                <text class="status-label">Error</text>
                <text class="status-count">{{ errorMachines }}</text>
              </view>
            </view>
            <view class="see-all-row" @click="goTo('/pages/manage/vm/index')">
              <text class="see-all-label">See all machines</text>
              <Icon name="chevron-right" size="16" />
            </view>
          </Card>
        </Motion>

        <!-- 6. Inventory Levels -->
        <Motion preset="fade-up" :index="6">
          <Card title="Inventory Levels" accent="warning" icon="inventory" padding="none">
            <view class="inventory-levels">
              <view class="inventory-item" v-for="item in inventoryItems" :key="item.id">
                <view class="inventory-header">
                  <view class="inventory-info">
                    <text class="inventory-name">{{ item.name }}</text>
                  </view>
                  <view class="inventory-stats">
                    <text class="stat-highlight" :class="{ 'text-danger': isInventoryLow(item) }">{{ inventoryStock(item) }}</text>
                    <text class="stat-label">{{ inventoryCapacityLabel(item) }}</text>
                  </view>
                </view>
                <view class="inventory-progress">
                  <ProgressBar
                    :value="inventoryStock(item)"
                    :max="inventoryMax(item)"
                    :color="isInventoryLow(item) ? 'error' : 'primary'"
                  />
                </view>
              </view>
              <view class="see-all-row" @click="goTo('/pages/inventory/index')">
                <text class="see-all-label">See all inventory</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </view>
          </Card>
        </Motion>

        <!-- 7. Team Workload -->
        <Motion preset="fade-up" :index="7">
          <Card title="Team Workload" accent="secondary" icon="users" padding="none">
            <view class="team-workload">
              <view class="team-member" v-for="member in teamMembers" :key="member.id">
                <view class="member-header">
                  <view class="member-info">
                    <Avatar :src="member.avatar" :text="memberInitial(member)" size="sm" />
                    <text class="member-name">{{ member.name }}</text>
                  </view>
                  <view class="member-stats">
                    <text class="stat-highlight">{{ teamCompleted(member) }}</text>
                    <text class="stat-label">{{ teamTasksLabel(member) }}</text>
                  </view>
                </view>
                <view class="member-progress">
                  <ProgressBar :value="teamCompleted(member)" :max="teamTotalTasks(member)" />
                </view>
              </view>
              <view class="see-all-row" @click="goTo('/pages/manage/emp/index')">
                <text class="see-all-label">See all team</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </view>
          </Card>
        </Motion>

        <!-- 8. Hot Products (insight) -->
        <Motion preset="fade-up" :index="8">
          <Card title="Hot Products" accent="primary" icon="trending-up" padding="none" class="hot-products-section">
            <view class="ranking-list">
              <view
                v-for="(item, index) in hotProducts"
                :key="index"
                class="ranking-item"
              >
                <view class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</view>
                <view class="product-name-wrap">
                  <text class="product-name">{{ hotProductLabel(item) }}</text>
                </view>
                <text class="product-count">{{ item.count }} orders</text>
              </view>
            </view>
            <view class="see-all-row" @click="goTo('/pages/analytics/index')">
              <text class="see-all-label">See full analytics</text>
              <Icon name="chevron-right" size="16" />
            </view>
          </Card>
        </Motion>
      </view>
    </scroll-view>
  </view>
  <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />
  <SearchOverlay
    v-model:visible="showSearch"
    @search="handleSearchQuery"
    @result-click="handleSearchResult"
  />
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Avatar from '@/components/ui/Avatar.vue'
import StatCard from '@/components/ui/StatCard.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Grid from '@/components/ui/Grid.vue'
import Icon from '@/components/ui/Icon.vue'
import Badge from '@/components/ui/Badge.vue'
import ProgressBar from '@/components/ui/ProgressBar.vue'
import Motion from '@/components/ui/Motion.vue'
import useUserStore from '@/store/modules/user'
import { getDashboardStats, getHotProducts, getAbnormalEquipment, getProductStats, getMachineStatusStats, getInventoryLevels, getTeamWorkload, getRevenueByWeekday } from '@/api/report'
import { listNode } from '@/api/manage/node'
import { listVm } from '@/api/manage/vm'
import { listEmp } from '@/api/manage/emp'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { listVmType } from '@/api/manage/vmType'
import { listTask } from '@/api/manage/task'
import { getInfo } from '@/api/login'
import { getTaskStatusText, getTaskStatusVariant, getTaskTypeText, TASK_STATUS } from '@/utils/task'
const userStore = useUserStore()

// Navigation
const activeTab = ref('dashboard')
const showSearch = ref(false)

// Profile
const userName = computed(() => userStore.name)
const profilePicture = computed(() => userStore.avatar || '')
const unreadCount = ref(0)

// Dashboard counts
const nodeCount = ref(0)
const deviceCount = ref(0)
const empCount = ref(0)
const regionCount = ref(0)
const partnerCount = ref(0)
const vmTypeCount = ref(0)
const onlineMachines = ref(0)
const totalProducts = ref(0)
const lowStockCount = ref(0)

// Business analytics
const totalRevenue = ref('¥0')
const totalOrders = ref(0)
const activeMachines = ref(0)
const pendingTasks = ref(0)

// Admin dashboard data
const totalMachines = ref(0)
const teamCount = ref(0)
const offlineMachines = ref(0)
const maintenanceMachines = ref(0)
const errorMachines = ref(0)
const recentTasks = ref([])
const inventoryItems = ref([])
const teamMembers = ref([])

const WEEKDAY_LABELS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

const emptyWeekRevenue = () =>
  WEEKDAY_LABELS.map((label, weekday) => ({ weekday, label, revenue: 0 }))

const weeklyRevenueByDay = ref(emptyWeekRevenue())

// Hot products
const hotProducts = ref([])

const hotProductLabel = (item) =>
  item?.skuName || item?.sku_name || item?.SKU_NAME || '—'

const toFiniteNumber = (v, fallback = 0) => {
  const n = Number(v)
  return Number.isFinite(n) ? n : fallback
}

const inventoryStock = (item) => toFiniteNumber(item?.stock)
const inventoryMax = (item) => toFiniteNumber(item?.maxStock)

const isInventoryLow = (item) => {
  const max = inventoryMax(item)
  if (max <= 0) return false
  return inventoryStock(item) < max * 0.2
}

const inventoryCapacityLabel = (item) => {
  const max = inventoryMax(item)
  if (max <= 0) return ' (no capacity)'
  return ` / ${max} Units`
}

const teamCompleted = (member) => toFiniteNumber(member?.tasksCompleted)
const teamTotalTasks = (member) => toFiniteNumber(member?.totalTasks)

const teamTasksLabel = (member) => {
  const total = teamTotalTasks(member)
  if (total <= 0) return ' (no tasks)'
  return ` / ${total} Tasks`
}

const memberInitial = (member) => String(member?.name || '?').charAt(0)

// Abnormal equipment
const abnormalEquipment = ref([])

const fetchUserInfo = async () => {
  try {
    const response = await getInfo()
    if (response && response.user) {
      userStore.setUserInfo({
        name: response.user.nickName || response.user.userName,
        avatar: response.user.avatar,
        roles: response.roles,
        permissions: response.permissions
      })
    }
  } catch (error) {
    console.error('Failed to fetch user info', error)
  }
}

const fetchWeeklyRevenue = async () => {
  try {
    const res = await getRevenueByWeekday()
    if (Array.isArray(res.data) && res.data.length > 0) {
      const base = emptyWeekRevenue()
      res.data.forEach((row, i) => {
        const idx = row.weekday != null ? Number(row.weekday) : i
        if (idx >= 0 && idx < 7) {
          base[idx] = {
            weekday: idx,
            label: String(row.label || WEEKDAY_LABELS[idx]),
            revenue: Number(row.revenue) || 0
          }
        }
      })
      weeklyRevenueByDay.value = base
      return
    }
  } catch (e) {
    console.error('Failed to fetch weekly revenue', e)
  }
  weeklyRevenueByDay.value = emptyWeekRevenue()
}

const formatWeekRevenue = (n) => {
  const v = Number(n) || 0
  if (v >= 100000) return `¥${(v / 10000).toFixed(1)}w`
  if (v >= 10000) return `¥${Math.round(v / 1000)}k`
  if (v >= 1000) return `¥${(v / 1000).toFixed(1)}k`
  return `¥${v}`
}

// Relative to this week: tallest day = 100%, others linear (fractional % so small days are not rounded to 0).
const weekBarHeightPct = (amount) => {
  const nums = weeklyRevenueByDay.value.map((d) => Number(d.revenue) || 0)
  const max = Math.max(...nums, 0)
  const v = Number(amount) || 0
  if (v <= 0 || max <= 0) return 0
  const pct = (v / max) * 100
  return Math.min(100, Number(pct.toFixed(1)))
}

const fetchDashboardCounts = async () => {
  try {
    const [nodes, devices, emps, regions, partners, vmTypes, dashboardStats, productStats] = await Promise.all([
      listNode({ pageNum: 1, pageSize: 1 }),
      listVm({ pageNum: 1, pageSize: 1 }),
      listEmp({ pageNum: 1, pageSize: 1 }),
      listRegion({ pageNum: 1, pageSize: 1 }),
      listPartner({ pageNum: 1, pageSize: 1 }),
      listVmType({ pageNum: 1, pageSize: 1 }),
      getDashboardStats(),
      getProductStats()
    ])

    nodeCount.value = nodes.total || 0
    deviceCount.value = devices.total || 0
    empCount.value = emps.total || 0
    regionCount.value = regions.total || 0
    partnerCount.value = partners.total || 0
    vmTypeCount.value = vmTypes.total || 0
    onlineMachines.value = Math.floor((deviceCount.value || 0) * 0.95)
    
    // Update dashboard stats from backend
    if (dashboardStats.data) {
      totalRevenue.value = `¥${dashboardStats.data.totalRevenue || 0}`
      totalOrders.value = dashboardStats.data.totalOrders || 0
      activeMachines.value = dashboardStats.data.activeMachines || 0
    }
    
    // Update product stats from backend
    if (productStats.data) {
      totalProducts.value = productStats.data.totalProducts || 0
      lowStockCount.value = productStats.data.lowStockCount || 0
    }
  } catch (error) {
    console.error('Failed to fetch dashboard counts', error)
  }
}

const fetchHotProducts = async () => {
  try {
    const response = await getHotProducts()
    if (response.data) {
      hotProducts.value = response.data
    }
  } catch (error) {
    console.error('Failed to fetch hot products', error)
  }
}

const fetchAbnormalEquipment = async () => {
  try {
    const response = await getAbnormalEquipment()
    if (response.data) {
      abnormalEquipment.value = response.data
    }
  } catch (error) {
    console.error('Failed to fetch abnormal equipment', error)
  }
}

const fetchAdminDashboardData = async () => {
  try {
    const [machineStatus, inventoryLevels, teamWorkload] = await Promise.all([
      getMachineStatusStats(),
      getInventoryLevels(),
      getTeamWorkload()
    ])

    if (machineStatus.data) {
      offlineMachines.value = machineStatus.data.offline || 0
      maintenanceMachines.value = machineStatus.data.maintenance || 0
      errorMachines.value = machineStatus.data.error || 0
      totalMachines.value = (machineStatus.data.online || 0) + offlineMachines.value + maintenanceMachines.value + errorMachines.value
      onlineMachines.value = machineStatus.data.online || 0
    }

    if (inventoryLevels.data) {
      inventoryItems.value = inventoryLevels.data
    }

    if (teamWorkload.data) {
      teamMembers.value = teamWorkload.data
      teamCount.value = teamWorkload.data.length || 0
    }
  } catch (error) {
    console.error('Failed to fetch admin dashboard data', error)
  }
}

const fetchTaskSnapshot = async () => {
  try {
    const [pendingResponse, recentResponse] = await Promise.all([
      listTask({
        pageNum: 1,
        pageSize: 1,
        taskStatus: TASK_STATUS.pending,
        orderByColumn: 'createTime',
        isAsc: 'desc'
      }),
      listTask({
        pageNum: 1,
        pageSize: 5,
        orderByColumn: 'createTime',
        isAsc: 'desc'
      })
    ])

    pendingTasks.value = pendingResponse.total || 0
    recentTasks.value = recentResponse.rows || []
  } catch (error) {
    console.error('Failed to fetch task snapshot', error)
  }
}

onMounted(() => {
  fetchUserInfo()
  fetchDashboardCounts()
  fetchWeeklyRevenue()
  fetchHotProducts()
  fetchAbnormalEquipment()
  fetchTaskSnapshot()
  fetchAdminDashboardData()
})

onShow(() => {
  if (!userStore.token) {
    uni.reLaunch({ url: '/pages/login/index' })
  }
})

const goTo = (url) => {
  uni.navigateTo({ url })
}

const handleBulkAssign = () => {
  uni.navigateTo({ url: '/pages/manage/task/index' })
}

const handleMachineStatus = () => {
  uni.navigateTo({ url: '/pages/manage/vm/index' })
}

const handleInventoryUpdate = () => {
  uni.navigateTo({ url: '/pages/inventory/index' })
}

const handleAdd = () => {
  // Handle add action
}

const handleSearch = () => {
  showSearch.value = true
}

const handleSearchQuery = (query) => {
  // Handle search query
}

const handleSearchResult = (result) => {
  // Handle search result click
}

const handleNotification = () => {
  goTo('/pages/notifications/index')
}

const handleProfile = () => {
  goTo('/pages/mine/index')
}

const handleTabChange = (tabId) => {
  activeTab.value = tabId
  // Navigate to respective page
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'dashboard') {
    uni.navigateTo({ url: routes[tabId] })
  }
}

</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.content-wrapper {
  padding-left: $spacing-4;
  padding-right: $spacing-4;
  box-sizing: border-box;
}

.week-revenue-card {
  margin-bottom: $spacing-4;
  cursor: pointer;
  @include interactive-pressable(0.99);
}

.week-bar-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: $spacing-1;
  min-height: 128px;
  padding-top: $spacing-1;
}

.week-bar-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: $spacing-2;
  min-width: 0;
}

.week-bar-value {
  @include text-caption;
  font-size: 10px;
  color: $color-text-tertiary;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
}

/* Fixed height so % heights on .week-bar-fill resolve (min-height alone breaks percentage layout). */
.week-bar-track {
  width: 100%;
  height: 96px;
  min-height: 96px;
  flex-shrink: 0;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.week-bar-fill {
  width: 100%;
  max-width: 22px;
  min-height: 0;
  border-radius: $radius-sm $radius-sm 0 0;
  background: $color-primary;

  /* Only when revenue > 0: tiny % heights still need a visible sliver */
  &--has-value {
    min-height: 5px;
  }
}

.week-bar-label {
  @include text-caption;
  font-size: 10px;
  font-weight: $font-weight-semibold;
  color: $color-text-secondary;
}

.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin-top: $spacing-5;
  margin-bottom: $spacing-3;
  display: block;

  &:first-child {
    margin-top: 0;
  }
}

.quick-stats {
  margin-bottom: 0;
}

.stat-card-link {
  cursor: pointer;
  transition: transform $transition-fast;

  &:active {
    transform: scale(0.98);
    opacity: 0.85;
  }
}

.quick-actions {
  margin-bottom: 0;
}

.machine-status-overview {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.status-item {
  display: flex;
  align-items: center;
  gap: $spacing-3;
}

.status-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  
  &.online {
    background: $color-success;
  }
  
  &.offline {
    background: $color-text-tertiary;
  }
  
  &.maintenance {
    background: $color-warning;
  }
  
  &.error {
    background: $color-error;
  }
}

.status-label {
  @include text-body;
  color: $color-text-secondary;
  flex: 1;
}

.status-count {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.task-queue {
  display: flex;
  flex-direction: column;
}

.see-all-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-4 0 0;
  margin-top: 0;
  cursor: pointer;
  color: $color-primary;

  &:active {
    opacity: 0.7;
  }
}

.see-all-label {
  @include text-body;
  color: $color-primary;
  font-weight: $font-weight-medium;
}

.task-item {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-4 0;
  border-bottom: 1px solid $color-border-subtle;

  &:first-child {
    padding-top: 0;
  }

  &:last-child {
    padding-bottom: 0;
    border-bottom: none;
  }
}

.task-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}

.task-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.task-assignee {
  @include text-caption;
  color: $color-text-secondary;
}

.inventory-levels {
  display: flex;
  flex-direction: column;
}

.inventory-item {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  padding: $spacing-4 0;
  border-bottom: 1px solid $color-border-subtle;

  &:first-child {
    padding-top: 0;
  }

  &:last-child {
    padding-bottom: 0;
    border-bottom: none;
  }
}

.inventory-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.inventory-info {
  display: flex;
  align-items: center;
}

.inventory-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.inventory-stats {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.inventory-progress {
  width: 100%;
}

.text-danger {
  color: $color-error !important;
}

.team-workload {
  display: flex;
  flex-direction: column;
}

.team-member {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  padding: $spacing-4 0;
  border-bottom: 1px solid $color-border-subtle;

  &:first-child {
    padding-top: 0;
  }

  &:last-child {
    padding-bottom: 0;
    border-bottom: none;
  }
}

.member-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.member-info {
  display: flex;
  align-items: center;
  gap: $spacing-3;
}

.member-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  max-width: 120px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.member-stats {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.stat-highlight {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.stat-label {
  @include text-caption;
  color: $color-text-secondary;
}

.member-progress {
  width: 100%;
}

.profile-section {
  display: flex;
  align-items: center;
  gap: $spacing-4;
  margin-bottom: $spacing-6;
  padding: $spacing-4;
  background: $color-bg-tertiary;
  border-radius: $radius-lg;
}

.profile-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}

.user-name {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.user-role {
  @include text-caption;
  color: $color-text-secondary;
}

.analytics-section {
  margin-bottom: $spacing-6;
}

.chart-section {
  margin-bottom: $spacing-6;
}

.chart-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.chart-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  gap: $spacing-3;
  
  .placeholder-text {
    @include text-caption;
    color: $color-text-tertiary;
  }
}

.section-cards {
  margin-bottom: 0;
}

.hot-products-section,
.abnormal-section {
  margin-bottom: 0;
}

.ranking-list {
  display: flex;
  flex-direction: column;
}

.ranking-item {
  display: flex;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;
}

.rank-badge {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: $font-weight-bold;
  color: $color-text-tertiary;
  margin-right: $spacing-3;
  background: $color-bg-elevated;

  &.rank-1 {
    background: $color-warning;
    color: $color-text-primary;
  }

  &.rank-2 {
    background: $color-text-secondary;
    color: $color-bg-primary;
  }

  &.rank-3 {
    background: $color-bg-elevated;
    color: $color-text-secondary;
    border: 1px solid $color-border-medium;
  }
}

.product-name-wrap {
  flex: 1;
  min-width: 0;
}

.product-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.product-count {
  @include text-caption;
  color: $color-primary;
  font-weight: $font-weight-semibold;
}

.equipment-item {
  display: flex;
  flex-direction: column;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;
  cursor: pointer;
  transition: background-color $transition-normal;

  &:active {
    background: $color-bg-elevated;
  }
}

.equipment-time {
  @include text-caption;
  color: $color-text-secondary;
  margin-bottom: $spacing-1;
}

.equipment-addr {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
  margin-bottom: $spacing-1;
}

.equipment-code {
  @include text-caption;
  color: $color-error;
  font-weight: $font-weight-semibold;
}

.empty-state {
  padding: $spacing-8 0;
  text-align: center;
}

.empty-text {
  @include text-body;
  color: $color-text-tertiary;
}
</style>
