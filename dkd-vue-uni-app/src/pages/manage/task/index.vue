<template>
  <AppTopBar
    :unread-count="unreadCount"
    :profile-picture="profilePicture"
    :user-name="userName"
    @search="handleSearch"
    @notification="handleNotification"
  />
  <view class="layout-container layout-container--chrome-filter layout-container--bottom-tabs">
    <view class="filter-tabs chrome-filter-tabs">
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

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <!-- Quick Actions -->
        <view class="quick-actions">
          <text class="section-title">Quick Actions</text>
          <Grid :columns="4" :gap="16">
            <view class="quick-action-tile" @click="handleAdd">
              <view class="icon-tile icon-tile--primary">
                <Icon name="add" size="20" color="currentColor" />
              </view>
              <text class="quick-action-label">Create</text>
            </view>
            <view class="quick-action-tile" @click="handleAssignAll">
              <view class="icon-tile icon-tile--secondary">
                <Icon name="partner" size="20" color="currentColor" />
              </view>
              <text class="quick-action-label">Assign</text>
            </view>
            <view class="quick-action-tile" @click="handleCompleteAll">
              <view class="icon-tile icon-tile--success">
                <Icon name="check" size="20" color="currentColor" />
              </view>
              <text class="quick-action-label">Done</text>
            </view>
            <view class="quick-action-tile" @click="handleExport">
              <view class="icon-tile icon-tile--neutral">
                <Icon name="document" size="20" color="currentColor" />
              </view>
              <text class="quick-action-label">Export</text>
            </view>
          </Grid>
        </view>

        <!-- Task List -->
        <text class="section-title">Task List</text>
        <view class="task-list">
          <view v-if="taskList.length === 0 && !loading" class="empty-state">
            <EmptyState title="No tasks found" description="Try adjusting your filters or create a new task" />
          </view>
          <Card v-for="item in taskList" :key="item.taskId" class="task-card" @click="handleViewDetail(item)">
            <view class="card-header">
              <text class="task-code">{{ item.taskCode }}</text>
              <Badge :variant="getTaskStatusVariant(item.taskStatus)">{{ getTaskStatusText(item.taskStatus) }}</Badge>
            </view>
            <view class="task-info">
              <view class="info-row">
                <text class="info-label">Type</text>
                <text class="info-value">{{ getTaskTypeText(item.productTypeId) }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Machine</text>
                <text class="info-value">{{ item.innerCode }}</text>
              </view>
              <view class="info-row">
                <text class="info-label">Operator</text>
                <text class="info-value">{{ item.userName || 'Unassigned' }}</text>
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
    title="Filter Tasks"
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
    :title="formMode === 'detail' ? 'Task Details' : (formData.taskId ? 'Edit Task' : 'New Task')"
    @update:visible="val => !val && closeDetail()"
    @close="closeDetail"
  >
    <view v-if="formMode === 'detail'" class="detail-view">
      <view class="detail-row">
        <text class="detail-label">Code</text>
        <text class="detail-value">{{ detailData.taskCode }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Status</text>
        <Badge :variant="getTaskStatusVariant(detailData.taskStatus)">{{ getTaskStatusText(detailData.taskStatus) }}</Badge>
      </view>
      <view class="detail-row">
        <text class="detail-label">Type</text>
        <text class="detail-value">{{ getTaskTypeText(detailData.productTypeId) }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Machine</text>
        <text class="detail-value">{{ detailData.innerCode }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Operator</text>
        <text class="detail-value">{{ detailData.userName || 'Unassigned' }}</text>
      </view>
      <view class="detail-row">
        <text class="detail-label">Address</text>
        <text class="detail-value">{{ detailData.addr || 'N/A' }}</text>
      </view>
      <view class="detail-row detail-row-column">
        <text class="detail-label">Description</text>
        <text class="detail-value detail-desc">{{ detailData.desc || 'No description' }}</text>
      </view>
    </view>
    <view v-else class="form-view">
      <view class="form-group">
        <text class="form-label">Task Type *</text>
        <picker mode="selector" :range="typeOptions" range-key="label" :value="typeIndex" @change="onTypeChange">
          <view class="form-picker">{{ typeOptions[typeIndex]?.label || 'Select type' }}</view>
        </picker>
      </view>
      <view class="form-group">
        <text class="form-label">Machine Code *</text>
        <SheetTextField v-model="formData.innerCode" placeholder="Enter machine inner code" />
      </view>
      <view class="form-group">
        <text class="form-label">Assignee</text>
        <SheetTextField v-model="formData.userName" placeholder="Operator name" />
      </view>
      <view class="form-group">
        <text class="form-label">Address</text>
        <SheetTextField v-model="formData.addr" placeholder="Machine location" />
      </view>
      <view class="form-group">
        <text class="form-label">Description</text>
        <SheetTextField v-model="formData.desc" placeholder="Task description" multiline />
      </view>
    </view>

    <template #header-actions>
      <template v-if="formMode === 'detail'">
        <view class="action-pill" @click="startEdit"><text class="action-pill-text">Edit</text></view>
        <view v-if="detailData.taskStatus === 1" class="action-pill action-pill--primary" @click="confirmAccept"><text class="action-pill-text">Accept</text></view>
        <view v-if="detailData.taskStatus === 2" class="action-pill action-pill--success" @click="confirmComplete"><text class="action-pill-text">Complete</text></view>
        <view v-if="detailData.taskStatus === 1 || detailData.taskStatus === 2" class="action-pill action-pill--danger" @click="confirmReject"><text class="action-pill-text">Reject</text></view>
      </template>
      <template v-else>
        <view class="action-pill" @click="closeDetail"><text class="action-pill-text">Cancel</text></view>
        <view class="action-pill action-pill--primary" @click="saveTask"><text class="action-pill-text">Save</text></view>
      </template>
    </template>
  </BottomSheet>
</template>

<script setup>
import { ref, computed, reactive } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import FilterModal from '@/components/app/FilterModal.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Button from '@/components/ui/Button.vue'
import Badge from '@/components/ui/Badge.vue'
import Grid from '@/components/ui/Grid.vue'
import Icon from '@/components/ui/Icon.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
import SheetTextField from '@/components/ui/SheetTextField.vue'
import { listTask, completeTask, acceptTask, rejectTask, addTask, updateTask, delTask, getTask } from '@/api/manage/task'
import { getInfo } from '@/api/login'
import useUserStore from '@/store/modules/user'
import { getTaskStatusText, getTaskStatusVariant, getTaskTypeText, TASK_STATUS } from '@/utils/task'
const userStore = useUserStore()

// Top bar state
const userName = computed(() => userStore.name)
const profilePicture = computed(() => userStore.avatar || '')
const unreadCount = ref(0)

// Fetch user info
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

// Navigation state
const activeTab = ref('tasks')
const showSearch = ref(false)
const showFilterModal = ref(false)

// Detail/edit modal state
const showDetail = ref(false)
const formMode = ref('detail') // 'detail' | 'create' | 'edit'
const detailData = ref({})
const emptyTaskForm = () => ({
  taskId: null,
  productTypeId: null,
  innerCode: '',
  userName: '',
  addr: '',
  desc: ''
})
const formData = reactive(emptyTaskForm())
const typeIndex = ref(0)
const typeOptions = ref([
  { label: 'Deploy', value: 1 },
  { label: 'Restock', value: 2 },
  { label: 'Maintenance', value: 3 },
  { label: 'Revoke', value: 4 }
])

// Filter tabs
const activeFilter = ref('all')
const filterTabs = ref([
  { label: 'All', value: 'all', count: 0 },
  { label: 'Pending', value: 'pending', count: 0 },
  { label: 'In Progress', value: 'progress', count: 0 },
  { label: 'Completed', value: 'completed', count: 0 },
  { label: 'Cancelled', value: 'cancelled', count: 0 }
])

const taskList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  taskCode: '',
  taskStatus: null,
  productTypeId: null,
  orderByColumn: 'createTime',
  isAsc: 'desc'
})
const total = ref(0)

const selectedFilters = ref({})
const filterSections = ref([
  {
    key: 'status',
    title: 'Status',
    options: [
      { label: 'Pending', value: 1 },
      { label: 'In Progress', value: 2 },
      { label: 'Cancelled', value: 3 },
      { label: 'Completed', value: 4 }
    ]
  },
  {
    key: 'type',
    title: 'Type',
    options: [
      { label: 'Deploy', value: 1 },
      { label: 'Restock', value: 2 },
      { label: 'Maintenance', value: 3 },
      { label: 'Revoke', value: 4 }
    ]
  }
])

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    taskList.value = []
  }
  try {
    loading.value = true
    const res = await listTask(queryParams.value)
    if (res.rows) {
      taskList.value = [...taskList.value, ...res.rows]
      total.value = res.total
    }
  } catch (error) {
    uni.showToast({ title: 'Failed to load data', icon: 'none' })
  } finally {
    loading.value = false
    isRefreshing.value = false
  }
}

