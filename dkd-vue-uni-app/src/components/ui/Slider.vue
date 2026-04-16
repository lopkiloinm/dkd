<template>
  <view class="slider">
    <slider
      :value="modelValue"
      :min="min"
      :max="max"
      :step="step"
      :disabled="disabled"
      :activeColor="activeColor"
      :backgroundColor="backgroundColor"
      @change="handleChange"
      @changing="handleChanging"
      class="slider-component"
    />
    <view v-if="showValue" class="slider-value">
      <text>{{ modelValue }}</text>
    </view>
  </view>
</template>

<script setup>
const props = defineProps({
  modelValue: {
    type: Number,
    default: 0
  },
  min: {
    type: Number,
    default: 0
  },
  max: {
    type: Number,
    default: 100
  },
  step: {
    type: Number,
    default: 1
  },
  disabled: {
    type: Boolean,
    default: false
  },
  showValue: {
    type: Boolean,
    default: true
  },
  activeColor: {
    type: String,
    default: '#007aff'
  },
  backgroundColor: {
    type: String,
    default: '#e9e9ea'
  }
})

const emit = defineEmits(['update:modelValue', 'change', 'changing'])

const handleChange = (e) => {
  emit('update:modelValue', e.detail.value)
  emit('change', e.detail.value)
}

const handleChanging = (e) => {
  emit('changing', e.detail.value)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.slider {
  display: flex;
  align-items: center;
  gap: $spacing-3;
}

.slider-component {
  flex: 1;
}

.slider-value {
  @include text-body;
  color: $color-text-primary;
  min-width: 40px;
  text-align: right;
  font-weight: $font-weight-medium;
}
</style>
