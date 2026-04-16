<template>
  <view class="swipeable-item">
    <view class="swipeable-actions-left" :style="leftActionsStyle">
      <slot name="left-actions"></slot>
    </view>
    <view class="swipeable-content" @touchstart="handleTouchStart" @touchmove="handleTouchMove" @touchend="handleTouchEnd" :style="contentStyle">
      <slot></slot>
    </view>
    <view class="swipeable-actions-right" :style="rightActionsStyle">
      <slot name="right-actions"></slot>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  leftActionsWidth: {
    type: Number,
    default: 80
  },
  rightActionsWidth: {
    type: Number,
    default: 80
  }
})

const emit = defineEmits(['left-action', 'right-action'])

const startX = ref(0)
const currentX = ref(0)
const isDragging = ref(false)

const contentStyle = computed(() => {
  return {
    transform: `translateX(${currentX.value}px)`
  }
})

const leftActionsStyle = computed(() => {
  return {
    width: props.leftActionsWidth + 'px',
    opacity: currentX.value > 0 ? 1 : 0
  }
})

const rightActionsStyle = computed(() => {
  return {
    width: props.rightActionsWidth + 'px',
    opacity: currentX.value < 0 ? 1 : 0
  }
})

const handleTouchStart = (e) => {
  startX.value = e.touches[0].clientX
  isDragging.value = true
}

const handleTouchMove = (e) => {
  if (!isDragging.value) return
  
  const deltaX = e.touches[0].clientX - startX.value
  const maxSwipe = Math.max(props.leftActionsWidth, props.rightActionsWidth)
  
  currentX.value = Math.min(Math.max(deltaX, -maxSwipe), maxSwipe)
}

const handleTouchEnd = () => {
  isDragging.value = false
  
  const threshold = 40
  
  if (currentX.value > threshold) {
    currentX.value = props.leftActionsWidth
    emit('left-action')
  } else if (currentX.value < -threshold) {
    currentX.value = -props.rightActionsWidth
    emit('right-action')
  } else {
    currentX.value = 0
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.swipeable-item {
  position: relative;
  overflow: hidden;
}

.swipeable-actions-left,
.swipeable-actions-right {
  position: absolute;
  top: 0;
  bottom: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: opacity $transition-normal;
}

.swipeable-actions-left {
  left: 0;
}

.swipeable-actions-right {
  right: 0;
}

.swipeable-content {
  position: relative;
  z-index: 1;
  background: $color-bg-secondary;
  transition: transform $transition-normal;
}
</style>
