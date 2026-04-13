<template>
  <view>
    <view class="nav-placeholder" :style="{ height: navHeight + 'px' }"></view>
    <view class="custom-navbar" :style="{ height: navHeight + 'px' }">
      <view class="status-bar" :style="{ height: statusBarHeight + 'px' }"></view>
      <view class="nav-content">
        <view class="nav-left" @click="goBack" v-if="back">
          <text class="back-icon">‹</text>
          <text class="breadcrumb">{{ breadcrumb }}</text>
        </view>
        <view class="nav-center">
          <text class="title">{{ title }}</text>
        </view>
        <view class="nav-right" v-if="back">
          <view class="add-btn" v-if="showAdd" @click="handleAdd">
            <text class="add-icon">+</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const props = defineProps({
  title: {
    type: String,
    default: 'DiKeDe'
  },
  breadcrumb: {
    type: String,
    default: 'Back'
  },
  back: {
    type: Boolean,
    default: false
  },
  showAdd: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['add'])

const handleAdd = () => {
  emit('add')
}

const statusBarHeight = ref(44)
const navHeight = ref(88) // 44 status + 44 content

onMounted(() => {
  const sysInfo = uni.getSystemInfoSync()
  // Correctly handle H5 where statusBarHeight is explicitly 0. 
  // Do not fallback to 44px if it's 0, otherwise it causes a massive empty gap at the top.
  statusBarHeight.value = typeof sysInfo.statusBarHeight === 'number' ? sysInfo.statusBarHeight : 0
  navHeight.value = statusBarHeight.value + 44
})

const goBack = () => {
  uni.navigateBack({
    fail: () => {
      // Fallback to home if no pages in stack
      uni.switchTab({ url: '/pages/index/index' })
    }
  })
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.nav-placeholder {
  width: 100%;
  flex-shrink: 0;
}

.custom-navbar {
  width: 100%;
  position: fixed;
  top: 0;
  z-index: 999;
  background: rgba(245, 245, 247, 0.85);
  backdrop-filter: blur(30px);
  -webkit-backdrop-filter: blur(30px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  box-sizing: border-box;
}

.nav-content {
  height: 44px;
  display: flex;
  align-items: center;
  padding: 0 16px;
  position: relative;
  justify-content: space-between;
}

.nav-left {
  display: flex;
  align-items: center;
  color: $apple-blue;
  cursor: pointer;
  z-index: 10;
  min-width: 80px;
  height: 100%;
}

.back-icon {
  font-size: 38px;
  font-weight: 300;
  margin-top: -6px;
  margin-right: 4px;
}

.breadcrumb {
  font-size: 17px;
  font-weight: 400;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  letter-spacing: -0.4px;
}

.nav-center {
  flex: 1;
  text-align: center;
  display: flex;
  justify-content: center;
  align-items: center;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 5;
  pointer-events: none;
}

.nav-right {
  min-width: 80px;
  z-index: 10;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.add-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background-color: $apple-blue;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: opacity 0.2s;
}

.add-btn:active {
  opacity: 0.7;
}

.add-icon {
  font-size: 28px;
  font-weight: 300;
  color: white;
  line-height: 1;
  margin-top: -4px;
}

.title {
  font-size: 17px;
  font-weight: 600;
  color: $apple-text-primary;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  letter-spacing: -0.4px;
}
</style>
