<template>
  <div class="counselor-dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%)">
              <el-icon :size="28"><ChatDotRound /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.chatCount }}</div>
              <div class="stat-label">咨询记录</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%)">
              <el-icon :size="28"><Message /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.liuyanCount }}</div>
              <div class="stat-label">待回复留言</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)">
              <el-icon :size="28"><User /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.userCount }}</div>
              <div class="stat-label">服务人数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-content">
            <div class="stat-icon" style="background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)">
              <el-icon :size="28"><Star /></el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ stats.collectionCount }}</div>
              <div class="stat-label">被收藏次数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近咨询记录 -->
    <el-row :gutter="20" class="mt-4">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="title">最近咨询记录</span>
              <el-button type="primary" text @click="router.push('/counselor/chat')">查看全部</el-button>
            </div>
          </template>
          <el-table :data="recentChats" style="width: 100%" v-loading="loading">
            <el-table-column prop="yonghuName" label="用户" width="120" />
            <el-table-column prop="chatIssue" label="咨询内容" min-width="200" show-overflow-tooltip />
            <el-table-column prop="zhuangtaiTypes" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getStatusType(row.zhuangtaiTypes)">
                  {{ getStatusText(row.zhuangtaiTypes) }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="insertTime" label="时间" width="180" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>

    <!-- 留言列表 -->
    <el-row :gutter="20" class="mt-4">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">
              <span class="title">最新留言</span>
              <el-button type="primary" text @click="router.push('/counselor/liuyan')">查看全部</el-button>
            </div>
          </template>
          <el-table :data="recentLiuyans" style="width: 100%" v-loading="loading">
            <el-table-column prop="yonghuName" label="用户" width="120" />
            <el-table-column prop="xinlizixunshiLiuyanText" label="留言内容" min-width="200" show-overflow-tooltip />
            <el-table-column prop="insertTime" label="时间" width="180" />
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" text size="small" @click="replyLiuyan(row)">回复</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ChatDotRound, Message, User, Star } from '@element-plus/icons-vue'
import { getCounselorChatList } from '@/api/xinlizixunshi'
import { getXinlizixunshiLiuyanList } from '@/api/xinlizixunshi'
import { ElMessage } from 'element-plus'

const router = useRouter()

const loading = ref(false)
const stats = reactive({
  chatCount: 0,
  liuyanCount: 0,
  userCount: 0,
  collectionCount: 0
})

const recentChats = ref([])
const recentLiuyans = ref([])

const getStatusType = (status) => {
  const types = {
    0: 'warning',
    1: 'success',
    2: 'info'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    0: '待回复',
    1: '已回复',
    2: '已处理'
  }
  return texts[status] || '未知'
}

const loadStats = async () => {
  try {
    // 获取咨询统计（不过滤状态，获取所有咨询记录）
    const chatRes = await getCounselorChatList({ page: 1, limit: 100 })
    stats.chatCount = chatRes.data.total || 0
    
    // 获取留言统计
    const liuyanRes = await getXinlizixunshiLiuyanList({ page: 1, limit: 100 })
    stats.liuyanCount = liuyanRes.data.total || 0
    
    // 服务人数：统计不同用户数量
    stats.userCount = new Set((chatRes.data.list || []).map(item => item.yonghuId)).size
    
    // 被收藏次数（暂时用咨询师收藏表数据）
    stats.collectionCount = 0
  } catch (error) {
    console.error('加载统计数据失败', error)
  }
}

const loadRecentChats = async () => {
  loading.value = true
  try {
    const res = await getCounselorChatList({ page: 1, limit: 5, orderBy: 'insert_time', order: 'desc' })
    recentChats.value = res.data.list || []
    // 更新咨询记录数
    stats.chatCount = res.data.total || 0
  } catch (error) {
    ElMessage.error('加载咨询记录失败')
  } finally {
    loading.value = false
  }
}

const loadRecentLiuyans = async () => {
  try {
    const res = await getXinlizixunshiLiuyanList({ page: 1, limit: 5, orderBy: 'insert_time', order: 'desc' })
    recentLiuyans.value = res.data.list || []
  } catch (error) {
    console.error('加载留言失败', error)
  }
}

const replyLiuyan = (row) => {
  router.push(`/counselor/liuyan?reply=${row.id}`)
}

onMounted(() => {
  loadStats()
  loadRecentChats()
  loadRecentLiuyans()
})
</script>

<style lang="scss" scoped>
.counselor-dashboard {
  .stats-row {
    .stat-card {
      border-radius: 12px;
      
      :deep(.el-card__body) {
        padding: 20px;
      }

      .stat-content {
        display: flex;
        align-items: center;
        gap: 16px;

        .stat-icon {
          width: 56px;
          height: 56px;
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #fff;
        }

        .stat-info {
          flex: 1;

          .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: #1e293b;
            line-height: 1;
          }

          .stat-label {
            font-size: 13px;
            color: #64748b;
            margin-top: 4px;
          }
        }
      }
    }
  }

  .mt-4 {
    margin-top: 20px;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .title {
      font-size: 16px;
      font-weight: 600;
      color: #1e293b;
    }
  }
}
</style>
