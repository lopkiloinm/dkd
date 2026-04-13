<template>
  <view class="layout-container">
    <view class="header-section">
      <view class="welcome-box">
        <text class="title">DiKeDe</text>
        <text class="subtitle">Overview and quick access</text>
      </view>
    </view>
    
    <view class="dashboard-grid">
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/node/index')">
        <image class="card-icon" src="/static/icons/node.svg"></image>
        <text class="card-value">120</text>
        <text class="card-label">Nodes</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/vm/index')">
        <image class="card-icon" src="/static/icons/device.svg"></image>
        <text class="card-value">345</text>
        <text class="card-label">Devices</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/emp/index')">
        <image class="card-icon" src="/static/icons/employee.svg"></image>
        <text class="card-value">8</text>
        <text class="card-label">Employees</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/region/index')">
        <image class="card-icon" src="/static/icons/region.svg"></image>
        <text class="card-value">15</text>
        <text class="card-label">Regions</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/partner/index')">
        <image class="card-icon" src="/static/icons/partner.svg"></image>
        <text class="card-value">12</text>
        <text class="card-label">Partners</text>
      </view>
      
      <view class="n-card" hover-class="n-card-hover" @click="goTo('/pages/manage/vmType/index')">
        <image class="card-icon" src="/static/icons/vmtype.svg"></image>
        <text class="card-value">6</text>
        <text class="card-label">VM Types</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { onShow } from '@dcloudio/uni-app'
import useUserStore from '@/store/modules/user'

const userStore = useUserStore()

onShow(() => {
  if (!userStore.token) {
    uni.reLaunch({ url: '/pages/login/index' })
  }
})

const goTo = (url) => {
  uni.navigateTo({ url })
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  min-height: 100vh;
  padding: 16px 20px;
  box-sizing: border-box;
}

.header-section {
  margin-bottom: 28px;
  padding-top: 16px;
}

.welcome-box {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 15px;
  color: $apple-text-secondary;
}

.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 32px;
}

.n-card {
  @include glass-panel;
  padding: 24px 16px;
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.n-card-hover {
  background-color: rgba(255, 255, 255, 0.8);
  transform: scale(0.97);
}

.card-icon {
  width: 44px;
  height: 44px;
  margin-bottom: 14px;
}

.card-value {
  font-size: 26px;
  font-weight: 700;
  color: $apple-text-primary;
  margin-bottom: 4px;
  letter-spacing: -0.5px;
}

.card-label {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.section-title {
  font-size: 17px;
  font-weight: 600;
  color: $apple-text-primary;
  margin-bottom: 14px;
  padding-left: 4px;
}

.action-list {
  @include glass-panel;
  overflow: hidden;
}

.n-list-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid $apple-glass-border;
  background-color: transparent;
  transition: background-color 0.2s;
}

.n-list-item:last-child {
  border-bottom: none;
}

.n-list-item-hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.list-title {
  font-size: 16px;
  font-weight: 500;
  color: $apple-text-primary;
}

.list-arrow {
  color: $apple-text-secondary;
  font-size: 16px;
  font-weight: 500;
}
</style>
