<template>
  <AppTopBar title="Machines" />
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

    <scroll-view class="scroll-area" scroll-y>
      <view class="content-wrapper">

        <!-- Section Cards Grid -->
        <text class="section-title">Overview</text>
        <view class="section-cards">
          <Grid :columns="2" :gap="16">
            <SectionCard
              title="Nodes"
              :stats="`${nodeCount} Total`"
              @click="goTo('/pages/manage/node/index')"
            />
            <SectionCard
              title="Devices"
              :stats="`${deviceCount} Total • ${onlineCount} Online`"
              @click="goTo('/pages/manage/vm/index')"
            />
            <SectionCard
              title="Device Types"
              :stats="`${vmTypeCount} Types`"
              @click="goTo('/pages/manage/vmType/index')"
            />
            <SectionCard
              title="Regions"
              :stats="`${regionCount} Regions`"
              @click="goTo('/pages/manage/region/index')"
            />
            <SectionCard
              title="Partners"
              :stats="`${partnerCount} Partners`"
              @click="goTo('/pages/manage/partner/index')"
            />
            <SectionCard
              title="Employees"
              :stats="`${empCount} Employees`"
              @click="goTo('/pages/manage/emp/index')"
            />
          </Grid>
        </view>
      </view>
    </scroll-view>
    <AppBottomBar :active-tab="'machines'" @tab-change="handleTabChange" />
  </view>

  <FilterModal
    :visible="filterModalVisible"
    @update:visible="filterModalVisible = $event"
    :filter-sections="filterSections"
    :selected-filters="selectedFilters"
    @apply="handleFilterApply"
    @reset="handleFilterReset"
  />
</template>

<script setup>
import { ref, onMounted } from 'vue'
import AppTopBar from '@/components/app/AppTopBar.vue'
import AppBottomBar from '@/components/app/AppBottomBar.vue'
import SectionCard from '@/components/app/SectionCard.vue'
import Grid from '@/components/ui/Grid.vue'
import Icon from '@/components/ui/Icon.vue'
import FilterModal from '@/components/app/FilterModal.vue'
import { listNode } from '@/api/manage/node'
import { listVm } from '@/api/manage/vm'
import { listEmp } from '@/api/manage/emp'
import { listRegion } from '@/api/manage/region'
import { listPartner } from '@/api/manage/partner'
import { listVmType } from '@/api/manage/vmType'

// Stats
const nodeCount = ref(0)
const deviceCount = ref(0)
const onlineCount = ref(0)
const empCount = ref(0)
const regionCount = ref(0)
const partnerCount = ref(0)
const vmTypeCount = ref(0)

// Filters
const filterTabs = ref([
  { label: 'All', value: 'all' },
  { label: 'Online', value: 'online' },
  { label: 'Offline', value: 'offline' }
])
const activeFilter = ref('all')
const filterModalVisible = ref(false)
const selectedFilters = ref({})
const filterSections = ref([
  {
    key: 'status',
    title: 'Status',
    options: [
      { label: 'Online', value: 'online' },
      { label: 'Offline', value: 'offline' }
    ]
  },
  {
    key: 'type',
    title: 'Type',
    options: [
      { label: 'Node', value: 'node' },
      { label: 'Device', value: 'device' }
    ]
  }
])

const handleFilterTab = (value) => {
  activeFilter.value = value
}

const handleMasterFilter = () => {
  filterModalVisible.value = true
}

const handleFilterApply = (filters) => {
  selectedFilters.value = filters
  filterModalVisible.value = false
}

const handleFilterReset = () => {
  selectedFilters.value = {}
}

const fetchStats = async () => {
  try {
    const [nodes, devices, emps, regions, partners, vmTypes] = await Promise.all([
      listNode({ pageNum: 1, pageSize: 1 }),
      listVm({ pageNum: 1, pageSize: 1 }),
      listEmp({ pageNum: 1, pageSize: 1 }),
      listRegion({ pageNum: 1, pageSize: 1 }),
      listPartner({ pageNum: 1, pageSize: 1 }),
      listVmType({ pageNum: 1, pageSize: 1 })
    ])

    nodeCount.value = nodes.total || 0
    deviceCount.value = devices.total || 0
    onlineCount.value = devices.rows?.filter(vm => vm.vmStatus === 1).length || 0
    empCount.value = emps.total || 0
    regionCount.value = regions.total || 0
    partnerCount.value = partners.total || 0
    vmTypeCount.value = vmTypes.total || 0
  } catch (error) {
    console.error('Failed to fetch stats', error)
  }
}

const goTo = (url) => {
  uni.navigateTo({ url })
}

const handleTabChange = (tabId) => {
  const routes = {
    dashboard: '/pages/index/index',
    machines: '/pages/manage/index',
    tasks: '/pages/manage/task/index',
    inventory: '/pages/inventory/index',
    analytics: '/pages/analytics/index'
  }
  if (routes[tabId] && tabId !== 'machines') {
    uni.navigateTo({ url: routes[tabId] })
  }
}

onMounted(() => {
  fetchStats()
})
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
  padding: $spacing-4 $spacing-4 calc($spacing-4 + #{$bottom-bar-height} + env(safe-area-inset-bottom, 0px)) $spacing-4;
  min-height: 100vh;
  box-sizing: border-box;
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

.section-cards {
  margin-bottom: $spacing-6;
}

.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
  margin-bottom: $spacing-3;
  display: block;
}
</style>
