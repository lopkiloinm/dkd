<template>
  <view class="layout-container">
    <view class="page-header">
      <view class="header-back" @click="handleBack">
        <Icon name="chevron-left" size="18" color="currentColor" />
        <text class="header-back-text">Back</text>
      </view>
      <text class="page-title">Notifications</text>
      <text class="header-action" @click="markAllRead">Mark all</text>
    </view>

    <view class="filter-tabs">
      <scroll-view class="tabs-scroll" scroll-x :show-scrollbar="false">
        <view class="tabs-list">
          <view
            v-for="tab in filterTabs"
            :key="tab.value"
            class="tab-item"
            :class="{ 'tab-active': activeFilter === tab.value }"
            @click="handleFilterTab(tab.value)"
          >
            <text class="tab-text">{{ tab.label }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <scroll-view class="scroll-area" scroll-y refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing" @scrolltolower="loadMore">
      <view class="content-wrapper">
        <view v-if="notificationList.length === 0 && !loading" class="empty-state">
          <EmptyState title="No notifications" description="You're all caught up!" />
        </view>

        <Card
          v-for="item in notificationList"
          :key="item.noticeId"
          class="notification-card"
          :class="{ unread: !item.read }"
          @click="handleViewDetail(item)"
        >
          <view class="notification-header">
            <view class="notification-title-row">
              <view class="notification-dot" v-if="!item.read"></view>
              <text class="notification-title">{{ item.noticeTitle }}</text>
            </view>
            <Badge :variant="getBadgeVariant(item.noticeType)">
              {{ getTypeLabel(item.noticeType) }}
            </Badge>
          </view>

          <text class="notification-preview">{{ stripHtml(item.noticeContent) }}</text>

          <view class="notification-meta">
            <text class="meta-text">{{ item.createBy || 'System' }}</text>
            <text class="meta-text">{{ formatDate(item.createTime) }}</text>
          </view>
        </Card>
      </view>
    </scroll-view>
  </view>

  <BottomSheet
    :visible="showDetail"
    :title="detailData.noticeTitle || 'Notification'"
    @update:visible="val => !val && closeDetail()"
    @close="closeDetail"
  >
    <template #header-actions>
      <view class="action-pill" @click="closeDetail">Close</view>
    </template>

    <view class="detail-meta">
      <Badge :variant="getBadgeVariant(detailData.noticeType)">
        {{ getTypeLabel(detailData.noticeType) }}
      </Badge>
      <text class="meta-text">{{ formatDate(detailData.createTime) }}</text>
    </view>

    <view class="detail-content">
      <text class="detail-text">{{ stripHtml(detailData.noticeContent) }}</text>
    </view>
  </BottomSheet>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import Icon from '@/components/ui/Icon.vue'
import Card from '@/components/ui/Card.vue'
import Badge from '@/components/ui/Badge.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listNotice } from '@/api/system/notice'

const activeFilter = ref('all')
const filterTabs = ref([
  { label: 'All', value: 'all' },
  { label: 'System', value: '2' },
  { label: 'Notice', value: '1' }
])

const notificationList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetail = ref(false)
const detailData = ref({})
const pageNum = ref(1)
const pageSize = ref(20)
const total = ref(0)

const getTypeLabel = (type) => {
  if (type === '1') return 'Notice'
  if (type === '2') return 'System'
  return 'Info'
}

const getBadgeVariant = (type) => {
  if (type === '2') return 'warning'
  if (type === '1') return 'primary'
  return 'default'
}

const stripHtml = (str) => {
  if (!str) return ''
  return str.replace(/<[^>]*>/g, '').trim()
}

const formatDate = (str) => {
  if (!str) return ''
  const d = new Date(str)
  if (isNaN(d)) return str
  return d.toLocaleDateString()
}

const fetchNotifications = async (reset = true) => {
  loading.value = true
  try {
    if (reset) {
      pageNum.value = 1
    }
    const params = { pageNum: pageNum.value, pageSize: pageSize.value, status: '0' }
    if (activeFilter.value !== 'all') {
      params.noticeType = activeFilter.value
    }
    const res = await listNotice(params)
    const rows = (res.rows || []).map((item) => ({ ...item, read: false }))
    notificationList.value = reset ? rows : [...notificationList.value, ...rows]
    total.value = res.total || 0
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const loadMore = () => {
  if (loading.value) return
  if (notificationList.value.length >= total.value) return
  pageNum.value++
  fetchNotifications(false)
}

const onRefresh = async () => {
  isRefreshing.value = true
  await fetchNotifications(true)
  isRefreshing.value = false
}

const handleFilterTab = (value) => {
  activeFilter.value = value
  fetchNotifications(true)
}

const handleViewDetail = (item) => {
  detailData.value = item
  item.read = true
  showDetail.value = true
}

const closeDetail = () => {
  showDetail.value = false
}

const markAllRead = () => {
  notificationList.value = notificationList.value.map((item) => ({ ...item, read: true }))
}

const handleBack = () => {
  const pages = getCurrentPages()
  if (pages.length > 1) {
    uni.navigateBack()
    return
  }
  uni.reLaunch({ url: '/pages/index/index' })
}

onShow(() => {
  fetchNotifications()
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  min-height: 100vh;
  background: $color-bg-primary;
  padding-top: $top-bar-total-height;
}

.page-header {
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

.header-back {
  display: flex;
  align-items: center;
  gap: $spacing-1;
  color: $color-text-secondary;
}

.header-back-text {
  @include text-caption;
  color: inherit;
}

.page-title {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.header-action {
  @include text-caption;
  color: $color-primary;
  font-weight: $font-weight-semibold;
}

.filter-tabs {
  padding: $spacing-3 $spacing-4;
}

.tabs-scroll {
  width: 100%;
  white-space: nowrap;
}

.tabs-list {
  display: flex;
  gap: $spacing-2;
}

.tab-item {
  padding: $spacing-2 $spacing-4;
  border-radius: $radius-full;
  background: $color-bg-tertiary;
  white-space: nowrap;

  &.tab-active {
    background: $color-primary;

    .tab-text {
      color: $color-text-primary;
    }
  }
}

.tab-text {
  @include text-caption;
  color: $color-text-secondary;
}

.scroll-area {
  height: calc(100vh - #{$top-bar-total-height} - 52px);
}


.notification-card {
  cursor: pointer;

  &.unread {
    border-left: 3px solid $color-primary;
  }
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: $spacing-3;
  margin-bottom: $spacing-2;
}

.notification-title-row {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  flex: 1;
  min-width: 0;
}

.notification-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: $color-primary;
  flex-shrink: 0;
}

.notification-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.notification-preview {
  @include text-caption;
  color: $color-text-secondary;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: $spacing-3;
}

.notification-meta {
  display: flex;
  justify-content: space-between;
  gap: $spacing-2;
}

.meta-text {
  @include text-caption;
  color: $color-text-tertiary;
  font-size: $font-size-caption-sm;
}

.empty-state {
  padding: $spacing-6 0;
}

.detail-meta {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  margin-bottom: $spacing-4;
}

.detail-content {
  @include text-body;
  color: $color-text-primary;
  line-height: 1.6;
}

.detail-text {
  @include text-body;
  color: $color-text-primary;
}

.action-pill {
  @include text-caption;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  padding: $spacing-1 $spacing-3;
  border-radius: $radius-full;
  background: $color-bg-tertiary;
}
</style>
