<template>
  <wd-navbar title="Partner Management" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.partnerName" placeholder="Search by Partner Name" @confirm="handleSearch" />
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="partner-list">
        <view class="partner-card" v-for="item in partnerList" :key="item.id">
          <view class="partner-card-header">
            <text class="partner-name">{{ item.partnerName }}</text>
            <view class="node-count">
              <text class="count-number">{{ item.nodeCount || 0 }}</text> Nodes
            </view>
          </view>
          
          <view class="partner-info">
            <view class="info-row">
              <text class="info-label">Contact</text>
              <text class="info-value">{{ item.contactPerson || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Phone</text>
              <text class="info-value">{{ item.contactPhone || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Account</text>
              <text class="info-value">{{ item.account || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Profit Ratio</text>
              <text class="info-value">{{ item.profitRatio || 0 }}%</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handleResetPwd(item)" v-if="hasPermission('manage:partner:edit')">
              <text class="action-text">Reset Pwd</text>
            </view>
            <view class="action-btn" @click="handleViewDetail(item)">
              <text class="action-text">View</text>
            </view>
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('manage:partner:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('manage:partner:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="partnerList.length === 0 && !loading">
          <text class="empty-text">No partners found</text>
        </view>
      </view>
    </scroll-view>

    <view class="modal-overlay" v-if="showModal" @click="closeModal">
      <view class="modal-content" @click.stop>
        <view class="modal-header">
          <text class="modal-title">{{ isEdit ? 'Edit Partner' : 'Add Partner' }}</text>
          <text class="modal-close" @click="closeModal">×</text>
        </view>
        <view class="modal-body">
          <view class="form-item">
            <text class="form-label">Partner Name *</text>
            <input class="n-input" v-model="form.partnerName" placeholder="Enter partner name" />
          </view>
          <view class="form-item">
            <text class="form-label">Contact Person *</text>
            <input class="n-input" v-model="form.contactPerson" placeholder="Enter contact person" />
          </view>
          <view class="form-item">
            <text class="form-label">Contact Phone *</text>
            <input class="n-input" v-model="form.contactPhone" placeholder="Enter contact phone" />
          </view>
          <view class="form-item">
            <text class="form-label">Profit Ratio (%) *</text>
            <input class="n-input" v-model="form.profitRatio" type="number" placeholder="Enter profit ratio" />
          </view>
          <view class="form-item" v-if="!isEdit">
            <text class="form-label">Account *</text>
            <input class="n-input" v-model="form.account" placeholder="Enter account" />
          </view>
          <view class="form-item" v-if="!isEdit">
            <text class="form-label">Password *</text>
            <input class="n-input" v-model="form.password" type="password" placeholder="Enter password" />
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

    <view class="modal-overlay" v-if="showDetailModal" @click="closeDetailModal">
      <view class="modal-content detail-modal" @click.stop>
        <view class="modal-header">
          <text class="modal-title">Partner Detail</text>
          <text class="modal-close" @click="closeDetailModal">×</text>
        </view>
        <view class="modal-body">
          <view class="detail-info-row">
            <text class="detail-label">Partner Name:</text>
            <text class="detail-value">{{ detailData.partnerName }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Contact Person:</text>
            <text class="detail-value">{{ detailData.contactPerson }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Contact Phone:</text>
            <text class="detail-value">{{ detailData.contactPhone }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Profit Ratio:</text>
            <text class="detail-value">{{ detailData.profitRatio }}%</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Account:</text>
            <text class="detail-value">{{ detailData.account }}</text>
          </view>
          <view class="detail-info-row">
            <text class="detail-label">Created:</text>
            <text class="detail-value">{{ detailData.createTime }}</text>
          </view>
        </view>
        <view class="modal-footer">
          <view class="modal-btn cancel" @click="closeDetailModal">
            <text>Close</text>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listPartner, getPartner, addPartner, updatePartner, delPartner, resetPartnerPwd } from '@/api/manage/partner'
import { hasPermission } from '@/utils/permission'

const partnerList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  partnerName: ''
})
const total = ref(0)

const showModal = ref(false)
const isEdit = ref(false)
const isSubmitting = ref(false)
const form = ref({
  id: null,
  partnerName: '',
  contactPerson: '',
  contactPhone: '',
  profitRatio: '',
  account: '',
  password: ''
})

const showDetailModal = ref(false)
const detailData = ref({
  partnerName: '',
  contactPerson: '',
  contactPhone: '',
  profitRatio: '',
  account: '',
  createTime: ''
})

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    partnerList.value = []
  }
  try {
    loading.value = true
    const res = await listPartner(queryParams.value)
    if (res.rows) {
      partnerList.value = [...partnerList.value, ...res.rows]
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

const handleAdd = () => {
  isEdit.value = false
  form.value = { id: null, partnerName: '', contactPerson: '', contactPhone: '', profitRatio: '', account: '', password: '' }
  showModal.value = true
}

const handleViewDetail = async (item) => {
  try {
    const res = await getPartner(item.id)
    detailData.value = {
      partnerName: res.data.partnerName,
      contactPerson: res.data.contactPerson,
      contactPhone: res.data.contactPhone,
      profitRatio: res.data.profitRatio,
      account: res.data.account,
      createTime: res.data.createTime
    }
    showDetailModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load partner detail', icon: 'none' })
  }
}

const closeDetailModal = () => {
  showDetailModal.value = false
  detailData.value = { partnerName: '', contactPerson: '', contactPhone: '', profitRatio: '', account: '', createTime: '' }
}

const handleResetPwd = (item) => {
  uni.showModal({
    title: 'Confirm Reset',
    content: `Are you sure you want to reset the password for ${item.partnerName}?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await resetPartnerPwd(item.id)
          uni.showToast({ title: 'Password reset successfully', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: 'Failed to reset password', icon: 'none' })
        }
      }
    }
  })
}

const handleEdit = async (item) => {
  try {
    const res = await getPartner(item.id)
    form.value = res.data
    isEdit.value = true
    showModal.value = true
  } catch (error) {
    uni.showToast({ title: 'Failed to load partner data', icon: 'none' })
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.partnerName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delPartner(item.id)
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
  form.value = { id: null, partnerName: '', contactPerson: '', contactPhone: '', profitRatio: '', account: '', password: '' }
}

const submitForm = async () => {
  if (isSubmitting.value) return
  
  // Validation rules matching webapp
  if (!form.value.partnerName) {
    uni.showToast({ title: 'Partner Name is required', icon: 'none' })
    return
  }
  if (!form.value.contactPerson) {
    uni.showToast({ title: 'Contact Person is required', icon: 'none' })
    return
  }
  if (!form.value.contactPhone) {
    uni.showToast({ title: 'Contact Phone is required', icon: 'none' })
    return
  }
  if (!form.value.profitRatio) {
    uni.showToast({ title: 'Profit Ratio is required', icon: 'none' })
    return
  }
  if (!isEdit.value && !form.value.account) {
    uni.showToast({ title: 'Account is required', icon: 'none' })
    return
  }
  if (!isEdit.value && !form.value.password) {
    uni.showToast({ title: 'Password is required', icon: 'none' })
    return
  }

  isSubmitting.value = true
  try {
    if (isEdit.value) {
      await updatePartner(form.value)
      uni.showToast({ title: 'Updated successfully', icon: 'success' })
    } else {
      await addPartner(form.value)
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
  if (partnerList.value.length < total.value) {
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
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.partner-list {
  padding: 0 16px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.partner-card {
  @include glass-panel;
  padding: 20px;
  transition: transform 0.2s ease;
}

.partner-card:active {
  transform: scale(0.98);
  background-color: rgba(255, 255, 255, 0.8);
}

.partner-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.partner-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.node-count {
  font-size: 13px;
  color: $apple-text-secondary;
  font-weight: 500;
}

.count-number {
  font-size: 16px;
  color: $apple-blue;
  font-weight: 700;
}

.partner-info {
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
