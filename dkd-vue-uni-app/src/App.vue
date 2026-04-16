<script>
export default {
  onLaunch: function () {
    console.log('App Launch')
  },
  onShow: function () {
    console.log('App Show')
  },
  onHide: function () {
    console.log('App Hide')
  },
}
</script>

<style lang="scss">
/* 每个页面公共css */
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
</style>
