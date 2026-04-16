<template>
  <view :class="stackClasses" :style="stackStyle">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  direction: {
    type: String,
    default: 'vertical',
    validator: (value) => ['vertical', 'horizontal'].includes(value)
  },
  spacing: {
    type: [Number, String],
    default: 16
  },
  align: {
    type: String,
    default: 'stretch',
    validator: (value) => ['stretch', 'start', 'center', 'end'].includes(value)
  },
  justify: {
    type: String,
    default: 'flex-start',
    validator: (value) => ['flex-start', 'center', 'flex-end', 'space-between', 'space-around'].includes(value)
  }
})

const stackClasses = computed(() => {
  return [
    'stack',
    `stack-${props.direction}`,
    `stack-align-${props.align}`
  ]
})

const stackStyle = computed(() => {
  return {
    gap: typeof props.spacing === 'number' ? props.spacing + 'px' : props.spacing,
    justifyContent: props.justify
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.stack {
  display: flex;
  
  &.stack-vertical {
    flex-direction: column;
  }
  
  &.stack-horizontal {
    flex-direction: row;
  }
  
  &.stack-align-stretch {
    align-items: stretch;
  }
  
  &.stack-align-start {
    align-items: flex-start;
  }
  
  &.stack-align-center {
    align-items: center;
  }
  
  &.stack-align-end {
    align-items: flex-end;
  }
}
</style>
