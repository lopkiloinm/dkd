<template>
  <view class="table-wrapper">
  <scroll-view class="table-scroll" scroll-x>
    <view class="table">
      <view class="table-header">
        <view
          v-for="(column, index) in columns"
          :key="index"
          class="table-cell table-header-cell"
          :style="{ width: column.width || 'auto' }"
          @click="handleSort(column)"
        >
          <text class="cell-text">{{ column.label }}</text>
          <view v-if="column.sortable" class="sort-icon">
            <text>{{ getSortIcon(column.key) }}</text>
          </view>
        </view>
      </view>
      <view class="table-body">
        <view
          v-for="(row, rowIndex) in data"
          :key="rowIndex"
          class="table-row"
          :class="{ 'table-row-selected': selectedRow === rowIndex }"
          @click="handleRowClick(row, rowIndex)"
        >
          <view
            v-for="(column, colIndex) in columns"
            :key="colIndex"
            class="table-cell table-body-cell"
            :style="{ width: column.width || 'auto' }"
          >
            <slot name="cell" :row="row" :column="column" :value="row[column.key]">
              <text class="cell-text">{{ row[column.key] }}</text>
            </slot>
          </view>
        </view>
      </view>
    </view>
  </scroll-view>
  </view>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  columns: {
    type: Array,
    default: () => []
  },
  data: {
    type: Array,
    default: () => []
  },
  selectable: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['row-click', 'sort'])

const selectedRow = ref(-1)
const sortKey = ref(null)
const sortOrder = ref('asc')

const getSortIcon = (key) => {
  if (sortKey.value !== key) return '↕'
  return sortOrder.value === 'asc' ? '↑' : '↓'
}

const handleSort = (column) => {
  if (!column.sortable) return
  
  if (sortKey.value === column.key) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortKey.value = column.key
    sortOrder.value = 'asc'
  }
  
  emit('sort', { key: column.key, order: sortOrder.value })
}

const handleRowClick = (row, index) => {
  if (props.selectable) {
    selectedRow.value = index
  }
  emit('row-click', row, index)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.table-wrapper {
  background: $color-bg-secondary;
  border-radius: $radius-md;
  overflow: hidden;
  border: 1px solid $color-border-subtle;
}

.table-scroll {
  @include scrollbar-hidden;
}

.table {
  width: 100%;
}

.table-header {
  display: flex;
  background: $color-bg-tertiary;
}

.table-body {
  display: flex;
  flex-direction: column;
}

.table-row {
  display: flex;
  transition: background-color $transition-normal;
  
  &:last-child {
    border-bottom: none;
  }
  
  &:active {
    background: $color-bg-tertiary;
  }
  
  &.table-row-selected {
    background: rgba($color-primary, 0.1);
  }
}

.table-cell {
  flex-shrink: 0;
  padding: $spacing-3 $spacing-4;
  
  &.table-header-cell {
    @include text-label;
    font-weight: $font-weight-semibold;
    color: $color-text-secondary;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    cursor: pointer;
    
    &:active {
      background: rgba(0, 0, 0, 0.05);
    }
  }
  
  &.table-body-cell {
    @include text-body;
    color: $color-text-primary;
  }
}

.cell-text {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.sort-icon {
  margin-left: $spacing-1;
  font-size: 12px;
  color: $color-text-tertiary;
}
</style>
