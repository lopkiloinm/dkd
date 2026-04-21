<template>
  <!-- Backdrop and panel are siblings inside a neutral mount so the panel is not a
       descendant of a `backdrop-filter` layer (which breaks fixed positioning + native inputs). -->
  <view v-if="mounted" class="sheet-mount">
    <transition name="sheet-fade" appear>
      <view
        v-if="visible"
        class="sheet-backdrop"
        @click="handleBackdropClick"
        @tap="handleBackdropClick"
      />
    </transition>
    <transition :name="`sheet-slide-${position}`" appear @after-leave="mounted = false">
      <view
        v-if="visible"
        :class="sheetClasses"
        :style="sheetStyle"
        @click.stop
        @tap.stop
        @touchstart="onTouchStart"
        @touchmove="onTouchMove"
        @touchend="onTouchEnd"
        @touchcancel="onTouchEnd"
      >
        <view v-if="$slots.header" class="sheet-header">
          <slot name="header"></slot>
        </view>
        <view class="sheet-body" ref="bodyRef" @scroll="onBodyScroll">
          <view class="sheet-body-inner">
            <slot></slot>
          </view>
        </view>
        <view v-if="$slots.footer" class="sheet-footer">
          <slot name="footer"></slot>
        </view>
      </view>
    </transition>
  </view>
</template>

<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  position: {
    type: String,
    default: 'bottom',
    validator: (value) => ['bottom', 'top', 'left', 'right'].includes(value)
  },
  closeOnOverlayClick: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:visible', 'close'])

/* `mounted` keeps the mount node in the DOM during the leave transition
   so the slide-out animation can play before unmount. It flips false in
   `@after-leave`. */
const mounted = ref(props.visible)
watch(() => props.visible, (val) => {
  if (val) mounted.value = true
})

const sheetClasses = computed(() => {
  return [
    'sheet',
    `sheet-${props.position}`,
    { 'sheet--dragging': dragging.value }
  ]
})

/* ---- Drag-to-dismiss (bottom sheet only) -------------------------------
   Follows finger, snaps back below threshold, dismisses past threshold or
   when flung. Drags initiated on the scrollable body only engage when the
   body is at scrollTop === 0 and the user pulls downward, so vertical
   scrolling inside the sheet still works.
----------------------------------------------------------------------- */
const DISMISS_DISTANCE = 120   // px past which release dismisses
const DISMISS_VELOCITY = 0.6   // px/ms — fast flick dismisses regardless of distance

const dragging = ref(false)
const dragOffset = ref(0)
const bodyRef = ref(null)
const bodyScrollTop = ref(0)

let touchStartY = 0
let touchStartX = 0
let lastY = 0
let lastT = 0
let velocityY = 0
let axisLocked = false   // once we've decided vertical vs horizontal
let isVerticalDrag = false
let engaged = false      // we've claimed the gesture for dismiss

const isDraggable = computed(() => props.position === 'bottom')

const sheetStyle = computed(() => {
  if (!dragging.value || dragOffset.value <= 0) return ''
  return `transform: translateY(${dragOffset.value}px);`
})

const onBodyScroll = (e) => {
  bodyScrollTop.value = e.target?.scrollTop ?? 0
}

const onTouchStart = (e) => {
  if (!isDraggable.value) return
  const t = e.touches?.[0]
  if (!t) return
  touchStartY = t.clientY
  touchStartX = t.clientX
  lastY = t.clientY
  lastT = Date.now()
  velocityY = 0
  axisLocked = false
  isVerticalDrag = false
  engaged = false
  dragOffset.value = 0
}

const onTouchMove = (e) => {
  if (!isDraggable.value) return
  const t = e.touches?.[0]
  if (!t) return
  const dy = t.clientY - touchStartY
  const dx = t.clientX - touchStartX

  // Lock axis once we've moved enough to decide direction
  if (!axisLocked && (Math.abs(dy) > 6 || Math.abs(dx) > 6)) {
    axisLocked = true
    isVerticalDrag = Math.abs(dy) > Math.abs(dx)
  }
  if (!axisLocked || !isVerticalDrag) return

  // Engage only on downward drag, and only if the body isn't scrolled
  if (!engaged) {
    if (dy <= 0) return
    if (bodyScrollTop.value > 0) return
    engaged = true
    dragging.value = true
  }

  // Track velocity (px/ms)
  const now = Date.now()
  const dt = Math.max(now - lastT, 1)
  velocityY = (t.clientY - lastY) / dt
  lastY = t.clientY
  lastT = now

  // Resist upward drag past origin with rubber-band
  let offset = dy
  if (offset < 0) offset = -Math.sqrt(-offset * 6)
  dragOffset.value = offset

  // Prevent page scroll / pull-to-refresh while engaged
  if (e.cancelable) e.preventDefault()
}

