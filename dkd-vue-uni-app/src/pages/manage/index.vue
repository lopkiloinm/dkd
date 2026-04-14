<template>
  <TopBar title="Manage" />
  <view class="layout-container">
    <view class="section">
      <text class="section-title">Business Management</text>
      <view class="menu-grid">
        <view class="menu-item" @click="goTo('/pages/manage/task/index')">
          <image class="menu-icon" src="/static/icons/work-order.svg" />
          <text class="menu-label">Work Orders</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/manage/node/index')">
          <image class="menu-icon" src="/static/icons/node.svg" />
          <text class="menu-label">Nodes</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/manage/vm/index')">
          <image class="menu-icon" src="/static/icons/device.svg" />
          <text class="menu-label">Devices</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/manage/vmType/index')">
          <image class="menu-icon" src="/static/icons/vmtype.svg" />
          <text class="menu-label">Device Types</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/manage/emp/index')">
          <image class="menu-icon" src="/static/icons/employee.svg" />
          <text class="menu-label">Employees</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/manage/region/index')">
          <image class="menu-icon" src="/static/icons/region.svg" />
          <text class="menu-label">Regions</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/manage/partner/index')">
          <image class="menu-icon" src="/static/icons/partner.svg" />
          <text class="menu-label">Partners</text>
        </view>
      </view>
    </view>

    <view class="section">
      <text class="section-title">System Management</text>
      <view class="menu-grid">
        <view class="menu-item" @click="goTo('/pages/system/user/index')">
          <image class="menu-icon" src="/static/icons/user.svg" />
          <text class="menu-label">Users</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/role/index')">
          <image class="menu-icon" src="/static/icons/role.svg" />
          <text class="menu-label">Roles</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/menu/index')">
          <image class="menu-icon" src="/static/icons/menu.svg" />
          <text class="menu-label">Menus</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/dept/index')">
          <image class="menu-icon" src="/static/icons/dept.svg" />
          <text class="menu-label">Departments</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/post/index')">
          <image class="menu-icon" src="/static/icons/post.svg" />
          <text class="menu-label">Posts</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/dict/index')">
          <image class="menu-icon" src="/static/icons/dict.svg" />
          <text class="menu-label">Dictionary</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/config/index')">
          <image class="menu-icon" src="/static/icons/config.svg" />
          <text class="menu-label">Config</text>
        </view>
        <view class="menu-item" @click="goTo('/pages/system/notice/index')">
          <image class="menu-icon" src="/static/icons/notice.svg" />
          <text class="menu-label">Notices</text>
        </view>
        <view class="menu-item menu-item-empty"></view>
      </view>
    </view>
  </view>
  <BottomBar />
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useI18n } from 'vue-i18n'
import TopBar from '@/components/TopBar/index.vue'
import BottomBar from '@/components/BottomBar/index.vue'

const goTo = (path) => {
  uni.navigateTo({ url: path })
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  min-height: 100vh;
  box-sizing: border-box;
  padding: 60px 16px 16px 16px;
  padding-bottom: 66px;
}

.section {
  margin-bottom: 32px;
  margin-top: 16px;
}

.section:first-child {
  margin-top: 0;
}

.section:last-child {
  margin-bottom: 0;
}

.section-title {
  display: block;
  font-size: 18px;
  font-weight: 600;
  color: $apple-text-primary;
  margin-bottom: 16px;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.menu-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px 8px;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  border-radius: 16px;
  transition: all 0.2s ease-out;
}

.menu-item:active {
  transform: scale(0.95);
  background: rgba(255, 255, 255, 0.8);
}

.menu-icon {
  width: 40px;
  height: 40px;
  margin-bottom: 8px;
}

.menu-label {
  font-size: 14px;
  color: $apple-text-primary;
  text-align: center;
}

.menu-item-empty {
  visibility: hidden;
}
</style>
