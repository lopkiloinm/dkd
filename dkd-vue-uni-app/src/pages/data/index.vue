<template>
  <TopBar title="Data" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="section">
        <text class="section-title">System Monitor</text>
        <view class="menu-grid">
          <view class="menu-item" @click="goTo('/pages/monitor/online/index')">
            <image class="menu-icon" src="/static/icons/online.svg" />
            <text class="menu-label">Online Users</text>
          </view>
          <view class="menu-item" @click="goTo('/pages/monitor/logininfor/index')">
            <image class="menu-icon" src="/static/icons/login.svg" />
            <text class="menu-label">Login Logs</text>
          </view>
          <view class="menu-item" @click="goTo('/pages/monitor/operlog/index')">
            <image class="menu-icon" src="/static/icons/operlog.svg" />
            <text class="menu-label">Operation Logs</text>
          </view>
          <view class="menu-item" @click="goTo('/pages/monitor/job/index')">
            <image class="menu-icon" src="/static/icons/job.svg" />
            <text class="menu-label">Job Management</text>
          </view>
          <view class="menu-item" @click="goTo('/pages/monitor/jobLog/index')">
            <image class="menu-icon" src="/static/icons/joblog.svg" />
            <text class="menu-label">Job Logs</text>
          </view>
          <view class="menu-item" @click="goTo('/pages/monitor/server/index')">
            <image class="menu-icon" src="/static/icons/server.svg" />
            <text class="menu-label">Server Monitor</text>
          </view>
          <view class="menu-item" @click="goTo('/pages/monitor/cache/index')">
            <image class="menu-icon" src="/static/icons/cache.svg" />
            <text class="menu-label">Cache Monitor</text>
          </view>
          <view class="menu-item menu-item-empty"></view>
          <view class="menu-item menu-item-empty"></view>
        </view>
      </view>

      <view class="section">
        <text class="section-title">Tools</text>
        <view class="menu-grid">
          <view class="menu-item" @click="goTo('/pages/tool/gen/index')">
            <image class="menu-icon" src="/static/icons/gen.svg" />
            <text class="menu-label">Code Generation</text>
          </view>
          <view class="menu-item menu-item-empty"></view>
          <view class="menu-item menu-item-empty"></view>
        </view>
      </view>
    </scroll-view>
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
