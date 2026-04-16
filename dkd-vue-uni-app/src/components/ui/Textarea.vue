<template>
  <view :class="textareaClasses">
    <textarea
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      :maxlength="maxlength"
      :autoHeight="autoHeight"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      class="textarea-field"
    />
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
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
    default: 500
  },
  autoHeight: {
    type: Boolean,
    default: true
  },
  rows: {
    type: Number,
    default: 3
  },
  error: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'focus', 'blur'])

const isFocused = ref(false)

const textareaClasses = computed(() => {
  return [
    'textarea-wrapper',
    {
      'textarea-disabled': props.disabled,
      'textarea-error': props.error,
      'textarea-focused': isFocused.value
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

.textarea-wrapper {
  @include input-base;
  padding: $spacing-3;
  min-height: 80px;
  
  &.textarea-error {
    border-color: $color-error;
  }
  
  &.textarea-focused {
    border-color: $color-primary;
  }
  
  &.textarea-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.textarea-field {
  width: 100%;
  height: 100%;
  min-height: 60px;
  background: transparent;
  border: none;
  outline: none;
  color: $color-text-primary;
  font-family: $font-family-body;
  font-size: $font-size-body-md;
  line-height: 1.5;
  resize: none;
  
  &::placeholder {
    color: $color-text-tertiary;
  }
}
</style>
