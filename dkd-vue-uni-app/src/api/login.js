import request from '@/utils/request'

// Login method
export function login(username, password, code, uuid) {
  const data = {
    username,
    password,
    code,
    uuid
  }
  return request({
    url: '/login',
    method: 'post',
    headers: { isToken: false },
    data: data
  })
}

// Register method
export function register(data) {
  return request({
    url: '/register',
    headers: { isToken: false },
    method: 'post',
    data: data
  })
}

// Get user detail
export function getInfo() {
  return request({
    url: '/getInfo',
    method: 'get'
  })
}

// Logout method
export function logout() {
  return request({
    url: '/logout',
    method: 'post'
  })
}

// Get captcha
export function getCodeImg() {
  return request({
    url: '/captchaImage',
    headers: { isToken: false },
    method: 'get'
  })
}
