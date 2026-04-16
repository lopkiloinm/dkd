<template>
  <AppTopBar
    :unread-count="unreadCount"
    :profile-picture="profilePicture"
    :user-name="userName"
    @add="handleAdd"
    @search="handleSearch"
    @notification="handleNotification"
    @profile="handleProfile"
  />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <!-- Time Range Selector -->
        <view class="time-range-selector">
          <SegmentedControl
            :options="timeRangeOptions"
            v-model="selectedTimeRange"
            @change="handleTimeRangeChange"
          />
        </view>

        <!-- Revenue Overview -->
        <view class="section">
          <text class="section-title">Revenue Overview</text>
          <Card>
            <CardSection variant="body">
              <view class="revenue-overview">
                <text class="revenue-value">${{ totalRevenue }}</text>
                <view class="revenue-change">
                  <Icon :name="revenueTrend === 'up' ? 'trend-up' : revenueTrend === 'down' ? 'trend-down' : 'trend-neutral'" size="16" :color="revenueTrendColor" />
                  <text class="revenue-change-value" :style="{ color: revenueTrendColor }">{{ revenueChange }}</text>
                </view>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Financial Metrics -->
        <text class="section-title">Financial Metrics</text>
        <Grid :columns="2" :gap="16">
          <StatCard
            label="Total Revenue"
            :value="totalRevenue"
            trend="+12.5%"
            trend-direction="up"
            variant="primary"
          />
          <StatCard
            label="Total Costs"
            :value="totalCosts"
            trend="+5.2%"
            trend-direction="up"
            variant="warning"
          />
          <StatCard
            label="Net Profit"
            :value="netProfit"
            trend="+18.3%"
            trend-direction="up"
            variant="success"
          />
          <StatCard
            label="Profit Margin"
            :value="profitMargin"
            trend="+2.1%"
            trend-direction="up"
            variant="default"
          />
        </Grid>

        <!-- Cost Breakdown -->
        <text class="section-title">Cost Breakdown</text>
        <Card>
          <CardSection variant="body">
            <view class="cost-breakdown">
              <view class="cost-item" v-for="cost in costBreakdown" :key="cost.category">
                <view class="cost-info">
                  <text class="cost-category">{{ cost.category }}</text>
                  <text class="cost-percentage">{{ cost.percentage }}%</text>
                </view>
                <ProgressBar :value="cost.amount" :max="totalCosts" :variant="cost.variant" />
                <text class="cost-amount">${{ cost.amount }}</text>
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- Revenue by Location -->
        <text class="section-title">Revenue by Location</text>
        <Card>
          <CardSection variant="body">
            <view class="location-revenue">
              <view class="location-item" v-for="location in locationRevenue" :key="location.id">
                <text class="location-name">{{ location.name }}</text>
                <ProgressBar :value="location.revenue" :max="maxLocationRevenue" />
                <text class="location-amount">${{ location.revenue }}</text>
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- Partner Performance -->
        <text class="section-title">Partner Performance</text>
        <Card>
          <CardSection variant="body">
            <view class="partner-performance">
              <view class="partner-item" v-for="partner in partnerPerformance" :key="partner.id">
                <text class="partner-name">{{ partner.name }}</text>
                <view class="partner-metrics">
                  <text class="partner-revenue">${{ partner.revenue }}</text>
                  <text class="partner-roi">ROI: {{ partner.roi }}</text>
                </view>
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- Performance KPIs -->
        <text class="section-title">Performance KPIs</text>
        <Grid :columns="2" :gap="16">
          <Card>
            <CardSection variant="body">
              <text class="kpi-label">Machine Uptime</text>
              <text class="kpi-value">{{ machineUptime }}%</text>
              <text class="kpi-trend" :class="{ positive: uptimeTrend > 0, negative: uptimeTrend < 0 }">{{ uptimeTrend > 0 ? '+' : '' }}{{ uptimeTrend }}%</text>
            </CardSection>
          </Card>
          <Card>
            <CardSection variant="body">
              <text class="kpi-label">Revenue Per Machine</text>
              <text class="kpi-value">${{ revenuePerMachine }}</text>
              <text class="kpi-trend" :class="{ positive: rpmTrend > 0, negative: rpmTrend < 0 }">{{ rpmTrend > 0 ? '+' : '' }}{{ rpmTrend }}%</text>
            </CardSection>
          </Card>
          <Card>
            <CardSection variant="body">
              <text class="kpi-label">Task Completion Rate</text>
              <text class="kpi-value">{{ taskCompletionRate }}%</text>
              <text class="kpi-trend" :class="{ positive: taskTrend > 0, negative: taskTrend < 0 }">{{ taskTrend > 0 ? '+' : '' }}{{ taskTrend }}%</text>
            </CardSection>
          </Card>
          <Card>
            <CardSection variant="body">
              <text class="kpi-label">Customer Satisfaction</text>
              <text class="kpi-value">{{ customerSatisfaction }}/5.0</text>
              <text class="kpi-trend" :class="{ positive: csatTrend > 0, negative: csatTrend < 0 }">{{ csatTrend > 0 ? '+' : '' }}{{ csatTrend }}%</text>
            </CardSection>
          </Card>
        </Grid>

        <!-- Analytics Tabs -->
        <view class="analytics-tabs">
          <view
            v-for="tab in analyticsTabs"
            :key="tab.id"
            :class="['analytics-tab', { active: activeAnalyticsTab === tab.id }]"
            @click="handleAnalyticsTab(tab.id)"
          >
            <Icon :name="tab.icon" size="16" color="currentColor" />
            <text class="analytics-tab-text">{{ tab.label }}</text>
          </view>
        </view>

        <!-- Sales Chart -->
        <view v-if="activeAnalyticsTab === 'sales'" class="chart-section">
          <text class="section-title">Sales Trend</text>
          <Card>
            <CardSection variant="body">
              <view class="chart-placeholder">
                <Icon name="bar-chart" size="48" color="currentColor" />
                <text class="chart-placeholder-text">Sales chart will be rendered here</text>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Orders Chart -->
        <view v-if="activeAnalyticsTab === 'orders'" class="chart-section">
          <text class="section-title">Orders Trend</text>
          <Card>
            <CardSection variant="body">
              <view class="chart-placeholder">
                <Icon name="line-chart" size="48" color="currentColor" />
                <text class="chart-placeholder-text">Orders chart will be rendered here</text>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Products Chart -->
        <view v-if="activeAnalyticsTab === 'products'" class="chart-section">
          <text class="section-title">Top Products</text>
          <Card>
            <CardSection variant="body">
              <view class="chart-placeholder">
                <Icon name="pie-chart" size="48" color="currentColor" />
                <text class="chart-placeholder-text">Products chart will be rendered here</text>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Machines Chart -->
        <view v-if="activeAnalyticsTab === 'machines'" class="chart-section">
          <text class="section-title">Machine Performance</text>
          <Card>
            <CardSection variant="body">
              <view class="chart-placeholder">
                <Icon name="activity" size="48" color="currentColor" />
                <text class="chart-placeholder-text">Machine performance chart will be rendered here</text>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Key Metrics -->
        <view class="metrics-section">
          <text class="section-title">Key Metrics</text>
          <Grid :columns="2" :gap="16">
            <StatCard
              label="Total Orders"
              :value="totalOrders"
              trend="+12.5%"
              trend-direction="up"
              variant="default"
            />
            <StatCard
              label="Avg Order Value"
              :value="avgOrderValue"
              trend="+5.2%"
              trend-direction="up"
              variant="default"
            />
            <StatCard
              label="Active Machines"
              :value="activeMachines"
              trend="95%"
              trend-direction="neutral"
              variant="default"
            />
            <StatCard
              label="Conversion Rate"
              :value="conversionRate"
              trend="-2.1%"
              trend-direction="down"
              variant="default"
            />
          </Grid>
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
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/store/modules/user'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Icon from '@/components/ui/Icon.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import StatCard from '@/components/ui/StatCard.vue'
import Grid from '@/components/ui/Grid.vue'
import SegmentedControl from '@/components/ui/SegmentedControl.vue'
import ProgressBar from '@/components/ui/ProgressBar.vue'
import { getInfo } from '@/api/login'
import { getDashboardStats, getHotProducts, getTaskStats, getProductStats, getFinancialMetrics, getCostBreakdown, getRevenueByLocation, getPartnerPerformance, getPerformanceKPIs } from '@/api/report'

