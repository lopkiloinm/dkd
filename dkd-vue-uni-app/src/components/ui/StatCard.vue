<template>
  <view :class="statClasses">
    <view v-if="iconName" class="stat-icon-wrapper" :class="iconClass">
      <Icon :name="iconName" size="24" color="currentColor" />
    </view>
    <view class="stat-content">
      <text class="stat-value">{{ value }}</text>
      <text class="stat-label">{{ label }}</text>
      <view v-if="trend" class="stat-trend" :class="trendClass">
        <Icon :name="trendDirection === 'up' ? 'arrow-up' : trendDirection === 'down' ? 'arrow-down' : 'minus'" size="12" color="currentColor" />
        <text class="trend-value">{{ trend }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  value: {
    type: [String, Number],
    required: true
  },
  label: {
    type: String,
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
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'primary', 'success', 'warning', 'error'].includes(value)
  },
  iconName: {
    type: String,
    default: ''
  }
})

const trendClass = computed(() => {
  return `trend-${props.trendDirection}`
})

const iconClass = computed(() => {
  return `icon-${props.variant}`
})

const statClasses = computed(() => {
  return [
    'stat-card',
    `stat-${props.variant}`
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.stat-card {
  @include card($radius-md, $shadow-sm);
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
  padding: $spacing-4;
}

.stat-icon-wrapper {
  @include icon-tile-base($icon-tile-size-sm);
  
  &.icon-default {
    @include icon-tone($color-text-secondary);
  }
  
  &.icon-primary {
    @include icon-tone($color-primary);
  }
  
  &.icon-success {
    @include icon-tone($color-success);
  }
  
  &.icon-warning {
    @include icon-tone($color-warning);
  }
  
  &.icon-error {
    @include icon-tone($color-error);
  }
}

.stat-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.stat-value {
  display: block;
  @include text-headline;
  font-size: 24px;
  font-weight: $font-weight-bold;
  color: $color-text-primary;
  margin-bottom: $spacing-1;
}

.stat-label {
  display: block;
  @include text-caption;
  color: $color-text-secondary;
  margin-bottom: $spacing-1;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: $spacing-1;
  margin-top: $spacing-1;
  
  &.trend-up {
    color: $color-success;
  }
  
  &.trend-down {
    color: $color-error;
  }
  
  &.trend-neutral {
    color: $color-text-tertiary;
  }
}

.trend-value {
  @include text-caption;
  font-weight: $font-weight-semibold;
  color: inherit;
}
</style>
