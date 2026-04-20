<template>
  <view class="app-top-bar">
    <view class="top-bar-pill">
      <view class="top-bar-side top-bar-side--leading">
        <view
          v-if="showBack"
          class="top-bar-button icon-tile icon-tile--neutral"
          @click="goBack"
        >
          <Icon name="arrow-left" size="20" class="button-icon" />
        </view>
        <view
          v-else
          class="top-bar-button icon-tile icon-tile--neutral"
          @click="openSidebar"
        >
          <Icon name="menu" size="20" class="button-icon" />
        </view>
      </view>
      <text class="app-title">{{ title }}</text>
      <view class="top-bar-side top-bar-side--trailing">
        <view v-if="slots.trailing" class="top-bar-trailing-slot">
          <slot name="trailing" />
        </view>
        <template v-else-if="showActions">
          <view class="top-bar-button icon-tile icon-tile--neutral" @click="handleSearch">
            <Icon name="search" size="20" class="button-icon" />
          </view>
          <view class="top-bar-button icon-tile icon-tile--neutral notification-button" @click="handleNotification">
            <Icon name="notification" size="20" class="button-icon" />
            <view v-if="unreadCount > 0" class="notification-badge">
              <text class="badge-text">{{ unreadCount > 99 ? '99+' : unreadCount }}</text>
            </view>
          </view>
        </template>
      </view>
    </view>
  </view>

  <Drawer v-if="!showBack" v-model:visible="sidebarOpen" position="left" width="280px">
    <view class="sidebar-header">
      <Avatar :src="profilePicture" :alt="userName" size="lg" />
      <view class="sidebar-user-info">
        <text class="sidebar-user-name">{{ userName || 'User' }}</text>
        <text class="sidebar-user-role">{{ userRole || 'Operator' }}</text>
      </view>
    </view>

    <view class="sidebar-section">
      <view
        v-for="item in menuItems"
        :key="item.id"
        class="sidebar-item"
        :class="{ 'sidebar-item--danger': item.danger }"
        @click="handleMenuClick(item)"
      >
        <Icon :name="item.icon" size="20" class="sidebar-item-icon" />
        <text class="sidebar-item-label">{{ item.label }}</text>
        <Icon v-if="!item.danger" name="chevron-right" size="16" class="sidebar-item-chevron" />
      </view>
    </view>

    <view class="sidebar-footer">
      <text class="sidebar-footer-text">AI Smart Shop · v1.0</text>
    </view>
  </Drawer>
</template>

<script setup>
import { ref, useSlots } from 'vue'
import Avatar from '@/components/ui/Avatar.vue'
import Icon from '@/components/ui/Icon.vue'
import Drawer from '@/components/ui/Drawer.vue'