const userStore = useUserStore()

const activeTab = ref('analytics')
const unreadCount = ref(3)
const showSearch = ref(false)
const selectedTimeRange = ref('7d')
const activeAnalyticsTab = ref('sales')

const profilePicture = computed(() => userStore.avatar || '/static/default-avatar.png')
const userName = computed(() => userStore.name)

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

const timeRangeOptions = [
  { id: '7d', label: '7 Days' },
  { id: '30d', label: '30 Days' },
  { id: '90d', label: '90 Days' },
  { id: '1y', label: '1 Year' }
]

const analyticsTabs = [
  { id: 'sales', label: 'Sales', icon: 'dollar-sign' },
  { id: 'orders', label: 'Orders', icon: 'shopping-cart' },
  { id: 'products', label: 'Products', icon: 'box' },
  { id: 'machines', label: 'Machines', icon: 'monitor' }
]

const totalRevenue = ref('$0')
const revenueChange = ref('+0%')
const revenueTrend = ref('up')
const revenueTrendColor = computed(() => {
  if (revenueTrend.value === 'up') return '#10b981'
  if (revenueTrend.value === 'down') return '#ef4444'
  return '#6b7280'
})

const totalCosts = ref('$0')
const netProfit = ref('$0')
const profitMargin = ref('0%')
const costBreakdown = ref([
  { category: 'Inventory', amount: 15000, percentage: 45, variant: 'primary' },
  { category: 'Maintenance', amount: 8000, percentage: 24, variant: 'warning' },
  { category: 'Operations', amount: 6000, percentage: 18, variant: 'default' },
  { category: 'Personnel', amount: 4400, percentage: 13, variant: 'secondary' }
])
const locationRevenue = ref([
  { id: 1, name: 'Downtown', revenue: 25000 },
  { id: 2, name: 'Mall A', revenue: 18000 },
  { id: 3, name: 'Airport', revenue: 15000 },
  { id: 4, name: 'Station', revenue: 12000 }
])
const maxLocationRevenue = computed(() => Math.max(...locationRevenue.value.map(l => l.revenue)))
const partnerPerformance = ref([
  { id: 1, name: 'Partner A', revenue: 35000, roi: '15.2%' },
  { id: 2, name: 'Partner B', revenue: 28000, roi: '12.8%' },
  { id: 3, name: 'Partner C', revenue: 22000, roi: '10.5%' },
  { id: 4, name: 'Partner D', revenue: 15000, roi: '8.3%' }
])