const onTouchEnd = () => {
  if (!isDraggable.value) return
  if (!engaged) {
    dragging.value = false
    dragOffset.value = 0
    return
  }
  const shouldDismiss =
    dragOffset.value > DISMISS_DISTANCE ||
    (velocityY > DISMISS_VELOCITY && dragOffset.value > 24)

  if (shouldDismiss) {
    // Let the leave transition take it the rest of the way.
    dragOffset.value = 0
    dragging.value = false
    emit('update:visible', false)
    emit('close')
  } else {
    // Snap back with a CSS transition.
    dragging.value = false
    dragOffset.value = 0
  }
  engaged = false
}

const handleBackdropClick = () => {
  if (props.closeOnOverlayClick) {
    emit('update:visible', false)
    emit('close')
  }
}

watch(() => props.visible, (newVal) => {
  if (typeof document === 'undefined') return
  if (newVal) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = ''
  }
})
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.sheet-mount {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: $z-index-modal-backdrop;
  pointer-events: auto;
}

.sheet-backdrop {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 0;
  @include overlay-scrim-flat;
}

.sheet {
  position: absolute;
  z-index: 1;
  max-width: 100vw;
  @include surface-modal-glass($radius-lg, $shadow-xl);
  backdrop-filter: none !important;
  -webkit-backdrop-filter: none !important;
  isolation: auto !important;
  background: $glass-card-shine, rgba(18, 20, 28, 0.96);
  /* No idle transition on the panel itself; motion is owned by the
     wrapping <transition> below so enter/leave can use spring curves.
     During a drag we suppress transitions; on release the snap-back
     uses a short spring. */
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  width: 100%;
  pointer-events: auto;
  will-change: transform, opacity;
  transition: transform 220ms cubic-bezier(0.22, 1, 0.36, 1);

  &.sheet--dragging {
    transition: none;
  }

  &.sheet-bottom {
    bottom: 0;
    left: 0;
    right: 0;
    border-radius: $radius-lg $radius-lg 0 0;
    max-height: 85vh;
  }

  &.sheet-top {
    top: 0;
    left: 0;
    right: 0;
    border-radius: 0 0 $radius-lg $radius-lg;
    max-height: 85vh;
  }

  &.sheet-left {
    top: 0;
    bottom: 0;
    left: 0;
    width: 80%;
    max-width: 400px;
    border-radius: 0 $radius-lg $radius-lg 0;
  }

  &.sheet-right {
    top: 0;
    bottom: 0;
    right: 0;
    width: 80%;
    max-width: 400px;
    border-radius: $radius-lg 0 0 $radius-lg;
  }
}

.sheet-header {
  flex-shrink: 0;
  border-bottom: 1px solid rgba(255, 255, 255, 0.08);
}

.sheet-body {
  flex: 1 1 auto;
  min-height: 0;
  box-sizing: border-box;
  overflow-x: hidden;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  @include scrollbar-hidden;
}

.sheet-body-inner {
  box-sizing: border-box;
}

.sheet-footer {
  flex-shrink: 0;
}

/* ---- Motion ----------------------------------------------------------
   Backdrop fades. Panel slides in from the docked edge with a soft
   spring-feel curve and a subtle scale on enter so it feels lifted.
--------------------------------------------------------------------- */
$sheet-spring: cubic-bezier(0.22, 1, 0.36, 1);
$sheet-out:    cubic-bezier(0.4, 0, 0.6, 1);

.sheet-fade-enter-active,
.sheet-fade-leave-active {
  transition: opacity 240ms $sheet-out;
}
.sheet-fade-enter-from,
.sheet-fade-leave-to { opacity: 0; }

/* Bottom sheet — slide up + slight lift */
.sheet-slide-bottom-enter-active {
  transition: transform 360ms $sheet-spring, opacity 240ms ease-out;
}
.sheet-slide-bottom-leave-active {
  transition: transform 260ms $sheet-out, opacity 200ms ease-in;
}
.sheet-slide-bottom-enter-from {
  transform: translateY(110%);
  opacity: 0.6;
}
.sheet-slide-bottom-leave-to {
  transform: translateY(110%);
  opacity: 0;
}

/* Top sheet */
.sheet-slide-top-enter-active {
  transition: transform 360ms $sheet-spring, opacity 240ms ease-out;
}
.sheet-slide-top-leave-active {
  transition: transform 260ms $sheet-out, opacity 200ms ease-in;
}
.sheet-slide-top-enter-from,
.sheet-slide-top-leave-to {
  transform: translateY(-110%);
  opacity: 0;
}

/* Left drawer */
.sheet-slide-left-enter-active {
  transition: transform 340ms $sheet-spring, opacity 220ms ease-out;
}
.sheet-slide-left-leave-active {
  transition: transform 240ms $sheet-out, opacity 180ms ease-in;
}
.sheet-slide-left-enter-from,
.sheet-slide-left-leave-to {
  transform: translateX(-100%);
  opacity: 0.7;
}

/* Right drawer */
.sheet-slide-right-enter-active {
  transition: transform 340ms $sheet-spring, opacity 220ms ease-out;
}
.sheet-slide-right-leave-active {
  transition: transform 240ms $sheet-out, opacity 180ms ease-in;
}
.sheet-slide-right-enter-from,
.sheet-slide-right-leave-to {
  transform: translateX(100%);
  opacity: 0.7;
}
</style>
