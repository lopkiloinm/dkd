<template>
  <!-- Backdrop and panel are siblings inside a neutral mount so the panel is not a
       descendant of a `backdrop-filter` layer (which breaks fixed positioning + native inputs). -->
  <view v-if="visible" class="sheet-mount">
    <view
      class="sheet-backdrop"
      @click="handleBackdropClick"
      @tap="handleBackdropClick"
    />
    <view :class="sheetClasses" @click.stop @tap.stop>
      <view v-if="$slots.header" class="sheet-header">
        <slot name="header"></slot>
      </view>
      <view class="sheet-body">
        <view class="sheet-body-inner">
          <slot></slot>
        </view>
      </view>
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

const handleBackdropClick = () => {
  if (props.closeOnOverlayClick) {
    emit('update:visible', false)
    emit('close')
  }
}

watch(() => props.visible, (newVal) => {
  if (typeof document === 'undefined') return
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

.sheet-mount {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  pointer-events: auto;
}

.sheet-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
  @include overlay-scrim-flat;
}

.sheet {
  position: absolute;
  z-index: 1;
  max-width: 100vw;
  @include surface-modal-glass($radius-lg, $shadow-xl);
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
  isolation: auto !important;
  background: $glass-card-shine, rgba(18, 20, 28, 0.96);
  transition: transform $transition-normal ease-out;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  width: 100%;
  pointer-events: auto;

  &.sheet-bottom {
    bottom: 0;
    left: 0;
    right: 0;
    border-radius: $radius-lg $radius-lg 0 0;
    max-height: 85vh;
  }

  &.sheet-top {
    top: 0;
    left: 0;
    right: 0;
    border-radius: 0 0 $radius-lg $radius-lg;
    max-height: 85vh;
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
  flex-shrink: 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.sheet-body {
  flex: 1 1 auto;
  min-height: 0;
  box-sizing: border-box;
  overflow-x: hidden;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  @include scrollbar-hidden;
}

.sheet-body-inner {
  box-sizing: border-box;
}

.sheet-footer {
  flex-shrink: 0;
}
</style>
