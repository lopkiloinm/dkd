<template>
  <view :class="sectionClasses">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'body',
    validator: (value) => ['header', 'body', 'footer'].includes(value)
  },
  padding: {
    type: String,
    default: 'md',
    validator: (value) => ['none', 'sm', 'md', 'lg'].includes(value)
  }
})

const sectionClasses = computed(() => {
  return [
    'card-section',
    `card-section-${props.variant}`,
    `card-section-padding-${props.padding}`,
  ]
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

/* CardSection owns its own 4-sided padding. Use inside a Card with
   padding="none" so sibling sections / list rows can render
   edge-to-edge bottom borders while their content stays inset. */
.card-section {
  &.card-section-header {
    padding: $spacing-4 $card-padding $spacing-3 $card-padding;
    &.card-section-padding-none { padding: 0; }
    &.card-section-padding-sm   { padding: $spacing-2 $spacing-3; }
    &.card-section-padding-md   { padding: $spacing-3 $card-padding; }
    &.card-section-padding-lg   { padding: $spacing-4 $spacing-6; }
  }

  &.card-section-body {
    padding: $spacing-4 $card-padding;
    &.card-section-padding-none { padding: 0; }
    &.card-section-padding-sm   { padding: $spacing-2 $spacing-3; }
    &.card-section-padding-md   { padding: $spacing-3 $card-padding; }
    &.card-section-padding-lg   { padding: $spacing-4 $spacing-6; }
  }

  &.card-section-footer {
    padding: $spacing-3 $card-padding $spacing-4 $card-padding;
    &.card-section-padding-none { padding: 0; }
    &.card-section-padding-sm   { padding: $spacing-2 $spacing-3 $spacing-3 $spacing-3; }
    &.card-section-padding-md   { padding: $spacing-3 $card-padding $spacing-4 $card-padding; }
    &.card-section-padding-lg   { padding: $spacing-4 $spacing-6 $spacing-6 $spacing-6; }
  }
}
</style>
