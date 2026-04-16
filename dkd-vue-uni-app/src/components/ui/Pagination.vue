<template>
  <view class="pagination">
    <view class="pagination-info">
      <text class="info-text">{{ showingText }}</text>
    </view>
    <view class="pagination-controls">
      <view
        class="pagination-button"
        :class="{ 'pagination-button-disabled': currentPage <= 1 }"
        @click="handlePrev"
      >
        <Icon name="chevron-left" size="20" color="currentColor" />
      </view>
      <view class="pagination-pages">
        <view
          v-for="page in visiblePages"
          :key="page"
          class="page-item"
          :class="{ 'page-item-active': page === currentPage, 'page-item-ellipsis': page === '...' }"
          @click="handlePageClick(page)"
        >
          <text class="page-text">{{ page }}</text>
        </view>
      </view>
      <view
        class="pagination-button"
        :class="{ 'pagination-button-disabled': currentPage >= totalPages }"
        @click="handleNext"
      >
        <Icon name="chevron-right" size="20" color="currentColor" />
      </view>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  currentPage: {
    type: Number,
    default: 1
  },
  totalPages: {
    type: Number,
    default: 1
  },
  pageSize: {
    type: Number,
    default: 10
  },
  totalItems: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['update:currentPage', 'change'])

const showingText = computed(() => {
  const start = (props.currentPage - 1) * props.pageSize + 1
  const end = Math.min(props.currentPage * props.pageSize, props.totalItems)
  return `${start}-${end} of ${props.totalItems}`
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  
  if (props.totalPages <= maxVisible) {
    for (let i = 1; i <= props.totalPages; i++) {
      pages.push(i)
    }
  } else {
    pages.push(1)
    
    if (props.currentPage > 3) {
      pages.push('...')
    }
    
    const start = Math.max(2, props.currentPage - 1)
    const end = Math.min(props.totalPages - 1, props.currentPage + 1)
    
    for (let i = start; i <= end; i++) {
      pages.push(i)
    }
    
    if (props.currentPage < props.totalPages - 2) {
      pages.push('...')
    }
    
    pages.push(props.totalPages)
  }
  
  return pages
})

const handlePrev = () => {
  if (props.currentPage > 1) {
    emit('update:currentPage', props.currentPage - 1)
    emit('change', props.currentPage - 1)
  }
}

const handleNext = () => {
  if (props.currentPage < props.totalPages) {
    emit('update:currentPage', props.currentPage + 1)
    emit('change', props.currentPage + 1)
  }
}

const handlePageClick = (page) => {
  if (page !== '...' && page !== props.currentPage) {
    emit('update:currentPage', page)
    emit('change', page)
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-4;
}

.pagination-info {
  @include text-caption;
  color: $color-text-secondary;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: $spacing-2;
}

.pagination-button {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  height: 32px;
  padding: 0 $spacing-2;
  background: $color-bg-tertiary;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: all $transition-normal;
  
  &:active {
    background: $color-bg-elevated;
  }
  
  &.pagination-button-disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.button-text {
  font-size: 18px;
  line-height: 1;
  color: $color-text-primary;
}

.pagination-pages {
  display: flex;
  align-items: center;
  gap: $spacing-1;
}

.page-item {
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  height: 32px;
  background: $color-bg-tertiary;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: all $transition-normal;
  
  &:active {
    background: $color-bg-elevated;
  }
  
  &.page-item-active {
    background: $color-primary;
  }
  
  &.page-item-ellipsis {
    background: transparent;
    cursor: default;
  }
  
  &.page-item-ellipsis:active {
    background: transparent;
  }
}

.page-text {
  @include text-caption;
  color: $color-text-primary;
  
  .page-item-active & {
    color: $color-text-primary;
    font-weight: $font-weight-semibold;
  }
  
  .page-item-ellipsis & {
    color: $color-text-tertiary;
  }
}
</style>
