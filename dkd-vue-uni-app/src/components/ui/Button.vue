<template>
  <button
    :class="buttonClasses"
    :disabled="disabled || loading"
    @click="handleClick"
  >
    <view v-if="loading" class="button-spinner"></view>
    <slot v-else></slot>
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'secondary', 'ghost', 'danger'].includes(value)
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  disabled: {
    type: Boolean,
    default: false
  },
  loading: {
    type: Boolean,
    default: false
  },
  block: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['click'])

const buttonClasses = computed(() => {
  return [
    'button',
    `button-${props.variant}`,
    `button-${props.size}`,
    {
      'button-block': props.block,
      'button-loading': props.loading
    }
  ]
})

const handleClick = (e) => {
  if (!props.disabled && !props.loading) {
    emit('click', e)
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.button {
  @include button-base;
  
  &.button-primary {
    @include button-primary;
  }
  
  &.button-secondary {
    @include button-secondary;
  }
  
  &.button-ghost {
    @include button-ghost;
  }
  
  &.button-danger {
    @include button-danger;
  }
  
  &.button-sm {
    min-height: 36px;
    padding: 0 $spacing-3;
    font-size: $font-size-body-sm;
  }
  
  &.button-md {
    min-height: $touch-target-min;
    padding: 0 $spacing-4;
    font-size: $font-size-body-md;
  }
  
  &.button-lg {
    min-height: 52px;
    padding: 0 $spacing-6;
    font-size: $font-size-body-md;
  }
  
  &.button-block {
    width: 100%;
  }
  
  &.button-loading {
    pointer-events: none;
  }
}

.button-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid currentColor;
  border-top-color: transparent;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
