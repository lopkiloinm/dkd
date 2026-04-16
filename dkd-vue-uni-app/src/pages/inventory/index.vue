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
            <text v-if="tab.count !== undefined" class="tab-count">{{ tab.count }}</text>
          </view>
        </view>
      </scroll-view>
    </view>

    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">

        <!-- Quick Stats -->
        <view class="stats-row">
          <view class="stat-item">
            <text class="stat-value">{{ totalProducts }}</text>
            <text class="stat-label">Total Products</text>
          </view>
          <view class="stat-item">
            <text class="stat-value">{{ lowStockCount }}</text>
            <text class="stat-label">Low Stock</text>
          </view>
          <view class="stat-item">
            <text class="stat-value">{{ outOfStockCount }}</text>
            <text class="stat-label">Out of Stock</text>
          </view>
        </view>

        <!-- Product List -->
        <text class="section-title">Product List</text>
        <view class="product-list">
          <view
            v-for="product in filteredProducts"
            :key="product.id"
            class="product-item"
            @click="handleProductClick(product)"
          >
            <view class="product-image">
              <Icon name="box" size="24" color="currentColor" />
            </view>
            <view class="product-info">
              <text class="product-name">{{ product.name }}</text>
              <text class="product-sku">SKU: {{ product.sku }}</text>
              <view class="product-meta">
                <text class="stock-count">{{ product.stock }} in stock</text>
                <Chip
                  :label="getStockStatus(product.stock)"
                  :variant="getStockVariant(product.stock)"
                  size="sm"
                />
              </view>
            </view>
            <view class="product-actions">
              <Icon name="chevron-right" size="20" color="currentColor" />
            </view>
          </view>
          <view v-if="filteredProducts.length === 0" class="empty-state">
            <text class="empty-text">No products found</text>
          </view>
        </view>
      </view>
    </scroll-view>
  </view>
  <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />
  <FilterModal
    :visible="showFilterModal"
    @update:visible="showFilterModal = $event"
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
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/store/modules/user'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import FilterModal from '@/components/app/FilterModal.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Icon from '@/components/ui/Icon.vue'
import Chip from '@/components/ui/Chip.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import { getInfo } from '@/api/login'

const userStore = useUserStore()

const activeTab = ref('inventory')
const unreadCount = ref(3)
const showSearch = ref(false)
const showFilterModal = ref(false)
const activeFilter = ref('all')
const selectedFilters = ref({})

const filterTabs = ref([
  { label: 'All', value: 'all' },
  { label: 'In Stock', value: 'in-stock' },
  { label: 'Low Stock', value: 'low-stock' },
  { label: 'Out of Stock', value: 'out-of-stock' }
])

const filterSections = ref([
  {
    key: 'category',
    title: 'Category',
    options: [
      { value: 'beverages', label: 'Beverages' },
      { value: 'snacks', label: 'Snacks' },
      { value: 'food', label: 'Food' },
      { value: 'other', label: 'Other' }
    ]
  },
  {
    key: 'status',
    title: 'Stock Status',
    options: [
      { value: 'in-stock', label: 'In Stock' },
      { value: 'low-stock', label: 'Low Stock' },
      { value: 'out-of-stock', label: 'Out of Stock' }
    ]
  }
])

const handleFilterTab = (value) => {
  activeFilter.value = value
}

const handleMasterFilter = () => {
  showFilterModal.value = true
}

const profilePicture = computed(() => userStore.avatar || '/static/default-avatar.png')
const userName = computed(() => userStore.name)

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
    console.error('Failed to fetch user info', error)
  }
}

const products = ref([
  { id: 1, name: 'Coca Cola 330ml', sku: 'BEV-001', stock: 150, category: 'beverages', price: 1.50 },
  { id: 2, name: 'Pepsi 330ml', sku: 'BEV-002', stock: 120, category: 'beverages', price: 1.50 },
  { id: 3, name: 'Lays Classic', sku: 'SNK-001', stock: 8, category: 'snacks', price: 2.00 },
  { id: 4, name: 'Doritos Nacho Cheese', sku: 'SNK-002', stock: 0, category: 'snacks', price: 2.50 },
  { id: 5, name: 'Sandwich Chicken', sku: 'FOD-001', stock: 45, category: 'food', price: 4.00 },
  { id: 6, name: 'Bottled Water 500ml', sku: 'BEV-003', stock: 200, category: 'beverages', price: 1.00 },
  { id: 7, name: 'Chocolate Bar', sku: 'SNK-003', stock: 5, category: 'snacks', price: 1.75 },
  { id: 8, name: 'Energy Drink', sku: 'BEV-004', stock: 0, category: 'beverages', price: 3.00 }
])

const totalProducts = computed(() => products.value.length)
const lowStockCount = computed(() => products.value.filter(p => p.stock > 0 && p.stock < 10).length)
const outOfStockCount = computed(() => products.value.filter(p => p.stock === 0).length)

const filteredProducts = computed(() => {
  if (activeFilter.value === 'all') return products.value
  if (activeFilter.value === 'in-stock') return products.value.filter(p => p.stock > 10)
  if (activeFilter.value === 'low-stock') return products.value.filter(p => p.stock > 0 && p.stock < 10)
  if (activeFilter.value === 'out-of-stock') return products.value.filter(p => p.stock === 0)
  return products.value
})

const getStockStatus = (stock) => {
  if (stock === 0) return 'Out of Stock'
  if (stock < 10) return 'Low Stock'
  return 'In Stock'
}

const getStockVariant = (stock) => {
  if (stock === 0) return 'error'
  if (stock < 10) return 'warning'
  return 'success'
}

const handleAdd = () => {
  uni.navigateTo({ url: '/pages/inventory/add' })
}

const handleSearch = () => {
  showSearch.value = true
}

const handleNotification = () => {
  uni.navigateTo({ url: '/pages/notification/index' })
}

const handleProfile = () => {
  uni.navigateTo({ url: '/pages/profile/index' })
}

const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/data/index'
  }
  if (routes[tabId] && tabId !== 'inventory') {
    uni.navigateTo({ url: routes[tabId] })
  }
}

const handleProductClick = (product) => {
  uni.navigateTo({ url: `/pages/inventory/detail?id=${product.id}` })
}

const handleApplyFilters = (filters) => {
  console.log('Applied filters:', filters)
  selectedFilters.value = filters
  showFilterModal.value = false
}

const handleResetFilters = () => {
  selectedFilters.value = {}
  showFilterModal.value = false
}

const handleSearchQuery = (query) => {
  console.log('Search query:', query)
}

const handleSearchResult = (result) => {
  console.log('Search result:', result)
  showSearch.value = false
}

onMounted(() => {
  fetchUserInfo()
  // Fetch inventory data from backend
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
  gap: $spacing-3;
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
  padding: $spacing-4;
  background: $color-bg-secondary;
  border-radius: $radius-md;
  cursor: pointer;
  transition: background-color $transition-normal;

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
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}

.product-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
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
  color: $color-text-secondary;
}

.product-actions {
  color: $color-text-tertiary;
}

.empty-state {
  padding: $spacing-8 0;
  text-align: center;
}

.empty-text {
  @include text-body;
  color: $color-text-tertiary;
}
</style>
