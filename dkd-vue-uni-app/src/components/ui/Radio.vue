<template>
  <view :class="radioClasses" @click="handleSelect">
    <view class="radio-box">
      <view v-if="isChecked" class="radio-dot"></view>
    </view>
    <text v-if="label" class="radio-label">{{ label }}</text>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: [String, Number, Boolean],
    default: null
  },
  value: {
    type: [String, Number, Boolean],
    required: true
  },
  label: {
    type: String,
    default: ''
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

const isChecked = computed(() => {
  return props.modelValue === props.value
})

const radioClasses = computed(() => {
  return [
    'radio',
    `radio-${props.size}`,
    {
      'radio-checked': isChecked.value,
      'radio-disabled': props.disabled
    }
  ]
})

const handleSelect = () => {
  if (!props.disabled) {
    emit('update:modelValue', props.value)
    emit('change', props.value)
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.radio {
  display: inline-flex;
  align-items: center;
  gap: $spacing-2;
  cursor: pointer;
  
  &.radio-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  &.radio-sm {
    .radio-box {
      width: 16px;
      height: 16px;
    }
    
    .radio-dot {
      width: 6px;
      height: 6px;
    }
  }
  
  &.radio-md {
    .radio-box {
      width: 20px;
      height: 20px;
    }
    
    .radio-dot {
      width: 8px;
      height: 8px;
    }
  }
  
  &.radio-lg {
    .radio-box {
      width: 24px;
      height: 24px;
    }
    
    .radio-dot {
      width: 10px;
      height: 10px;
    }
  }
}

.radio-box {
  display: flex;
  align-items: center;
  justify-content: center;
  background: $color-bg-tertiary;
  border: 2px solid $color-border-medium;
  border-radius: 50%;
  transition: all $transition-normal;
  
  .radio-checked & {
    border-color: $color-primary;
  }
}

.radio-dot {
  background: $color-primary;
  border-radius: 50%;
}

.radio-label {
  @include text-body;
  color: $color-text-primary;
}
</style>
