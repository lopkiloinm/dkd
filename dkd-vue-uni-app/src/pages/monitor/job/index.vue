<template>
  <AppTopBar title="Job Management" :showBack="true" />
  <view class="layout-container">

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="search-bar">
        <input class="n-input search-input" :value="queryParams.jobName" @input="queryParams.jobName = $event.detail.value" placeholder="Search by Job Name" @confirm="handleSearch" />
        <view class="filter-toggle" @click="toggleFilters">
          <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
          <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
        </view>
        <view class="filters-container" :class="{ expanded: filtersExpanded }">
          <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
            <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</view>
          </picker>
        </view>
      </view>
      <view class="job-list">
        <view class="job-card" v-for="item in jobList" :key="item.jobId">
          <view class="job-card-header">
            <text class="job-name">{{ item.jobName }}</text>
            <view class="status-badge" :class="item.status === '0' ? 'status-active' : 'status-inactive'">
              {{ item.status === '0' ? 'Running' : 'Stopped' }}
            </view>
          </view>
          
          <view class="job-info">
            <view class="info-row">
              <text class="info-label">Job Group</text>
              <text class="info-value">{{ item.jobGroup }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Cron</text>
              <text class="info-value">{{ item.cronExpression }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Invoke Target</text>
              <text class="info-value">{{ item.invokeTarget }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Next Time</text>
              <text class="info-value">{{ item.nextValidTime }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handleToggleStatus(item)" v-if="hasPermission('monitor:job:edit')">
              <text class="action-text">{{ item.status === '0' ? 'Stop' : 'Start' }}</text>
            </view>
            <view class="action-btn" @click="handleRun(item)" v-if="hasPermission('monitor:job:edit')">
              <text class="action-text">Run</text>
            </view>
            <view class="action-btn" @click="handleViewLog(item)">
              <text class="action-text">Logs</text>
            </view>
            <view class="action-btn" @click="handleEdit(item)" v-if="hasPermission('monitor:job:edit')">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)" v-if="hasPermission('monitor:job:remove')">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="jobList.length === 0 && !loading">
          <text class="empty-text">No jobs found</text>
        </view>
      </view>
    </scroll-view>

    <view class="fab" @click="handleAdd" v-if="hasPermission('monitor:job:add')">+</view>

    <BottomSheet :visible="showModal" :title="isEdit ? 'Edit Job' : 'New Job'" @update:visible="val => !val && closeModal()" @close="closeModal">
      <view class="form-view">
        <view class="form-group">
          <text class="form-label">Job Name *</text>
          <SheetTextField v-model="form.jobName" placeholder="Job name" />
        </view>
        <view class="form-group">
          <text class="form-label">Job Group</text>
          <SheetTextField v-model="form.jobGroup" placeholder="DEFAULT" />
        </view>
        <view class="form-group">
          <text class="form-label">Invoke Target *</text>
          <SheetTextField v-model="form.invokeTarget" placeholder="e.g. ryTask.ryParams('ry')" />
        </view>
        <view class="form-group">
          <text class="form-label">Cron Expression *</text>
          <SheetTextField v-model="form.cronExpression" placeholder="0/10 * * * * ?" />
        </view>
      </view>
      <template #header-actions>
        <view class="action-pill" @click="closeModal"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--primary" @click="submitForm"><text class="action-pill-text">Save</text></view>
      </template>
    </BottomSheet>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import { listJob, getJob, addJob, updateJob, delJob, runJob, changeJobStatus } from '@/api/monitor/job'
import { hasPermission } from '@/utils/permission'
import SheetTextField from '@/components/ui/SheetTextField.vue'

const jobList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const showModal = ref(false)
const isEdit = ref(false)
const form = ref({
  jobName: '',
  jobGroup: 'DEFAULT',
  invokeTarget: '',
  cronExpression: '',
  misfirePolicy: '1',
  concurrent: '1',
  status: '1'
})

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  jobName: '',
  status: null
})
const total = ref(0)
const filtersExpanded = ref(false)

const statusOptions = ['All Status', 'Running', 'Stopped']
const filterStatusIndex = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    jobList.value = []
  }
  try {
    loading.value = true
    const res = await listJob(queryParams.value)
    if (res.rows) {
      jobList.value = [...jobList.value, ...res.rows]
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

const onFilterStatusChange = (e) => {
  filterStatusIndex.value = e.detail.value
  queryParams.value.status = e.detail.value === 0 ? null : (e.detail.value === 1 ? '0' : '1')
  handleSearch()
}

const handleToggleStatus = (item) => {
  const newStatus = item.status === '0' ? '1' : '0'
  const text = newStatus === '0' ? 'start' : 'stop'
  uni.showModal({
    title: 'Confirm',
    content: `Are you sure you want to ${text} "${item.jobName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await changeJobStatus(item.jobId, newStatus)
          uni.showToast({ title: 'Status updated successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to update status', icon: 'none' })
        }
      }
    }
  })
}

const handleRun = (item) => {
  uni.showModal({
    title: 'Confirm Run',
    content: `Are you sure you want to run "${item.jobName}" now?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await runJob(item.jobId, item.jobGroup)
          uni.showToast({ title: 'Job started successfully', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: 'Failed to start job', icon: 'none' })
        }
      }
    }
  })
}

