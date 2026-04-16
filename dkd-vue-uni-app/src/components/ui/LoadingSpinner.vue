<template>
  <view :class="spinnerClasses">
    <view class="spinner-ring"></view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  color: {
    type: String,
    default: 'primary'
  }
})

const spinnerClasses = computed(() => {
  return [
    'loading-spinner',
    `spinner-${props.size}`,
    `spinner-${props.color}`
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.loading-spinner {
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.spinner-ring {
  border: 3px solid $color-border-medium;
  border-top-color: currentColor;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
  
  .spinner-primary & {
    border-top-color: $color-primary;
  }
  
  .spinner-secondary & {
    border-top-color: $color-secondary;
  }
  
  .spinner-success & {
    border-top-color: $color-success;
  }
  
  .spinner-warning & {
    border-top-color: $color-warning;
  }
  
  .spinner-error & {
    border-top-color: $color-error;
  }
  
  .spinner-sm & {
    width: 16px;
    height: 16px;
    border-width: 2px;
  }
  
  .spinner-md & {
    width: 24px;
    height: 24px;
    border-width: 3px;
  }
  
  .spinner-lg & {
    width: 32px;
    height: 32px;
    border-width: 4px;
  }
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
