<template>
  <view class="layout-container">
    <Card class="login-card">
      <view class="login-header">
        <text class="title">{{ $t('login.title') }}</text>
        <text class="subtitle">Welcome back to DiKeDe Management</text>
      </view>

      <view class="login-form">
        <FormField label="Username">
          <Input v-model="form.username" placeholder="Please enter your username" />
        </FormField>

        <FormField label="Password">
          <Input v-model="form.password" type="password" placeholder="Please enter your password" />
        </FormField>

        <FormField v-if="captchaEnabled" label="Verification Code">
          <view class="captcha-row">
            <Input v-model="form.code" placeholder="Captcha" class="captcha-input" />
            <image class="captcha-img" :src="codeUrl" @click="getCode" mode="aspectFit"></image>
          </view>
        </FormField>

        <Button variant="primary" size="lg" block @click="handleLogin" :loading="loading" :disabled="loading">
          {{ loading ? 'Signing in...' : $t('common.confirm') }}
        </Button>
      </view>
    </Card>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { login, getCodeImg, getInfo } from '@/api/login'
import useUserStore from '@/store/modules/user'
import { useI18n } from 'vue-i18n'
import Card from '@/components/ui/Card.vue'
import Input from '@/components/ui/Input.vue'
import Button from '@/components/ui/Button.vue'
import FormField from '@/components/ui/FormField.vue'

const { t } = useI18n()
const userStore = useUserStore()

const form = ref({
  username: '',
  password: '',
  code: '',
  uuid: ''
})

const codeUrl = ref('')
const captchaEnabled = ref(true)
const loading = ref(false)

const getCode = async () => {
  try {
    const res = await getCodeImg()
    captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
    if (captchaEnabled.value && res.img) {
      codeUrl.value = 'data:image/gif;base64,' + res.img
      form.value.uuid = res.uuid
    }
  } catch (error) {
    console.error('Failed to get captcha', error)
    uni.showToast({ title: 'Failed to load captcha. Tap to retry.', icon: 'none' })
  }
}

onMounted(() => {
  getCode()
})

const handleLogin = async () => {
  if (!form.value.username || !form.value.password) {
    uni.showToast({ title: 'Please fill out all fields', icon: 'none' })
    return
  }
  if (captchaEnabled.value && !form.value.code) {
    uni.showToast({ title: 'Please enter captcha', icon: 'none' })
    return
  }
  
  try {
    loading.value = true
    const res = await login(form.value.username, form.value.password, form.value.code, form.value.uuid)
    
    if (res.token) {
      userStore.setToken(res.token)
      // Fetch user info from backend using the token
      try {
        const userInfo = await getInfo()
        if (userInfo && userInfo.user) {
          userStore.setUserInfo({
            name: userInfo.user.nickName || userInfo.user.userName,
            avatar: userInfo.user.avatar,
            roles: userInfo.roles,
            permissions: userInfo.permissions
          })
        }
      } catch (infoError) {
        console.error('Failed to fetch user info after login', infoError)
        // Fallback to username from login form
        userStore.setUserInfo({
          name: form.value.username,
          avatar: '',
          roles: [],
          permissions: []
        })
      }
      uni.showToast({ title: 'Login success', icon: 'success' })
      setTimeout(() => {
        uni.reLaunch({ url: '/pages/index/index' })
      }, 1000)
    }
  } catch (error) {
    console.error('Login error', error)
    if (captchaEnabled.value) {
      getCode()
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
@import "@/styles/_variables.scss";
@import "@/styles/_mixins.scss";

.layout-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: $spacing-6;
  box-sizing: border-box;
  background: $color-bg-primary;
}

.login-card {
  width: 100%;
  max-width: 400px;
  padding: $spacing-10 $spacing-6;
  background: $color-bg-secondary;
  border-radius: $radius-lg;
  border: 1px solid $color-border-subtle;
}

.login-header {
  margin-bottom: $spacing-10;
  text-align: center;
}

.title {
  @include text-display($font-size-display-md, $font-weight-bold);
  color: $color-text-primary;
  display: block;
  margin-bottom: $spacing-2;
  letter-spacing: -0.5px;
}

.subtitle {
  @include text-body($font-size-body-sm, $font-weight-regular);
  color: $color-text-secondary;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: $spacing-5;
}

.captcha-row {
  display: flex;
  align-items: center;
  gap: $spacing-3;
}

.captcha-input {
  flex: 1;
}

.captcha-img {
  width: 120px;
  height: $touch-target-min;
  border-radius: $radius-md;
  background-color: $color-bg-tertiary;
  border: 1px solid $color-border-subtle;
  cursor: pointer;
}
</style>
