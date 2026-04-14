<template>
  <TopBar title="Notice Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.noticeTitle" placeholder="Search by Title" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="noticeTypeOptions" :value="filterNoticeTypeIndex" @change="onFilterNoticeTypeChange">
          <view class="filter-picker">{{ noticeTypeOptions[filterNoticeTypeIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="notice-list">
        <view class="notice-card" v-for="item in noticeList" :key="item.noticeId" @click="handleViewDetail(item)">
          <view class="notice-card-header">
            <text class="notice-title">{{ item.noticeTitle }}</text>
            <view class="notice-type-badge" :class="item.noticeType === '1' ? 'type-notice' : (item.noticeType === '2' ? 'type-system' : 'type-announcement')">
              {{ item.noticeType === '1' ? 'Notice' : (item.noticeType === '2' ? 'System' : 'Announcement') }}
            </view>
          </view>
          
          <view class="notice-info">
            <view class="info-row">
              <text class="info-label">Status</text>
              <text class="info-value" :class="item.status === '0' ? 'status-active' : 'status-inactive'">{{ item.status === '0' ? 'Published' : 'Draft' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Created By</text>
              <text class="info-value">{{ item.createBy || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Created Time</text>
              <text class="info-value">{{ item.createTime }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="hasPermission('system:notice:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="hasPermission('system:notice:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="noticeList.length === 0 && !loading">
          <text class="empty-text">No notices found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Notice Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-info-row">
            <text class="detail-label">Title:</text>
            <text class="detail-value">{{ detailData.noticeTitle }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Type:</text>
            <text class="detail-value">{{ detailData.noticeType === '1' ? 'Notice' : (detailData.noticeType === '2' ? 'System' : 'Announcement') }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Status:</text>
            <text class="detail-value">{{ detailData.status === '0' ? 'Published' : 'Draft' }}</text>
          </view>
          <view class="detail-content-section">
            <text class="detail-label">Content:</text>
            <text class="detail-content-text">{{ detailData.noticeContent || 'N/A' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Created By:</text>
            <text class="detail-value">{{ detailData.createBy || 'N/A' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Created Time:</text>
            <text class="detail-value">{{ detailData.createTime }}</text>
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
          <text class="modal-title">{{ isEdit ? 'Edit Notice' : 'Add Notice' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">Title *</text>
            <input class="n-input" v-model="form.noticeTitle" placeholder="Enter title" />
          </view>
          <view class="form-item">
            <text class="form-label">Type *</text>
            <picker mode="selector" :range="noticeTypeOptions" :value="noticeTypeIndex" @change="onNoticeTypeChange">
              <view class="picker-input">{{ noticeTypeOptions[noticeTypeIndex] }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Status</text>
            <picker mode="selector" :range="statusOptions" :value="statusIndex" @change="onStatusChange">
              <view class="picker-input">{{ statusOptions[statusIndex] }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Content *</text>
            <textarea class="n-textarea" v-model="form.noticeContent" placeholder="Enter content" />
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
import { listNotice, getNotice, addNotice, updateNotice, delNotice } from '@/api/system/notice'
import { hasPermission } from '@/utils/permission'

const noticeList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  noticeTitle: '',
  noticeType: '',
  status: '',
  noticeContent: '',
  createBy: '',
  createTime: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  noticeTitle: '',
  noticeType: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  noticeId: null,
  noticeTitle: '',
  noticeType: '1',
  status: '0',
  noticeContent: ''
})

const noticeTypeOptions = ['All Types', 'Notice', 'System', 'Announcement']
const filterNoticeTypeIndex = ref(0)
const noticeTypeIndex = ref(1)
const statusOptions = ['Published', 'Draft']
const statusIndex = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    noticeList.value = []
  }
  try {
    loading.value = true
    const res = await listNotice(queryParams.value)
    if (res.rows) {
      noticeList.value = [...noticeList.value, ...res.rows]
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

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { noticeId: null, noticeTitle: '', noticeType: '1', status: '0', noticeContent: '' }
  noticeTypeIndex.value = 1
  statusIndex.value = 0
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getNotice(item.noticeId)
    detailData.value = {
      noticeTitle: res.data.noticeTitle,
      noticeType: res.data.noticeType,
      status: res.data.status,
      noticeContent: res.data.noticeContent,
      createBy: res.data.createBy,
      createTime: res.data.createTime
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load notice detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { noticeTitle: '', noticeType: '', status: '', noticeContent: '', createBy: '', createTime: '' }
}

const handleEdit = async (item) => {
  try {
    const res = await getNotice(item.noticeId)
    form.value = res.data
    isEdit.value = true
    noticeTypeIndex.value = res.data.noticeType === '1' ? 1 : (res.data.noticeType === '2' ? 2 : 3)
    statusIndex.value = res.data.status === '0' ? 0 : 1
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load notice data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.noticeTitle}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delNotice(item.noticeId)
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
  form.value = { noticeId: null, noticeTitle: '', noticeType: '1', status: '0', noticeContent: '' }
}

const onNoticeTypeChange = (e) => {
  noticeTypeIndex.value = e.detail.value
  form.value.noticeType = e.detail.value === 1 ? '1' : (e.detail.value === 2 ? '2' : '3')
}

const onStatusChange = (e) => {
  statusIndex.value = e.detail.value
  form.value.status = e.detail.value === 0 ? '0' : '1'
}

const onFilterNoticeTypeChange = (e) => {
  filterNoticeTypeIndex.value = e.detail.value
  queryParams.value.noticeType = e.detail.value === 0 ? null : (e.detail.value === 1 ? '1' : (e.detail.value === 2 ? '2' : '3'))
  handleSearch()
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  if (!form.value.noticeTitle) {
    uni.showToast({ title: 'Title is required', icon: 'none' })
    return
  }
  if (!form.value.noticeContent) {
    uni.showToast({ title: 'Content is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateNotice(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addNotice(form.value)
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
  if (noticeList.value.length < total.value) {
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
  color: $apple-text-primary;
}

.n-input::placeholder {
  color: $apple-text-secondary;
}

.filter-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 16px;
  background-color: rgba(0, 122, 255, 0.1);
  border-radius: $apple-radius-sm;
  transition: background-color 0.2s;
}

.filter-toggle:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.filter-toggle-text {
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.filter-toggle-icon {
  font-size: 12px;
  color: #007aff;
  transition: transform 0.2s;
}

.filters-container {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease-out, opacity 0.3s ease-out;
  opacity: 0;
}

.filters-container.expanded {
  max-height: 150px;
  opacity: 1;
}

.filter-picker {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  color: $apple-text-primary;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.notice-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.notice-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.notice-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.notice-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.notice-title {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.notice-type-badge {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.type-notice {
  background-color: rgba(0, 122, 255, 0.15);
  color: #007aff;
}

.type-system {
  background-color: rgba(255, 159, 10, 0.15);
  color: #ff9f0a;
}

.type-announcement {
  background-color: rgba(52, 199, 89, 0.15);
  color: #34c759;
}

.notice-info {
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

.status-active {
  color: #34c759;
}

.status-inactive {
  color: #ff9f0a;
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

.picker-input {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
}

.n-textarea {
  @include glass-input;
  min-height: 120px;
  padding: 12px 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  border-radius: 12px;
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

.detail-content-section {
  padding: 12px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.detail-label {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
  margin-bottom: 8px;
}

.detail-content-text {
  font-size: 15px;
  color: $apple-text-primary;
  font-weight: 500;
  line-height: 1.5;
}

.detail-value {
  font-size: 15px;
  color: $apple-text-primary;
  font-weight: 600;
}
</style>
