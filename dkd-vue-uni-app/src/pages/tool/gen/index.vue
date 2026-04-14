<template>
  <TopBar title="Code Generation" :showBack="true" />
  <view class="layout-container">
    <view class="search-bar">
      <input class="n-input search-input" v-model="queryParams.tableName" placeholder="Search by Table Name" @confirm="handleSearch" />
      <input class="n-input search-input" v-model="queryParams.tableComment" placeholder="Search by Table Comment" @confirm="handleSearch" />
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="table-list">
        <view class="table-card" v-for="item in tableList" :key="item.tableId">
          <view class="table-card-header">
            <text class="table-name">{{ item.tableName }}</text>
            <view class="action-btn" @click="handleSync(item)">
              <text class="action-text">Sync</text>
            </view>
          </view>
          
          <view class="table-info">
            <view class="info-row">
              <text class="info-label">Table Comment</text>
              <text class="info-value">{{ item.tableComment || 'N/A' }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Class Name</text>
              <text class="info-value">{{ item.className }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Create Time</text>
              <text class="info-value">{{ item.createTime }}</text>
            </view>
            <view class="info-row">
              <text class="info-label">Update Time</text>
              <text class="info-value">{{ item.updateTime }}</text>
            </view>
          </view>

          <view class="card-actions">
            <view class="action-btn" @click="handlePreview(item)">
              <text class="action-text">Preview</text>
            </view>
            <view class="action-btn" @click="handleEdit(item)">
              <text class="action-text">Edit</text>
            </view>
            <view class="action-btn" @click="handleGenerate(item)">
              <text class="action-text">Generate</text>
            </view>
            <view class="action-btn delete" @click="handleDelete(item)">
              <text class="action-text">Delete</text>
            </view>
          </view>
        </view>

        <view class="empty-state" v-if="tableList.length === 0 && !loading">
          <text class="empty-text">No tables found</text>
        </view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import TopBar from '@/components/TopBar/index.vue'
import { listTable, delTable, synchDb, previewTable, genCode } from '@/api/tool/gen'

const tableList = ref([])
const loading = ref(false)
const isRefreshing = ref(false)

const queryParams = ref({
  pageNum: 1,
  pageSize: 10,
  tableName: '',
  tableComment: ''
})
const total = ref(0)

const fetchList = async (reset = false) => {
  if (reset) {
    queryParams.value.pageNum = 1
    tableList.value = []
  }
  try {
    loading.value = true
    const res = await listTable(queryParams.value)
    if (res.rows) {
      tableList.value = [...tableList.value, ...res.rows]
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

const handleImport = () => {
  uni.showToast({ title: 'Import functionality not implemented yet', icon: 'none' })
}

const handleSync = (item) => {
  uni.showModal({
    title: 'Confirm Sync',
    content: `Are you sure you want to sync table "${item.tableName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await synchDb(item.tableName)
          uni.showToast({ title: 'Sync successful', icon: 'success' })
          fetchList(true)
        } catch (error) {
          uni.showToast({ title: 'Failed to sync', icon: 'none' })
        }
      }
    }
  })
}

const handlePreview = async (item) => {
  try {
    const res = await previewTable(item.tableId)
    uni.showToast({ title: 'Preview loaded', icon: 'success' })
  } catch (error) {
    uni.showToast({ title: 'Failed to load preview', icon: 'none' })
  }
}

const handleEdit = (item) => {
  uni.showToast({ title: 'Edit functionality not implemented yet', icon: 'none' })
}

const handleGenerate = (item) => {
  uni.showModal({
    title: 'Confirm Generate',
    content: `Are you sure you want to generate code for "${item.tableName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await genCode(item.tableName)
          uni.showToast({ title: 'Code generated successfully', icon: 'success' })
        } catch (error) {
          uni.showToast({ title: 'Failed to generate code', icon: 'none' })
        }
      }
    }
  })
}

const handleDelete = (item) => {
  uni.showModal({
    title: 'Confirm Delete',
    content: `Are you sure you want to delete "${item.tableName}"?`,
    success: async (res) => {
      if (res.confirm) {
        try {
          await delTable(item.tableId)
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
  if (tableList.value.length < total.value) {
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
  padding: 16px 20px 16px;
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

.table-list {
  padding: 0 20px 24px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.table-card {
  @include glass-panel;
  padding: 20px;
}

.table-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid $apple-glass-border;
}

.table-name {
  font-size: 18px;
  font-weight: 700;
  color: $apple-text-primary;
  letter-spacing: -0.5px;
}

.action-btn {
  padding: 10px 16px;
  border-radius: 8px;
  background-color: rgba(0, 122, 255, 0.1);
  text-align: center;
  transition: background-color 0.2s;
}

.action-btn:active {
  background-color: rgba(0, 122, 255, 0.2);
}

.action-text {
  font-size: 14px;
  font-weight: 600;
  color: #007aff;
}

.table-info {
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
  gap: 8px;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid $apple-glass-border;
}

.action-btn {
  flex: 1;
  padding: 10px 8px;
}

.action-btn.delete {
  background-color: rgba(255, 59, 48, 0.1);
}

.action-btn.delete:active {
  background-color: rgba(255, 59, 48, 0.2);
}

.action-btn.delete .action-text {
  color: #ff3b30;
}
</style>
