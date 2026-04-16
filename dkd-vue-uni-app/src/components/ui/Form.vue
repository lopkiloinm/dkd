<template>
  <view class="form">
    <slot></slot>
  </view>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue', 'submit'])
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.form {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}
</style>
