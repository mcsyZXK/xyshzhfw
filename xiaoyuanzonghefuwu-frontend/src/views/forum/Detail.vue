<template>
  <div class="forum-detail-page">
    <el-button class="back-btn" @click="handleBack">
      <el-icon><ArrowLeft /></el-icon>返回
    </el-button>

    <el-row :gutter="24">
      <el-col :xs="24" :sm="16">
        <el-card class="post-card">
          <div class="post-header">
            <div class="post-avatar">
              <el-avatar :size="56" :icon="User" />
            </div>
            <div class="post-info">
              <h1 class="post-title">{{ detail.forumName }}</h1>
              <div class="post-meta">
                <span class="meta-author">
                  <el-icon><User /></el-icon> {{ detail.yonghuName || detail.xinlizixunshiName || detail.uusername || '楼主' }}
                </span>
                <span class="meta-time">
                  <el-icon><Clock /></el-icon> {{ formatTime(detail.insertTime) }}
                </span>
                <el-tag size="small">{{ detail.forumValue || '帖子' }}</el-tag>
              </div>
            </div>
          </div>

          <div class="post-content">
            <p>{{ postText || '暂无内容' }}</p>
            <div v-if="postImages.length" class="post-images">
              <img v-for="img in postImages" :key="img" :src="img" alt="帖子图片" />
            </div>
          </div>

          <div class="post-footer">
            <div class="post-stats">
              <span class="stat-item">
                <el-icon><ChatDotRound /></el-icon> {{ replies.length }} 回复
              </span>
            </div>
          </div>
        </el-card>

        <el-card class="replies-card">
          <template #header>
            <div class="card-header">
              <span>回复</span>
              <span class="reply-count">{{ replies.length }} 条</span>
            </div>
          </template>

          <div class="reply-input-box">
            <el-input
              v-model="replyText"
              type="textarea"
              :rows="3"
              placeholder="写下你的回复..."
              class="reply-input"
            />
            <div class="reply-upload-row">
              <el-upload
                :show-file-list="false"
                :http-request="handleUploadReplyImage"
                accept="image/*"
              >
                <el-button plain>上传图片</el-button>
              </el-upload>
              <el-button type="primary" class="submit-btn" @click="handleReply">发表回复</el-button>
            </div>
            <div class="reply-image-list" v-if="replyImages.length">
              <div v-for="(img, index) in replyImages" :key="img" class="reply-image-item">
                <img :src="resolveFileUrl(img)" alt="回复图片" />
                <el-button type="danger" text @click="removeReplyImage(index)">删除</el-button>
              </div>
            </div>
          </div>

          <div class="reply-list">
            <div v-for="item in replies" :key="item.id" class="reply-item">
              <div class="reply-avatar">
                <el-avatar :icon="User" :size="40" />
              </div>
              <div class="reply-content">
                <div class="reply-user">{{ item.yonghuName || item.xinlizixunshiName || item.uusername || '同学' }}</div>
                <div class="reply-text">{{ getReplyText(item) || '暂无内容' }}</div>
                <div v-if="getReplyImages(item).length" class="reply-images">
                  <img v-for="img in getReplyImages(item)" :key="img" :src="img" alt="回复图片" />
                </div>
                <div class="reply-time">{{ formatTime(item.insertTime) }}</div>
              </div>
            </div>
            <el-empty v-if="replies.length === 0" description="暂无回复，抢沙发" />
          </div>
        </el-card>
      </el-col>

      <el-col :xs="24" :sm="8">
        <el-card class="author-card">
          <h3 class="card-title">楼主信息</h3>
          <div class="author-info">
            <el-avatar :size="64" :icon="User" />
            <div class="author-name">{{ detail.yonghuName || detail.xinlizixunshiName || detail.uusername || '未知' }}</div>
          </div>
        </el-card>

        <el-card class="hot-card">
          <h3 class="card-title">热门帖子</h3>
          <div class="hot-list">
            <div v-for="item in hotPosts" :key="item.id" class="hot-item" @click="handleDetail(item.id)">
              <div class="hot-info">
                <div class="hot-name">{{ item.forumName }}</div>
                <div class="hot-meta">{{ formatTime(item.insertTime) }}</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ArrowLeft, User, Clock, ChatDotRound } from '@element-plus/icons-vue'
import { getForumInfo, getForumList, saveForum } from '@/api/forum'
import { uploadImage } from '@/api/file'
import { buildForumContent, extractImagesFromForumContent, stripForumImageTokens, resolveFileUrl } from '@/utils/media'

const router = useRouter()
const route = useRoute()

const detail = ref({})
const replyText = ref('')
const replies = ref([])
const hotPosts = ref([])
const replyImages = ref([])

const postText = computed(() => stripForumImageTokens(detail.value?.forumContent || ''))
const postImages = computed(() => extractImagesFromForumContent(detail.value?.forumContent || ''))

const loadPageData = async () => {
  await fetchDetail()
  await fetchReplies()
  await fetchHot()
}

onMounted(loadPageData)

watch(() => route.params.id, () => {
  loadPageData()
})

const fetchDetail = async () => {
  try {
    const res = await getForumInfo(route.params.id)
    if (res?.data) detail.value = res.data
  } catch (error) {
    console.error('获取帖子详情失败:', error)
  }
}

