<template>
  <wd-navbar title="Work Orders" fixed placeholder safe-area-inset-top left-arrow />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.taskCode" placeholder="Search by Order No." @confirm="handleSearch" />
      <view class="filter-toggle" @click="toggleFilters">
        <text class="filter-toggle-text">{{ filtersExpanded ? 'Hide Filters' : 'Show Filters' }}</text>
        <text class="filter-toggle-icon">{{ filtersExpanded ? '▼' : '▶' }}</text>
      </wd-button>
      <view class="filters-container" :class="{ expanded: filtersExpanded }">
        <picker mode="selector" :range="statusOptions" :value="filterStatusIndex" @change="onFilterStatusChange">
          <view class="filter-picker">{{ statusOptions[filterStatusIndex] }}</wd-button>
        </picker>
        <picker mode="selector" :range="typeOptions" :value="filterTypeIndex" @change="onFilterTypeChange">
          <view class="filter-picker">{{ typeOptions[filterTypeIndex] }}</wd-button>
        </picker>
      </wd-button>
    </wd-button>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="card-list">
        <view class="glass-card" v-for="item in taskList" :key="item.taskId">
          <view class="card-header">
            <text class="card-title">{{ item.taskCode }}</text>
            <wd-tag :class="'status-' + item.taskStatus">
              {{ getStatusText(item.taskStatus) }}
            </wd-button>
          </wd-button>
          
          <view class="info-section">
            <view class="info-row">
              <text class="info-label">Type</text>
              <text class="info-value">{{ getTypeText(item.productTypeId) }}</text>
            </wd-button>
            <view class="info-row">
              <text class="info-label">Device Code</text>
              <text class="info-value">{{ item.innerCode }}</text>
            </wd-button>
            <view class="info-row">
              <text class="info-label">Operator</text>
              <text class="info-value">{{ item.userName || 'Unassigned' }}</text>
            </wd-button>
            <view class="info-row">
              <text class="info-label">Created</text>
              <text class="info-value">{{ item.createTime }}</text>
            </wd-button>
          </wd-button>
        </wd-button>

        <view class="empty-state" v-if="taskList.length === 0 && !loading">
          <text class="empty-text">No work orders found</text>
        </wd-button>
      </wd-button>
    </scroll-view>
  </wd-button>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { listTask } from '@/api/manage/task'

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
const filtersExpanded = ref(false)

const statusOptions = ['All Status', 'Pending', 'In Progress', 'Cancelled', 'Completed']
const filterStatusIndex = ref(0)
const typeOptions = ['All Types', 'Deploy', 'Restock', 'Maintenance', 'Revoke']
const filterTypeIndex = ref(0)

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
  fetchList(true)
})

const handleSearch = () => {
  fetchList(true)
}

const toggleFilters = () => {
  filtersExpanded.value = !filtersExpanded.value
}

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

const getStatusText = (status) => {
  switch (status) {
    case 1: return 'Pending'
    case 2: return 'In Progress'
    case 3: return 'Cancelled'
    case 4: return 'Completed'
    default: return 'Unknown'
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

const onFilterStatusChange = (e) => {
  filterStatusIndex.value = e.detail.value
  queryParams.value.taskStatus = e.detail.value === 0 ? null : e.detail.value
  handleSearch()
}

const onFilterTypeChange = (e) => {
  filterTypeIndex.value = e.detail.value
  queryParams.value.productTypeId = e.detail.value === 0 ? null : e.detail.value
  handleSearch()
}
</script>

<style scoped lang="scss">
@import "@/styles/apple.scss";

/* Page-specific styles only — shared patterns come from _layout.scss */

.status-1 {
  background-color: rgba(255, 149, 0, 0.15);
  color: #ff9500;
}

.status-2 {
  background-color: rgba(0, 122, 255, 0.15);
  color: $apple-blue;
}

.status-3 {
  background-color: rgba(255, 59, 48, 0.15);
  color: $apple-red;
}

.status-4 {
  background-color: rgba(52, 199, 89, 0.15);
  color: $apple-green;
}
</style>
