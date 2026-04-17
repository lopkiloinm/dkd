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
        <text class="page-title">Channels</text>
        <text class="page-subtitle">Manage vending machine slots</text>
      </view>
      <Button variant="primary" size="sm" @click="handleAdd">
        <Icon name="plus" size="sm" />
        <text>Add</text>
      </Button>
    </view>

    <view class="filter-bar">
      <input
        class="search-input"
        v-model="queryParams.innerCode"
        placeholder="Filter by machine code"
        confirm-type="search"
        @confirm="fetchList(true)"
      />
      <Button variant="ghost" size="sm" @click="fetchList(true)">Search</Button>
    </view>

    <scroll-view
      scroll-y
      class="scroll-area"
      refresher-enabled
      :refresher-triggered="isRefreshing"
      @refresherrefresh="onRefresh"
      @scrolltolower="loadMore"
    >
      <view class="channel-list" v-if="channelList.length > 0">
        <view
          class="channel-card"
          v-for="item in channelList"
          :key="item.id"
          @click="handleView(item)"
        >
          <view class="channel-header">
            <view class="channel-code">
              <text class="channel-label">Slot</text>
              <text class="channel-value">{{ item.channelCode }}</text>
            </view>
            <Badge :variant="getCapacityVariant(item)">{{ getCapacityText(item) }}</Badge>
          </view>
          <view class="channel-body">
            <view class="channel-row">
              <text class="row-label">Machine</text>
              <text class="row-value">{{ item.innerCode || '—' }}</text>
            </view>
            <view class="channel-row">
              <text class="row-label">SKU ID</text>
              <text class="row-value">{{ item.skuId || 'Empty' }}</text>
            </view>
            <view class="channel-row">
              <text class="row-label">Stock</text>
              <text class="row-value">{{ item.currentCapacity || 0 }} / {{ item.maxCapacity || 0 }}</text>
            </view>
          </view>
        </view>
      </view>
      <EmptyState v-else-if="!loading" icon="package" text="No channels found" />
    </scroll-view>

    <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />

    <BottomSheet
      :visible="showDetail"
      :title="deleteConfirmMode ? 'Delete Channel?' : (formMode === 'detail' ? 'Channel Details' : (formData.id ? 'Edit Channel' : 'New Channel'))"
      @update:visible="val => !val && closeDetail()"
      @close="closeDetail"
    >
      <template #header-actions>
        <template v-if="deleteConfirmMode">
          <view class="action-pill" @click="cancelDeleteConfirm"><text class="action-pill-text">Cancel</text></view>
          <view class="action-pill action-pill--danger" @click="executeDelete"><text class="action-pill-text">Delete</text></view>
        </template>
        <template v-else-if="formMode === 'detail'">
          <view class="action-pill" @click="confirmDelete"><text class="action-pill-text">Delete</text></view>
          <view class="action-pill action-pill--primary" @click="startEdit"><text class="action-pill-text">Edit</text></view>
        </template>
        <template v-else>
          <view class="action-pill" @click="closeDetail"><text class="action-pill-text">Cancel</text></view>
          <view class="action-pill action-pill--primary" @click="saveChannel"><text class="action-pill-text">Save</text></view>
        </template>
      </template>
      <view v-if="deleteConfirmMode" class="delete-confirm">
        <text class="delete-confirm-message">Are you sure you want to delete slot "{{ detailData.channelCode }}"? This action cannot be undone.</text>
      </view>
      <view v-else-if="formMode === 'detail'" class="detail-view">
        <view class="detail-row">
          <text class="detail-label">Slot Code</text>
          <text class="detail-value">{{ detailData.channelCode }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">Machine</text>
          <text class="detail-value">{{ detailData.innerCode }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">SKU ID</text>
          <text class="detail-value">{{ detailData.skuId || 'Empty' }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">Current Stock</text>
          <text class="detail-value">{{ detailData.currentCapacity || 0 }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">Max Capacity</text>
          <text class="detail-value">{{ detailData.maxCapacity || 0 }}</text>
        </view>
        <view class="detail-row">
          <text class="detail-label">Last Supply</text>
          <text class="detail-value">{{ formatDate(detailData.lastSupplyTime) }}</text>
        </view>
      </view>
      <view v-else class="form-view">
        <view class="form-group">
          <text class="form-label">Slot Code *</text>
          <input class="form-input" v-model="formData.channelCode" placeholder="e.g. 1-1" />
        </view>
        <view class="form-group">
          <text class="form-label">Machine Code *</text>
          <input class="form-input" v-model="formData.innerCode" placeholder="Machine inner code" />
        </view>
        <view class="form-group">
          <text class="form-label">SKU</text>
          <picker mode="selector" :range="skuOptions" range-key="label" :value="skuIndex" @change="onSkuChange">
            <view class="form-picker">{{ skuOptions[skuIndex]?.label || 'Select SKU' }}</view>
          </picker>
        </view>
        <view class="form-group">
          <text class="form-label">Max Capacity</text>
          <input class="form-input" type="number" v-model="formData.maxCapacity" placeholder="0" />
        </view>
        <view class="form-group">
          <text class="form-label">Current Stock</text>
          <input class="form-input" type="number" v-model="formData.currentCapacity" placeholder="0" />
        </view>
      </view>

    </BottomSheet>
  </view>
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Badge from '@/components/ui/Badge.vue'
import Button from '@/components/ui/Button.vue'
import Icon from '@/components/ui/Icon.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listChannel, addChannel, updateChannel, delChannel, getChannel } from '@/api/manage/channel'
import { listSku } from '@/api/manage/sku'
import { getInfo } from '@/api/login'
import useUserStore from '@/store/modules/user'

const userStore = useUserStore()
const userName = computed(() => userStore.name)
const profilePicture = computed(() => userStore.avatar || '')
const unreadCount = ref(0)
const activeTab = ref('machines')

const channelList = ref([])
const total = ref(0)
const loading = ref(false)
const isRefreshing = ref(false)
const queryParams = ref({ pageNum: 1, pageSize: 20, innerCode: '' })

const showDetail = ref(false)
const formMode = ref('detail')
const detailData = ref({})
const formData = ref({})
const skuOptions = ref([{ label: 'None', value: null }])
const skuIndex = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    channelList.value = []
  }
  loading.value = true
  try {
    const res = await listChannel(queryParams.value)
    if (reset) {
      channelList.value = res.rows || []
    } else {
      channelList.value = [...channelList.value, ...(res.rows || [])]
    }
    total.value = res.total || 0
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const fetchSkus = async () => {
  try {
    const res = await listSku({ pageNum: 1, pageSize: 100 })
    skuOptions.value = [{ label: 'None', value: null }, ...(res.rows || []).map(s => ({ label: s.skuName, value: s.skuId }))]
  } catch (e) { console.error(e) }
}

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
  } catch (e) { console.error(e) }
}

const loadMore = () => {
  if (channelList.value.length < total.value) {
    queryParams.value.pageNum++
    fetchList()
  }
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
}

const getCapacityVariant = (item) => {
  const cur = item.currentCapacity || 0
  const max = item.maxCapacity || 0
  if (max === 0) return 'default'
  const pct = cur / max
  if (pct === 0) return 'error'
  if (pct < 0.3) return 'warning'
  return 'success'
}

const getCapacityText = (item) => {
  const cur = item.currentCapacity || 0
  const max = item.maxCapacity || 0
  if (max === 0) return 'Unset'
  if (cur === 0) return 'Empty'
  if (cur / max < 0.3) return 'Low'
  return 'OK'
}

const formatDate = (d) => {
  if (!d) return 'Never'
  return new Date(d).toLocaleString()
}

const handleView = async (item) => {
  try {
    const res = await getChannel(item.id)
    detailData.value = res.data || item
  } catch (e) {
    detailData.value = item
  }
  formMode.value = 'detail'
  showDetail.value = true
}

const handleAdd = () => {
  formData.value = {
    channelCode: '',
    innerCode: '',
    skuId: null,
    maxCapacity: 0,
    currentCapacity: 0
  }
  skuIndex.value = 0
  formMode.value = 'create'
  showDetail.value = true
}

const startEdit = () => {
  formData.value = { ...detailData.value }
  const idx = skuOptions.value.findIndex(s => s.value === formData.value.skuId)
  skuIndex.value = idx >= 0 ? idx : 0
  formMode.value = 'edit'
}

const closeDetail = () => {
  showDetail.value = false
  deleteConfirmMode.value = false
}

const onSkuChange = (e) => {
  skuIndex.value = e.detail.value
  formData.value.skuId = skuOptions.value[e.detail.value]?.value
}

const saveChannel = async () => {
  if (!formData.value.channelCode || !formData.value.innerCode) {
    uni.showToast({ title: 'Slot & machine code required', icon: 'none' })
    return
  }
  try {
    if (formData.value.id) {
      await updateChannel(formData.value)
      uni.showToast({ title: 'Channel updated', icon: 'success' })
    } else {
      await addChannel(formData.value)
      uni.showToast({ title: 'Channel created', icon: 'success' })
    }
    closeDetail()
    fetchList(true)
  } catch (e) { console.error(e) }
}

const deleteConfirmMode = ref(false)

const confirmDelete = () => {
  deleteConfirmMode.value = true
}

const cancelDeleteConfirm = () => {
  deleteConfirmMode.value = false
}

const executeDelete = async () => {
  await delChannel(detailData.value.id)
  uni.showToast({ title: 'Deleted', icon: 'success' })
  deleteConfirmMode.value = false
  closeDetail()
  fetchList(true)
}

const handleSearch = () => {}
const handleNotification = () => uni.navigateTo({ url: '/pages/notifications/index' })
const handleProfile = () => uni.navigateTo({ url: '/pages/mine/index' })

const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId]) uni.navigateTo({ url: routes[tabId] })
}

