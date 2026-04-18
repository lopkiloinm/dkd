<template>
  <AppTopBar title="User Management" :showBack="true" />
  <view class="layout-container">
    <!-- Bulk Actions Bar -->
    <view v-if="selectedUsers.length > 0" class="bulk-actions-bar">
      <text class="selected-count">{{ selectedUsers.length }} selected</text>
      <view class="bulk-actions">
        <Button variant="secondary" size="sm" @click="handleBulkActivate">Activate</Button>
        <Button variant="secondary" size="sm" @click="handleBulkDeactivate">Deactivate</Button>
        <Button variant="secondary" size="sm" @click="handleBulkDelete">Delete</Button>
        <Button variant="secondary" size="sm" @click="handleBulkRoleAssign">Assign Role</Button>
      </view>
    </view>

    <view class="search-bar">
      <input class="n-input search-input" :value="queryParams.userName" @input="queryParams.userName = $event.detail.value" placeholder="Search by User Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" :value="queryParams.phonenumber" @input="queryParams.phonenumber = $event.detail.value" placeholder="Search by Phone" @confirm="handleSearch" />
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <!-- Quick Actions -->
    <view class="quick-actions-bar">
      <Button variant="primary" size="sm" @click="handleAddUser">Add User</Button>
      <Button variant="secondary" size="sm" @click="handleRoleTemplate">Role Template</Button>
      <Button variant="secondary" size="sm" @click="handlePermissionMatrix">Permission Matrix</Button>
      <Button variant="secondary" size="sm" @click="handleAuditLog">Audit Log</button>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="user-list">
        <view class="user-card" v-for="item in userList" :key="item.userId" @click="handleViewDetail(item)">
          <view class="user-card-header">
            <view class="user-select-checkbox" @click.stop>
              <checkbox :checked="selectedUsers.includes(item.userId)" @change="toggleUserSelection(item.userId)" />
            </view>
            <view class="user-avatar">
              <image v-if="item.avatar" :src="item.avatar" class="avatar-image" mode="aspectFill" />
              <view v-else class="avatar-placeholder">
                <text class="avatar-initial">{{ item.userName?.charAt(0)?.toUpperCase() || '?' }}</text>
              </view>
            </view>
            <view class="user-info-header">
              <text class="user-name">{{ item.userName }}</text>
              <text class="user-nickname">{{ item.nickName }}</text>
            </view>
            <view class="status-badge" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              {{ item.status === '0' ? 'Active' : 'Inactive' }}
            </view>
          </view>
          
          <view class="user-info">
            <view class="info-row">
              <text class="info-label">Department</text>
              <text class="info-value">{{ item.dept?.deptName || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Phone</text>
              <text class="info-value">{{ item.phonenumber || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Email</text>
              <text class="info-value">{{ item.email || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Roles</text>
              <text class="info-value">{{ item.roles?.map(r => r.roleName).join(', ') || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Last Login</text>
              <text class="info-value">{{ item.loginDate || 'Never' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleResetPwd(item)" v-if="item.userId !== 1 && hasPermission('system:user:resetPwd')">
              <text class="action-text">Reset Pwd</text>
            </view>
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="item.userId !== 1 && hasPermission('system:user:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="item.userId !== 1 && hasPermission('system:user:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="userList.length === 0 && !loading">
          <text class="empty-text">No users found</text>
        </view>
      </view>
    </scroll-view>

    <BottomSheet :visible="showDetailModal" title="User Detail" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal">
      <view class="detail-avatar-section">
        <view class="detail-avatar">
          <image v-if="detailData.avatar" :src="detailData.avatar" class="detail-avatar-image" mode="aspectFill" />
          <view v-else class="detail-avatar-placeholder">
            <text class="detail-avatar-initial">{{ detailData.userName?.charAt(0)?.toUpperCase() || '?' }}</text>
          </view>
        </view>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">User Name</text>
        <text class="detail-value">{{ detailData.userName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Nickname</text>
        <text class="detail-value">{{ detailData.nickName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Department</text>
        <text class="detail-value">{{ detailData.deptName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Phone</text>
        <text class="detail-value">{{ detailData.phonenumber }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Email</text>
        <text class="detail-value">{{ detailData.email }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Status</text>
        <text class="detail-value">{{ detailData.status === '0' ? 'Active' : 'Inactive' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Created</text>
        <text class="detail-value">{{ detailData.createTime }}</text>
      </view>
      
    </BottomSheet>

    <BottomSheet :visible="showModal" :title="isEdit ? 'Edit User' : 'Add User'" @update:visible="val => !val && closeModal()" @close="closeModal">
      <view class="form-item">
        <text class="form-label">User Name *</text>
        <input class="n-input" :value="form.userName" @input="form.userName = $event.detail.value" placeholder="Enter user name" />
      </view>
      <view class="form-item">
        <text class="form-label">Nickname *</text>
        <input class="n-input" :value="form.nickName" @input="form.nickName = $event.detail.value" placeholder="Enter nickname" />
      </view>
      <view class="form-item">
        <text class="form-label">Department *</text>
        <picker mode="selector" :range="deptList" range-key="deptName" :value="deptIndex" @change="onDeptChange">
          <view class="picker-input">{{ form.deptId ? deptList[deptIndex]?.deptName : 'Select Department' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="form-label">Phone</text>
        <input class="n-input" :value="form.phonenumber" @input="form.phonenumber = $event.detail.value" placeholder="Enter phone number" />
      </view>
      <view class="form-item">
        <text class="form-label">Email</text>
        <input class="n-input" :value="form.email" @input="form.email = $event.detail.value" placeholder="Enter email" />
      </view>
      <view class="form-item" v-if="!isEdit">
        <text class="form-label">Password *</text>
        <input class="n-input" :value="form.password" @input="form.password = $event.detail.value" type="password" placeholder="Enter password" />
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
import AppTopBar from '@/components/app/AppTopBar.vue'
import Button from '@/components/ui/Button.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listUser, getUser, addUser, updateUser, delUser, resetUserPwd } from '@/api/system/user'
import { listDept } from '@/api/system/dept'
import { hasPermission } from '@/utils/permission'

const userList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  userName: '',
  nickName: '',
  deptName: '',
  phonenumber: '',
  email: '',
  avatar: '',
  status: '',
  createTime: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  userName: '',
  phonenumber: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)
const selectedUsers = ref([])

const toggleUserSelection = (userId) => {
  const index = selectedUsers.value.indexOf(userId)
  if (index > -1) {
    selectedUsers.value.splice(index, 1)
  } else {
    selectedUsers.value.push(userId)
  }
}

const handleBulkActivate = () => {
  uni.showToast({
    title: `Activating ${selectedUsers.value.length} users...`,
    icon: 'loading'
  })
}

const handleBulkDeactivate = () => {
  uni.showToast({
    title: `Deactivating ${selectedUsers.value.length} users...`,
    icon: 'loading'
  })
}

const handleBulkDelete = () => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Delete ${selectedUsers.value.length} selected users?`,
    success: (res) => {
      if (res.confirm) {
        uni.showToast({
          title: `Deleting ${selectedUsers.value.length} users...`,
          icon: 'loading'
        })
      }
    }
  })
}

const handleBulkRoleAssign = () => {
  uni.navigateTo({ url: '/pages/system/role/index' })
}

const handleAddUser = () => {
  showModal.value = true
  isEdit.value = false
}

const handleRoleTemplate = () => {
  uni.navigateTo({ url: '/pages/system/role/index' })
}

const handlePermissionMatrix = () => {
  uni.showToast({
    title: 'Opening permission matrix...',
    icon: 'loading'
  })
}

const handleAuditLog = () => {
  uni.navigateTo({ url: '/pages/monitor/operlog/index' })
}

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  userId: null,
  userName: '',
  nickName: '',
  deptId: null,
  phonenumber: '',
  email: '',
  password: '',
  status: '0'
})

const deptList = ref([])
const deptIndex = ref(0)
const statusOptions = ['All Status', 'Active', 'Inactive']
const filterStatusIndex = ref(0)
const statusIndex = ref(1)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    userList.value = []
  }
  try {
    loading.value = true
    const res = await listUser(queryParams.value)
    if (res.rows) {
      userList.value = [...userList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load data', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const fetchDeptList = async () => {
  try {
    const res = await listDept({ pageNum: 1, pageSize: 100 })
    deptList.value = res.rows || []
  } catch (error) {
    console.error('Failed to fetch department list', error)
  }
}

onShow(() => {
  fetchList(true)
  fetchDeptList()
})

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { userId: null, userName: '', nickName: '', deptId: null, phonenumber: '', email: '', password: '', status: '0' }
  deptIndex.value = 0
  statusIndex.value = 1
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getUser(item.userId)
    detailData.value = {
      userName: res.data.userName,
      nickName: res.data.nickName,
      deptName: res.data.dept?.deptName || 'Unknown',
      phonenumber: res.data.phonenumber,
      email: res.data.email,
      avatar: res.data.avatar,
      status: res.data.status,
      createTime: res.data.createTime
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load user detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { userName: '', nickName: '', deptName: '', phonenumber: '', email: '', avatar: '', status: '', createTime: '' }
}

const handleResetPwd = (item) => {
  uni.showModal({
    title: 'Reset Password',
    content: `Are you sure you want to reset the password for ${item.userName}?`,
    editable: true,
    placeholderText: 'Enter new password',
    success: async (res) => {
      if (res.confirm && res.content) {
        try {
          await resetUserPwd(item.userId, res.content)
          uni.showToast({ title: 'Password reset successfully', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: 'Failed to reset password', icon: 'none' })
        }
      }
    }
  })
}

const handleToggleStatus = (item) => {
  const newStatus = item.status === '0' ? '1' : '0'
  const text = newStatus === '0' ? 'enable' : 'disable'
  uni.showModal({
    title: 'Confirm',
    content: `Are you sure you want to ${text} "${item.userName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await changeUserStatus(item.userId, newStatus)
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
    const res = await getUser(item.userId)
    form.value = res.data
    isEdit.value = true
    statusIndex.value = res.data.status === '0' ? 1 : 2
    if (res.data.deptId) {
      deptIndex.value = deptList.value.findIndex(d => d.id === res.data.deptId)
    }
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load user data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.userName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delUser(item.userId)
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
  form.value = { userId: null, userName: '', nickName: '', deptId: null, phonenumber: '', email: '', password: '', status: '0' }
}

const onDeptChange = (e) => {
  deptIndex.value = e.detail.value
  form.value.deptId = deptList.value[e.detail.value].id
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
  
  if (!form.value.userName) {
    uni.showToast({ title: 'User Name is required', icon: 'none' })
    return
  }
  if (!form.value.nickName) {
    uni.showToast({ title: 'Nickname is required', icon: 'none' })
    return
  }
  if (!form.value.deptId) {
    uni.showToast({ title: 'Department is required', icon: 'none' })
    return
  }
  if (!isEdit.value && !form.value.password) {
    uni.showToast({ title: 'Password is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateUser(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addUser(form.value)
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
  if (userList.value.length < total.value) {
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

.bulk-actions-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-3 $spacing-4;
  background: $color-bg-tertiary;
  border-bottom: 1px solid $color-border-subtle;
}

.selected-count {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.bulk-actions {
  display: flex;
  gap: $spacing-2;
}

.quick-actions-bar {
  display: flex;
  gap: $spacing-2;
  padding: $spacing-3 $spacing-4;
  background: $color-bg-secondary;
  border-bottom: 1px solid $color-border-subtle;
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

.user-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.user-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.user-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.user-card-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.user-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  margin-right: 16px;
  flex-shrink: 0;
}

.avatar-image {
  width: 100%;
  height: 100%;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-initial {
  font-size: 24px;
  font-weight: 700;
  color: white;
}

.user-info-header {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.user-nickname {
  font-size: 14px;
  color: $apple-text-secondary;
  font-weight: 500;
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

.user-info {
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

.detail-avatar-section {
  display: flex;
  justify-content: center;
  margin-bottom: $spacing-4;
}

.detail-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.detail-avatar-image { width: 100%; height: 100%; }

.detail-avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.detail-avatar-initial {
  font-size: 32px;
  font-weight: $font-weight-bold;
  color: $color-text-primary;
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

.detail-label { @include text-caption; color: $color-text-secondary; }
.detail-value { @include text-body; color: $color-text-primary; font-weight: $font-weight-medium; }
</style>
