<template>
  <AppTopBar
    :unread-count="unreadCount"
    :profile-picture="profilePicture"
    :user-name="userName"
    @search="handleSearch"
    @notification="handleNotification"
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

    <scroll-view
      class="scroll-area"
      scroll-y
      @scrolltolower="loadMore"
      refresher-enabled
      @refresherrefresh="onRefresh"
      :refresher-triggered="isRefreshing"
    >
      <view class="content-wrapper">
        <text class="section-title">Machines</text>
        <view class="vm-list">
          <view v-if="vmList.length === 0 && !loading" class="empty-state">
            <EmptyState title="No machines found" description="Try adjusting your filters or add a new machine" />
          </view>
          <Card
            v-for="item in vmList"
            :key="item.id"
            class="vm-card"
            @click="handleViewDetail(item)"
          >
            <view class="card-header">
              <text class="vm-code">{{ item.innerCode }}</text>
              <Badge :variant="getStatusVariant(item.vmStatus)">{{ getStatusText(item.vmStatus) }}</Badge>
            </view>
            <view class="vm-info">
              <view class="info-row">
                <text class="info-label">Address</text>
                <text class="info-value">{{ item.addr || 'N/A' }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Node</text>
                <text class="info-value">{{ item.nodeName || 'Unassigned' }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Partner</text>
                <text class="info-value">{{ item.partnerName || 'None' }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Type</text>
                <text class="info-value">{{ item.vmTypeName || '—' }}</text>
              </view>
            </view>
          </Card>
        </view>
      </view>
    </scroll-view>
  </view>
  <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />

  <FilterModal
    v-model:visible="showFilterModal"
    title="Filter Machines"
    :filter-sections="filterSections"
    :selected-filters="selectedFilters"
    @apply="handleFilterApply"
    @reset="handleFilterReset"
  />
  <SearchOverlay
    v-model:visible="showSearch"
    @search="handleSearchQuery"
    @result-click="handleSearchResult"
  />

  <BottomSheet
    :visible="showDetail"
    :title="formMode === 'detail' ? 'Machine Details' : (formData.id ? 'Edit Machine' : 'New Machine')"
    @update:visible="val => !val && closeDetail()"
    @close="closeDetail"
  >
    <view v-if="formMode === 'detail'" class="detail-view">
      <view class="detail-row">
        <text class="detail-label">Code</text>
        <text class="detail-value">{{ detailData.innerCode }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Status</text>
        <Badge :variant="getStatusVariant(detailData.vmStatus)">{{ getStatusText(detailData.vmStatus) }}</Badge>
      </view>
      <view class="detail-row">
        <text class="detail-label">Address</text>
        <text class="detail-value">{{ detailData.addr || 'N/A' }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Node</text>
        <text class="detail-value">{{ detailData.nodeName }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Region</text>
        <text class="detail-value">{{ detailData.regionName }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Partner</text>
        <text class="detail-value">{{ detailData.partnerName }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Type</text>
        <text class="detail-value">{{ detailData.vmTypeName }}</text>
      </view>
    </view>

    <view v-else class="form-view">
      <view class="form-group">
        <text class="form-label">Inner Code *</text>
        <input class="form-input" :value="formData.innerCode" @input="formData.innerCode = $event.detail.value" placeholder="Machine inner code" />
      </view>
      <view class="form-group">
        <text class="form-label">Node *</text>
        <picker mode="selector" :range="nodeList" range-key="nodeName" :value="nodeIndex" @change="onNodeChange">
          <view class="form-picker">{{ nodeList[nodeIndex]?.nodeName || 'Select node' }}</view>
        </picker>
      </view>
      <view class="form-group">
        <text class="form-label">VM Type *</text>
        <picker mode="selector" :range="vmTypeList" range-key="name" :value="vmTypeIndex" @change="onVmTypeChange">
          <view class="form-picker">{{ vmTypeList[vmTypeIndex]?.name || 'Select type' }}</view>
        </picker>
      </view>
    </view>

    <template v-if="formMode === 'detail'" #header-actions>
      <view
        v-if="detailData.vmStatus === 0"
        class="action-pill action-pill--primary"
        @click="updateStatus(1)"
      >
        <text class="action-pill-text">Activate</text>
      </view>
      <view
        v-if="detailData.vmStatus === 1"
        class="action-pill"
        @click="updateStatus(3)"
      >
        <text class="action-pill-text">Report Fault</text>
      </view>
      <view
        v-if="detailData.vmStatus === 3"
        class="action-pill action-pill--primary"
        @click="updateStatus(1)"
      >
        <text class="action-pill-text">Mark Repaired</text>
      </view>
      <view class="action-pill" @click="handleEditFromDetail">
        <text class="action-pill-text">Edit</text>
      </view>
    </template>

    <template v-if="formMode !== 'detail'" #header-actions>
      <view class="action-pill" @click="closeDetail"><text class="action-pill-text">Cancel</text></view>
      <view class="action-pill action-pill--primary" @click="submitForm"><text class="action-pill-text">Save</text></view>
    </template>
  </BottomSheet>
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
import Card from '@/components/ui/Card.vue'
import Badge from '@/components/ui/Badge.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listVm, getVm, addVm, updateVm } from '@/api/manage/vm'
import { listNode } from '@/api/manage/node'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { listVmType } from '@/api/manage/vmType'
import { getInfo } from '@/api/login'

const userStore = useUserStore()

// Top bar
const userName = computed(() => userStore.name)
const profilePicture = computed(() => userStore.avatar || '')
const unreadCount = ref(0)

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

// Navigation
const activeTab = ref('machines')
const showSearch = ref(false)
const showFilterModal = ref(false)

// List state
const vmList = ref([])
const total = ref(0)
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  innerCode: '',
  nodeId: null,
  regionId: null,
  partnerId: null,
  vmTypeId: null,
  vmStatus: null,
  orderByColumn: 'createTime',
  isAsc: 'desc'
})

// Filter tabs
const activeFilter = ref('all')
const filterTabs = ref([
  { label: 'All', value: 'all' },
  { label: 'Operating', value: 'operating' },
  { label: 'Unoperated', value: 'unoperated' },
  { label: 'Fault', value: 'fault' }
])

// Dropdowns
const nodeList = ref([])
const vmTypeList = ref([])
const regionList = ref([])
const partnerList = ref([])

// Filter modal
const selectedFilters = ref({})
const filterSections = computed(() => [
  {
    key: 'status',
    title: 'Status',
    options: [
      { label: 'Unoperated', value: 0 },
      { label: 'Operating', value: 1 },
      { label: 'Fault', value: 3 }
    ]
  },
  {
    key: 'node',
    title: 'Node',
    options: nodeList.value.map(n => ({ label: n.nodeName, value: n.id }))
  },
  {
    key: 'region',
    title: 'Region',
    options: regionList.value.map(r => ({ label: r.regionName, value: r.id }))
  },
  {
    key: 'partner',
    title: 'Partner',
    options: partnerList.value.map(p => ({ label: p.partnerName, value: p.id }))
  },
  {
    key: 'vmType',
    title: 'Machine Type',
    options: vmTypeList.value.map(v => ({ label: v.name, value: v.id }))
  }
])

// Detail / form sheet
const showDetail = ref(false)
const formMode = ref('detail') // 'detail' | 'create' | 'edit'
const detailData = ref({})
const formData = ref({ id: null, innerCode: '', nodeId: null, vmTypeId: null })
const isSubmitting = ref(false)
const nodeIndex = ref(0)
const vmTypeIndex = ref(0)

// Status values (0=Unoperated, 1=Operating, 3=Fault)
const vmStatusLabels = { 0: 'Unoperated', 1: 'Operating', 3: 'Fault' }

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    vmList.value = []
  }
  try {
    loading.value = true
    const res = await listVm(queryParams.value)
    if (res.rows) {
      vmList.value = [...vmList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load machines', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const fetchDropdownData = async () => {
  try {
    const [nodeRes, vmTypeRes, regionRes, partnerRes] = await Promise.all([
      listNode({ pageNum: 1, pageSize: 100 }),
      listVmType({ pageNum: 1, pageSize: 100 }),
      listRegion({ pageNum: 1, pageSize: 100 }),
      listPartner({ pageNum: 1, pageSize: 100 })
    ])
    nodeList.value = nodeRes.rows || []
    vmTypeList.value = vmTypeRes.rows || []
    regionList.value = regionRes.rows || []
    partnerList.value = partnerRes.rows || []
  } catch (error) {
    console.error('Failed to fetch dropdown data', error)
  }
}

onShow(() => {
  fetchUserInfo()
  fetchList(true)
  fetchDropdownData()
})

const loadMore = () => {
  if (vmList.value.length < total.value) {
    queryParams.value.pageNum++
    fetchList()
  }
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
}

const handleSearch = () => {
  showSearch.value = true
}

const handleSearchQuery = () => {}
const handleSearchResult = () => {}

const handleNotification = () => {
  uni.navigateTo({ url: '/pages/notifications/index' })
}

const handleProfile = () => {
  uni.navigateTo({ url: '/pages/mine/index' })
}

const handleTabChange = (tabId) => {
  activeTab.value = tabId
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'machines') {
    uni.redirectTo({ url: routes[tabId] })
  }
}

const handleFilterTab = (value) => {
  activeFilter.value = value
  if (value === 'operating') {
    queryParams.value.vmStatus = 1
  } else if (value === 'unoperated') {
    queryParams.value.vmStatus = 0
  } else if (value === 'fault') {
    queryParams.value.vmStatus = 3
  } else {
    queryParams.value.vmStatus = null
  }
  fetchList(true)
}

const handleMasterFilter = () => {
  showFilterModal.value = true
}

const handleFilterApply = (filters) => {
  selectedFilters.value = filters
  queryParams.value.vmStatus = filters.status?.[0] ?? null
  queryParams.value.nodeId = filters.node?.[0] ?? null
  queryParams.value.regionId = filters.region?.[0] ?? null
  queryParams.value.partnerId = filters.partner?.[0] ?? null
  queryParams.value.vmTypeId = filters.vmType?.[0] ?? null
  showFilterModal.value = false
  fetchList(true)
}

const handleFilterReset = () => {
  selectedFilters.value = {}
  queryParams.value.vmStatus = null
  queryParams.value.nodeId = null
  queryParams.value.regionId = null
  queryParams.value.partnerId = null
  queryParams.value.vmTypeId = null
  showFilterModal.value = false
  fetchList(true)
}

const handleViewDetail = async (item) => {
  try {
    const res = await getVm(item.id)
    detailData.value = {
      id: res.data.id,
      innerCode: res.data.innerCode,
      addr: res.data.addr,
      nodeId: res.data.nodeId,
      nodeName: res.data.node?.nodeName || res.data.nodeName || 'Unknown',
      regionName: res.data.region?.regionName || res.data.regionName || 'Unknown',
      partnerName: res.data.partner?.partnerName || res.data.partnerName || 'None',
      vmTypeId: res.data.vmTypeId,
      vmTypeName: res.data.vmType?.name || res.data.vmTypeName || 'Unknown',
      vmStatus: res.data.vmStatus
    }
    formMode.value = 'detail'
    showDetail.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load machine detail', icon: 'none' })
  }
}

const updateStatus = async (newStatus) => {
  try {
    const full = await getVm(detailData.value.id)
    const payload = { ...full.data, vmStatus: newStatus }
    await updateVm(payload)
    uni.showToast({ title: 'Status updated', icon: 'success' })
    closeDetail()
    fetchList(true)
  } catch (error) {
    uni.showToast({ title: 'Failed to update status', icon: 'none' })
  }
}

const handleAdd = () => {
  formMode.value = 'create'
  formData.value = { id: null, innerCode: '', nodeId: null, vmTypeId: null }
  nodeIndex.value = 0
  vmTypeIndex.value = 0
  showDetail.value = true
}

const handleEditFromDetail = async () => {
  try {
    const res = await getVm(detailData.value.id)
    formData.value = {
      id: res.data.id,
      innerCode: res.data.innerCode,
      nodeId: res.data.nodeId,
      vmTypeId: res.data.vmTypeId
    }
    nodeIndex.value = Math.max(0, nodeList.value.findIndex(n => n.id === res.data.nodeId))
    vmTypeIndex.value = Math.max(0, vmTypeList.value.findIndex(v => v.id === res.data.vmTypeId))
    formMode.value = 'edit'
  } catch (error) {
    uni.showToast({ title: 'Failed to load machine', icon: 'none' })
  }
}

const onNodeChange = (e) => {
  nodeIndex.value = e.detail.value
  formData.value.nodeId = nodeList.value[e.detail.value]?.id ?? null
}

const onVmTypeChange = (e) => {
  vmTypeIndex.value = e.detail.value
  formData.value.vmTypeId = vmTypeList.value[e.detail.value]?.id ?? null
}

const closeDetail = () => {
  showDetail.value = false
  formMode.value = 'detail'
  detailData.value = {}
  formData.value = { id: null, innerCode: '', nodeId: null, vmTypeId: null }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  if (!formData.value.innerCode) {
    uni.showToast({ title: 'Inner Code is required', icon: 'none' })
    return
  }
  if (!formData.value.nodeId) {
    uni.showToast({ title: 'Please select a Node', icon: 'none' })
    return
  }
  if (!formData.value.vmTypeId) {
    uni.showToast({ title: 'Please select a Machine Type', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (formData.value.id) {
      await updateVm(formData.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addVm(formData.value)
      uni.showToast({ title: 'Added successfully', icon: 'success' })
    }
    closeDetail()
    fetchList(true)
  } catch (error) {
    uni.showToast({ title: formData.value.id ? 'Failed to update' : 'Failed to add', icon: 'none' })
  } finally {
    isSubmitting.value = false
  }
}

const getStatusText = (status) => vmStatusLabels[status] || 'Unknown'

const getStatusVariant = (status) => {
  if (status === 1) return 'success'
  if (status === 0) return 'warning'
  if (status === 3) return 'error'
  return 'default'
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

  &:active { opacity: 0.7; }
  &.tab-active { background: $color-primary; }
}

.tab-text {
  @include text-caption;
  white-space: nowrap;
  color: $color-text-primary;
  font-weight: $font-weight-medium;

  .tab-active & { color: white; }
}

.tab-count {
  @include text-label;
  color: $color-text-tertiary;

  .tab-active & { color: rgba(255, 255, 255, 0.8); }
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

  &:active { opacity: 0.7; }
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

.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin-bottom: $spacing-3;
  display: block;
}

.vm-list {
  display: flex;
  flex-direction: column;
}

.vm-card {
  cursor: pointer;
  margin-bottom: $spacing-3;

  &:last-child { margin-bottom: 0; }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $spacing-3;
}

.vm-code {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.vm-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-2;
}

.info-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.info-label {
  @include text-caption;
  color: $color-text-tertiary;
}

.info-value {
  @include text-caption;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
}

.empty-state { padding: $spacing-4 0; }

.detail-view { display: flex; flex-direction: column; }

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;

  &:last-child { border-bottom: none; }
  &:first-child { padding-top: 0; }
}

.detail-label { @include text-caption; color: $color-text-secondary; }
.detail-value { @include text-body; color: $color-text-primary; font-weight: $font-weight-medium; }

.form-view { display: flex; flex-direction: column; gap: $spacing-4; }
.form-group { display: flex; flex-direction: column; gap: $spacing-2; }
.form-label { @include text-caption; color: $color-text-secondary; font-weight: $font-weight-medium; }

.form-input {
  @include text-body;
  color: $color-text-primary;
  padding: $spacing-3;
  background: $color-bg-tertiary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-pill;
  width: 100%;
  box-sizing: border-box;
}

.form-picker {
  @include text-body;
  color: $color-text-primary;
  padding: $spacing-3;
  background: $color-bg-tertiary;
  border: 1px solid $color-border-subtle;
  border-radius: $radius-pill;
  line-height: 1.4;
  box-sizing: border-box;
}

.form-group {
  picker,
  :deep(uni-picker) {
    display: block;
    width: 100%;
    line-height: 0;
    font-size: 0;
    margin: 0;
    padding: 0;
    vertical-align: top;
  }
}
</style>