const handleViewLog = (item) => {
  uni.navigateTo({
    url: `/pages/monitor/jobLog/index?jobId=${item.jobId}&jobName=${item.jobName}`
  })
}

const handleEdit = async (item) => {
  try {
    const res = await getJob(item.jobId)
    form.value = { ...res.data }
    isEdit.value = true
    showModal.value = true
  } catch (e) {
    uni.showToast({ title: 'Failed to load job', icon: 'none' })
  }
}

const handleAdd = () => {
  form.value = {
    jobName: '',
    jobGroup: 'DEFAULT',
    invokeTarget: '',
    cronExpression: '',
    misfirePolicy: '1',
    concurrent: '1',
    status: '1'
  }
  isEdit.value = false
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
}

const submitForm = async () => {
  if (!form.value.jobName || !form.value.invokeTarget || !form.value.cronExpression) {
    uni.showToast({ title: 'Name, target & cron required', icon: 'none' })
    return
  }
  try {
    if (isEdit.value) {
      await updateJob(form.value)
      uni.showToast({ title: 'Job updated', icon: 'success' })
    } else {
      await addJob(form.value)
      uni.showToast({ title: 'Job created', icon: 'success' })
    }
    closeModal()
    fetchList(true)
  } catch (e) {
    console.error(e)
  }
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.jobName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delJob(item.jobId)
          uni.showToast({ title: 'Deleted successfully', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to delete', icon: 'none' })
        }
      }
    }
  })
}

const loadMore = () => {
  if (jobList.value.length < total.value) {
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


.job-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.job-card {
  @include glass-panel;
  padding: 20px;
}

.job-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.job-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.status-active {
  background-color: rgba(52, 199, 89, 0.15);
  color: $color-success;
}

.status-inactive {
  background-color: rgba(255, 59, 48, 0.15);
  color: $color-error;
}

.job-info {
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
  gap: 8px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid $apple-glass-border;
}

.action-btn {
  flex: 1;
  padding: 10px 8px;
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
  font-size: 13px;
  font-weight: 600;
  color: $color-primary;
}

.action-btn.delete .action-text {
  color: $color-error;
}

.fab {
  position: fixed;
  right: $spacing-4;
  bottom: calc($bottom-bar-height + $spacing-4 + env(safe-area-inset-bottom, 0px));
  width: 56px;
  height: 56px;
  border-radius: 50%;
  background: $color-primary;
  color: white;
  font-size: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(61, 139, 255, 0.4);
  z-index: 100;
}

.form-input {
  @include text-body; color: $color-text-primary; padding: $spacing-3;
  background: $color-bg-tertiary; border: 1px solid $color-border-subtle;
  border-radius: $radius-pill; width: 100%; box-sizing: border-box;
}
</style>
