<template>
  <view :class="searchBarClasses">
    <view class="search-icon">
      <Icon name="search" size="16" color="currentColor" />
    </view>
    <input
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      @input="handleInput"
      @focus="handleFocus"
      @blur="handleBlur"
      class="search-input"
    />
    <view v-if="modelValue" class="clear-icon" @click="handleClear">
      <Icon name="close" size="20" color="currentColor" />
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  modelValue: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: 'Search...'
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'focus', 'blur', 'clear', 'search'])

const searchBarClasses = computed(() => {
  return [
    'search-bar',
    {
      'search-bar-disabled': props.disabled
    }
  ]
})

const handleInput = (e) => {
  emit('update:modelValue', e.detail.value)
}

const handleFocus = (e) => {
  emit('focus', e)
}

const handleBlur = (e) => {
  emit('blur', e)
}

const handleClear = () => {
  emit('update:modelValue', '')
  emit('clear')
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.search-bar {
  @include input-base;
  display: flex;
  align-items: center;
  gap: $spacing-2;
  padding: 0 $spacing-3;
  
  &.search-bar-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.search-icon,
.clear-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.search-icon {
  .icon {
    font-size: 16px;
  }
}

.clear-icon {
  cursor: pointer;
  
  .icon {
    font-size: 20px;
    line-height: 1;
    color: $color-text-tertiary;
  }
}

.search-input {
  flex: 1;
  height: 100%;
  background: transparent;
  border: none;
  outline: none;
  color: $color-text-primary;
  font-family: $font-family-body;
  font-size: $font-size-body-md;
  
  &::placeholder {
    color: $color-text-tertiary;
  }
}
</style>
