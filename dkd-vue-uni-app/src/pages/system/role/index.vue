<template>
  <TopBar title="Role Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.roleName" placeholder="Search by Role Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" v-model="queryParams.roleKey" placeholder="Search by Role Key" @confirm="handleSearch" />
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="role-list">
        <view class="role-card" v-for="item in roleList" :key="item.roleId" @click="handleViewDetail(item)">
          <view class="role-card-header">
            <text class="role-name">{{ item.roleName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              {{ item.status === '0' ? 'Active' : 'Inactive' }}
            </view>
          </view>
          
          <view class="role-info">
            <view class="info-row">
              <text class="info-label">Role Key</text>
              <text class="info-value">{{ item.roleKey }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Sort Order</text>
              <text class="info-value">{{ item.roleSort }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Created</text>
              <text class="info-value">{{ item.createTime }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleToggleStatus(item)" v-if="item.roleId !== 1 && hasPermission('system:role:edit')">
              <text class="action-text">{{ item.status === '0' ? 'Disable' : 'Enable' }}</text>
            </view>
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="item.roleId !== 1 && hasPermission('system:role:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="item.roleId !== 1 && hasPermission('system:role:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="roleList.length === 0 && !loading">
          <text class="empty-text">No roles found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Role Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-info-row">
            <text class="detail-label">Role Name:</text>
            <text class="detail-value">{{ detailData.roleName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Role Key:</text>
            <text class="detail-value">{{ detailData.roleKey }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Sort Order:</text>
            <text class="detail-value">{{ detailData.roleSort }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Status:</text>
            <text class="detail-value">{{ detailData.status === '0' ? 'Active' : 'Inactive' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Remark:</text>
            <text class="detail-value">{{ detailData.remark || 'N/A' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Created:</text>
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
          <text class="modal-title">{{ isEdit ? 'Edit Role' : 'Add Role' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">Role Name *</text>
            <input class="n-input" v-model="form.roleName" placeholder="Enter role name" />
          </view>
          <view class="form-item">
            <text class="form-label">Role Key *</text>
            <input class="n-input" v-model="form.roleKey" placeholder="Enter role key" />
          </view>
          <view class="form-item">
            <text class="form-label">Sort Order *</text>
            <input class="n-input" v-model="form.roleSort" type="number" placeholder="Enter sort order" />
          </view>
          <view class="form-item">
            <text class="form-label">Status</text>
            <picker mode="selector" :range="statusOptions" :value="statusIndex" @change="onStatusChange">
              <view class="picker-input">{{ statusOptions[statusIndex] }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Remark</text>
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
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import { listRole, getRole, addRole, updateRole, delRole, changeRoleStatus } from '@/api/system/role'
import { hasPermission } from '@/utils/permission'

const roleList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  roleName: '',
  roleKey: '',
  roleSort: '',
  status: '',
  remark: '',
  createTime: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  roleName: '',
  roleKey: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  roleId: null,
  roleName: '',
  roleKey: '',
  roleSort: 0,
  status: '0',
  remark: ''
})

const statusOptions = ['All Status', 'Active', 'Inactive']
const filterStatusIndex = ref(0)
const statusIndex = ref(1)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    roleList.value = []
  }
  try {
    loading.value = true
    const res = await listRole(queryParams.value)
    if (res.rows) {
      roleList.value = [...roleList.value, ...res.rows]
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
  form.value = { roleId: null, roleName: '', roleKey: '', roleSort: 0, status: '0', remark: '' }
  statusIndex.value = 1
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getRole(item.roleId)
    detailData.value = {
      roleName: res.data.roleName,
      roleKey: res.data.roleKey,
      roleSort: res.data.roleSort,
      status: res.data.status,
      remark: res.data.remark,
      createTime: res.data.createTime
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load role detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { roleName: '', roleKey: '', roleSort: '', status: '', remark: '', createTime: '' }
}

const handleToggleStatus = (item) => {
  const newStatus = item.status === '0' ? '1' : '0'
  const text = newStatus === '0' ? 'enable' : 'disable'
  uni.showModal({
    title: 'Confirm',
    content: `Are you sure you want to ${text} "${item.roleName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await changeRoleStatus(item.roleId, newStatus)
          uni.showToast({ title: 'Status updated successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to update status', icon: 'none' })
        }
      }
    }
  })
}

const handleEdit = async (item) => {
  try {
    const res = await getRole(item.roleId)
    form.value = res.data
    form.value.roleSort = Number(form.value.roleSort)
    isEdit.value = true
    statusIndex.value = res.data.status === '0' ? 1 : 2
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load role data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.roleName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delRole(item.roleId)
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
  form.value = { roleId: null, roleName: '', roleKey: '', roleSort: 0, status: '0', remark: '' }
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
  
  if (!form.value.roleName) {
    uni.showToast({ title: 'Role Name is required', icon: 'none' })
    return
  }
  if (!form.value.roleKey) {
    uni.showToast({ title: 'Role Key is required', icon: 'none' })
    return
  }
  if (!form.value.roleSort && form.value.roleSort !== 0) {
    uni.showToast({ title: 'Sort Order is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateRole(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addRole(form.value)
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
  if (roleList.value.length < total.value) {
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

.role-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.role-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.role-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.role-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.role-name {
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

.role-info {
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
  min-height: 80px;
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
