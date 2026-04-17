<template>
  <AppTopBar
    :unread-count="unreadCount"
    :profile-picture="profilePicture"
    :user-name="userName"
    @add="handleAdd"
    @search="handleSearch"
    @notification="handleNotification"
    @profile="handleProfile"
  />
  <view class="layout-container">
    <view class="filter-tabs">
      <scroll-view class="tabs-scroll" scroll-x :show-scrollbar="false">
        <view class="tabs-list">
          <view class="master-filter-tab" @click="handleMasterFilter">
            <Icon name="settings" size="18" color="currentColor" />
          </view>
          <view
            v-for="tab in filterTabs"
            :key="tab.value"
            class="tab-item"
            :class="{ 'tab-active': activeFilter === tab.value }"
            @click="handleFilterTab(tab.value)"
          >
            <text class="tab-text">{{ tab.label }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <scroll-view class="scroll-area" scroll-y refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <!-- Quick Stats -->
        <view class="stats-row">
          <view class="stat-item">
            <text class="stat-value">{{ totalProducts }}</text>
            <text class="stat-label">Total SKUs</text>
          </view>
          <view class="stat-item">
            <text class="stat-value">{{ discountCount }}</text>
            <text class="stat-label">On Discount</text>
          </view>
          <view class="stat-item">
            <text class="stat-value">{{ classCount }}</text>
            <text class="stat-label">Categories</text>
          </view>
        </view>

        <!-- Product List -->
        <text class="section-title">Product Catalog</text>
        <view class="product-list">
          <view v-if="filteredProducts.length === 0 && !loading" class="empty-state-wrapper">
            <EmptyState title="No products found" description="Add a new SKU to get started" />
          </view>
          <view
            v-for="product in filteredProducts"
            :key="product.skuId"
            class="product-item"
            @click="handleProductClick(product)"
          >
            <view class="product-image">
              <image v-if="product.skuImage" :src="product.skuImage" class="product-img" mode="aspectFill" />
              <Icon v-else name="box" size="24" color="currentColor" />
            </view>
            <view class="product-info">
              <text class="product-name">{{ product.skuName }}</text>
              <text class="product-sku">{{ product.brandName || 'Generic' }} · {{ product.unit || 'unit' }}</text>
              <view class="product-meta">
                <text class="stock-count">¥{{ product.price || 0 }}</text>
                <Badge v-if="product.isDiscount" variant="warning">Discount</Badge>
              </view>
            </view>
            <view class="product-actions">
              <Icon name="chevron-right" size="20" color="currentColor" />
            </view>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
  <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />

  <BottomSheet
    :visible="showDetail"
    :title="deleteConfirmMode ? 'Delete Product?' : (isEditing ? (formData.skuId ? 'Edit Product' : 'New Product') : 'Product Details')"
    @update:visible="val => !val && closeDetail()"
    @close="closeDetail"
  >
    <template #header-actions>
      <template v-if="deleteConfirmMode">
        <view class="action-pill" @click="cancelDeleteConfirm"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--danger" @click="confirmDelete"><text class="action-pill-text">Delete</text></view>
      </template>
      <template v-else-if="!isEditing">
        <view class="action-pill" @click="handleDelete"><text class="action-pill-text">Delete</text></view>
        <view class="action-pill action-pill--primary" @click="startEdit"><text class="action-pill-text">Edit</text></view>
      </template>
      <template v-else>
        <view class="action-pill" @click="cancelEdit"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--primary" @click="saveForm"><text class="action-pill-text">Save</text></view>
      </template>
    </template>
    <view v-if="deleteConfirmMode" class="delete-confirm">
      <text class="delete-confirm-message">Are you sure you want to delete "{{ detailData.skuName }}"? This action cannot be undone.</text>
    </view>
    <view v-else-if="!isEditing" class="detail-view">
      <view class="detail-row">
        <text class="detail-label">Name</text>
        <text class="detail-value">{{ detailData.skuName }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Brand</text>
        <text class="detail-value">{{ detailData.brandName || 'N/A' }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Unit</text>
        <text class="detail-value">{{ detailData.unit || 'N/A' }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Price</text>
        <text class="detail-value">¥{{ detailData.price || 0 }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Category</text>
        <text class="detail-value">{{ getClassName(detailData.classId) }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Discount</text>
        <text class="detail-value">{{ detailData.isDiscount ? 'Yes' : 'No' }}</text>
      </view>
    </view>
    <view v-else class="form-view">
      <view class="form-group">
        <text class="form-label">Product Name *</text>
        <input class="form-input" v-model="formData.skuName" placeholder="Enter product name" />
      </view>
      <view class="form-group">
        <text class="form-label">Brand</text>
        <input class="form-input" v-model="formData.brandName" placeholder="Enter brand name" />
      </view>
      <view class="form-group">
        <text class="form-label">Unit</text>
        <input class="form-input" v-model="formData.unit" placeholder="e.g. bottle, pack" />
      </view>
      <view class="form-group">
        <text class="form-label">Price (¥) *</text>
        <input class="form-input" v-model.number="formData.price" type="number" placeholder="0" />
      </view>
      <view class="form-group">
        <text class="form-label">Category</text>
        <picker mode="selector" :range="classOptions" range-key="className" :value="classIndex" @change="onClassChange">
          <view class="form-picker">{{ getClassName(formData.classId) || 'Select category' }}</view>
        </picker>
      </view>
      <view class="form-group form-toggle">
        <text class="form-label">On Discount</text>
        <switch :checked="formData.isDiscount" @change="formData.isDiscount = $event.detail.value" color="#3d8bff" />
      </view>
    </view>

  </BottomSheet>

  <FilterModal
    v-model:visible="showFilterModal"
    :filter-sections="filterSections"
    :selected-filters="selectedFilters"
    @apply="handleApplyFilters"
    @reset="handleResetFilters"
  />
  <SearchOverlay
    v-model:visible="showSearch"
    @search="handleSearchQuery"
    @result-click="handleSearchResult"
  />
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import useUserStore from '@/store/modules/user'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import FilterModal from '@/components/app/FilterModal.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Icon from '@/components/ui/Icon.vue'
import Badge from '@/components/ui/Badge.vue'
import Button from '@/components/ui/Button.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listSku, addSku, updateSku, delSku, listSkuClass } from '@/api/manage/sku'
import { getInfo } from '@/api/login'

const userStore = useUserStore()

const activeTab = ref('inventory')
const unreadCount = ref(0)
const showSearch = ref(false)
const showFilterModal = ref(false)
const activeFilter = ref('all')
const selectedFilters = ref({})
const loading = ref(false)
const isRefreshing = ref(false)

const products = ref([])
const classOptions = ref([])
const showDetail = ref(false)
const isEditing = ref(false)
const detailData = ref({})
const formData = ref({})
const classIndex = ref(0)

const filterTabs = computed(() => [
  { label: 'All', value: 'all' },
  { label: 'Discount', value: 'discount' },
  ...classOptions.value.map(c => ({ label: c.className, value: String(c.classId) }))
])

const filterSections = computed(() => [
  {
    key: 'category',
    title: 'Category',
    options: classOptions.value.map(c => ({ value: String(c.classId), label: c.className }))
  },
  {
    key: 'discount',
    title: 'Discount',
    options: [
      { value: 'true', label: 'On Discount' },
      { value: 'false', label: 'Regular Price' }
    ]
  }
])

const profilePicture = computed(() => userStore.avatar || '')
const userName = computed(() => userStore.name)

const totalProducts = computed(() => products.value.length)
const discountCount = computed(() => products.value.filter(p => p.isDiscount).length)
const classCount = computed(() => classOptions.value.length)

const filteredProducts = computed(() => {
  if (activeFilter.value === 'all') return products.value
  if (activeFilter.value === 'discount') return products.value.filter(p => p.isDiscount)
  const classIdNum = Number(activeFilter.value)
  if (!Number.isNaN(classIdNum)) return products.value.filter(p => p.classId === classIdNum)
  return products.value
})

const getClassName = (classId) => {
  const c = classOptions.value.find(x => x.classId === classId)
  return c ? c.className : ''
}

const fetchUserInfo = async () => {
  try {
    const response = await getInfo()
    if (response && response.user) {
      userStore.setUserInfo({
        name: response.user.nickName || response.user.userName,
        avatar: response.user.avatar,
        roles: response.roles,
        permissions: response.permissions
      })
    }
  } catch (error) {
    console.error(error)
  }
}

const fetchClasses = async () => {
  try {
    const res = await listSkuClass({ pageNum: 1, pageSize: 100 })
    classOptions.value = res.rows || []
  } catch (error) {
    console.error(error)
  }
}

const fetchProducts = async () => {
  loading.value = true
  try {
    const params = { pageNum: 1, pageSize: 100 }
    if (selectedFilters.value.category) {
      params.classId = selectedFilters.value.category
    }
    if (selectedFilters.value.discount) {
      params.isDiscount = selectedFilters.value.discount === 'true'
    }
    const res = await listSku(params)
    products.value = res.rows || []
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const onRefresh = async () => {
  isRefreshing.value = true
  await Promise.all([fetchClasses(), fetchProducts()])
  isRefreshing.value = false
}

const handleFilterTab = (value) => {
  activeFilter.value = value
}

const handleMasterFilter = () => {
  showFilterModal.value = true
}

const handleProductClick = (product) => {
  detailData.value = { ...product }
  isEditing.value = false
  showDetail.value = true
}

const handleAdd = () => {
  detailData.value = {}
  formData.value = {
    skuName: '',
    brandName: '',
    unit: '',
    price: 0,
    classId: classOptions.value[0]?.classId,
    isDiscount: false
  }
  classIndex.value = 0
  isEditing.value = true
  showDetail.value = true
}

const startEdit = () => {
  formData.value = { ...detailData.value }
  const idx = classOptions.value.findIndex(c => c.classId === formData.value.classId)
  classIndex.value = idx >= 0 ? idx : 0
  isEditing.value = true
}

const cancelEdit = () => {
  if (formData.value.skuId) {
    isEditing.value = false
  } else {
    closeDetail()
  }
}

const closeDetail = () => {
  showDetail.value = false
  isEditing.value = false
  deleteConfirmMode.value = false
}

const onClassChange = (e) => {
  classIndex.value = e.detail.value
  formData.value.classId = classOptions.value[e.detail.value]?.classId
}

const saveForm = async () => {
  if (!formData.value.skuName) {
    uni.showToast({ title: 'Product name required', icon: 'none' })
    return
  }
  try {
    if (formData.value.skuId) {
      await updateSku(formData.value)
      uni.showToast({ title: 'Product updated', icon: 'success' })
    } else {
      await addSku(formData.value)
      uni.showToast({ title: 'Product added', icon: 'success' })
    }
    closeDetail()
    fetchProducts()
  } catch (error) {
    console.error(error)
  }
}

const deleteConfirmMode = ref(false)

const handleDelete = () => {
  deleteConfirmMode.value = true
}

const cancelDeleteConfirm = () => {
  deleteConfirmMode.value = false
}

const confirmDelete = async () => {
  try {
    await delSku(detailData.value.skuId)
    uni.showToast({ title: 'Product deleted', icon: 'success' })
    deleteConfirmMode.value = false
    closeDetail()
    fetchProducts()
  } catch (error) {
    console.error(error)
  }
}

const handleApplyFilters = (filters) => {
  selectedFilters.value = filters
  showFilterModal.value = false
  fetchProducts()
}

const handleResetFilters = () => {
  selectedFilters.value = {}
  showFilterModal.value = false
  fetchProducts()
}

const handleSearch = () => {
  showSearch.value = true
}

const handleSearchQuery = async (query) => {
  if (query) {
    try {
      const res = await listSku({ pageNum: 1, pageSize: 50, skuName: query })
      products.value = res.rows || []
    } catch (error) {
      console.error(error)
    }
  } else {
    fetchProducts()
  }
}

const handleSearchResult = () => {
  showSearch.value = false
}

const handleNotification = () => {
  uni.navigateTo({ url: '/pages/notifications/index' })
}

const handleProfile = () => {
  uni.navigateTo({ url: '/pages/mine/index' })
}

const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'inventory') {
    uni.navigateTo({ url: routes[tabId] })
  }
}

onShow(() => {
  fetchUserInfo()
  fetchClasses()
  fetchProducts()
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

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

.content-wrapper {
  padding: $spacing-4 $spacing-4 calc($spacing-4 + #{$bottom-bar-height} + env(safe-area-inset-bottom, 0px)) $spacing-4;
  min-height: 100vh;
  box-sizing: border-box;
}

.filter-tabs {
  display: flex;
  align-items: center;
  padding: $spacing-3 $spacing-4;
}

.tabs-scroll {
  flex: 1;
  @include scrollbar-hidden;
}

.tabs-list {
  display: flex;
  gap: $spacing-2;
}

.tab-item {
  display: inline-flex;
  align-items: center;
  gap: $spacing-1;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $transition-normal;

  &:active {
    opacity: 0.7;
  }

  &.tab-active {
    background: $color-primary;
  }
}

.tab-text {
  @include text-caption;
  white-space: nowrap;
  color: $color-text-primary;
  font-weight: $font-weight-medium;

  .tab-active & {
    color: white;
  }
}

.tab-count {
  @include text-label;
  color: $color-text-tertiary;

  .tab-active & {
    color: rgba(255, 255, 255, 0.8);
  }
}

.master-filter-tab {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-1 $spacing-2;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  cursor: pointer;
  transition: all $transition-normal;
  color: $color-text-tertiary;
  flex-shrink: 0;

  &:active {
    opacity: 0.7;
  }
}

.stats-row {
  display: flex;
  gap: $spacing-3;
  margin-bottom: $spacing-4;
}

.stat-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-md;
  border: 1px solid $color-border-subtle;
}

.stat-value {
  @include text-title;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
  margin-bottom: $spacing-1;
}

.stat-label {
  @include text-caption;
  color: $color-text-secondary;
}

.product-list {
  display: flex;
  flex-direction: column;
  margin-bottom: $spacing-6;
}

.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin-bottom: $spacing-3;
  display: block;
}

.product-item {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-4 0;
  border-bottom: 1px solid $color-border-subtle;
  cursor: pointer;
  transition: background-color $transition-normal;

  &:first-child {
    padding-top: 0;
  }

  &:last-child {
    padding-bottom: 0;
    border-bottom: none;
  }

  &:active {
    background: $color-bg-elevated;
  }
}

.product-image {
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: $color-bg-elevated;
  border-radius: $radius-sm;
  color: $color-text-tertiary;
  overflow: hidden;
  flex-shrink: 0;
}

.product-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
  min-width: 0;
}

.product-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.product-sku {
  @include text-caption;
  color: $color-text-tertiary;
}

.product-meta {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.stock-count {
  @include text-caption;
  color: $color-primary;
  font-weight: $font-weight-semibold;
}

.product-actions {
  color: $color-text-tertiary;
}

.empty-state {
  padding: $spacing-8 0;
  text-align: center;
}

.empty-state-wrapper {
  padding: $spacing-6 0;
}

.empty-text {
  @include text-body;
  color: $color-text-tertiary;
}

.detail-view {
  display: flex;
  flex-direction: column;
}

.action-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-1 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-full;
  cursor: pointer;

  &:active { opacity: 0.7; }
  &--primary { background: $color-primary; }
  &--danger { background: $color-error; }
}

.action-pill-text {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;

  .action-pill--primary & { color: #fff; }
  .action-pill--danger & { color: #fff; }
}

.delete-confirm {
  padding: $spacing-4 0;
}

.delete-confirm-message {
  @include text-body;
  color: $color-text-secondary;
  line-height: 1.5;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;

  &:first-child {
    padding-top: 0;
  }

  &:last-child {
    border-bottom: none;
  }
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

.form-view {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
}

.form-toggle {
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.form-label {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.form-input {
  @include text-body;
  color: $color-text-primary;
  padding: $spacing-3;
  background: $color-bg-tertiary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-sm;
  width: 100%;
  box-sizing: border-box;
}

.form-picker {
  @include text-body;
  color: $color-text-primary;
  padding: $spacing-3;
  background: $color-bg-tertiary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-sm;
}
</style>
