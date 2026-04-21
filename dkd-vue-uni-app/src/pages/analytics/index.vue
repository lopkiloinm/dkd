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
        <view class="filter-tabs">
          <SegmentedControl
            :options="timeRangeOptions"
            v-model="selectedTimeRange"
            @change="handleTimeRangeChange"
          />
        </view>
        <!-- Revenue Overview -->
        <Motion preset="fade-up" :index="0">
          <Card title="Revenue Overview" accent="primary" icon="dollar-sign" padding="md">
            <view class="revenue-overview">
              <text class="revenue-value">{{ totalRevenue }}</text>
              <view class="revenue-change">
                <Icon :name="revenueTrend === 'up' ? 'trend-up' : revenueTrend === 'down' ? 'trend-down' : 'trend-neutral'" size="16" :color="revenueTrendColor" />
                <text class="revenue-change-value" :style="{ color: revenueTrendColor }">{{ revenueChange }}</text>
              </view>
            </view>
          </Card>
        </Motion>

        <!-- Financial Metrics -->
        <Motion preset="fade-up" :index="1">
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
        </Motion>

        <!-- Cost Breakdown -->
        <Motion preset="fade-up" :index="2">
          <Card title="Cost Breakdown" accent="warning" icon="pie-chart" padding="md">
            <view class="cost-breakdown">
              <view class="donut-container">
                <svg viewBox="0 0 120 120" class="donut-chart">
                  <circle
                    v-for="(seg, i) in donutSegments"
                    :key="i"
                    cx="60" cy="60" r="50"
                    fill="none"
                    :stroke="seg.color"
                    stroke-width="12"
                    :stroke-dasharray="seg.dash"
                    :stroke-dashoffset="seg.offset"
                  />
                </svg>
              </view>
              <view class="cost-legend">
                <view class="cost-legend-item" v-for="cost in costBreakdown" :key="cost.category">
                  <view class="cost-dot" :style="{ background: variantColor(cost.variant) }"></view>
                  <text class="cost-category">{{ cost.category }}</text>
                  <text class="cost-percentage">{{ cost.percentage }}%</text>
                </view>
              </view>
            </view>
          </Card>
        </Motion>

        <!-- Revenue by Location -->
        <Motion preset="fade-up" :index="3">
          <Card title="Revenue by Location" accent="secondary" icon="map-pin" padding="none">
            <view class="location-revenue">
              <view class="location-item" v-for="location in locationRevenue" :key="location.id">
                <view class="location-header">
                  <text class="location-name">{{ location.name }}</text>
                  <text class="location-amount">¥{{ location.revenue }}</text>
                </view>
                <ProgressBar :value="location.revenue" :max="maxLocationRevenue" />
              </view>
            </view>
          </Card>
        </Motion>

        <!-- Partner Performance -->
        <Motion preset="fade-up" :index="4">
          <Card title="Partner Performance" accent="success" icon="users" padding="none">
            <view class="partner-performance">
              <view class="partner-item" v-for="partner in partnerPerformance" :key="partner.id">
                <text class="partner-name">{{ partner.name }}</text>
                <view class="partner-metrics">
                  <text class="partner-revenue">¥{{ partner.revenue }}</text>
                  <text class="partner-roi">ROI: {{ partner.roi }}</text>
                </view>
              </view>
            </view>
          </Card>
        </Motion>

        <!-- Performance KPIs -->
        <Motion preset="fade-up" :index="5">
          <text class="section-title">Performance KPIs</text>
          <Grid :columns="2" :gap="16">
            <StatCard
              label="Machine Uptime"
              :value="machineUptime + '%'"
              :trend="(uptimeTrend > 0 ? '+' : '') + uptimeTrend + '%'"
              :trend-direction="uptimeTrend > 0 ? 'up' : uptimeTrend < 0 ? 'down' : 'neutral'"
              variant="success"
            />
            <StatCard
              label="Revenue Per Machine"
              :value="'¥' + revenuePerMachine"
              :trend="(rpmTrend > 0 ? '+' : '') + rpmTrend + '%'"
              :trend-direction="rpmTrend > 0 ? 'up' : rpmTrend < 0 ? 'down' : 'neutral'"
              variant="primary"
            />
            <StatCard
              label="Task Completion"
              :value="taskCompletionRate + '%'"
              :trend="(taskTrend > 0 ? '+' : '') + taskTrend + '%'"
              :trend-direction="taskTrend > 0 ? 'up' : taskTrend < 0 ? 'down' : 'neutral'"
              variant="default"
            />
            <StatCard
              label="Satisfaction"
              :value="customerSatisfaction + '/5.0'"
              :trend="(csatTrend > 0 ? '+' : '') + csatTrend + '%'"
              :trend-direction="csatTrend > 0 ? 'up' : csatTrend < 0 ? 'down' : 'neutral'"
              variant="warning"
            />
          </Grid>
        </Motion>

        <!-- Analytics Tabs -->
        <view class="analytics-tabs">
          <view
            v-for="tab in analyticsTabs"
            :key="tab.id"
            :class="['analytics-tab', { active: activeAnalyticsTab === tab.id }]"
            @click="handleAnalyticsTab(tab.id)"
          >
            <text class="analytics-tab-text">{{ tab.label }}</text>
          </view>
        </view>

        <!-- Sales Chart -->
        <Motion v-if="activeAnalyticsTab === 'sales'" preset="fade" :index="0">
          <Card title="Sales Trend" accent="primary" icon="bar-chart" padding="md">
            <view class="chart-placeholder">
              <Icon name="bar-chart" size="48" color="currentColor" />
              <text class="chart-placeholder-text">Sales chart will be rendered here</text>
            </view>
          </Card>
        </Motion>

        <!-- Orders Chart -->
        <Motion v-if="activeAnalyticsTab === 'orders'" preset="fade" :index="0">
          <Card title="Orders Trend" accent="primary" icon="line-chart" padding="md">
            <view class="chart-placeholder">
              <Icon name="line-chart" size="48" color="currentColor" />
              <text class="chart-placeholder-text">Orders chart will be rendered here</text>
            </view>
          </Card>
        </Motion>

        <!-- Products Chart -->
        <Motion v-if="activeAnalyticsTab === 'products'" preset="fade" :index="0">
          <Card title="Top Products" accent="secondary" icon="pie-chart" padding="md">
            <view class="chart-placeholder">
              <Icon name="pie-chart" size="48" color="currentColor" />
              <text class="chart-placeholder-text">Products chart will be rendered here</text>
            </view>
          </Card>
        </Motion>

        <!-- Machines Chart -->
        <Motion v-if="activeAnalyticsTab === 'machines'" preset="fade" :index="0">
          <Card title="Machine Performance" accent="success" icon="activity" padding="md">
            <view class="chart-placeholder">
              <Icon name="activity" size="48" color="currentColor" />
              <text class="chart-placeholder-text">Machine performance chart will be rendered here</text>
            </view>
          </Card>
        </Motion>

        <!-- Key Metrics -->
        <Motion preset="fade-up" :index="6">
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
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
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
import Motion from '@/components/ui/Motion.vue'
import { getInfo } from '@/api/login'
import { getDashboardStats, getProductStats, getFinancialMetrics, getCostBreakdown, getRevenueByLocation, getPartnerPerformance, getPerformanceKPIs, getRevenueByWeekday } from '@/api/report'
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

