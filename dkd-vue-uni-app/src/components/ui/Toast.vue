<template>
  <view v-if="visible" :class="toastClasses">
    <view v-if="type === 'success'" class="toast-icon success">✓</view>
    <view v-if="type === 'error'" class="toast-icon error">✕</view>
    <view v-if="type === 'warning'" class="toast-icon warning">!</view>
    <view v-if="type === 'info'" class="toast-icon info">i</view>
    <text class="toast-message">{{ message }}</text>
  </view>
</template>

<script setup>
import { computed, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  message: {
    type: String,
    default: ''
  },
  type: {
    type: String,
    default: 'info',
    validator: (value) => ['success', 'error', 'warning', 'info'].includes(value)
  },
  duration: {
    type: Number,
    default: 3000
  },
  position: {
    type: String,
    default: 'top',
    validator: (value) => ['top', 'bottom', 'center'].includes(value)
  }
})

let timer = null

onMounted(() => {
  if (props.visible && props.duration > 0) {
    timer = setTimeout(() => {
      // Emit close event or handle close
    }, props.duration)
  }
})

onUnmounted(() => {
  if (timer) {
    clearTimeout(timer)
  }
})

const toastClasses = computed(() => {
  return [
    'toast',
    `toast-${props.type}`,
    `toast-${props.position}`
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.toast {
  position: fixed;
  left: 50%;
  transform: translateX(-50%);
  z-index: $z-index-tooltip;
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3 $spacing-4;
  background: $color-bg-elevated;
  border-radius: $radius-md;
  box-shadow: $shadow-lg;
  min-width: 200px;
  max-width: 80%;
  @include fade-in;
  
  &.toast-top {
    top: $spacing-4;
  }
  
  &.toast-bottom {
    bottom: $spacing-4;
  }
  
  &.toast-center {
    top: 50%;
    transform: translate(-50%, -50%);
  }
  
  &.toast-success {
    border-left: 4px solid $color-success;
  }
  
  &.toast-error {
    border-left: 4px solid $color-error;
  }
  
  &.toast-warning {
    border-left: 4px solid $color-warning;
  }
  
  &.toast-info {
    border-left: 4px solid $color-primary;
  }
}

.toast-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  font-size: 12px;
  font-weight: bold;
  
  &.success {
    background: $color-success;
    color: white;
  }
  
  &.error {
    background: $color-error;
    color: white;
  }
  
  &.warning {
    background: $color-warning;
    color: white;
  }
  
  &.info {
    background: $color-primary;
    color: white;
  }
}

.toast-message {
  @include text-body;
  color: $color-text-primary;
}
</style>
