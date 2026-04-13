<template>
  <TopBar title="Profile" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="profile-section">
        <view class="profile-header">
          <view class="avatar-placeholder">
            <text class="avatar-text">{{ username.charAt(0) }}</text>
          </view>
          <text class="username">{{ username }}</text>
        </view>
      </view>

      <view class="section">
        <text class="section-title">Account</text>
        <view class="menu-list">
          <view class="menu-list-item" @click="goTo('/pages/profile/index')">
            <text class="menu-list-label">Profile</text>
            <text class="menu-list-arrow">›</text>
          </view>
          <view class="menu-list-item" @click="handleLogout">
            <text class="menu-list-label" style="color: #ff3b30;">Logout</text>
          </view>
        </view>
      </view>

      <view class="section">
        <text class="section-title">About</text>
        <view class="menu-list">
          <view class="menu-list-item">
            <text class="menu-list-label">Version</text>
            <text class="menu-list-value">1.0.0</text>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
  <BottomBar />
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import BottomBar from '@/components/BottomBar/index.vue'
import useUserStore from '@/store/modules/user'

const username = ref('Admin')

const goTo = (path) => {
  uni.navigateTo({ url: path })
}

const handleLogout = () => {
  uni.showModal({
    title: 'Confirm Logout',
    content: 'Are you sure you want to logout?',
    success: (res) => {
      if (res.confirm) {
        uni.reLaunch({ url: '/pages/login/index' })
      }
    }
  })
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  box-sizing: border-box;
  padding: 60px 16px 16px 16px;
  padding-bottom: 66px;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.profile-section {
  margin-bottom: 32px;
}

.profile-section:last-child {
  margin-bottom: 0;
}

.profile-header {
  display: flex;
  align-items: center;
  padding: 20px;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 16px;
}

.avatar-placeholder {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  margin-right: 16px;
  background: linear-gradient(135deg, #007aff 0%, #5856d6 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-text {
  font-size: 28px;
  font-weight: 700;
  color: white;
  letter-spacing: -0.5px;
}

.username {
  font-size: 20px;
  font-weight: 600;
  color: $apple-text-primary;
}

.section {
  margin-bottom: 32px;
  margin-top: 16px;
}

.section:first-child {
  margin-top: 0;
}

.section-title {
  display: block;
  font-size: 18px;
  font-weight: 600;
  color: $apple-text-primary;
  margin-bottom: 16px;
}

.menu-list {
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 16px;
  overflow: hidden;
}

.menu-list-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 20px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  transition: background-color 0.2s;
}

.menu-list-item:last-child {
  border-bottom: none;
}

.menu-list-item:active {
  background-color: rgba(0, 0, 0, 0.05);
}

.menu-list-label {
  font-size: 16px;
  color: $apple-text-primary;
}

.menu-list-value {
  font-size: 16px;
  color: $apple-text-secondary;
}

.menu-list-arrow {
  font-size: 24px;
  color: $apple-text-secondary;
}
</style>
