<template>
  <wd-navbar title="Employee Management" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.userName" placeholder="Search by Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="regionList" range-key="regionName" :value="filterRegionIndex" @change="onFilterRegionChange">
          <view class="filter-picker">{{ queryParams.regionId ? regionList[filterRegionIndex]?.regionName : 'All Regions' }}</view>
        </picker>
        <picker mode="selector" :range="roleList" range-key="roleName" :value="filterRoleIndex" @change="onFilterRoleChange">
          <view class="filter-picker">{{ queryParams.roleId ? roleList[filterRoleIndex]?.roleName : 'All Roles' }}</view>
        </picker>
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="emp-list">
        <view class="emp-card" v-for="item in empList" :key="item.id" @click="handleViewDetail(item)">
          <view class="emp-card-header">
            <view class="emp-avatar">
              <image v-if="item.image" :src="item.image" class="avatar-image" mode="aspectFill" />
              <view v-else class="avatar-placeholder">
                <text class="avatar-initial">{{ item.userName?.charAt(0)?.toUpperCase() || '?' }}</text>
              </view>
            </view>
            <view class="emp-info-header">
              <text class="emp-name">{{ item.userName }}</text>
              <view class="emp-status" :class="item.status === 1 ? 'status-active' : 'status-inactive'">
                <text class="status-dot"></text>
                <text class="status-text">{{ getStatusLabel(item.status) }}</text>
              </view>
            </view>
          </view>
          
          <view class="emp-info">
            <view class="info-row">
              <text class="info-label">Region</text>
              <text class="info-value">{{ item.regionName || 'Unknown' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Role</text>
              <text class="info-value">{{ item.roleName || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Mobile</text>
              <text class="info-value">{{ item.mobile || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('manage:emp:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('manage:emp:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="empList.length === 0 && !loading">
          <text class="empty-text">No employees found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Employee Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-avatar-section">
            <view class="detail-avatar">
              <image v-if="detailData.image" :src="detailData.image" class="detail-avatar-image" mode="aspectFill" />
              <view v-else class="detail-avatar-placeholder">
                <text class="detail-avatar-initial">{{ detailData.userName?.charAt(0)?.toUpperCase() || '?' }}</text>
              </view>
            </view>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">User Name:</text>
            <text class="detail-value">{{ detailData.userName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Region:</text>
            <text class="detail-value">{{ detailData.regionName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Role:</text>
            <text class="detail-value">{{ detailData.roleName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Mobile:</text>
            <text class="detail-value">{{ detailData.mobile }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Status:</text>
            <text class="detail-value">{{ getStatusLabel(detailData.status) }}</text>
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
          <text class="modal-title">{{ isEdit ? 'Edit Employee' : 'Add Employee' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">User Name *</text>
            <input class="modal-input" v-model="form.userName" placeholder="Enter user name" />
          </view>
          <view class="form-item">
            <text class="form-label">Region *</text>
            <picker mode="selector" :range="regionList" range-key="regionName" :value="regionIndex" @change="onRegionChange">
              <view class="modal-input">{{ form.regionId ? regionList[regionIndex]?.regionName : 'Select Region' }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Role *</text>
            <picker mode="selector" :range="roleList" range-key="roleName" :value="roleIndex" @change="onRoleChange">
              <view class="modal-input">{{ form.roleId ? roleList[roleIndex]?.roleName : 'Select Role' }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Mobile *</text>
            <input class="modal-input" v-model="form.mobile" type="number" placeholder="Enter mobile number" />
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
          <view class="form-item">
            <text class="form-label">Status *</text>
            <picker mode="selector" :range="statusOptions" :value="statusIndex" @change="onStatusChange">
              <view class="modal-input">{{ statusOptions[statusIndex] }}</view>
            </picker>
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
import { useI18n } from 'vue-i18n'
import { listEmp, getEmp, addEmp, updateEmp, delEmp } from '@/api/manage/emp'
import { listRegion } from '@/api/manage/region'
import { listRole } from '@/api/manage/role'
import { hasPermission } from '@/utils/permission'

const { t } = useI18n()

const empList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  userName: '',
  regionName: '',
  roleName: '',
  mobile: '',
  image: '',
  status: '',
  createTime: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  userName: '',
  regionId: null,
  roleId: null,
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  userName: '',
  regionId: '',
  roleId: '',
  mobile: '',
  image: '',
  status: 1
})

const regionList = ref([])
const roleList = ref([])
const regionIndex = ref(0)
const roleIndex = ref(0)
const statusIndex = ref(0)
const filterRegionIndex = ref(0)
const filterRoleIndex = ref(0)
const filterStatusIndex = ref(0)
const statusOptions = ['All Status', 'Active', 'Inactive']

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    empList.value = []
  }
  try {
    loading.value = true
    const res = await listEmp(queryParams.value)
    if (res.rows) {
      empList.value = [...empList.value, ...res.rows]
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
  fetchDropdownData()
})

const fetchDropdownData = async () => {
  try {
    const [regionRes, roleRes] = await Promise.all([
      listRegion({ pageNum: 1, pageSize: 100 }),
      listRole({ pageNum: 1, pageSize: 100 })
    ])
    regionList.value = regionRes.rows || []
    roleList.value = roleRes.rows || []
  } catch (error) {
    console.error('Failed to fetch dropdown data', error)
  }
}

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { id: null, userName: '', regionId: null, roleId: null, mobile: '', image: '', status: 1 }
  regionIndex.value = 0
  roleIndex.value = 0
  statusIndex.value = 0
  showModal.value = true
}

const handleEdit = async (item) => {
  try {
    const res = await getEmp(item.id)
    form.value = res.data
    isEdit.value = true
    
    regionIndex.value = regionList.value.findIndex(r => r.id === form.value.regionId)
    roleIndex.value = roleList.value.findIndex(r => r.roleId === form.value.roleId)
    statusIndex.value = form.value.status === 1 ? 0 : 1
    
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load employee data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.userName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delEmp(item.id)
          uni.showToast({ title: 'Deleted successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to delete', icon: 'none' })
        }
      }
    }
  })
}

const onRegionChange = (e) => {
  regionIndex.value = e.detail.value
  form.value.regionId = regionList.value[e.detail.value].id
}

const onRoleChange = (e) => {
  roleIndex.value = e.detail.value
  form.value.roleId = roleList.value[e.detail.value].roleId
}

const onStatusChange = (e) => {
  statusIndex.value = e.detail.value
  form.value.status = e.detail.value === 1 ? 1 : 0
}

const onFilterRegionChange = (e) => {
  filterRegionIndex.value = e.detail.value
  queryParams.value.regionId = regionList.value[e.detail.value]?.id || null
  handleSearch()
}

const onFilterRoleChange = (e) => {
  filterRoleIndex.value = e.detail.value
  queryParams.value.roleId = roleList.value[e.detail.value]?.roleId || null
  handleSearch()
}

const onFilterStatusChange = (e) => {
  filterStatusIndex.value = e.detail.value
  queryParams.value.status = e.detail.value === 0 ? null : (e.detail.value === 1 ? 1 : 0)
  handleSearch()
}

const handleViewDetail = async (item) => {
  try {
    const res = await getEmp(item.id)
    detailData.value = {
      userName: res.data.userName,
      regionName: res.data.region?.regionName || 'Unknown',
      roleName: res.data.role?.roleName || 'Unknown',
      mobile: res.data.mobile,
      image: res.data.image,
      status: res.data.status,
      createTime: res.data.createTime
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load employee detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { userName: '', regionName: '', roleName: '', mobile: '', image: '', status: '', createTime: '' }
}

const closeModal = () => {
  showModal.value = false
  form.value = { id: null, userName: '', regionId: null, roleId: null, mobile: '', image: '', status: 1 }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.userName) {
    uni.showToast({ title: 'User Name is required', icon: 'none' })
    return
  }
  if (!form.value.regionId) {
    uni.showToast({ title: 'Please select a Region', icon: 'none' })
    return
  }
  if (!form.value.roleId) {
    uni.showToast({ title: 'Please select a Role', icon: 'none' })
    return
  }
  if (!form.value.mobile) {
    uni.showToast({ title: 'Mobile is required', icon: 'none' })
    return
  }
  if (!form.value.image) {
    uni.showToast({ title: 'Image is required', icon: 'none' })
    return
  }
  if (form.value.status === undefined || form.value.status === null) {
    uni.showToast({ title: 'Please select a Status', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateEmp(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addEmp(form.value)
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

const getStatusLabel = (status) => {
  return t(`emp.statusTypes.${status}`) || 'Unknown'
}

const loadMore = () => {
  if (empList.value.length < total.value) {
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

.emp-list {
  padding: 0 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.emp-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.emp-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.emp-card-header {
  display: flex;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.emp-avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  margin-right: 16px;
  flex-shrink: 0;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

.emp-info-header {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.emp-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.emp-status {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  font-weight: 500;
}

.status-active {
  color: #34c759;
}

.status-inactive {
  color: #8e8e93;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background-color: currentColor;
}

.emp-info {
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
  max-height: 80vh;
  overflow-y: auto;
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
  padding: 12px 16px;
  font-size: 16px;
  color: $apple-text-primary;
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

.detail-avatar-section {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}

.detail-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.detail-avatar-image {
  width: 100%;
  height: 100%;
}

.detail-avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.detail-avatar-initial {
  font-size: 32px;
  font-weight: 700;
  color: white;
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
