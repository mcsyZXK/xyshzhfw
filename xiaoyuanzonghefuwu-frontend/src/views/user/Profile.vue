<template>
  <div class="profile-page">
    <div class="profile-header">
      <div class="header-content">
        <div class="avatar-section">
          <el-avatar :size="100" :icon="UserFilled" class="avatar" />
          <el-button class="edit-avatar-btn" size="small">
            <el-icon><Camera /></el-icon>
          </el-button>
        </div>
        <div class="user-info">
          <h1>{{ userInfo.username || '同学' }}</h1>
          <p class="user-role">{{ roleText }}</p>
          <div class="user-stats">
            <div class="stat-item">
              <span class="stat-value">0</span>
              <span class="stat-label">活动</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">0</span>
              <span class="stat-label">帖子</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">0</span>
              <span class="stat-label">收藏</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="profile-body">
      <el-row :gutter="24">
        <el-col :xs="24" :sm="8">
          <div class="menu-card">
            <el-menu class="profile-menu" @select="handleMenuSelect">
              <el-menu-item index="info">
                <el-icon><User /></el-icon>
                <span>基本信息</span>
              </el-menu-item>
              <el-menu-item index="security">
                <el-icon><Lock /></el-icon>
                <span>账号安全</span>
              </el-menu-item>
              <el-menu-item index="activity">
                <el-icon><Trophy /></el-icon>
                <span>我的活动</span>
              </el-menu-item>
              <el-menu-item index="collection">
                <el-icon><Star /></el-icon>
                <span>我的收藏</span>
              </el-menu-item>
            </el-menu>
          </div>
        </el-col>

        <el-col :xs="24" :sm="16">
          <el-card class="content-card" v-if="activeTab === 'info'">
            <template #header>
              <div class="card-header">
                <span>📋 基本信息</span>
                <el-button type="primary" size="small" @click="handleSave">
                  <el-icon><Check /></el-icon>保存
                </el-button>
              </div>
            </template>

            <el-form :model="form" label-width="100px" class="profile-form">
              <el-form-item label="用户名">
                <el-input v-model="form.username" disabled class="disabled-input" />
              </el-form-item>

              <el-form-item label="手机号">
                <el-input v-model="form.phone" placeholder="请输入手机号" />
              </el-form-item>

              <el-form-item label="邮箱">
                <el-input v-model="form.email" placeholder="请输入邮箱" />
              </el-form-item>

              <el-form-item label="性别">
                <el-radio-group v-model="form.sex">
                  <el-radio label="男">👦 男</el-radio>
                  <el-radio label="女">👧 女</el-radio>
                  <el-radio label="保密">🤫 保密</el-radio>
                </el-radio-group>
              </el-form-item>

              <el-form-item label="个性签名">
                <el-input
                  v-model="form.signature"
                  type="textarea"
                  :rows="3"
                  placeholder="介绍一下自己吧..."
                />
              </el-form-item>
            </el-form>
          </el-card>

          <el-card class="content-card" v-if="activeTab === 'security'">
            <template #header>
              <div class="card-header">
                <span>🔒 账号安全</span>
              </div>
            </template>

            <el-form :model="securityForm" label-width="100px" class="profile-form">
              <el-form-item label="当前密码">
                <el-input v-model="securityForm.oldPassword" type="password" placeholder="请输入当前密码" />
              </el-form-item>

              <el-form-item label="新密码">
                <el-input v-model="securityForm.newPassword" type="password" placeholder="请输入新密码" />
              </el-form-item>

              <el-form-item label="确认密码">
                <el-input v-model="securityForm.confirmPassword" type="password" placeholder="请确认新密码" />
              </el-form-item>

              <el-form-item>
                <el-button type="primary" @click="handleChangePassword">
                  修改密码
                </el-button>
              </el-form-item>
            </el-form>
          </el-card>

          <el-card class="content-card" v-if="activeTab === 'activity'">
            <template #header>
              <div class="card-header">
                <span>🎪 我的活动</span>
              </div>
            </template>

            <el-empty description="还没有参加任何活动哦" v-if="myActivities.length === 0" />
            <div v-else class="activity-list">
              <div v-for="item in myActivities" :key="item.id" class="activity-item">
                <div class="activity-emoji">🎪</div>
                <div class="activity-info">
                  <div class="activity-name">{{ item.name }}</div>
                  <div class="activity-time">{{ item.time }}</div>
                </div>
                <el-tag size="small">已报名</el-tag>
              </div>
            </div>
          </el-card>

          <el-card class="content-card" v-if="activeTab === 'collection'">
            <template #header>
              <div class="card-header">
                <span>⭐ 我的收藏</span>
              </div>
            </template>

            <el-empty description="还没有收藏任何内容哦" v-if="myCollections.length === 0" />
            <div v-else class="collection-list">
              <div v-for="item in myCollections" :key="item.id" class="collection-item">
                <div class="collection-emoji">{{ item.emoji }}</div>
                <div class="collection-info">
                  <div class="collection-name">{{ item.name }}</div>
                  <div class="collection-type">{{ item.type }}</div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { UserFilled, User, Lock, Trophy, Star, Camera, Check } from '@element-plus/icons-vue'

const activeTab = ref('info')
const userInfo = ref({})
const roleText = ref('普通用户')

