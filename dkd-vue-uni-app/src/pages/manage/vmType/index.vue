<template>
  <AppTopBar title="VM Type Management" :showBack="true" />
  <view class="layout-container layout-container--bottom-tabs">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <view class="vmtype-list">
        <view class="vmtype-card" v-for="item in vmTypeList" :key="item.id" @click="handleViewDetail(item)">
          <view class="vmtype-card-header">
              <view class="vmtype-image">
                <image v-if="item.image" :src="item.image" class="type-image" mode="aspectFill" />
                <view v-else class="image-placeholder">
                  <text class="placeholder-text">No Image</text>
                </view>
              </view>
              <view class="vmtype-info-header">
                <text class="vmtype-name">{{ item.name }}</text>
                <text class="vmtype-model">{{ item.model || 'N/A' }}</text>
              </view>
            </view>
            
            <view class="vmtype-info">
              <view class="info-row">
                <text class="info-label">Rows</text>
                <text class="info-value">{{ item.vmRow || 0 }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Columns</text>
                <text class="info-value">{{ item.vmCol || 0 }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Capacity</text>
                <text class="info-value">{{ item.channelMaxCapacity || 0 }}</text>
              </view>
            </view>
        </view>

        <EmptyState v-if="vmTypeList.length === 0 && !loading" message="No VM types found" />
      </view>
    </view>
    </scroll-view>
    <view class="fab" @click="handleAdd">+</view>
    <AppBottomBar :active-tab="'machines'" @tab-change="handleTabChange" />
  </view>

  <BottomSheet :visible="showDetailModal" title="VM Type Detail" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal">
        <view class="detail-image-section">
          <view class="detail-image-container">
            <image v-if="detailData.image" :src="detailData.image" class="detail-type-image" mode="aspectFill" />
            <view v-else class="detail-image-placeholder">
              <text class="detail-placeholder-text">No Image</text>
            </view>
          </view>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Type Name</text>
          <text class="detail-value">{{ detailData.name }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Model</text>
          <text class="detail-value">{{ detailData.model }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Rows</text>
          <text class="detail-value">{{ detailData.vmRow }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Columns</text>
          <text class="detail-value">{{ detailData.vmCol }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Capacity</text>
          <text class="detail-value">{{ detailData.channelMaxCapacity }}</text>
        </view>
      </BottomSheet>

      <BottomSheet :visible="showModal" :title="isEdit ? 'Edit VM Type' : 'Add VM Type'" @update:visible="val => !val && closeModal()" @close="closeModal">
        <Input v-model="form.name" label="Type Name *" placeholder="Enter type name" />
        <Input v-model="form.model" label="Model *" placeholder="Enter model" />
        <Input v-model="form.vmRow" label="Rows *" type="number" placeholder="Enter rows (1-10)" />
        <Input v-model="form.vmCol" label="Columns *" type="number" placeholder="Enter columns (1-10)" />
        <Input v-model="form.channelMaxCapacity" label="Capacity *" type="number" placeholder="Enter capacity" />
        <view class="form-item">
          <text class="form-label">Image *</text>
          <view class="image-upload-container">
            <image v-if="form.image" :src="form.image" class="preview-image" mode="aspectFill" @click="removeImage" />
            <view v-else class="upload-placeholder" @click="chooseImage">
              <text class="upload-icon">+</text>
              <text class="upload-text">Tap to upload</text>
            </view>
          </view>
        </view>
        <template #header-actions>
          <view class="action-pill" @click="closeModal"><text class="action-pill-text">Cancel</text></view>
          <view class="action-pill action-pill--primary" @click="submitForm"><text class="action-pill-text">{{ isSubmitting ? 'Saving...' : 'Save' }}</text></view>
        </template>
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
import { listVmType, getVmType, addVmType, updateVmType, delVmType } from '@/api/manage/vmType'
import { hasPermission } from '@/utils/permission'
const vmTypeList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  name: '',
  model: '',
  image: '',
  vmRow: '',
  vmCol: '',
  channelMaxCapacity: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  name: '',
  model: ''
})
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  name: '',
  model: '',
  vmRow: '',
  vmCol: '',
  channelMaxCapacity: '',
  image: ''
})

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    vmTypeList.value = []
  }
  try {
    loading.value = true
    const res = await listVmType(queryParams.value)
    if (res.rows) {
      vmTypeList.value = [...vmTypeList.value, ...res.rows]
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
  form.value = { id: null, name: '', model: '', vmRow: '', vmCol: '', channelMaxCapacity: '', image: '' }
  showModal.value = true
}

const handleEdit = async (item) => {
  try {
    const res = await getVmType(item.id)
    form.value = res.data
    isEdit.value = true
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load VM type data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.name}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delVmType(item.id)
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
  form.value = { id: null, name: '', model: '', vmRow: '', vmCol: '', channelMaxCapacity: '', image: '' }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.name) {
    uni.showToast({ title: 'Type Name is required', icon: 'none' })
    return
  }
  if (!form.value.model) {
    uni.showToast({ title: 'Model is required', icon: 'none' })
    return
  }
  if (!form.value.vmRow) {
    uni.showToast({ title: 'Rows is required', icon: 'none' })
    return
  }
  if (!form.value.vmCol) {
    uni.showToast({ title: 'Columns is required', icon: 'none' })
    return
  }
  if (!form.value.channelMaxCapacity) {
    uni.showToast({ title: 'Capacity is required', icon: 'none' })
    return
  }
  if (!form.value.image) {
    uni.showToast({ title: 'Image is required', icon: 'none' })
    return
  }

  // Validate number constraints
  const vmRow = parseInt(form.value.vmRow)
  const vmCol = parseInt(form.value.vmCol)
  const capacity = parseInt(form.value.channelMaxCapacity)
  
  if (vmRow < 1 || vmRow > 10) {
    uni.showToast({ title: 'Rows must be between 1 and 10', icon: 'none' })
    return
  }
  if (vmCol < 1 || vmCol > 10) {
    uni.showToast({ title: 'Columns must be between 1 and 10', icon: 'none' })
    return
  }
  if (capacity < 1 || capacity > 10) {
    uni.showToast({ title: 'Capacity must be between 1 and 10', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateVmType(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addVmType(form.value)
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

const chooseImage = () => {
  uni.chooseImage({
    count: 1,
    sizeType: ['compressed'],
    sourceType: ['album', 'camera'],
    success: (res) => {
      const tempFilePath = res.tempFilePaths[0]
      uni.uploadFile({
        url: '/common/upload',
        filePath: tempFilePath,
        name: 'file',
        success: (uploadRes) => {
          const data = JSON.parse(uploadRes.data)
          if (data.url) {
            form.value.image = data.url
          }
        },
        fail: () => {
          uni.showToast({ title: 'Upload failed', icon: 'none' })
        }
      })
    }
  })
}

const removeImage = () => {
  uni.showModal({
    title: 'Remove Image',
    content: 'Are you sure you want to remove this image?',
    success: (res) => {
      if (res.confirm) {
        form.value.image = ''
      }
    }
  })
}

const loadMore = () => {
  if (vmTypeList.value.length < total.value) {
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

const handleViewDetail = async (item) => {
  try {
    const res = await getVmType(item.id)
    detailData.value = {
      name: res.data.name,
      model: res.data.model,
      image: res.data.image,
      vmRow: res.data.vmRow,
      vmCol: res.data.vmCol,
      channelMaxCapacity: res.data.channelMaxCapacity
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load VM type detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { name: '', model: '', image: '', vmRow: '', vmCol: '', channelMaxCapacity: '' }
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

.vmtype-list {
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.vmtype-card {
  padding: $spacing-4;
  transition: transform $transition-normal;
}

.vmtype-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.vmtype-card-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.vmtype-image {
  width: 64px;
  height: 64px;
  border-radius: $radius-md;
  margin-right: $spacing-4;
  flex-shrink: 0;
  overflow: hidden;
  background: $color-bg-elevated;
  border: 1px solid $color-border-subtle;
}

.type-image {
  width: 100%;
  height: 100%;
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.placeholder-text {
  font-size: 11px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.vmtype-info-header {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.vmtype-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.vmtype-model {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.vmtype-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.info-row {
  display: flex;
  justify-content: space-between;
}

.info-label {
  font-size: 14px;
  color: $apple-text-secondary;
}

.info-value {
  font-size: 14px;
  color: $apple-text-primary;
  font-weight: 500;
  text-align: right;
}

.empty-state {
  padding: 40px 0;
  text-align: center;
}

.empty-text {
  color: $apple-text-secondary;
  font-size: 15px;
}

.card-actions {
  display: flex;
  gap: $spacing-4;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid $apple-glass-border;
}

.action-btn {
  flex: 1;
  padding: 10px 16px;
  border-radius: 8px;
  background-color: rgba(0, 122, 255, 0.1);
  text-align: center;
  transition: background-color 0.2s;
}

.action-btn:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.action-btn.delete {
  background-color: rgba(255, 59, 48, 0.1);
}

.action-btn.delete:active {
  background-color: rgba(255, 59, 48, 0.2);
}

.action-text {
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.action-btn.delete .action-text {
  color: #ff3b30;
}

.image-upload-container {
  width: 100%;
  height: 120px;
  border: 2px dashed $color-border-subtle;
  border-radius: $radius-sm;
  background: $color-bg-tertiary;
  overflow: hidden;
}

.preview-image { width: 100%; height: 100%; object-fit: cover; }

.upload-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: $spacing-2;
}

.upload-icon { font-size: 32px; color: $color-text-tertiary; font-weight: 300; }
.upload-text { @include text-caption; color: $color-text-secondary; }

.form-item { margin-bottom: $spacing-4; &:last-child { margin-bottom: 0; } }

.detail-image-section {
  display: flex;
  justify-content: center;
  margin-bottom: $spacing-4;
}

.detail-image-container {
  width: 120px;
  height: 120px;
  border-radius: $radius-sm;
  overflow: hidden;
  background: $color-bg-tertiary;
}

.detail-type-image { width: 100%; height: 100%; }

.detail-image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.detail-placeholder-text { @include text-caption; color: $color-text-tertiary; }

.detail-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;

  &:first-child { padding-top: 0; }
  &:last-child { border-bottom: none; }
}

.fab {
  position: fixed;
  right: $spacing-4;
  bottom: calc(#{$bottom-bar-total-height} + #{$spacing-4});
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: $color-primary;
  color: white;
  font-size: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(61, 139, 255, 0.4);
  z-index: 100;
}
</style>
