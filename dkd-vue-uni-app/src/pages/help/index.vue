<template>
  <AppTopBar title="Help &amp; Support" :show-back="true" :show-actions="false" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <Motion preset="fade-up" :index="0">
          <Card title="Help &amp; Support" accent="primary" icon="help" padding="none">
            <view class="menu-list">
              <view class="menu-item" @click="handleFAQ">
                <view class="menu-item-left">
                  <Icon name="help" size="20" color="currentColor" />
                  <text class="menu-label">FAQ</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="handleContact">
                <view class="menu-item-left">
                  <Icon name="notification" size="20" color="currentColor" />
                  <text class="menu-label">Contact Support</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="handleDocs">
                <view class="menu-item-left">
                  <Icon name="file-text" size="20" color="currentColor" />
                  <text class="menu-label">Documentation</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item">
                <view class="menu-item-left">
                  <Icon name="info" size="20" color="currentColor" />
                  <text class="menu-label">Version</text>
                </view>
                <text class="menu-value">{{ version }}</text>
              </view>
            </view>
          </Card>
        </Motion>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import AppTopBar from '@/components/app/AppTopBar.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Icon from '@/components/ui/Icon.vue'
import Motion from '@/components/ui/Motion.vue'
const version = '1.0.0'

const notImplemented = () => {
  uni.showToast({ title: 'Coming soon', icon: 'none' })
}

const handleFAQ = notImplemented
const handleDocs = notImplemented

const handleContact = () => {
  uni.showModal({
    title: 'Contact Support',
    content: 'Email: support@dikede.example\nPhone: +1 (555) 010-2026',
    showCancel: false
  })
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
