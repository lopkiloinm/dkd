<template>
  <view class="tooltip-wrapper" @mouseenter="showTooltip" @mouseleave="hideTooltip">
    <slot></slot>
    <view v-if="visible" class="tooltip" :class="tooltipClasses">
      <text class="tooltip-text">{{ text }}</text>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  text: {
    type: String,
    required: true
  },
  position: {
    type: String,
    default: 'top',
    validator: (value) => ['top', 'bottom', 'left', 'right'].includes(value)
  },
  delay: {
    type: Number,
    default: 300
  }
})

const visible = ref(false)
let timeoutId = null

const tooltipClasses = computed(() => {
  return [
    'tooltip',
    `tooltip-${props.position}`
  ]
})

const showTooltip = () => {
  if (timeoutId) clearTimeout(timeoutId)
  timeoutId = setTimeout(() => {
    visible.value = true
  }, props.delay)
}

const hideTooltip = () => {
  if (timeoutId) clearTimeout(timeoutId)
  visible.value = false
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.tooltip-wrapper {
  position: relative;
  display: inline-block;
}

.tooltip {
  position: absolute;
  z-index: $z-index-tooltip;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-elevated;
  border-radius: $radius-sm;
  box-shadow: $shadow-lg;
  white-space: nowrap;
  @include fade-in;
  
  &.tooltip-top {
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-bottom: $spacing-2;
  }
  
  &.tooltip-bottom {
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: $spacing-2;
  }
  
  &.tooltip-left {
    right: 100%;
    top: 50%;
    transform: translateY(-50%);
    margin-right: $spacing-2;
  }
  
  &.tooltip-right {
    left: 100%;
    top: 50%;
    transform: translateY(-50%);
    margin-left: $spacing-2;
  }
}

.tooltip-text {
  @include text-caption;
  color: $color-text-primary;
}
</style>
