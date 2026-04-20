<template>
  <Card padding="none" :radius="radius">
    <template v-if="$slots.header" #header>
      <CardSection variant="header" :padding="padding">
        <slot name="header"></slot>
      </CardSection>
    </template>
    <CardSection variant="body" :padding="padding">
      <view class="chart-card-content">
        <slot></slot>
      </view>
    </CardSection>
    <template v-if="$slots.footer" #footer>
      <CardSection variant="footer" :padding="padding">
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
