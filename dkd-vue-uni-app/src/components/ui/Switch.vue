<template>
  <view :class="switchClasses" @click="handleToggle">
    <view class="switch-track">
      <view class="switch-thumb" :style="thumbStyle"></view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
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

const switchClasses = computed(() => {
  return [
    'switch',
    `switch-${props.size}`,
    {
      'switch-checked': props.modelValue,
      'switch-disabled': props.disabled
    }
  ]
})

const thumbStyle = computed(() => {
  return {
    transform: props.modelValue ? 'translateX(100%)' : 'translateX(0)'
  }
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

.switch {
  cursor: pointer;
  
  &.switch-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  &.switch-sm {
    .switch-track {
      width: 36px;
      height: 20px;
    }
    
    .switch-thumb {
      width: 16px;
      height: 16px;
    }
  }
  
  &.switch-md {
    .switch-track {
      width: 44px;
      height: 24px;
    }
    
    .switch-thumb {
      width: 20px;
      height: 20px;
    }
  }
  
  &.switch-lg {
    .switch-track {
      width: 52px;
      height: 28px;
    }
    
    .switch-thumb {
      width: 24px;
      height: 24px;
    }
  }
}

.switch-track {
  position: relative;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  transition: background-color $transition-normal;
  
  .switch-checked & {
    background: $color-primary;
  }
}

.switch-thumb {
  position: absolute;
  top: 2px;
  left: 2px;
  background: $color-bg-primary;
  border-radius: 50%;
  box-shadow: $shadow-sm;
  transition: transform $transition-normal ease-out;
}
</style>
