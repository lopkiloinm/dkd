<template>
  <view :class="segmentedClasses">
    <view
      v-for="(option, index) in options"
      :key="index"
      :class="segmentClasses(option)"
      @click="handleSegmentClick(index)"
    >
      <slot name="segment" :option="option" :index="index">
        {{ option.label }}
      </slot>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  options: {
    type: Array,
    default: () => []
  },
  modelValue: {
    type: [String, Number],
    default: 0
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const segmentedClasses = computed(() => {
  return [
    'segmented-control'
  ]
})

const segmentClasses = (option) => {
  const isSelected = props.modelValue === option.value
  return [
    'segment',
    {
      'segment-active': isSelected
    }
  ]
}

const handleSegmentClick = (index) => {
  const selectedOption = props.options[index]
  emit('update:modelValue', selectedOption.value)
  emit('change', selectedOption.value, selectedOption)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.segmented-control {
  position: relative;
  display: flex;
  gap: $spacing-2;
}

.segment {
  position: relative;
  flex: 1;
  padding: $spacing-2 $spacing-4;
  font-family: $font-family-body;
  font-size: $font-size-body-sm;
  font-weight: $font-weight-medium;
  color: $color-text-primary;
  text-align: center;
  border-radius: 999px;
  cursor: pointer;
  transition: all $transition-normal;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
  background: $color-bg-tertiary;
  
  &:active {
    opacity: 0.7;
  }
  
  &.segment-active {
    background: $color-primary;
    color: white;
    box-shadow: none;
  }
}
</style>