const totalRevenueValue = ref(0)
const totalRevenue = computed(() => `¥${totalRevenueValue.value}`)
const revenueChange = ref('+0%')
const revenueTrend = ref('up')
const revenueTrendColor = computed(() => {
  if (revenueTrend.value === 'up') return '#10b981'
  if (revenueTrend.value === 'down') return '#ef4444'
  return '#6b7280'
})

const totalCostsValue = ref(0)
const netProfitValue = ref(0)
const totalCosts = computed(() => `¥${totalCostsValue.value}`)
const netProfit = computed(() => `¥${netProfitValue.value}`)
const profitMargin = ref('0%')
const costBreakdown = ref([
  { category: 'Inventory', amount: 15000, percentage: 45, variant: 'primary' },
  { category: 'Maintenance', amount: 8000, percentage: 24, variant: 'warning' },
  { category: 'Operations', amount: 6000, percentage: 18, variant: 'default' },
  { category: 'Personnel', amount: 4400, percentage: 13, variant: 'secondary' }
])

const variantColor = (variant) => {
  const map = { primary: '#3d8bff', warning: '#f59e0b', success: '#22c55e', error: '#ef4444', default: '#6b7280', secondary: '#8b5cf6' }
  return map[variant] || map.default
}

const donutSegments = computed(() => {
  const r = 50
  const circumference = 2 * Math.PI * r
  let accumulated = 0
  return costBreakdown.value.map(cost => {
    const arcLength = (cost.percentage / 100) * circumference
    const seg = {
      color: variantColor(cost.variant),
      dash: `${arcLength} ${circumference - arcLength}`,
      offset: -(accumulated - circumference / 4)
    }
    accumulated += arcLength
    return seg
  })
})
const locationRevenue = ref([
  { id: 1, name: 'Downtown', revenue: 25000 },
  { id: 2, name: 'Mall A', revenue: 18000 },
  { id: 3, name: 'Airport', revenue: 15000 },
  { id: 4, name: 'Station', revenue: 12000 }
])
const maxLocationRevenue = computed(() => {
  const max = Math.max(...locationRevenue.value.map((l) => Number(l.revenue) || 0), 0)
  return max > 0 ? max : 1
})
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

