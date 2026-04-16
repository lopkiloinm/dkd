<template>
  <view :class="dividerClasses">
    <text v-if="text" class="divider-text">{{ text }}</text>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  orientation: {
    type: String,
    default: 'horizontal',
    validator: (value) => ['horizontal', 'vertical'].includes(value)
  },
  text: {
    type: String,
    default: ''
  }
})

const dividerClasses = computed(() => {
  return [
    'divider',
    `divider-${props.orientation}`,
    {
      'divider-with-text': props.text
    }
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.divider {
  border-color: $color-border-medium;
  
  &.divider-horizontal {
    width: 100%;
    height: 1px;
    border-top: 1px solid;
    border-bottom: none;
    
    &.divider-with-text {
      display: flex;
      align-items: center;
      text-align: center;
      
      &::before,
      &::after {
        content: '';
        flex: 1;
        border-top: 1px solid $color-border-medium;
      }
      
      .divider-text {
        padding: 0 $spacing-4;
        color: $color-text-tertiary;
        font-size: $font-size-caption-sm;
        font-weight: $font-weight-medium;
      }
    }
  }
  
  &.divider-vertical {
    width: 1px;
    height: 100%;
    border-left: 1px solid;
    border-right: none;
  }
}
</style>
