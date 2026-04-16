<template>
  <Sheet :visible="visible" @update:visible="handleVisibleChange" position="bottom" @close="handleClose" class="filter-sheet">
    <template #header>
      <view class="filter-header">
        <text class="filter-title">{{ title }}</text>
        <view class="filter-actions">
          <view class="action-button" @click="handleReset">
            <text class="action-text">Reset</text>
          </view>
          <view class="action-button primary" @click="handleApply">
            <text class="action-text">Apply</text>
          </view>
        </view>
      </view>
    </template>
    <scroll-view class="filter-body" scroll-y>
      <view class="filter-content">
        <view v-for="(section, index) in filterSections" :key="index" class="filter-section">
          <text class="section-title">{{ section.title }}</text>
          <view class="section-content">
            <view
              v-for="(option, optIndex) in section.options"
              :key="optIndex"
              class="filter-option"
              :class="{ 'filter-option-selected': isOptionSelected(section.key, option.value) }"
              @click="toggleOption(section.key, option.value)"
            >
              <text class="option-label">{{ option.label }}</text>
              <view class="option-checkbox" :class="{ 'checked': isOptionSelected(section.key, option.value) }">
                <Icon v-if="isOptionSelected(section.key, option.value)" name="check" size="14" color="currentColor" class="checkbox-check" />
              </view>
            </view>
          </view>
        </view>
      </view>
    </scroll-view>
  </Sheet>
</template>

<script setup>
import { ref, watch, computed } from 'vue'
import Sheet from '@/components/ui/Sheet.vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  title: {
    type: String,
    default: 'Filters'
  },
  filterSections: {
    type: Array,
    default: () => []
  },
  selectedFilters: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:visible', 'close', 'apply', 'reset'])

const localFilters = ref({})

watch(() => props.selectedFilters, (newVal) => {
  localFilters.value = { ...newVal }
}, { immediate: true, deep: true })

const isOptionSelected = (sectionKey, optionValue) => {
  const sectionFilters = localFilters.value[sectionKey] || []
  return sectionFilters.includes(optionValue)
}

const toggleOption = (sectionKey, optionValue) => {
  if (!localFilters.value[sectionKey]) {
    localFilters.value[sectionKey] = []
  }
  
  const index = localFilters.value[sectionKey].indexOf(optionValue)
  if (index > -1) {
    localFilters.value[sectionKey].splice(index, 1)
  } else {
    localFilters.value[sectionKey].push(optionValue)
  }
}

const handleReset = () => {
  localFilters.value = {}
  emit('reset')
}

const handleApply = () => {
  emit('apply', localFilters.value)
  handleClose()
}

const handleClose = () => {
  emit('update:visible', false)
  emit('close')
}

const handleVisibleChange = (value) => {
  emit('update:visible', value)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.filter-sheet :deep(.sheet-header) {
  padding: $spacing-2;
  border-bottom: none;
}

.filter-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-2;
  padding: $spacing-2;
}

.filter-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.filter-actions {
  display: flex;
  gap: $spacing-2;
  align-items: center;
}

.action-button {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 32px;
  padding: 0 $spacing-2;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: background-color $transition-normal;

  &:active {
    opacity: 0.7;
  }

  &.primary {
    background: $color-primary;
  }

  .action-text {
    @include text-caption;
    color: $color-text-primary;
    font-weight: $font-weight-medium;

    .primary & {
      color: $color-text-primary;
    }
  }
}

.filter-body {
  padding: 0;
  @include scrollbar-hidden;
  max-width: 100%;
  width: 100%;
  box-sizing: border-box;
}

.filter-content {
  padding: $spacing-4;
  max-width: 100%;
  width: 100%;
  box-sizing: border-box;
  overflow: hidden;
}

.filter-section {
  margin-bottom: $spacing-5;

  &:last-child {
    margin-bottom: 0;
  }
}

.section-title {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-semibold;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: $spacing-3;
  display: block;
}

.section-content {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
  overflow: hidden;
  max-width: 100%;
}

.filter-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: $spacing-3;
  padding: $spacing-3;
  background: $color-bg-tertiary;
  border-radius: $radius-sm;
  cursor: pointer;
  transition: all $transition-normal;
  box-sizing: border-box;
  max-width: 100%;
  width: 100%;

  &:active {
    background: $color-bg-elevated;
  }

  &.filter-option-selected {
    background: rgba($color-primary, 0.1);
  }
}

.option-label {
  @include text-body;
  color: $color-text-primary;
  white-space: nowrap;
}

.option-checkbox {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  background: $color-bg-secondary;
  border: 2px solid $color-border-medium;
  border-radius: $radius-xs;
  transition: all $transition-fast;
  flex-shrink: 0;

  &.checked {
    background: $color-primary;
    border-color: $color-primary;
  }
}

.checkbox-check {
  color: white;
}
</style>
