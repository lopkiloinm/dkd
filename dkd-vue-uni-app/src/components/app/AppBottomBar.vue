<template>
  <view class="app-bottom-bar">
    <view
      v-for="(tab, index) in tabs"
      :key="index"
      class="bottom-tab"
      :class="{ 'bottom-tab-active': activeTab === tab.id }"
      @click="handleTabClick(tab.id)"
    >
      <view class="tab-icon">
        <Icon :name="tab.icon" size="24" color="currentColor" />
      </view>
      <text class="tab-label">{{ tab.label }}</text>
    </view>
  </view>
</template>

<script setup>
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  activeTab: {
    type: String,
    default: 'dashboard'
  }
})

const emit = defineEmits(['tab-change'])

const tabs = [
  { id: 'dashboard', label: 'Home', icon: 'dashboard' },
  { id: 'machines', label: 'VM', icon: 'machines' },
  { id: 'tasks', label: 'Task', icon: 'tasks' },
  { id: 'inventory', label: 'Stock', icon: 'inventory' },
  { id: 'analytics', label: 'Stats', icon: 'analytics' }
]

const handleTabClick = (tabId) => {
  emit('tab-change', tabId)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.app-bottom-bar {
  position: fixed !important;
  bottom: 0 !important;
  left: 0 !important;
  right: 0 !important;
  height: calc(#{$bottom-bar-height} + env(safe-area-inset-bottom, 0px));
  width: 100vw;
  max-width: 100vw;
  @include glass($surface-overlay-strong, transparent);
  border-top: 1px solid $color-border-subtle;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-4;
  padding: $spacing-2 $spacing-2 calc(env(safe-area-inset-bottom, 0px) + $spacing-2);
  z-index: $z-index-fixed;
  transform: translateZ(0);
  opacity: 1;
  visibility: visible;
  overflow: visible;

  @media (max-width: 480px) {
    gap: $spacing-2;
    padding: $spacing-1 $spacing-1 calc(env(safe-area-inset-bottom, 0px) + $spacing-1);
  }

  @media (max-width: 360px) {
    gap: $spacing-1;
    padding: $spacing-1 $spacing-1 calc(env(safe-area-inset-bottom, 0px) + $spacing-1);
  }
}

.bottom-tab {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  padding: $spacing-2 $spacing-3;
  cursor: pointer;
  transition: all $transition-normal;
  color: $color-text-tertiary;

  @media (max-width: 480px) {
    padding: $spacing-1 $spacing-2;
  }

  @media (max-width: 360px) {
    padding: $spacing-1;
  }

  &:active {
    opacity: 0.7;
  }

  &.bottom-tab-active {
    color: $color-primary;

    .tab-icon {
      background: rgba($color-primary, 0.16);
      border-color: rgba($color-primary, 0.24);
    }

    .tab-label {
      color: $color-primary;
    }
  }
}

.tab-icon {
  @include icon-tile-base(34px, $radius-md);
  margin-bottom: $spacing-1;
  color: inherit;
  background: rgba(255, 255, 255, 0.06);
  border-color: rgba(255, 255, 255, 0.08);

  @media (max-width: 360px) {
    margin-bottom: $spacing-0;
  }
}

.tab-label {
  @include text-caption;
  color: inherit;
  font-weight: $font-weight-medium;
  transition: color $transition-normal;

  @media (max-width: 360px) {
    font-size: 10px;
  }
}
</style>
