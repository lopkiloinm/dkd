<template>
  <view :class="tabsClasses">
    <scroll-view class="tabs-scroll" scroll-x :show-scrollbar="false">
      <view class="tabs-list">
        <view
          v-for="(tab, index) in tabs"
          :key="index"
          :class="tabClasses(tab)"
          @click="handleTabClick(index)"
        >
          <slot name="tab" :tab="tab" :index="index">
            {{ tab.label }}
          </slot>
        </view>
        <view class="tabs-indicator" :style="indicatorStyle"></view>
      </view>
    </scroll-view>
  </view>
</template>

<script setup>
import { computed, ref, nextTick, onMounted } from 'vue'

const props = defineProps({
  tabs: {
    type: Array,
    default: () => []
  },
  modelValue: {
    type: Number,
    default: 0
  },
  variant: {
    type: String,
    default: 'default',
    validator: (value) => ['default', 'segmented', 'pills'].includes(value)
  }
})

const emit = defineEmits(['update:modelValue', 'change'])

const tabsList = ref(null)
const tabWidths = ref([])

const tabsClasses = computed(() => {
  return [
    'tabs',
    `tabs-${props.variant}`
  ]
})

const tabClasses = (tab) => {
  return [
    'tab-item',
    {
      'tab-active': props.tabs.indexOf(tab) === props.modelValue
    }
  ]
}

const indicatorStyle = computed(() => {
  if (props.variant === 'default') {
    const activeIndex = props.modelValue
    let left = 0
    for (let i = 0; i < activeIndex; i++) {
      left += tabWidths.value[i] || 0
    }
    return {
      left: left + 'px',
      width: (tabWidths.value[activeIndex] || 0) + 'px'
    }
  }
  return {}
})

const handleTabClick = (index) => {
  emit('update:modelValue', index)
  emit('change', index, props.tabs[index])
}

const measureTabWidths = () => {
  nextTick(() => {
    const tabItems = tabsList.value?.children || []
    tabWidths.value = Array.from(tabItems).map(item => item.offsetWidth)
  })
}

onMounted(() => {
  measureTabWidths()
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.tabs {
  background: $color-bg-secondary;
  
  &.tabs-segmented {
    background: transparent;
  }
  
  &.tabs-pills {
    background: transparent;
  }
}

.tabs-scroll {
  width: 100%;
  @include scrollbar-hidden;
}

.tabs-list {
  position: relative;
  display: flex;
  min-width: 100%;
}

.tab-item {
  position: relative;
  flex-shrink: 0;
  padding: $spacing-3 $spacing-4;
  font-family: $font-family-body;
  font-size: $font-size-body-md;
  font-weight: $font-weight-medium;
  color: $color-text-secondary;
  cursor: pointer;
  transition: all $transition-normal;
  white-space: nowrap;
  
  &:active {
    opacity: 0.7;
  }
  
  &.tab-active {
    color: $color-text-primary;
  }
}

.tabs-indicator {
  position: absolute;
  bottom: 0;
  height: 2px;
  background: $color-primary;
  border-radius: 1px;
  transition: all $transition-normal ease-out;
}

.tabs-segmented {
  .tabs-list {
    background: $color-bg-tertiary;
    border-radius: $radius-sm;
    padding: $spacing-1;
  }
  
  .tab-item {
    padding: $spacing-2 $spacing-4;
    border-radius: $radius-sm;
    color: $color-text-secondary;
    
    &.tab-active {
      background: $color-bg-secondary;
      color: $color-text-primary;
      box-shadow: $shadow-sm;
    }
  }
  
  .tabs-indicator {
    display: none;
  }
}

.tabs-pills {
  .tabs-list {
    gap: $spacing-2;
  }
  
  .tab-item {
    padding: $spacing-2 $spacing-4;
    border-radius: $radius-full;
    background: $color-bg-tertiary;
    color: $color-text-secondary;
    
    &.tab-active {
      background: $color-primary;
      color: $color-text-primary;
    }
  }
  
  .tabs-indicator {
    display: none;
  }
}
</style>
