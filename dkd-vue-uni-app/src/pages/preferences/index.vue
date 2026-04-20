<template>
  <AppTopBar title="Preferences" :show-back="true" :show-actions="false" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <Motion preset="fade-up" :index="0">
          <Card title="Preferences" accent="primary" icon="settings" padding="none">
            <view class="menu-list">
              <view class="menu-item" @click="handleLanguage">
                <view class="menu-item-left">
                  <Icon name="globe" size="20" color="currentColor" />
                  <text class="menu-label">Language</text>
                </view>
                <view class="menu-item-right">
                  <text class="menu-value">{{ currentLanguage }}</text>
                  <Icon name="chevron-right" size="18" color="currentColor" />
                </view>
              </view>
              <view class="menu-item" @click="toggleNotifications">
                <view class="menu-item-left">
                  <Icon name="notification" size="20" color="currentColor" />
                  <text class="menu-label">Notifications</text>
                </view>
                <view class="menu-item-right">
                  <text class="menu-value">{{ notificationsEnabled ? 'On' : 'Off' }}</text>
                </view>
              </view>
              <view class="menu-item" @click="toggleTheme">
                <view class="menu-item-left">
                  <Icon name="settings" size="20" color="currentColor" />
                  <text class="menu-label">Theme</text>
                </view>
                <view class="menu-item-right">
                  <text class="menu-value">{{ theme }}</text>
                </view>
              </view>
            </view>
          </Card>
        </Motion>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import AppTopBar from '@/components/app/AppTopBar.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Icon from '@/components/ui/Icon.vue'
import Motion from '@/components/ui/Motion.vue'
const currentLanguage = ref('English')
const notificationsEnabled = ref(true)
const theme = ref('Light')

const handleLanguage = () => {
  uni.showActionSheet({
    itemList: ['English', '中文'],
    success: (res) => {
      currentLanguage.value = res.tapIndex === 0 ? 'English' : '中文'
    }
  })
}

const toggleNotifications = () => {
  notificationsEnabled.value = !notificationsEnabled.value
}

const toggleTheme = () => {
  theme.value = theme.value === 'Light' ? 'Dark' : 'Light'
  uni.showToast({ title: 'Dark mode coming soon', icon: 'none' })
  theme.value = 'Light'
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.menu-list {
  display: flex;
  flex-direction: column;
}

.menu-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-3 $spacing-4;
  border-bottom: 1px solid $color-border-subtle;
  cursor: pointer;

  &:last-child { border-bottom: none; }
  &:active { background: $color-bg-tertiary; }
}

.menu-item-left {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  color: $color-text-primary;
}

.menu-item-right {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  color: $color-text-tertiary;
}

.menu-label {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.menu-value {
  @include text-caption;
  color: $color-text-tertiary;
}
</style>
