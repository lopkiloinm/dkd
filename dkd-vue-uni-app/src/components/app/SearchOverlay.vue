<template>
  <view v-if="visible" class="search-mount">
    <view
      class="search-backdrop"
      @click="handleOverlayClick"
      @tap="handleOverlayClick"
    />
    <view class="search-content" @click.stop @tap.stop>
      <view class="search-header">
        <view class="search-input-wrapper">
          <Icon name="search" size="16" class="search-icon" />
          <input
            v-model="searchQuery"
            class="search-input"
            placeholder="Search machines, tasks, products..."
            @input="handleSearch"
            auto-focus
          />
          <view v-if="searchQuery" class="clear-icon" @click="handleClear">
            <Icon name="close" size="20" />
          </view>
        </view>
        <view class="cancel-button" @click="handleCancel">
          <text class="cancel-text">Cancel</text>
        </view>
      </view>
      <scroll-view class="search-results" scroll-y>
        <view v-if="loading" class="loading-state">
          <LoadingSpinner />
          <text class="loading-text">Searching...</text>
        </view>
        <view v-else-if="results.length === 0 && searchQuery" class="empty-state">
          <text class="empty-text">No results found</text>
        </view>
        <view v-else-if="!searchQuery" class="recent-searches">
          <text class="section-title">Recent Searches</text>
          <view
            v-for="(item, index) in recentSearches"
            :key="index"
            class="recent-item"
            @click="handleRecentClick(item)"
          >
            <Icon name="history" size="16" class="recent-icon" />
            <text class="recent-text">{{ item }}</text>
          </view>
        </view>
        <view v-else class="results-list">
          <view
            v-for="(result, index) in results"
            :key="index"
            class="result-item"
            @click="handleResultClick(result)"
          >
            <view class="result-icon">
              <Icon :name="getResultIcon(result.type)" size="20" />
            </view>
            <view class="result-info">
              <text class="result-title">{{ result.title }}</text>
              <text class="result-subtitle">{{ result.subtitle }}</text>
            </view>
            <text class="result-type">{{ result.type }}</text>
          </view>
        </view>
      </scroll-view>
    </view>
  </view>
</template>

<script setup>
import { ref, watch } from 'vue'
import LoadingSpinner from '@/components/ui/LoadingSpinner.vue'
import Icon from '@/components/ui/Icon.vue'
import { search } from '@/api/search'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:visible', 'search', 'result-click', 'cancel'])

const searchQuery = ref('')
const loading = ref(false)
const results = ref([])
const recentSearches = ref([])

// Load recent searches from storage
const loadRecentSearches = () => {
  try {
    const stored = uni.getStorageSync('recent_searches')
    if (stored) {
      recentSearches.value = JSON.parse(stored)
    }
  } catch (e) {
    console.error('Failed to load recent searches', e)
  }
}

// Save recent searches to storage
const saveRecentSearches = () => {
  try {
    uni.setStorageSync('recent_searches', JSON.stringify(recentSearches.value))
  } catch (e) {
    console.error('Failed to save recent searches', e)
  }
}

// Add query to recent searches
const addToRecentSearches = (query) => {
  const index = recentSearches.value.indexOf(query)
  if (index > -1) {
    recentSearches.value.splice(index, 1)
  }
  recentSearches.value.unshift(query)
  if (recentSearches.value.length > 10) {
    recentSearches.value = recentSearches.value.slice(0, 10)
  }
  saveRecentSearches()
}

watch(() => props.visible, (newVal) => {
  if (newVal) {
    loadRecentSearches()
    searchQuery.value = ''
    results.value = []
  }
})

const handleSearch = async () => {
  if (searchQuery.value.trim()) {
    loading.value = true
    try {
      const response = await search(searchQuery.value)
      if (response && response.data) {
        results.value = response.data.map(item => ({
          type: item.type,
          title: item.title,
          subtitle: item.subtitle,
          id: item.id,
          url: item.url
        }))
        addToRecentSearches(searchQuery.value)
      }
    } catch (error) {
      console.error('Search failed', error)
      results.value = []
    } finally {
      loading.value = false
    }
    emit('search', searchQuery.value)
  }
}

const handleClear = () => {
  searchQuery.value = ''
  results.value = []
}

const handleCancel = () => {
  emit('update:visible', false)
  emit('cancel')
}

const handleOverlayClick = () => {
  handleCancel()
}

const handleResultClick = (result) => {
  emit('result-click', result)
  handleCancel()
}

const handleRecentClick = (item) => {
  searchQuery.value = item
  handleSearch()
}

const getResultIcon = (type) => {
  const icons = {
    Machine: 'machines',
    Task: 'tasks',
    Product: 'inventory',
    Partner: 'partner',
    Node: 'node'
  }
  return icons[type] || 'document'
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.search-mount {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  pointer-events: auto;
}

.search-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
  @include overlay-scrim-flat;
}

.search-content {
  position: absolute;
  top: $spacing-4;
  left: $spacing-4;
  right: $spacing-4;
  z-index: 1;
  max-height: 80vh;
  @include surface-modal-glass($radius-lg, $shadow-xl);
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
  isolation: auto !important;
  background: $glass-card-shine, rgba(18, 20, 28, 0.96);
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-sizing: border-box;
}

.search-header {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3 $spacing-4;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.search-input-wrapper {
  flex: 1;
  @include input-base;
  min-height: 40px;
  padding: 0 $spacing-3;
}

.search-icon {
  margin-right: $spacing-2;
  color: $color-text-tertiary;
}

.search-input {
  flex: 1;
  height: 100%;
  background: transparent;
  border: none;
  outline: none;
  color: $color-text-primary;
  @include text-body;
  
  &::placeholder {
    color: $color-text-tertiary;
  }
}

.clear-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: $color-text-tertiary;
}

.cancel-button {
  cursor: pointer;
  padding: $spacing-2;
}

.cancel-text {
  @include text-body;
  color: $color-primary;
  font-weight: $font-weight-medium;
}

.search-results {
  flex: 1;
  @include scrollbar-hidden;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: $spacing-8;
}

.loading-text {
  @include text-caption;
  color: $color-text-secondary;
  margin-top: $spacing-2;
}

.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-8;
}

.empty-text {
  @include text-body;
  color: $color-text-tertiary;
}

.recent-searches {
  padding: $spacing-3 $spacing-4;
}

.section-title {
  @include text-caption;
  color: $color-text-tertiary;
  font-weight: $font-weight-semibold;
  text-transform: uppercase;
  margin-bottom: $spacing-3;
}

.recent-item {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  cursor: pointer;

  &:last-child {
    border-bottom: none;
  }
}

.recent-icon {
  color: $color-text-tertiary;
}

.recent-text {
  @include text-body;
  color: $color-text-primary;
}

.results-list {
  padding: 0 $spacing-4;
}

.result-item {
  display: flex;
  align-items: center;
  gap: $spacing-3;
  padding: $spacing-3 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
  cursor: pointer;

  &:last-child {
    border-bottom: none;
  }
}

.result-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  @include surface-card-glass($radius-sm, $shadow-sm);
  color: $color-text-secondary;
}

.result-info {
  flex: 1;
}

.result-title {
  display: block;
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-medium;
  margin-bottom: $spacing-1;
}

.result-subtitle {
  display: block;
  @include text-caption;
  color: $color-text-secondary;
}

.result-type {
  @include text-caption;
  color: $color-text-tertiary;
  text-transform: capitalize;
}
</style>
