<template>
  <view :class="pickerClasses" @click="handleClick">
    <view class="picker-value">
      <text v-if="formattedDate" class="value-text">{{ formattedDate }}</text>
      <text v-else class="placeholder">{{ placeholder }}</text>
    </view>
    <view class="picker-icon">
      <Icon name="calendar" size="18" color="currentColor" />
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  modelValue: {
    type: [Date, String, null],
    default: null
  },
  placeholder: {
    type: String,
    default: 'Select date...'
  },
  disabled: {
    type: Boolean,
    default: false
  },
  format: {
    type: String,
    default: 'YYYY-MM-DD'
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const formattedDate = computed(() => {
  if (!props.modelValue) return ''
  
  if (typeof props.modelValue === 'string') {
    return props.modelValue
  }
  
  if (props.modelValue instanceof Date) {
    return props.modelValue.toISOString().split('T')[0]
  }
  
  return ''
})

const pickerClasses = computed(() => {
  return [
    'date-picker',
    {
      'date-picker-disabled': props.disabled
    }
  ]
})

const handleClick = () => {
  if (!props.disabled) {
    // In a real implementation, this would open a date picker
    // For now, we'll use the uni-app date picker
    uni.showActionSheet({
      itemList: ['Today', 'Tomorrow', 'Next Week'],
      success: (res) => {
        // Handle date selection
        emit('change', res.tapIndex)
      }
    })
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.date-picker {
  @include input-base;
  display: flex;
  align-items: center;
  justify-content: space-between;
  cursor: pointer;
  
  &.date-picker-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.picker-value {
  flex: 1;
}

.value-text {
  color: $color-text-primary;
}

.placeholder {
  color: $color-text-tertiary;
}

.picker-icon {
  margin-left: $spacing-2;
}

.icon {
  font-size: 18px;
}
</style>
