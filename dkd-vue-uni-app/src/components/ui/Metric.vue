<template>
  <view :class="metricClasses">
    <text class="metric-label">{{ label }}</text>
    <text class="metric-value">{{ value }}</text>
    <view v-if="trend" class="metric-trend" :class="trendClass">
      <text class="trend-icon">{{ trendIcon }}</text>
      <text class="trend-value">{{ trend }}</text>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  label: {
    type: String,
    required: true
  },
  value: {
    type: [String, Number],
    required: true
  },
  trend: {
    type: String,
    default: ''
  },
  trendDirection: {
    type: String,
    default: 'up',
    validator: (value) => ['up', 'down', 'neutral'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  align: {
    type: String,
    default: 'left',
    validator: (value) => ['left', 'center', 'right'].includes(value)
  }
})

const trendIcon = computed(() => {
  if (props.trendDirection === 'up') return '↑'
  if (props.trendDirection === 'down') return '↓'
  return '→'
})

const trendClass = computed(() => {
  return `trend-${props.trendDirection}`
})

const metricClasses = computed(() => {
  return [
    'metric',
    `metric-${props.size}`,
    `metric-${props.align}`
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.metric {
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
  
  &.metric-left {
    align-items: flex-start;
  }
  
  &.metric-center {
    align-items: center;
  }
  
  &.metric-right {
    align-items: flex-end;
  }
  
  &.metric-sm {
    .metric-value {
      font-size: 18px;
    }
    
    .metric-label {
      font-size: 11px;
    }
  }
  
  &.metric-md {
    .metric-value {
      font-size: 24px;
    }
    
    .metric-label {
      font-size: 12px;
    }
  }
  
  &.metric-lg {
    .metric-value {
      font-size: 32px;
    }
    
    .metric-label {
      font-size: 14px;
    }
  }
}

.metric-label {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.metric-value {
  @include text-headline;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
  line-height: 1;
}

.metric-trend {
  display: flex;
  align-items: center;
  gap: $spacing-1;
  
  &.trend-up {
    .trend-icon,
    .trend-value {
      color: $color-success;
    }
  }
  
  &.trend-down {
    .trend-icon,
    .trend-value {
      color: $color-error;
    }
  }
  
  &.trend-neutral {
    .trend-icon,
    .trend-value {
      color: $color-text-tertiary;
    }
  }
}

.trend-icon {
  font-size: 12px;
  line-height: 1;
}

.trend-value {
  @include text-caption;
  font-weight: $font-weight-medium;
}
</style>
