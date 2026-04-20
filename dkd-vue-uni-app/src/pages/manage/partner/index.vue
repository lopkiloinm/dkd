<template>
  <AppTopBar title="Partner Management" :showBack="true" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <view class="partner-list">
        <Card class="partner-card" v-for="item in partnerList" :key="item.id">
          <view class="partner-card-header">
            <text class="partner-name">{{ item.partnerName }}</text>
            <view class="node-count">
              <text class="count-number">{{ item.nodeCount || 0 }}</text> Nodes
            </view>
          </view>
          
          <view class="partner-info">
            <view class="info-row">
              <text class="info-label">Contact</text>
              <text class="info-value">{{ item.contactPerson || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Phone</text>
              <text class="info-value">{{ item.contactPhone || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Account</text>
              <text class="info-value">{{ item.account || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Profit Ratio</text>
              <text class="info-value">{{ item.profitRatio || 0 }}%</text>
            </view>
          </view>
        </Card>

        <EmptyState class="empty-state" v-if="partnerList.length === 0 && !loading">
          <text class="empty-text">No partners found</text>
        </EmptyState>
      </view>
    </view>
    </scroll-view>
    <AppBottomBar :active-tab="'machines'" @tab-change="handleTabChange" />
  </view>

  <BottomSheet :visible="showModal" @update:visible="val => !val && closeModal()" @close="closeModal" :title="isEdit ? 'Edit Partner' : 'Add Partner'">
      <Input v-model="form.partnerName" label="Partner Name *" placeholder="Enter partner name" />
      <Input v-model="form.contactPerson" label="Contact Person *" placeholder="Enter contact person" />
      <Input v-model="form.contactPhone" label="Contact Phone *" placeholder="Enter contact phone" />
      <Input v-model="form.profitRatio" label="Profit Ratio (%) *" type="number" placeholder="Enter profit ratio" />
      <Input v-if="!isEdit" v-model="form.account" label="Account *" placeholder="Enter account" />
      <Input v-if="!isEdit" v-model="form.password" label="Password *" type="password" placeholder="Enter password" />
      <template #header-actions>
        <view class="action-pill" @click="closeModal"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--primary" @click="submitForm"><text class="action-pill-text">{{ isSubmitting ? 'Saving...' : 'Save' }}</text></view>
      </template>
    </BottomSheet>

    <BottomSheet :visible="showDetailModal" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal" title="Partner Detail">
      <view class="detail-info-row">
        <text class="detail-label">Partner Name</text>
        <text class="detail-value">{{ detailData.partnerName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Contact Person</text>
        <text class="detail-value">{{ detailData.contactPerson }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Contact Phone</text>
        <text class="detail-value">{{ detailData.contactPhone }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Profit Ratio</text>
        <text class="detail-value">{{ detailData.profitRatio || 0 }}%</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Account</text>
        <text class="detail-value">{{ detailData.account }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Created</text>
        <text class="detail-value">{{ detailData.createTime }}</text>
      </view>
    </BottomSheet>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useI18n } from 'vue-i18n'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Card from '@/components/ui/Card.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import Input from '@/components/ui/Input.vue'
import Button from '@/components/ui/Button.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { listPartner, getPartner, addPartner, updatePartner, delPartner } from '@/api/manage/partner'
import { hasPermission } from '@/utils/permission'

const partnerList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  partnerName: ''
})
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  partnerName: '',
  contactPerson: '',
  contactPhone: '',
  profitRatio: '',
  account: '',
  password: ''
})

const showDetailModal = ref(false)
const detailData = ref({
  partnerName: '',
  contactPerson: '',
  contactPhone: '',
  profitRatio: '',
  account: '',
  createTime: ''
})

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    partnerList.value = []
  }
  try {
    loading.value = true
    const res = await listPartner(queryParams.value)
    if (res.rows) {
      partnerList.value = [...partnerList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load data', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

onShow(() => {
  fetchList(true)
})

const handleSearch = () => {
  fetchList(true)
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { id: null, partnerName: '', contactPerson: '', contactPhone: '', profitRatio: '', account: '', password: '' }
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getPartner(item.id)
    detailData.value = {
      partnerName: res.data.partnerName,
      contactPerson: res.data.contactPerson,
      contactPhone: res.data.contactPhone,
      profitRatio: res.data.profitRatio,
      account: res.data.account,
      createTime: res.data.createTime
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load partner detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { partnerName: '', contactPerson: '', contactPhone: '', profitRatio: '', account: '', createTime: '' }
}

const handleResetPwd = (item) => {
  uni.showModal({
    title: 'Confirm Reset',
    content: `Are you sure you want to reset the password for ${item.partnerName}?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await resetPartnerPwd(item.id)
          uni.showToast({ title: 'Password reset successfully', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: 'Failed to reset password', icon: 'none' })
        }
      }
    }
  })
}

const handleEdit = async (item) => {
  try {
    const res = await getPartner(item.id)
    form.value = res.data
    isEdit.value = true
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load partner data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.partnerName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delPartner(item.id)
          uni.showToast({ title: 'Deleted successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to delete', icon: 'none' })
        }
      }
    }
  })
}

const closeModal = () => {
  showModal.value = false
  form.value = { id: null, partnerName: '', contactPerson: '', contactPhone: '', profitRatio: '', account: '', password: '' }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.partnerName) {
    uni.showToast({ title: 'Partner Name is required', icon: 'none' })
    return
  }
  if (!form.value.contactPerson) {
    uni.showToast({ title: 'Contact Person is required', icon: 'none' })
    return
  }
  if (!form.value.contactPhone) {
    uni.showToast({ title: 'Contact Phone is required', icon: 'none' })
    return
  }
  if (!form.value.profitRatio) {
    uni.showToast({ title: 'Profit Ratio is required', icon: 'none' })
    return
  }
  if (!isEdit.value && !form.value.account) {
    uni.showToast({ title: 'Account is required', icon: 'none' })
    return
  }
  if (!isEdit.value && !form.value.password) {
    uni.showToast({ title: 'Password is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updatePartner(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addPartner(form.value)
      uni.showToast({ title: 'Added successfully', icon: 'success' })
    }
    closeModal()
    fetchList(true)
  } catch (error) {
    uni.showToast({ title: isEdit.value ? 'Failed to update' : 'Failed to add', icon: 'none' })
  } finally {
    isSubmitting.value = false
  }
}

const loadMore = () => {
  if (partnerList.value.length < total.value) {
    queryParams.value.pageNum++
    fetchList()
  }
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
}

const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId]) {
    uni.navigateTo({ url: routes[tabId] })
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.action-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-1 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-full;

  &:active { opacity: 0.7; }
  &--primary { background: $color-primary; }
}

.action-pill-text {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;

  .action-pill--primary & { color: #fff; }
}

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $color-bg-primary;
  padding-top: $top-bar-total-height;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}


.partner-list {
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.n-input {
  height: 44px;
  line-height: 44px;
  padding: 0 $spacing-4;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  color: $color-text-primary;
  background: $color-bg-secondary;
  border-radius: $radius-pill;
}

.n-input::placeholder {
  color: $color-text-secondary;
}

.partner-card {
  padding: $spacing-4;
  transition: transform $transition-normal;
}

.partner-card:active {
  transform: scale(0.98);
  background-color: $color-bg-elevated;
}

.partner-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-4;
  padding-bottom: $spacing-3;
}

.partner-name {
  font-size: 18px;
  font-weight: $font-weight-bold;
  color: $color-text-primary;
  letter-spacing: -0.5px;
}

.node-count {
  font-size: 13px;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.count-number {
  font-size: 16px;
  font-weight: $font-weight-bold;
  color: $color-primary;
  margin-right: 2px;
}

.partner-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.info-row {
  display: flex;
  justify-content: space-between;
}

.info-label {
  font-size: 14px;
  color: $color-text-secondary;
}

.info-value {
  font-size: 14px;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
  text-align: right;
  max-width: 60%;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.detail-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;

  &:first-child { padding-top: 0; }
  &:last-child { border-bottom: none; }
}

.detail-label {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.detail-value {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}
</style>
