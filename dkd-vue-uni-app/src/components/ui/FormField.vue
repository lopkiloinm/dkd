<template>
  <view class="form-field">
    <text v-if="label" class="field-label">{{ label }}</text>
    <slot></slot>
    <text v-if="error" class="field-error">{{ error }}</text>
    <text v-if="hint && !error" class="field-hint">{{ hint }}</text>
  </view>
</template>

<script setup>
const props = defineProps({
  label: {
    type: String,
    default: ''
  },
  error: {
    type: String,
    default: ''
  },
  hint: {
    type: String,
    default: ''
  },
  required: {
    type: Boolean,
    default: false
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.form-field {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
}

.field-label {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.field-error {
  @include text-caption;
  color: $color-error;
}

.field-hint {
  @include text-caption;
  color: $color-text-tertiary;
}
</style>
