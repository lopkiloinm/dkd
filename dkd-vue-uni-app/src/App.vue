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

<style>
/* 每个页面公共css */
page {
  /* Apple glassmorphism requires a colorful/interesting background to pop */
  background-color: #f2f2f7;
  background-image: radial-gradient(at 40% 20%, rgba(255, 189, 132, 0.4) 0px, transparent 50%),
                    radial-gradient(at 80% 0%, rgba(100, 210, 255, 0.4) 0px, transparent 50%),
                    radial-gradient(at 0% 50%, rgba(255, 150, 170, 0.4) 0px, transparent 50%);
  background-attachment: fixed;
  font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
  color: #1d1d1f;
  min-height: 100vh;
}
</style>
