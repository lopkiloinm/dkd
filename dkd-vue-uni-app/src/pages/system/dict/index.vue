<template>
  <AppTopBar title="Dictionary Management" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" :value="queryParams.dictName" @input="queryParams.dictName = $event.detail.value" placeholder="Search by Dict Name" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <input class="n-input search-input" :value="queryParams.dictType" @input="queryParams.dictType = $event.detail.value" placeholder="Search by Dict Type" @confirm="handleSearch" />
        <picker mode="selector" :range="filterStatusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ filterStatusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="dict-list">
        <view class="dict-card" v-for="item in dictList" :key="item.dictId" @click="handleViewDetail(item)">
          <view class="dict-card-header">
            <text class="dict-name">{{ item.dictName }}</text>
            <view class="action-btn small" @click.stop="handleViewData(item)">
              <text class="action-text-small">View Data</text>
            </view>
          </view>
          
          <view class="dict-info">
            <view class="info-row">
              <text class="info-label">Dict Type</text>
              <text class="info-value">{{ item.dictType }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Status</text>
              <text class="info-value" :class="item.status === '0' ? 'status-active' : 'status-inactive'">{{ item.status === '0' ? 'Active' : 'Inactive' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Remark</text>
              <text class="info-value">{{ item.remark || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click.stop="handleEdit(item)" v-if="hasPermission('system:dict:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click.stop="handleDelete(item)" v-if="hasPermission('system:dict:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="dictList.length === 0 && !loading">
          <text class="empty-text">No dictionary types found</text>
        </view>
      </view>
    </scroll-view>

    <BottomSheet
      :visible="showDetailModal"
      title="Dictionary Type Detail"
      @update:visible="val => !val && closeDetailModal()"
      @close="closeDetailModal"
    >
      <view class="detail-info-row">
        <text class="detail-label">Dict Name</text>
        <text class="detail-value">{{ detailData.dictName }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Dict Type</text>
        <text class="detail-value">{{ detailData.dictType }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Status</text>
        <text class="detail-value">{{ detailData.status === '0' ? 'Active' : 'Inactive' }}</text>
      </view>
      <view class="detail-info-row">
        <text class="detail-label">Remark</text>
        <text class="detail-value">{{ detailData.remark || 'N/A' }}</text>
      </view>

    </BottomSheet>

    <BottomSheet
      :visible="showModal"
      :title="isEdit ? 'Edit Dictionary Type' : 'Add Dictionary Type'"
      @update:visible="val => !val && closeModal()"
      @close="closeModal"
    >
      <view class="form-item">
        <text class="form-label">Dict Name *</text>
        <SheetTextField v-model="form.dictName" placeholder="Enter dict name" />
      </view>
      <view class="form-item">
        <text class="form-label">Dict Type *</text>
        <SheetTextField v-model="form.dictType" placeholder="Enter dict type" :disabled="isEdit" />
      </view>
      <view class="form-item">
        <text class="form-label">Status</text>
        <picker mode="selector" :range="statusOptions" :value="statusIndex" @change="onStatusChange">
          <view class="picker-input">{{ statusOptions[statusIndex] }}</view>
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
import { listType, getType, addType, updateType, delType, refreshCache } from '@/api/system/dict/type'
import { hasPermission } from '@/utils/permission'
import SheetTextField from '@/components/ui/SheetTextField.vue'

const dictList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  dictName: '',
  dictType: '',
  status: '',
  remark: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  dictName: '',
  dictType: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  dictId: null,
  dictName: '',
  dictType: '',
  status: '0',
  remark: ''
})

const statusOptions = ['Active', 'Inactive']
const filterStatusOptions = ['All Status', 'Active', 'Inactive']
const statusIndex = ref(0)
const filterStatusIndex = ref(0)

const onFilterStatusChange = (e) => {
  filterStatusIndex.value = Number(e.detail.value)
  if (filterStatusIndex.value === 0) {
    queryParams.value.status = null
  } else {
    queryParams.value.status = filterStatusIndex.value === 1 ? '0' : '1'
  }
  fetchList(true)
}

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    dictList.value = []
  }
  try {
    loading.value = true
    const res = await listType(queryParams.value)
    if (res.rows) {
      dictList.value = [...dictList.value, ...res.rows]
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
  form.value = { dictId: null, dictName: '', dictType: '', status: '0', remark: '' }
  statusIndex.value = 0
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getType(item.dictId)
    detailData.value = {
      dictName: res.data.dictName,
      dictType: res.data.dictType,
      status: res.data.status,
      remark: res.data.remark
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load dict detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { dictName: '', dictType: '', status: '', remark: '' }
}

const handleViewData = (item) => {
  uni.navigateTo({
    url: `/pages/system/dict/data?dictType=${item.dictType}&dictName=${item.dictName}`
  })
}

const handleEdit = async (item) => {
  try {
    const res = await getType(item.dictId)
    form.value = res.data
    isEdit.value = true
    statusIndex.value = res.data.status === '0' ? 0 : 1
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load dict data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.dictName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delType(item.dictId)
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
  form.value = { dictId: null, dictName: '', dictType: '', status: '0', remark: '' }
}

const onStatusChange = (e) => {
  statusIndex.value = e.detail.value
  form.value.status = e.detail.value === 0 ? '0' : '1'
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  if (!form.value.dictName) {
    uni.showToast({ title: 'Dict Name is required', icon: 'none' })
    return
  }
  if (!form.value.dictType) {
    uni.showToast({ title: 'Dict Type is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateType(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addType(form.value)
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
  if (dictList.value.length < total.value) {
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
  gap: $spacing-3;
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

.dict-list {
  padding: 0 $spacing-5 $spacing-6;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.dict-card {
  @include glass-panel;
  padding: $spacing-5;
  transition: transform $transition-normal;
}

.dict-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.dict-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-3;
border-bottom: 1px solid $apple-glass-border;
}

.dict-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.action-btn.small {
  padding: $spacing-1 $spacing-3;
  background-color: rgba(0, 122, 255, 0.1);
  border-radius: $radius-md;
}

.action-btn.small:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.action-text-small {
  font-size: 12px;
  font-weight: 600;
  color: $color-primary;
}

.dict-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
}




.status-active {
  color: $color-success;
}

.status-inactive {
  color: $color-error;
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
  color: $color-primary;
}

.action-btn.delete .action-text {
  color: $color-error;
}

.form-item {
  margin-bottom: $spacing-5;
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
