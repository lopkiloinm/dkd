<template>
  <AppTopBar title="Online Users" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.ipaddr" placeholder="Search by IP" @confirm="handleSearch" />
      <input class="n-input search-input" v-model="queryParams.userName" placeholder="Search by User Name" @confirm="handleSearch" />
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="online-list">
        <view class="online-card" v-for="item in onlineList" :key="item.tokenId">
          <view class="online-card-header">
            <text class="user-name">{{ item.userName }}</text>
            <view class="action-btn delete" @click="handleForceLogout(item)">
              <text class="action-text">Force Logout</text>
            </view>
          </view>
          
          <view class="online-info">
            <view class="info-row">
              <text class="info-label">IP Address</text>
              <text class="info-value">{{ item.ipaddr }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Login Location</text>
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
          </view>
        </view>

        <view class="empty-state" v-if="onlineList.length === 0 && !loading">
          <text class="empty-text">No online users found</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import { list, forceLogout } from '@/api/monitor/online'

const onlineList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  ipaddr: '',
  userName: ''
})
const total = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    onlineList.value = []
  }
  try {
    loading.value = true
    const res = await list(queryParams.value)
    if (res.rows) {
      onlineList.value = [...onlineList.value, ...res.rows]
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

const handleForceLogout = (item) => {
  uni.showModal({
    title: 'Confirm Force Logout',
    content: `Are you sure you want to force logout user "${item.userName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await forceLogout(item.tokenId)
          uni.showToast({ title: 'Force logout successful', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to force logout', icon: 'none' })
        }
      }
    }
  })
}

const loadMore = () => {
  if (onlineList.value.length < total.value) {
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

.online-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.online-card {
  @include glass-panel;
  padding: 20px;
}

.online-card-header {
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
  color: $color-error;
}

.online-info {
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
</style>
