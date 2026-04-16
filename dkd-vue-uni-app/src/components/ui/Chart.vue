<template>
  <view :class="chartClasses" :style="chartStyle">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: 'line',
    validator: (value) => ['line', 'bar', 'pie', 'doughnut', 'area'].includes(value)
  },
  height: {
    type: [String, Number],
    default: 300
  },
  width: {
    type: [String, Number],
    default: '100%'
  }
})

const chartClasses = computed(() => {
  return [
    'chart',
    `chart-${props.type}`
  ]
})

const chartStyle = computed(() => {
  return {
    height: typeof props.height === 'number' ? props.height + 'px' : props.height,
    width: typeof props.width === 'number' ? props.width + 'px' : props.width
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.chart {
  position: relative;
  width: 100%;
  
  &.chart-line,
  &.chart-bar,
  &.chart-area {
    // Chart-specific styles for line/bar/area charts
  }
  
  &.chart-pie,
  &.chart-doughnut {
    display: flex;
    align-items: center;
    justify-content: center;
  }
}
</style>
