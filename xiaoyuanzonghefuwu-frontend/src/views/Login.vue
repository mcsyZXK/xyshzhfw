<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <div class="logo">
          <el-icon :size="48"><School /></el-icon>
        </div>
        <h1>校园生活综合服务</h1>
        <p>让校园生活更美好</p>
      </div>

      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        class="login-form"
        @keyup.enter="handleLogin"
      >
        <el-form-item prop="username">
          <el-input
            v-model="loginForm.username"
            placeholder="账号"
            size="large"
            prefix-icon="User"
            clearable
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-select
            v-model="loginForm.role"
            placeholder="选择身份"
            size="large"
            style="width: 100%"
          >
            <el-option label="普通用户" value="yonghu" />
            <el-option label="心理咨询师" value="xinlizixunshi" />
            <el-option label="管理员" value="users" />
          </el-select>
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="login-btn"
            @click="handleLogin"
          >
            登录
          </el-button>
        </el-form-item>

        <div class="login-footer">
          <span>还没有账号？</span>
          <router-link to="/register">去注册</router-link>
        </div>
      </el-form>

    </div>
    
    <div class="decoration">
      <div class="deco-item deco-1">📚</div>
      <div class="deco-item deco-2">🎓</div>
      <div class="deco-item deco-3">✏️</div>
      <div class="deco-item deco-4">🏀</div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { login as adminLogin, yonghuLogin } from '@/api/user'
import { xinlizixunshiLogin } from '@/api/xinlizixunshi'

const router = useRouter()
const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: '',
  role: 'yonghu'
})

const loginRules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

// 获取角色名称
const getRoleName = (role) => {
  const roleMap = {
    'users': '管理员',
    'yonghu': '普通用户',
    'xinlizixunshi': '心里咨询师'
  }
  return roleMap[role] || '用户'
}

// 根据角色获取跳转路径
const getRedirectPath = (role) => {
  const pathMap = {
    'users': '/admin/user',           // 管理员 -> 后台管理
    'yonghu': '/home',                // 普通用户 -> 首页
    'xinlizixunshi': '/counselor/dashboard' // 咨询师 -> 咨询师工作台
  }
  return pathMap[role] || '/home'
}

const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  await loginFormRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      let res
      const data = {
        username: loginForm.username,
        password: loginForm.password
      }

      if (loginForm.role === 'users') {
        res = await adminLogin(data)
      } else if (loginForm.role === 'yonghu') {
        res = await yonghuLogin(data)
      } else if (loginForm.role === 'xinlizixunshi') {
        res = await xinlizixunshiLogin(data)
      }

      if (res && (res.code === 0 || res.code === 200)) {
        const token = res.token || res.data?.token
        if (!token) {
          ElMessage.error('登录失败：后端未返回 token')
          return
        }
        const roleValue = getRoleName(loginForm.role)
        const userRoleValue = loginForm.role
        const redirectPath = getRedirectPath(loginForm.role)
        
        console.log('登录成功：role =', roleValue, 'userRole =', userRoleValue, 'redirectPath =', redirectPath)
        
        localStorage.setItem('token', token)
        localStorage.setItem('role', roleValue)
        localStorage.setItem('userRole', userRoleValue)
        localStorage.setItem('userInfo', JSON.stringify(res.data || res))

        ElMessage.success('登录成功')
        
        // 使用 replace 模式跳转，避免回退到登录页
        router.replace(redirectPath)
      }
    } catch (error) {
      console.error('登录失败:', error)
    } finally {
      loading.value = false
    }
  })
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$secondary: #FFB703;
$secondary-dark: #FB8500;
$bg-warm: #FEFAE0;
$accent-blue: #89C2D9;
$accent-pink: #FFAFCC;

.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: linear-gradient(135deg, $bg-warm 0%, #E9EDC9 100%);
  position: relative;
  overflow: hidden;
}

.login-card {
  width: 100%;
  max-width: 400px;
  background: #fff;
  border-radius: 24px;
  padding: 40px 32px;
  box-shadow: 8px 8px 0 rgba($primary, 0.2);
  border: 3px solid $primary;
  position: relative;
  z-index: 1;
  animation: slide-up 0.5s ease;
}

@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.login-header {
  text-align: center;
  margin-bottom: 32px;

  .logo {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 88px;
    height: 88px;
    background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
    border-radius: 50%;
    margin-bottom: 16px;
    color: #fff;
    border: 4px solid $secondary;
    box-shadow: 4px 4px 0 rgba($primary, 0.3);
  }

  h1 {
    font-size: 22px;
    font-weight: 700;
    color: $primary;
    margin-bottom: 6px;
  }

  p {
    color: #888;
    font-size: 14px;
  }
}

.login-form {
  .login-btn {
    width: 100%;
    background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
    border: 2px solid $primary-dark;
    font-size: 16px;
    font-weight: 700;
    border-radius: 12px;
    padding: 14px;
    box-shadow: 3px 3px 0 $primary-dark;
    transition: all 0.2s ease;
    
    &:hover {
      transform: translate(-2px, -2px);
      box-shadow: 5px 5px 0 $primary-dark;
    }
    
    &:active {
      transform: translate(0, 0);
      box-shadow: 0 0 0 $primary-dark;
    }
  }
}

.login-footer {
  text-align: center;
  margin-top: 20px;
  color: #666;
  font-size: 14px;

  a {
    color: $secondary-dark;
    text-decoration: none;
    margin-left: 5px;
    font-weight: 600;
    
    &:hover {
      text-decoration: underline;
    }
  }
}

// 装饰元素
.decoration {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;
  
  .deco-item {
    position: absolute;
    font-size: 48px;
    opacity: 0.15;
    animation: float 4s ease-in-out infinite;
  }
  
  .deco-1 {
    top: 10%;
    left: 8%;
    animation-delay: 0s;
  }
  
  .deco-2 {
    top: 20%;
    right: 10%;
    animation-delay: 1s;
  }
  
  .deco-3 {
    bottom: 15%;
    left: 12%;
    animation-delay: 2s;
  }
  
  .deco-4 {
    bottom: 25%;
    right: 8%;
    animation-delay: 3s;
  }
}

@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-15px) rotate(5deg); }
}

// 移动端适配
@media (max-width: 480px) {
  .login-card {
    padding: 32px 24px;
  }
}
</style>
