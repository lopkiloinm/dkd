<template>
  <AppTopBar title="Region Management" :showBack="true" />
  <view class="layout-container layout-container--bottom-tabs">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <view class="region-list">
        <Card class="region-card" v-for="item in regionList" :key="item.id">
          <view class="region-card-header">
            <text class="region-name">{{ item.regionName }}</text>
            <view class="node-count">
              <text class="count-number">{{ item.nodeCount || 0 }}</text> Nodes
            </view>
          </view>
          
          <view class="region-info">
            <view class="info-row">
              <text class="info-label">Remark</text>
              <text class="info-value">{{ item.remark || 'N/A' }}</text>
            </view>
          </view>
        </Card>

        <EmptyState class="empty-state" v-if="regionList.length === 0 && !loading">
          <text class="empty-text">No regions found</text>
        </EmptyState>
      </view>
    </view>
    </scroll-view>
    <AppBottomBar :active-tab="'machines'" @tab-change="handleTabChange" />
  </view>

  <BottomSheet :visible="showModal" @update:visible="val => !val && closeModal()" @close="closeModal" :title="isEdit ? 'Edit Region' : 'Add Region'">
      <Input v-model="form.regionName" label="Region Name *" placeholder="Enter region name" />
      <view class="form-item">
        <text class="form-label">Remark *</text>
        <SheetTextField v-model="form.remark" placeholder="Enter remark" multiline />
      </view>
      <template #header-actions>
        <view class="action-pill" @click="closeModal"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--primary" @click="submitForm"><text class="action-pill-text">{{ isSubmitting ? 'Saving...' : 'Save' }}</text></view>
      </template>
    </BottomSheet>

    <BottomSheet :visible="showDetailModal" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal" title="Region Detail">
      <view class="detail-info-row">
        <text class="detail-label">Region Name</text>
        <text class="detail-value">{{ detailData.regionName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Remark</text>
        <text class="detail-value">{{ detailData.remark || 'N/A' }}</text>
      </view>
      <view class="section-title">Nodes in this region</view>
      <view class="node-list-detail">
        <view class="node-item" v-for="node in detailData.nodeList" :key="node.id">
          <text class="node-name">{{ node.nodeName }}</text>
          <text class="node-vm-count">{{ node.vmCount || 0 }} VMs</text>
        </view>
        <EmptyState class="empty-nodes" v-if="detailData.nodeList.length === 0">
          <text class="empty-text">No nodes in this region</text>
        </EmptyState>
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
import { listRegion, getRegion, addRegion, updateRegion, delRegion } from '@/api/manage/region'
import { listNode } from '@/api/manage/node'
import { hasPermission } from '@/utils/permission'
import SheetTextField from '@/components/ui/SheetTextField.vue'
const regionList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  regionName: ''
})
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  regionName: '',
  remark: ''
})

const showDetailModal = ref(false)
const detailData = ref({
  regionName: '',
  nodeList: []
})

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    regionList.value = []
  }
  try {
    loading.value = true
    const res = await listRegion(queryParams.value)
    if (res.rows) {
      regionList.value = [...regionList.value, ...res.rows]
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
  form.value = { id: null, regionName: '', remark: '' }
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    detailData.value.regionName = item.regionName
    const res = await listNode({ regionId: item.id, pageNum: 1, pageSize: 100 })
    detailData.value.nodeList = res.rows || []
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load region detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { regionName: '', nodeList: [] }
}

const handleEdit = async (item) => {
  try {
    const res = await getRegion(item.id)
    form.value = res.data
    isEdit.value = true
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load region data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.regionName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delRegion(item.id)
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
  form.value = { id: null, regionName: '', remark: '' }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.regionName) {
    uni.showToast({ title: 'Region Name is required', icon: 'none' })
    return
  }
  if (!form.value.remark) {
    uni.showToast({ title: 'Remark is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateRegion(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addRegion(form.value)
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
  if (regionList.value.length < total.value) {
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
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.content-wrapper {
  padding-left: $spacing-4;
  padding-right: $spacing-4;
  box-sizing: border-box;
}

.region-list {
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.region-card {
  padding: $spacing-4;
  transition: transform $transition-normal;
}

.region-card:active {
  transform: scale(0.98);
  background-color: $color-bg-elevated;
}

.region-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-4;
  padding-bottom: $spacing-3;
}

.region-name {
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

.region-info {
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
  font-weight: $font-weight-medium;
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

.empty-state {
  padding: 40px 0;
  text-align: center;
}

.empty-text {
  color: $color-text-secondary;
  font-size: 15px;
}

.card-actions {
  display: flex;
  gap: $spacing-2;
  margin-top: $spacing-4;
  padding-top: $spacing-3;
}

.form-item {
  margin-bottom: $spacing-4;
}

.form-item:last-child {
  margin-bottom: 0;
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

.node-list-detail {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  max-height: 200px;
  overflow-y: auto;
}

.node-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-secondary;
  border-radius: $radius-md;
}

.node-name {
  font-size: 14px;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.node-vm-count {
  font-size: 13px;
  color: $color-text-secondary;
}

.empty-nodes {
  padding: 40px 0;
  text-align: center;
}

.empty-nodes .empty-text {
  color: $apple-text-secondary;
  font-size: 14px;
}
</style>
