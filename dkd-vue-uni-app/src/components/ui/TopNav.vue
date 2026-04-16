<template>
  <view class="top-nav">
    <view v-if="$slots.leading" class="nav-leading">
      <slot name="leading"></slot>
    </view>
    <view class="nav-center">
      <slot name="center">
        <text class="nav-title">{{ title }}</text>
      </slot>
    </view>
    <view v-if="$slots.trailing" class="nav-trailing">
      <slot name="trailing"></slot>
    </view>
  </view>
</template>

<script setup>
const props = defineProps({
  title: {
    type: String,
    default: ''
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.top-nav {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: $top-bar-height;
  background: $color-bg-secondary;
  border-bottom: 1px solid $color-border-subtle;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 $spacing-4;
  padding-top: env(safe-area-inset-top, 0);
  z-index: $z-index-sticky;
}

.nav-leading,
.nav-trailing {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  flex-shrink: 0;
}

.nav-center {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}
</style>
