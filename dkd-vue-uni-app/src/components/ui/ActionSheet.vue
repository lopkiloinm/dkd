<template>
  <view v-if="visible" class="action-sheet-overlay" @click="handleOverlayClick">
    <view class="action-sheet" @click.stop>
      <view class="action-sheet-header">
        <text class="sheet-title">{{ title }}</text>
        <view class="sheet-close" @click="handleClose">
          <Icon name="close" size="24" color="currentColor" />
        </view>
      </view>
      <scroll-view class="action-sheet-body" scroll-y>
        <view
          v-for="(action, index) in actions"
          :key="index"
          class="action-item"
          :class="{ 'action-item-destructive': action.destructive }"
          @click="handleActionClick(action, index)"
        >
          <text class="action-label">{{ action.label }}</text>
          <text v-if="action.icon" class="action-icon">{{ action.icon }}</text>
        </view>
      </scroll-view>
      <view v-if="$slots.footer" class="action-sheet-footer">
        <slot name="footer"></slot>
      </view>
    </view>
  </view>
</template>

<script setup>
import { watch } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: ''
  },
  actions: {
    type: Array,
    default: () => []
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:visible', 'close', 'action'])

const handleOverlayClick = () => {
  if (props.closeOnOverlayClick) {
    handleClose()
  }
}

const handleClose = () => {
  emit('update:visible', false)
  emit('close')
}

const handleActionClick = (action, index) => {
  emit('action', action, index)
  if (!action.keepOpen) {
    handleClose()
  }
}

watch(() => props.visible, (newVal) => {
  if (newVal) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.action-sheet-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  @include flex-center;
}

.action-sheet {
  background: $color-bg-secondary;
  border-radius: $radius-lg;
  width: 90%;
  max-width: 400px;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  box-shadow: $shadow-xl;
  @include scale-in;
}

.action-sheet-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-4;
}

.sheet-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.sheet-close {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  cursor: pointer;
  transition: background-color $transition-normal;
  
  &:active {
    background: $color-bg-tertiary;
  }
  
  .close-icon {
    font-size: 24px;
    line-height: 1;
    color: $color-text-tertiary;
  }
}

.action-sheet-body {
  flex: 1;
  padding: $spacing-2;
  @include scrollbar-hidden;
}

.action-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-3 $spacing-4;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: background-color $transition-normal;
  
  &:active {
    background: $color-bg-tertiary;
  }
  
  &.action-item-destructive {
    .action-label {
      color: $color-error;
    }
  }
}

.action-label {
  @include text-body;
  color: $color-text-primary;
}

.action-icon {
  font-size: 20px;
  color: $color-text-tertiary;
}

.action-sheet-footer {
  padding: $spacing-4;
  border-top: 1px solid $color-border-subtle;
}
</style>
