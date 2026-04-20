<template>
  <AppTopBar title="Menu Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" :value="queryParams.menuName" @input="queryParams.menuName = $event.detail.value" placeholder="Search by Menu Name" @confirm="handleSearch" />
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

    <BottomSheet :visible="showDetailModal" title="Menu Detail" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal">
      <view class="detail-info-row">
        <text class="detail-label">Menu Name</text>
        <text class="detail-value">{{ detailData.menuName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Menu Type</text>
        <text class="detail-value">{{ detailData.menuType === 'M' ? 'Directory' : (detailData.menuType === 'C' ? 'Menu' : 'Button') }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Order Num</text>
        <text class="detail-value">{{ detailData.orderNum }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Path</text>
        <text class="detail-value">{{ detailData.path || 'N/A' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Component</text>
        <text class="detail-value">{{ detailData.component || 'N/A' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Perms</text>
        <text class="detail-value">{{ detailData.perms || 'N/A' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Visible</text>
        <text class="detail-value">{{ detailData.visible === '0' ? 'Yes' : 'No' }}</text>
      </view>
      
    </BottomSheet>

    <BottomSheet :visible="showModal" :title="isEdit ? 'Edit Menu' : 'Add Menu'" @update:visible="val => !val && closeModal()" @close="closeModal">
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
        <input class="n-input" :value="form.menuName" @input="form.menuName = $event.detail.value" placeholder="Enter menu name" />
      </view>
      <view class="form-item">
        <text class="form-label">Order Num *</text>
        <input class="n-input" :value="form.orderNum" @input="form.orderNum = $event.detail.value" type="number" placeholder="Enter order num" />
      </view>
      <view class="form-item" v-if="form.menuType !== 'F'">
        <text class="form-label">Path</text>
        <input class="n-input" :value="form.path" @input="form.path = $event.detail.value" placeholder="Enter path" />
      </view>
      <view class="form-item" v-if="form.menuType === 'C'">
        <text class="form-label">Component</text>
        <input class="n-input" :value="form.component" @input="form.component = $event.detail.value" placeholder="Enter component" />
      </view>
      <view class="form-item" v-if="form.menuType !== 'M'">
        <text class="form-label">Perms</text>
        <input class="n-input" :value="form.perms" @input="form.perms = $event.detail.value" placeholder="Enter perms" />
      </view>
      <view class="form-item">
        <text class="form-label">Visible</text>
        <picker mode="selector" :range="visibleOptions" :value="visibleIndex" @change="onVisibleChange">
          <view class="picker-input">{{ visibleOptions[visibleIndex] }}</view>
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
import BottomSheet from '@/components/ui/BottomSheet.vue'
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
  color: $color-primary;
}

.filter-toggle-icon {
  font-size: 12px;
  color: $color-primary;
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
  color: $color-primary;
}

.type-menu {
  background-color: rgba(52, 199, 89, 0.15);
  color: $color-success;
}

.type-button {
  background-color: rgba(255, 159, 10, 0.15);
  color: $color-warning;
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
  color: $color-success;
}

.status-inactive {
  color: $color-error;
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
  color: $color-primary;
}

.action-btn.delete .action-text {
  color: $color-error;
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
  @include sheet-form-picker-trigger;
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
