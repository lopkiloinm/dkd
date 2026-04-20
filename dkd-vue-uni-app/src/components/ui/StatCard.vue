<template>
  <view :class="statClasses">
    <view v-if="iconName" class="stat-icon-wrapper" :class="`stat-icon--${variant}`">
      <Icon :name="iconName" size="20" color="currentColor" />
    </view>
    <view class="stat-content">
      <text class="stat-value">{{ value }}</text>
      <text class="stat-label">{{ label }}</text>
      <view v-if="trend" class="stat-trend" :class="`trend-${trendDirection}`">
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
  value: { type: [String, Number], required: true },
  label: { type: String, required: true },
  trend: { type: String, default: '' },
  trendDirection: {
    type: String,
    default: 'up',
    validator: (v) => ['up', 'down', 'neutral'].includes(v)
  },
  variant: {
    type: String,
    default: 'default',
    validator: (v) => ['default', 'primary', 'secondary', 'success', 'warning', 'error'].includes(v)
  },
  iconName: { type: String, default: '' }
})

const statClasses = computed(() => ['stat-card', `stat-${props.variant}`])
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.stat-card {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $card-padding;
  background: $color-bg-secondary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-md;
  box-shadow: $shadow-sm;
  height: 100%;
  box-sizing: border-box;
}

.stat-icon-wrapper {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  flex: 0 0 36px;
  border-radius: $radius-sm;
  background: $color-bg-tertiary;
  color: $color-text-secondary;

  &.stat-icon--primary   { color: $color-primary; }
  &.stat-icon--secondary { color: $color-secondary; }
  &.stat-icon--success   { color: $color-success; }
  &.stat-icon--warning   { color: $color-warning; }
  &.stat-icon--error     { color: $color-error; }
}

.stat-content {
  flex: 1 1 auto;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-family: $font-family-body;
  font-size: 22px;
  font-weight: $font-weight-bold;
  color: $color-text-primary;
  line-height: 1.2;
  letter-spacing: -0.3px;
}

.stat-label {
  font-family: $font-family-body;
  font-size: 12px;
  font-weight: $font-weight-medium;
  color: $color-text-secondary;
  margin-top: 2px;
  text-transform: uppercase;
  letter-spacing: 0.4px;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: $spacing-1;
  margin-top: $spacing-2;

  &.trend-up      { color: $color-success; }
  &.trend-down    { color: $color-error; }
  &.trend-neutral { color: $color-text-tertiary; }
}

.trend-value {
  font-size: 12px;
  font-weight: $font-weight-semibold;
  color: inherit;
}
</style>
