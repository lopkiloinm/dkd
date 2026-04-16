<template>
  <Card :padding="padding" :radius="radius">
    <template v-if="$slots.header" #header>
      <CardSection variant="header">
        <slot name="header"></slot>
      </CardSection>
    </template>
    <CardSection variant="body">
      <view class="chart-card-content">
        <slot></slot>
      </view>
    </CardSection>
    <template v-if="$slots.footer" #footer>
      <CardSection variant="footer">
        <slot name="footer"></slot>
      </CardSection>
    </template>
  </Card>
</template>

<script setup>
import Card from '@/components/ui/Card.vue'
import CardSection from '@/components/ui/CardSection.vue'

const props = defineProps({
  padding: {
    type: String,
    default: 'md'
  },
  radius: {
    type: String,
    default: 'md'
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.chart-card-content {
  min-height: 200px;
}
</style>