onShow(() => {
  fetchUserInfo()
  fetchSkus()
  fetchList(true)
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $color-bg-primary;
  padding-top: $top-bar-total-height;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  padding: $spacing-4;
}

.page-title {
  @include text-h2;
  color: $color-text-primary;
  display: block;
}

.page-subtitle {
  @include text-caption;
  color: $color-text-secondary;
  display: block;
  margin-top: $spacing-1;
}

.filter-bar {
  display: flex;
  gap: $spacing-2;
  padding: 0 $spacing-4 $spacing-3;
}

.search-input {
  flex: 1;
  @include text-body;
  color: $color-text-primary;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-sm;
}

.scroll-area {
  flex: 1;
  padding: 0 $spacing-4 $spacing-6;
}

.channel-list {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.channel-card {
  background: $color-bg-secondary;
  border-radius: $radius-md;
  padding: $spacing-4;
  border: 1px solid $color-border-subtle;
}

.channel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-3;
}

.channel-code { display: flex; flex-direction: column; gap: 2px; }
.channel-label { @include text-label; color: $color-text-tertiary; }
.channel-value { @include text-body; color: $color-text-primary; font-weight: $font-weight-semibold; }

.channel-body { display: flex; flex-direction: column; gap: $spacing-2; }
.channel-row { display: flex; justify-content: space-between; }
.row-label { @include text-caption; color: $color-text-secondary; }
.row-value { @include text-caption; color: $color-text-primary; }

.detail-view { display: flex; flex-direction: column; }

.action-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-1 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  cursor: pointer;

  &:active { opacity: 0.7; }
  &--primary { background: $color-primary; }
  &--danger { background: $color-error; }
}

