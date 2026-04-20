<template>
  <view :class="progressClasses">
    <view class="progress-track">
      <view class="progress-fill" :style="fillStyle"></view>
    </view>
    <text v-if="showPercentage" class="progress-text">{{ percentage }}%</text>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  value: {
    type: Number,
    default: 0
  },
  max: {
    type: Number,
    default: 100
  },
  variant: {
    type: String,
    default: 'linear',
    validator: (value) => ['linear', 'circular'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  color: {
    type: String,
    default: 'primary'
  },
  showPercentage: {
    type: Boolean,
    default: false
  }
})

const percentage = computed(() => {
  const max = Number(props.max)
  const value = Number(props.value)
  if (!Number.isFinite(max) || max <= 0) {
    return 0
  }
  if (!Number.isFinite(value)) return 0
  return Math.min(Math.max((value / max) * 100, 0), 100)
})

const fillStyle = computed(() => {
  return {
    width: percentage.value + '%'
  }
})

const progressClasses = computed(() => {
  return [
    'progress-bar',
    `progress-${props.variant}`,
    `progress-${props.size}`,
    `progress-${props.color}`
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.progress-bar {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  
  &.progress-linear {
    width: 100%;
  }
  
  &.progress-sm {
    .progress-track {
      height: 4px;
    }
  }
  
  &.progress-md {
    .progress-track {
      height: 8px;
    }
  }
  
  &.progress-lg {
    .progress-track {
      height: 12px;
    }
  }
  
  &.progress-primary .progress-fill {
    background: $color-primary;
  }
  
  &.progress-secondary .progress-fill {
    background: $color-secondary;
  }
  
  &.progress-success .progress-fill {
    background: $color-success;
  }
  
  &.progress-warning .progress-fill {
    background: $color-warning;
  }
  
  &.progress-error .progress-fill {
    background: $color-error;
  }
}

.progress-track {
  flex: 1;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  border-radius: $radius-full;
  transition: width $transition-normal ease-out;
}

.progress-text {
  @include text-caption;
  color: $color-text-secondary;
  min-width: 40px;
  text-align: right;
}
</style>
