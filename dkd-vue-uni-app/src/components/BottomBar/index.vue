<template>
  <view class="bottom-bar">
    <view 
      v-for="item in items" 
      :key="item.pagePath" 
      class="bottom-bar-item"
      :class="{ active: currentPage === item.pagePath }"
      @click="navigateTo(item.pagePath)"
    >
      <view class="bottom-bar-icon" v-html="item.icon"></view>
      <text class="bottom-bar-text">{{ item.text }}</text>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'

const items = [
  {
    pagePath: '/pages/index/index',
    text: 'Home',
    icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>'
  },
  {
    pagePath: '/pages/manage/index',
    text: 'Manage',
    icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="2" width="16" height="20" rx="2" ry="2"></rect><line x1="12" y1="18" x2="12.01" y2="18"></line></svg>'
  },
  {
    pagePath: '/pages/data/index',
    text: 'Data',
    icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2" ry="2"></rect><rect x="2" y="14" width="20" height="8" rx="2" ry="2"></rect><line x1="6" y1="6" x2="6.01" y2="6"></line><line x1="6" y1="18" x2="6.01" y2="18"></line></svg>'
  },
  {
    pagePath: '/pages/mine/index',
    text: 'Profile',
    icon: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>'
  }
]

const currentPage = ref('')

const getCurrentPage = () => {
  const pages = getCurrentPages()
  if (pages.length > 0) {
    const currentPage = pages[pages.length - 1]
    return '/' + currentPage.route
  }
  return ''
}

onShow(() => {
  currentPage.value = getCurrentPage()
})

const navigateTo = (path) => {
  uni.navigateTo({ url: path })
}
</script>

<style scoped lang="scss">
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 50px;
  display: flex;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-top: 1px solid rgba(0, 0, 0, 0.05);
  z-index: 1000;
}

.bottom-bar-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4px 0;
}

.bottom-bar-icon {
  width: 24px;
  height: 24px;
  margin-bottom: 2px;
  color: #86868b;
}

.bottom-bar-item.active .bottom-bar-icon {
  color: #007aff;
}

.bottom-bar-text {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  font-size: 11px;
  color: #86868b;
  font-weight: 500;
  letter-spacing: -0.2px;
}

.bottom-bar-item.active .bottom-bar-text {
  color: #007aff;
  font-weight: 600;
}

.bottom-bar-item:active {
  opacity: 0.7;
}
</style>