// Performance KPIs data
const machineUptime = ref(95)
const uptimeTrend = ref(2.3)
const revenuePerMachine = ref(1250)
const rpmTrend = ref(8.5)
const taskCompletionRate = ref(92)
const taskTrend = ref(5.2)
const customerSatisfaction = ref(4.5)
const csatTrend = ref(1.2)

const totalOrders = ref(0)
const avgOrderValue = ref('¥0')
const activeMachines = ref(0)
const conversionRate = ref('0%')

const hotProducts = ref([])

const fetchAnalyticsData = async () => {
  try {
    const [dashboardStats, hotProductsData, productStats, financialMetrics, costBreakdownData, revenueByLocationData, partnerPerformanceData, performanceKPIsData] = await Promise.all([
      getDashboardStats(),
      getHotProducts(),
      getProductStats(),
      getFinancialMetrics(),
      getCostBreakdown(),
      getRevenueByLocation(),
      getPartnerPerformance(),
      getPerformanceKPIs()
    ])

    if (dashboardStats.data) {
      totalRevenue.value = `¥${dashboardStats.data.totalRevenue || 0}`
      totalOrders.value = dashboardStats.data.totalOrders || 0
      activeMachines.value = dashboardStats.data.activeMachines || 0
      pendingTasks.value = dashboardStats.data.pendingTasks || 0
    }

    if (hotProductsData.data) {
      hotProducts.value = hotProductsData.data
    }

    if (productStats.data) {
      totalProducts.value = productStats.data.totalProducts || 0
      lowStockCount.value = productStats.data.lowStockCount || 0
    }

    if (financialMetrics.data) {
      totalCosts.value = `¥${financialMetrics.data.totalCosts || 0}`
      netProfit.value = `¥${financialMetrics.data.netProfit || 0}`
      profitMargin.value = financialMetrics.data.profitMargin || '0%'
    }

    if (costBreakdownData.data) {
      costBreakdown.value = costBreakdownData.data
    }

    if (revenueByLocationData.data) {
      locationRevenue.value = revenueByLocationData.data
    }

    if (partnerPerformanceData.data) {
      partnerPerformance.value = partnerPerformanceData.data
    }

    if (performanceKPIsData.data) {
      machineUptime.value = performanceKPIsData.data.machineUptime || 0
      uptimeTrend.value = performanceKPIsData.data.uptimeTrend || 0
      revenuePerMachine.value = performanceKPIsData.data.revenuePerMachine || 0
      rpmTrend.value = performanceKPIsData.data.rpmTrend || 0
      taskCompletionRate.value = performanceKPIsData.data.taskCompletionRate || 0
      taskTrend.value = performanceKPIsData.data.taskTrend || 0
      customerSatisfaction.value = performanceKPIsData.data.customerSatisfaction || 0
      csatTrend.value = performanceKPIsData.data.csatTrend || 0
    }
  } catch (error) {
    console.error('Failed to fetch analytics data', error)
  }
}

