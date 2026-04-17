<template>
  <TopBar title="Department Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.deptName" placeholder="Search by Dept Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="dept-list">
        <view class="dept-card" v-for="item in deptList" :key="item.deptId" @click="handleViewDetail(item)">
          <view class="dept-card-header">
            <text class="dept-name">{{ item.deptName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              {{ item.status === '0' ? 'Active' : 'Inactive' }}
            </view>
          </view>
          
          <view class="dept-info">
            <view class="info-row">
              <text class="info-label">Order Num</text>
              <text class="info-value">{{ item.orderNum }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Leader</text>
              <text class="info-value">{{ item.leader || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Phone</text>
              <text class="info-value">{{ item.phone || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleAdd(item)" v-if="hasPermission('system:dept:add')">
              <text class="action-text">Add Sub</text>
            </view>
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="hasPermission('system:dept:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="item.parentId !== 0 && hasPermission('system:dept:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="deptList.length === 0 && !loading">
          <text class="empty-text">No departments found</text>
        </view>
      </view>
    </scroll-view>

    <BottomSheet :visible="showDetailModal" title="Department Detail" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal">
      <view class="detail-info-row">
        <text class="detail-label">Dept Name</text>
        <text class="detail-value">{{ detailData.deptName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Order Num</text>
        <text class="detail-value">{{ detailData.orderNum }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Leader</text>
        <text class="detail-value">{{ detailData.leader || 'N/A' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Phone</text>
        <text class="detail-value">{{ detailData.phone || 'N/A' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Email</text>
        <text class="detail-value">{{ detailData.email || 'N/A' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Status</text>
        <text class="detail-value">{{ detailData.status === '0' ? 'Active' : 'Inactive' }}</text>
      </view>
      
    </BottomSheet>

    <BottomSheet :visible="showModal" :title="isEdit ? 'Edit Department' : 'Add Department'" @update:visible="val => !val && closeModal()" @close="closeModal">
      <view class="form-item" v-if="form.parentId !== 0">
        <text class="form-label">Parent Dept</text>
        <picker mode="selector" :range="parentDeptOptions" range-key="deptName" :value="parentDeptIndex" @change="onParentDeptChange">
          <view class="picker-input">{{ form.parentId ? parentDeptOptions[parentDeptIndex]?.deptName : 'Select Parent' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="form-label">Dept Name *</text>
        <input class="n-input" v-model="form.deptName" placeholder="Enter dept name" />
      </view>
      <view class="form-item">
        <text class="form-label">Order Num *</text>
        <input class="n-input" v-model="form.orderNum" type="number" placeholder="Enter order num" />
      </view>
      <view class="form-item">
        <text class="form-label">Leader</text>
        <input class="n-input" v-model="form.leader" placeholder="Enter leader" />
      </view>
      <view class="form-item">
        <text class="form-label">Phone</text>
        <input class="n-input" v-model="form.phone" placeholder="Enter phone" />
      </view>
      <view class="form-item">
        <text class="form-label">Email</text>
        <input class="n-input" v-model="form.email" placeholder="Enter email" />
      </view>
      <view class="form-item">
        <text class="form-label">Status</text>
        <picker mode="selector" :range="statusOptions" :value="statusIndex" @change="onStatusChange">
          <view class="picker-input">{{ statusOptions[statusIndex] }}</view>
        </picker>
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
import TopBar from '@/components/TopBar/index.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listDept, getDept, addDept, updateDept, delDept } from '@/api/system/dept'
import { hasPermission } from '@/utils/permission'

const deptList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  deptName: '',
  orderNum: '',
  leader: '',
  phone: '',
  email: '',
  status: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  deptName: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  deptId: null,
  parentId: 0,
  deptName: '',
  orderNum: 0,
  leader: '',
  phone: '',
  email: '',
  status: '0'
})

const parentDeptOptions = ref([])
const parentDeptIndex = ref(0)
const statusOptions = ['All Status', 'Active', 'Inactive']
const filterStatusIndex = ref(0)
const statusIndex = ref(1)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    deptList.value = []
  }
  try {
    loading.value = true
    const res = await listDept(queryParams.value)
    if (res.rows) {
      deptList.value = [...deptList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load data', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const fetchParentDepts = async () => {
  try {
    const res = await listDept({ pageNum: 1, pageSize: 100 })
    parentDeptOptions.value = res.rows || []
  } catch (error) {
    console.error('Failed to fetch parent departments', error)
  }
}

onShow(() => {
  fetchList(true)
  fetchParentDepts()
})

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

const handleAdd = (parentItem = null) => {
  isEdit.value = false
  form.value = { deptId: null, parentId: parentItem ? parentItem.deptId : 0, deptName: '', orderNum: 0, leader: '', phone: '', email: '', status: '0' }
  if (parentItem) {
    parentDeptIndex.value = parentDeptOptions.value.findIndex(d => d.deptId === parentItem.deptId)
  } else {
    parentDeptIndex.value = 0
  }
  statusIndex.value = 1
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getDept(item.deptId)
    detailData.value = {
      deptName: res.data.deptName,
      orderNum: res.data.orderNum,
      leader: res.data.leader,
      phone: res.data.phone,
      email: res.data.email,
      status: res.data.status
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load dept detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { deptName: '', orderNum: '', leader: '', phone: '', email: '', status: '' }
}

const handleEdit = async (item) => {
  try {
    const res = await getDept(item.deptId)
    form.value = res.data
    isEdit.value = true
    statusIndex.value = res.data.status === '0' ? 1 : 2
    if (res.data.parentId) {
      parentDeptIndex.value = parentDeptOptions.value.findIndex(d => d.deptId === res.data.parentId)
    }
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load dept data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.deptName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delDept(item.deptId)
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
  form.value = { deptId: null, parentId: 0, deptName: '', orderNum: 0, leader: '', phone: '', email: '', status: '0' }
}

const onParentDeptChange = (e) => {
  parentDeptIndex.value = e.detail.value
  form.value.parentId = parentDeptOptions.value[e.detail.value]?.deptId || 0
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
  
  if (!form.value.deptName) {
    uni.showToast({ title: 'Dept Name is required', icon: 'none' })
    return
  }
  if (!form.value.orderNum && form.value.orderNum !== 0) {
    uni.showToast({ title: 'Order Num is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateDept(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addDept(form.value)
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
  if (deptList.value.length < total.value) {
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
  padding: 0 $spacing-4;
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
  gap: $spacing-2;
  padding: $spacing-2 $spacing-4;
  background-color: rgba(0, 122, 255, 0.1);
  border-radius: $apple-radius-sm;
  transition: background-color $transition-normal;
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
  gap: $spacing-3;
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
  padding: 0 $spacing-4;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  color: $apple-text-primary;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.dept-list {
  padding: 0 $spacing-5 $spacing-6;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.dept-card {
  @include glass-panel;
  padding: $spacing-5;
  transition: transform $transition-normal;
}

.dept-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.dept-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-4;
  padding-bottom: $spacing-3;
  border-bottom: 1px solid $apple-glass-border;
}

.dept-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.status-badge {
  padding: $spacing-1 $spacing-3;
  border-radius: $radius-lg;
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

.dept-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
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
  padding: $spacing-10 0;
  text-align: center;
}

.empty-text {
  color: $apple-text-secondary;
  font-size: 15px;
}

.card-actions {
  display: flex;
  gap: $spacing-3;
  margin-top: $spacing-4;
  padding-top: $spacing-3;
  border-top: 1px solid $apple-glass-border;
}

.action-btn {
  flex: 1;
  padding: $spacing-2 $spacing-4;
  border-radius: $radius-md;
  background-color: rgba(0, 122, 255, 0.1);
  text-align: center;
  transition: background-color $transition-normal;
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
  font-weight: $font-weight-medium