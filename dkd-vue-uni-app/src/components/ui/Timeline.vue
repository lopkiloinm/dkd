<template>
  <view class="timeline">
    <view
      v-for="(item, index) in items"
      :key="index"
      class="timeline-item"
    >
      <view class="timeline-marker">
        <view class="marker-dot"></view>
      </view>
      <view class="timeline-content">
        <slot name="content" :item="item" :index="index">
          <text class="timeline-title">{{ item.title }}</text>
          <text v-if="item.description" class="timeline-description">{{ item.description }}</text>
          <text v-if="item.time" class="timeline-time">{{ item.time }}</text>
        </slot>
      </view>
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
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.timeline {
  display: flex;
  flex-direction: column;
  gap: $spacing-4;
}

.timeline-item {
  display: flex;
  gap: $spacing-4;
}

.timeline-marker {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex-shrink: 0;
  width: 20px;
  
  &::after {
    content: '';
    flex: 1;
    width: 2px;
    background: $color-border-subtle;
  }
  
  &:last-child::after {
    display: none;
  }
}

.marker-dot {
  width: 12px;
  height: 12px;
  background: $color-primary;
  border: 3px solid $color-bg-secondary;
  border-radius: 50%;
  box-shadow: 0 0 0 2px $color-primary;
}

.timeline-content {
  flex: 1;
  padding-bottom: $spacing-4;
}

.timeline-title {
  display: block;
  @include text-title;
  color: $color-text-primary;
  margin-bottom: $spacing-1;
}

.timeline-description {
  display: block;
  @include text-body;
  color: $color-text-secondary;
  margin-bottom: $spacing-1;
}

.timeline-time {
  display: block;
  @include text-caption;
  color: $color-text-tertiary;
}
</style>
