<template>
  <view :class="inputClasses">
    <view v-if="$slots.prefix" class="input-prefix">
      <slot name="prefix"></slot>
    </view>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :maxlength="maxlength"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      class="input-field"
    />
    <view v-if="$slots.suffix" class="input-suffix">
      <slot name="suffix"></slot>
    </view>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: ''
  },
  type: {
    type: String,
    default: 'text'
  },
  placeholder: {
    type: String,
    default: ''
  },
  disabled: {
    type: Boolean,
    default: false
  },
  maxlength: {
    type: [String, Number],
    default: 140
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  error: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'focus', 'blur'])

const isFocused = ref(false)

const inputClasses = computed(() => {
  return [
    'input-wrapper',
    `input-${props.size}`,
    {
      'input-disabled': props.disabled,
      'input-error': props.error,
      'input-focused': isFocused.value
    }
  ]
})

const handleInput = (e) => {
  emit('update:modelValue', e.detail.value)
}

const handleFocus = (e) => {
  isFocused.value = true
  emit('focus', e)
}

const handleBlur = (e) => {
  isFocused.value = false
  emit('blur', e)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.input-wrapper {
  @include input-base;
  position: relative;
  display: flex;
  align-items: center;
  
  &.input-sm {
    min-height: 36px;
    padding: 0 $spacing-3;
    font-size: $font-size-body-sm;
  }
  
  &.input-md {
    min-height: $touch-target-min;
    padding: 0 $spacing-4;
    font-size: $font-size-body-md;
  }
  
  &.input-lg {
    min-height: 52px;
    padding: 0 $spacing-5;
    font-size: $font-size-body-md;
  }
  
  &.input-error {
    border-color: $color-error;
  }
  
  &.input-focused {
    border-color: $color-primary;
  }
  
  &.input-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.input-field {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  color: $color-text-primary;
  
  &::placeholder {
    color: $color-text-tertiary;
  }
}

.input-prefix,
.input-suffix {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.input-prefix {
  margin-right: $spacing-2;
}

.input-suffix {
  margin-left: $spacing-2;
}
</style>
