<template>
  <AppTopBar title="Employee Management" :showBack="true" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <view class="emp-list">
        <Card v-for="item in empList" :key="item.id" @click="handleViewDetail(item)" class="emp-card">
          <view class="emp-card-header">
            <Avatar :src="item.image" :text="item.userName?.charAt(0)?.toUpperCase() || '?'" size="md" />
            <view class="emp-info-header">
              <text class="emp-name">{{ item.userName }}</text>
              <Badge :variant="item.status === 1 ? 'success' : 'secondary'">{{ getStatusLabel(item.status) }}</Badge>
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
        </Card>

        <EmptyState v-if="empList.length === 0 && !loading" message="No employees found" />
      </view>
    </view>
    </scroll-view>
    <AppBottomBar :active-tab="'machines'" @tab-change="handleTabChange" />
  </view>

  <BottomSheet :visible="showDetailModal" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal" title="Employee Detail">
      <view class="detail-avatar-section">
        <Avatar :src="detailData.image" :text="detailData.userName?.charAt(0)?.toUpperCase() || '?'" size="lg" />
      </view>
      <view class="detail-info-row">
        <text class="detail-label">User Name</text>
        <text class="detail-value">{{ detailData.userName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Region</text>
        <text class="detail-value">{{ detailData.regionName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Role</text>
        <text class="detail-value">{{ detailData.roleName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Mobile</text>
        <text class="detail-value">{{ detailData.mobile }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Status</text>
        <text class="detail-value">{{ getStatusLabel(detailData.status) }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Created</text>
        <text class="detail-value">{{ detailData.createTime }}</text>
      </view>
    </BottomSheet>

    <BottomSheet :visible="showModal" @update:visible="val => !val && closeModal()" @close="closeModal" :title="isEdit ? 'Edit Employee' : 'Add Employee'">
      <Input v-model="form.userName" label="User Name *" placeholder="Enter user name" />
      <view class="form-item">
        <text class="form-label">Region *</text>
        <picker mode="selector" :range="regionList" range-key="regionName" :value="regionIndex" @change="onRegionChange">
          <view class="picker-input">{{ form.regionId ? regionList[regionIndex]?.regionName : 'Select Region' }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="form-label">Role *</text>
        <picker mode="selector" :range="roleList" range-key="roleName" :value="roleIndex" @change="onRoleChange">
          <view class="picker-input">{{ form.roleId ? roleList[roleIndex]?.roleName : 'Select Role' }}</view>
        </picker>
      </view>
      <Input v-model="form.mobile" label="Mobile *" type="number" placeholder="Enter mobile number" />
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
          <view class="picker-input">{{ statusOptions[statusIndex] }}</view>
        </picker>
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
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Card from '@/components/ui/Card.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import Input from '@/components/ui/Input.vue'
import Button from '@/components/ui/Button.vue'
import Avatar from '@/components/ui/Avatar.vue'
import Badge from '@/components/ui/Badge.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
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
  background: $color-bg-primary;
  padding-top: $top-bar-total-height;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}


.emp-list {
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.emp-card {
  padding: $spacing-4;
  transition: transform $transition-normal;
}

.emp-card:active {
  transform: scale(0.98);
  background-color: $color-bg-elevated;
}

.emp-card-header {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  margin-bottom: $spacing-4;
  padding-bottom: $spacing-3;
}

.emp-info-header {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
  margin-left: $spacing-3;
}

.emp-name {
  font-size: 18px;
  font-weight: $font-weight-bold;
  color: $color-text-primary;
  letter-spacing: -0.5px;
}

.emp-info {
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

.card-actions {
  display: flex;
  gap: $spacing-3;
  margin-top: $spacing-4;
  padding-top: $spacing-3;
  border-top: 1px solid $color-border-subtle;
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
  font-weight: $font-weight-semibold;
  color: $color-text-secondary;
  margin-bottom: $spacing-2;
}

.picker-input {
  height: 44px;
  padding: 0 $spacing-4;
  background: $color-bg-secondary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-pill;
  font-size: 16px;
  color: $color-text-primary;
  box-sizing: border-box;
}

.image-upload-container {
  width: 100%;
  height: 120px;
  border: 2px dashed $color-border-subtle;
  border-radius: $radius-lg;
  background: $color-bg-secondary;
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
  gap: $spacing-2;
}

.upload-icon {
  font-size: 32px;
  color: $color-text-secondary;
  font-weight: $font-weight-light;
}

.upload-text {
  font-size: 12px;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.detail-avatar-section {
  display: flex;
  justify-content: center;
  margin-bottom: $spacing-4;
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
  font-weight: $font-weight-medium;
}

.detail-value {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}
</style>
