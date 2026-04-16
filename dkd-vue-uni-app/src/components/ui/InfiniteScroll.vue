<template>
  <scroll-view
    class="infinite-scroll"
    scroll-y
    @scrolltolower="handleLoadMore"
    :lower-threshold="100"
  >
    <slot></slot>
    <view v-if="loading" class="loading-more">
      <view class="spinner"></view>
      <text class="loading-text">Loading more...</text>
    </view>
    <view v-if="!hasMore && !loading" class="no-more">
      <text class="no-more-text">No more items</text>
    </view>
  </scroll-view>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  loading: {
    type: Boolean,
    default: false
  },
  hasMore: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['load-more'])

const handleLoadMore = () => {
  if (!props.loading && props.hasMore) {
    emit('load-more')
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.infinite-scroll {
  height: 100%;
}

.loading-more {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: $spacing-4;
  gap: $spacing-2;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid $color-border-medium;
  border-top-color: $color-primary;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

.loading-text {
  @include text-caption;
  color: $color-text-secondary;
}

.no-more {
  padding: $spacing-4;
  text-align: center;
}

.no-more-text {
  @include text-caption;
  color: $color-text-tertiary;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
</style>
