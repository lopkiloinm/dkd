import useUserStore from '@/store/modules/user'

const baseURL = 'http://localhost:8080'

export const request = (options) => {
  return new Promise((resolve, reject) => {
    uni.showLoading({ title: '加载中...', mask: true })
    
    const userStore = useUserStore()
    const header = options.header || {}
    const isToken = (options.headers || {}).isToken === false
    
    if (userStore.token && !isToken) {
      header['Authorization'] = 'Bearer ' + userStore.token
    }

    uni.request({
      url: baseURL + options.url,
      method: options.method || 'GET',
      data: options.data || {},
      header: header,
      success: (res) => {
        uni.hideLoading()
        if (res.data && res.data.code === 401) {
          userStore.clearToken()
          uni.reLaunch({ url: '/pages/login/index' })
          reject(new Error('Login expired'))
        } else if (res.data && res.data.code === 200) {
          resolve(res.data)
        } else {
          uni.showToast({ title: res.data.msg || '请求错误', icon: 'none' })
          reject(res.data)
        }
      },
      fail: (err) => {
        uni.hideLoading()
        uni.showToast({ title: '网络异常，请稍后再试', icon: 'none' })
        reject(err)
      }
    })
  })
}

export default request
