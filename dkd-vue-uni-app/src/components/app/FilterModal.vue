<template>
  <BottomSheet
    :visible="visible"
    :title="title"
    @update:visible="handleVisibleChange"
    @close="handleClose"
  >
    <template #header-actions>
      <view class="action-pill" @click="handleReset">
        <text class="action-pill-text">Reset</text>
      </view>
      <view class="action-pill action-pill--primary" @click="handleApply">
        <text class="action-pill-text">Apply</text>
      </view>
    </template>

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
  </BottomSheet>
</template>

<script setup>
import { ref, watch } from 'vue'
import BottomSheet from '@/components/ui/BottomSheet.vue'
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

.action-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-1 $spacing-3;
  @include surface-floating($radius-full, $shadow-sm);
  cursor: pointer;

  &:active {
    opacity: 0.7;
  }

  &--primary {
    background: $color-primary;
    border-color: $color-primary;
  }
}

.action-pill-text {
  @include text-caption;
  color: $color-text-secondary;
  font-weight: $font-weight-medium;

  .action-pill--primary & {
    color: #fff;
  }
}

.filter-content {
  max-width: 100%;
  box-sizing: border-box;
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
  @include surface-card-glass($radius-md, $shadow-sm);
  cursor: pointer;
  transition: border-color $transition-normal, box-shadow $transition-normal, opacity $transition-normal;
  box-sizing: border-box;
  max-width: 100%;
  width: 100%;

  &:active {
    opacity: 0.92;
  }

  &.filter-option-selected {
    border-color: rgba($color-primary, 0.45);
    box-shadow: inset 0 0 0 1px rgba($color-primary, 0.2), $shadow-sm;
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
  background: rgba(14, 16, 22, 0.35);
  border: 1px solid $glass-card-border;
  border-radius: $radius-xs;
  backdrop-filter: saturate(140%) blur(8px);
  -webkit-backdrop-filter: saturate(140%) blur(8px);
  transition: border-color $transition-fast, background-color $transition-fast;
  flex-shrink: 0;

  &.checked {
    background: rgba($color-primary, 0.85);
    border-color: rgba(255, 255, 255, 0.28);
  }
}

.checkbox-check {
  color: white;
}
</style>
