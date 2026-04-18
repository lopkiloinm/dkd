<template>
  <AppTopBar
    :unread-count="unreadCount"
    :profile-picture="profilePicture"
    :user-name="userName"
    @search="handleSearch"
    @notification="handleNotification"
  />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <!-- 1. Operations Overview -->
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

        <!-- 2. Real-Time Alerts -->
        <template v-if="alerts.length > 0">
        <text class="section-title">Real-Time Alerts</text>
        <view class="alerts-section">
          <view class="alerts-list">
            <Alert
              v-for="alert in alerts"
              :key="alert.id"
              :variant="alert.variant"
              @dismiss="dismissAlert(alert.id)"
            >
              <text class="alert-message">{{ alert.message }}</text>
            </Alert>
          </view>
        </view>
        </template>

        <!-- 3. Abnormal Equipment (urgent, actionable) -->
        <text class="section-title">Abnormal Equipment</text>
        <view class="abnormal-section">
          <Card padding="none">
            <CardSection variant="body">
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
            </CardSection>
          </Card>
        </view>

        <!-- 4. Quick Actions -->
        <text class="section-title">Quick Actions</text>
        <view class="quick-actions">
          <Grid :columns="4" :gap="16">
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
            <view class="quick-action-tile" @click="handleEmergency">
              <view class="icon-tile icon-tile--error">
                <Icon name="alert" size="20" color="currentColor" />
              </view>
              <text class="quick-action-label">Alert</text>
            </view>
          </Grid>
        </view>

        <!-- 5. Task Queue -->
        <text class="section-title">Task Queue</text>
        <Card padding="none">
          <CardSection variant="body">
            <view class="task-queue">
              <view class="task-item" v-for="task in recentTasks" :key="task.id">
                <view class="task-info">
                  <text class="task-title">{{ task.title }}</text>
                  <text class="task-assignee">{{ task.assignee }}</text>
                </view>
                <Badge :variant="task.priority === 'high' ? 'error' : task.priority === 'medium' ? 'warning' : 'default'">
                  {{ task.priority.charAt(0).toUpperCase() + task.priority.slice(1) }}
                </Badge>
              </view>
              <view class="see-all-row" @click="goTo('/pages/manage/task/index')">
                <text class="see-all-label">See all tasks</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- 6. Machine Status -->
        <text class="section-title">Machine Status</text>
        <Card padding="none">
          <CardSection variant="body">
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
          </CardSection>
        </Card>

        <!-- 7. Inventory Levels -->
        <text class="section-title">Inventory Levels</text>
        <Card padding="none">
          <CardSection variant="body">
            <view class="inventory-levels">
              <view class="inventory-item" v-for="item in inventoryItems" :key="item.id">
                <view class="inventory-header">
                  <view class="inventory-info">
                    <text class="inventory-name">{{ item.name }}</text>
                  </view>
                  <view class="inventory-stats">
                    <text class="stat-highlight" :class="{ 'text-danger': item.stock < item.maxStock * 0.2 }">{{ item.stock }}</text>
                    <text class="stat-label">/ {{ item.maxStock }} Units</text>
                  </view>
                </view>
                <view class="inventory-progress">
                  <ProgressBar :value="item.stock" :max="item.maxStock" :color="item.stock < item.maxStock * 0.2 ? 'error' : 'primary'" />
                </view>
              </view>
              <view class="see-all-row" @click="goTo('/pages/inventory/index')">
                <text class="see-all-label">See all inventory</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- 8. Team Workload -->
        <text class="section-title">Team Workload</text>
        <Card padding="none">
          <CardSection variant="body">
            <view class="team-workload">
              <view class="team-member" v-for="member in teamMembers" :key="member.id">
                <view class="member-header">
                  <view class="member-info">
                    <Avatar :src="member.avatar" :text="member.name.charAt(0)" size="sm" />
                    <text class="member-name">{{ member.name }}</text>
                  </view>
                  <view class="member-stats">
                    <text class="stat-highlight">{{ member.tasksCompleted }}</text>
                    <text class="stat-label">/ {{ member.totalTasks }} Tasks</text>
                  </view>
                </view>
                <view class="member-progress">
                  <ProgressBar :value="member.tasksCompleted" :max="member.totalTasks" />
                </view>
              </view>
              <view class="see-all-row" @click="goTo('/pages/manage/emp/index')">
                <text class="see-all-label">See all team</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- 9. Hot Products (insight) -->
        <text class="section-title">Hot Products</text>
        <view class="hot-products-section">
          <Card padding="none">
            <CardSection variant="body">
              <view class="ranking-list">
                <view
                  v-for="(item, index) in hotProducts"
                  :key="index"
                  class="ranking-item"
                >
                  <view class="rank-badge" :class="'rank-' + (index + 1)">{{ index + 1 }}</view>
                  <text class="product-name">{{ item.skuName }}</text>
                  <text class="product-count">{{ item.count }} orders</text>
                </view>
              </view>
              <view class="see-all-row" @click="goTo('/pages/analytics/index')">
                <text class="see-all-label">See full analytics</text>
                <Icon name="chevron-right" size="16" />
              </view>
            </CardSection>
          </Card>
        </view>
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
import ChartCard from '@/components/app/ChartCard.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Grid from '@/components/ui/Grid.vue'
import Chart from '@/components/ui/Chart.vue'
import SegmentedControl from '@/components/ui/SegmentedControl.vue'
import Icon from '@/components/ui/Icon.vue'
import Alert from '@/components/ui/Alert.vue'
import Badge from '@/components/ui/Badge.vue'
import ProgressBar from '@/components/ui/ProgressBar.vue'
import useUserStore from '@/store/modules/user'
import { getDashboardStats, getHotProducts, getAbnormalEquipment, getTaskStats, getProductStats, getMachineStatusStats, getRealTimeAlerts, getRecentTasks, getInventoryLevels, getTeamWorkload } from '@/api/report'
import { listNode } from '@/api/manage/node'
import { listVm } from '@/api/manage/vm'
import { listEmp } from '@/api/manage/emp'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { listVmType } from '@/api/manage/vmType'
import { getInfo } from '@/api/login'

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
const alerts = ref([])
const offlineMachines = ref(0)
const maintenanceMachines = ref(0)
const errorMachines = ref(0)
const recentTasks = ref([])
const inventoryItems = ref([])
const teamMembers = ref([])