const fetchReplies = async () => {
  try {
    const res = await getForumList({
      page: 1,
      limit: 100,
      superIds: route.params.id,
      orderBy: 'id'
    })
    replies.value = res?.data?.list || []
  } catch (error) {
    console.error('获取回复失败:', error)
  }
}

const fetchHot = async () => {
  try {
    const res = await getForumList({ page: 1, limit: 5, superIds: 0, orderBy: 'insert_time' })
    hotPosts.value = res?.data?.list || []
  } catch (error) {
    console.error('获取热门帖子失败:', error)
  }
}

const handleBack = () => router.back()

const handleUploadReplyImage = async (option) => {
  try {
    if (replyImages.value.length >= 6) {
      ElMessage.warning('最多上传 6 张图')
      option.onError(new Error('图片数量超限'))
      return
    }
    const res = await uploadImage(option.file)
    replyImages.value.push(res.file)
    option.onSuccess(res)
    ElMessage.success('图片上传成功')
  } catch (error) {
    option.onError(error)
    ElMessage.error('图片上传失败')
  }
}

const removeReplyImage = (index) => {
  replyImages.value.splice(index, 1)
}

const handleReply = async () => {
  if (!replyText.value.trim() && replyImages.value.length === 0) {
    ElMessage.warning('请输入回复内容或上传图片')
    return
  }
  try {
    await saveForum({
      forumName: `回复：${(detail.value.forumName || '帖子').slice(0, 20)}`,
      forumContent: buildForumContent(replyText.value.trim(), replyImages.value),
      superIds: Number(route.params.id),
      forumTypes: detail.value.forumTypes || 1,
      forumStateTypes: 0
    })
    replyText.value = ''
    replyImages.value = []
    ElMessage.success('回复成功')
    await fetchReplies()
  } catch (error) {
    console.error('提交回复失败:', error)
  }
}

const handleDetail = (id) => router.push(`/forum/${id}`)

const getReplyText = (item) => stripForumImageTokens(item?.forumContent || '')

const getReplyImages = (item) => extractImagesFromForumContent(item?.forumContent || '')

const formatTime = (time) => {
  if (!time) return '刚刚'
  const date = new Date(time)
  const now = new Date()
  const diff = now - date
  if (diff < 60000) return '刚刚'
  if (diff < 3600000) return `${Math.floor(diff / 60000)}分钟前`
  if (diff < 86400000) return `${Math.floor(diff / 3600000)}小时前`
  return `${date.getMonth() + 1}/${date.getDate()}`
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$bg-light: #E9EDC9;
$text-primary: #2D3436;

.forum-detail-page {
  max-width: 1000px;
  margin: 0 auto;
  padding-top: 20px;
}

.back-btn {
  margin-bottom: 16px;
  border-radius: 10px;
  border: 2px solid $primary;
}

.post-card,
.replies-card,
.author-card,
.hot-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;
  background: #fff;
}

.post-header {
  display: flex;
  gap: 16px;
  padding-bottom: 20px;
  border-bottom: 2px dashed $bg-light;
}

.post-title {
  font-size: 24px;
  font-weight: 800;
  color: $text-primary;
  margin: 0 0 8px 0;
}

.post-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 13px;
  color: #888;
}

.post-content {
  padding: 20px 0;
  font-size: 15px;
  color: #333;
  line-height: 1.8;
  white-space: pre-line;
}

.post-images,
.reply-images {
  margin-top: 12px;
  display: flex;
  flex-wrap: wrap;
  gap: 10px;

  img {
    width: 140px;
    height: 100px;
    object-fit: cover;
    border-radius: 8px;
  }
}

.post-footer {
  padding-top: 12px;
  border-top: 2px dashed $bg-light;
}

.reply-input-box {
  margin-bottom: 20px;
}

.reply-upload-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 10px;
}

.reply-image-list {
  margin-top: 12px;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.reply-image-item {
  width: 120px;
  display: flex;
  flex-direction: column;
  gap: 6px;

  img {
    width: 120px;
    height: 88px;
    object-fit: cover;
    border-radius: 8px;
  }
}

.reply-item {
  display: flex;
  gap: 12px;
  padding: 16px 0;
  border-bottom: 1px dashed $bg-light;
}

.reply-content {
  flex: 1;
}

.reply-user {
  font-size: 14px;
  font-weight: 600;
  color: $text-primary;
  margin-bottom: 6px;
}

.reply-text {
  font-size: 14px;
  color: #666;
  margin-bottom: 6px;
  white-space: pre-line;
}

.reply-time {
  font-size: 12px;
  color: #999;
}

.card-title {
  font-size: 18px;
  font-weight: 700;
  color: $text-primary;
  margin: 0 0 16px 0;
}

.author-info {
  text-align: center;
}

.author-name {
  margin-top: 12px;
  font-size: 16px;
  font-weight: 600;
  color: $text-primary;
}

.hot-item {
  display: flex;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px dashed $bg-light;
  cursor: pointer;
}

.hot-info {
  flex: 1;
}

.hot-name {
  font-size: 14px;
  font-weight: 600;
  color: $text-primary;
}

.hot-meta {
  font-size: 12px;
  color: #999;
}

@media (max-width: 768px) {
  .post-header {
    flex-direction: column;
  }
}
</style>