const toData = (res) => (res && typeof res === 'object' && 'data' in res ? res.data : null)
const toNumber = (value, fallback = 0) => {
  const n = Number(value)
  return Number.isFinite(n) ? n : fallback
}

const fetchAnalyticsData = async () => {
  try {
    const [dashboardStatsRes, productStatsRes, financialMetricsRes, costBreakdownRes, revenueByLocationRes, partnerPerformanceRes, performanceKPIsRes, revenueByWeekdayRes] = await Promise.allSettled([
      getDashboardStats(),
      getProductStats(),
      getFinancialMetrics(),
      getCostBreakdown(),
      getRevenueByLocation(),
      getPartnerPerformance(),
      getPerformanceKPIs(),
      getRevenueByWeekday()
    ])

    const dashboardStats = dashboardStatsRes.status === 'fulfilled' ? toData(dashboardStatsRes.value) : null
    const productStats = productStatsRes.status === 'fulfilled' ? toData(productStatsRes.value) : null
    const financialMetrics = financialMetricsRes.status === 'fulfilled' ? toData(financialMetricsRes.value) : null
    const costBreakdownData = costBreakdownRes.status === 'fulfilled' ? toData(costBreakdownRes.value) : null
    const revenueByLocationData = revenueByLocationRes.status === 'fulfilled' ? toData(revenueByLocationRes.value) : null
    const partnerPerformanceData = partnerPerformanceRes.status === 'fulfilled' ? toData(partnerPerformanceRes.value) : null
    const performanceKPIsData = performanceKPIsRes.status === 'fulfilled' ? toData(performanceKPIsRes.value) : null
    const revenueByWeekdayData = revenueByWeekdayRes.status === 'fulfilled' ? toData(revenueByWeekdayRes.value) : null

    if (dashboardStats) {
      totalRevenueValue.value = toNumber(dashboardStats.totalRevenue)
      totalOrders.value = toNumber(dashboardStats.totalOrders)
      activeMachines.value = toNumber(dashboardStats.activeMachines)
    }

    if (productStats) {
      const lowStockCount = toNumber(productStats.lowStockCount)
      const totalProducts = Math.max(toNumber(productStats.totalProducts), 1)
      conversionRate.value = `${((1 - lowStockCount / totalProducts) * 100).toFixed(1)}%`
    }

    if (financialMetrics) {
      totalCostsValue.value = toNumber(financialMetrics.totalCosts)
      netProfitValue.value = toNumber(financialMetrics.netProfit)
      profitMargin.value = financialMetrics.profitMargin || '0%'
      avgOrderValue.value = totalOrders.value > 0 ? `¥${Math.round(totalRevenueValue.value / totalOrders.value)}` : '¥0'
    }

    if (Array.isArray(costBreakdownData) && costBreakdownData.length > 0) {
      costBreakdown.value = costBreakdownData
    }

    if (Array.isArray(revenueByLocationData)) {
      locationRevenue.value = revenueByLocationData.map((item) => ({
        ...item,
        revenue: toNumber(item.revenue)
      }))
    }

    if (Array.isArray(partnerPerformanceData)) {
      partnerPerformance.value = partnerPerformanceData
    }

    if (performanceKPIsData) {
      machineUptime.value = toNumber(performanceKPIsData.machineUptime)
      uptimeTrend.value = toNumber(performanceKPIsData.uptimeTrend)
      revenuePerMachine.value = toNumber(performanceKPIsData.revenuePerMachine)
      rpmTrend.value = toNumber(performanceKPIsData.rpmTrend)
      taskCompletionRate.value = toNumber(performanceKPIsData.taskCompletionRate)
      taskTrend.value = toNumber(performanceKPIsData.taskTrend)
      customerSatisfaction.value = toNumber(performanceKPIsData.customerSatisfaction)
      csatTrend.value = toNumber(performanceKPIsData.csatTrend)
    }

    if (Array.isArray(revenueByWeekdayData) && revenueByWeekdayData.length >= 2) {
      const latest = toNumber(revenueByWeekdayData[revenueByWeekdayData.length - 1].revenue)
      const previous = toNumber(revenueByWeekdayData[revenueByWeekdayData.length - 2].revenue)
      const deltaPct = previous > 0 ? ((latest - previous) / previous) * 100 : 0
      revenueTrend.value = deltaPct > 0 ? 'up' : deltaPct < 0 ? 'down' : 'neutral'
      revenueChange.value = `${deltaPct > 0 ? '+' : ''}${deltaPct.toFixed(1)}%`
    }
  } catch (error) {
    console.error('Failed to fetch analytics data', error)
  }
}

