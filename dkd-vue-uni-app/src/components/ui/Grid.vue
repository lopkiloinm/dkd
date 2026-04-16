<template>
  <view :class="gridClasses" :style="gridStyle">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  columns: {
    type: [Number, String],
    default: 1
  },
  gap: {
    type: [Number, String],
    default: 16
  },
  autoFit: {
    type: Boolean,
    default: false
  },
  minColumnWidth: {
    type: [Number, String],
    default: 250
  }
})

const gridClasses = computed(() => {
  return [
    'grid',
    {
      'grid-auto-fit': props.autoFit
    }
  ]
})

const gridStyle = computed(() => {
  if (props.autoFit) {
    return {
      gridTemplateColumns: `repeat(auto-fit, minmax(${typeof props.minColumnWidth === 'number' ? props.minColumnWidth + 'px' : props.minColumnWidth}, 1fr))`,
      gap: typeof props.gap === 'number' ? props.gap + 'px' : props.gap
    }
  }
  return {
    gridTemplateColumns: `repeat(${props.columns}, 1fr)`,
    gap: typeof props.gap === 'number' ? props.gap + 'px' : props.gap
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.grid {
  display: grid;
  width: 100%;
}
</style>
