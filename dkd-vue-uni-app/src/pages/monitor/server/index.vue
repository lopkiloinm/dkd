<template>
  <wd-navbar title="Server Monitor" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="server-info">
        <view class="info-card">
          <view class="card-header">
            <text class="card-title">CPU</text>
          </view>
          <view class="info-row">
            <text class="info-label">Core Count</text>
            <text class="info-value">{{ server.cpu?.cpuNum || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">User Usage</text>
            <text class="info-value">{{ server.cpu?.used || 0 }}%</text>
          </view>
          <view class="info-row">
            <text class="info-label">System Usage</text>
            <text class="info-value">{{ server.cpu?.sys || 0 }}%</text>
          </view>
          <view class="info-row">
            <text class="info-label">Idle Rate</text>
            <text class="info-value">{{ server.cpu?.free || 0 }}%</text>
          </view>
        </view>

        <view class="info-card">
          <view class="card-header">
            <text class="card-title">Memory</text>
          </view>
          <view class="info-row">
            <text class="info-label">Total</text>
            <text class="info-value">{{ server.mem?.total || 0 }}G</text>
          </view>
          <view class="info-row">
            <text class="info-label">Used</text>
            <text class="info-value">{{ server.mem?.used || 0 }}G</text>
          </view>
          <view class="info-row">
            <text class="info-label">Free</text>
            <text class="info-value">{{ server.mem?.free || 0 }}G</text>
          </view>
          <view class="info-row">
            <text class="info-label">Usage</text>
            <text class="info-value" :class="{ 'text-danger': server.mem?.usage > 80 }">{{ server.mem?.usage || 0 }}%</text>
          </view>
        </view>

        <view class="info-card">
          <view class="card-header">
            <text class="card-title">JVM</text>
          </view>
          <view class="info-row">
            <text class="info-label">Total</text>
            <text class="info-value">{{ server.jvm?.total || 0 }}M</text>
          </view>
          <view class="info-row">
            <text class="info-label">Used</text>
            <text class="info-value">{{ server.jvm?.used || 0 }}M</text>
          </view>
          <view class="info-row">
            <text class="info-label">Free</text>
            <text class="info-value">{{ server.jvm?.free || 0 }}M</text>
          </view>
          <view class="info-row">
            <text class="info-label">Usage</text>
            <text class="info-value" :class="{ 'text-danger': server.jvm?.usage > 80 }">{{ server.jvm?.usage || 0 }}%</text>
          </view>
        </view>

        <view class="info-card">
          <view class="card-header">
            <text class="card-title">Server Info</text>
          </view>
          <view class="info-row">
            <text class="info-label">Server Name</text>
            <text class="info-value">{{ server.sys?.computerName || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">OS</text>
            <text class="info-value">{{ server.sys?.osName || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Server IP</text>
            <text class="info-value">{{ server.sys?.computerIp || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Architecture</text>
            <text class="info-value">{{ server.sys?.osArch || 'N/A' }}</text>
          </view>
        </view>

        <view class="info-card">
          <view class="card-header">
            <text class="card-title">Java VM Info</text>
          </view>
          <view class="info-row">
            <text class="info-label">Java Name</text>
            <text class="info-value">{{ server.jvm?.name || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Java Version</text>
            <text class="info-value">{{ server.jvm?.version || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Start Time</text>
            <text class="info-value">{{ server.jvm?.startTime || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Run Time</text>
            <text class="info-value">{{ server.jvm?.runTime || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Home Path</text>
            <text class="info-value">{{ server.jvm?.home || 'N/A' }}</text>
          </view>
          <view class="info-row">
            <text class="info-label">Project Path</text>
            <text class="info-value">{{ server.sys?.userDir || 'N/A' }}</text>
          </view>
        </view>

        <view class="info-card" v-if="server.sys?.files?.length">
          <view class="card-header">
            <text class="card-title">Disk Status</text>
          </view>
          <view class="disk-item" v-for="(disk, index) in server.sys.files" :key="index">
            <view class="disk-header">
              <text class="disk-path">{{ disk.path }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">File System</text>
              <text class="info-value">{{ disk.fileSystem || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Type</text>
              <text class="info-value">{{ disk.type || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Total</text>
              <text class="info-value">{{ disk.total || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Free</text>
              <text class="info-value">{{ disk.free || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Used</text>
              <text class="info-value">{{ disk.used || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Usage</text>
              <text class="info-value" :class="{ 'text-danger': parseFloat(disk.usage) > 80 }">{{ disk.usage || '0' }}%</text>
            </view>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getServer } from '@/api/monitor/server'

const server = ref({
  cpu: null,
  mem: null,
  jvm: null,
  sys: null
})
const isRefreshing = ref(false)

const fetchServerInfo = async () => {
  try {
    const res = await getServer()
    server.value = res.data
  } catch (error) {
    uni.showToast({ title: 'Failed to load server info', icon: 'none' })
  }
}

onShow(() => {
  fetchServerInfo()
})

const loadMore = () => {}

const onRefresh = () => {
  isRefreshing.value = true
  fetchServerInfo()
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  box-sizing: border-box;
  padding: 16px;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.server-info {
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.info-card {
  @include glass-panel;
  padding: 20px;
}

.card-header {
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

.text-danger {
  color: #ff3b30;
}

.disk-item {
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.disk-item:last-child {
  border-bottom: none;
}

.disk-header {
  margin-bottom: 8px;
}

.disk-path {
  font-size: 16px;
  font-weight: 600;
  color: $apple-text-primary;
}
</style>
