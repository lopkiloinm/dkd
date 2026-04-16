<template>
  <view class="breadcrumb">
    <view
      v-for="(item, index) in items"
      :key="index"
      class="breadcrumb-item"
      :class="{ 'breadcrumb-item-last': index === items.length - 1 }"
      @click="handleClick(item, index)"
    >
      <text class="breadcrumb-text">{{ item.label }}</text>
      <text v-if="index < items.length - 1" class="breadcrumb-separator">/</text>
    </view>
  </view>
</template>

<script setup>
const props = defineProps({
  items: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['click'])

const handleClick = (item, index) => {
  emit('click', item, index)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.breadcrumb {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: $spacing-2;
}

.breadcrumb-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  transition: color $transition-normal;
  
  &:not(.breadcrumb-item-last):active {
    opacity: 0.7;
  }
  
  &.breadcrumb-item-last {
    cursor: default;
  }
}

.breadcrumb-text {
  @include text-caption;
  color: $color-text-secondary;
  
  .breadcrumb-item:last-child & {
    color: $color-text-primary;
    font-weight: $font-weight-semibold;
  }
}

.breadcrumb-separator {
  @include text-caption;
  color: $color-text-tertiary;
  margin-left: $spacing-2;
}
</style>
