<template>
  <view class="accordion">
    <view
      v-for="(item, index) in items"
      :key="index"
      class="accordion-item"
    >
      <view class="accordion-header" @click="handleToggle(index)">
        <slot name="header" :item="item" :index="index" :expanded="expandedIndex === index">
          {{ item.title }}
        </slot>
        <view class="accordion-icon" :class="{ 'accordion-icon-expanded': expandedIndex === index }">
          <Icon name="chevron-down" size="20" color="currentColor" />
        </view>
      </view>
      <view v-if="expandedIndex === index" class="accordion-body">
        <slot name="body" :item="item" :index="index">
          {{ item.content }}
        </slot>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import Icon from '@/components/ui/Icon.vue'

const props = defineProps({
  items: {
    type: Array,
    default: () => []
  },
  multiple: {
    type: Boolean,
    default: false
  }
})

const expandedIndex = ref(-1)

const handleToggle = (index) => {
  if (props.multiple) {
    // For multiple expanded items, we'd need a Set or array
    // For now, simple toggle
    expandedIndex.value = expandedIndex.value === index ? -1 : index
  } else {
    expandedIndex.value = expandedIndex.value === index ? -1 : index
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.accordion {
  background: $color-bg-secondary;
  border-radius: $radius-md;
  overflow: hidden;
}

.accordion-item {
  &:last-child {
    border-bottom: none;
  }
}

.accordion-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: $spacing-4;
  cursor: pointer;
  transition: background-color $transition-normal;
  
  &:active {
    background: $color-bg-tertiary;
  }
}

.accordion-icon {
  margin-left: $spacing-3;
  transition: transform $transition-normal;
  
  &.accordion-icon-expanded {
    transform: rotate(90deg);
  }
  
  .icon {
    font-size: 24px;
    line-height: 1;
    color: $color-text-secondary;
  }
}

.accordion-body {
  padding: $spacing-4;
  border-top: 1px solid $color-border-subtle;
  background: $color-bg-tertiary;
}
</style>
