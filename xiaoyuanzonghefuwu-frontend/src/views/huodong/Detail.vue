<template>
  <div class="huodong-detail-page">
    <!-- 返回按钮 -->
    <el-button class="back-btn" @click="handleBack">
      <el-icon><ArrowLeft /></el-icon>返回
    </el-button>

    <el-row :gutter="24">
      <el-col :xs="24" :sm="16">
        <!-- 活动头部 -->
        <el-card class="detail-card">
          <div class="detail-header">
            <div class="header-emoji">🎪</div>
            <div class="header-info">
              <h1>{{ detail.huodongName || '活动详情' }}</h1>
              <div class="header-meta">
                <el-tag type="success" v-if="detail.status">{{ detail.status }}</el-tag>
                <span class="view-count" v-if="detail.clicknum">
                  <el-icon><View /></el-icon> {{ detail.clicknum }} 次浏览
                </span>
              </div>
            </div>
          </div>

          <div class="detail-content">
            <div class="content-section">
              <h3 class="section-title">📝 活动介绍</h3>
              <p class="section-text">{{ detail.huodongContent || '暂无详细介绍' }}</p>
            </div>

            <div class="content-section">
              <h3 class="section-title">📍 活动地点</h3>
              <p class="section-text">{{ detail.huodongLocation || '地点待定' }}</p>
            </div>

            <div class="content-section">
              <h3 class="section-title">⏰ 活动时间</h3>
              <p class="section-text">
                {{ formatTime(detail.kaishiTime) }} 至 {{ formatTime(detail.jieshuTime) }}
              </p>
            </div>

            <div class="content-section" v-if="detail.huodongFile">
              <h3 class="section-title">📎 附件</h3>
              <el-button type="primary" text @click="handleDownload">
                <el-icon><Download /></el-icon>下载附件
              </el-button>
            </div>
          </div>
        </el-card>

        <!-- 留言区 -->
        <el-card class="comment-card">
          <template #header>
            <div class="card-header">
              <span>💬 留言互动</span>
              <span class="comment-count">{{ comments.length }} 条</span>
            </div>
          </template>

          <!-- 发表留言 -->
          <div class="comment-input-box">
            <el-input
              v-model="commentText"
              type="textarea"
              :rows="3"
              placeholder="写下你的想法..."
              class="comment-input"
            />
            <el-button type="primary" class="submit-btn" @click="handleComment">
              发表留言
            </el-button>
          </div>

          <!-- 留言列表 -->
          <div class="comment-list">
            <div v-for="item in comments" :key="item.id" class="comment-item">
              <div class="comment-avatar">
                <el-avatar :icon="User" :size="40" />
              </div>
              <div class="comment-content">
                <div class="comment-user">{{ item.yonghuName || item.xinlizixunshiName || '匿名用户' }}</div>
                <div class="comment-text">{{ item.huodongLiuyanText || item.replyText || '暂无内容' }}</div>
                <div class="comment-time">{{ formatTime(item.insertTime) }}</div>
              </div>
            </div>
            <el-empty v-if="comments.length === 0" description="暂无留言，快来抢沙发吧" />
          </div>
        </el-card>
      </el-col>

      <!-- 侧边栏 -->
      <el-col :xs="24" :sm="8">
        <el-card class="action-card">
          <h3 class="action-title">🎯 参与方式</h3>
          <el-button
            type="primary"
            class="action-btn"
            :loading="joining || checkingJoinStatus"
            :disabled="joined"
            @click="handleJoin"
          >
            {{ joined ? '已报名' : '立即报名' }}
          </el-button>
          <el-button class="action-btn" @click="handleCollect">
            <el-icon><Star /></el-icon>收藏活动
          </el-button>
          <el-button class="action-btn" @click="handleShare">
            <el-icon><Share /></el-icon>分享活动
          </el-button>
        </el-card>

        <el-card class="info-card">
          <h3 class="info-title">📊 活动信息</h3>
          <div class="info-list">
            <div class="info-item">
              <span class="info-label">发布者</span>
              <span class="info-value">{{ detail.fabuzhe || '管理员' }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">浏览数</span>
              <span class="info-value">{{ detail.clicknum || 0 }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">状态</span>
              <el-tag size="small" type="success">报名中</el-tag>
            </div>
          </div>
        </el-card>

        <el-card class="related-card">
          <h3 class="related-title">🔥 热门活动</h3>
          <div class="related-list">
            <div
              v-for="item in hotActivities"
              :key="item.id"
              class="related-item"
              @click="handleDetail(item.id)"
            >
              <div class="related-emoji">🎪</div>
              <div class="related-info">
                <div class="related-name">{{ item.huodongName }}</div>
                <div class="related-meta">{{ formatTime(item.kaishiTime) }}</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft, View, Download, User, Star, Share
} from '@element-plus/icons-vue'
import {
  getHuodongInfo,
  getHuodongList,
  getHuodongLiuyanList,
  saveHuodongLiuyan
} from '@/api/huodong'
import { addHuodongOrder, getHuodongOrderList } from '@/api/huodongOrder'

const router = useRouter()
const route = useRoute()

const detail = ref({})
const commentText = ref('')
const comments = ref([])
const hotActivities = ref([])
const joining = ref(false)
const joined = ref(false)
const checkingJoinStatus = ref(false)

const loadPageData = async () => {
  await fetchDetail()
  await fetchJoinStatus()
  await fetchComments()
  await fetchHotActivities()
}

onMounted(loadPageData)

watch(() => route.params.id, () => {
  loadPageData()
})

const fetchDetail = async () => {
  try {
    const id = route.params.id
    const res = await getHuodongInfo(id)
    if (res && res.data) {
      detail.value = res.data
    }
  } catch (error) {
    console.error('获取活动详情失败:', error)
  }
}

const fetchHotActivities = async () => {
  try {
    const res = await getHuodongList({ page: 1, limit: 5, orderBy: 'huodong_clicknum' })
    if (res && res.data) {
      hotActivities.value = res.data.list || res.data || []
    }
  } catch (error) {
    console.error('获取热门活动失败:', error)
  }
}

const fetchComments = async () => {
  try {
    const res = await getHuodongLiuyanList({
      page: 1,
      limit: 100,
      huodongId: route.params.id,
      orderBy: 'insert_time'
    })
    comments.value = res?.data?.list || []
  } catch (error) {
    console.error('获取活动留言失败:', error)
  }
}

const handleBack = () => {
  router.back()
}

const fetchJoinStatus = async () => {
  joined.value = false
  const token = localStorage.getItem('token')
  const userRole = localStorage.getItem('userRole')
  if (!token || userRole !== 'yonghu') return

  checkingJoinStatus.value = true
  try {
    const huodongId = Number(route.params.id)
    if (!huodongId) return
    const res = await getHuodongOrderList({
      page: 1,
      limit: 1,
      huodongId,
      orderBy: 'id'
    })
    const total = Number(res?.data?.total || 0)
    joined.value = total > 0
  } catch (error) {
    console.error('获取报名状态失败:', error)
  } finally {
    checkingJoinStatus.value = false
  }
}

const handleJoin = async () => {
  if (joined.value) {
    ElMessage.info('你已报名该活动')
    return
  }
  const token = localStorage.getItem('token')
  if (!token) {
    ElMessage.warning('请先登录后再报名')
    router.push('/login')
    return
  }
  if (localStorage.getItem('userRole') !== 'yonghu') {
    ElMessage.warning('仅普通用户可以报名活动')
    return
  }
  const huodongId = Number(route.params.id)
  if (!huodongId) {
    ElMessage.error('活动信息异常，请刷新重试')
    return
  }
  joining.value = true
  try {
    await addHuodongOrder({ huodongId })
    joined.value = true
    ElMessage.success('报名成功！')
  } catch (error) {
    console.error('活动报名失败:', error)
  } finally {
    joining.value = false
  }
}

const handleCollect = () => {
  ElMessage.success('已收藏')
}

const handleShare = () => {
  ElMessage.success('分享链接已复制')
}

const handleComment = async () => {
  if (!commentText.value.trim()) {
    ElMessage.warning('请输入留言内容')
    return
  }
  try {
    await saveHuodongLiuyan({
      huodongId: Number(route.params.id),
      huodongLiuyanText: commentText.value.trim()
    })
    commentText.value = ''
    ElMessage.success('留言成功')
    await fetchComments()
  } catch (error) {
    console.error('发表活动留言失败:', error)
  }
}

const handleDownload = () => {
  ElMessage.info('下载功能开发中')
}

const handleDetail = (id) => {
  router.push(`/huodong/${id}`)
}

const formatTime = (time) => {
  if (!time) return '待定'
  const date = new Date(time)
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${month}/${day} ${hours}:${minutes}`
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

.huodong-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 20px;
}

// 返回按钮
.back-btn {
  margin-bottom: 16px;
  border-radius: 10px;
  border: 2px solid $primary;
  
  &:hover {
    transform: translateX(-4px);
  }
}

// 详情卡片
.detail-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;
  background: #fff;
  
  .detail-header {
    display: flex;
    align-items: center;
    gap: 20px;
    padding-bottom: 20px;
    border-bottom: 2px dashed $bg-light;
    
    .header-emoji {
      font-size: 64px;
    }
    
    .header-info {
      flex: 1;
      
      h1 {
        font-size: 26px;
        font-weight: 800;
        color: $text-primary;
        margin: 0 0 12px 0;
      }
      
      .header-meta {
        display: flex;
        align-items: center;
        gap: 12px;
        
        .view-count {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 13px;
          color: #888;
        }
      }
    }
  }
  
  .detail-content {
    .content-section {
      padding: 20px 0;
      border-bottom: 1px dashed $bg-light;
      
      &:last-child {
        border-bottom: none;
      }
      
      .section-title {
        font-size: 18px;
        font-weight: 700;
        color: $text-primary;
        margin: 0 0 12px 0;
      }
      
      .section-text {
        font-size: 15px;
        color: #666;
        line-height: 1.8;
        margin: 0;
      }
    }
  }
}

// 评论卡片
.comment-card {
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
    
    .comment-count {
      font-size: 14px;
      color: #888;
    }
  }
  
  .comment-input-box {
    margin-bottom: 20px;
    
    .comment-input {
      margin-bottom: 12px;
    }
    
    .submit-btn {
      float: right;
      background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
      border-color: $primary-dark;
    }
  }
  
  .comment-list {
    .comment-item {
      display: flex;
      gap: 16px;
      padding: 16px 0;
      border-bottom: 1px dashed $bg-light;
      
      &:last-child {
        border-bottom: none;
      }
      
      .comment-content {
        flex: 1;
        
        .comment-user {
          font-size: 14px;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 6px;
        }
        
        .comment-text {
          font-size: 14px;
          color: #666;
          margin-bottom: 6px;
        }
        
        .comment-time {
          font-size: 12px;
          color: #999;
        }
      }
    }
  }
}

// 操作卡片
.action-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;
  background: #fff;
  text-align: center;
  
  .action-title {
    font-size: 18px;
    font-weight: 700;
    color: $text-primary;
    margin: 0 0 16px 0;
  }
  
  .action-btn {
    width: 100%;
    margin-bottom: 12px;
    border-radius: 10px;
    
    &:first-of-type {
      background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
      border-color: $primary-dark;
    }
  }
}

// 信息卡片
.info-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;
  background: #fff;
  
  .info-title {
    font-size: 18px;
    font-weight: 700;
    color: $text-primary;
    margin: 0 0 16px 0;
  }
  
  .info-list {
    .info-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px dashed $bg-light;
      
      &:last-child {
        border-bottom: none;
      }
      
      .info-label {
        font-size: 14px;
        color: #888;
      }
      
      .info-value {
        font-size: 14px;
        font-weight: 600;
        color: $text-primary;
      }
    }
  }
}

// 相关卡片
.related-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  background: #fff;
  
  .related-title {
    font-size: 18px;
    font-weight: 700;
    color: $text-primary;
    margin: 0 0 16px 0;
  }
  
  .related-list {
    .related-item {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 12px 0;
      border-bottom: 1px dashed $bg-light;
      cursor: pointer;
      
      &:last-child {
        border-bottom: none;
      }
      
      &:hover .related-name {
        color: $primary;
      }
      
      .related-emoji {
        font-size: 32px;
      }
      
      .related-info {
        flex: 1;
        
        .related-name {
          font-size: 14px;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 4px;
          transition: color 0.2s;
        }
        
        .related-meta {
          font-size: 12px;
          color: #999;
        }
      }
    }
  }
}

// 响应式
@media (max-width: 768px) {
  .detail-header {
    flex-direction: column;
    text-align: center;
  }
  
  .header-meta {
    justify-content: center;
  }
}
</style>
