<template>
  <view v-if="visible" class="drawer-overlay" @click="handleOverlayClick">
    <view :class="drawerClasses" :style="drawerStyle" @click.stop>
      <scroll-view class="drawer-body" scroll-y>
        <slot></slot>
      </scroll-view>
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

.drawer-overlay {
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

.drawer {
  position: fixed;
  top: 0;
  bottom: 0;
  z-index: $z-index-modal;
  background: $color-bg-secondary;
  box-shadow: $shadow-xl;
  transition: transform $transition-normal ease-out;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  overflow: hidden;

  &.drawer-left {
    left: 0;
    border-right: 1px solid $color-border-subtle;
  }

  &.drawer-right {
    right: 0;
    border-left: 1px solid $color-border-subtle;
  }
}

.drawer-body {
  flex: 1;
  width: 100%;
  padding: $spacing-4;
  box-sizing: border-box;
  @include scrollbar-hidden;
}
</style>
