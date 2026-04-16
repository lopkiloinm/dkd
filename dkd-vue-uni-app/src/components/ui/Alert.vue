<template>
  <view v-if="visible" :class="alertClasses">
    <view class="alert-icon" v-if="showIcon">
      <Icon :name="iconName" size="20" color="currentColor" />
    </view>
    <view class="alert-content">
      <text v-if="title" class="alert-title">{{ title }}</text>
      <text class="alert-message">{{ message }}</text>
      <view v-if="$slots.action" class="alert-action">
        <slot name="action"></slot>
      </view>
    </view>
    <view v-if="closable" class="alert-close" @click="handleClose">
      <Icon name="close" size="20" color="currentColor" />
    </view>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  type: {
    type: String,
    default: 'info',
    validator: (value) => ['success', 'error', 'warning', 'info'].includes(value)
  },
  title: {
    type: String,
    default: ''
  },
  message: {
    type: String,
    default: ''
  },
  showIcon: {
    type: Boolean,
    default: true
  },
  dismissible: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['dismiss'])

const iconName = computed(() => {
  const icons = {
    success: 'check',
    error: 'close',
    warning: 'notification',
    info: 'document'
  }
  return icons[props.type]
})

const alertClasses = computed(() => {
  return [
    'alert',
    `alert-${props.type}`
  ]
})

const handleDismiss = () => {
  emit('dismiss')
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.alert {
  display: flex;
  align-items: flex-start;
  gap: $spacing-3;
  padding: $spacing-4;
  border-radius: $radius-md;
  border: 1px solid;
  
  &.alert-success {
    background: rgba($color-success, 0.1);
    border-color: rgba($color-success, 0.3);
  }
  
  &.alert-error {
    background: rgba($color-error, 0.1);
    border-color: rgba($color-error, 0.3);
  }
  
  &.alert-warning {
    background: rgba($color-warning, 0.1);
    border-color: rgba($color-warning, 0.3);
  }
  
  &.alert-info {
    background: rgba($color-primary, 0.1);
    border-color: rgba($color-primary, 0.3);
  }
}

.alert-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  flex-shrink: 0;
  margin-top: 2px;
  
  .icon {
    font-size: 12px;
    font-weight: bold;
    color: white;
  }
  
  .alert-success & {
    background: $color-success;
  }
  
  .alert-error & {
    background: $color-error;
  }
  
  .alert-warning & {
    background: $color-warning;
  }
  
  .alert-info & {
    background: $color-primary;
  }
}

.alert-content {
  flex: 1;
}

.alert-title {
  display: block;
  @include text-title;
  font-size: $font-size-body-md;
  margin-bottom: $spacing-1;
  
  .alert-success & {
    color: $color-success;
  }
  
  .alert-error & {
    color: $color-error;
  }
  
  .alert-warning & {
    color: $color-warning;
  }
  
  .alert-info & {
    color: $color-primary;
  }
}

.alert-message {
  @include text-body;
  color: $color-text-secondary;
}

.alert-dismiss {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  cursor: pointer;
  transition: background-color $transition-normal;
  
  &:active {
    background: rgba(0, 0, 0, 0.1);
  }
  
  .dismiss-icon {
    font-size: 20px;
    line-height: 1;
    color: $color-text-tertiary;
  }
}
</style>
