<template>
  <view :class="chipClasses" @click="handleClick">
    <view v-if="$slots.prefix" class="chip-prefix">
      <slot name="prefix"></slot>
    </view>
    <slot></slot>
    <view v-if="dismissible" class="chip-dismiss" @click.stop="handleDismiss">
      <Icon name="close" size="14" color="currentColor" />
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  selected: {
    type: Boolean,
    default: false
  },
  dismissible: {
    type: Boolean,
    default: false
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg'].includes(value)
  },
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'primary', 'outlined'].includes(value)
  }
})

const emit = defineEmits(['click', 'dismiss'])

const chipClasses = computed(() => {
  return [
    'chip',
    `chip-${props.size}`,
    `chip-${props.variant}`,
    {
      'chip-selected': props.selected
    }
  ]
})

const handleClick = (e) => {
  emit('click', e)
}

const handleDismiss = (e) => {
  emit('dismiss', e)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.chip {
  display: inline-flex;
  align-items: center;
  gap: $spacing-2;
  padding: 6px 12px;
  border-radius: $radius-full;
  font-family: $font-family-body;
  font-size: $font-size-body-sm;
  font-weight: $font-weight-medium;
  cursor: pointer;
  transition: all $transition-normal;
  user-select: none;
  -webkit-tap-highlight-color: transparent;
  
  &.chip-default {
    background: $color-bg-tertiary;
    color: $color-text-primary;
    border: 1px solid $color-border-medium;
    
    &:active {
      background: $color-bg-elevated;
    }
    
    &.chip-selected {
      background: $color-primary;
      color: $color-text-primary;
      border-color: $color-primary;
    }
  }
  
  &.chip-primary {
    background: rgba($color-primary, 0.1);
    color: $color-primary;
    border: 1px solid rgba($color-primary, 0.2);
    
    &:active {
      background: rgba($color-primary, 0.2);
    }
    
    &.chip-selected {
      background: $color-primary;
      color: $color-text-primary;
      border-color: $color-primary;
    }
  }
  
  &.chip-outlined {
    background: transparent;
    color: $color-text-primary;
    border: 1px solid $color-border-medium;
    
    &:active {
      background: $color-bg-tertiary;
    }
    
    &.chip-selected {
      background: $color-primary;
      color: $color-text-primary;
      border-color: $color-primary;
    }
  }
  
  &.chip-sm {
    padding: 4px 10px;
    font-size: $font-size-caption-sm;
  }
  
  &.chip-lg {
    padding: 8px 16px;
    font-size: $font-size-body-md;
  }
}

.chip-prefix {
  display: flex;
  align-items: center;
}

.chip-dismiss {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  margin-left: $spacing-1;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  
  .dismiss-icon {
    font-size: 16px;
    line-height: 1;
    color: inherit;
  }
}
</style>
