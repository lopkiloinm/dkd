<template>
  <view class="app-top-bar" :class="{ 'app-top-bar--sub': showBack }">
    <view class="top-bar-left">
      <view v-if="showBack" class="back-button" @click="goBack">
        <Icon name="arrow-left" size="22" class="back-icon" />
      </view>
      <view v-else class="top-bar-button icon-tile icon-tile--neutral" @click="openSidebar">
        <Icon name="menu" size="20" class="button-icon" />
      </view>
    </view>
    <text class="app-title">{{ title }}</text>
    <view class="top-bar-right">
      <template v-if="showActions">
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
import { ref } from 'vue'
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
  height: $top-bar-total-height;
  @include glass($surface-overlay-strong, transparent);
  border-bottom: 1px solid $color-border-subtle;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: calc(env(safe-area-inset-top, 0px) + $spacing-2) $spacing-4 $spacing-2;
  z-index: $z-index-sticky;
}

.top-bar-left,
.top-bar-right {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  flex: 1;
}

.top-bar-right {
  justify-content: flex-end;
}

.app-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
  text-align: center;
  flex-shrink: 0;
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
  position: relative;

  &:active {
    background: $color-bg-tertiary;
  }
}

.button-icon {
  font-size: 20px;
  line-height: 1;
}

.back-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  margin-left: -4px;
  cursor: pointer;
  color: $color-text-primary;
  border-radius: $radius-sm;

  &:active {
    opacity: 0.6;
  }
}

.back-icon {
  color: $color-text-primary;
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
