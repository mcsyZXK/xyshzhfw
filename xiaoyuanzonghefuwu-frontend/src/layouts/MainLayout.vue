<template>
  <el-container class="main-layout">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapse ? '70px' : '220px'" class="sidebar">
      <div class="logo-wrapper">
        <div class="logo" @click="$router.push('/home')">
          <el-icon :size="32"><School /></el-icon>
          <span v-show="!isCollapse">校园服务</span>
        </div>
      </div>

      <el-menu
        :default-active="activeMenu"
        class="sidebar-menu"
        :collapse="isCollapse"
        :collapse-transition="false"
        @select="handleMenuSelect"
      >
        <!-- 管理员菜单 -->
        <template v-if="isAdmin">
          <el-menu-item index="/admin/dashboard">
            <el-icon><House /></el-icon>
            <template #title>管理首页</template>
          </el-menu-item>

          <el-menu-item index="/admin/user">
            <el-icon><User /></el-icon>
            <template #title>用户管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/huodong">
            <el-icon><PieChart /></el-icon>
            <template #title>活动管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/huodongorder">
            <el-icon><List /></el-icon>
            <template #title>报名管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/wupin">
            <el-icon><Box /></el-icon>
            <template #title>物品管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/xunwu">
            <el-icon><Search /></el-icon>
            <template #title>失物招领管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/forum">
            <el-icon><ChatDotRound /></el-icon>
            <template #title>论坛管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/dictionary">
            <el-icon><Collection /></el-icon>
            <template #title>字典管理</template>
          </el-menu-item>

          <el-menu-item index="/admin/config">
            <el-icon><Setting /></el-icon>
            <template #title>系统配置</template>
          </el-menu-item>

          <el-menu-item index="/profile">
            <el-icon><UserFilled /></el-icon>
            <template #title>个人中心</template>
          </el-menu-item>
        </template>

        <!-- 普通用户菜单 -->
        <template v-else>
          <el-menu-item index="/home">
            <el-icon><House /></el-icon>
            <template #title>首页</template>
          </el-menu-item>

          <el-menu-item index="/huodong">
            <el-icon><PieChart /></el-icon>
            <template #title>校园活动</template>
          </el-menu-item>

          <el-menu-item index="/wupin">
            <el-icon><Box /></el-icon>
            <template #title>二手物品</template>
          </el-menu-item>

          <el-menu-item index="/xunwu">
            <el-icon><Search /></el-icon>
            <template #title>失物招领</template>
          </el-menu-item>

          <el-menu-item index="/forum">
            <el-icon><ChatDotRound /></el-icon>
            <template #title>校园论坛</template>
          </el-menu-item>

          <el-menu-item index="/profile">
            <el-icon><User /></el-icon>
            <template #title>个人中心</template>
          </el-menu-item>
        </template>
      </el-menu>

      <div class="sidebar-footer">
        <el-button text @click="toggleCollapse">
          <el-icon><Fold v-if="!isCollapse" /><Expand v-else /></el-icon>
        </el-button>
      </div>
    </el-aside>

    <el-container>
      <!-- 顶部栏 -->
      <el-header class="header">
        <div class="header-left">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item :to="{ path: '/home' }">首页</el-breadcrumb-item>
            <el-breadcrumb-item v-if="breadcrumb">{{ breadcrumb }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="header-right">
          <div class="user-info">
            <el-avatar :size="36" :icon="UserFilled" />
            <span class="username">{{ username }}</span>
          </div>

          <el-dropdown @command="handleCommand">
            <el-button text>
              <el-icon><ArrowDown /></el-icon>
            </el-button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">
                  <el-icon><User /></el-icon>个人中心
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 主内容区 -->
      <el-main class="main-content">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" :key="route.fullPath" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  School, House, PieChart, Box, Search, ChatDotRound,
  User, Setting, Fold, Expand, ArrowDown,
  SwitchButton, UserFilled, List, Collection
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const isCollapse = ref(false)
const username = ref('同学')

// 使用 computed 动态读取 localStorage 中的角色信息
const role = computed(() => localStorage.getItem('role') || '')
const isAdmin = computed(() => role.value === '管理员')

const normalizeMenuPath = (path) => {
  if (!path) return '/home'
  if (path.startsWith('/wupin/')) return '/wupin'
  if (path.startsWith('/huodong/')) return '/huodong'
  if (path.startsWith('/xunwu/')) return '/xunwu'
  if (path.startsWith('/forum/')) return '/forum'
  return path
}

const activeMenu = computed(() => normalizeMenuPath(route.path))

const breadcrumb = computed(() => {
  const map = {
    '/home': '首页',
    '/huodong': '校园活动',
    '/wupin': '二手物品',
    '/xunwu': '失物招领',
    '/forum': '校园论坛',
    '/profile': '个人中心',
    '/admin': '后台管理'
  }
  return map[route.path] || ''
})

// 更新用户信息
const updateUserInfo = () => {
  const user = localStorage.getItem('userInfo')
  if (user) {
    try {
      const userInfo = JSON.parse(user)
      username.value = userInfo.username || userInfo.name || '同学'
    } catch (e) {
      console.error('解析用户信息失败')
    }
  }
}

onMounted(() => {
  updateUserInfo()
})

// 监听路由变化，更新用户信息
watch(() => route.path, () => {
  updateUserInfo()
})

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleMenuSelect = async (index) => {
  if (normalizeMenuPath(route.path) === normalizeMenuPath(index)) {
    return
  }
  try {
    await router.push(index)
  } catch (error) {
    console.error('菜单跳转失败:', error)
  }
}

const handleCommand = async (command) => {
  if (command === 'profile') {
    router.push('/profile')
  } else if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '退出',
        cancelButtonText: '取消',
        type: 'warning'
      })
      localStorage.removeItem('token')
      localStorage.removeItem('role')
      localStorage.removeItem('userRole')
      localStorage.removeItem('userInfo')
      ElMessage.success('已退出登录')
      router.push('/login')
    } catch {
      // 取消退出
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$primary-light: #40916C;
$secondary: #FFB703;
$secondary-dark: #FB8500;
$bg-warm: #FEFAE0;
$bg-light: #E9EDC9;
$text-primary: #2D3436;

.main-layout {
  min-height: 100vh;
  background: $bg-warm;
}

// 侧边栏
.sidebar {
  background: linear-gradient(180deg, $primary 0%, $primary-dark 100%);
  border-right: 3px solid $secondary;
  transition: width 0.3s ease;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.logo-wrapper {
  padding: 20px 16px;
  border-bottom: 2px dashed rgba($secondary, 0.3);
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  color: #fff;
  font-size: 18px;
  font-weight: 700;
  cursor: pointer;
  transition: transform 0.2s;
  
  &:hover {
    transform: scale(1.05);
  }
  
  .el-icon {
    color: $secondary;
  }
}

.sidebar-menu {
  flex: 1;
  border-right: none;
  background: transparent;
  padding: 12px 8px;
  
  .el-menu-item {
    border-radius: 10px;
    margin: 4px 8px;
    color: rgba(#fff, 0.85);
    transition: all 0.2s ease;
    
    &:hover {
      background-color: rgba($secondary, 0.2) !important;
      color: #fff !important;
    }
    
    &.is-active {
      background: linear-gradient(135deg, $secondary 0%, $secondary-dark 100%) !important;
      color: #fff !important;
      box-shadow: 3px 3px 0 rgba(0, 0, 0, 0.2);
    }
    
    .el-icon {
      font-size: 20px;
    }
  }
}

.sidebar-footer {
  padding: 16px;
  border-top: 2px dashed rgba($secondary, 0.3);
  
  .el-button {
    width: 100%;
    color: rgba(#fff, 0.85);
    
    &:hover {
      background: rgba($secondary, 0.2);
    }
  }
}

// 顶部栏
.header {
  background: #fff;
  border-bottom: 2px solid $bg-light;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba($primary, 0.08);
}

.header-left {
  :deep(.el-breadcrumb) {
    .el-breadcrumb__item {
      font-size: 14px;
      
      a {
        color: $text-primary;
        font-weight: 500;
        
        &:hover {
          color: $primary;
        }
      }
    }
    
    .el-breadcrumb__separator {
      color: #ccc;
    }
    
    .el-breadcrumb__inner.is-link {
      color: $primary;
    }
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
  
  .user-info {
    display: flex;
    align-items: center;
    gap: 10px;
    
    .username {
      font-size: 14px;
      font-weight: 600;
      color: $text-primary;
    }
  }
}

// 主内容区
.main-content {
  background: transparent;
  padding: 24px;
  min-height: calc(100vh - 60px);
}

// 页面切换动画
.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.fade-enter-from {
  opacity: 0;
  transform: translateY(20px) rotate(-1deg);
}

.fade-leave-to {
  opacity: 0;
  transform: translateY(-20px) rotate(1deg);
}

// 响应式
@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    bottom: 0;
    z-index: 1000;
  }
  
  .header {
    padding: 0 16px;
  }
  
  .main-content {
    padding: 16px;
  }
}
</style>
