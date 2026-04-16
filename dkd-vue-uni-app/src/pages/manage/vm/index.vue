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
      <view class="master-filter-btn" @click="handleMasterFilter">
        <text class="filter-icon">⚙</text>
      </view>
    </view>

    <scroll-view class="scroll-area" scroll-y @scrolltolower="loadMore" refresher-enabled @refresherrefresh="onRefresh" :refresher-triggered="isRefreshing">
      <view class="content-wrapper">
        <!-- Section Cards -->
        <view class="section-cards">
          <SectionCard
            title="Machines"
            :stats="`${totalMachines} Total • ${onlineMachines} Online`"
            @click="showMachineSection = true"
          />
          <SectionCard
            title="Partners"
            :stats="`${partnerCount} Active Partners`"
            @click="showPartnerSection = true"
          />
        </view>

        <!-- Machine List -->
        <view v-if="showMachineSection" class="machine-list">
          <text class="list-title">Machines</text>
          <view v-if="vmList.length === 0 && !loading" class="empty-state">
            <EmptyState title="No machines found" description="Try adjusting your filters" />
          </view>
          <Card v-for="item in vmList" :key="item.id" class="machine-card" @click="handleViewDetail(item)">
            <CardSection variant="body">
              <view class="card-header">
                <text class="machine-code">{{ item.innerCode }}</text>
                <Badge :variant="getStatusVariant(item.vmStatus)">{{ getStatusText(item.vmStatus) }}</Badge>
              </view>
              <view class="machine-info">
                <text class="info-text">{{ item.addr || 'Unknown address' }}</text>
                <text class="info-sub">{{ item.partnerName || 'No partner assigned' }}</text>
              </view>
            </CardSection>
          </Card>
        </view>

        <!-- Partner List -->
        <view v-if="showPartnerSection" class="partner-list">
          <text class="list-title">Partners</text>
          <view v-if="partnerList.length === 0" class="empty-state">
            <EmptyState title="No partners found" description="Add partners to get started" />
          </view>
          <Card v-for="partner in partnerList" :key="partner.id" class="partner-card" @click="handlePartnerClick(partner)">
            <CardSection variant="body">
              <view class="partner-header">
                <text class="partner-name">{{ partner.partnerName }}</text>
                <Badge variant="success">Active</Badge>
              </view>
              <text class="partner-contact">{{ partner.contactPhone || 'No contact info' }}</text>
            </CardSection>
          </Card>
        </view>
      </view>
    </scroll-view>
  </view>
  <AppBottomBar :active-tab="activeTab" @tab-change="handleTabChange" />
  <FilterModal
    v-model:visible="showFilterModal"
    :title="'Filter Machines'"
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
import { ref, computed, onMounted } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useUserStore } from '@/store/modules/user'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import FilterModal from '@/components/app/FilterModal.vue'
import SearchOverlay from '@/components/app/SearchOverlay.vue'
import Icon from '@/components/ui/Icon.vue'
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'
import SectionCard from '@/components/app/SectionCard.vue'
import Badge from '@/components/ui/Badge.vue'
import EmptyState from '@/components/ui/EmptyState.vue'
import { listVm } from '@/api/manage/vm'
import { listPartner } from '@/api/manage/partner'
import { listVmType } from '@/api/manage/vmType'
import { getInfo } from '@/api/login'

const userStore = useUserStore()

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

// Navigation
const activeTab = ref('machines')
const showSearch = ref(false)
const showFilterModal = ref(false)
const showMachineSection = ref(true)
const showPartnerSection = ref(false)

// Profile
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

// Filter tabs
const activeFilter = ref('all')
const filterTabs = ref([
  { label: 'All', value: 'all', count: 85 },
  { label: 'Online', value: 'online', count: 80 },
  { label: 'Offline', value: 'offline', count: 3 },
  { label: 'Fault', value: 'fault', count: 2 },
  { label: 'Partner', value: 'partner' }
])

// Section stats
const totalMachines = ref(85)
const onlineMachines = ref(80)
const partnerCount = ref(12)

// Filter modal
const selectedFilters = ref({})
const filterSections = ref([
  {
    key: 'status',
    title: 'Status',
    options: [
      { label: 'Operating', value: 1 },
      { label: 'Unoperated', value: 0 },
      { label: 'Fault', value: 3 }
    ]
  },
  {
    key: 'node',
    title: 'Node',
    options: []
  },
  {
    key: 'region',
    title: 'Region',
    options: []
  },
  {
    key: 'partner',
    title: 'Partner',
    options: []
  }
])

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
  fetchUserInfo()
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

const handleSearchQuery = (query) => {
  // Implement search logic
}

const handleSearchResult = (result) => {
  // Handle search result click
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
    machines: '/pages/manage/vm/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'machines') {
    uni.switchTab({ url: routes[tabId] })
  }
}

const handleFilterTab = (value) => {
  activeFilter.value = value
  showMachineSection.value = value !== 'partner'
  showPartnerSection.value = value === 'partner'
  
  // Update query params based on filter
  if (value === 'online') {
    queryParams.value.vmStatus = 1
  } else if (value === 'offline') {
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
  // Apply filters to query params
  if (filters.status && filters.status.length > 0) {
    queryParams.value.vmStatus = filters.status[0]
  }
  if (filters.node && filters.node.length > 0) {
    queryParams.value.nodeId = filters.node[0]
  }
  if (filters.region && filters.region.length > 0) {
    queryParams.value.regionId = filters.region[0]
  }
  if (filters.partner && filters.partner.length > 0) {
    queryParams.value.partnerId = filters.partner[0]
  }
  
  fetchList(true)
}

const handleFilterReset = () => {
  selectedFilters.value = {}
  queryParams.value = {
    pageNum: 1,
    pageSize: 10,
    innerCode: '',
    nodeId: null,
    regionId: null,
    partnerId: null,
    vmTypeId: null,
    vmStatus: null,
    policyId: ''
  }
  showFilterModal.value = false
  fetchList(true)
}

const handlePartnerClick = (partner) => {
  // Navigate to partner detail page
  uni.navigateTo({ url: `/pages/manage/partner/detail?id=${partner.id}` })
}

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

.layout-container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $color-bg-primary;
  padding-top: $top-bar-total-height;
}

.scroll-area {
  flex: 1;
  overflow: hidden;
}

.content-wrapper {
  padding: $spacing-4 $spacing-4 calc(#{$bottom-bar-height} + env(safe-area-inset-bottom, 0px) + #{$spacing-4}) $spacing-4;
}

.filter-tabs {
  display: flex;
  gap: $spacing-2;
  margin-bottom: $spacing-4;
  overflow-x: auto;
  padding-bottom: $spacing-1;
}

.filter-tab {
  display: flex;
  align-items: center;
  gap: $spacing-2;
  padding: $spacing-2 $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-lg;
  white-space: nowrap;
  color: $color-text-secondary;
  transition: all $transition-normal;

  &.active {
    background: $color-primary;
    color: white;
  }
}

.filter-tab-text {
  @include text-caption;
  font-weight: $font-weight-medium;
}

.section-cards {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
  margin-bottom: $spacing-6;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $spacing-2;
}

.machine-code {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.machine-info {
  display: flex;
  flex-direction: column;
  gap: $spacing-1;
}

.info-text {
  @include text-caption;
  color: $color-text-secondary;
}

.info-sub {
  @include text-caption;
  color: $color-text-tertiary;
}

.partner-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: $spacing-2;
}

.partner-name {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.partner-contact {
  @include text-caption;
  color: $color-text-secondary;
}

.empty-state {
  padding: $spacing-8 0;
}
</style>
