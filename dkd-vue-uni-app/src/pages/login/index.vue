<template>
  <view class="layout-container">
    <view class="login-card">
      <view class="login-header">
        <text class="title">{{ $t('login.title') }}</text>
        <text class="subtitle">Welcome back to DiKeDe Management</text>
      </view>
      
      <view class="n-form">
        <view class="n-form-item">
          <text class="n-form-label">Username</text>
          <input class="n-input" v-model="form.username" placeholder="Please enter your username" placeholder-class="n-input-placeholder" />
        </view>
        
        <view class="n-form-item">
          <text class="n-form-label">Password</text>
          <input class="n-input" type="password" v-model="form.password" placeholder="Please enter your password" placeholder-class="n-input-placeholder" />
        </view>
        
        <view class="n-form-item" v-if="captchaEnabled">
          <text class="n-form-label">Verification Code</text>
          <view class="captcha-row">
            <input class="n-input n-input-captcha" v-model="form.code" placeholder="Captcha" placeholder-class="n-input-placeholder" />
            <image class="captcha-img" :src="codeUrl" @click="getCode" mode="aspectFit"></image>
          </view>
        </view>
        
        <button class="n-button n-button-primary" @click="handleLogin" :loading="loading" :disabled="loading">
          {{ loading ? 'Signing in...' : $t('common.confirm') }}
        </button>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { login, getCodeImg } from '@/api/login'
import useUserStore from '@/store/modules/user'
import { useI18n } from 'vue-i18n'

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
      // Store permissions if available
      if (res.permissions) {
        userStore.setPermissions(res.permissions)
      }
      // Store user info if available
      if (res.user) {
        userStore.setUserInfo(res.user)
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
@import "@/styles/apple.scss";

.layout-container {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 24px;
  box-sizing: border-box;
}

.login-card {
  width: 100%;
  max-width: 400px;
  @include glass-panel;
  padding: 40px 24px;
}

.login-header {
  margin-bottom: 36px;
  text-align: center;
}

.title {
  font-size: 32px;
  font-weight: 700;
  color: $apple-text-primary;
  display: block;
  margin-bottom: 8px;
  letter-spacing: -0.5px;
}

.subtitle {
  font-size: 15px;
  color: $apple-text-secondary;
}

.n-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.n-form-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.n-form-label {
  font-size: 13px;
  color: $apple-text-secondary;
  font-weight: 600;
  padding-left: 4px;
}

.n-input {
  @include glass-input;
  height: 48px;
  line-height: 48px;
  padding: 0 16px;
  font-size: 16px;
}

.n-input:focus {
  @include glass-input-focus;
}

.n-input-placeholder {
  color: rgba(60, 60, 67, 0.4);
}

.captcha-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.n-input-captcha {
  flex: 1;
}

.captcha-img {
  width: 120px;
  height: 48px;
  border-radius: $apple-radius-sm;
  background-color: rgba(255, 255, 255, 0.4);
  border: 1px solid $apple-glass-border;
  cursor: pointer;
}

.n-button {
  margin-top: 24px;
  height: 50px;
  line-height: 50px;
  border-radius: 25px;
  font-size: 17px;
  font-weight: 600;
  text-align: center;
  transition: all 0.3s ease;
}

.n-button::after {
  border: none;
}

.n-button-primary {
  background-color: $apple-blue;
  color: #fff;
  box-shadow: 0 4px 14px rgba(0, 122, 255, 0.3);
}

.n-button-primary:active {
  background-color: $apple-blue-pressed;
  transform: scale(0.98);
}

.n-button-primary[disabled] {
  background-color: rgba(0, 122, 255, 0.5);
  box-shadow: none;
}
</style>
