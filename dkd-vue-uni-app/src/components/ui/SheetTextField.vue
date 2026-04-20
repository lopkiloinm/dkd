<template>
  <!--
    Outer `view` is layout-only. The `textarea` uses `input-native-glass` (same glass language
    as search bars / native glass inputs), not flat `.form-picker` fills.
  -->
  <view
    class="sheet-field"
    :class="{
      'sheet-field--single': !multiline,
      'sheet-field--multi': multiline
    }"
  >
    <textarea
      class="sheet-field__textarea"
      :class="{
        'sheet-field__textarea--single': !multiline,
        'sheet-field__textarea--multi': multiline
      }"
      :value="displayValue"
      :placeholder="placeholder"
      :auto-height="multiline && autoHeight"
      :confirm-type="confirmType"
      :adjust-position="adjustPosition"
      @input="onInput"
    />
  </view>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  modelValue: {
    type: [String, Number],
    default: ''
  },
  placeholder: {
    type: String,
    default: ''
  },
  multiline: {
    type: Boolean,
    default: false
  },
  numeric: {
    type: Boolean,
    default: false
  },
  allowDecimal: {
    type: Boolean,
    default: false
  },
  autoHeight: {
    type: Boolean,
    default: true
  },
  confirmType: {
    type: String,
    default: 'done'
  },
  adjustPosition: {
    type: Boolean,
    default: true
  }
})

const emit = defineEmits(['update:modelValue'])

const displayValue = computed(() => {
  const v = props.modelValue
  if (v === null || v === undefined || v === '') return ''
  return String(v)
})

const onInput = (e) => {
  let v = e?.detail?.value ?? ''
  if (!props.multiline) {
    v = v.replace(/\r?\n/g, '')
  }
  if (props.numeric) {
    if (props.allowDecimal) {
      v = String(v).replace(/[^\d.]/g, '')
      const i = v.indexOf('.')
      if (i !== -1) {
        v = v.slice(0, i + 1) + v.slice(i + 1).replace(/\./g, '')
      }
    } else {
      v = String(v).replace(/\D/g, '')
    }
  }
  emit('update:modelValue', v)
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

/* Same total height as `.form-picker` row (padding + one line + borders, border-box). */
$sheet-control-row-height: calc(
  #{$spacing-3} + #{$spacing-3} + (#{$font-size-body-md} * #{$line-height-normal}) + 2px
);

.sheet-field {
  width: 100%;
  box-sizing: border-box;
  position: relative;
  z-index: 2;
}

.sheet-field--single,
.sheet-field--multi {
  display: block;
}

/* Glass: same `input-native-glass` as search / glass inputs; blur tuned to card tokens. */
.sheet-field__textarea--single {
  @include input-native-glass;
  @include text-body;
  line-height: $line-height-normal;
  display: block;
  width: 100%;
  margin: 0;
  box-sizing: border-box;
  padding: $spacing-3;
  height: $sheet-control-row-height;
  min-height: $sheet-control-row-height;
  max-height: $sheet-control-row-height;
  overflow: hidden;
  resize: none;
  isolation: isolate;
  backdrop-filter: saturate($glass-card-saturate) blur($glass-card-blur);
  -webkit-backdrop-filter: saturate($glass-card-saturate) blur($glass-card-blur);
  background: $glass-card-shine, $glass-card-fill;
  box-shadow: $shadow-sm, inset 0 1px 0 rgba(255, 255, 255, 0.07), 0 1px 0 rgba(0, 0, 0, 0.12);
}

.sheet-field__textarea--multi {
  @include input-native-glass;
  @include text-body;
  line-height: $line-height-normal;
  border-radius: $radius-lg;
  display: block;
  width: 100%;
  margin: 0;
  box-sizing: border-box;
  padding: $spacing-3;
  min-height: calc(
    #{$spacing-3} + #{$spacing-3} + (3 * #{$font-size-body-md} * #{$line-height-normal})
  );
  max-height: 36vh;
  overflow-y: auto;
  resize: none;
  isolation: isolate;
  backdrop-filter: saturate($glass-card-saturate) blur($glass-card-blur);
  -webkit-backdrop-filter: saturate($glass-card-saturate) blur($glass-card-blur);
  background: $glass-card-shine, $glass-card-fill;
  box-shadow: $shadow-sm, inset 0 1px 0 rgba(255, 255, 255, 0.07), 0 1px 0 rgba(0, 0, 0, 0.12);
}
</style>
