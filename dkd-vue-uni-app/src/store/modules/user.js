import { defineStore } from 'pinia'

export const useUserStore = defineStore(
  'user',
  {
    state: () => ({
      token: uni.getStorageSync('token') || '',
      name: '',
      avatar: '',
      roles: [],
      permissions: []
    }),
    actions: {
      setToken(token) {
        this.token = token
        uni.setStorageSync('token', token)
      },
      setPermissions(permissions) {
        this.permissions = permissions || []
        uni.setStorageSync('permissions', permissions || [])
      },
      setUserInfo(info) {
        this.name = info.name || ''
        this.avatar = info.avatar || ''
        this.roles = info.roles || []
      },
      clearToken() {
        this.token = ''
        this.name = ''
        this.avatar = ''
        this.roles = []
        this.permissions = []
        uni.removeStorageSync('token')
        uni.removeStorageSync('permissions')
      }
    }
  }
)

export default useUserStore
