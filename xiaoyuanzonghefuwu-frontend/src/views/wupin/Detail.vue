<template>
  <div class="wupin-detail-page">
    <el-button class="back-btn" @click="handleBack">
      <el-icon><ArrowLeft /></el-icon>返回
    </el-button>

    <el-row :gutter="24">
      <el-col :xs="24" :sm="16">
        <el-card class="detail-card">
          <div class="detail-header">
            <div class="header-emoji">📚</div>
            <div class="header-info">
              <h1>{{ detail.wupinName || '物品详情' }}</h1>
              <div class="header-meta">
                <el-tag type="success" v-if="displayCondition">{{ displayCondition }}</el-tag>
                <span class="view-count" v-if="detail.clicknum">
                  <el-icon><View /></el-icon> {{ detail.clicknum }} 次浏览
                </span>
              </div>
            </div>
          </div>

          <div class="detail-content">
            <div class="content-section" v-if="detailImageUrl">
              <h3 class="section-title">📷 物品图片</h3>
              <div class="photo-box">
                <img :src="detailImageUrl" :alt="detail.wupinName || '物品图片'" />
              </div>
            </div>

            <div class="content-section">
              <h3 class="section-title">📝 物品描述</h3>
              <p class="section-text">{{ detail.wupinContent || '暂无描述' }}</p>
            </div>

            <div class="content-section">
              <h3 class="section-title">💰 价格</h3>
              <p class="section-text price-text">
                <span class="price-symbol">￥</span>
                <span class="price-value">{{ displayPrice }}</span>
              </p>
            </div>

            <div class="content-section">
              <h3 class="section-title">👤 卖家信息</h3>
              <div class="seller-card">
                <el-avatar :size="48" :icon="User" />
                <div class="seller-info">
                  <div class="seller-name">{{ detail.yonghuName || '卖家' }}</div>
                  <div class="seller-contact">
                    <el-icon><Iphone /></el-icon> {{ sellerPhone }}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-card>

        <el-card class="comment-card">
          <template #header>
            <div class="card-header">
              <span>💬 留言咨询</span>
              <span class="comment-count">{{ comments.length }} 条</span>
            </div>
          </template>

          <div class="comment-input-box">
            <el-input
              v-model="commentText"
              type="textarea"
              :rows="3"
              placeholder="向卖家提问..."
              class="comment-input"
            />
            <el-button type="primary" class="submit-btn" @click="handleComment">
              发送留言
            </el-button>
          </div>

          <div class="comment-list">
            <div v-for="item in comments" :key="item.id" class="comment-item">
              <div class="comment-avatar">
                <el-avatar :icon="User" :size="40" />
              </div>
              <div class="comment-content">
                <div class="comment-user">{{ item.yonghuName || item.xinlizixunshiName || '匿名用户' }}</div>
                <div class="comment-text">{{ item.wupinLiuyanText || item.replyText || '暂无内容' }}</div>
                <div class="comment-time">{{ formatTime(item.insertTime) }}</div>
              </div>
            </div>
            <el-empty v-if="comments.length === 0" description="暂无留言" />
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="8">
        <el-card class="action-card">
          <h3 class="action-title">🎯 快速操作</h3>
          <el-button v-if="!isOwnItem" type="primary" class="action-btn" @click="handleContact">
            <el-icon><Iphone /></el-icon>联系卖家
          </el-button>
          <el-button class="action-btn" @click="handleCollect">
            <el-icon><Star /></el-icon>收藏物品
          </el-button>
          <el-button class="action-btn" @click="handleShare">
            <el-icon><Share /></el-icon>分享好物
          </el-button>
        </el-card>

        <WupinRealtimeChat v-if="detail.id" :wupin-id="detail.id" />

        <el-card class="info-card">
          <h3 class="info-title">📊 物品信息</h3>
          <div class="info-list">
            <div class="info-item">
              <span class="info-label">发布时间</span>
              <span class="info-value">{{ formatTime(detail.insertTime) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">浏览数</span>
              <span class="info-value">{{ detail.clicknum || 0 }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">成色</span>
              <el-tag size="small" type="success">{{ displayCondition || '待定' }}</el-tag>
            </div>
          </div>
        </el-card>

        <el-card class="related-card">
          <h3 class="related-title">🔥 其他好物</h3>
          <div class="related-list">
            <div v-for="item in relatedItems" :key="item.id" class="related-item" @click="handleDetail(item.id)">
              <div class="related-emoji">📦</div>
              <div class="related-info">
                <div class="related-name">{{ item.wupinName }}</div>
                <div class="related-price">￥{{ formatPrice(item.wupinNewMoney ?? item.wupinPrice) }}</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, View, User, Iphone, Star, Share } from '@element-plus/icons-vue'
import {
  getWupinInfo,
  getWupinList,
  getWupinLiuyanList,
  saveWupinLiuyan
} from '@/api/wupin'
import WupinRealtimeChat from '@/components/wupin/WupinRealtimeChat.vue'
import { resolveFileUrl } from '@/utils/media'

const router = useRouter()
const route = useRoute()

const detail = ref({})
const commentText = ref('')
const comments = ref([])
const relatedItems = ref([])

const currentUserId = computed(() => {
  try {
    const raw = localStorage.getItem('userInfo')
    if (!raw) return 0
    const parsed = JSON.parse(raw)
    return Number(parsed.userId || parsed.userid || parsed.id || 0)
  } catch (error) {
    return 0
  }
})

const isOwnItem = computed(() => {
  return Number(detail.value?.yonghuId || 0) === Number(currentUserId.value || 0)
})

const displayPrice = computed(() => {
  return formatPrice(detail.value?.wupinNewMoney ?? detail.value?.wupinPrice)
})

const sellerPhone = computed(() => {
  return detail.value?.yonghuPhone || detail.value?.lianxirenPhone || detail.value?.phone || '私聊获取'
})

const displayCondition = computed(() => {
  return detail.value?.wupinMaichuValue || detail.value?.wupinNew || ''
})

const detailImageUrl = computed(() => resolveFileUrl(detail.value?.wupinPhoto))

const loadPageData = async () => {
  await fetchDetail()
  await fetchComments()
  await fetchRelated()
}

onMounted(loadPageData)

watch(() => route.params.id, () => {
  loadPageData()
})

const fetchDetail = async () => {
  try {
    const id = route.params.id
    const res = await getWupinInfo(id)
    if (res && res.data) {
      detail.value = res.data
    }
  } catch (error) {
    console.error('获取物品详情失败:', error)
  }
}

const fetchRelated = async () => {
  try {
    const res = await getWupinList({ page: 1, limit: 5 })
    if (res && res.data) {
      relatedItems.value = res.data.list || res.data || []
    }
  } catch (error) {
    console.error('获取相关物品失败:', error)
  }
}

const fetchComments = async () => {
  try {
    const res = await getWupinLiuyanList({
      page: 1,
      limit: 100,
      wupinId: route.params.id,
      orderBy: 'insert_time'
    })
    comments.value = res?.data?.list || []
  } catch (error) {
    console.error('获取物品留言失败:', error)
  }
}

const handleBack = () => router.back()
const handleContact = () => ElMessage.success('已发起聊天请求')
const handleCollect = () => ElMessage.success('已收藏')
const handleShare = () => ElMessage.success('分享链接已复制')
const handleComment = async () => {
  if (!commentText.value.trim()) {
    ElMessage.warning('请输入留言内容')
    return
  }
  try {
    await saveWupinLiuyan({
      wupinId: Number(route.params.id),
      wupinLiuyanText: commentText.value.trim()
    })
    commentText.value = ''
    ElMessage.success('留言已发送')
    await fetchComments()
  } catch (error) {
    console.error('发表物品留言失败:', error)
  }
}
const handleDetail = (id) => router.push(`/wupin/${id}`)

const formatPrice = (value) => {
  if (value === null || value === undefined || value === '') return '面议'
  return value
}

const formatTime = (time) => {
  if (!time) return '待定'
  const date = new Date(time)
  return `${date.getMonth() + 1}/${date.getDate()}`
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

.wupin-detail-page {
  max-width: 1200px;
  margin: 0 auto;
  padding-top: 20px;
}

.back-btn {
  margin-bottom: 16px;
  border-radius: 10px;
  border: 2px solid $primary;
  
  &:hover {
    transform: translateX(-4px);
  }
}

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
    
    .header-emoji { font-size: 64px; }
    
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
      &:last-child { border-bottom: none; }
      
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
      .price-text {
        .price-symbol {
          font-size: 18px;
          color: $secondary-dark;
          font-weight: 600;
        }
        .price-value {
          font-size: 32px;
          color: $secondary-dark;
          font-weight: 700;
        }
      }
    }
    
    .seller-card {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px;
      background: $bg-warm;
      border-radius: 12px;
      
      .seller-info {
        .seller-name {
          font-size: 16px;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 4px;
        }
        .seller-contact {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 14px;
          color: #666;
        }
      }
    }

    .photo-box {
      width: 100%;
      max-width: 420px;
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid #dcdfe6;

      img {
        width: 100%;
        height: auto;
        display: block;
      }
    }
  }
}

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
    .comment-count { font-size: 14px; color: #888; }
  }
  
  .comment-input-box {
    margin-bottom: 20px;
    .comment-input { margin-bottom: 12px; }
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
      &:last-child { border-bottom: none; }
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
      &:last-child { border-bottom: none; }
      .info-label { font-size: 14px; color: #888; }
      .info-value { font-size: 14px; font-weight: 600; color: $text-primary; }
    }
  }
}

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
      &:last-child { border-bottom: none; }
      &:hover .related-name { color: $primary; }
      .related-emoji { font-size: 32px; }
      .related-info {
        flex: 1;
        .related-name {
          font-size: 14px;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 4px;
          transition: color 0.2s;
        }
        .related-price {
          font-size: 13px;
          color: $secondary-dark;
          font-weight: 600;
        }
      }
    }
  }
}

@media (max-width: 768px) {
  .detail-header {
    flex-direction: column;
    text-align: center;
  }
  .header-meta { justify-content: center; }
}
</style>
