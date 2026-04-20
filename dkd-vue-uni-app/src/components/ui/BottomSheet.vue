<template>
  <Sheet
    :visible="visible"
    position="bottom"
    :close-on-overlay-click="closeOnOverlayClick"
    @update:visible="handleVisibleChange"
    @close="handleClose"
  >
    <template #header>
      <view class="bs-handle-wrap">
        <view class="bs-handle" />
      </view>
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

.bs-handle-wrap {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-2 0 $spacing-1 0;
}

.bs-handle {
  width: 36px;
  height: 4px;
  border-radius: 2px;
  background: rgba(255, 255, 255, 0.18);
}

.bs-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-3;
  padding: $spacing-2 $spacing-4 $spacing-3 $spacing-4;
}

.bs-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  flex: 1;
  min-width: 0;
  letter-spacing: 0.1px;
}

.bs-header-actions {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  flex-shrink: 0;
}

.bs-body {
  /* Zero horizontal padding so child sections (`.detail-view` rows,
     `.form-view`) own their own inset and bottom borders span EDGE
     TO EDGE inside the sheet. The `.detail-view` and `.form-view`
     globals in _layout.scss provide the proper inner padding. */
  padding: 0 0 $spacing-4 0;
  box-sizing: border-box;
}
</style>
