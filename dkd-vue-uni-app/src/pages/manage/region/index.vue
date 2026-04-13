<template>
  <view class="layout-container">
    <NavBar class="nav-bar-comp" back breadcrumb="Home" title="Regions" :showAdd="hasPermission('manage:region:add')" @add="handleAdd" />
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.regionName" placeholder="Search by Region Name" @confirm="handleSearch" />
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="region-list">
        <view class="region-card" v-for="item in regionList" :key="item.id">
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

          <view class="card-actions">
            <view class="action-btn" @click="handleViewDetail(item)" v-if="hasPermission('manage:node:list')">
              <text class="action-text">View</text>
            </view>
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('manage:region:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('manage:region:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="regionList.length === 0 && !loading">
          <text class="empty-text">No regions found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showModal" @click="closeModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">{{ isEdit ? 'Edit Region' : 'Add Region' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">Region Name *</text>
            <input class="n-input" v-model="form.regionName" placeholder="Enter region name" />
          </view>
          <view class="form-item">
            <text class="form-label">Remark *</text>
            <textarea class="n-textarea" v-model="form.remark" placeholder="Enter remark" />
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

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Region Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-info">
            <text class="detail-label">Region Name:</text>
            <text class="detail-value">{{ detailData.regionName }}</text>
          </view>
          <view class="detail-section-title">Nodes in this Region</view>
          <view class="node-list-detail">
            <view class="node-item" v-for="node in detailData.nodeList" :key="node.id">
              <text class="node-name">{{ node.nodeName }}</text>
              <text class="node-vm-count">{{ node.vmCount || 0 }} VMs</text>
            </view>
            <view class="empty-nodes" v-if="detailData.nodeList.length === 0">
              <text class="empty-text">No nodes in this region</text>
            </view>
          </view>
        </view>
        <view class="modal-footer">
          <view class="modal-btn cancel" @click="closeDetailModal">
            <text>Close</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import NavBar from '@/components/NavBar/index.vue'
import { listRegion, getRegion, addRegion, updateRegion, delRegion } from '@/api/manage/region'
import { listNode } from '@/api/manage/node'
import { hasPermission } from '@/utils/permission'

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
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  box-sizing: border-box;
}

.nav-bar-comp {
  flex-shrink: 0;
}

.search-bar {
  padding: 16px 20px 16px;
  z-index: 10;
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

.region-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.region-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.region-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.region-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.region-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.node-count {
  font-size: 13px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.count-number {
  font-size: 16px;
  color: $apple-blue;
  font-weight: 700;
}

.region-info {
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

.n-textarea {
  @include glass-input;
  width: 100%;
  min-height: 100px;
  padding: 12px 16px;
  font-size: 16px;
  border-radius: 12px;
  box-sizing: border-box;
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

.modal-btn.confirm.disabled {
  background-color: rgba(0, 122, 255, 0.5);
  opacity: 0.7;
  pointer-events: none;
}

.detail-modal {
  max-width: 500px;
}

.detail-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background-color: rgba(0, 122, 255, 0.05);
  border-radius: 12px;
  margin-bottom: 20px;
}

.detail-label {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.detail-value {
  font-size: 16px;
  color: $apple-text-primary;
  font-weight: 700;
}

.detail-section-title {
  font-size: 16px;
  font-weight: 700;
  color: $apple-text-primary;
  margin-bottom: 16px;
}

.node-list-detail {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 300px;
  overflow-y: auto;
}

.node-item {
  @include glass-panel;
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.node-item .node-name {
  font-size: 15px;
  font-weight: 600;
  color: $apple-text-primary;
}

.node-item .node-vm-count {
  font-size: 14px;
  color: $apple-blue;
  font-weight: 500;
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
