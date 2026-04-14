<template>
  <wd-navbar title="Menu Management" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.menuName" placeholder="Search by Menu Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="menuTypeOptions" :value="filterMenuTypeIndex" @change="onFilterMenuTypeChange">
          <view class="filter-picker">{{ menuTypeOptions[filterMenuTypeIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="menu-list">
        <view class="menu-card" v-for="item in menuList" :key="item.menuId" @click="handleViewDetail(item)">
          <view class="menu-card-header">
            <text class="menu-name">{{ item.menuName }}</text>
            <view class="menu-type-badge" :class="item.menuType === 'M' ? 'type-directory' : (item.menuType === 'C' ? 'type-menu' : 'type-button')">
              {{ item.menuType === 'M' ? 'Directory' : (item.menuType === 'C' ? 'Menu' : 'Button') }}
            </view>
          </view>
          
          <view class="menu-info">
            <view class="info-row">
              <text class="info-label">Menu Type</text>
              <text class="info-value">{{ item.menuType === 'M' ? 'Directory' : (item.menuType === 'C' ? 'Menu' : 'Button') }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Order Num</text>
              <text class="info-value">{{ item.orderNum }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Path</text>
              <text class="info-value">{{ item.path || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Visible</text>
              <text class="info-value" :class="item.visible === '0' ? 'status-active' : 'status-inactive'">{{ item.visible === '0' ? 'Yes' : 'No' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleAdd(item)" v-if="item.menuType !== 'F' && hasPermission('system:menu:add')">
              <text class="action-text">Add Sub</text>
            </view>
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="hasPermission('system:menu:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="hasPermission('system:menu:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="menuList.length === 0 && !loading">
          <text class="empty-text">No menus found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Menu Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-info-row">
            <text class="detail-label">Menu Name:</text>
            <text class="detail-value">{{ detailData.menuName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Menu Type:</text>
            <text class="detail-value">{{ detailData.menuType === 'M' ? 'Directory' : (detailData.menuType === 'C' ? 'Menu' : 'Button') }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Order Num:</text>
            <text class="detail-value">{{ detailData.orderNum }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Path:</text>
            <text class="detail-value">{{ detailData.path || 'N/A' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Component:</text>
            <text class="detail-value">{{ detailData.component || 'N/A' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Perms:</text>
            <text class="detail-value">{{ detailData.perms || 'N/A' }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Visible:</text>
            <text class="detail-value">{{ detailData.visible === '0' ? 'Yes' : 'No' }}</text>
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
          <text class="modal-title">{{ isEdit ? 'Edit Menu' : 'Add Menu' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item" v-if="form.parentId !== 0">
            <text class="form-label">Parent Menu</text>
            <picker mode="selector" :range="parentMenuOptions" range-key="menuName" :value="parentMenuIndex" @change="onParentMenuChange">
              <view class="picker-input">{{ form.parentId ? parentMenuOptions[parentMenuIndex]?.menuName : 'Select Parent' }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Menu Type *</text>
            <picker mode="selector" :range="menuTypeOptions" :value="menuTypeIndex" @change="onMenuTypeChange">
              <view class="picker-input">{{ menuTypeOptions[menuTypeIndex] }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">Menu Name *</text>
            <input class="n-input" v-model="form.menuName" placeholder="Enter menu name" />
          </view>
          <view class="form-item">
            <text class="form-label">Order Num *</text>
            <input class="n-input" v-model="form.orderNum" type="number" placeholder="Enter order num" />
          </view>
          <view class="form-item" v-if="form.menuType !== 'F'">
            <text class="form-label">Path</text>
            <input class="n-input" v-model="form.path" placeholder="Enter path" />
          </view>
          <view class="form-item" v-if="form.menuType === 'C'">
            <text class="form-label">Component</text>
            <input class="n-input" v-model="form.component" placeholder="Enter component" />
          </view>
          <view class="form-item" v-if="form.menuType !== 'M'">
            <text class="form-label">Perms</text>
            <input class="n-input" v-model="form.perms" placeholder="Enter perms" />
          </view>
          <view class="form-item">
            <text class="form-label">Visible</text>
            <picker mode="selector" :range="visibleOptions" :value="visibleIndex" @change="onVisibleChange">
              <view class="picker-input">{{ visibleOptions[visibleIndex] }}</view>
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
import { listMenu, getMenu, addMenu, updateMenu, delMenu } from '@/api/system/menu'
import { hasPermission } from '@/utils/permission'

const menuList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  menuName: '',
  menuType: '',
  orderNum: '',
  path: '',
  component: '',
  perms: '',
  visible: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  menuName: '',
  menuType: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  menuId: null,
  parentId: 0,
  menuName: '',
  menuType: 'M',
  orderNum: 0,
  path: '',
  component: '',
  perms: '',
  visible: '0'
})

const parentMenuOptions = ref([])
const parentMenuIndex = ref(0)
const menuTypeOptions = ['All Types', 'Directory', 'Menu', 'Button']
const filterMenuTypeIndex = ref(0)
const menuTypeIndex = ref(1)
const visibleOptions = ['Yes', 'No']
const visibleIndex = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    menuList.value = []
  }
  try {
    loading.value = true
    const res = await listMenu(queryParams.value)
    if (res.rows) {
      menuList.value = [...menuList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load data', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const fetchParentMenus = async () => {
  try {
    const res = await listMenu({ pageNum: 1, pageSize: 100, menuType: 'M' })
    parentMenuOptions.value = res.rows || []
  } catch (error) {
    console.error('Failed to fetch parent menus', error)
  }
}

onShow(() => {
  fetchList(true)
  fetchParentMenus()
})

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

const handleAdd = (parentItem = null) => {
  isEdit.value = false
  form.value = { menuId: null, parentId: parentItem ? parentItem.menuId : 0, menuName: '', menuType: parentItem ? 'C' : 'M', orderNum: 0, path: '', component: '', perms: '', visible: '0' }
  if (parentItem) {
    parentMenuIndex.value = parentMenuOptions.value.findIndex(m => m.menuId === parentItem.menuId)
    menuTypeIndex.value = 2
  } else {
    parentMenuIndex.value = 0
    menuTypeIndex.value = 1
  }
  visibleIndex.value = 0
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getMenu(item.menuId)
    detailData.value = {
      menuName: res.data.menuName,
      menuType: res.data.menuType,
      orderNum: res.data.orderNum,
      path: res.data.path,
      component: res.data.component,
      perms: res.data.perms,
      visible: res.data.visible
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load menu detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { menuName: '', menuType: '', orderNum: '', path: '', component: '', perms: '', visible: '' }
}

const handleEdit = async (item) => {
  try {
    const res = await getMenu(item.menuId)
    form.value = res.data
    form.value.orderNum = Number(form.value.orderNum)
    isEdit.value = true
    menuTypeIndex.value = res.data.menuType === 'M' ? 1 : (res.data.menuType === 'C' ? 2 : 3)
    visibleIndex.value = res.data.visible === '0' ? 0 : 1
    if (res.data.parentId) {
      parentMenuIndex.value = parentMenuOptions.value.findIndex(m => m.menuId === res.data.parentId)
    }
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load menu data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.menuName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delMenu(item.menuId)
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
  form.value = { menuId: null, parentId: 0, menuName: '', menuType: 'M', orderNum: 0, path: '', component: '', perms: '', visible: '0' }
}

const onParentMenuChange = (e) => {
  parentMenuIndex.value = e.detail.value
  form.value.parentId = parentMenuOptions.value[e.detail.value]?.menuId || 0
}

const onMenuTypeChange = (e) => {
  menuTypeIndex.value = e.detail.value
  form.value.menuType = e.detail.value === 1 ? 'M' : (e.detail.value === 2 ? 'C' : 'F')
}

const onVisibleChange = (e) => {
  visibleIndex.value = e.detail.value
  form.value.visible = e.detail.value === 0 ? '0' : '1'
}

const onFilterMenuTypeChange = (e) => {
  filterMenuTypeIndex.value = e.detail.value
  queryParams.value.menuType = e.detail.value === 0 ? null : (e.detail.value === 1 ? 'M' : (e.detail.value === 2 ? 'C' : 'F'))
  handleSearch()
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  if (!form.value.menuName) {
    uni.showToast({ title: 'Menu Name is required', icon: 'none' })
    return
  }
  if (!form.value.orderNum && form.value.orderNum !== 0) {
    uni.showToast({ title: 'Order Num is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateMenu(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addMenu(form.value)
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
  if (menuList.value.length < total.value) {
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

.menu-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.menu-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.menu-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.menu-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.menu-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.menu-type-badge {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.type-directory {
  background-color: rgba(0, 122, 255, 0.15);
  color: #007aff;
}

.type-menu {
  background-color: rgba(52, 199, 89, 0.15);
  color: #34c759;
}

.type-button {
  background-color: rgba(255, 159, 10, 0.15);
  color: #ff9f0a;
}

.menu-info {
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
  color: #ff3b30;
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
