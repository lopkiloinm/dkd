<template>
  <AppTopBar title="Config Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" :value="queryParams.configName" @input="queryParams.configName = $event.detail.value" placeholder="Search by Config Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" :value="queryParams.configKey" @input="queryParams.configKey = $event.detail.value" placeholder="Search by Config Key" @confirm="handleSearch" />
        <picker mode="selector" :range="configTypeOptions" :value="filterConfigTypeIndex" @change="onFilterConfigTypeChange">
          <view class="filter-picker">{{ configTypeOptions[filterConfigTypeIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="config-list">
        <view class="config-card" v-for="item in configList" :key="item.configId" @click="handleViewDetail(item)">
          <view class="config-card-header">
            <text class="config-name">{{ item.configName }}</text>
            <view class="config-type-badge" :class="item.configType === 'Y' ? 'type-system' : 'type-user'">
              {{ item.configType === 'Y' ? 'System' : 'User' }}
            </view>
          </view>
          
          <view class="config-info">
            <view class="info-row">
              <text class="info-label">Config Key</text>
              <text class="info-value">{{ item.configKey }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Config Value</text>
              <text class="info-value">{{ item.configValue }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Remark</text>
              <text class="info-value">{{ item.remark || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="hasPermission('system:config:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="hasPermission('system:config:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="configList.length === 0 && !loading">
          <text class="empty-text">No configs found</text>
        </view>
      </view>
    </scroll-view>

    <BottomSheet :visible="showDetailModal" title="Config Detail" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal">
      <view class="detail-info-row">
        <text class="detail-label">Config Name</text>
        <text class="detail-value">{{ detailData.configName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Config Key</text>
        <text class="detail-value">{{ detailData.configKey }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Config Value</text>
        <text class="detail-value">{{ detailData.configValue }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Config Type</text>
        <text class="detail-value">{{ detailData.configType === 'Y' ? 'System' : 'User' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Remark</text>
        <text class="detail-value">{{ detailData.remark || 'N/A' }}</text>
      </view>
      
    </BottomSheet>

    <BottomSheet :visible="showModal" :title="isEdit ? 'Edit Config' : 'Add Config'" @update:visible="val => !val && closeModal()" @close="closeModal">
      <view class="form-item">
        <text class="form-label">Config Name *</text>
        <SheetTextField v-model="form.configName" placeholder="Enter config name" />
      </view>
      <view class="form-item">
        <text class="form-label">Config Key *</text>
        <SheetTextField v-model="form.configKey" placeholder="Enter config key" />
      </view>
      <view class="form-item">
        <text class="form-label">Config Value *</text>
        <SheetTextField v-model="form.configValue" placeholder="Enter config value" />
      </view>
      <view class="form-item">
        <text class="form-label">Config Type *</text>
        <picker mode="selector" :range="configTypeOptions" :value="configTypeIndex" @change="onConfigTypeChange">
          <view class="picker-input">{{ configTypeOptions[configTypeIndex] }}</view>
        </picker>
      </view>
      <view class="form-item">
        <text class="form-label">Remark</text>
        <SheetTextField v-model="form.remark" placeholder="Enter remark" multiline />
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
import { listConfig, getConfig, addConfig, updateConfig, delConfig } from '@/api/system/config'
import { hasPermission } from '@/utils/permission'
import SheetTextField from '@/components/ui/SheetTextField.vue'

const configList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  configName: '',
  configKey: '',
  configValue: '',
  configType: '',
  remark: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  configName: '',
  configKey: '',
  configType: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  configId: null,
  configName: '',
  configKey: '',
  configValue: '',
  configType: 'N',
  remark: ''
})

const configTypeOptions = ['All Types', 'System', 'User']
const filterConfigTypeIndex = ref(0)
const configTypeIndex = ref(2)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    configList.value = []
  }
  try {
    loading.value = true
    const res = await listConfig(queryParams.value)
    if (res.rows) {
      configList.value = [...configList.value, ...res.rows]
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
  form.value = { configId: null, configName: '', configKey: '', configValue: '', configType: 'N', remark: '' }
  configTypeIndex.value = 2
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getConfig(item.configId)
    detailData.value = {
      configName: res.data.configName,
      configKey: res.data.configKey,
      configValue: res.data.configValue,
      configType: res.data.configType,
      remark: res.data.remark
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load config detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { configName: '', configKey: '', configValue: '', configType: '', remark: '' }
}

const handleEdit = async (item) => {
  try {
    const res = await getConfig(item.configId)
    form.value = res.data
    isEdit.value = true
    configTypeIndex.value = res.data.configType === 'Y' ? 1 : 2
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load config data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.configName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delConfig(item.configId)
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
  form.value = { configId: null, configName: '', configKey: '', configValue: '', configType: 'N', remark: '' }
}

const onConfigTypeChange = (e) => {
  configTypeIndex.value = e.detail.value
  form.value.configType = e.detail.value === 1 ? 'Y' : 'N'
}

const onFilterConfigTypeChange = (e) => {
  filterConfigTypeIndex.value = e.detail.value
  queryParams.value.configType = e.detail.value === 0 ? null : (e.detail.value === 1 ? 'Y' : 'N')
  handleSearch()
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  if (!form.value.configName) {
    uni.showToast({ title: 'Config Name is required', icon: 'none' })
    return
  }
  if (!form.value.configKey) {
    uni.showToast({ title: 'Config Key is required', icon: 'none' })
    return
  }
  if (!form.value.configValue) {
    uni.showToast({ title: 'Config Value is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateConfig(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addConfig(form.value)
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
  if (configList.value.length < total.value) {
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

.config-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.config-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.config-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.config-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.config-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.config-type-badge {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.type-system {
  background-color: rgba(0, 122, 255, 0.15);
  color: $color-primary;
}

.type-user {
  background-color: rgba(52, 199, 89, 0.15);
  color: $color-success;
}

.config-info {
  display: flex;
  flex-direction: column;
  gap: 10px;
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

.picker-input {
  @include sheet-form-picker-trigger;
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


</style>
