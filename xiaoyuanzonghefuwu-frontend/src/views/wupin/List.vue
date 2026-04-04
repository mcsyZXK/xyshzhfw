<template>
  <div class="wupin-list-page">
    <div class="page-header">
      <div class="header-content">
        <div class="header-text">
          <h1>二手物品</h1>
          <p>好物转手，省钱省心</p>
        </div>
        <el-button v-if="isYonghu" type="primary" class="publish-btn" @click="handlePublish">
          <el-icon><Plus /></el-icon>发布物品
        </el-button>
      </div>
    </div>

    <el-card class="search-card">
      <div class="search-box">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索物品..."
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

    <div class="wupin-grid">
      <el-card
        v-for="item in wupinList"
        :key="item.id"
        class="wupin-card"
        shadow="hover"
        @click="handleDetail(item.id)"
      >
        <div class="card-image">
          <img v-if="resolveItemImage(item)" :src="resolveItemImage(item)" :alt="item.wupinName" />
          <div v-else class="image-placeholder">
            <el-icon><Box /></el-icon>
          </div>
          <div class="card-tag" v-if="item.wupinMaichuValue">{{ item.wupinMaichuValue }}</div>
        </div>
        <div class="card-content">
          <h3 class="card-title">{{ item.wupinName }}</h3>
          <p class="card-desc">{{ item.wupinContent || '暂无描述' }}</p>
          <div class="card-price">
            <span class="price-label">￥</span>
            <span class="price-value">{{ formatPrice(item.wupinNewMoney) }}</span>
          </div>
          <div class="card-footer">
            <div class="seller-info">
              <el-avatar :size="24" :icon="User" />
              <span>{{ item.yonghuName || '卖家' }}</span>
            </div>
            <el-tag size="small" effect="plain">{{ item.wupinValue || '未分类' }}</el-tag>
          </div>
        </div>
      </el-card>
    </div>

    <el-empty v-if="wupinList.length === 0" description="还没有物品">
      <el-button v-if="isYonghu" type="primary" @click="handlePublish">发布第一个物品</el-button>
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

    <el-dialog v-model="publishVisible" title="发布二手物品" width="620px">
      <el-form :model="publishForm" label-width="92px">
        <el-form-item label="物品名称" required>
          <el-input v-model="publishForm.wupinName" maxlength="30" show-word-limit placeholder="例如：高数教材" />
        </el-form-item>
        <el-form-item label="物品类型" required>
          <el-select v-model="publishForm.wupinTypes" style="width: 100%">
            <el-option
              v-for="option in wupinTypeOptions"
              :key="option.codeIndex"
              :label="option.indexName"
              :value="Number(option.codeIndex)"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="交易地点" required>
          <el-input v-model="publishForm.wupinAddress" maxlength="40" show-word-limit placeholder="例如：图书馆南门" />
        </el-form-item>
        <el-form-item label="联系人" required>
          <el-input v-model="publishForm.lianxirenName" maxlength="20" show-word-limit />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="publishForm.lianxirenPhone" maxlength="20" />
        </el-form-item>
        <el-form-item label="原价">
          <el-input-number v-model="publishForm.wupinOldMoney" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="售价" required>
          <el-input-number v-model="publishForm.wupinNewMoney" :min="0" :precision="2" style="width: 100%" />
        </el-form-item>
        <el-form-item label="物品图片">
          <el-upload
            class="uploader"
            :show-file-list="false"
            :http-request="handleUploadImage"
            accept="image/*"
          >
            <img v-if="publishForm.wupinPhoto" :src="resolveFileUrl(publishForm.wupinPhoto)" class="upload-preview" />
            <div v-else class="upload-placeholder">
              <el-icon><Plus /></el-icon>
              <span>上传图片</span>
            </div>
          </el-upload>
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model="publishForm.wupinContent"
            type="textarea"
            :rows="4"
            maxlength="500"
            show-word-limit
            placeholder="说清成色、配件和交易时间"
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
import { getWupinList, saveWupin } from '@/api/wupin'
import { getDictionaryByType } from '@/api/dictionary'
import { uploadImage } from '@/api/file'
import { resolveFileUrl } from '@/utils/media'
import { Search, Plus, User, Box } from '@element-plus/icons-vue'

const router = useRouter()

const isYonghu = ref(false)
const searchForm = reactive({
  name: ''
})

const wupinList = ref([])
const wupinTypeOptions = ref([])
const currentPage = ref(1)
const pageSize = ref(9)
const total = ref(0)

const publishVisible = ref(false)
const publishLoading = ref(false)
const publishForm = reactive({
  wupinName: '',
  wupinPhoto: '',
  wupinAddress: '',
  lianxirenName: '',
  lianxirenPhone: '',
  wupinTypes: 1,
  wupinNumber: 1,
  wupinOldMoney: 0,
  wupinNewMoney: 0,
  wupinContent: ''
})

onMounted(async () => {
  const userRole = localStorage.getItem('userRole')
  isYonghu.value = userRole === 'yonghu'
  await fetchWupinTypes()
  fillDefaultContact()
  await fetchList()
})

