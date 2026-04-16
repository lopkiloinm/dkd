<template>
  <view :class="selectClasses" @click="handleClick">
    <view class="select-value">
      <text v-if="selectedLabel" class="value-text">{{ selectedLabel }}</text>
      <text v-else class="placeholder">{{ placeholder }}</text>
    </view>
    <view class="select-arrow">
      <Icon name="chevron-down" size="16" color="currentColor" />
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  options: {
    type: Array,
    default: () => []
  },
  modelValue: {
    type: [String, Number],
    default: null
  },
  placeholder: {
    type: String,
    default: 'Select...'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const selectedLabel = computed(() => {
  const selectedOption = props.options.find(opt => opt.value === props.modelValue)
  return selectedOption ? selectedOption.label : ''
})

const selectClasses = computed(() => {
  return [
    'select',
    `select-${props.size}`,
    {
      'select-disabled': props.disabled
    }
  ]
})

const handleClick = () => {
  if (!props.disabled) {
    // In a real implementation, this would open a picker/modal
    // For now, we'll just emit a change event
    emit('change')
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.select {
  @include input-base;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  
  &.select-sm {
    min-height: 36px;
    padding: 0 $spacing-3;
    font-size: $font-size-body-sm;
  }
  
  &.select-md {
    min-height: $touch-target-min;
    padding: 0 $spacing-4;
    font-size: $font-size-body-md;
  }
  
  &.select-lg {
    min-height: 52px;
    padding: 0 $spacing-5;
    font-size: $font-size-body-md;
  }
  
  &.select-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.select-value {
  flex: 1;
}

.value-text {
  color: $color-text-primary;
}

.placeholder {
  color: $color-text-tertiary;
}

.select-arrow {
  margin-left: $spacing-2;
}

.arrow {
  font-size: 12px;
  color: $color-text-tertiary;
}
</style>
