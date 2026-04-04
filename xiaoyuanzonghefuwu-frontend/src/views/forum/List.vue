<template>
  <div class="forum-list-page">
    <div class="page-header">
      <div class="header-content">
        <div class="header-text">
          <h1>校园论坛</h1>
          <p>图文发帖，聊点实在的</p>
        </div>
        <el-button type="primary" class="publish-btn" @click="handlePublish">
          <el-icon><Plus /></el-icon>发帖
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <div class="search-box">
        <el-input
          v-model="searchForm.title"
          placeholder="搜索帖子..."
          clearable
          class="search-input"
          @clear="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </el-card>

    <div class="forum-list">
      <el-card
        v-for="item in forumList"
        :key="item.id"
        class="forum-card"
        shadow="hover"
        @click="handleDetail(item.id)"
      >
        <div class="card-left">
          <div class="card-avatar">
            <el-avatar :size="48" :icon="User" />
          </div>
          <div class="card-main">
            <div class="card-header">
              <h3 class="card-title">{{ item.forumName }}</h3>
              <el-tag size="small" type="info">{{ item.forumValue || '帖子' }}</el-tag>
            </div>
            <div v-if="getPostImages(item).length" class="card-image-preview">
              <img :src="getPostImages(item)[0]" :alt="item.forumName" />
            </div>
            <p class="card-content">{{ getPostText(item) || '暂无内容' }}</p>
            <div class="card-meta">
              <span class="meta-author">
                <el-icon><User /></el-icon> {{ item.yonghuName || item.uusername || '楼主' }}
              </span>
              <span class="meta-time">
                <el-icon><Clock /></el-icon> {{ formatTime(item.insertTime) }}
              </span>
            </div>
          </div>
        </div>
        <div class="card-right">
          <div class="stat-item">
            <el-icon><ChatDotRound /></el-icon>
            <span>{{ item.superNumber || 0 }}</span>
          </div>
        </div>
      </el-card>
    </div>

    <el-empty v-if="forumList.length === 0" description="还没有帖子">
      <el-button type="primary" @click="handlePublish">发第一个帖</el-button>
    </el-empty>

    <div class="pagination-box" v-if="total > pageSize">
      <el-pagination
        :current-page="currentPage"
        :page-size="pageSize"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>

    <el-dialog v-model="publishVisible" title="发布帖子" width="600px">
      <el-form :model="publishForm" label-width="84px">
        <el-form-item label="帖子标题">
          <el-input
            v-model="publishForm.forumName"
            maxlength="60"
            show-word-limit
            placeholder="标题尽量清楚"
          />
        </el-form-item>
        <el-form-item label="帖子内容">
          <el-input
            v-model="publishForm.forumContent"
            type="textarea"
            :rows="6"
            maxlength="1000"
            show-word-limit
            placeholder="把时间、地点、关键信息写明白"
          />
        </el-form-item>
        <el-form-item label="帖子类型">
          <el-select v-model="publishForm.forumTypes" style="width: 100%">
            <el-option
              v-for="option in forumTypeOptions"
              :key="option.codeIndex"
              :label="option.indexName"
              :value="Number(option.codeIndex)"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="上传图片">
          <el-upload
            class="uploader"
            :show-file-list="false"
            :http-request="handleUploadImage"
            accept="image/*"
          >
            <div class="upload-box">
              <el-icon><Plus /></el-icon>
              <span>添加图片</span>
            </div>
          </el-upload>
          <div class="image-list" v-if="publishImages.length">
            <div v-for="(img, index) in publishImages" :key="img" class="image-item">
              <img :src="resolveFileUrl(img)" alt="帖子图片" />
              <el-button type="danger" text @click.stop="removeImage(index)">删除</el-button>
            </div>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="publishVisible = false">取消</el-button>
        <el-button type="primary" :loading="publishLoading" @click="submitPublish">发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getForumList, saveForum } from '@/api/forum'
import { getDictionaryByType } from '@/api/dictionary'
import { uploadImage } from '@/api/file'
import { buildForumContent, extractImagesFromForumContent, stripForumImageTokens, resolveFileUrl } from '@/utils/media'
import { Search, Plus, User, Clock, ChatDotRound } from '@element-plus/icons-vue'

const router = useRouter()

const searchForm = reactive({
  title: ''
})

const forumList = ref([])
const forumTypeOptions = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const publishVisible = ref(false)
const publishLoading = ref(false)
const publishImages = ref([])
const publishForm = reactive({
  forumName: '',
  forumContent: '',
  forumTypes: 1,
  forumStateTypes: 0
})

onMounted(async () => {
  await fetchForumTypes()
  await fetchList()
})

async function fetchForumTypes() {
  try {
    const res = await getDictionaryByType('forum')
    forumTypeOptions.value = res?.data?.list || []
    if (!forumTypeOptions.value.length) return
    const currentType = Number(publishForm.forumTypes)
    const hasCurrent = forumTypeOptions.value.some(item => Number(item.codeIndex) === currentType)
    if (!hasCurrent) {
      publishForm.forumTypes = Number(forumTypeOptions.value[0].codeIndex)
    }
  } catch (error) {
    console.error('获取帖子类型失败:', error)
  }
}

