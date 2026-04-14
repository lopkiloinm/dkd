<template>
  <wd-navbar title="Login Logs" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.userName" placeholder="Search by User Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" v-model="queryParams.ipaddr" placeholder="Search by IP" @confirm="handleSearch" />
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="log-list">
        <view class="log-card" v-for="item in logList" :key="item.infoId">
          <view class="log-card-header">
            <text class="user-name">{{ item.userName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-success' : 'status-failed'">
              {{ item.status === '0' ? 'Success' : 'Failed' }}
            </view>
          </view>
          
          <view class="log-info">
            <view class="info-row">
              <text class="info-label">IP Address</text>
              <text class="info-value">{{ item.ipaddr }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Location</text>
              <text class="info-value">{{ item.loginLocation }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Browser</text>
              <text class="info-value">{{ item.browser }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">OS</text>
              <text class="info-value">{{ item.os }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Login Time</text>
              <text class="info-value">{{ item.loginTime }}</text>
            </view>
            <view class="info-row" v-if="item.status === '1'">
              <text class="info-label">Msg</text>
              <text class="info-value">{{ item.msg }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handleUnlock(item)" v-if="item.status === '1'">
              <text class="action-text">Unlock</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="logList.length === 0 && !loading">
          <text class="empty-text">No login logs found</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { list, delLogininfor, unlockLogininfor, cleanLogininfor } from '@/api/monitor/logininfor'

const logList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  userName: '',
  ipaddr: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const statusOptions = ['All Status', 'Success', 'Failed']
const filterStatusIndex = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    logList.value = []
  }
  try {
    loading.value = true
    const res = await list(queryParams.value)
    if (res.rows) {
      logList.value = [...logList.value, ...res.rows]
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

const handleUnlock = (item) => {
  uni.showModal({
    title: 'Confirm Unlock',
    content: `Are you sure you want to unlock user "${item.userName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await unlockLogininfor(item.userName)
          uni.showToast({ title: 'Unlock successful', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to unlock', icon: 'none' })
        }
      }
    }
  })
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete this log?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delLogininfor(item.infoId)
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
  if (logList.value.length < total.value) {
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
  max-height: 200px;
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

.log-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.log-card {
  @include glass-panel;
  padding: 20px;
}

.log-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.user-name {
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

.status-success {
  background-color: rgba(52, 199, 89, 0.15);
  color: #34c759;
}

.status-failed {
  background-color: rgba(255, 59, 48, 0.15);
  color: #ff3b30;
}

.log-info {
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
  gap: 12px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid $apple-glass-border;
}

.action-btn {
  flex: 1;
  padding: 10px 16px;
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
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.action-btn.delete .action-text {
  color: #ff3b30;
}
</style>