const refreshFilterCounts = async () => {
  try {
    const buildCountQuery = (taskStatus = null) => ({
      pageNum: 1,
      pageSize: 1,
      taskStatus,
      productTypeId: queryParams.value.productTypeId,
      orderByColumn: 'createTime',
      isAsc: 'desc'
    })

    const [allRes, pendingRes, progressRes, completedRes, cancelledRes] = await Promise.all([
      listTask(buildCountQuery()),
      listTask(buildCountQuery(TASK_STATUS.pending)),
      listTask(buildCountQuery(TASK_STATUS.inProgress)),
      listTask(buildCountQuery(TASK_STATUS.completed)),
      listTask(buildCountQuery(TASK_STATUS.cancelled))
    ])

    const countMap = {
      all: allRes.total || 0,
      pending: pendingRes.total || 0,
      progress: progressRes.total || 0,
      completed: completedRes.total || 0,
      cancelled: cancelledRes.total || 0
    }

    filterTabs.value = filterTabs.value.map((tab) => ({
      ...tab,
      count: countMap[tab.value] ?? 0
    }))
  } catch (error) {
    console.error('Failed to refresh task counts', error)
  }
}

onShow(() => {
  fetchUserInfo()
  fetchList(true)
  refreshFilterCounts()
})

const loadMore = () => {
  if (taskList.value.length < total.value) {
    queryParams.value.pageNum++
    fetchList()
  }
}