const handleAdd = () => {
  uni.navigateTo({ url: '/pages/analytics/custom' })
}

const handleSearch = () => {
  showSearch.value = true
}

const handleNotification = () => {
  uni.navigateTo({ url: '/pages/notification/index' })
}

const handleProfile = () => {
  uni.navigateTo({ url: '/pages/profile/index' })
}

const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/vm/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'analytics') {
    uni.switchTab({ url: routes[tabId] })
  }
}

const handleTimeRangeChange = (value) => {
  console.log('Time range changed:', value)
}

const handleAnalyticsTab = (tabId) => {
  activeAnalyticsTab.value = tabId
}

const handleSearchQuery = (query) => {
  console.log('Search query:', query)
}

const handleSearchResult = (result) => {
  console.log('Search result:', result)
  showSearch.value = false
}

onMounted(() => {
  fetchUserInfo()
  fetchAnalyticsData()
})
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
  padding: $spacing-4 $spacing-4 calc(#{$bottom-bar-height} + env(safe-area-inset-bottom, 0px) + #{$spacing-4}) $spacing-4;
}

.time-range-selector {
  margin-bottom: $spacing-4;
}

.section {
  margin-bottom: $spacing-6;
}

.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin: $spacing-6 0 $spacing-4 0;
}

.revenue-overview {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.revenue-value {
  @include text-display-sm;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.revenue-change {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.cost-breakdown {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.cost-item {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
}

.cost-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.cost-category {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.cost-percentage {
  @include text-caption;
  color: $color-text-secondary;
}

.cost-amount {
  @include text-caption;
  color: $color-text-primary;
  text-align: right;
}

.location-revenue {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.location-item {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
}

.location-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.location-amount {
  @include text-caption;
  color: $color-text-primary;
  text-align: right;
}

.partner-performance {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.partner-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-3 0;
}

.partner-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.partner-metrics {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: $spacing-1;
}

.partner-revenue {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.partner-roi {
  @include text-caption;
  color: $color-success;
  font-weight: $font-weight-medium;
}

.kpi-label {
  @include text-caption;
  color: $color-text-secondary;
  margin-bottom: $spacing-2;
}

.kpi-value {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
  margin-bottom: $spacing-1;
}

.kpi-trend {
  @include text-caption;
  color: $color-success;
  font-weight: $font-weight-medium;
  
  &.positive {
    color: $color-success;
  }
  
  &.negative {
    color: $color-error;
  }
}

.revenue-change-value {
  @include text-body;
  font-weight: $font-weight-semibold;
}

.analytics-tabs {
  display: flex;
  gap: $spacing-2;
  margin-bottom: $spacing-4;
  overflow-x: auto;
  padding-bottom: $spacing-1;
}

.analytics-tab {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-lg;
  white-space: nowrap;
  color: $color-text-secondary;
  transition: all $transition-normal;

  &.active {
    background: $color-primary;
    color: white;
  }
}

.analytics-tab-text {
  @include text-caption;
  font-weight: $font-weight-medium;
}

.chart-section {
  margin-bottom: $spacing-6;
}

.chart-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-8 0;
  color: $color-text-tertiary;
}

.chart-placeholder-text {
  @include text-caption;
  margin-top: $spacing-3;
}

.metrics-section {
  margin-bottom: $spacing-6;
}
</style>
