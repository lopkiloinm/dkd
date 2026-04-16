<template>
  <view :class="checkboxClasses" @click="handleToggle">
    <view class="checkbox-box">
      <view v-if="modelValue" class="checkbox-check">✓</view>
    </view>
    <text v-if="label" class="checkbox-label">{{ label }}</text>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
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

const checkboxClasses = computed(() => {
  return [
    'checkbox',
    `checkbox-${props.size}`,
    {
      'checkbox-checked': props.modelValue,
      'checkbox-disabled': props.disabled
    }
  ]
})

const handleToggle = () => {
  if (!props.disabled) {
    emit('update:modelValue', !props.modelValue)
    emit('change', !props.modelValue)
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.checkbox {
  display: inline-flex;
  align-items: center;
  gap: $spacing-2;
  cursor: pointer;
  
  &.checkbox-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  &.checkbox-sm {
    .checkbox-box {
      width: 16px;
      height: 16px;
    }
    
    .checkbox-check {
      font-size: 10px;
    }
  }
  
  &.checkbox-md {
    .checkbox-box {
      width: 20px;
      height: 20px;
    }
    
    .checkbox-check {
      font-size: 12px;
    }
  }
  
  &.checkbox-lg {
    .checkbox-box {
      width: 24px;
      height: 24px;
    }
    
    .checkbox-check {
      font-size: 14px;
    }
  }
}

.checkbox-box {
  display: flex;
  align-items: center;
  justify-content: center;
  background: $color-bg-tertiary;
  border: 2px solid $color-border-medium;
  border-radius: $radius-xs;
  transition: all $transition-normal;
  
  .checkbox-checked & {
    background: $color-primary;
    border-color: $color-primary;
  }
}

.checkbox-check {
  color: $color-text-primary;
  font-weight: bold;
  line-height: 1;
}

.checkbox-label {
  @include text-body;
  color: $color-text-primary;
}
</style>
