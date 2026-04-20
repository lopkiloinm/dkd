<template>
  <AppTopBar title="Account" :show-back="true" :show-actions="false" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <Motion preset="fade-up" :index="0">
          <view class="profile-card">
            <Avatar :src="profilePicture" :alt="userName" size="xl" />
            <text class="user-name">{{ userName }}</text>
            <text class="user-subtitle">{{ userRoleText }}</text>
          </view>
        </Motion>

        <Motion preset="fade-up" :index="1">
          <Card title="Account" accent="primary" icon="user" padding="none">
            <view class="menu-list">
              <view class="menu-item" @click="goTo('/pages/notifications/index')">
                <view class="menu-item-left">
                  <Icon name="notification" size="20" color="currentColor" />
                  <text class="menu-label">Notifications</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" class="menu-arrow" />
              </view>

              <view class="menu-item">
                <view class="menu-item-left">
                  <Icon name="user" size="20" color="currentColor" />
                  <text class="menu-label">Username</text>
                </view>
                <text class="menu-value">{{ userName }}</text>
              </view>

              <view class="menu-item">
                <view class="menu-item-left">
                  <Icon name="info" size="20" color="currentColor" />
                  <text class="menu-label">Version</text>
                </view>
                <text class="menu-value">1.0.0</text>
              </view>
            </view>
          </Card>
        </Motion>

        <Motion preset="fade-up" :index="2">
          <Button variant="error" size="lg" @click="handleLogout">Log Out</Button>
        </Motion>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import Avatar from '@/components/ui/Avatar.vue'
import Icon from '@/components/ui/Icon.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Button from '@/components/ui/Button.vue'
import Motion from '@/components/ui/Motion.vue'
import useUserStore from '@/store/modules/user'
import { getInfo } from '@/api/login'
const userStore = useUserStore()

const userName = computed(() => userStore.name || 'Admin')
const profilePicture = computed(() => userStore.avatar || '/static/default-avatar.png')
const userRoleText = computed(() => {
  if (userStore.roles && userStore.roles.length > 0) {
    return userStore.roles.join(', ')
  }
  return 'Team Member'
})

const fetchUserInfo = async () => {
  try {
    const response = await getInfo()
    if (response && response.user) {
      userStore.setUserInfo({
        name: response.user.nickName || response.user.userName,
        avatar: response.user.avatar,
        roles: response.roles,
        permissions: response.permissions
      })
    }
  } catch (error) {
    console.error('Failed to fetch user info', error)
  }
}

const goTo = (path) => {
  uni.navigateTo({ url: path })
}

const handleLogout = () => {
  userStore.clearToken()
  uni.reLaunch({ url: '/pages/login/index' })
}

onShow(() => {
  fetchUserInfo()
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.scroll-area {
  flex: 1;
}

.content-wrapper {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
  padding-left: $spacing-4;
  padding-right: $spacing-4;
}

.profile-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: $spacing-2;
  padding: $spacing-5 $spacing-4;
  @include surface-panel;
}

.user-name {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.user-subtitle {
  @include text-caption;
  color: $color-text-secondary;
}

.menu-list {
  display: flex;
  flex-direction: column;
}

.menu-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-3;
  padding: $spacing-4 0;
  border-bottom: 1px solid $color-border-subtle;

  &:last-child {
    border-bottom: none;
  }
}

.menu-item-left {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  min-width: 0;
}

.menu-label {
  @include text-body;
  color: $color-text-primary;
}

.menu-value {
  @include text-caption;
  color: $color-text-secondary;
}

.menu-arrow {
  color: $color-text-tertiary;
}
</style>
