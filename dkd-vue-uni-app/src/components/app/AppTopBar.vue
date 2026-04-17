<template>
  <view class="app-top-bar">
    <text class="app-title">AI Smart Shop</text>
    <view class="top-bar-actions">
      <view class="top-bar-button icon-tile icon-tile--neutral" @click="handleSearch">
        <Icon name="search" size="20" class="button-icon" />
      </view>
      <view class="top-bar-button icon-tile icon-tile--neutral notification-button" @click="handleNotification">
        <Icon name="notification" size="20" class="button-icon" />
        <view v-if="unreadCount > 0" class="notification-badge">
          <text class="badge-text">{{ unreadCount > 99 ? '99+' : unreadCount }}</text>
        </view>
      </view>
      <view class="top-bar-button profile-button" @click="handleProfile">
        <Avatar :src="profilePicture" :alt="userName" size="sm" />
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Avatar from '@/components/ui/Avatar.vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  unreadCount: {
    type: Number,
    default: 0
  },
  profilePicture: {
    type: String,
    default: ''
  },
  userName: {
    type: String,
    default: ''
  },
  currentTab: {
    type: String,
    default: 'dashboard'
  }
})

const emit = defineEmits(['add', 'search', 'notification', 'profile'])

const handleAdd = () => {
  emit('add')
}

const handleSearch = () => {
  emit('search')
}

const handleNotification = () => {
  emit('notification')
}

const handleProfile = () => {
  emit('profile')
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.app-top-bar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: $top-bar-total-height;
  @include glass($surface-overlay-strong, transparent);
  border-bottom: 1px solid $color-border-subtle;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: calc(env(safe-area-inset-top, 0px) + $spacing-2) $spacing-4 $spacing-2;
  z-index: $z-index-sticky;
}

.app-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.top-bar-actions {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.top-bar-button {
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  cursor: pointer;
  box-sizing: border-box;

  &:active {
    background: $color-bg-tertiary;
  }

  &.notification-button,
  &.profile-button {
    position: relative;
  }
}

.button-icon {
  font-size: 20px;
  line-height: 1;
}

.notification-badge {
  position: absolute;
  top: -2px;
  right: -2px;
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  background: $color-error;
  border-radius: $radius-full;
  border: none;
  
  .badge-text {
    @include text-label;
    color: white;
    font-weight: $font-weight-semibold;
    line-height: 1;
  }
}
</style>
