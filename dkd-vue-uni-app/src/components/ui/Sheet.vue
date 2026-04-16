<template>
  <view v-if="visible" class="sheet-overlay" @click="handleOverlayClick">
    <view :class="sheetClasses" @click.stop>
      <view v-if="$slots.header" class="sheet-header">
        <slot name="header"></slot>
      </view>
      <scroll-view class="sheet-body" scroll-y>
        <slot></slot>
      </scroll-view>
      <view v-if="$slots.footer" class="sheet-footer">
        <slot name="footer"></slot>
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed, watch } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  position: {
    type: String,
    default: 'bottom',
    validator: (value) => ['bottom', 'top', 'left', 'right'].includes(value)
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:visible', 'close'])

const sheetClasses = computed(() => {
  return [
    'sheet',
    `sheet-${props.position}`
  ]
})

const handleOverlayClick = () => {
  if (props.closeOnOverlayClick) {
    emit('update:visible', false)
    emit('close')
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

.sheet-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

.sheet {
  position: fixed;
  z-index: $z-index-modal;
  background: $color-bg-secondary;
  box-shadow: $shadow-xl;
  transition: transform $transition-normal ease-out;
  box-sizing: border-box;
  width: 100%;
  max-width: 100vw;

  &.sheet-bottom {
    bottom: 0;
    left: 0;
    right: 0;
    border-radius: $radius-lg $radius-lg 0 0;
    max-height: 80vh;
  }
  
  &.sheet-top {
    top: 0;
    left: 0;
    right: 0;
    border-radius: 0 0 $radius-lg $radius-lg;
    max-height: 80vh;
  }
  
  &.sheet-left {
    top: 0;
    bottom: 0;
    left: 0;
    width: 80%;
    max-width: 400px;
    border-radius: 0 $radius-lg $radius-lg 0;
  }
  
  &.sheet-right {
    top: 0;
    bottom: 0;
    right: 0;
    width: 80%;
    max-width: 400px;
    border-radius: $radius-lg 0 0 $radius-lg;
  }
}

.sheet-header {
  padding: $spacing-4;
}

.sheet-body {
  flex: 1;
  max-height: calc(80vh - 120px);
  @include scrollbar-hidden;
  box-sizing: border-box;
}

.sheet-footer {
  padding: $spacing-4;
  border-top: 1px solid $color-border-subtle;
}
</style>