const onRefresh = () => {
  isRefreshing.value = true
  fetchList(true)
  refreshFilterCounts()
}

const handleAdd = () => {
  formMode.value = 'create'
  Object.assign(formData, emptyTaskForm(), {
    productTypeId: typeOptions.value[0]?.value ?? null
  })
  typeIndex.value = 0
  showDetail.value = true
}

const startEdit = () => {
  const d = detailData.value
  Object.assign(formData, emptyTaskForm(), {
    taskId: d.taskId ?? null,
    productTypeId: d.productTypeId ?? null,
    innerCode: d.innerCode || '',
    userName: d.userName || '',
    addr: d.addr || '',
    desc: d.desc || ''
  })
  const ti = typeOptions.value.findIndex((t) => t.value === formData.productTypeId)
  typeIndex.value = ti >= 0 ? ti : 0
  formMode.value = 'edit'
}

const handleAssignAll = () => {
  uni.showToast({ title: 'Bulk assign coming soon', icon: 'none' })
}

const handleCompleteAll = () => {
  uni.showModal({
    title: 'Complete All In-Progress',
    content: 'Mark all in-progress tasks as complete?',
    success: async (r) => {
      if (r.confirm) {
        const inProgress = taskList.value.filter(t => t.taskStatus === 2)
        for (const t of inProgress) {
          try { await completeTask(t.taskId) } catch (e) { console.error(e) }
        }
        uni.showToast({ title: `${inProgress.length} completed`, icon: 'success' })
        fetchList(true)
      }
    }
  })
}

const handleExport = () => {
  uni.showToast({ title: 'Export coming soon', icon: 'none' })
}

const handleSearch = () => {
  showSearch.value = true
}

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
  if (routes[tabId] && tabId !== 'tasks') {
    uni.navigateTo({ url: routes[tabId] })
  }
}

const handleFilterTab = (value) => {
  activeFilter.value = value
  
  if (value === 'pending') {
    queryParams.value.taskStatus = 1
  } else if (value === 'progress') {
    queryParams.value.taskStatus = 2
  } else if (value === 'cancelled') {
    queryParams.value.taskStatus = 3
  } else if (value === 'completed') {
    queryParams.value.taskStatus = 4
  } else {
    queryParams.value.taskStatus = null
  }
  
  fetchList(true)
  refreshFilterCounts()
}

const handleMasterFilter = () => {
  showFilterModal.value = true
}

const handleFilterApply = (filters) => {
  selectedFilters.value = filters
  if (filters.status && filters.status.length > 0) {
    queryParams.value.taskStatus = filters.status[0]
  }
  if (filters.type && filters.type.length > 0) {
    queryParams.value.productTypeId = filters.type[0]
  }
  fetchList(true)
}

const handleFilterReset = () => {
  selectedFilters.value = {}
  queryParams.value.taskStatus = null
  queryParams.value.productTypeId = null
  fetchList(true)
}

