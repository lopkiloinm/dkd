<template>
  <view class="page">
    <view class="top-bar">
      <view class="top-bar-back" @click="goBack">
        <text class="back-caret">‹</text>
        <text class="back-text">Back</text>
      </view>
      <text class="top-bar-title">Node Management</text>
    </view>
    <view class="layout-container">
      <view class="search-bar">
        <input class="n-input search-input" v-model="queryParams.nodeName" placeholder="Search by Node Name" @confirm="handleSearch" />
        <picker mode="selector" :range="regionList" range-key="regionName" :value="filterRegionIndex" @change="onFilterRegionChange">
          <view class="filter-picker">{{ queryParams.regionId ? regionList[filterRegionIndex]?.regionName : 'All Regions' }}</view>
        </picker>
      </view>

      <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
        <view class="node-list">
          <view class="node-card" v-for="item in nodeList" :key="item.id" @click="handleViewDetail(item)">
            <view class="node-card-header">
              <text class="node-name">{{ item.nodeName }}</text>
              <view class="device-count">
                <text class="count-number">{{ item.vmCount || 0 }}</text> Devices
              </view>
            </view>

            <view class="node-info">
              <view class="info-row">
                <text class="info-label">Region</text>
                <text class="info-value">{{ item.region?.regionName || 'Unknown' }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Business Type</text>
                <text class="info-value">{{ getBusinessTypeLabel(item.businessType) }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Partner</text>
                <text class="info-value">{{ item.partner?.partnerName || 'Unknown' }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Address</text>
                <text class="info-value">{{ item.address || 'N/A' }}</text>
              </view>
            </view>

            <view class="card-actions">
              <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('manage:node:edit')">
                <text class="action-text">Edit</text>
              </view>
              <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('manage:node:remove')">
                <text class="action-text">Delete</text>
              </view>
            </view>
          </view>

          <view class="empty-state" v-if="nodeList.length === 0 && !loading">
            <text class="empty-text">No nodes found</text>
          </view>
        </view>
      </scroll-view>

      <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
        <view class="modal-content detail-modal" @click.stop>
          <view class="modal-header">
            <text class="modal-title">Node Detail</text>
            <text class="modal-close" @click="closeDetailModal">×</text>
          </view>
          <view class="modal-body">
            <view class="detail-info-row">
              <text class="detail-label">Node Name:</text>
              <text class="detail-value">{{ detailData.nodeName }}</text>
            </view>
            <view class="detail-info-row">
              <text class="detail-label">Region:</text>
              <text class="detail-value">{{ detailData.regionName }}</text>
            </view>
            <view class="detail-info-row">
              <text class="detail-label">Business Type:</text>
              <text class="detail-value">{{ getBusinessTypeLabel(detailData.businessType) }}</text>
            </view>
            <view class="detail-info-row">
              <text class="detail-label">Partner:</text>
              <text class="detail-value">{{ detailData.partnerName }}</text>
            </view>
            <view class="detail-info-row">
              <text class="detail-label">Address:</text>
              <text class="detail-value">{{ detailData.address }}</text>
            </view>
            <view class="detail-info-row">
              <text class="detail-label">Device Count:</text>
              <text class="detail-value">{{ detailData.vmCount || 0 }}</text>
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
            <text class="modal-title">{{ isEdit ? 'Edit Node' : 'Add Node' }}</text>
            <text class="modal-close" @click="closeModal">×</text>
          </view>
          <view class="modal-body">
            <view class="form-item">
              <text class="form-label">Node Name *</text>
              <input class="n-input" v-model="form.nodeName" placeholder="Enter node name" />
            </view>
            <view class="form-item">
              <text class="form-label">Region *</text>
              <picker mode="selector" :range="regionList" range-key="regionName" :value="regionIndex" @change="onRegionChange">
                <view class="picker-input">{{ form.regionId ? regionList[regionIndex]?.regionName : 'Select Region' }}</view>
              </picker>
            </view>
            <view class="form-item">
              <text class="form-label">Business Type *</text>
              <picker mode="selector" :range="businessTypes" :value="businessTypeIndex" @change="onBusinessTypeChange">
                <view class="picker-input">{{ form.businessType ? businessTypes[businessTypeIndex] : 'Select Business Type' }}</view>
              </picker>
            </view>
            <view class="form-item">
              <text class="form-label">Partner *</text>
              <picker mode="selector" :range="partnerList" range-key="partnerName" :value="partnerIndex" @change="onPartnerChange">
                <view class="picker-input">{{ form.partnerId ? partnerList[partnerIndex]?.partnerName : 'Select Partner' }}</view>
              </picker>
            </view>
            <view class="form-item">
              <text class="form-label">Address *</text>
              <textarea class="n-textarea" v-model="form.address" placeholder="Enter address" />
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
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useI18n } from 'vue-i18n'

const goBack = () => {
  uni.navigateBack()
}
import { listNode, getNode, addNode, updateNode, delNode } from '@/api/manage/node'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { hasPermission } from '@/utils/permission'

const { t } = useI18n()

const nodeList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)
const showDetailModal = ref(false)
const detailData = ref({
  nodeName: '',
  regionName: '',
  businessType: '',
  partnerName: '',
  address: '',
  vmCount: 0
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  nodeName: '',
  regionId: null
})
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  nodeName: '',
  regionId: '',
  businessType: '',
  partnerId: '',
  address: ''
})

