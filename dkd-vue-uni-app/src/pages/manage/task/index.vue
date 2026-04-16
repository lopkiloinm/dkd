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
              <Badge :variant="getStatusVariant(item.taskStatus)">{{ getStatusText(item.taskStatus) }}</Badge>
            </view>
            <view class="task-info">
              <view class="info-row">
                <text class="info-label">Type</text>
                <text class="info-value">{{ getTypeText(item.productTypeId) }}</text>
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
</template>

<script setup>
import { ref, computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import FilterModal from '@/components/app/FilterModal.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import Badge from '@/components/ui/Badge.vue'
import Grid from '@/components/ui/Grid.vue'
import Icon from '@/components/ui/Icon.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { listTask } from '@/api/manage/task'
import { getInfo } from '@/api/login'
import useUserStore from '@/store/modules/user'

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

// Filter tabs
const activeFilter = ref('all')
const filterTabs = ref([
  { label: 'All', value: 'all', count: 12 },
  { label: 'Pending', value: 'pending', count: 5 },
  { label: 'In Progress', value: 'progress', count: 3 },
  { label: 'Completed', value: 'completed' },
  { label: 'Cancelled', value: 'cancelled' }
])

const taskList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  taskCode: '',
  taskStatus: null,
  productTypeId: null
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

onShow(() => {
  fetchUserInfo()
  fetchList(true)
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
}

const handleAdd = () => {
  // Navigate to add task
}

const handleAssignAll = () => {
  // Handle assign
}

const handleCompleteAll = () => {
  // Handle complete
}

const handleExport = () => {
  // Handle export
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
    analytics: '/pages/data/index'
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

const handleViewDetail = (item) => {
  // Navigate to task detail
}

const getStatusText = (status) => {
  switch (status) {
    case 1: return 'Pending'
    case 2: return 'In Progress'
    case 3: return 'Cancelled'
    case 4: return 'Completed'
    default: return 'Unknown'
  }
}

const getStatusVariant = (status) => {
  switch (status) {
    case 1: return 'warning'
    case 2: return 'primary'
    case 3: return 'error'
    case 4: return 'success'
    default: return 'default'
  }
}

const getTypeText = (typeId) => {
  switch (typeId) {
    case 1: return 'Deploy'
    case 2: return 'Restock'
    case 3: return 'Maintenance'
    case 4: return 'Revoke'
    default: return 'Unknown'
  }
}

const handleSearchQuery = () => {}
const handleSearchResult = () => {}
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

.quick-actions {
  margin-bottom: $spacing-6;
}

.task-list {
  display: flex;
  flex-direction: column;
  margin-bottom: $spacing-6;
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
</style>
