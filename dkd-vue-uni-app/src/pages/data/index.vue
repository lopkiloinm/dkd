<template>
  <AppTopBar title="Analytics" />
  <view class="layout-container">
    <view class="filter-tabs">
      <scroll-view class="tabs-scroll" scroll-x :show-scrollbar="false">
        <view class="tabs-list">
          <view class="master-filter-tab" @click="handleMasterFilter">
            <Icon name="settings" size="18" color="currentColor" />
          </view>
          <view
            v-for="tab in filterTabs"
            :key="tab.value"
            class="tab-item"
            :class="{ 'tab-active': activeFilter === tab.value }"
            @click="handleFilterTab(tab.value)"
          >
            <text class="tab-text">{{ tab.label }}</text>
            <text v-if="tab.count !== undefined" class="tab-count">{{ tab.count }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <!-- Time Range Selector -->
        <view class="time-range-selector">
          <view
            v-for="range in timeRanges"
            :key="range.value"
            class="time-range-item"
            :class="{ 'time-range-active': selectedTimeRange === range.value }"
            @click="handleTimeRangeChange(range.value)"
          >
            <text class="time-range-text">{{ range.label }}</text>
          </view>
        </view>

        <!-- Chart Section -->
        <view class="chart-section">
          <Card>
            <CardSection variant="header">
              <text class="chart-title">{{ currentChartTitle }}</text>
            </CardSection>
            <CardSection variant="body">
              <view class="chart-placeholder">
                <Icon name="chart" size="48" color="$color-text-tertiary" />
                <text class="placeholder-text">Chart visualization</text>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Detailed Metrics -->
        <text class="section-title">Detailed Metrics</text>
        <view class="metrics-section">
          <Grid :columns="2" :gap="16">
            <StatCard
              title="Total Revenue"
              :value="revenueValue"
              :trend="revenueTrend"
            />
            <StatCard
              title="Total Orders"
              :value="ordersValue"
              :trend="ordersTrend"
            />
            <StatCard
              title="Completion Rate"
              :value="completionRate"
              :trend="completionTrend"
            />
            <StatCard
              title="Avg Order Value"
              :value="avgOrderValue"
              :trend="avgOrderTrend"
            />
          </Grid>
        </view>
      </view>
    </scroll-view>
    <AppBottomBar :active-tab="'analytics'" @tab-change="handleTabChange" />
  </view>

  <FilterModal
    :visible="filterModalVisible"
    @update:visible="filterModalVisible = $event"
    :filter-sections="filterSections"
    :selected-filters="selectedFilters"
    @apply="handleFilterApply"
    @reset="handleFilterReset"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import StatCard from '@/components/ui/StatCard.vue'
import Grid from '@/components/ui/Grid.vue'
import Icon from '@/components/ui/Icon.vue'
import FilterModal from '@/components/app/FilterModal.vue'

// Filters
const filterTabs = ref([
  { label: 'All', value: 'all' },
  { label: 'Revenue', value: 'revenue' },
  { label: 'Tasks', value: 'tasks' },
  { label: 'Machines', value: 'machines' }
])
const activeFilter = ref('all')
const filterModalVisible = ref(false)
const selectedFilters = ref({})
const filterSections = ref([
  {
    key: 'timeRange',
    title: 'Time Range',
    options: [
      { label: '7 Days', value: '7d' },
      { label: '28 Days', value: '28d' },
      { label: '90 Days', value: '90d' },
      { label: 'Custom', value: 'custom' }
    ]
  },
  {
    key: 'metric',
    title: 'Metric',
    options: [
      { label: 'Revenue', value: 'revenue' },
      { label: 'Orders', value: 'orders' },
      { label: 'Completion Rate', value: 'completion' }
    ]
  }
])

const handleFilterTab = (value) => {
  activeFilter.value = value
}

const handleMasterFilter = () => {
  filterModalVisible.value = true
}

const handleFilterApply = (filters) => {
  selectedFilters.value = filters
  filterModalVisible.value = false
}

const handleFilterReset = () => {
  selectedFilters.value = {}
}

// Sub-tabs
const activeSubTab = ref('revenue')
const subTabs = [
  { id: 'revenue', label: 'Revenue' },
  { id: 'tasks', label: 'Tasks' },
  { id: 'machines', label: 'Machines' },
  { id: 'inventory', label: 'Inventory' }
]

// Time ranges
const selectedTimeRange = ref('28d')
const timeRanges = [
  { label: '7 Days', value: '7d' },
  { label: '28 Days', value: '28d' },
  { label: '90 Days', value: '90d' },
  { label: 'Custom', value: 'custom' }
]

// Chart data
const currentChartTitle = ref('Revenue Trend')
const revenueValue = ref('¥0')
const revenueTrend = ref({ value: 0, direction: 'neutral' })
const ordersValue = ref('0')
const ordersTrend = ref({ value: 0, direction: 'neutral' })
const completionRate = ref('0%')
const completionTrend = ref({ value: 0, direction: 'neutral' })
const avgOrderValue = ref('¥0')
const avgOrderTrend = ref({ value: 0, direction: 'neutral' })

const handleSubTabChange = (tabId) => {
  activeSubTab.value = tabId
  // Update chart title based on selected tab
  const titles = {
    revenue: 'Revenue Trend',
    tasks: 'Task Completion',
    machines: 'Machine Performance',
    inventory: 'Inventory Analytics'
  }
  currentChartTitle.value = titles[tabId] || 'Analytics'
}

const handleTimeRangeChange = (range) => {
  selectedTimeRange.value = range
  // Fetch data for the selected time range
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


.filter-tabs {
  display: flex;
  align-items: center;
  padding: $spacing-3 $spacing-4;
}

.tabs-scroll {
  flex: 1;
  @include scrollbar-hidden;
}

.tabs-list {
  display: flex;
  gap: $spacing-2;
}

.tab-item {
  display: inline-flex;
  align-items: center;
  gap: $spacing-1;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $transition-normal;

  &:active {
    opacity: 0.7;
  }

  &.tab-active {
    background: $color-primary;
  }
}

.tab-text {
  @include text-caption;
  white-space: nowrap;
  color: $color-text-primary;
  font-weight: $font-weight-medium;

  .tab-active & {
    color: white;
  }
}

.tab-count {
  @include text-label;
  color: $color-text-tertiary;

  .tab-active & {
    color: rgba(255, 255, 255, 0.8);
  }
}

.master-filter-tab {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-1 $spacing-2;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $transition-normal;
  color: $color-text-tertiary;
  flex-shrink: 0;

  &:active {
    opacity: 0.7;
  }
}

.time-range-selector {
  display: flex;
  gap: $spacing-2;
  margin-bottom: $spacing-6;
  overflow-x: auto;
  padding-bottom: $spacing-1;
}

.time-range-item {
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: 999px;
  white-space: nowrap;
  transition: all $transition-normal;

  &.time-range-active {
    background: $color-primary;
  }
}

.time-range-text {
  @include text-caption;
  font-weight: $font-weight-medium;

  .time-range-active & {
    color: white;
  }
}

.chart-section {
  margin-top: $spacing-6;
  margin-bottom: $spacing-6;
}

.chart-title {
  @include text-body;
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
}

.placeholder-text {
  @include text-caption;
  color: $color-text-tertiary;
}

.metrics-section {
  margin-bottom: $spacing-6;
}

</style>
