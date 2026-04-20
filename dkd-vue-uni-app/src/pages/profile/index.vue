<template>
  <AppTopBar title="Profile" :show-back="true" :show-actions="false" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
      <!-- Profile Header -->
      <view class="profile-header">
        <Avatar :src="profilePicture" :alt="userName" size="xl" />
        <text class="user-name">{{ userName }}</text>
      </view>

      <!-- Settings List -->
      <Card padding="none">
        <CardSection variant="body">
          <view class="settings-list">
            <view class="settings-item" @click="handleSettings('account')">
              <view class="settings-item-left">
                <Icon name="user" size="20" color="currentColor" />
                <text class="settings-item-text">Account Settings</text>
              </view>
              <Icon name="chevron-right" size="20" color="currentColor" class="settings-item-arrow" />
            </view>
            <view class="settings-item" @click="handleSettings('language')">
              <view class="settings-item-left">
                <Icon name="globe" size="20" color="currentColor" />
                <text class="settings-item-text">Language</text>
              </view>
              <Icon name="chevron-right" size="20" color="currentColor" class="settings-item-arrow" />
            </view>
            <view class="settings-item" @click="handleSettings('notifications')">
              <view class="settings-item-left">
                <Icon name="notification" size="20" color="currentColor" />
                <text class="settings-item-text">Notifications</text>
              </view>
              <Icon name="chevron-right" size="20" color="currentColor" class="settings-item-arrow" />
            </view>
            <view class="settings-item" @click="handleSettings('about')">
              <view class="settings-item-left">
                <Icon name="info" size="20" color="currentColor" />
                <text class="settings-item-text">About</text>
              </view>
              <Icon name="chevron-right" size="20" color="currentColor" class="settings-item-arrow" />
            </view>
          </view>
        </CardSection>
      </Card>

      <!-- Logout Button -->
      <Button variant="error" size="lg" @click="handleLogout">
        Log Out
      </Button>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/store/modules/user'
import AppTopBar from '@/components/app/AppTopBar.vue'
import Avatar from '@/components/ui/Avatar.vue'
import Icon from '@/components/ui/Icon.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Button from '@/components/ui/Button.vue'
import { getInfo } from '@/api/login'

const userStore = useUserStore()

const profilePicture = computed(() => userStore.avatar || '/static/default-avatar.png')
const userName = computed(() => userStore.name)

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

const handleSettings = (type) => {
  if (type === 'notifications') {
    uni.navigateTo({ url: '/pages/notifications/index' })
    return
  }
  if (type === 'account') {
    uni.showToast({ title: 'Account settings coming soon', icon: 'none' })
    return
  }
  if (type === 'language') {
    uni.showToast({ title: 'Language settings coming soon', icon: 'none' })
    return
  }
  uni.showToast({ title: 'About page coming soon', icon: 'none' })
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
  background: transparent;
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

.profile-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: $spacing-6;
  padding: $spacing-6;
  background: $color-bg-tertiary;
  border-radius: $radius-lg;
}

.user-name {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
  margin-top: $spacing-3;
  margin-bottom: $spacing-1;
}

.user-role {
  @include text-body;
  color: $color-text-secondary;
}

.settings-list {
  display: flex;
  flex-direction: column;
}

.settings-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-4 0;
  border-bottom: 1px solid $color-border-subtle;
  cursor: pointer;
  transition: background-color $transition-normal;

  &:last-child {
    border-bottom: none;
  }

  &:active {
    background: $color-bg-elevated;
  }
}

.settings-item-left {
  display: flex;
  align-items: center;
  gap: $spacing-3;
}

.settings-item-text {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.settings-item-arrow {
  color: $color-text-tertiary;
}
</style>
