<template>
  <TopBar title="Profile" :showBack="true" />
  <view class="layout-container">
    <view class="profile-header">
      <view class="avatar-container">
        <view class="avatar"></view>
      </view>
      <text class="user-name">{{ userStore.name || 'Admin User' }}</text>
      <text class="user-role">System Administrator</text>
    </view>

    <view class="action-list">
      <view class="n-list-item" hover-class="n-list-item-hover">
        <text class="list-title">Account Settings</text>
        <text class="list-arrow">›</text>
      </view>
      <view class="n-list-item" hover-class="n-list-item-hover">
        <text class="list-title">Language</text>
        <text class="list-arrow">›</text>
      </view>
      <view class="n-list-item" hover-class="n-list-item-hover">
        <text class="list-title">About</text>
        <text class="list-arrow">›</text>
      </view>
    </view>

    <button class="n-button n-button-error" @click="logout">
      Log Out
    </button>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import TopBar from '@/components/TopBar/index.vue'
import useUserStore from '@/store/modules/user'

const userStore = useUserStore()

const logout = () => {
  userStore.clearToken()
  uni.reLaunch({ url: '/pages/login/index' })
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  min-height: 100vh;
  padding: 60px 20px 24px 20px;
  box-sizing: border-box;
}

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 36px;
  padding: 36px 0;
  @include glass-panel;
}

.avatar-container {
  margin-bottom: 16px;
}

.avatar {
  width: 88px;
  height: 88px;
  border-radius: 44px;
  background-color: rgba(0, 122, 255, 0.1);
  border: 3px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.user-name {
  font-size: 22px;
  font-weight: 700;
  color: $apple-text-primary;
  margin-bottom: 4px;
  letter-spacing: -0.5px;
}

.user-role {
  font-size: 15px;
  color: $apple-text-secondary;
}

.action-list {
  @include glass-panel;
  overflow: hidden;
  margin-bottom: 36px;
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

.n-button {
  height: 50px;
  line-height: 50px;
  border-radius: 25px;
  font-size: 17px;
  font-weight: 600;
  text-align: center;
  transition: all 0.3s ease;
  box-shadow: 0 4px 14px rgba(255, 59, 48, 0.2);
}

.n-button::after {
  border: none;
}

.n-button-error {
  background-color: $apple-red;
  color: #fff;
}

.n-button-error:active {
  background-color: darken(#ff3b30, 10%);
  transform: scale(0.98);
}
</style>
