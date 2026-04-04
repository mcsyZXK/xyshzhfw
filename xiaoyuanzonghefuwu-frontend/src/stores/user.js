import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref(localStorage.getItem('token') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || '{}'))
  const role = ref(localStorage.getItem('role') || '')

  // 计算属性
  const isLoggedIn = computed(() => !!token.value)
  const isAdmin = computed(() => role.value === '管理员')
  const username = computed(() => userInfo.value?.username || '')

  // 方法
  function setToken(newToken) {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  function setUserInfo(info) {
    userInfo.value = info
    localStorage.setItem('userInfo', JSON.stringify(info))
  }

  function setRole(newRole) {
    role.value = newRole
    localStorage.setItem('role', newRole)
  }

  function login(data) {
    setToken(data.token)
    setUserInfo(data)
    setRole(data.role)
  }

  function logout() {
    token.value = ''
    userInfo.value = {}
    role.value = ''
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    localStorage.removeItem('role')
    localStorage.removeItem('userRole')
  }

  return {
    token,
    userInfo,
    role,
    isLoggedIn,
    isAdmin,
    username,
    setToken,
    setUserInfo,
    setRole,
    login,
    logout
  }
})
