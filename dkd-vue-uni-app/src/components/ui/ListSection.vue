<template>
  <view class="list-section">
    <view v-if="title" class="list-section-header">
      <text class="list-section-title">{{ title }}</text>
    </view>
    <view class="list-section-body">
      <slot></slot>
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

.list-section {
  margin-bottom: $spacing-4;
}

.list-section-header {
  padding: $spacing-2 $spacing-4;
  background: $color-bg-tertiary;
}

.list-section-title {
  @include text-caption;
  font-weight: $font-weight-semibold;
  color: $color-text-tertiary;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.list-section-body {
  background: $color-bg-secondary;
  border-top: 1px solid $color-border-subtle;
  border-bottom: 1px solid $color-border-subtle;
}
</style>
