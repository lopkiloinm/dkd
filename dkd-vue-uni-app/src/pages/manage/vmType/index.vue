<template>
  <TopBar title="Device Type Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.name" placeholder="Search by Name" @confirm="handleSearch" />
      <input class="n-input search-input" v-model="queryParams.model" placeholder="Search by Model" @confirm="handleSearch" />
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
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

          <view class="card-actions">
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('manage:vmType:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('manage:vmType:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="vmTypeList.length === 0 && !loading">
          <text class="empty-text">No VM types found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">VM Type Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-image-section">
            <view class="detail-image-container">
              <image v-if="detailData.image" :src="detailData.image" class="detail-type-image" mode="aspectFill" />
              <view v-else class="detail-image-placeholder">
                <text class="detail-placeholder-text">No Image</text>
              </view>
            </view>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Type Name:</text>
            <text class="detail-value">{{ detailData.name }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Model:</text>
            <text class="detail-value">{{ detailData.model }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Rows:</text>
            <text class="detail-value">{{ detailData.vmRow }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Columns:</text>
            <text class="detail-value">{{ detailData.vmCol }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Capacity:</text>
            <text class="detail-value">{{ detailData.channelMaxCapacity }}</text>
          </view>
        </view>
        <view class="modal-footer">
          <view class="modal-btn cancel" @click="closeDetailModal">
            <text>Close</text>
          </view>
        </view>
      </view>
    </view>

    <view class="modal-overlay" v-if="showModal" @click="closeModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">{{ isEdit ? 'Edit VM Type' : 'Add VM Type' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">Type Name *</text>
            <input class="modal-input" v-model="form.name" placeholder="Enter type name" />
          </view>
          <view class="form-item">
            <text class="form-label">Model *</text>
            <input class="modal-input" v-model="form.model" placeholder="Enter model" />
          </view>
          <view class="form-item">
            <text class="form-label">Rows *</text>
            <input class="modal-input" v-model="form.vmRow" type="number" placeholder="Enter rows (1-10)" />
          </view>
          <view class="form-item">
            <text class="form-label">Columns *</text>
            <input class="modal-input" v-model="form.vmCol" type="number" placeholder="Enter columns (1-10)" />
          </view>
          <view class="form-item">
            <text class="form-label">Capacity *</text>
            <input class="modal-input" v-model="form.channelMaxCapacity" type="number" placeholder="Enter capacity" />
          </view>
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
        </view>
        <view class="modal-footer">
          <view class="modal-btn cancel" @click="closeModal">
            <text>Cancel</text>
          </view>
          <view class="modal-btn confirm" :class="{ disabled: isSubmitting }" @click="submitForm">
            <text>{{ isSubmitting ? 'Submitting...' : 'Confirm' }}</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
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
@import "@/styles/apple.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  box-sizing: border-box;
  padding: 60px 0 16px 0;
}

.search-bar {
  padding: 16px;
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.n-input {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.vmtype-list {
  padding: 0 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.vmtype-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
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
  border-radius: 12px;
  margin-right: 16px;
  flex-shrink: 0;
  overflow: hidden;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
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
  gap: 12px;
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

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(10px);
}

.modal-input {
  width: 100%;
  height: 44px;
  padding: 0 16px;
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: $apple-radius-sm;
  font-size: 16px;
  color: $apple-text-primary;
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  box-sizing: border-box;
}

.image-upload-container {
  width: 100%;
  height: 120px;
  border: 2px dashed rgba(0, 0, 0, 0.15);
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  overflow: hidden;
}

.preview-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.upload-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.upload-icon {
  font-size: 32px;
  color: $apple-text-secondary;
  font-weight: 300;
}

.upload-text {
  font-size: 12px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.modal-content {
  background-color: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  width: 90%;
  max-width: 400px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid $apple-glass-border;
}

.modal-title {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.modal-close {
  font-size: 32px;
  color: $apple-text-secondary;
  line-height: 1;
  padding: 0 8px;
}

.modal-body {
  padding: 24px;
}

.form-item {
  margin-bottom: 20px;
}

.form-item:last-child {
  margin-bottom: 0;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  color: $apple-text-primary;
  margin-bottom: 8px;
}

.modal-footer {
  display: flex;
  gap: 12px;
  padding: 16px 24px 24px;
}

.modal-btn {
  flex: 1;
  padding: 14px;
  border-radius: 12px;
  text-align: center;
  font-size: 16px;
  font-weight: 600;
  transition: opacity 0.2s;
}

.modal-btn:active {
  opacity: 0.7;
}

.modal-btn.cancel {
  background-color: rgba(118, 118, 128, 0.1);
  color: $apple-text-primary;
}

.modal-btn.confirm {
  background-color: #007aff;
  color: white;
}

.detail-modal {
  max-width: 500px;
}

.detail-image-section {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.detail-image-container {
  width: 120px;
  height: 120px;
  border-radius: 12px;
  overflow: hidden;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.detail-type-image {
  width: 100%;
  height: 100%;
}

.detail-image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.detail-placeholder-text {
  font-size: 12px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.detail-info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.detail-info-row:last-child {
  border-bottom: none;
}

.detail-label {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.detail-value {
  font-size: 15px;
  color: $apple-text-primary;
  font-weight: 600;
}
</style>