const regionList = ref([])
const partnerList = ref([])
const regionIndex = ref(0)
const partnerIndex = ref(0)
const businessTypeIndex = ref(0)
const filterRegionIndex = ref(0)
const businessTypes = ['Tourist Area', 'Shopping Mall/Office', 'School', 'Factory', 'Other']

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    nodeList.value = []
  }
  try {
    loading.value = true
    const res = await listNode(queryParams.value)
    if (res.rows) {
      nodeList.value = [...nodeList.value, ...res.rows]
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
    const [regionRes, partnerRes] = await Promise.all([
      listRegion({ pageNum: 1, pageSize: 100 }),
      listPartner({ pageNum: 1, pageSize: 100 })
    ])
    regionList.value = regionRes.rows || []
    partnerList.value = partnerRes.rows || []
  } catch (error) {
    console.error('Failed to fetch dropdown data', error)
  }
}

const handleSearch = () => {
  fetchList(true)
}

const handleAdd = () => {
  isEdit.value = false
  form.value = { id: null, nodeName: '', regionId: null, businessType: null, partnerId: null, address: '' }
  regionIndex.value = 0
  partnerIndex.value = 0
  businessTypeIndex.value = 0
  showModal.value = true
}

const handleEdit = async (item) => {
  try {
    const res = await getNode(item.id)
    form.value = res.data
    isEdit.value = true
    
    regionIndex.value = regionList.value.findIndex(r => r.id === form.value.regionId)
    partnerIndex.value = partnerList.value.findIndex(p => p.id === form.value.partnerId)
    businessTypeIndex.value = form.value.businessType - 1
    
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load node data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.nodeName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delNode(item.id)
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

const onFilterRegionChange = (e) => {
  filterRegionIndex.value = e.detail.value
  queryParams.value.regionId = regionList.value[e.detail.value]?.id || null
  handleSearch()
}

const onPartnerChange = (e) => {
  partnerIndex.value = e.detail.value
  form.value.partnerId = partnerList.value[e.detail.value].id
}

const onBusinessTypeChange = (e) => {
  businessTypeIndex.value = e.detail.value
  form.value.businessType = e.detail.value + 1
}

const closeModal = () => {
  showModal.value = false
  form.value = { id: null, nodeName: '', regionId: null, businessType: null, partnerId: null, address: '' }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.nodeName) {
    uni.showToast({ title: 'Node Name is required', icon: 'none' })
    return
  }
  if (!form.value.regionId) {
    uni.showToast({ title: 'Please select a Region', icon: 'none' })
    return
  }
  if (!form.value.businessType) {
    uni.showToast({ title: 'Please select a Business Type', icon: 'none' })
    return
  }
  if (!form.value.partnerId) {
    uni.showToast({ title: 'Please select a Partner', icon: 'none' })
    return
  }
  if (!form.value.address) {
    uni.showToast({ title: 'Address is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updateNode(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addNode(form.value)
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

const getBusinessTypeLabel = (type) => {
  if (!type) return 'N/A'
  return t(`node.businessTypes.${type}`) || type
}

const loadMore = () => {
  if (nodeList.value.length < total.value) {
    queryParams.value.pageNum++
    fetchList()
  }
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
}

const handleViewDetail = async (item) => {
  try {
    const res = await getNode(item.id)
    detailData.value = {
      nodeName: res.data.nodeName,
      regionName: res.data.region?.regionName || 'Unknown',
      businessType: res.data.businessType,
      partnerName: res.data.partner?.partnerName || 'Unknown',
      address: res.data.address,
      vmCount: res.data.vmCount || 0
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load node detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { nodeName: '', regionName: '', businessType: '', partnerName: '', address: '', vmCount: 0 }
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

.page {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.top-bar {
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

.top-bar-back {
  position: absolute;
  left: 16px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.back-caret {
  font-size: 24px;
  color: #007aff;
  line-height: 1;
  font-weight: 300;
}

.back-text {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  font-size: 17px;
  color: #007aff;
  font-weight: 500;
  letter-spacing: -0.3px;
}

.top-bar-title {
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  font-size: 17px;
  font-weight: 600;
  color: #1d1d1f;
  letter-spacing: -0.4px;
}

.layout-container {
  display: flex;
  flex-direction: column;
  flex: 1;
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
}

.filter-picker {
  @include glass-input;
  height: 44px;
  line-height: 44px;
  padding: 0 16px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.node-list {
  padding: 0 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.node-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.node-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.node-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.node-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.device-count {
  font-size: 13px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.count-number {
  font-size: 16px;
  color: $apple-blue;
  font-weight: 700;
}

.node-info {
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

.n-textarea {
  @include glass-input;
  width: 100%;
  min-height: 100px;
  padding: 12px 16px;
  font-size: 16px;
  border-radius: 12px;
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
