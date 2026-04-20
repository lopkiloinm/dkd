<template>
  <view :class="cardClasses">
    <!-- Horizontal header row across the top (when title is provided) -->
    <view
      v-if="title"
      class="card-header"
      :class="`card-header--${accent}`"
    >
      <view class="card-header-icon-wrap" v-if="icon">
        <Icon :name="icon" size="20" color="currentColor" />
      </view>
      <view class="card-header-text">
        <text v-if="eyebrow" class="card-header-eyebrow">{{ eyebrow }}</text>
        <text class="card-header-title">{{ title }}</text>
      </view>
      <view v-if="$slots.headerAction" class="card-header-action">
        <slot name="headerAction"></slot>
      </view>
    </view>

    <!-- Body -->
    <view class="card-body" :class="`card-body-padding-${padding}`">
      <view v-if="subtitle" class="card-body-subtitle">{{ subtitle }}</view>
      <slot></slot>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from './Icon.vue'

const props = defineProps({
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  eyebrow: { type: String, default: '' },
  icon: { type: String, default: '' },
  accent: {
    type: String,
    default: 'primary',
    validator: (v) => ['primary', 'secondary', 'success', 'warning', 'error', 'neutral'].includes(v)
  },
  variant: {
    type: String,
    default: 'default',
    validator: (v) => ['default', 'elevated', 'outlined', 'glass'].includes(v)
  },
  padding: {
    type: String,
    default: 'md',
    validator: (v) => ['none', 'sm', 'md', 'lg'].includes(v)
  },
  hoverable: { type: Boolean, default: false },
  interactive: { type: Boolean, default: false }
})

const cardClasses = computed(() => [
  'card',
  `card-${props.variant}`,
  {
    'card-has-header': !!props.title,
    'card-hoverable': props.hoverable || props.interactive
  }
])
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

/* ============================================
   Card v2 — flat surface, optional horizontal
   accent header bar across the top, body below.
   No gradients. No diagonals. No rotation.
   ============================================ */

.card {
  position: relative;
  display: flex;
  flex-direction: column;
  width: 100%;
  box-sizing: border-box;
  background: $color-bg-secondary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-md;
  box-shadow: $shadow-sm;
  overflow: hidden;
  transition: border-color $transition-fast, box-shadow $transition-fast, transform $transition-fast;

  &.card-elevated { box-shadow: $shadow-md; }
  &.card-outlined { background: transparent; box-shadow: none; }
  &.card-glass    { background: $color-bg-secondary; }

  &.card-hoverable {
    cursor: pointer;
    @include interactive-pressable(0.99);
  }
}

/* ---- Header (horizontal row, full-width, flat color) ---- */
.card-header {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3 $card-padding;
  min-height: 48px;
  border-bottom: 1px solid $color-border-subtle;
  color: #fff;
  box-sizing: border-box;

  &--primary   { background: $color-primary; }
  &--secondary { background: $color-secondary; }
  &--success   { background: $color-success; }
  &--warning   { background: $color-warning; color: $color-text-primary; }
  &--error     { background: $color-error; }
  &--neutral   { background: $color-bg-elevated; color: $color-text-primary; }
}

.card-header-icon-wrap {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  flex: 0 0 28px;
}

.card-header-text {
  flex: 1 1 auto;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.card-header-title {
  font-family: $font-family-body;
  font-size: $font-size-title-sm;
  font-weight: $font-weight-semibold;
  letter-spacing: 0.1px;
  line-height: 1.25;
  color: inherit;
}

.card-header-eyebrow {
  font-family: $font-family-body;
  font-size: 10px;
  font-weight: $font-weight-medium;
  letter-spacing: 0.6px;
  text-transform: uppercase;
  opacity: 0.78;
  color: inherit;
  margin-bottom: 2px;
}

.card-header-action {
  flex: 0 0 auto;
  display: inline-flex;
  align-items: center;
  margin-left: $spacing-2;
}

/* ---- Body ---- */
.card-body {
  flex: 1 1 auto;
  min-width: 0;
  display: flex;
  flex-direction: column;
  background: $color-bg-secondary;

  &.card-body-padding-none { padding: 0; }
  &.card-body-padding-sm { padding: $spacing-3; }
  &.card-body-padding-md { padding: $card-padding; }
  &.card-body-padding-lg { padding: $spacing-5; }
}

.card-body-subtitle {
  margin-bottom: $spacing-3;
  text-transform: uppercase;
  letter-spacing: 0.6px;
  font-weight: $font-weight-medium;
  font-size: 12px;
  color: $color-text-tertiary;
}
</style>