.action-pill-text {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;

  .action-pill--primary & { color: #fff; }
  .action-pill--danger & { color: #fff; }
}

.delete-confirm {
  padding: $spacing-4 0;
}

.delete-confirm-message {
  @include text-body;
  color: $color-text-secondary;
  line-height: 1.5;
}

.detail-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: $spacing-3 0; border-bottom: 1px solid $color-border-subtle;

  &:first-child { padding-top: 0; }
  &:last-child { border-bottom: none; }
}
.detail-label { @include text-caption; color: $color-text-secondary; }
.detail-value { @include text-body; color: $color-text-primary; font-weight: $font-weight-medium; }

.form-view { display: flex; flex-direction: column; gap: $spacing-4; }
.form-group { display: flex; flex-direction: column; gap: $spacing-2; }
.form-label { @include text-caption; color: $color-text-secondary; font-weight: $font-weight-medium; }

.form-input {
  @include text-body; color: $color-text-primary; padding: $spacing-3;
  background: $color-bg-tertiary; border: 1px solid $color-border-subtle;
  border-radius: $radius-sm; width: 100%; box-sizing: border-box;
}

.form-picker {
  @include text-body; color: $color-text-primary; padding: $spacing-3;
  background: $color-bg-tertiary; border: 1px solid $color-border-subtle;
  border-radius: $radius-sm;
}
</style>
