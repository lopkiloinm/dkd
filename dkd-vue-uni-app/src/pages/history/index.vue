<template>
  <AppTopBar title="History" :show-back="true" :show-actions="false" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">
        <Card padding="none">
          <CardSection variant="body">
            <view class="menu-list">
              <view class="menu-item" @click="goToOrders">
                <view class="menu-item-left">
                  <Icon name="document" size="20" color="currentColor" />
                  <text class="menu-label">My Orders</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="goToTasks">
                <view class="menu-item-left">
                  <Icon name="tasks" size="20" color="currentColor" />
                  <text class="menu-label">Completed Tasks</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="goToLogins">
                <view class="menu-item-left">
                  <Icon name="history" size="20" color="currentColor" />
                  <text class="menu-label">Login History</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
              <view class="menu-item" @click="goToActivity">
                <view class="menu-item-left">
                  <Icon name="activity" size="20" color="currentColor" />
                  <text class="menu-label">Activity Log</text>
                </view>
                <Icon name="chevron-right" size="18" color="currentColor" />
              </view>
            </view>
          </CardSection>
        </Card>

        <EmptyState
          v-if="false"
          title="No history yet"
          description="Your activity will appear here."
        />
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import AppTopBar from '@/components/app/AppTopBar.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Icon from '@/components/ui/Icon.vue'
import EmptyState from '@/components/ui/EmptyState.vue'

const goToOrders = () => uni.navigateTo({ url: '/pages/manage/orders/index' })
const goToTasks = () => uni.navigateTo({ url: '/pages/manage/task/index' })
const goToLogins = () => uni.navigateTo({ url: '/pages/monitor/logininfor/index' })
const goToActivity = () => uni.navigateTo({ url: '/pages/monitor/operlog/index' })
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
</style>
