<template>
  <div class="register-container">
    <div class="register-card">
      <div class="register-header">
        <div class="logo">
          <el-icon :size="48"><School /></el-icon>
        </div>
        <h1>加入校园服务</h1>
        <p>开启便捷校园生活</p>
      </div>

      <el-form
        ref="registerFormRef"
        :model="registerForm"
        :rules="registerRules"
        class="register-form"
      >
        <el-form-item prop="username">
          <el-input
            v-model="registerForm.username"
            placeholder="用户名"
            size="large"
            prefix-icon="User"
            clearable
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="registerForm.password"
            type="password"
            placeholder="密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item prop="confirmPassword">
          <el-input
            v-model="registerForm.confirmPassword"
            type="password"
            placeholder="确认密码"
            size="large"
            prefix-icon="Lock"
            show-password
          />
        </el-form-item>

        <el-form-item prop="phone">
          <el-input
            v-model="registerForm.phone"
            placeholder="手机号"
            size="large"
            prefix-icon="Iphone"
            clearable
            maxlength="11"
          />
        </el-form-item>

        <el-form-item prop="email">
          <el-input
            v-model="registerForm.email"
            placeholder="邮箱（选填）"
            size="large"
            prefix-icon="Message"
            clearable
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            class="register-btn"
            @click="handleRegister"
          >
            立即注册
          </el-button>
        </el-form-item>

        <div class="register-footer">
          <span>已有账号？</span>
          <router-link to="/login">去登录</router-link>
        </div>
      </el-form>
    </div>
    
    <div class="decoration">
      <div class="deco-item deco-1">🎒</div>
      <div class="deco-item deco-2">📝</div>
      <div class="deco-item deco-3">🎯</div>
      <div class="deco-item deco-4">🌟</div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { School } from '@element-plus/icons-vue'
import { registerUser as userRegister } from '@/api/user'

const router = useRouter()
const registerFormRef = ref(null)
const loading = ref(false)

const registerForm = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  phone: '',
  email: ''
})

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== registerForm.password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3-20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度至少 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '手机号格式不正确', trigger: 'blur' }
  ],
  email: [
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
  ]
}

const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  await registerFormRef.value.validate(async (valid) => {
    if (!valid) return

    loading.value = true
    try {
      const data = {
        username: registerForm.username,
        password: registerForm.password,
        phone: registerForm.phone,
        email: registerForm.email || ''
      }

      const res = await userRegister(data)
      
      if (res && (res.code === 0 || res.code === 200)) {
        ElMessage.success('注册成功，请登录')
        router.push('/login')
      }
    } catch (error) {
      console.error('注册失败:', error)
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

.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  background: linear-gradient(135deg, $bg-warm 0%, #E9EDC9 100%);
  position: relative;
  overflow: hidden;
}

.register-card {
  width: 100%;
  max-width: 420px;
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

.register-header {
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

.register-form {
  .register-btn {
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

.register-footer {
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
    top: 8%;
    left: 6%;
    animation-delay: 0s;
  }
  
  .deco-2 {
    top: 18%;
    right: 8%;
    animation-delay: 1.5s;
  }
  
  .deco-3 {
    bottom: 12%;
    left: 10%;
    animation-delay: 2.5s;
  }
  
  .deco-4 {
    bottom: 22%;
    right: 6%;
    animation-delay: 3.5s;
  }
}

@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  50% { transform: translateY(-15px) rotate(5deg); }
}

// 移动端适配
@media (max-width: 480px) {
  .register-card {
    padding: 32px 24px;
  }
}
</style>