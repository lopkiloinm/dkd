<template>
  <view :class="itemClasses" @click="handleClick">
    <view v-if="$slots.leading" class="item-leading">
      <slot name="leading"></slot>
    </view>
    <view class="item-content">
      <slot></slot>
    </view>
    <view v-if="$slots.trailing" class="item-trailing">
      <slot name="trailing"></slot>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  clickable: {
    type: Boolean,
    default: false
  },
  selected: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['click'])

const itemClasses = computed(() => {
  return [
    'list-item',
    {
      'list-item-clickable': props.clickable,
      'list-item-selected': props.selected,
      'list-item-disabled': props.disabled
    }
  ]
})

const handleClick = (e) => {
  if (!props.disabled && props.clickable) {
    emit('click', e)
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.list-item {
  display: flex;
  align-items: center;
  padding: $spacing-3 $spacing-4;
  background: transparent;
  transition: background-color $transition-normal;
  
  &:last-child {
    border-bottom: none;
  }
  
  &.list-item-clickable {
    cursor: pointer;
    
    &:active {
      background: $color-bg-tertiary;
    }
  }
  
  &.list-item-selected {
    background: rgba($color-primary, 0.1);
  }
  
  &.list-item-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.item-leading {
  display: flex;
  align-items: center;
  margin-right: $spacing-3;
  flex-shrink: 0;
}

.item-content {
  flex: 1;
  min-width: 0;
}

.item-trailing {
  display: flex;
  align-items: center;
  margin-left: $spacing-3;
  flex-shrink: 0;
}
</style>
