<template>
  <view class="layout-container">
    <AppTopBar
      :user-name="userName"
      :profile-picture="profilePicture"
      :unread-count="unreadCount"
      @search="handleSearch"
      @notification="handleNotification"
    />

    <view class="page-header">
      <view class="header-main">
        <text class="page-title">Replenish</text>
        <text class="page-subtitle">Refill a machine &amp; create a supply work order</text>
      </view>
    </view>

    <view class="filter-bar">
      <input
        class="search-input"
        v-model="innerCode"
        placeholder="Enter machine code (e.g. VM000001)"
        confirm-type="search"
        @confirm="loadMachine"
      />
      <Button variant="primary" size="sm" @click="loadMachine">Load</Button>
    </view>

    <scroll-view scroll-y class="scroll-area">
      <view v-if="machine" class="content-wrapper">
        <Card class="machine-card">
          <view class="machine-head">
            <text class="machine-title">{{ machine.innerCode }}</text>
            <Badge variant="info">{{ machine.addr || 'No address' }}</Badge>
          </view>
          <view class="machine-meta">
            <text class="machine-meta-text">Last supply: {{ formatDate(machine.lastSupplyTime) }}</text>
            <text class="machine-meta-text">Slots: {{ channels.length }}</text>
          </view>
        </Card>

        <text class="section-title">Slots</text>
        <view class="slot-list">
          <view v-for="row in channels" :key="row.id" class="slot-row">
            <view class="slot-head">
              <text class="slot-code">{{ row.channelCode }}</text>
              <text class="slot-sku">{{ row.skuName || ('SKU ' + (row.skuId || '—')) }}</text>
            </view>
            <view class="slot-body">
              <text class="slot-cur">{{ row.currentCapacity || 0 }} / {{ row.maxCapacity || 0 }}</text>
              <view class="qty-control">
                <view class="qty-btn" @click="decQty(row)"><text class="qty-btn-text">−</text></view>
                <input
                  class="qty-input"
                  type="number"
                  :value="row.expectCapacity"
                  @input="onQtyInput(row, $event)"
                />
                <view class="qty-btn" @click="incQty(row)"><text class="qty-btn-text">+</text></view>
              </view>
            </view>
          </view>
        </view>

        <view class="submit-row">
          <Button variant="primary" :disabled="submitting" @click="submit">
            <text>Create Supply Task</text>
          </Button>
        </view>
      </view>
      <EmptyState
        v-else
        icon="package"
        text="Enter a machine code above to start replenishing"
      />
    </scroll-view>

    <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />
  </view>
</template>

<script setup>
import { ref } from 'vue'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Card from '@/components/ui/Card.vue'
import Badge from '@/components/ui/Badge.vue'
import Button from '@/components/ui/Button.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { listChannel } from '@/api/manage/channel'
import { listVm } from '@/api/manage/vm'
import { listSku } from '@/api/manage/sku'
import { addTask } from '@/api/manage/task'
import { getInfo } from '@/api/login'

const innerCode = ref('')
const machine = ref(null)
const channels = ref([])
const submitting = ref(false)
const activeTab = ref('manage')
const userName = ref('')
const profilePicture = ref('')
const unreadCount = ref(0)
const skuMap = ref({})

getInfo().then(res => {
  userName.value = res.user?.userName || ''
  profilePicture.value = res.user?.avatar || ''
}).catch(() => {})

const loadMachine = async () => {
  if (!innerCode.value) {
    uni.showToast({ title: 'Enter a machine code', icon: 'none' })
    return
  }
  try {
    uni.showLoading({ title: 'Loading' })
    const vmRes = await listVm({ innerCode: innerCode.value })
    const vm = (vmRes.rows || [])[0]
    if (!vm) {
      uni.hideLoading()
      uni.showToast({ title: 'Machine not found', icon: 'none' })
      machine.value = null
      channels.value = []
      return
    }
    machine.value = vm
    const chRes = await listChannel({ innerCode: vm.innerCode, pageSize: 200 })
    const rows = chRes.rows || []
    // load sku names once
    if (!Object.keys(skuMap.value).length) {
      try {
        const skuRes = await listSku({ pageSize: 200 })
        const arr = skuRes.rows || []
        skuMap.value = arr.reduce((acc, s) => { acc[s.skuId] = s; return acc }, {})
      } catch (e) { /* ignore */ }
    }
    channels.value = rows.map(r => ({
      ...r,
      skuName: skuMap.value[r.skuId]?.skuName,
      expectCapacity: Number(r.currentCapacity || 0)
    }))
    uni.hideLoading()
  } catch (e) {
    uni.hideLoading()
    uni.showToast({ title: 'Failed to load', icon: 'none' })
  }
}

