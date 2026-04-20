<script>
export default {
  onLaunch: function () {},
  onShow: function () {},
  onHide: function () {},
}
</script>

<style lang="scss">
/* 每个页面公共css */
@import "@/styles/_fonts.scss";
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";
@import "@/styles/_layout.scss";
@import "@/styles/_utilities.scss";
@import "@/styles/_design-language.scss";

page {
  background: $gradient-page;
  font-family: $font-family-body;
  color: $color-text-primary;
  min-height: 100vh;
  letter-spacing: $letter-spacing-normal;
}

view,
text,
button,
input,
textarea {
  box-sizing: border-box;
}

/* Bottom sheets / modals: allow text selection and typing (some parents use pressable user-select: none) */
input,
textarea {
  user-select: text;
  -webkit-user-select: text;
}

/* ---- Global focus polish: native inputs, custom .form-input fields, textareas ---- */
input,
textarea,
.form-input {
  transition:
    border-color $transition-fast,
    box-shadow $transition-fast,
    background-color $transition-fast;
}

input:focus,
textarea:focus,
.form-input:focus,
.form-input:focus-within {
  outline: none;
  border-color: rgba($color-primary, 0.62) !important;
  box-shadow: 0 0 0 3px rgba($color-primary, 0.18) !important;
  background-color: rgba($color-primary, 0.05);
}

/* ---- Page-level entrance: subtle fade so navigations feel intentional ---- */
.layout-container,
.scroll-area > .content-wrapper {
  animation: pageEnter 280ms cubic-bezier(0.22, 1, 0.36, 1) both;
}

@keyframes pageEnter {
  from { opacity: 0; transform: translateY(6px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* ---- Reduced motion: respect OS / browser preference ---- */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* Ensure native uni-app overlays appear above Sheet modals */
uni-picker,
.uni-picker-container,
.uni-system-picker-wrapper {
  z-index: 9999 !important;
}

uni-picker .uni-mask {
  z-index: 9998 !important;
}

/* ---- Picker overlay theming ---- */
.uni-picker-container {
  .uni-mask {
    background: rgba(0, 0, 0, 0.5) !important;
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
  }

  /* Bottom sheet panel */
  .uni-picker-custom {
    background: $color-bg-secondary !important;
    border-radius: $radius-lg $radius-lg 0 0 !important;
    overflow: hidden;
  }

  /* Header bar */
  .uni-picker-header {
    background: $color-bg-secondary !important;
    border-bottom: 1px solid $color-border-subtle !important;
    position: relative;

    &::after {
      display: none !important;
    }
  }

  /* Cancel / Confirm buttons */
  .uni-picker-action {
    font-family: $font-family-body;
    font-size: $font-size-body-sm !important;
    font-weight: $font-weight-medium;
    padding: 0 $spacing-4 !important;
  }

  .uni-picker-action-cancel {
    color: $color-text-tertiary !important;
  }

  .uni-picker-action-confirm {
    color: $color-primary !important;
  }

  /* Scroll wheel area */
  .uni-picker-content {
    background: $color-bg-secondary !important;
  }

  /* Individual option rows */
  .uni-picker-item {
    color: $color-text-primary !important;
    font-family: $font-family-body;
    font-size: $font-size-body-sm !important;
  }

  /* Selected row indicator */
  .uni-picker-view-indicator {
    border: none !important;

    &::before, &::after {
      content: '' !important;
      display: block !important;
      position: absolute !important;
      left: 0 !important;
      right: 0 !important;
      height: 1px !important;
      background: $color-border-subtle !important;
      border: none !important;
      transform: none !important;
    }

    &::before { top: 0 !important; }
    &::after { bottom: 0 !important; }
  }

  /* Gradient mask on scroll columns — overrides white background-image */
  .uni-picker-view-mask {
    background-image:
      linear-gradient(180deg, rgba(17, 17, 17, 0.95), rgba(17, 17, 17, 0)),
      linear-gradient(0deg, rgba(17, 17, 17, 0.95), rgba(17, 17, 17, 0)) !important;
  }
}

/* Desktop popup mode (≥500px) */
@media (min-width: 500px) and (min-height: 500px) {
  .uni-picker-container {
    .uni-picker-custom {
      border-radius: $radius-lg !important;
      box-shadow: $shadow-xl !important;
      background: $color-bg-secondary !important;
    }

    .uni-picker-content {
      background: $color-bg-secondary !important;
    }

    /* Dropdown select mode */
    .uni-picker-select {
      background: $color-bg-elevated !important;
      border: 1px solid $color-border-medium !important;
      border-radius: $radius-sm !important;
      box-shadow: $shadow-lg !important;
    }

    .uni-picker-select .uni-picker-item {
      color: $color-text-primary !important;
      font-family: $font-family-body;
      font-size: $font-size-body-sm !important;

      &:hover {
        background: $color-bg-tertiary !important;
      }
    }
  }
}

/* Global mask override — ensures dark gradient regardless of nesting */
.uni-picker-view-mask {
  background-image:
    linear-gradient(180deg, rgba(17, 17, 17, 0.95), rgba(17, 17, 17, 0)),
    linear-gradient(0deg, rgba(17, 17, 17, 0.95), rgba(17, 17, 17, 0)) !important;
}

.uni-picker-view-indicator {
  &::before {
    border-top-color: $color-border-subtle !important;
  }
  &::after {
    border-bottom-color: $color-border-subtle !important;
  }
}

/* Improve untoggled switch thumb visibility on dark surfaces */
uni-switch .uni-switch-input:not(.uni-switch-input-checked) {
  border-color: $color-border-medium !important;
  background-color: $color-bg-tertiary !important;
}

uni-switch .uni-switch-input:not(.uni-switch-input-checked)::before {
  background-color: $color-bg-elevated !important;
}

uni-switch .uni-switch-input:not(.uni-switch-input-checked)::after {
  background-color: #f2f4f8 !important;
  border: 1px solid rgba(15, 23, 42, 0.18) !important;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.45) !important;
}
</style>
