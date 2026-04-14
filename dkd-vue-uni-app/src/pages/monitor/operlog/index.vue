<template>
  <TopBar title="Operation Logs" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.operName" placeholder="Search by Operation" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" v-model="queryParams.operIp" placeholder="Search by IP" @confirm="handleSearch" />
        <input class="n-input search-input" v-model="queryParams.userName" placeholder="Search by User" @confirm="handleSearch" />
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="log-list">
        <view class="log-card" v-for="item in logList" :key="item.operId">
          <view class="log-card-header">
            <text class="oper-name">{{ item.operName }}</text>
            <view class="action-btn delete" @click="handleDelete(item)">
              <text class="action-text">Delete</text>
            </view>
          </view>
          
          <view class="log-info">
            <view class="info-row">
              <text class="info-label">User</text>
              <text class="info-value">{{ item.userName }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Module</text>
              <text class="info-value">{{ item.title }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Type</text>
              <text class="info-value">{{ item.businessType }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Method</text>
              <text class="info-value">{{ item.method }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Request URL</text>
              <text class="info-value">{{ item.operUrl }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">IP</text>
              <text class="info-value">{{ item.operIp }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Location</text>
              <text class="info-value">{{ item.operLocation }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Status</text>
              <text class="info-value" :class="item.status === '0' ? 'status-success' : 'status-failed'">{{ item.status === '0' ? 'Success' : 'Failed' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Time</text>
              <text class="info-value">{{ item.operTime }}</text>
            </view>
            <view class="info-row" v-if="item.errorMsg">
              <text class="info-label">Error</text>
              <text class="info-value error-text">{{ item.errorMsg }}</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="logList.length === 0 && !loading">
          <text class="empty-text">No operation logs found</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import { list, delOperlog, cleanOperlog } from '@/api/monitor/operlog'

const logList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  operName: '',
  operIp: '',
  userName: ''
})
const total = ref(0)
const filtersExpanded = ref(false)

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

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete this log?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delOperlog(item.operId)
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

.oper-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.action-btn {
  padding: 10px 16px;
  border-radius: 8px;
  text-align: center;
  transition: background-color 0.2s;
}

.action-btn:active {
  background-color: rgba(255, 59, 48, 0.2);
}

.action-btn.delete {
  background-color: rgba(255, 59, 48, 0.1);
}

.action-text {
  font-size: 14px;
  font-weight: 600;
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

.status-success {
  color: #34c759;
}

.status-failed {
  color: #ff3b30;
}

.error-text {
  color: #ff3b30;
  max-width: 100%;
  white-space: normal;
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
