<template>
  <div class="xunwu-list-page">
    <div class="page-header">
      <div class="header-content">
        <div class="header-text">
          <h1>🔍 失物招领</h1>
          <p>东西丢了，大家一起找</p>
        </div>
        <el-button v-if="isYonghu" type="primary" class="publish-btn" @click="openPublishDialog">
          <el-icon><Plus /></el-icon>发布信息
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <div class="search-box">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索物品名称"
          clearable
          class="search-input"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-select v-model="searchForm.type" placeholder="信息类型" clearable class="type-select">
          <el-option
            v-for="option in xunwuTypeOptions"
            :key="option.codeIndex"
            :label="option.indexName"
            :value="Number(option.codeIndex)"
          />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </el-card>

    <div class="xunwu-grid">
      <el-card
        v-for="item in xunwuList"
        :key="item.id"
        class="xunwu-card"
        shadow="hover"
        @click="handleDetail(item.id)"
      >
        <div class="card-image">
          <img v-if="resolveItemImage(item)" :src="resolveItemImage(item)" :alt="item.xunwuName" />
          <div v-else class="image-placeholder">{{ getTypeEmoji(item.xunwuTypes) }}</div>
          <div class="card-status" :class="Number(item.xunwuTypes) === 2 ? 'status-found' : 'status-lost'">
            {{ Number(item.xunwuTypes) === 2 ? '招领中' : '寻物中' }}
          </div>
        </div>

        <div class="card-content">
          <h3 class="card-title">{{ item.xunwuName }}</h3>
          <p class="card-desc">{{ item.xunwuContent || '暂无描述' }}</p>
          <div class="card-meta">
            <div class="meta-item">
              <el-icon><Location /></el-icon>
              <span>{{ item.diushiAddress || '地点不详' }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Clock /></el-icon>
              <span>{{ formatTime(item.diushiTime || item.insertTime) }}</span>
            </div>
          </div>
          <div class="card-footer">
            <el-tag size="small" :type="Number(item.xunwuTypes) === 2 ? 'success' : 'warning'">
              {{ item.xunwuValue || (Number(item.xunwuTypes) === 2 ? '招领' : '寻物') }}
            </el-tag>
            <span class="contact-info">
              <el-icon><Iphone /></el-icon> {{ item.lianxirenPhone || '私聊获取' }}
            </span>
          </div>
        </div>
      </el-card>
    </div>

    <el-empty v-if="xunwuList.length === 0" description="还没有失物信息">
      <el-button v-if="isYonghu" type="primary" @click="openPublishDialog">发布第一条信息</el-button>
    </el-empty>

    <div class="pagination-box" v-if="total > pageSize">
      <el-pagination
        :current-page="currentPage"
        :page-size="pageSize"
        :page-sizes="[9, 18, 36]"
        layout="total, sizes, prev, pager, next"
        :total="total"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </div>

    <el-dialog v-model="publishVisible" title="发布失物信息" width="620px">
      <el-form :model="publishForm" label-width="92px">
        <el-form-item label="物品名称" required>
          <el-input v-model="publishForm.xunwuName" maxlength="30" show-word-limit placeholder="例如：黑色钱包" />
        </el-form-item>
        <el-form-item label="信息类型" required>
          <el-select v-model="publishForm.xunwuTypes" style="width: 100%">
            <el-option
              v-for="option in xunwuTypeOptions"
              :key="option.codeIndex"
              :label="option.indexName"
              :value="Number(option.codeIndex)"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="丢失时间">
          <el-date-picker
            v-model="publishForm.diushiTime"
            type="datetime"
            value-format="YYYY-MM-DD HH:mm:ss"
            placeholder="请选择丢失时间"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="地点" required>
          <el-input v-model="publishForm.diushiAddress" maxlength="40" show-word-limit placeholder="例如：图书馆二楼" />
        </el-form-item>
        <el-form-item label="物品特征">
          <el-input v-model="publishForm.diushiTezheng" maxlength="80" show-word-limit placeholder="颜色、品牌、挂件" />
        </el-form-item>
        <el-form-item label="联系人" required>
          <el-input v-model="publishForm.lianxirenName" maxlength="20" show-word-limit />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="publishForm.lianxirenPhone" maxlength="20" />
        </el-form-item>
        <el-form-item label="物品图片">
          <el-upload class="uploader" :show-file-list="false" :http-request="handleUploadImage" accept="image/*">
            <img v-if="publishForm.xunwuPhoto" :src="resolveFileUrl(publishForm.xunwuPhoto)" class="upload-preview" />
            <div v-else class="upload-placeholder">
              <el-icon><Plus /></el-icon>
              <span>上传图片</span>
            </div>
          </el-upload>
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="publishForm.xunwuContent"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="写清楚线索"
          />
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
import { Search, Plus, Location, Clock, Iphone } from '@element-plus/icons-vue'
import { getXunwuList, saveXunwu } from '@/api/xunwu'
import { getDictionaryByType } from '@/api/dictionary'
import { uploadImage } from '@/api/file'
import { resolveFileUrl } from '@/utils/media'

const router = useRouter()
const isYonghu = ref(false)
const xunwuList = ref([])
const xunwuTypeOptions = ref([])
const currentPage = ref(1)
const pageSize = ref(9)
const total = ref(0)

const searchForm = reactive({
  name: '',
  type: null
})

const publishVisible = ref(false)
const publishLoading = ref(false)
const publishForm = reactive({
  xunwuName: '',
  xunwuPhoto: '',
  lianxirenName: '',
  lianxirenPhone: '',
  xunwuTypes: 1,
  xunwuZhuangtaiTypes: 0,
  diushiTime: '',
  diushiAddress: '',
  diushiTezheng: '',
  xunwuContent: ''
})

onMounted(async () => {
  const userRole = localStorage.getItem('userRole')
  isYonghu.value = userRole === 'yonghu'
  await fetchXunwuTypes()
  fillDefaultContact()
  await fetchList()
})

const fetchXunwuTypes = async () => {
  try {
    const res = await getDictionaryByType('xunwu')
    xunwuTypeOptions.value = res?.data?.list || []
    if (!xunwuTypeOptions.value.length) return
    const currentType = Number(publishForm.xunwuTypes)
    const exists = xunwuTypeOptions.value.some(item => Number(item.codeIndex) === currentType)
    if (!exists) {
      publishForm.xunwuTypes = Number(xunwuTypeOptions.value[0].codeIndex)
    }
  } catch (error) {
    console.error('获取寻物类型失败:', error)
  }
}

const fillDefaultContact = () => {
  try {
    const raw = localStorage.getItem('userInfo')
    if (!raw) return
    const userInfo = JSON.parse(raw)
    publishForm.lianxirenName = userInfo.yonghuName || userInfo.username || publishForm.lianxirenName
    publishForm.lianxirenPhone = userInfo.yonghuPhone || userInfo.phone || publishForm.lianxirenPhone
  } catch (error) {
    console.error('读取用户信息失败:', error)
  }
}

const fetchList = async () => {
  try {
    const params = {
      page: currentPage.value,
      limit: pageSize.value,
      xunwuName: searchForm.name || '',
      orderBy: 'id'
    }
    if (searchForm.type !== null && searchForm.type !== '' && searchForm.type !== undefined) {
      params.xunwuTypes = Number(searchForm.type)
    }
    const res = await getXunwuList(params)
    if (res?.data) {
      xunwuList.value = res.data.list || []
      total.value = res.data.total || 0
    }
  } catch (error) {
    console.error('获取失物列表失败:', error)
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

const handleDetail = (id) => {
  router.push(`/xunwu/${id}`)
}

const openPublishDialog = () => {
  if (!isYonghu.value) {
    ElMessage.warning('仅普通用户可以发布')
    return
  }
  publishForm.xunwuName = ''
  publishForm.xunwuPhoto = ''
  publishForm.diushiTime = ''
  publishForm.diushiAddress = ''
  publishForm.diushiTezheng = ''
  publishForm.xunwuContent = ''
  publishForm.xunwuTypes = xunwuTypeOptions.value.length ? Number(xunwuTypeOptions.value[0].codeIndex) : 1
  publishForm.xunwuZhuangtaiTypes = 0
  fillDefaultContact()
  publishVisible.value = true
}

const handleUploadImage = async (option) => {
  try {
    const res = await uploadImage(option.file)
    publishForm.xunwuPhoto = res.file
    option.onSuccess(res)
    ElMessage.success('图片上传成功')
  } catch (error) {
    option.onError(error)
    ElMessage.error('图片上传失败')
  }
}

const submitPublish = async () => {
  if (!publishForm.xunwuName.trim()) {
    ElMessage.warning('请填写物品名称')
    return
  }
  if (!publishForm.diushiAddress.trim()) {
    ElMessage.warning('请填写地点')
    return
  }
  if (!publishForm.lianxirenName.trim()) {
    ElMessage.warning('请填写联系人')
    return
  }
  if (!publishForm.lianxirenPhone.trim()) {
    ElMessage.warning('请填写联系电话')
    return
  }
  publishLoading.value = true
  try {
    await saveXunwu({
      xunwuName: publishForm.xunwuName.trim(),
      xunwuPhoto: publishForm.xunwuPhoto || null,
      xunwuTypes: Number(publishForm.xunwuTypes) || 1,
      xunwuZhuangtaiTypes: 0,
      diushiTime: publishForm.diushiTime || null,
      diushiAddress: publishForm.diushiAddress.trim(),
      diushiTezheng: publishForm.diushiTezheng.trim(),
      lianxirenName: publishForm.lianxirenName.trim(),
      lianxirenPhone: publishForm.lianxirenPhone.trim(),
      xunwuContent: publishForm.xunwuContent.trim()
    })
    ElMessage.success('发布成功')
    publishVisible.value = false
    currentPage.value = 1
    await fetchList()
  } catch (error) {
    console.error('发布失物信息失败:', error)
  } finally {
    publishLoading.value = false
  }
}

const resolveItemImage = (item) => resolveFileUrl(item?.xunwuPhoto)

const getTypeEmoji = (typeValue) => {
  const map = {
    1: '🔎',
    2: '🎁'
  }
  return map[Number(typeValue)] || '🎒'
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

.xunwu-list-page {
  max-width: 1200px;
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
}

.search-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;

  .search-box {
    display: flex;
    gap: 12px;
  }

  .search-input {
    flex: 1;
  }

  .type-select {
    width: 160px;
  }
}

.xunwu-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-bottom: 24px;
}

.xunwu-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  cursor: pointer;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);

  &:hover {
    transform: translateY(-6px) rotate(-1deg);
    box-shadow: 8px 8px 0 rgba($primary, 0.2);
  }

  .card-image {
    height: 160px;
    background: linear-gradient(135deg, $bg-warm 0%, $bg-light 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .image-placeholder {
    font-size: 72px;
  }

  .card-status {
    position: absolute;
    top: 12px;
    right: 12px;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;

    &.status-found {
      background: #2D6A4F;
      color: #fff;
    }

    &.status-lost {
      background: #BC4749;
      color: #fff;
    }
  }

  .card-content {
    padding: 16px;
  }

  .card-title {
    font-size: 17px;
    font-weight: 700;
    color: $text-primary;
    margin: 0 0 8px 0;
  }

  .card-desc {
    font-size: 13px;
    color: #888;
    margin: 0 0 12px 0;
  }

  .card-meta {
    margin-bottom: 12px;

    .meta-item {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: #666;
      margin-bottom: 6px;
    }
  }

  .card-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }

  .contact-info {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
    color: #666;
  }
}

.pagination-box {
  display: flex;
  justify-content: center;
  margin-bottom: 8px;
}

.uploader {
  width: 100%;
}

.upload-preview {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 12px;
  border: 2px solid $primary;
}

.upload-placeholder {
  width: 120px;
  height: 120px;
  border-radius: 12px;
  border: 2px dashed $primary;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: $primary;
  gap: 6px;
}

@media (max-width: 992px) {
  .xunwu-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .xunwu-grid {
    grid-template-columns: 1fr;
  }

  .page-header .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .search-card .search-box {
    flex-direction: column;
  }

  .search-card .type-select {
    width: 100%;
  }
}
</style>