const handleSearch = () => {
  showSearch.value = true
}

const handleNotification = () => {
  uni.navigateTo({ url: '/pages/notifications/index' })
}


const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'analytics') {
    uni.navigateTo({ url: routes[tabId] })
  }
}

const handleTimeRangeChange = (value) => {
  selectedTimeRange.value = value
  fetchAnalyticsData()
}

const handleAnalyticsTab = (tabId) => {
  activeAnalyticsTab.value = tabId
}

const handleSearchQuery = () => {}

const handleSearchResult = () => {
  showSearch.value = false
}

onShow(() => {
  fetchUserInfo()
  fetchAnalyticsData()
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";




.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin: $spacing-6 0 $spacing-3 0;
  display: block;

  &:first-child {
    margin-top: 0;
  }
}

.revenue-overview {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.revenue-value {
  @include text-display($font-size-display-sm);
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
  align-items: center;
  gap: $spacing-4;
}

.donut-container {
  width: 120px;
  height: 120px;
  flex-shrink: 0;
}

.donut-chart {
  width: 100%;
  height: 100%;
}

.cost-legend {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.cost-legend-item {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.cost-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.cost-category {
  @include text-caption;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
  flex: 1;
}

.cost-percentage {
  @include text-caption;
  color: $color-text-secondary;
}

.location-revenue {
  display: flex;
  flex-direction: column;
}

.location-item {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  padding: $spacing-4 $card-padding;
  border-bottom: 1px solid $color-border-subtle;

  &:last-child {
    border-bottom: none;
  }
}

.location-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.location-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-3;
}

.location-amount {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.partner-performance {
  display: flex;
  flex-direction: column;
}

.partner-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-4 $card-padding;
  border-bottom: 1px solid $color-border-subtle;

  &:last-child {
    border-bottom: none;
  }
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

.revenue-change-value {
  @include text-body;
  font-weight: $font-weight-semibold;
}

.analytics-tabs {
  display: flex;
  gap: $spacing-2;
  margin: $spacing-6 0 $spacing-3 0;
  overflow-x: auto;
  padding-bottom: $spacing-1;
}

.analytics-tab {
  display: inline-flex;
  align-items: center;
  gap: $spacing-2;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  white-space: nowrap;
  color: $color-text-secondary;
  cursor: pointer;
  transition: all $transition-normal;

  &:active {
    opacity: 0.7;
  }

  &.active {
    background: $color-primary;
    color: white;
  }
}

.analytics-tab-text {
  @include text-caption;
  font-weight: $font-weight-medium;
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
</style>
