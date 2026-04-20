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
        <!-- Report Types -->
        <text class="section-title">Report Types</text>
        <view class="report-types">
          <Grid :columns="2" :gap="16">
            <Card @click="generateReport('financial')" class="report-card">
              <CardSection variant="body">
                <view class="report-icon-wrapper financial">
                  <Icon name="dollar-sign" size="24" color="currentColor" />
                </view>
                <text class="report-title">Financial</text>
                <text class="report-description">Revenue, costs, profit</text>
              </CardSection>
            </Card>
            <Card @click="generateReport('operational')" class="report-card">
              <CardSection variant="body">
                <view class="report-icon-wrapper operational">
                  <Icon name="activity" size="24" color="currentColor" />
                </view>
                <text class="report-title">Operational</text>
                <text class="report-description">Machine performance</text>
              </CardSection>
            </Card>
            <Card @click="generateReport('inventory')" class="report-card">
              <CardSection variant="body">
                <view class="report-icon-wrapper inventory">
                  <Icon name="box" size="24" color="currentColor" />
                </view>
                <text class="report-title">Inventory</text>
                <text class="report-description">Stock levels, sales</text>
              </CardSection>
            </Card>
            <Card @click="generateReport('team')" class="report-card">
              <CardSection variant="body">
                <view class="report-icon-wrapper team">
                  <Icon name="users" size="24" color="currentColor" />
                </view>
                <text class="report-title">Team</text>
                <text class="report-description">Performance metrics</text>
              </CardSection>
            </Card>
          </Grid>
        </view>

        <!-- Date Range Selector -->
        <text class="section-title">Date Range</text>
        <Card>
          <CardSection variant="body">
            <SegmentedControl
              :options="dateRangeOptions"
              v-model="selectedDateRange"
              @change="handleDateRangeChange"
            />
          </CardSection>
        </Card>

        <!-- Export Options -->
        <text class="section-title">Export Options</text>
        <Card>
          <CardSection variant="body">
            <view class="export-options">
              <view class="export-option" @click="exportReport('csv')">
                <Icon name="file-text" size="20" color="currentColor" />
                <text class="export-label">Export as CSV</text>
              </view>
              <view class="export-option" @click="exportReport('pdf')">
                <Icon name="file" size="20" color="currentColor" />
                <text class="export-label">Export as PDF</text>
              </view>
              <view class="export-option" @click="exportReport('excel')">
                <Icon name="grid" size="20" color="currentColor" />
                <text class="export-label">Export as Excel</text>
              </view>
            </view>
          </CardSection>
        </Card>

        <!-- Recent Reports -->
        <text class="section-title">Recent Reports</text>
        <Card>
          <CardSection variant="body">
            <view class="recent-reports">
              <view class="report-item" v-for="report in recentReports" :key="report.id">
                <view class="report-info">
                  <text class="report-name">{{ report.name }}</text>
                  <text class="report-date">{{ report.date }}</text>
                </view>
                <view class="report-actions">
                  <Button variant="secondary" size="sm" @click="downloadReport(report.id)">Download</Button>
                </view>
              </view>
            </view>
          </CardSection>
        </Card>
      </view>
    </scroll-view>
  </view>
  <AppBottomBar :active-tab="'analytics'" @tab-change="handleTabChange" />
</template>

<script setup>
import { ref, computed } from 'vue'
import { useUserStore } from '@/store/modules/user'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Icon from '@/components/ui/Icon.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Grid from '@/components/ui/Grid.vue'
import SegmentedControl from '@/components/ui/SegmentedControl.vue'
import Button from '@/components/ui/Button.vue'

const userStore = useUserStore()

const unreadCount = ref(0)
const selectedDateRange = ref('month')

const profilePicture = computed(() => userStore.avatar || '')
const userName = computed(() => userStore.name)

const dateRangeOptions = [
  { label: 'This Week', value: 'week' },
  { label: 'This Month', value: 'month' },
  { label: 'This Quarter', value: 'quarter' },
  { label: 'This Year', value: 'year' }
]

const recentReports = ref([
  { id: 1, name: 'Financial Report - March 2026', date: '2026-03-31' },
  { id: 2, name: 'Operational Report - March 2026', date: '2026-03-31' },
  { id: 3, name: 'Inventory Report - March 2026', date: '2026-03-30' }
])

const generateReport = (type) => {
  const labels = { financial: 'Financial', operational: 'Operational', inventory: 'Inventory', team: 'Team' }
  const newReport = {
    id: Date.now(),
    name: `${labels[type] || type} Report - ${new Date().toISOString().slice(0, 10)}`,
    date: new Date().toISOString().slice(0, 10)
  }
  recentReports.value.unshift(newReport)
  uni.showToast({ title: `${labels[type] || type} report generated`, icon: 'success' })
}

const exportReport = (format) => {
  uni.showModal({
    title: `Export as ${format.toUpperCase()}`,
    content: 'This will export the latest report. Continue?',
    success: (r) => {
      if (r.confirm) {
        uni.showToast({ title: `${format.toUpperCase()} export queued`, icon: 'success' })
      }
    }
  })
}

const downloadReport = (id) => {
  const report = recentReports.value.find(r => r.id === id)
  uni.showToast({ title: report ? `Downloading "${report.name}"` : 'Report not found', icon: 'none' })
}

const handleDateRangeChange = (value) => {
  selectedDateRange.value = value
}

const handleAdd = () => {
  generateReport('financial')
}

const handleSearch = () => {}

const handleNotification = () => {
  uni.navigateTo({ url: '/pages/notifications/index' })
}

const handleProfile = () => {
  uni.navigateTo({ url: '/pages/mine/index' })
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



.report-types {
  margin-bottom: $spacing-6;
}

.report-card {
  transition: transform $transition-normal;
}

.report-card:active {
  transform: scale(0.98);
}

.report-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: $radius-md;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: $spacing-3;
  
  &.financial {
    background: rgba($color-primary, 0.1);
    color: $color-primary;
  }
  
  &.operational {
    background: rgba($color-success, 0.1);
    color: $color-success;
  }
  
  &.inventory {
    background: rgba($color-warning, 0.1);
    color: $color-warning;
  }
  
  &.team {
    background: rgba($color-secondary, 0.1);
    color: $color-secondary;
  }
}

.report-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin-bottom: $spacing-1;
}

.report-description {
  @include text-caption;
  color: $color-text-secondary;
}

.export-options {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.export-option {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3;
  background: $color-bg-secondary;
  border-radius: $radius-md;
  transition: transform $transition-normal;
}

.export-option:active {
  transform: scale(0.98);
}

.export-label {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.recent-reports {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.report-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-3 0;
}

.report-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}

.report-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.report-date {
  @include text-caption;
  color: $color-text-secondary;
}

.report-actions {
  display: flex;
  gap: $spacing-2;
}
</style>
