<template>
  <view :class="cardClasses">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'elevated', 'outlined', 'glass'].includes(value)
  },
  padding: {
    type: String,
    default: 'md',
    validator: (value) => ['none', 'sm', 'md', 'lg'].includes(value)
  },
  radius: {
    type: String,
    default: 'md',
    validator: (value) => ['none', 'sm', 'md', 'lg'].includes(value)
  },
  hoverable: {
    type: Boolean,
    default: false
  }
})

const cardClasses = computed(() => {
  return [
    'card',
    `card-${props.variant}`,
    `card-padding-${props.padding}`,
    `card-radius-${props.radius}`,
    {
      'card-hoverable': props.hoverable
    }
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

:host {
  display: block;
  height: 100%;
}

.card {
  height: 100%;
  box-sizing: border-box;
  background: transparent;
  overflow: hidden;
  transition: transform $transition-fast, background-color $transition-fast, border-color $transition-fast, box-shadow $transition-fast;
  
  &.card-default {
    @include card;
  }
  
  &.card-elevated {
    @include card($radius-panel, $shadow-lg);
  }
  
  &.card-outlined {
    @include surface-muted($radius-panel);
    box-shadow: none;
  }
  
  &.card-glass {
    @include surface-floating($radius-panel, $shadow-md);
  }
  
  &.card-radius-none {
    border-radius: 0;
  }
  
  &.card-radius-sm {
    border-radius: $radius-sm;
  }
  
  &.card-radius-md {
    border-radius: $radius-md;
  }
  
  &.card-radius-lg {
    border-radius: $radius-lg;
  }
  
  &.card-padding-none {
    padding: 0;
  }
  
  &.card-padding-sm {
    padding: $spacing-3;
  }
  
  &.card-padding-md {
    padding: $spacing-4;
  }
  
  &.card-padding-lg {
    padding: $spacing-6;
  }
  
  &.card-hoverable {
    cursor: pointer;
    @include interactive-pressable;
    
    &:active {
      background: rgba($surface-card-elevated, 0.96);
    }
  }
}
</style>