const handleViewDetail = async (item) => {
  try {
    const res = await getTask(item.taskId)
    detailData.value = res.data || item
  } catch (e) {
    detailData.value = item
  }
  formMode.value = 'detail'
  showDetail.value = true
}

const closeDetail = () => {
  showDetail.value = false
  formMode.value = 'detail'
  Object.assign(formData, emptyTaskForm())
}

const onTypeChange = (e) => {
  typeIndex.value = e.detail.value
  formData.productTypeId = typeOptions.value[e.detail.value]?.value ?? null
}

const saveTask = async () => {
  if (!formData.innerCode) {
    uni.showToast({ title: 'Machine code required', icon: 'none' })
    return
  }
  const payload = { ...formData }
  try {
    if (formData.taskId) {
      await updateTask(payload)
      uni.showToast({ title: 'Task updated', icon: 'success' })
    } else {
      const { taskId: _tid, ...createBody } = payload
      await addTask(createBody)
      uni.showToast({ title: 'Task created', icon: 'success' })
    }
    closeDetail()
    fetchList(true)
    refreshFilterCounts()
  } catch (e) {
    console.error(e)
  }
}

const confirmComplete = () => {
  uni.showModal({
    title: 'Complete Task',
    content: 'Mark this task as complete?',
    success: async (r) => {
      if (r.confirm) {
        await completeTask(detailData.value.taskId)
        uni.showToast({ title: 'Task completed', icon: 'success' })
        closeDetail()
        fetchList(true)
        refreshFilterCounts()
      }
    }
  })
}

const confirmAccept = () => {
  uni.showModal({
    title: 'Accept Task',
    content: 'Take ownership of this task?',
    success: async (r) => {
      if (r.confirm) {
        try {
          await acceptTask(detailData.value.taskId)
          uni.showToast({ title: 'Task accepted', icon: 'success' })
          closeDetail()
          fetchList(true)
          refreshFilterCounts()
        } catch (e) {
          console.error(e)
        }
      }
    }
  })
}

const confirmReject = () => {
  uni.showModal({
    title: 'Reject Task',
    content: 'Reject this task? You can optionally enter a reason.',
    editable: true,
    placeholderText: 'Reason (optional)',
    confirmColor: '#ef4444',
    success: async (r) => {
      if (r.confirm) {
        try {
          await rejectTask(detailData.value.taskId, r.content || '')
          uni.showToast({ title: 'Task rejected', icon: 'success' })
          closeDetail()
          fetchList(true)
          refreshFilterCounts()
        } catch (e) {
          console.error(e)
        }
      }
    }
  })
}

const confirmDelete = () => {
  uni.showModal({
    title: 'Delete Task',
    content: 'Permanently delete this task?',
    confirmColor: '#ef4444',
    success: async (r) => {
      if (r.confirm) {
        await delTask(detailData.value.taskId)
        uni.showToast({ title: 'Task deleted', icon: 'success' })
        closeDetail()
        fetchList(true)
        refreshFilterCounts()
      }
    }
  })
}

const handleSearchQuery = () => {}
const handleSearchResult = () => {}
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

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.content-wrapper {
  padding-left: $spacing-4;
  padding-right: $spacing-4;
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

.quick-actions {
  margin-bottom: $spacing-6;
}

.task-list {
  display: flex;
  flex-direction: column;
}

.task-card {
  cursor: pointer;
  margin-bottom: $spacing-3;

  &:last-child {
    margin-bottom: 0;
  }
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $spacing-3;
}

.task-code {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-bold;
}

.task-info {
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

.empty-state {
  padding: $spacing-4 0;
}

.detail-view { display: flex; flex-direction: column; }

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: $spacing-3 0;
  border-bottom: 1px solid $color-border-subtle;

  &:last-child {
    border-bottom: none;
  }

  &:first-child {
    padding-top: 0;
  }
}

.detail-row-column {
  flex-direction: column;
  align-items: flex-start;
  gap: $spacing-2;
}

.detail-label { @include text-caption; color: $color-text-secondary; }
.detail-value { @include text-body; color: $color-text-primary; font-weight: $font-weight-medium; }
.detail-desc { font-weight: $font-weight-regular; }

.form-view { display: flex; flex-direction: column; gap: $spacing-4; }
.form-group { display: flex; flex-direction: column; gap: $spacing-2; }
.form-label { @include text-caption; color: $color-text-secondary; font-weight: $font-weight-medium; }

.form-picker {
  @include sheet-form-picker-trigger;
}
</style>
