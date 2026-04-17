<template>
  <view class="layout-container">
    <AppTopBar
      :user-name="userName"
      :profile-picture="profilePicture"
      :unread-count="unreadCount"
      @search="handleSearch"
      @notification="handleNotification"
      @profile="handleProfile"
    />

    <view class="page-header">
      <view class="header-main">
        <text class="page-title">Orders</text>
        <text class="page-subtitle">Transaction history</text>
      </view>
    </view>

    <view class="filter-tabs">
      <scroll-view scroll-x :show-scrollbar="false">
        <view class="tabs-list">
          <view
            v-for="tab in statusTabs"
            :key="tab.value === null ? 'all' : tab.value"
            class="tab-item"
            :class="{ 'tab-active': queryParams.status === tab.value }"
            @click="onTab(tab.value)"
          >
            <text class="tab-text">{{ tab.label }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <view class="filter-bar">
      <input
        class="search-input"
        v-model="queryParams.innerCode"
        placeholder="Filter by machine code"
        confirm-type="search"
        @confirm="fetchList(true)"
      />
      <Button variant="ghost" size="sm" @click="fetchList(true)">Apply</Button>
    </view>

    <scroll-view
      scroll-y
      class="scroll-area"
      refresher-enabled
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
      @scrolltolower="loadMore"
    >
      <view v-if="orderList.length > 0" class="order-list">
        <Card
          v-for="item in orderList"
          :key="item.id"
          class="order-card"
          @click="openDetail(item)"
        >
          <view class="card-header">
            <text class="order-no">{{ item.orderNo }}</text>
            <Badge :variant="statusVariant(item.status)">{{ statusText(item.status) }}</Badge>
          </view>
          <view class="order-body">
            <view class="info-row">
              <text class="info-label">SKU</text>
              <text class="info-value">{{ item.skuName || '—' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Machine</text>
              <text class="info-value">{{ item.innerCode }} · {{ item.channelCode || '—' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Amount</text>
              <text class="info-value info-value--strong">{{ formatMoney(item.amount) }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Pay</text>
              <text class="info-value">{{ item.payType || '—' }} · {{ payStatusText(item.payStatus) }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Placed</text>
              <text class="info-value">{{ formatTime(item.createTime) }}</text>
            </view>
          </view>
        </Card>
      </view>
      <EmptyState v-else-if="!loading" icon="receipt" text="No orders" />
    </scroll-view>

    <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />

    <BottomSheet
      :visible="showDetail"
      title="Order Details"
      @update:visible="val => !val && (showDetail = false)"
      @close="showDetail = false"
    >
      <view v-if="detail" class="detail-view">
        <view class="detail-row"><text class="detail-label">Order No</text><text class="detail-value">{{ detail.orderNo }}</text></view>
        <view class="detail-row"><text class="detail-label">Status</text><Badge :variant="statusVariant(detail.status)">{{ statusText(detail.status) }}</Badge></view>
        <view class="detail-row"><text class="detail-label">SKU</text><text class="detail-value">{{ detail.skuName }}</text></view>
        <view class="detail-row"><text class="detail-label">Machine</text><text class="detail-value">{{ detail.innerCode }}</text></view>
        <view class="detail-row"><text class="detail-label">Channel</text><text class="detail-value">{{ detail.channelCode || '—' }}</text></view>
        <view class="detail-row"><text class="detail-label">Amount</text><text class="detail-value">{{ formatMoney(detail.amount) }}</text></view>
        <view class="detail-row"><text class="detail-label">List Price</text><text class="detail-value">{{ formatMoney(detail.price) }}</text></view>
        <view class="detail-row"><text class="detail-label">Partner Bill</text><text class="detail-value">{{ formatMoney(detail.bill) }}</text></view>
        <view class="detail-row"><text class="detail-label">Pay Type</text><text class="detail-value">{{ detail.payType || '—' }}</text></view>
        <view class="detail-row"><text class="detail-label">Pay Status</text><text class="detail-value">{{ payStatusText(detail.payStatus) }}</text></view>
        <view class="detail-row"><text class="detail-label">Region</text><text class="detail-value">{{ detail.regionName || '—' }}</text></view>
        <view class="detail-row"><text class="detail-label">Node</text><text class="detail-value">{{ detail.nodeName || '—' }}</text></view>
        <view class="detail-row"><text class="detail-label">Consumer</text><text class="detail-value">{{ detail.openId || 'Anonymous' }}</text></view>
        <view class="detail-row"><text class="detail-label">Placed</text><text class="detail-value">{{ formatTime(detail.createTime) }}</text></view>
      </view>
    </BottomSheet>
  </view>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Card from '@/components/ui/Card.vue'
import Badge from '@/components/ui/Badge.vue'
import Button from '@/components/ui/Button.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { listOrder, getOrder } from '@/api/manage/order'
import { getInfo } from '@/api/login'

const orderList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetail = ref(false)
const detail = ref(null)
const total = ref(0)
const activeTab = ref('data')
const userName = ref('')
const profilePicture = ref('')
const unreadCount = ref(0)

const queryParams = reactive({
  pageNum: 1,
  pageSize: 20,
  innerCode: '',
  status: null
})

const statusTabs = [
  { label: 'All',        value: null },
  { label: 'Dispensed',  value: 2 },
  { label: 'Paid',       value: 1 },
  { label: 'Failed',     value: 3 },
  { label: 'Cancelled',  value: 4 },
  { label: 'Pending',    value: 0 }
]

getInfo().then(res => {
  userName.value = res.user?.userName || ''
  profilePicture.value = res.user?.avatar || ''
}).catch(() => {})

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.pageNum = 1
    orderList.value = []
  }
  loading.value = true
  try {
    const res = await listOrder({ ...queryParams })
    const rows = res.rows || []
    if (reset) {
      orderList.value = rows
    } else {
      orderList.value = [...orderList.value, ...rows]
    }
    total.value = res.total || 0
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const loadMore = () => {
  if (orderList.value.length >= total.value) return
  queryParams.pageNum += 1
  fetchList(false)
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
}

const onTab = (v) => {
  queryParams.status = v
  fetchList(true)
}

const openDetail = async (item) => {
  try {
    const res = await getOrder(item.id)
    detail.value = res.data || item
  } catch (e) {
    detail.value = item
  }
  showDetail.value = true
}

const statusText = (s) => {
  switch (s) {
    case 0: return 'Pending'
    case 1: return 'Paid'
    case 2: return 'Dispensed'
    case 3: return 'Failed'
    case 4: return 'Cancelled'
    default: return '—'
  }
}
const statusVariant = (s) => {
  switch (s) {
    case 2: return 'success'
    case 1: return 'info'
    case 3: return 'danger'
    case 4: return 'neutral'
    default: return 'warning'
  }
}
const payStatusText = (s) => {
  switch (s) {
    case 0: return 'Unpaid'
    case 1: return 'Paid'
    case 2: return 'Refunding'
    case 3: return 'Refunded'
    default: return '—'
  }
}
const formatMoney = (cents) => {
  if (cents == null) return '—'
  return '$' + (Number(cents) / 100).toFixed(2)
}
const formatTime = (t) => {
  if (!t) return '—'
  try { return new Date(t).toLocaleString() } catch { return String(t) }
}

const handleSearch = () => {}
const handleNotification = () => { uni.navigateTo({ url: '/pages/notifications/index' }) }
const handleProfile = () => { uni.navigateTo({ url: '/pages/profile/index' }) }
const handleTabChange = (tab) => { activeTab.value = tab }

onShow(() => { fetchList(true) })
</script>

<style lang="scss" scoped>
@import '@/styles/_variables.scss';
@import '@/styles/_mixins.scss';

.layout-container {
  min-height: 100vh;
  background: $color-surface-subtle;
  padding-bottom: 96rpx;
}
.page-header { padding: $spacing-4 $spacing-4 $spacing-2; }
.page-title { @include text-headline; color: $color-text-primary; }
.page-subtitle { @include text-caption; color: $color-text-secondary; }

.filter-tabs { padding: 0 $spacing-4; }
.tabs-list { display: flex; gap: $spacing-2; }
.tab-item {
  padding: $spacing-2 $spacing-3;
  border-radius: 999rpx;
  background: $color-surface-raised;
  border: 1px solid $color-border-subtle;
}
.tab-active { background: $color-primary; border-color: $color-primary; }
.tab-text { @include text-caption; color: $color-text-secondary; }
.tab-active .tab-text { color: #fff; }

.filter-bar { display: flex; gap: $spacing-2; padding: $spacing-2 $spacing-4 $spacing-3; }
.search-input {
  flex: 1;
  background: $color-surface-raised;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-md;
  padding: $spacing-2 $spacing-3;
  @include text-body;
  color: $color-text-primary;
}

.scroll-area { height: calc(100vh - 320rpx); }
.order-list { padding: 0 $spacing-4; display: flex; flex-direction: column; gap: $spacing-3; }
.order-card { padding: $spacing-3; }
.card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: $spacing-2; }
.order-no { @include text-caption; color: $color-text-secondary; }
.order-body { display: flex; flex-direction: column; gap: $spacing-1; }
.info-row { display: flex; justify-content: space-between; }
.info-label { @include text-caption; color: $color-text-secondary; }
.info-value { @include text-body; color: $color-text-primary; }
.info-value--strong { font-weight: $font-weight-semibold; }

.detail-view { display: flex; flex-direction: column; }
.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;
  &:last-child { border-bottom: none; }
}
.detail-label { @include text-caption; color: $color-text-secondary; }
.detail-value { @include text-body; color: $color-text-primary; font-weight: $font-weight-medium; }
</style>
