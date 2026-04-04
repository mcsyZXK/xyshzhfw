<template>
  <div class="detail-page">
    <div v-loading="loading" class="detail-content">
      <el-card v-if="detail" class="detail-card">
        <template #header>
          <div class="card-header">
            <el-button text @click="$router.back()">
              <el-icon><ArrowLeft /></el-icon>
              返回
            </el-button>
          </div>
        </template>

        <div class="detail-body">
          <div class="detail-header">
            <div class="avatar">
              <el-icon :size="80"><User /></el-icon>
            </div>
            <div class="info">
              <h1 class="name">{{ detail.xinlizixunshiName }}</h1>
              <p class="title">心理咨询师</p>
            </div>
          </div>
          
          <div class="detail-meta">
            <div class="meta-item">
              <el-icon><Phone /></el-icon>
              <span>电话：{{ detail.xinlizixunshiPhone || '未留电话' }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Message /></el-icon>
              <span>邮箱：{{ detail.xinlizixunshiEmail || '未留邮箱' }}</span>
            </div>
          </div>

          <el-divider />

          <div class="detail-section">
            <h3>个人介绍</h3>
            <div class="detail-content-text">
              {{ detail.xinlizixunshiContent || '暂无介绍' }}
            </div>
          </div>

          <div class="action-section">
            <el-button type="primary" size="large" @click="handleContact">
              <el-icon><Phone /></el-icon>
              预约咨询
            </el-button>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getXinlizixunshiInfo } from '@/api/xinlizixunshi'

const route = useRoute()
const loading = ref(false)
const detail = ref(null)

onMounted(async () => {
  await fetchDetail()
})

const fetchDetail = async () => {
  loading.value = true
  try {
    const res = await getXinlizixunshiInfo(route.params.id)
    if (res && res.data) {
      detail.value = res.data
    }
  } catch (error) {
    console.error('获取详情失败:', error)
    ElMessage.error('获取详情失败')
  } finally {
    loading.value = false
  }
}

const handleContact = () => {
  if (detail.value?.xinlizixunshiPhone) {
    window.location.href = `tel:${detail.value.xinlizixunshiPhone}`
  } else {
    ElMessage.info('咨询师未留联系电话')
  }
}
</script>

<style lang="scss" scoped>
.detail-page {
  max-width: 800px;
  margin: 0 auto;
}

.detail-card {
  border-radius: 12px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.detail-body {
  .detail-header {
    display: flex;
    align-items: center;
    gap: 30px;
    margin-bottom: 30px;
    
    .avatar {
      width: 120px;
      height: 120px;
      border-radius: 50%;
      background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      flex-shrink: 0;
    }
    
    .info {
      .name {
        font-size: 28px;
        font-weight: 600;
        color: #333;
        margin-bottom: 8px;
      }
      
      .title {
        font-size: 16px;
        color: #666;
      }
    }
  }

  .detail-meta {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 15px;
    margin-bottom: 20px;

    .meta-item {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 15px;
      color: #666;
    }
  }

  .detail-section {
    margin: 30px 0;

    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #333;
      margin-bottom: 15px;
    }

    .detail-content-text {
      font-size: 15px;
      color: #666;
      line-height: 1.8;
      white-space: pre-wrap;
      min-height: 100px;
    }
  }

  .action-section {
    text-align: center;
    padding: 30px 0;
  }
}
</style>