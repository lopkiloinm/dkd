<template>
  <view v-if="visible" class="drawer-mount">
    <view
      class="drawer-backdrop"
      @click="handleBackdropClick"
      @tap="handleBackdropClick"
    />
    <view :class="drawerClasses" :style="drawerStyle" @click.stop @tap.stop>
      <view class="drawer-body">
        <slot></slot>
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
    default: 'right',
    validator: (value) => ['left', 'right'].includes(value)
  },
  width: {
    type: String,
    default: '300px'
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:visible', 'close'])

const drawerClasses = computed(() => {
  return [
    'drawer',
    `drawer-${props.position}`
  ]
})

const drawerStyle = computed(() => ({
  width: props.width
}))

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

.drawer-mount {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  pointer-events: auto;
}

.drawer-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
  @include overlay-scrim-flat;
}

.drawer {
  position: absolute;
  top: 0;
  bottom: 0;
  z-index: 1;
  @include surface-modal-glass($radius-lg, $shadow-xl);
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
  isolation: auto !important;
  background: $glass-card-shine, rgba(18, 20, 28, 0.96);
  transition: transform $transition-normal ease-out;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  overflow: hidden;

  &.drawer-left {
    left: 0;
    border-radius: 0 $radius-lg $radius-lg 0;
    border-right: 1px solid $glass-card-border;
  }

  &.drawer-right {
    right: 0;
    border-radius: $radius-lg 0 0 $radius-lg;
    border-left: 1px solid $glass-card-border;
  }
}

.drawer-body {
  flex: 1;
  min-height: 0;
  width: 100%;
  padding: $spacing-4;
  box-sizing: border-box;
  overflow-x: hidden;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  @include scrollbar-hidden;
}
</style>
