import useUserStore from '@/store/modules/user'

const baseURL = 'http://localhost:8080'

// Serialize an object into a query string, skipping null/undefined values.
const buildQueryString = (params) => {
  if (!params || typeof params !== 'object') return ''
  const parts = []
  Object.keys(params).forEach((key) => {
    const value = params[key]
    if (value === null || value === undefined || value === '') return
    parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
  })
  return parts.length ? `?${parts.join('&')}` : ''
}

export const request = (options) => {
  return new Promise((resolve, reject) => {
    uni.showLoading({ title: '加载中...', mask: true })

    const userStore = useUserStore()
    const header = options.header || {}
    const isToken = (options.headers || {}).isToken === false

    if (userStore.token && !isToken) {
      header['Authorization'] = 'Bearer ' + userStore.token
    }

    const method = (options.method || 'GET').toUpperCase()
    // For GET/DELETE, accept either `params` or `data` and put them in the URL.
    // For POST/PUT, send `data` in the body as usual (still allow `params` as query string).
    const isQueryMethod = method === 'GET' || method === 'DELETE'
    const queryObj = options.params || (isQueryMethod ? options.data : null)
    const queryString = buildQueryString(queryObj)
    const bodyData = isQueryMethod ? {} : (options.data || {})

    uni.request({
      url: baseURL + options.url + queryString,
      method,
      data: bodyData,
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
