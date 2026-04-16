<template>
  <view class="bottom-nav">
    <view
      v-for="(item, index) in items"
      :key="index"
      class="nav-item"
      :class="{ 'nav-item-active': modelValue === index }"
      @click="handleClick(index)"
    >
      <view class="nav-icon">
        <slot name="icon" :item="item" :index="index" :active="modelValue === index">
          <text class="icon">{{ item.icon }}</text>
        </slot>
      </view>
      <text class="nav-label">{{ item.label }}</text>
      <view v-if="item.badge" class="nav-badge">
        <text class="badge-text">{{ item.badge }}</text>
      </view>
    </view>
  </view>
</template>

<script setup>
const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  modelValue: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const handleClick = (index) => {
  emit('update:modelValue', index)
  emit('change', index)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: calc(#{$bottom-bar-height} + env(safe-area-inset-bottom, 0px));
  background: $color-bg-secondary;
  border-top: 1px solid $color-border-subtle;
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding-bottom: env(safe-area-inset-bottom, 0);
  z-index: $z-index-sticky;
}

.nav-item {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  height: 100%;
  padding: $spacing-2;
  cursor: pointer;
  transition: all $transition-normal;
  
  &:active {
    opacity: 0.7;
  }
  
  &.nav-item-active {
    .nav-icon {
      background: rgba($color-primary, 0.12);
      border-color: rgba($color-primary, 0.16);
    }

    .nav-icon .icon,
    .nav-label {
      color: $color-primary;
    }
  }
}

.nav-icon {
  @include icon-tile-base(32px, $radius-md);
  margin-bottom: $spacing-1;
  background: transparent;
  
  .icon {
    font-size: 20px;
    color: $color-text-tertiary;
    transition: color $transition-normal;
  }
}

.nav-label {
  @include text-caption;
  color: $color-text-tertiary;
  font-weight: $font-weight-medium;
  transition: color $transition-normal;
}

.nav-badge {
  position: absolute;
  top: $spacing-1;
  right: 25%;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  background: $color-error;
  border-radius: $radius-full;
  
  .badge-text {
    @include text-label;
    color: white;
    font-weight: $font-weight-semibold;
  }
}
</style>