const form = reactive({
  username: '',
  phone: '',
  email: '',
  sex: '保密',
  signature: ''
})

const securityForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const myActivities = ref([])
const myCollections = ref([])

onMounted(() => {
  const user = localStorage.getItem('userInfo')
  const role = localStorage.getItem('role')
  
  if (user) {
    try {
      const userData = JSON.parse(user)
      userInfo.value = userData
      form.username = userData.username || '同学'
      form.phone = userData.phone || ''
      form.email = userData.email || ''
    } catch (e) {
      console.error('解析用户信息失败')
    }
  }
  
  if (role === '管理员') {
    roleText.value = '👑 管理员'
  } else if (role === '心理咨询师' || role === '心里咨询师') {
    roleText.value = '💚 心理咨询师'
  } else {
    roleText.value = '🎓 同学'
  }
})

const handleMenuSelect = (index) => {
  activeTab.value = index
}

const handleSave = () => {
  ElMessage.success('保存成功')
}

const handleChangePassword = () => {
  if (!securityForm.oldPassword || !securityForm.newPassword) {
    ElMessage.warning('请填写完整密码信息')
    return
  }
  
  if (securityForm.newPassword !== securityForm.confirmPassword) {
    ElMessage.warning('两次输入的新密码不一致')
    return
  }
  
  ElMessage.success('密码修改成功')
  securityForm.oldPassword = ''
  securityForm.newPassword = ''
  securityForm.confirmPassword = ''
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$secondary: #FFB703;
$secondary-dark: #FB8500;
$bg-warm: #FEFAE0;
$bg-light: #E9EDC9;
$text-primary: #2D3436;

.profile-page {
  max-width: 1000px;
  margin: 0 auto;
}

// 头部区域
.profile-header {
  margin-bottom: 24px;
  
  .header-content {
    display: flex;
    align-items: center;
    gap: 24px;
    background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
    border-radius: 20px;
    padding: 32px;
    border: 3px solid $secondary;
    box-shadow: 6px 6px 0 rgba($primary, 0.3);
  }
  
  .avatar-section {
    position: relative;
    
    .avatar {
      border: 4px solid $secondary;
      box-shadow: 4px 4px 0 rgba(0, 0, 0, 0.2);
    }
    
    .edit-avatar-btn {
      position: absolute;
      bottom: -8px;
      right: -8px;
      background: $secondary;
      border-color: $secondary-dark;
      border-radius: 50%;
      width: 36px;
      height: 36px;
      padding: 0;
      display: flex;
      align-items: center;
      justify-content: center;
    }
  }
  
  .user-info {
    flex: 1;
    
    h1 {
      font-size: 28px;
      font-weight: 700;
      color: #fff;
      margin: 0 0 8px 0;
    }
    
    .user-role {
      font-size: 14px;
      color: rgba(#fff, 0.9);
      margin-bottom: 16px;
    }
    
    .user-stats {
      display: flex;
      gap: 24px;
      
      .stat-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        
        .stat-value {
          font-size: 24px;
          font-weight: 700;
          color: $secondary;
        }
        
        .stat-label {
          font-size: 12px;
          color: rgba(#fff, 0.8);
        }
      }
    }
  }
}

// 主体区域
.profile-body {
  .menu-card {
    background: #fff;
    border-radius: 16px;
    border: 2px solid $primary;
    box-shadow: 4px 4px 0 rgba($primary, 0.15);
    overflow: hidden;
  }
  
  .profile-menu {
    border-right: none;
    
    .el-menu-item {
      border-radius: 10px;
      margin: 4px 8px;
      color: $text-primary;
      
      &:hover {
        background-color: $bg-warm !important;
      }
      
      &.is-active {
        background: linear-gradient(135deg, $secondary 0%, $secondary-dark 100%) !important;
        color: #fff !important;
      }
      
      .el-icon {
        margin-right: 8px;
      }
    }
  }
  
  .content-card {
    border-radius: 16px;
    border: 2px solid $primary;
    box-shadow: 4px 4px 0 rgba($primary, 0.15);
    background: #fff;
    
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-weight: 600;
      color: $text-primary;
    }
  }
  
  .profile-form {
    .disabled-input {
      background: $bg-warm;
    }
  }
}

// 活动列表
.activity-list {
  .activity-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px 0;
    border-bottom: 1px dashed $bg-light;
    
    &:last-child {
      border-bottom: none;
    }
    
    .activity-emoji {
      font-size: 32px;
    }
    
    .activity-info {
      flex: 1;
      
      .activity-name {
        font-size: 15px;
        font-weight: 600;
        color: $text-primary;
        margin-bottom: 4px;
      }
      
      .activity-time {
        font-size: 13px;
        color: #888;
      }
    }
  }
}

// 收藏列表
.collection-list {
  .collection-item {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px 0;
    border-bottom: 1px dashed $bg-light;
    
    &:last-child {
      border-bottom: none;
    }
    
    .collection-emoji {
      font-size: 32px;
    }
    
    .collection-info {
      flex: 1;
      
      .collection-name {
        font-size: 15px;
        font-weight: 600;
        color: $text-primary;
        margin-bottom: 4px;
      }
      
      .collection-type {
        font-size: 13px;
        color: #888;
      }
    }
  }
}

// 响应式
@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    text-align: center;
  }
  
  .user-stats {
    justify-content: center;
  }
}
</style>
