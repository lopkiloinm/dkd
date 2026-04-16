<template>
  <view :class="skeletonClasses" :style="skeletonStyle">
    <view class="skeleton-shimmer"></view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'text',
    validator: (value) => ['text', 'circular', 'rectangular', 'rounded'].includes(value)
  },
  width: {
    type: [String, Number],
    default: '100%'
  },
  height: {
    type: [String, Number],
    default: 'auto'
  },
  animation: {
    type: Boolean,
    default: true
  }
})

const skeletonClasses = computed(() => {
  return [
    'skeleton',
    `skeleton-${props.variant}`,
    {
      'skeleton-animated': props.animation
    }
  ]
})

const skeletonStyle = computed(() => {
  const style = {}
  if (props.width) {
    style.width = typeof props.width === 'number' ? `${props.width}px` : props.width
  }
  if (props.height && props.height !== 'auto') {
    style.height = typeof props.height === 'number' ? `${props.height}px` : props.height
  }
  return style
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.skeleton {
  position: relative;
  background: $color-bg-tertiary;
  overflow: hidden;
  
  &.skeleton-text {
    height: 16px;
    border-radius: 4px;
  }
  
  &.skeleton-circular {
    border-radius: 50%;
  }
  
  &.skeleton-rectangular {
    border-radius: $radius-sm;
  }
  
  &.skeleton-rounded {
    border-radius: $radius-full;
  }
  
  &.skeleton-animated .skeleton-shimmer {
    @include shimmer;
  }
}

.skeleton-shimmer {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(
    90deg,
    $color-bg-tertiary 0%,
    $color-bg-elevated 50%,
    $color-bg-tertiary 100%
  );
  background-size: 200% 100%;
}
</style>
