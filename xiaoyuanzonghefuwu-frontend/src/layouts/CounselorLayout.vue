<template>
  <div class="counselor-layout">
    <el-container>
      <!-- 侧边栏 -->
      <el-aside :width="isCollapse ? '64px' : '220px'" class="counselor-aside">
        <div class="logo">
          <el-icon :size="24" color="#fff"><School /></el-icon>
          <span v-show="!isCollapse">心理咨询中心</span>
        </div>
        <el-menu
          :default-active="activeMenu"
          background-color="#1e293b"
          text-color="#94a3b8"
          active-text-color="#fff"
          class="counselor-menu"
          :collapse="isCollapse"
          router
        >
          <el-menu-item index="/counselor/dashboard">
            <el-icon><DataAnalysis /></el-icon>
            <template #title>工作台</template>
          </el-menu-item>
          <el-menu-item index="/counselor/chat">
            <el-icon><ChatDotRound /></el-icon>
            <template #title>咨询管理</template>
          </el-menu-item>
          <el-menu-item index="/counselor/liuyan">
            <el-icon><Message /></el-icon>
            <template #title>留言管理</template>
          </el-menu-item>
          <el-menu-item index="/counselor/forum">
            <el-icon><Document /></el-icon>
            <template #title>帖子管理</template>
          </el-menu-item>
          <el-menu-item index="/counselor/profile">
            <el-icon><User /></el-icon>
            <template #title>个人信息</template>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <el-container>
        <!-- 顶部导航 -->
        <el-header class="counselor-header">
          <div class="header-left">
            <el-icon class="collapse-btn" @click="toggleCollapse">
              <component :is="isCollapse ? 'Expand' : 'Fold'" />
            </el-icon>
            <el-breadcrumb separator="/">
              <el-breadcrumb-item>心理咨询师端</el-breadcrumb-item>
              <el-breadcrumb-item>{{ currentPageName }}</el-breadcrumb-item>
            </el-breadcrumb>
          </div>
          <div class="header-right">
            <el-dropdown @command="handleCommand">
              <span class="user-info">
                <el-avatar :size="32" :src="userStore.userInfo?.xinlizixunshi_photo || ''" />
                <span class="username">{{ userStore.userInfo?.xinlizixunshi_name || '咨询师' }}</span>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">个人信息</el-dropdown-item>
                  <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </el-header>

        <!-- 主内容区 -->
        <el-main class="counselor-main">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  DataAnalysis,
  ChatDotRound,
  Message,
  Document,
  User,
  Expand,
  Fold,
  School
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const isCollapse = ref(false)
const activeMenu = computed(() => route.path)

const currentPageName = computed(() => {
  const pageMap = {
    '/counselor/dashboard': '工作台',
    '/counselor/chat': '咨询管理',
    '/counselor/liuyan': '留言管理',
    '/counselor/forum': '帖子管理',
    '/counselor/profile': '个人信息'
  }
  return pageMap[route.path] || '工作台'
})

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value
}

const handleCommand = async (command) => {
  if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      userStore.logout()
      router.push('/login')
      ElMessage.success('已退出登录')
    } catch {
      // 取消退出
    }
  } else if (command === 'profile') {
    router.push('/counselor/profile')
  }
}
</script>

<style lang="scss" scoped>
.counselor-layout {
  height: 100vh;
  overflow: hidden;
}

.el-container {
  height: 100%;
}

.counselor-aside {
  background-color: #1e293b;
  transition: width 0.3s;
  overflow-x: hidden;

  .logo {
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    color: #fff;
    font-size: 18px;
    font-weight: 600;
    border-bottom: 1px solid #334155;
  }

  .counselor-menu {
    border-right: none;
    
    .el-menu-item {
      &:hover {
        background-color: #334155 !important;
      }
      
      &.is-active {
        background-color: #3b82f6 !important;
      }
    }
  }
}

.counselor-header {
  background-color: #fff;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;

  .header-left {
    display: flex;
    align-items: center;
    gap: 20px;

    .collapse-btn {
      font-size: 20px;
      cursor: pointer;
      transition: color 0.3s;
      
      &:hover {
        color: #3b82f6;
      }
    }
  }

  .header-right {
    .user-info {
      display: flex;
      align-items: center;
      gap: 10px;
      cursor: pointer;
      
      .username {
        font-size: 14px;
        color: #334155;
      }
    }
  }
}

.counselor-main {
  background-color: #f1f5f9;
  padding: 20px;
  overflow-y: auto;
}
</style>