<template>
  <view class="app-bottom-bar">
    <view class="bottom-bar-pill">
      <view
        v-for="(tab, index) in tabs"
        :key="index"
        class="bottom-tab"
        :class="{ 'bottom-tab-active': activeTab === tab.id }"
        @click="handleTabClick(tab.id)"
      >
        <view class="tab-icon">
          <Icon :name="tab.icon" size="22" color="currentColor" />
        </view>
        <text class="tab-label">{{ tab.label }}</text>
      </view>
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
  height: $bottom-bar-total-height;
  width: 100vw;
  display: flex;
  align-items: flex-end;
  justify-content: center;
  padding: $spacing-2 $bottom-bar-inline-margin calc(env(safe-area-inset-bottom, 0px) + $spacing-2);
  z-index: $z-index-fixed;
  box-sizing: border-box;
  background: transparent;
  pointer-events: none;

  > * {
    pointer-events: auto;
  }
}

.bottom-bar-pill {
  @include surface-floating($radius-pill, $shadow-lg);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-1;
  width: 100%;
  max-width: $bottom-bar-pill-max-width;
  min-height: $bottom-bar-pill-height;
  padding: $spacing-1 $spacing-2;

  @media (max-width: 480px) {
    gap: $spacing-2;
    padding: $spacing-2;
  }

  @media (max-width: 360px) {
    gap: $spacing-1;
    padding: $spacing-1;
  }
}

.bottom-tab {
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  flex: 1;
  min-height: calc(#{$bottom-bar-pill-height} - #{$spacing-4});
  padding: $spacing-2 $spacing-2;
  border-radius: $radius-pill;
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
      background: transparent;
      border-color: transparent;
      box-shadow: none;
    }

    .tab-label {
      color: $color-primary;
    }
  }
}

.tab-icon {
  @include icon-tile-base(40px);
  margin-bottom: $spacing-1;
  color: inherit;
  background: transparent;
  border-color: transparent;
  transition: opacity $transition-normal, transform $transition-normal;

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