const props = defineProps({
  title: {
    type: String,
    default: 'AI Smart Shop'
  },
  showBack: {
    type: Boolean,
    default: false
  },
  showActions: {
    type: Boolean,
    default: true
  },
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
  userRole: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['search', 'notification'])

const slots = useSlots()
const sidebarOpen = ref(false)

const goBack = () => {
  const pages = getCurrentPages()
  if (pages.length > 1) {
    uni.navigateBack()
  } else {
    uni.reLaunch({ url: '/pages/index/index' })
  }
}

const menuItems = [
  { id: 'account', label: 'Account', icon: 'account', route: '/pages/mine/index' },
  { id: 'preferences', label: 'Preferences', icon: 'settings', route: '/pages/preferences/index' },
  { id: 'security', label: 'Security', icon: 'lock', route: '/pages/security/index' },
  { id: 'history', label: 'History', icon: 'history', route: '/pages/history/index' },
  { id: 'help', label: 'Help & Support', icon: 'help', route: '/pages/help/index' },
  { id: 'logout', label: 'Log Out', icon: 'logout', danger: true }
]

const openSidebar = () => {
  sidebarOpen.value = true
}

const handleSearch = () => {
  emit('search')
}

const handleNotification = () => {
  emit('notification')
}

const handleMenuClick = async (item) => {
  sidebarOpen.value = false
  if (item.id === 'logout') {
    uni.showModal({
      title: 'Log Out',
      content: 'Are you sure you want to log out?',
      success: async (res) => {
        if (res.confirm) {
          const { default: useUserStore } = await import('@/store/modules/user')
          const userStore = useUserStore()
          userStore.clearToken()
          uni.reLaunch({ url: '/pages/login/index' })
        }
      }
    })
    return
  }
  if (item.route) {
    uni.navigateTo({
      url: item.route,
      fail: () => {
        uni.showToast({ title: `${item.label} coming soon`, icon: 'none' })
      }
    })
  }
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
  min-height: $top-bar-total-height;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: calc(env(safe-area-inset-top, 0px) + #{$top-bar-pad-after-safe}) $top-bar-inline-margin $top-bar-pad-below-pill;
  z-index: $z-index-sticky;
  background: transparent;
  pointer-events: none;

  > * {
    pointer-events: auto;
  }
}

.top-bar-pill {
  @include surface-floating($radius-pill, $shadow-md);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-2;
  width: 100%;
  max-width: $top-bar-pill-max-width;
  min-height: $top-bar-pill-height;
  padding: 0 $spacing-2;
  box-sizing: border-box;
}

.top-bar-side {
  flex: 0 0 $top-bar-side-slot-width;
  display: flex;
  align-items: center;
  gap: $spacing-2;
  min-width: 0;
  box-sizing: border-box;
}

.top-bar-side--leading {
  justify-content: flex-start;
}

.top-bar-side--trailing {
  justify-content: flex-end;
}

.top-bar-trailing-slot {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex: 1;
  min-width: 0;

  /* Slot content (e.g. “Mark all”) — class must be set on slotted nodes */
  :deep(.top-bar-trailing-action) {
    @include text-caption;
    color: $color-primary;
    font-weight: $font-weight-semibold;
    padding: $spacing-1 $spacing-2;
    flex-shrink: 0;
  }
}

.app-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
  text-align: center;
  flex: 1 1 auto;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.top-bar-button {
  margin: 0;
  cursor: pointer;
  box-sizing: border-box;
  position: relative;
  flex-shrink: 0;
  @include interactive-pressable(0.96);

  &:active {
    opacity: 0.88;
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

  .badge-text {
    @include text-label;
    color: white;
    font-weight: $font-weight-semibold;
    line-height: 1;
  }
}

// ---- Sidebar ----
.sidebar-header {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-2 $spacing-2 $spacing-4;
  border-bottom: 1px solid $color-border-subtle;
  margin-bottom: $spacing-3;
}

.sidebar-user-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
  flex: 1;
  min-width: 0;
}

.sidebar-user-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.sidebar-user-role {
  @include text-caption;
  color: $color-text-tertiary;
}

.sidebar-section {
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}

.sidebar-item {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3;
  border-radius: $radius-md;
  cursor: pointer;
  transition: background $transition-fast;

  &:active {
    background: $color-bg-tertiary;
  }

  &--danger {
    color: $color-error;
    margin-top: $spacing-4;
    border-top: 1px solid $color-border-subtle;
    border-radius: 0;
    padding-top: $spacing-4;

    .sidebar-item-label { color: $color-error; }
    .sidebar-item-icon { color: $color-error; }
  }
}

.sidebar-item-icon {
  color: $color-text-secondary;
  flex-shrink: 0;
}

.sidebar-item-label {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
  flex: 1;
}

.sidebar-item-chevron {
  color: $color-text-tertiary;
  flex-shrink: 0;
}

.sidebar-footer {
  margin-top: auto;
  padding-top: $spacing-6;
  text-align: center;
}

.sidebar-footer-text {
  @include text-caption;
  color: $color-text-tertiary;
}
</style>
