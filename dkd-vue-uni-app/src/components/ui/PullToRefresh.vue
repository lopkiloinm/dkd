<template>
  <scroll-view
    class="pull-to-refresh"
    scroll-y
    @scrolltoupper="handleRefresh"
    :upper-threshold="100"
  >
    <view class="refresh-indicator" :style="indicatorStyle">
      <view v-if="loading" class="spinner"></view>
      <text v-else class="refresh-text">{{ refreshText }}</text>
    </view>
    <slot></slot>
  </scroll-view>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  loading: {
    type: Boolean,
    default: false
  },
  threshold: {
    type: Number,
    default: 60
  }
})

const emit = defineEmits(['refresh'])

const pullDistance = ref(0)

const refreshText = computed(() => {
  if (props.loading) return 'Loading...'
  if (pullDistance.value > props.threshold) return 'Release to refresh'
  return 'Pull to refresh'
})

const indicatorStyle = computed(() => {
  const opacity = Math.min(pullDistance.value / props.threshold, 1)
  return {
    opacity: opacity,
    transform: `translateY(${Math.min(pullDistance.value, props.threshold)}px)`
  }
})

const handleRefresh = () => {
  emit('refresh')
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.pull-to-refresh {
  position: relative;
  height: 100%;
}

.refresh-indicator {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
}

.refresh-text {
  @include text-caption;
  color: $color-text-secondary;
}

.spinner {
  width: 24px;
  height: 24px;
  border: 2px solid $color-border-medium;
  border-top-color: $color-primary;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
