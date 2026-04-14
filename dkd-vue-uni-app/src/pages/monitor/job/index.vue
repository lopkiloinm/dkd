<template>
  <wd-navbar title="Job Management" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.jobName" placeholder="Search by Job Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="job-list">
        <view class="job-card" v-for="item in jobList" :key="item.jobId">
          <view class="job-card-header">
            <text class="job-name">{{ item.jobName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              {{ item.status === '0' ? 'Running' : 'Stopped' }}
            </view>
          </view>
          
          <view class="job-info">
            <view class="info-row">
              <text class="info-label">Job Group</text>
              <text class="info-value">{{ item.jobGroup }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Cron</text>
              <text class="info-value">{{ item.cronExpression }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Invoke Target</text>
              <text class="info-value">{{ item.invokeTarget }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Next Time</text>
              <text class="info-value">{{ item.nextValidTime }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handleToggleStatus(item)" v-if="hasPermission('monitor:job:edit')">
              <text class="action-text">{{ item.status === '0' ? 'Stop' : 'Start' }}</text>
            </view>
            <view class="action-btn" @click="handleRun(item)" v-if="hasPermission('monitor:job:edit')">
              <text class="action-text">Run</text>
            </view>
            <view class="action-btn" @click="handleViewLog(item)">
              <text class="action-text">Logs</text>
            </view>
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('monitor:job:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('monitor:job:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="jobList.length === 0 && !loading">
          <text class="empty-text">No jobs found</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listJob, getJob, addJob, updateJob, delJob, executeJob } from '@/api/monitor/job'
import { hasPermission } from '@/utils/permission'

const jobList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  jobName: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const statusOptions = ['All Status', 'Running', 'Stopped']
const filterStatusIndex = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    jobList.value = []
  }
  try {
    loading.value = true
    const res = await listJob(queryParams.value)
    if (res.rows) {
      jobList.value = [...jobList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load data', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

onShow(() => {
  fetchList(true)
})

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

const onFilterStatusChange = (e) => {
  filterStatusIndex.value = e.detail.value
  queryParams.value.status = e.detail.value === 0 ? null : (e.detail.value === 1 ? '0' : '1')
  handleSearch()
}

const handleToggleStatus = (item) => {
  const newStatus = item.status === '0' ? '1' : '0'
  const text = newStatus === '0' ? 'start' : 'stop'
  uni.showModal({
    title: 'Confirm',
    content: `Are you sure you want to ${text} "${item.jobName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await changeJobStatus(item.jobId, newStatus)
          uni.showToast({ title: 'Status updated successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to update status', icon: 'none' })
        }
      }
    }
  })
}

const handleRun = (item) => {
  uni.showModal({
    title: 'Confirm Run',
    content: `Are you sure you want to run "${item.jobName}" now?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await runJob(item.jobId, item.jobGroup)
          uni.showToast({ title: 'Job started successfully', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: 'Failed to start job', icon: 'none' })
        }
      }
    }
  })
}

const handleViewLog = (item) => {
  uni.navigateTo({
    url: `/pages/monitor/jobLog/index?jobId=${item.jobId}&jobName=${item.jobName}`
  })
}

const handleEdit = (item) => {
  uni.showToast({ title: 'Edit functionality not implemented yet', icon: 'none' })
}

const handleAdd = () => {
  uni.showToast({ title: 'Add functionality not implemented yet', icon: 'none' })
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.jobName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delJob(item.jobId)
          uni.showToast({ title: 'Deleted successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to delete', icon: 'none' })
        }
      }
    }
  })
}

const loadMore = () => {
  if (jobList.value.length < total.value) {
    queryParams.value.pageNum++
    fetchList()
  }
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  box-sizing: border-box;
  padding: 60px 0 16px 0;
}

.search-bar {
  padding: 16px;
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.n-input {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  color: $apple-text-primary;
}

.n-input::placeholder {
  color: $apple-text-secondary;
}

.filter-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 16px;
  background-color: rgba(0, 122, 255, 0.1);
  border-radius: $apple-radius-sm;
  transition: background-color 0.2s;
}

.filter-toggle:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.filter-toggle-text {
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.filter-toggle-icon {
  font-size: 12px;
  color: #007aff;
  transition: transform 0.2s;
}

.filters-container {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease-out, opacity 0.3s ease-out;
  opacity: 0;
}

.filters-container.expanded {
  max-height: 150px;
  opacity: 1;
}

.filter-picker {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  color: $apple-text-primary;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.job-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.job-card {
  @include glass-panel;
  padding: 20px;
}

.job-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.job-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.status-active {
  background-color: rgba(52, 199, 89, 0.15);
  color: #34c759;
}

.status-inactive {
  background-color: rgba(255, 59, 48, 0.15);
  color: #ff3b30;
}

.job-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  justify-content: space-between;
}

.info-label {
  font-size: 14px;
  color: $apple-text-secondary;
}

.info-value {
  font-size: 14px;
  color: $apple-text-primary;
  font-weight: 500;
  text-align: right;
  max-width: 60%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.empty-state {
  padding: 40px 0;
  text-align: center;
}

.empty-text {
  color: $apple-text-secondary;
  font-size: 15px;
}

.card-actions {
  display: flex;
  gap: 8px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid $apple-glass-border;
}

.action-btn {
  flex: 1;
  padding: 10px 8px;
  border-radius: 8px;
  background-color: rgba(0, 122, 255, 0.1);
  text-align: center;
  transition: background-color 0.2s;
}

.action-btn:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.action-btn.delete {
  background-color: rgba(255, 59, 48, 0.1);
}

.action-btn.delete:active {
  background-color: rgba(255, 59, 48, 0.2);
}

.action-text {
  font-size: 13px;
  font-weight: 600;
  color: #007aff;
}

.action-btn.delete .action-text {
  color: #ff3b30;
}
</style>
