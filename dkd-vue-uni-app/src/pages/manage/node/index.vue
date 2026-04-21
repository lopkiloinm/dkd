<template>
  <AppTopBar title="Node Management" :showBack="true" />
  <view class="layout-container">
    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <view class="node-list">
          <Card v-for="item in nodeList" :key="item.id" @click="handleViewDetail(item)" class="node-card">
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
          </Card>

          <EmptyState v-if="nodeList.length === 0 && !loading" message="No nodes found" />
        </view>
      </view>
      </scroll-view>
      <AppBottomBar :active-tab="'machines'" @tab-change="handleTabChange" />
    </view>

    <BottomSheet :visible="showDetailModal" @update:visible="val => !val && closeDetailModal()" @close="closeDetailModal" title="Node Detail">
        <view class="detail-info-row">
          <text class="detail-label">Node Name</text>
          <text class="detail-value">{{ detailData.nodeName }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Region</text>
          <text class="detail-value">{{ detailData.regionName }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Business Type</text>
          <text class="detail-value">{{ getBusinessTypeLabel(detailData.businessType) }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Partner</text>
          <text class="detail-value">{{ detailData.partnerName }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Address</text>
          <text class="detail-value">{{ detailData.address }}</text>
        </view>
        <view class="detail-info-row">
          <text class="detail-label">Device Count</text>
          <text class="detail-value">{{ detailData.vmCount || 0 }}</text>
        </view>
      </BottomSheet>

      <BottomSheet :visible="showModal" @update:visible="val => !val && closeModal()" @close="closeModal" :title="isEdit ? 'Edit Node' : 'Add Node'">
        <Input v-model="form.nodeName" label="Node Name *" placeholder="Enter node name" />
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
          <SheetTextField v-model="form.address" placeholder="Enter address" multiline />
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
import { useI18n } from 'vue-i18n'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import Card from '@/components/ui/Card.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import Input from '@/components/ui/Input.vue'
import Button from '@/components/ui/Button.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { listNode, getNode, addNode, updateNode, delNode } from '@/api/manage/node'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { hasPermission } from '@/utils/permission'
import SheetTextField from '@/components/ui/SheetTextField.vue'

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




.node-list {
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.node-card {
  transition: transform $transition-normal;
}

.node-card:active {
  transform: scale(0.98);
  background-color: $color-bg-elevated;
}

.node-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: $spacing-3;
}

.node-name {
  font-size: 18px;
  font-weight: $font-weight-bold;
  color: $color-text-primary;
  letter-spacing: -0.5px;
}

.device-count {
  font-size: 13px;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;
}

.count-number {
  font-size: 16px;
  font-weight: $font-weight-bold;
  color: $color-primary;
  margin-right: 2px;
}

.node-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}




.form-item {
  margin-bottom: $spacing-4;
}

.form-item:last-child {
  margin-bottom: 0;
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

.card-actions {
  display: flex;
  gap: $spacing-3;
  margin-top: $spacing-4;
  padding-top: $spacing-3;
}

.n-textarea {
  min-height: 88px;
  padding: $spacing-3 $spacing-4;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
  color: $color-text-primary;
  background: $color-bg-secondary;
  border-radius: $radius-lg;
}


</style>
