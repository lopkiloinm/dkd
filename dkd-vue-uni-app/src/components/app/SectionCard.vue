<template>
  <Card :padding="padding" :radius="radius" :hoverable="clickable" @click="handleClick">
    <view class="section-card">
      <view class="section-header">
        <text class="section-title">{{ title }}</text>
      </view>
      <view class="section-stats">
        <slot name="stats">
          <text class="stats-text">{{ stats }}</text>
        </slot>
      </view>
    </view>
  </Card>
</template>

<script setup>
import Card from '@/components/ui/Card.vue'

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  stats: {
    type: String,
    default: ''
  },
  clickable: {
    type: Boolean,
    default: true
  },
  padding: {
    type: String,
    default: 'md'
  },
  radius: {
    type: String,
    default: 'md'
  }
})

const emit = defineEmits(['click'])

const handleClick = () => {
  if (props.clickable) {
    emit('click')
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.section-card {
  display: flex;
  flex-direction: column;
  gap: $spacing-3;
}

.section-header {
  display: flex;
  align-items: center;
}

.section-title {
  @include text-body;
  color: $color-text-primary;
  font-weight: $font-weight-semibold;
}

.section-stats {
  margin-top: $spacing-1;
}

.stats-text {
  @include text-caption;
  color: $color-text-secondary;
}
</style>