// Chart
const selectedTimeRange = ref('week')
const timeRangeOptions = [
  { label: 'Day', value: 'day' },
  { label: 'Week', value: 'week' },
  { label: 'Month', value: 'month' }
]

// Hot products
const hotProducts = ref([])

// Abnormal equipment
const abnormalEquipment = ref([])

// Work order stats
const completedOrders = ref(0)
const inProgressOrders = ref(0)
const cancelledOrders = ref(0)

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
      pendingTasks.value = dashboardStats.data.pendingTasks || 0
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

const fetchTaskStats = async () => {
  try {
    const response = await getTaskStats()
    if (response.data) {
      completedOrders.value = response.data.completedOrders || 0
      inProgressOrders.value = response.data.inProgressOrders || 0
      cancelledOrders.value = response.data.cancelledOrders || 0
    }
  } catch (error) {
    console.error('Failed to fetch task stats', error)
  }
}

const fetchAdminDashboardData = async () => {
  try {
    const [machineStatus, realTimeAlerts, recentTasksData, inventoryLevels, teamWorkload] = await Promise.all([
      getMachineStatusStats(),
      getRealTimeAlerts(),
      getRecentTasks(),
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

    if (realTimeAlerts.data) {
      alerts.value = realTimeAlerts.data
    }

    if (recentTasksData.data) {
      recentTasks.value = recentTasksData.data
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

onMounted(() => {
  fetchUserInfo()
  fetchDashboardCounts()
  fetchHotProducts()
  fetchAbnormalEquipment()
  fetchTaskStats()
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

const dismissAlert = (id) => {
  alerts.value = alerts.value.filter(alert => alert.id !== id)
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

const handleEmergency = () => {
  uni.showModal({
    title: 'Emergency Mode',
    content: 'This will show all machines with fault status. Continue?',
    success: (r) => {
      if (r.confirm) {
        uni.navigateTo({ url: '/pages/manage/vm/index?vmStatus=3' })
      }
    }
  })
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

const handleTimeRangeChange = (value) => {
  // Handle time range change for chart
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $color-bg-primary;
  padding-top: $top-bar-total-height;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.content-wrapper {
  padding: $spacing-4 $spacing-4 calc($spacing-6 + #{$bottom-bar-height} + env(safe-area-inset-bottom, 0px)) $spacing-4;
  box-sizing: border-box;
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

.alerts-section {
  margin-bottom: 0;
}

.alerts-list {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.alert-message {
  @include text-body;
  color: $color-text-primary;
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
  color: $color-primary;
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
    background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
    color: white;
  }

  &.rank-2 {
    background: linear-gradient(135deg, #C0C0C0 0%, #A8A8A8 100%);
    color: white;
  }

  &.rank-3 {
    background: linear-gradient(135deg, #CD7F32 0%, #B87333 100%);
    color: white;
  }
}

.product-name {
  flex: 1;
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
