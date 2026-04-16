<template>
  <view class="popover-wrapper">
    <view @click="togglePopover">
      <slot name="trigger"></slot>
    </view>
    <view v-if="visible" class="popover" :class="popoverClasses" :style="popoverStyle">
    <scroll-view class="popover-content" scroll-y>
      <slot></slot>
    </scroll-view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  position: {
    type: String,
    default: 'bottom',
    validator: (value) => ['top', 'bottom', 'left', 'right'].includes(value)
  },
  width: {
    type: String,
    default: '200px'
  },
  closeOnClickOutside: {
    type: Boolean,
    default: true
  }
})

const visible = ref(false)

const popoverClasses = computed(() => {
  return [
    'popover',
    `popover-${props.position}`
  ]
})

const popoverStyle = computed(() => ({
  width: props.width
}))

const togglePopover = () => {
  visible.value = !visible.value
}

const closePopover = () => {
  visible.value = false
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.popover-wrapper {
  position: relative;
  display: inline-block;
}

.popover {
  position: absolute;
  z-index: $z-index-popover;
  background: $color-bg-secondary;
  border: 1px solid $color-border-medium;
  border-radius: $radius-md;
  box-shadow: $shadow-lg;
  max-height: 300px;
  @include fade-in;
  
  &.popover-top {
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-bottom: $spacing-2;
  }
  
  &.popover-bottom {
    top: 100%;
    left: 50%;
    transform: translateX(-50%);
    margin-top: $spacing-2;
  }
  
  &.popover-left {
    right: 100%;
    top: 50%;
    transform: translateY(-50%);
    margin-right: $spacing-2;
  }
  
  &.popover-right {
    left: 100%;
    top: 50%;
    transform: translateY(-50%);
    margin-left: $spacing-2;
  }
}

.popover-content {
  padding: $spacing-3;
  @include scrollbar-hidden;
}
</style>