const fetchWupinTypes = async () => {
  try {
    const res = await getDictionaryByType('wupin')
    wupinTypeOptions.value = res?.data?.list || []
    if (!wupinTypeOptions.value.length) return
    const currentType = Number(publishForm.wupinTypes)
    const hasCurrent = wupinTypeOptions.value.some(item => Number(item.codeIndex) === currentType)
    if (!hasCurrent) {
      publishForm.wupinTypes = Number(wupinTypeOptions.value[0].codeIndex)
    }
  } catch (error) {
    console.error('获取物品类型失败:', error)
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
    const res = await getWupinList({
      page: currentPage.value,
      limit: pageSize.value,
      wupinName: searchForm.name || '',
      orderBy: 'id'
    })
    if (res?.data) {
      wupinList.value = res.data.list || []
      total.value = res.data.total || 0
    }
  } catch (error) {
    console.error('获取物品列表失败:', error)
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
  router.push(`/wupin/${id}`)
}

const handlePublish = () => {
  if (!isYonghu.value) {
    ElMessage.warning('仅普通用户可以发布物品')
    return
  }
  publishForm.wupinName = ''
  publishForm.wupinPhoto = ''
  publishForm.wupinAddress = ''
  publishForm.wupinTypes = wupinTypeOptions.value.length
    ? Number(wupinTypeOptions.value[0].codeIndex)
    : 1
  publishForm.wupinNumber = 1
  publishForm.wupinOldMoney = 0
  publishForm.wupinNewMoney = 0
  publishForm.wupinContent = ''
  fillDefaultContact()
  publishVisible.value = true
}

const handleUploadImage = async (option) => {
  try {
    const res = await uploadImage(option.file)
    publishForm.wupinPhoto = res.file
    option.onSuccess(res)
    ElMessage.success('图片上传成功')
  } catch (error) {
    option.onError(error)
    ElMessage.error('图片上传失败')
  }
}

const submitPublish = async () => {
  if (!publishForm.wupinName.trim()) {
    ElMessage.warning('请填写物品名称')
    return
  }
  if (!publishForm.wupinAddress.trim()) {
    ElMessage.warning('请填写交易地点')
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
  if (Number(publishForm.wupinNewMoney) <= 0) {
    ElMessage.warning('售价必须大于 0')
    return
  }

  publishLoading.value = true
  try {
    await saveWupin({
      wupinName: publishForm.wupinName.trim(),
      wupinPhoto: publishForm.wupinPhoto || null,
      wupinAddress: publishForm.wupinAddress.trim(),
      lianxirenName: publishForm.lianxirenName.trim(),
      lianxirenPhone: publishForm.lianxirenPhone.trim(),
      wupinTypes: Number(publishForm.wupinTypes) || 1,
      wupinNumber: Number(publishForm.wupinNumber) || 1,
      wupinMaichuTypes: 1,
      wupinOldMoney: Number(publishForm.wupinOldMoney) || 0,
      wupinNewMoney: Number(publishForm.wupinNewMoney) || 0,
      wupinContent: publishForm.wupinContent.trim()
    })
    ElMessage.success('发布成功')
    publishVisible.value = false
    currentPage.value = 1
    await fetchList()
  } catch (error) {
    console.error('发布物品失败:', error)
  } finally {
    publishLoading.value = false
  }
}

const resolveItemImage = (item) => {
  return resolveFileUrl(item?.wupinPhoto)
}

const formatPrice = (value) => {
  if (value === null || value === undefined || value === '') return '面议'
  return Number(value).toFixed(2)
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

.wupin-list-page {
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

  .publish-btn {
    background: linear-gradient(135deg, $secondary 0%, $secondary-dark 100%);
    border-color: $secondary-dark;
    box-shadow: 3px 3px 0 rgba(0, 0, 0, 0.2);

    &:hover {
      transform: translate(-2px, -2px);
      box-shadow: 5px 5px 0 rgba(0, 0, 0, 0.2);
    }
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

.wupin-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-bottom: 24px;
}

.wupin-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  overflow: hidden;
  background: #fff;

  &:hover {
    transform: translateY(-6px) rotate(-1deg);
    box-shadow: 8px 8px 0 rgba($primary, 0.2);
  }

  .card-image {
    height: 170px;
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

    .image-placeholder {
      color: #9aa0a6;
      font-size: 48px;
    }

    .card-tag {
      position: absolute;
      top: 12px;
      right: 12px;
      background: $secondary-dark;
      color: #fff;
      padding: 4px 10px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 600;
    }
  }

  .card-content {
    padding: 16px;

    .card-title {
      font-size: 17px;
      font-weight: 700;
      color: $text-primary;
      margin: 0 0 8px 0;
      display: -webkit-box;
      -webkit-line-clamp: 1;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .card-desc {
      font-size: 13px;
      color: #888;
      margin: 0 0 12px 0;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .card-price {
      margin: 12px 0;

      .price-label {
        font-size: 14px;
        color: $secondary-dark;
        font-weight: 600;
      }

      .price-value {
        font-size: 22px;
        color: $secondary-dark;
        font-weight: 700;
      }
    }

    .card-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 12px;
      border-top: 1px dashed $bg-light;

      .seller-info {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 13px;
        color: #666;
      }
    }
  }
}

.pagination-box {
  display: flex;
  justify-content: center;
  padding: 24px 0;
}

.uploader {
  width: 100%;
}

.upload-preview {
  width: 160px;
  height: 120px;
  object-fit: cover;
  border-radius: 10px;
  border: 1px solid #dcdfe6;
}

.upload-placeholder {
  width: 160px;
  height: 120px;
  border: 1px dashed #dcdfe6;
  border-radius: 10px;
  color: #909399;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

@media (max-width: 992px) {
  .wupin-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 576px) {
  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }

  .wupin-grid {
    grid-template-columns: 1fr;
  }

  .search-box {
    flex-direction: column;
  }
}
</style>
