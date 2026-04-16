<template>
  <view v-if="visible" class="modal-overlay" @click="handleOverlayClick">
    <view :class="modalClasses" @click.stop>
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

.modal-overlay {
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

.modal {
  background: $color-bg-secondary;
  border-radius: $radius-lg;
  box-shadow: $shadow-xl;
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
}

.modal-body {
  flex: 1;
  padding: $spacing-4;
  overflow-y: auto;
  @include scrollbar-hidden;
}

.modal-footer {
  padding: $spacing-4;
}
</style>
