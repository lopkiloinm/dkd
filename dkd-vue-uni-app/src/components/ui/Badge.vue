<template>
  <view :class="badgeClasses">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'primary', 'success', 'warning', 'error', 'dot'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  count: {
    type: [Number, String],
    default: null
  },
  max: {
    type: Number,
    default: 99
  }
})

const badgeClasses = computed(() => {
  return [
    'badge',
    `badge-${props.variant}`,
    `badge-${props.size}`
  ]
})

const displayCount = computed(() => {
  if (props.count === null) return null
  const num = Number(props.count)
  return num > props.max ? `${props.max}+` : num
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-family: $font-family-body;
  font-weight: $font-weight-medium;
  white-space: nowrap;
  
  &.badge-default {
    @include status-badge($color-text-secondary);
  }
  
  &.badge-primary {
    @include status-badge($color-primary);
  }
  
  &.badge-success {
    @include status-badge($color-success);
  }
  
  &.badge-warning {
    @include status-badge($color-warning);
  }
  
  &.badge-error {
    @include status-badge($color-error);
  }
  
  &.badge-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: $color-error;
    border: 2px solid $color-bg-primary;
  }
  
  &.badge-sm {
    padding: 2px 6px;
    font-size: $font-size-caption-sm;
  }
  
  &.badge-md {
    padding: 3px 8px;
    font-size: $font-size-caption-sm;
  }
  
  &.badge-lg {
    padding: 4px 12px;
    font-size: $font-size-caption-md;
  }
}
</style>