async function fetchList() {
  try {
    const res = await getForumList({
      page: currentPage.value,
      limit: pageSize.value,
      forumName: searchForm.title || '',
      superIds: 0
    })
    if (res?.data) {
      forumList.value = res.data.list || []
      total.value = res.data.total || 0
    }
  } catch (error) {
    console.error('获取论坛列表失败:', error)
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchList()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  fetchList()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  fetchList()
}

const handleDetail = (id) => router.push(`/forum/${id}`)

const handlePublish = () => {
  publishForm.forumName = ''
  publishForm.forumContent = ''
  publishForm.forumTypes = forumTypeOptions.value.length
    ? Number(forumTypeOptions.value[0].codeIndex)
    : 1
  publishImages.value = []
  publishVisible.value = true
}

const handleUploadImage = async (option) => {
  try {
    if (publishImages.value.length >= 6) {
      ElMessage.warning('最多上传 6 张图')
      option.onError(new Error('图片数量超限'))
      return
    }
    const res = await uploadImage(option.file)
    publishImages.value.push(res.file)
    option.onSuccess(res)
    ElMessage.success('图片上传成功')
  } catch (error) {
    option.onError(error)
    ElMessage.error('图片上传失败')
  }
}

const removeImage = (index) => {
  publishImages.value.splice(index, 1)
}

const submitPublish = async () => {
  if (!publishForm.forumName.trim()) {
    ElMessage.warning('请输入标题')
    return
  }
  if (!publishForm.forumContent.trim() && publishImages.value.length === 0) {
    ElMessage.warning('请输入内容或上传图片')
    return
  }
  publishLoading.value = true
  try {
    await saveForum({
      forumName: publishForm.forumName.trim(),
      forumContent: buildForumContent(publishForm.forumContent, publishImages.value),
      forumTypes: Number(publishForm.forumTypes) || 1,
      forumStateTypes: 0
    })
    ElMessage.success('发布成功')
    publishVisible.value = false
    currentPage.value = 1
    await fetchList()
  } catch (error) {
    console.error('发布帖子失败:', error)
  } finally {
    publishLoading.value = false
  }
}

const getPostText = (item) => stripForumImageTokens(item?.forumContent || '')

const getPostImages = (item) => extractImagesFromForumContent(item?.forumContent || '')

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
$secondary: #FFB703;
$secondary-dark: #FB8500;
$bg-warm: #FEFAE0;
$bg-light: #E9EDC9;
$text-primary: #2D3436;

.forum-list-page {
  max-width: 1000px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 24px;

  .header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
    border-radius: 20px;
    padding: 32px;
    border: 3px solid $secondary;
    box-shadow: 6px 6px 0 rgba($primary, 0.3);
  }

  .header-text {
    h1 {
      font-size: 32px;
      font-weight: 800;
      color: #fff;
      margin: 0 0 8px 0;
    }

    p {
      font-size: 15px;
      color: rgba(#fff, 0.9);
      margin: 0;
    }
  }

  .publish-btn {
    background: linear-gradient(135deg, $secondary 0%, $secondary-dark 100%);
    border-color: $secondary-dark;
  }
}

.search-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;
  background: #fff;

  .search-box {
    display: flex;
    gap: 12px;

    .search-input {
      flex: 1;
    }
  }
}

.forum-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 24px;
}

.forum-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  background: #fff;

  &:hover {
    transform: translateX(4px);
    box-shadow: 6px 6px 0 rgba($primary, 0.2);
  }

  .card-left {
    display: flex;
    gap: 16px;
  }

  .card-main {
    flex: 1;
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 8px;
  }

  .card-title {
    font-size: 17px;
    font-weight: 700;
    color: $text-primary;
    margin: 0;
  }

  .card-image-preview {
    width: 160px;
    height: 90px;
    border-radius: 8px;
    overflow: hidden;
    margin: 8px 0;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
  }

  .card-content {
    font-size: 14px;
    color: #666;
    margin: 0 0 12px 0;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    white-space: pre-line;
  }

  .card-meta {
    display: flex;
    gap: 16px;
    font-size: 13px;
    color: #888;

    span {
      display: flex;
      align-items: center;
      gap: 4px;
    }
  }

  .card-right {
    display: flex;
    gap: 20px;
    padding-left: 20px;
    border-left: 1px dashed $bg-light;

    .stat-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 4px;
      font-size: 13px;
      color: #666;

      span {
        font-size: 18px;
        font-weight: 700;
        color: $primary;
      }
    }
  }
}

.pagination-box {
  display: flex;
  justify-content: center;
  padding: 24px 0;
}

.upload-box {
  width: 120px;
  height: 88px;
  border: 1px dashed #dcdfe6;
  border-radius: 8px;
  color: #909399;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 6px;
}

.image-list {
  margin-top: 12px;
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.image-item {
  width: 120px;
  display: flex;
  flex-direction: column;
  gap: 6px;

  img {
    width: 120px;
    height: 88px;
    border-radius: 8px;
    object-fit: cover;
  }
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }

  .forum-card {
    .card-left {
      flex-direction: column;
    }

    .card-right {
      border-left: none;
      border-top: 1px dashed $bg-light;
      padding-left: 0;
      padding-top: 12px;
      margin-top: 12px;
    }
  }

  .search-box {
    flex-direction: column;
  }
}
</style>
