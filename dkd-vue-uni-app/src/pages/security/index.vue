<template>
  <AppTopBar title="Security" :show-back="true" :show-actions="false" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <Motion preset="fade-up" :index="0">
          <Card title="Security" accent="error" icon="lock" padding="none">
            <view class="menu-list">
              <view class="menu-item" @click="handleChangePassword">
                <view class="menu-item-left">
                  <Icon name="lock" size="20" color="currentColor" />
                  <text class="menu-label">Change Password</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="toggleBiometric">
                <view class="menu-item-left">
                  <Icon name="account" size="20" color="currentColor" />
                  <text class="menu-label">Biometric Login</text>
                </view>
                <text class="menu-value">{{ biometricEnabled ? 'On' : 'Off' }}</text>
              </view>
              <view class="menu-item" @click="handleSessions">
                <view class="menu-item-left">
                  <Icon name="activity" size="20" color="currentColor" />
                  <text class="menu-label">Active Sessions</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="handleAuditLog">
                <view class="menu-item-left">
                  <Icon name="file-text" size="20" color="currentColor" />
                  <text class="menu-label">Audit Log</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
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
const biometricEnabled = ref(false)

const notImplemented = () => {
  uni.showToast({ title: 'Coming soon', icon: 'none' })
}

const handleChangePassword = notImplemented
const handleSessions = notImplemented
const handleAuditLog = () => {
  uni.navigateTo({ url: '/pages/monitor/logininfor/index' })
}

const toggleBiometric = () => {
  biometricEnabled.value = !biometricEnabled.value
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.menu-list { display: flex; flex-direction: column; }
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
.menu-label { @include text-body; color: $color-text-primary; font-weight: $font-weight-medium; }
.menu-value { @include text-caption; color: $color-text-tertiary; }
</style>
