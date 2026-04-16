<template>
  <view :class="appBarClasses">
    <view v-if="$slots.leading" class="appbar-leading">
      <slot name="leading"></slot>
    </view>
    <view v-if="$slots.title" class="appbar-title">
      <slot name="title"></slot>
    </view>
    <view v-if="$slots.trailing" class="appbar-trailing">
      <slot name="trailing"></slot>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'elevated', 'floating'].includes(value)
  },
  fixed: {
    type: Boolean,
    default: false
  }
})

const appBarClasses = computed(() => {
  return [
    'appbar',
    `appbar-${props.variant}`,
    {
      'appbar-fixed': props.fixed
    }
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.appbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: $top-bar-height;
  padding: 0 $spacing-4;
  background: rgba($surface-card, 0.88);
  border-bottom: 1px solid $color-border-subtle;
  
  &.appbar-elevated {
    box-shadow: $shadow-md;
  }
  
  &.appbar-floating {
    @include surface-floating($radius-panel, $shadow-lg);
    margin: $spacing-4;
  }
  
  &.appbar-fixed {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: $z-index-sticky;
  }
}

.appbar-leading,
.appbar-trailing {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  flex-shrink: 0;
}

.appbar-title {
  flex: 1;
  text-align: center;
  overflow: hidden;
  @include text-truncate;
}
</style>
