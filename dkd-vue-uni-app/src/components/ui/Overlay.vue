<template>
  <view v-if="visible" class="overlay" :class="overlayClasses" @click="handleClick">
    <slot></slot>
  </view>
</template>

<script setup>
import { watch } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  blur: {
    type: Boolean,
    default: true
  },
  closeOnClick: {
    type: Boolean,
    default: true
  },
  zIndex: {
    type: Number,
    default: 1000
  }
})

const emit = defineEmits(['update:visible', 'click'])

const overlayClasses = computed(() => {
  return [
    'overlay',
    {
      'overlay-blur': props.blur
    }
  ]
})

const handleClick = () => {
  if (props.closeOnClick) {
    emit('update:visible', false)
  }
  emit('click')
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

.overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  
  &.overlay-blur {
    backdrop-filter: blur(4px);
    -webkit-backdrop-filter: blur(4px);
  }
}
</style>
