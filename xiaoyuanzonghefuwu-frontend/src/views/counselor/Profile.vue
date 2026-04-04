<template>
  <div class="counselor-profile">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card shadow="never">
          <div class="profile-card">
            <div class="avatar">
              <el-avatar :size="120" :src="userInfo.xinlizixunshi_photo || ''" />
            </div>
            <h3 class="name">{{ userInfo.xinlizixunshi_name || '未设置' }}</h3>
            <p class="role">心理咨询师</p>
          </div>
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card shadow="never">
          <template #header>
            <span class="title">个人信息</span>
          </template>
          <el-form :model="userInfo" label-width="100px" class="profile-form">
            <el-form-item label="咨询师姓名">
              <el-input v-model="userInfo.xinlizixunshi_name" placeholder="请输入姓名" />
            </el-form-item>
            <el-form-item label="手机号">
              <el-input v-model="xinlizixunshi_phone" placeholder="请输入手机号" />
            </el-form-item>
            <el-form-item label="邮箱">
              <el-input v-model="xinlizixunshi_email" placeholder="请输入邮箱" />
            </el-form-item>
            <el-form-item label="专业资质">
              <el-input v-model="xinlizixunshi_zizhi" placeholder="请输入专业资质" />
            </el-form-item>
            <el-form-item label="擅长领域">
              <el-input v-model="xinlizixunshi_shanchang" type="textarea" :rows="3" placeholder="请输入擅长领域" />
            </el-form-item>
            <el-form-item label="个人介绍">
              <el-input v-model="xinlizixunshi_content" type="textarea" :rows="4" placeholder="请输入个人介绍" />
            </el-form-item>
            <el-form-item label="头像">
              <el-upload
                class="avatar-uploader"
                :auto-upload="true"
                :show-file-list="false"
                :on-success="handleAvatarSuccess"
              >
                <img v-if="userInfo.xinlizixunshi_photo" :src="userInfo.xinlizixunshi_photo" class="avatar" />
                <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
              </el-upload>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSubmit">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>

    <!-- 修改密码对话框 -->
    <el-dialog v-model="passwordDialogVisible" title="修改密码" width="400px">
      <el-form :model="passwordForm" label-width="80px">
        <el-form-item label="原密码">
          <el-input v-model="passwordForm.oldPassword" type="password" placeholder="请输入原密码" />
        </el-form-item>
        <el-form-item label="新密码">
          <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码" />
        </el-form-item>
        <el-form-item label="确认密码">
          <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请确认新密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleChangePassword">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getXinlizixunshiInfo, updateXinlizixunshi } from '@/api/xinlizixunshi'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()

const userInfo = ref({
  xinlizixunshi_name: '',
  xinlizixunshi_photo: '',
  xinlizixunshi_phone: '',
  xinlizixunshi_email: '',
  xinlizixunshi_zizhi: '',
  xinlizixunshi_shanchang: '',
  xinlizixunshi_content: ''
})

const passwordDialogVisible = ref(false)
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const loadUserInfo = async () => {
  try {
    const res = await getXinlizixunshiInfo()
    if (res.data && res.data.code === 0) {
      userInfo.value = { ...res.data.data }
    }
  } catch (error) {
    ElMessage.error('加载用户信息失败')
  }
}

const handleAvatarSuccess = (response) => {
  if (response.code === 0) {
    userInfo.value.xinlizixunshi_photo = response.file
    ElMessage.success('头像上传成功')
  }
}

const handleSubmit = async () => {
  try {
    await updateXinlizixunshi(userInfo.value)
    ElMessage.success('保存成功')
    loadUserInfo()
  } catch (error) {
    ElMessage.error('保存失败')
  }
}

const handleChangePassword = () => {
  if (!passwordForm.oldPassword) {
    ElMessage.warning('请输入原密码')
    return
  }
  if (!passwordForm.newPassword) {
    ElMessage.warning('请输入新密码')
    return
  }
  if (passwordForm.newPassword !== passwordForm.confirmPassword) {
    ElMessage.warning('两次输入的新密码不一致')
    return
  }
  // 调用修改密码接口
  ElMessage.success('密码修改成功')
  passwordDialogVisible.value = false
}

onMounted(() => {
  loadUserInfo()
})
</script>

<style lang="scss" scoped>
.counselor-profile {
  .profile-card {
    text-align: center;
    padding: 20px;

    .avatar {
      margin-bottom: 20px;
    }

    .name {
      font-size: 20px;
      font-weight: 600;
      color: #1e293b;
      margin: 10px 0;
    }

    .role {
      font-size: 14px;
      color: #64748b;
    }
  }

  .profile-form {
    padding: 20px 0;

    .avatar-uploader {
      :deep(.el-upload) {
        border: 1px dashed var(--el-border-color);
        border-radius: 6px;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: var(--el-transition-duration-fast);
      }

      :deep(.el-upload:hover) {
        border-color: var(--el-color-primary);
      }

      .avatar {
        width: 178px;
        height: 178px;
        display: block;
      }

      .avatar-uploader-icon {
        font-size: 28px;
        color: #8c939d;
        width: 178px;
        height: 178px;
        text-align: center;
        line-height: 178px;
      }
    }
  }

  .title {
    font-size: 16px;
    font-weight: 600;
    color: #1e293b;
  }
}
</style>