<template>
  <view :class="avatarClasses" :style="avatarStyle">
    <image v-if="src" :src="src" class="avatar-image" @error="handleImageError" />
    <text v-else class="avatar-text">{{ initials }}</text>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'

const props = defineProps({
  src: {
    type: String,
    default: ''
  },
  alt: {
    type: String,
    default: ''
  },
  size: {
    type: String,
    default: 'md',
    validator: (value) => ['xs', 'sm', 'md', 'lg', 'xl'].includes(value)
  },
  shape: {
    type: String,
    default: 'circle',
    validator: (value) => ['circle', 'square'].includes(value)
  }
})

const imageError = ref(false)

const avatarClasses = computed(() => {
  return [
    'avatar',
    `avatar-${props.size}`,
    `avatar-${props.shape}`
  ]
})

const avatarStyle = computed(() => {
  const sizes = {
    xs: '24px',
    sm: '32px',
    md: '40px',
    lg: '48px',
    xl: '64px'
  }
  return {
    width: sizes[props.size],
    height: sizes[props.size]
  }
})

const initials = computed(() => {
  if (props.alt) {
    return props.alt
      .split(' ')
      .map(word => word.charAt(0).toUpperCase())
      .slice(0, 2)
      .join('')
  }
  return '?'
})

const handleImageError = () => {
  imageError.value = true
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";

.avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, $color-primary, $color-secondary);
  color: $color-text-primary;
  font-family: $font-family-body;
  font-weight: $font-weight-semibold;
  overflow: hidden;
  margin: 0;
  padding: 0;

  &.avatar-circle {
    border-radius: 50%;
  }

  &.avatar-square {
    border-radius: $radius-md;
  }

  &.avatar-xs {
    font-size: 10px;
  }

  &.avatar-sm {
    font-size: 12px;
  }

  &.avatar-md {
    font-size: 14px;
  }

  &.avatar-lg {
    font-size: 18px;
  }

  &.avatar-xl {
    font-size: 24px;
  }
}

.avatar-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-text {
  user-select: none;
}
</style>
