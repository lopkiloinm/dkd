<template>
  <view class="top-bar">
    <view v-if="showBack" class="top-bar-back" @click="goBack">
      <text class="back-caret">‹</text>
      <text class="back-text">Back</text>
    </view>
    <text class="top-bar-title">{{ title }}</text>
  </view>
</template>

<script setup>
const props = defineProps({
  title: {
    type: String,
    default: 'DiKeDe'
  },
  showBack: {
    type: Boolean,
    default: false
  }
})

const goBack = () => {
  uni.navigateBack()
}
</script>

<style scoped lang="scss">
.top-bar {
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  margin: 0;
  padding: 0;
  width: 100%;
}

.top-bar-back {
  position: absolute;
  left: 16px;
  display: flex;
  align-items: center;
  gap: 1px;
  cursor: pointer;
}

.back-caret {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  font-size: 22px;
  color: #007aff;
  line-height: 1;
  font-weight: 300;
  margin-bottom: 1px;
}

.back-text {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  font-size: 17px;
  color: #007aff;
  font-weight: 500;
  letter-spacing: -0.3px;
}

.top-bar-title {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  font-size: 17px;
  font-weight: 600;
  color: #1d1d1f;
  letter-spacing: -0.4px;
}
</style>