const incQty = (row) => {
  const max = Number(row.maxCapacity || 0)
  if (row.expectCapacity < max) row.expectCapacity += 1
}
const decQty = (row) => {
  if (row.expectCapacity > 0) row.expectCapacity -= 1
}
const onQtyInput = (row, e) => {
  const raw = Number(e.detail.value || 0)
  const max = Number(row.maxCapacity || 0)
  row.expectCapacity = Math.max(0, Math.min(max, isNaN(raw) ? 0 : raw))
}

const submit = async () => {
  if (!machine.value) return
  const details = channels.value
    .filter(c => Number(c.expectCapacity) !== Number(c.currentCapacity || 0))
    .map(c => ({
      channelCode: c.channelCode,
      expectCapacity: Number(c.expectCapacity),
      skuId: c.skuId,
      skuName: skuMap.value[c.skuId]?.skuName,
      skuImage: skuMap.value[c.skuId]?.skuImage
    }))
  if (details.length === 0) {
    uni.showToast({ title: 'No quantity changes', icon: 'none' })
    return
  }
  submitting.value = true
  try {
    await addTask({
      innerCode: machine.value.innerCode,
      productTypeId: 2, // TASK_TYPE_SUPPLY
      createType: 1,
      desc: 'Mobile replenish',
      details
    })
    uni.showToast({ title: 'Supply task created', icon: 'success' })
    machine.value = null
    channels.value = []
    innerCode.value = ''
  } catch (e) {
    console.error(e)
  } finally {
    submitting.value = false
  }
}

const formatDate = (d) => {
  if (!d) return '—'
  try { return new Date(d).toLocaleDateString() } catch { return String(d) }
}

const handleSearch = () => {}
const handleNotification = () => { uni.navigateTo({ url: '/pages/notifications/index' }) }
const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId]) {
    uni.redirectTo({ url: routes[tabId] })
  }
}
</script>

<style lang="scss" scoped>
@import '@/styles/_variables.scss';
@import '@/styles/_mixins.scss';

.layout-container {
  min-height: 100vh;
  background: $color-surface-subtle;
  padding-bottom: 96rpx;
}

.page-header {
  padding: $spacing-4 $spacing-4 $spacing-2;
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}
.page-title { @include text-headline; color: $color-text-primary; }
.page-subtitle { @include text-caption; color: $color-text-secondary; }

.filter-bar {
  display: flex;
  gap: $spacing-2;
  padding: 0 $spacing-4 $spacing-3;
}
.search-input {
  flex: 1;
  background: $color-surface-raised;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-pill;
  padding: $spacing-2 $spacing-3;
  @include text-body;
  color: $color-text-primary;
}

.scroll-area { height: calc(100vh - 260rpx); }

.machine-card { padding: $spacing-3; }
.machine-head { display: flex; align-items: center; justify-content: space-between; }
.machine-title { @include text-title; color: $color-text-primary; }
.machine-meta { display: flex; gap: $spacing-4; margin-top: $spacing-2; }
.machine-meta-text { @include text-caption; color: $color-text-secondary; }


.slot-list {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  background: $color-surface-raised;
  border-radius: $radius-md;
  border: 1px solid $color-border-subtle;
  overflow: hidden;
}
.slot-row {
  padding: $spacing-3;
  border-bottom: 1px solid $color-border-subtle;
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  &:last-child { border-bottom: none; }
}
.slot-head { display: flex; justify-content: space-between; align-items: center; }
.slot-code { @include text-body; font-weight: $font-weight-medium; color: $color-text-primary; }
.slot-sku  { @include text-caption; color: $color-text-secondary; }
.slot-body { display: flex; justify-content: space-between; align-items: center; }
.slot-cur  { @include text-body; color: $color-text-secondary; }

.qty-control { display: flex; align-items: center; gap: $spacing-2; }
.qty-btn {
  width: 56rpx; height: 56rpx;
  display: flex; align-items: center; justify-content: center;
  border-radius: $radius-sm;
  background: $color-surface-subtle;
  border: 1px solid $color-border-subtle;
}
.qty-btn-text { @include text-title; color: $color-text-primary; }
.qty-input {
  width: 100rpx; height: 56rpx;
  text-align: center;
  background: $color-surface-subtle;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-pill;
  @include text-body;
  color: $color-text-primary;
}

.submit-row {
  padding: $spacing-4 0 $spacing-5;
  display: flex;
  justify-content: center;
}
</style>
