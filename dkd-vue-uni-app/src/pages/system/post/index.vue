<template>
  <AppTopBar title="Post Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" :value="queryParams.postCode" @input="queryParams.postCode = $event.detail.value" placeholder="Search by Post Code" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" :value="queryParams.postName" @input="queryParams.postName = $event.detail.value" placeholder="Search by Post Name" @confirm="handleSearch" />
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="post-list">
        <view class="post-card" v-for="item in postList" :key="item.postId" @click="handleViewDetail(item)">
          <view class="post-card-header">
            <text class="post-name">{{ item.postName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              {{ item.status === '0' ? 'Active' : 'Inactive' }}
            </view>
          </view>
          
          <view class="post-info">
            <view class="info-row">
              <text class="info-label">Post Code</text>
              <text class="info-value">{{ item.postCode }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Sort Order</text>
              <text class="info-value">{{ item.postSort }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Remark</text>
              <text class="info-value">{{ item.remark || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="hasPermission('system:post:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="hasPermission('system:post:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="postList.length === 0 && !loading">
          <text class="empty-text">No posts found</text>
        </view>
      </view>
    </scroll-view>

    <BottomSheet :visible="showDetailModal" title="Post Detail" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal">
      <view class="detail-info-row">
        <text class="detail-label">Post Name</text>
        <text class="detail-value">{{ detailData.postName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Post Code</text>
        <text class="detail-value">{{ detailData.postCode }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Sort Order</text>
        <text class="detail-value">{{ detailData.postSort }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Status</text>
        <text class="detail-value">{{ detailData.status === '0' ? 'Active' : 'Inactive' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Remark</text>
        <text class="detail-value">{{ detailData.remark || 'N/A' }}</text>
      </view>
      
    </BottomSheet>

    <BottomSheet :visible="showModal" :title="isEdit ? 'Edit Post' : 'Add Post'" @update:visible="val => !val && closeModal()" @close="closeModal">
      <view class="form-item">
        <text class="form-label">Post Name *</text>
        <input class="n-input" :value="form.postName" @input="form.postName = $event.detail.value" placeholder="Enter post name" />
      </view>
      <view class="form-item">
        <text class="form-label">Post Code *</text>
        <input class="n-input" :value="form.postCode" @input="form.postCode = $event.detail.value" placeholder="Enter post code" />
      </view>
      <view class="form-item">
        <text class="form-label">Sort Order *</text>
        <input class="n-input" :value="form.postSort" @input="form.postSort = $event.detail.value" type="number" placeholder="Enter sort order" />
      </view>
      <view class="form-item">
        <text class="form-label">Status</text>
        <picker mode="selector" :range="statusOptions" :value="statusIndex" @change="onStatusChange">
          <view class="picker-input">{{ statusOptions[statusIndex] }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="form-label">Remark</text>
        <textarea class="n-textarea" :value="form.remark" @input="form.remark = $event.detail.value" placeholder="Enter remark" />
      </view>
      <template #header-actions>
        <view class="action-pill" @click="closeModal"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--primary" @click="submitForm"><text class="action-pill-text">{{ isSubmitting ? 'Saving...' : 'Save' }}</text></view>
      </template>
    </BottomSheet>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listPost, getPost, addPost, updatePost, delPost } from '@/api/system/post'
import { hasPermission } from '@/utils/permission'

const postList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  postName: '',
  postCode: '',
  postSort: '',
  status: '',
  remark: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  postCode: '',
  postName: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  postId: null,
  postName: '',
  postCode: '',
  postSort: 0,
  status: '0',
  remark: ''
})

const statusOptions = ['All Status', 'Active', 'Inactive']
const filterStatusIndex = ref(0)
const statusIndex = ref(1)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    postList.value = []
  }
  try {
    loading.value = true
    const res = await listPost(queryParams.value)
    if (res.rows) {
      postList.value = [...postList.value, ...res.rows]
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
  form.value = { postId: null, postName: '', postCode: '', postSort: 0, status: '0', remark: '' }
  statusIndex.value = 1
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getPost(item.postId)
    detailData.value = {
      postName: res.data.postName,
      postCode: res.data.postCode,
      postSort: res.data.postSort,
      status: res.data.status,
      remark: res.data.remark
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load post detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { postName: '', postCode: '', postSort: '', status: '', remark: '' }
}

const handleEdit = async (item) => {
  try {
    const res = await getPost(item.postId)
    form.value = res.data
    form.value.postSort = Number(form.value.postSort)
    isEdit.value = true
    statusIndex.value = res.data.status === '0' ? 1 : 2
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load post data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.postName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delPost(item.postId)
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
  form.value = { postId: null, postName: '', postCode: '', postSort: 0, status: '0', remark: '' }
}

const onStatusChange = (e) => {
  statusIndex.value = e.detail.value
  form.value.status = e.detail.value === 1 ? '0' : '1'
}

const onFilterStatusChange = (e) => {
  filterStatusIndex.value = e.detail.value
  queryParams.value.status = e.detail.value === 0 ? null : (e.detail.value === 1 ? '0' : '1')
  handleSearch()
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  if (!form.value.postName) {
    uni.showToast({ title: 'Post Name is required', icon: 'none' })
    return
  }
  if (!form.value.postCode) {
    uni.showToast({ title: 'Post Code is required', icon: 'none' })
    return
  }
  if (!form.value.postSort && form.value.postSort !== 0) {
    uni.showToast({ title: 'Sort Order is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updatePost(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addPost(form.value)
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
  if (postList.value.length < total.value) {
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
  box-sizing: border-box;
  padding: calc($spacing-4 + env(safe-area-inset-top, 0px)) $spacing-4 calc($spacing-4 + #{$bottom-bar-height} + env(safe-area-inset-bottom, 0px)) $spacing-4;
}

.search-bar {
  padding: $spacing-4;
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
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
  gap: $spacing-4;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease-out, opacity 0.3s ease-out;
  opacity: 0;
}

.filters-container.expanded {
  max-height: 200px;
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

.post-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.post-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.post-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.post-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.post-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.status-active {
  background-color: rgba(52, 199, 89, 0.15);
  color: #34c759;
}

.status-inactive {
  background-color: rgba(255, 59, 48, 0.15);
  color: #ff3b30;
}

.post-info {
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

.form-item {
  margin-bottom: $spacing-4;
}

.form-item:last-child {
  margin-bottom: 0;
}

.form-label {
  display: block;
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
  margin-bottom: $spacing-2;
}

.picker-input {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 $spacing-4;
  @include text-body;
  width: 100%;
  box-sizing: border-box;
}

.n-textarea {
  @include glass-input;
  min-height: 80px;
  padding: $spacing-3 $spacing-4;
  @include text-body;
  width: 100%;
  box-sizing: border-box;
  border-radius: $radius-lg;
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
}

.detail-value {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}
</style>
