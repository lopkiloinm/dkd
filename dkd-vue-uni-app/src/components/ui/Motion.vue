<template>
  <view :class="motionClasses" :style="motionStyle">
    <slot></slot>
  </view>
</template>

<script setup>
import { computed } from 'vue'

/**
 * Motion — a tiny, uni-app cross-platform entrance-animation wrapper.
 *
 * Why not @vueuse/motion or motion-v?
 * Those rely on Web Animations API or DOM observers that are not available on
 * WeChat MiniProgram, App-V3, or other non-H5 uni-app targets. CSS keyframes
 * compile down identically across every uni-app platform, so this wrapper
 * gives consistent results everywhere.
 */
const props = defineProps({
  preset: {
    type: String,
    default: 'fade-up',
    validator: (v) => ['fade', 'fade-up', 'fade-down', 'scale', 'slide-left', 'slide-right'].includes(v)
  },
  /** Stagger index (0-based). Each step adds `step` ms to the animation-delay. */
  index: { type: Number, default: 0 },
  step: { type: Number, default: 60 },
  /** Total duration in ms. */
  duration: { type: Number, default: 320 },
  /** Custom delay in ms (added on top of staggered index). */
  delay: { type: Number, default: 0 },
  disabled: { type: Boolean, default: false }
})

const motionClasses = computed(() => [
  'motion',
  `motion-${props.preset}`,
  { 'motion-disabled': props.disabled }
])

const motionStyle = computed(() => {
  if (props.disabled) return {}
  const totalDelay = props.delay + props.index * props.step
  return {
    'animation-duration': `${props.duration}ms`,
    'animation-delay': `${totalDelay}ms`
  }
})
</script>

<style scoped lang="scss">
.motion {
  display: block;
  will-change: transform, opacity;
  animation-fill-mode: both;
  animation-timing-function: cubic-bezier(0.22, 1, 0.36, 1);
}

.motion-disabled {
  animation: none !important;
}

.motion-fade { animation-name: motionFade; }
.motion-fade-up { animation-name: motionFadeUp; }
.motion-fade-down { animation-name: motionFadeDown; }
.motion-scale { animation-name: motionScale; }
.motion-slide-left { animation-name: motionSlideLeft; }
.motion-slide-right { animation-name: motionSlideRight; }

@keyframes motionFade {
  from { opacity: 0; }
  to   { opacity: 1; }
}
@keyframes motionFadeUp {
  from { opacity: 0; transform: translateY(16px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes motionFadeDown {
  from { opacity: 0; transform: translateY(-16px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes motionScale {
  from { opacity: 0; transform: scale(0.92); }
  to   { opacity: 1; transform: scale(1); }
}
@keyframes motionSlideLeft {
  from { opacity: 0; transform: translateX(20px); }
  to   { opacity: 1; transform: translateX(0); }
}
@keyframes motionSlideRight {
  from { opacity: 0; transform: translateX(-20px); }
  to   { opacity: 1; transform: translateX(0); }
}
</style>
