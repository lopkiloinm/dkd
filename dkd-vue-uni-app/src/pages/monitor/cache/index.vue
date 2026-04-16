<template>
  <TopBar title="Cache Monitor" :showBack="true" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="cache-info">
        <view class="info-card">
          <view class="card-header">
            <text class="card-title">Cache Information</text>
            <view class="action-btn" @click="handleRefresh">
              <text class="action-text">Refresh</text>
            </view>
          </view>
          <view class="info-row">
            <text class="info-label">Cache Name</text>
            <text class="info-value">{{ cacheInfo.cacheName || 'N/A' }}</text>
          </view>
        </view>

        <view class="info-card" v-for="(item, index) in cacheInfo.infos" :key="index">
          <view class="card-header">
            <text class="card-title">{{ item.name }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Cache Hits</text>
            <text class="info-value">{{ item.hits }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Cache Misses</text>
            <text class="info-value">{{ item.misses }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Hit Rate</text>
            <text class="info-value">{{ item.hitRate }}%</text>
          </view>
        </view>

        <view class="info-card">
          <view class="card-header">
            <text class="card-title">Cache Names</text>
          </view>
          <view class="cache-name-list">
            <view class="cache-name-item" v-for="(name, index) in cacheNames" :key="index" @click="handleViewCacheKeys(name)">
              <text class="cache-name-text">{{ name }}</text>
              <view class="action-btn small" @click.stop="handleClearCacheName(name)">
                <text class="action-text-small">Clear</text>
              </view>
            </view>
          </view>
        </view>

        <view class="info-card" v-if="selectedCacheName">
          <view class="card-header">
            <text class="card-title">Cache Keys: {{ selectedCacheName }}</text>
          </view>
          <view class="cache-key-list">
            <view class="cache-key-item" v-for="(key, index) in cacheKeys" :key="index" @click="handleViewCacheValue(key)">
              <text class="cache-key-text">{{ key }}</text>
              <view class="action-btn small" @click.stop="handleClearCacheKey(key)">
                <text class="action-text-small">Clear</text>
              </view>
            </view>
          </view>
        </view>

        <view class="info-card" v-if="cacheValue !== null">
          <view class="card-header">
            <text class="card-title">Cache Value</text>
            <text class="modal-close" @click="cacheValue = null">×</text>
          </view>
          <view class="cache-value-content">
            <text class="cache-value-text">{{ cacheValue }}</text>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import { getCache, listCacheName, listCacheKey, getCacheValue, clearCacheName, clearCacheKey, clearCacheAll } from '@/api/monitor/cache'

const cacheInfo = ref({
  cacheName: '',
  infos: []
})
const cacheNames = ref([])
const cacheKeys = ref([])
const selectedCacheName = ref('')
const cacheValue = ref(null)
const isRefreshing = ref(false)

const fetchCacheInfo = async () => {
  try {
    const res = await getCache()
    cacheInfo.value = res.data
  } catch (error) {
    uni.showToast({ title: 'Failed to load cache info', icon: 'none' })
  }
}

const fetchCacheNames = async () => {
  try {
    const res = await listCacheName()
    cacheNames.value = res.data || []
  } catch (error) {
    uni.showToast({ title: 'Failed to load cache names', icon: 'none' })
  }
}

const fetchCacheKeys = async (cacheName) => {
  try {
    const res = await listCacheKey(cacheName)
    cacheKeys.value = res.data || []
    selectedCacheName.value = cacheName
  } catch (error) {
    uni.showToast({ title: 'Failed to load cache keys', icon: 'none' })
  }
}

onShow(() => {
  fetchCacheInfo()
  fetchCacheNames()
})

const handleRefresh = () => {
  fetchCacheInfo()
  fetchCacheNames()
  if (selectedCacheName.value) {
    fetchCacheKeys(selectedCacheName.value)
  }
}

const handleViewCacheKeys = (name) => {
  fetchCacheKeys(name)
}

const handleViewCacheValue = async (key) => {
  try {
    const res = await getCacheValue(selectedCacheName.value, key)
    cacheValue.value = res.data
  } catch (error) {
    uni.showToast({ title: 'Failed to load cache value', icon: 'none' })
  }
}

const handleClearCacheName = (name) => {
  uni.showModal({
    title: 'Confirm Clear',
    content: `Are you sure you want to clear cache "${name}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await clearCacheName(name)
          uni.showToast({ title: 'Cache cleared successfully', icon: 'success' })
          handleRefresh()
        } catch (error) {
          uni.showToast({ title: 'Failed to clear cache', icon: 'none' })
        }
      }
    }
  })
}

const handleClearCacheKey = (key) => {
  uni.showModal({
    title: 'Confirm Clear',
    content: `Are you sure you want to clear cache key "${key}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await clearCacheKey(key)
          uni.showToast({ title: 'Cache key cleared successfully', icon: 'success' })
          if (selectedCacheName.value) {
            fetchCacheKeys(selectedCacheName.value)
          }
        } catch (error) {
          uni.showToast({ title: 'Failed to clear cache key', icon: 'none' })
        }
      }
    }
  })
}

const loadMore = () => {}

const onRefresh = () => {
  isRefreshing.value = true
  handleRefresh()
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

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.cache-info {
  padding: $spacing-5;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card {
  @include glass-panel;
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.card-title {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.action-btn {
  padding: 10px 16px;
  border-radius: 8px;
  background-color: rgba(0, 122, 255, 0.1);
  text-align: center;
  transition: background-color 0.2s;
}

.action-btn:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.action-btn.small {
  padding: 6px 12px;
}

.action-text {
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.action-text-small {
  font-size: 12px;
  font-weight: 600;
  color: #007aff;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.info-value {
  font-size: 15px;
  color: $apple-text-primary;
  font-weight: 600;
}

.cache-name-list,
.cache-key-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.cache-name-item,
.cache-key-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background-color: rgba(255, 255, 255, 0.5);
  border-radius: 8px;
  transition: background-color 0.2s;
}

.cache-name-item:active,
.cache-key-item:active {
  background-color: rgba(255, 255, 255, 0.8);
}

.cache-name-text,
.cache-key-text {
  font-size: 14px;
  color: $apple-text-primary;
  font-weight: 500;
}

.modal-close {
  font-size: 32px;
  color: $apple-text-secondary;
  line-height: 1;
  padding: 0 8px;
}

.cache-value-content {
  padding: 12px;
  background-color: rgba(255, 255, 255, 0.5);
  border-radius: 8px;
}

.cache-value-text {
  font-size: 14px;
  color: $apple-text-primary;
  font-weight: 500;
  word-break: break-all;
}
</style>
