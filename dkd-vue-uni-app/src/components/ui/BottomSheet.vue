<template>
  <Sheet
    :visible="visible"
    position="bottom"
    :close-on-overlay-click="closeOnOverlayClick"
    @update:visible="handleVisibleChange"
    @close="handleClose"
  >
    <template #header>
      <view class="bs-header">
        <text class="bs-title">{{ title }}</text>
        <view v-if="$slots['header-actions']" class="bs-header-actions">
          <slot name="header-actions"></slot>
        </view>
      </view>
    </template>

    <view class="bs-body">
      <slot></slot>
    </view>
  </Sheet>
</template>

<script setup>
import Sheet from '@/components/ui/Sheet.vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: ''
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:visible', 'close'])

const handleClose = () => {
  emit('update:visible', false)
  emit('close')
}

const handleVisibleChange = (value) => {
  emit('update:visible', value)
  if (!value) emit('close')
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.bs-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-3;
  padding: $spacing-4;
}

.bs-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  flex: 1;
  min-width: 0;
}

.bs-header-actions {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.bs-body {
  padding: 0 $spacing-4 $spacing-4 $spacing-4;
  box-sizing: border-box;
}
</style>
