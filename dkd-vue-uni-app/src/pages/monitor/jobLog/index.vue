<template>
  <TopBar title="Job Logs" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.jobName" placeholder="Search by Job Name" @confirm="handleSearch" />
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="log-list">
        <view class="log-card" v-for="item in logList" :key="item.jobLogId">
          <view class="log-card-header">
            <text class="job-name">{{ item.jobName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-success' : 'status-failed'">
              {{ item.status === '0' ? 'Success' : 'Failed' }}
            </view>
          </view>
          
          <view class="log-info">
            <view class="info-row">
              <text class="info-label">Job Group</text>
              <text class="info-value">{{ item.jobGroup }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Invoke Target</text>
              <text class="info-value">{{ item.invokeTarget }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Job Message</text>
              <text class="info-value">{{ item.jobMessage }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Exception Info</text>
              <text class="info-value">{{ item.exceptionInfo || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Start Time</text>
              <text class="info-value">{{ item.createTime }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Stop Time</text>
              <text class="info-value">{{ item.stopTime || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn delete" @click="handleDelete(item)">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="logList.length === 0 && !loading">
          <text class="empty-text">No job logs found</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import { listJobLog } from '@/api/monitor/jobLog'

const logList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  jobName: ''
})
const total = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    logList.value = []
  }
  try {
    loading.value = true
    const res = await listJobLog(queryParams.value)
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

onLoad((options) => {
  if (options.jobName) {
    queryParams.value.jobName = options.jobName
  }
  fetchList(true)
})

onShow(() => {
  fetchList(true)
})

const handleSearch = () => {
  fetchList(true)
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete this log?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delJobLog(item.jobLogId)
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
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  box-sizing: border-box;
  padding: calc($spacing-4 + env(safe-area-inset-top, 0px)) $spacing-4 calc($spacing-4 + #{$bottom-bar-height} + env(safe-area-inset-bottom, 0px)) $spacing-4;
}

.search-bar {
  padding: $spacing-4;
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.n-input {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
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
  gap: $spacing-4;
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
