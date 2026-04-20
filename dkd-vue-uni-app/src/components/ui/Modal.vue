<template>
  <view v-if="visible" class="modal-mount">
    <view
      class="modal-backdrop"
      @click="handleBackdropClick"
      @tap="handleBackdropClick"
    />
    <view class="modal-stage">
      <view :class="modalClasses" @click.stop @tap.stop>
        <view v-if="$slots.header" class="modal-header">
          <slot name="header"></slot>
        </view>
        <view class="modal-body">
          <slot></slot>
        </view>
        <view v-if="$slots.footer" class="modal-footer">
          <slot name="footer"></slot>
        </view>
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
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['sm', 'md', 'lg', 'full'].includes(value)
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:visible', 'close'])

const modalClasses = computed(() => {
  return [
    'modal',
    `modal-${props.size}`
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

.modal-mount {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  pointer-events: auto;
}

.modal-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
  @include overlay-scrim-flat;
}

.modal-stage {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-4;
  box-sizing: border-box;
  pointer-events: none;
}

.modal {
  pointer-events: auto;
  @include surface-modal-glass($radius-lg, $shadow-xl);
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
  isolation: auto !important;
  background: $glass-card-shine, rgba(18, 20, 28, 0.96);
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;

  &.modal-sm {
    width: 90%;
    max-width: 400px;
  }

  &.modal-md {
    width: 90%;
    max-width: 600px;
  }

  &.modal-lg {
    width: 90%;
    max-width: 800px;
  }

  &.modal-full {
    width: 100%;
    height: 100%;
    max-width: none;
    max-height: none;
    border-radius: 0;
  }
}

.modal-header {
  padding: $spacing-4;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.modal-body {
  flex: 1;
  padding: $spacing-4;
  overflow-y: auto;
  @include scrollbar-hidden;
}

.modal-footer {
  padding: $spacing-4;
  border-top: 1px solid rgba(255, 255, 255, 0.08);
}
</style>
