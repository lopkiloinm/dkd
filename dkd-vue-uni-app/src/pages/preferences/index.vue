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
              <view class="menu-item">
                <view class="menu-item-left">
                  <Icon name="notification" size="20" color="currentColor" />
                  <text class="menu-label">Notifications</text>
                </view>
                <view class="menu-item-right">
                  <Switch v-model="notificationsEnabled" @change="onNotificationsChange" />
                </view>
              </view>
              <view class="menu-item">
                <view class="menu-item-left">
                  <Icon name="settings" size="20" color="currentColor" />
                  <text class="menu-label">Dark Mode</text>
                </view>
                <view class="menu-item-right">
                  <Switch v-model="darkMode" @change="onThemeChange" />
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
import Icon from '@/components/ui/Icon.vue'
import Motion from '@/components/ui/Motion.vue'
import Switch from '@/components/ui/Switch.vue'
import { useI18n } from 'vue-i18n'

const { locale } = useI18n()
const PREFS_KEY = 'dkd_user_prefs'

const loadPrefs = () => {
  try { return JSON.parse(uni.getStorageSync(PREFS_KEY) || '{}') } catch (e) { return {} }
}
const savedPrefs = loadPrefs()

const currentLanguage = ref(savedPrefs.language || (locale.value === 'zh-CN' ? '中文' : 'English'))
const notificationsEnabled = ref(savedPrefs.notifications !== false)
const darkMode = ref(savedPrefs.darkMode === true)

const persist = () => {
  uni.setStorageSync(PREFS_KEY, JSON.stringify({
    language: currentLanguage.value,
    notifications: notificationsEnabled.value,
    darkMode: darkMode.value
  }))
}

const handleLanguage = () => {
  uni.showActionSheet({
    itemList: ['English', '中文'],
    success: (res) => {
      currentLanguage.value = res.tapIndex === 0 ? 'English' : '中文'
      locale.value = res.tapIndex === 0 ? 'en' : 'zh-CN'
      persist()
    }
  })
}

const onNotificationsChange = () => {
  persist()
}

const onThemeChange = () => {
  persist()
  uni.showToast({ title: 'Dark mode coming soon', icon: 'none' })
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
