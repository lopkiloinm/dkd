<template>
  <view class="empty-state">
    <view v-if="$slots.icon" class="empty-icon">
      <slot name="icon"></slot>
    </view>
    <text v-if="title" class="empty-title">{{ title }}</text>
    <text v-if="description" class="empty-description">{{ description }}</text>
    <view v-if="$slots.action" class="empty-action">
      <slot name="action"></slot>
    </view>
  </view>
</template>

<script setup>
const props = defineProps({
  title: {
    type: String,
    default: 'No data'
  },
  description: {
    type: String,
    default: 'There is nothing to display here'
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-8 $spacing-4;
  text-align: center;
}

.empty-icon {
  margin-bottom: $spacing-4;
  opacity: 0.5;
}

.empty-title {
  @include text-headline;
  color: $color-text-primary;
  margin-bottom: $spacing-2;
}

.empty-description {
  @include text-body;
  color: $color-text-secondary;
  margin-bottom: $spacing-4;
  max-width: 300px;
}

.empty-action {
  margin-top: $spacing-2;
}
</style>
