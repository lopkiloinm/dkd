<template>
  <view class="tag-cloud">
    <view
      v-for="(tag, index) in tags"
      :key="index"
      class="tag-item"
      :class="tagClasses(tag)"
      :style="tagStyle(tag)"
      @click="handleTagClick(tag, index)"
    >
      <text class="tag-text">{{ tag.label }}</text>
      <text v-if="tag.count" class="tag-count">{{ tag.count }}</text>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  tags: {
    type: Array,
    default: () => []
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

const emit = defineEmits(['tag-click'])

const tagClasses = (tag) => {
  return [
    'tag-item',
    `tag-${props.size}`,
    `tag-${props.variant}`,
    {
      'tag-active': tag.active
    }
  ]
}

const tagStyle = (tag) => {
  if (tag.color) {
    return {
      background: tag.variant === 'outlined' ? 'transparent' : tag.color + '20',
      borderColor: tag.color,
      color: tag.color
    }
  }
  return {}
}

const handleTagClick = (tag, index) => {
  emit('tag-click', tag, index)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.tag-cloud {
  display: flex;
  flex-wrap: wrap;
  gap: $spacing-2;
}

.tag-item {
  display: inline-flex;
  align-items: center;
  gap: $spacing-1;
  padding: $spacing-2 $spacing-3;
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $transition-normal;
  
  &:active {
    transform: scale(0.95);
  }
  
  &.tag-default {
    background: $color-bg-tertiary;
    color: $color-text-primary;
    border: 1px solid $color-border-medium;
    
    &:active {
      background: $color-bg-elevated;
    }
    
    &.tag-active {
      background: $color-primary;
      color: $color-text-primary;
      border-color: $color-primary;
    }
  }
  
  &.tag-primary {
    background: rgba($color-primary, 0.1);
    color: $color-primary;
    border: 1px solid rgba($color-primary, 0.2);
    
    &:active {
      background: rgba($color-primary, 0.2);
    }
    
    &.tag-active {
      background: $color-primary;
      color: $color-text-primary;
      border-color: $color-primary;
    }
  }
  
  &.tag-outlined {
    background: transparent;
    color: $color-text-primary;
    border: 1px solid $color-border-medium;
    
    &:active {
      background: $color-bg-tertiary;
    }
    
    &.tag-active {
      background: $color-primary;
      color: $color-text-primary;
      border-color: $color-primary;
    }
  }
  
  &.tag-sm {
    padding: 4px 10px;
    font-size: $font-size-caption-sm;
  }
  
  &.tag-md {
    padding: 6px 12px;
    font-size: $font-size-caption-md;
  }
  
  &.tag-lg {
    padding: 8px 16px;
    font-size: $font-size-body-sm;
  }
}

.tag-text {
  font-weight: $font-weight-medium;
}

.tag-count {
  @include text-caption;
  color: inherit;
  opacity: 0.7;
}
</style>
