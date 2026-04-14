<template>
  <wd-navbar title="Device Management" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.innerCode" placeholder="Search by Inner Code" @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </view>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="nodeList" range-key="nodeName" :value="filterNodeIndex" @change="onFilterNodeChange">
          <view class="filter-picker">{{ queryParams.nodeId ? nodeList[filterNodeIndex]?.nodeName : 'All Nodes' }}</view>
        </picker>
        <picker mode="selector" :range="regionList" range-key="regionName" :value="filterRegionIndex" @change="onFilterRegionChange">
          <view class="filter-picker">{{ queryParams.regionId ? regionList[filterRegionIndex]?.regionName : 'All Regions' }}</view>
        </picker>
        <picker mode="selector" :range="partnerList" range-key="partnerName" :value="filterPartnerIndex" @change="onFilterPartnerChange">
          <view class="filter-picker">{{ queryParams.partnerId ? partnerList[filterPartnerIndex]?.partnerName : 'All Partners' }}</view>
        </picker>
        <picker mode="selector" :range="vmTypeList" range-key="typeName" :value="filterVmTypeIndex" @change="onFilterVmTypeChange">
          <view class="filter-picker">{{ queryParams.vmTypeId ? vmTypeList[filterVmTypeIndex]?.typeName : 'All VM Types' }}</view>
        </picker>
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
        </picker>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="vm-list">
        <view class="vm-card" v-for="item in vmList" :key="item.id" @click="handleViewDetail(item)">
          <view class="vm-card-header">
            <text class="vm-code">{{ item.innerCode }}</text>
            <view class="status-badge" :class="'status-' + item.vmStatus">
              {{ getStatusText(item.vmStatus) }}
            </view>
          </view>
          
          <view class="vm-info">
            <view class="info-row">
              <text class="info-label">Address</text>
              <text class="info-value">{{ item.addr || 'Unknown' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Model</text>
              <text class="info-value">{{ item.vmTypeId || 'Unknown' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Partner ID</text>
              <text class="info-value">{{ item.partnerId || 'N/A' }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('manage:vm:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('manage:vm:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="vmList.length === 0 && !loading">
          <text class="empty-text">No devices found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Device Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-info-row">
            <text class="detail-label">Device Code:</text>
            <text class="detail-value">{{ detailData.innerCode }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Address:</text>
            <text class="detail-value">{{ detailData.addr }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Node:</text>
            <text class="detail-value">{{ detailData.nodeName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Region:</text>
            <text class="detail-value">{{ detailData.regionName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Partner:</text>
            <text class="detail-value">{{ detailData.partnerName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">VM Type:</text>
            <text class="detail-value">{{ detailData.vmTypeName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Status:</text>
            <text class="detail-value">{{ getStatusText(detailData.vmStatus) }}</text>
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
          <text class="modal-title">{{ isEdit ? 'Edit Device' : 'Add Device' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">Device Code *</text>
            <input class="n-input" v-model="form.innerCode" placeholder="Enter device code" />
          </view>
          <view class="form-item">
            <text class="form-label">Node *</text>
            <picker mode="selector" :range="nodeList" range-key="nodeName" :value="nodeIndex" @change="onNodeChange">
              <view class="picker-input">{{ form.nodeId ? nodeList[nodeIndex]?.nodeName : 'Select Node' }}</view>
            </picker>
          </view>
          <view class="form-item">
            <text class="form-label">VM Type *</text>
            <picker mode="selector" :range="vmTypeList" range-key="name" :value="vmTypeIndex" @change="onVmTypeChange">
              <view class="picker-input">{{ form.vmTypeId ? vmTypeList[vmTypeIndex]?.name : 'Select VM Type' }}</view>
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
import { listVm, getVm, addVm, updateVm, delVm } from '@/api/manage/vm'
import { listNode } from '@/api/manage/node'
import { listVmType } from '@/api/manage/vmType'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { hasPermission } from '@/utils/permission'

const vmList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  innerCode: '',
  addr: '',
  nodeName: '',
  regionName: '',
  partnerName: '',
  vmTypeName: '',
  vmStatus: ''
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  innerCode: '',
  nodeId: null,
  regionId: null,
  partnerId: null,
  vmTypeId: null,
  vmStatus: null,
  policyId: ''
})
const total = ref(0)
const filtersExpanded = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  innerCode: '',
  nodeId: '',
  vmTypeId: ''
})

const nodeList = ref([])
const vmTypeList = ref([])
const regionList = ref([])
const partnerList = ref([])
const nodeIndex = ref(0)
const vmTypeIndex = ref(0)
const filterNodeIndex = ref(0)
const filterRegionIndex = ref(0)
const filterPartnerIndex = ref(0)
const filterVmTypeIndex = ref(0)
const filterVmStatusIndex = ref(0)
const vmStatusOptions = ['All Status', 'Unoperated', 'Operating', 'Fault']

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

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

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

const getStatusText = (status) => {
  if (status === 0) return 'Unoperated'
  if (status === 1) return 'Operating'
  if (status === 3) return 'Fault'
  return 'Unknown'
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { id: null, innerCode: '', nodeId: null, vmTypeId: null }
  nodeIndex.value = 0
  vmTypeIndex.value = 0
  showModal.value = true
}

const handleEdit = async (item) => {
  try {
    const res = await getVm(item.id)
    form.value = res.data
    isEdit.value = true
    
    nodeIndex.value = nodeList.value.findIndex(n => n.id === form.value.nodeId)
    vmTypeIndex.value = vmTypeList.value.findIndex(v => v.id === form.value.vmTypeId)
    
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load device data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.innerCode}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delVm(item.id)
          uni.showToast({ title: 'Deleted successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to delete', icon: 'none' })
        }
      }
    }
  })
}

const onNodeChange = (e) => {
  nodeIndex.value = e.detail.value
  form.value.nodeId = nodeList.value[e.detail.value].id
}

const onVmTypeChange = (e) => {
  vmTypeIndex.value = e.detail.value
  form.value.vmTypeId = vmTypeList.value[e.detail.value].id
}

const onFilterNodeChange = (e) => {
  filterNodeIndex.value = e.detail.value
  queryParams.value.nodeId = nodeList.value[e.detail.value]?.id || null
  handleSearch()
}

const onFilterRegionChange = (e) => {
  filterRegionIndex.value = e.detail.value
  queryParams.value.regionId = regionList.value[e.detail.value]?.id || null
  handleSearch()
}

const onFilterPartnerChange = (e) => {
  filterPartnerIndex.value = e.detail.value
  queryParams.value.partnerId = partnerList.value[e.detail.value]?.id || null
  handleSearch()
}

const onFilterVmTypeChange = (e) => {
  filterVmTypeIndex.value = e.detail.value
  queryParams.value.vmTypeId = vmTypeList.value[e.detail.value]?.id || null
  handleSearch()
}

const onFilterVmStatusChange = (e) => {
  filterVmStatusIndex.value = e.detail.value
  queryParams.value.vmStatus = e.detail.value === 0 ? null : e.detail.value
  handleSearch()
}

const handleViewDetail = async (item) => {
  try {
    const res = await getVm(item.id)
    detailData.value = {
      innerCode: res.data.innerCode,
      addr: res.data.addr,
      nodeName: res.data.node?.nodeName || 'Unknown',
      regionName: res.data.region?.regionName || 'Unknown',
      partnerName: res.data.partner?.partnerName || 'Unknown',
      vmTypeName: res.data.vmType?.name || 'Unknown',
      vmStatus: res.data.vmStatus
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load device detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { innerCode: '', addr: '', nodeName: '', regionName: '', partnerName: '', vmTypeName: '', vmStatus: '' }
}

const closeModal = () => {
  showModal.value = false
  form.value = { id: null, innerCode: '', nodeId: null, vmTypeId: null }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.innerCode) {
    uni.showToast({ title: 'Device Code is required', icon: 'none' })
    return
  }
  if (!form.value.nodeId) {
    uni.showToast({ title: 'Please select a Node', icon: 'none' })
    return
  }
  if (!form.value.vmTypeId) {
    uni.showToast({ title: 'Please select a VM Type', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateVm(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addVm(form.value)
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
  max-height: 300px;
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

.vm-list {
  padding: 0 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.vm-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.vm-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.vm-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.vm-code {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.status-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.status-0 {
  background-color: rgba(255, 149, 0, 0.15);
  color: #ff9500;
}

.status-1 {
  background-color: rgba(52, 199, 89, 0.15);
  color: #34c759;
}

.status-3 {
  background-color: rgba(255, 59, 48, 0.15);
  color: #ff3b30;
}

.vm-info {
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
