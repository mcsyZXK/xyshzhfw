<template>
  <div class="xunwu-list-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-text">
          <h1>🔍 失物招领</h1>
          <p>丢了东西别着急，大家帮你找</p>
        </div>
        <el-button type="primary" class="publish-btn" v-if="isAdmin" @click="handlePublish">
          <el-icon><Plus /></el-icon>发布信息
        </el-button>
      </div>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <div class="search-box">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索失物..."
          clearable
          class="search-input"
          @clear="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-select v-model="searchForm.type" placeholder="物品类型" clearable class="type-select">
          <el-option label="📱 手机数码" value="手机数码" />
          <el-option label="💼 箱包证件" value="箱包证件" />
          <el-option label="👕 衣物饰品" value="衣物饰品" />
          <el-option label="📚 书籍文具" value="书籍文具" />
          <el-option label="🔑 钥匙卡片" value="钥匙卡片" />
          <el-option label="🎒 其他物品" value="其他" />
        </el-select>
        <el-button type="primary" @click="handleSearch">搜索</el-button>
      </div>
    </el-card>

    <!-- 失物列表 -->
    <div class="xunwu-grid">
      <el-card
        v-for="item in xunwuList"
        :key="item.id"
        class="xunwu-card"
        shadow="hover"
        @click="handleDetail(item.id)"
      >
        <div class="card-image">
          <div class="image-placeholder">{{ getTypeEmoji(item.xunwuType) }}</div>
          <div class="card-status" :class="item.xunwuType === '拾到' ? 'status-found' : 'status-lost'">
            {{ item.xunwuType === '拾到' ? '🟢 已拾到' : '🔴 已丢失' }}
          </div>
        </div>
        <div class="card-content">
          <h3 class="card-title">{{ item.xunwuName }}</h3>
          <p class="card-desc">{{ item.xunwuContent || '暂无描述' }}</p>
          <div class="card-meta">
            <div class="meta-item">
              <el-icon><Location /></el-icon>
              <span>{{ item.xunwuLocation || '地点不详' }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Clock /></el-icon>
              <span>{{ formatTime(item.insertTime) }}</span>
            </div>
          </div>
          <div class="card-footer">
            <el-tag size="small" :type="item.xunwuType === '拾到' ? 'success' : 'warning'">
              {{ item.xunwuType === '拾到' ? '招领' : '寻物' }}
            </el-tag>
            <span class="contact-info">
              <el-icon><Iphone /></el-icon> {{ item.phone || '私聊获取' }}
            </span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 空状态 -->
    <el-empty v-if="xunwuList.length === 0" description="还没有失物信息哦">
      <el-button type="primary" v-if="isAdmin" @click="handlePublish">发布第一条信息</el-button>
    </el-empty>

    <!-- 分页 -->
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getXunwuList } from '@/api/xunwu'
import { Search, Plus, Location, Clock, Iphone } from '@element-plus/icons-vue'

const router = useRouter()
const isAdmin = ref(false)

const searchForm = reactive({
  name: '',
  type: ''
})

const xunwuList = ref([])
const currentPage = ref(1)
const pageSize = ref(9)
const total = ref(0)

onMounted(async () => {
  const role = localStorage.getItem('role')
  isAdmin.value = role === '管理员'
  await fetchList()
})

const fetchList = async () => {
  try {
    const res = await getXunwuList({
      page: currentPage.value,
      limit: pageSize.value,
      xunwuName: searchForm.name || '',
      xunwuType: searchForm.type || ''
    })
    
    if (res && res.data) {
      xunwuList.value = res.data.list || res.data || []
      total.value = res.data.total || xunwuList.value.length
    }
  } catch (error) {
    console.error('获取失物列表失败:', error)
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchList()
}

const handleSizeChange = () => fetchList()
const handleCurrentChange = () => fetchList()
const handleDetail = (id) => router.push(`/xunwu/${id}`)
const handlePublish = () => router.push('/admin/xunwu')

const getTypeEmoji = (type) => {
  const map = {
    '手机数码': '📱',
    '箱包证件': '💼',
    '衣物饰品': '👕',
    '书籍文具': '📚',
    '钥匙卡片': '🔑',
    '其他': '🎒'
  }
  return map[type] || '🎒'
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
    
    .search-input { flex: 1; }
    .type-select { width: 160px; }
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
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  overflow: hidden;
  background: #fff;
  
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
    
    .image-placeholder { font-size: 72px; }
    
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
    
    .card-meta {
      display: flex;
      flex-direction: column;
      gap: 8px;
      margin-bottom: 12px;
      
      .meta-item {
        display: flex;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: #666;
        
        .el-icon { color: $primary; }
      }
    }
    
    .card-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 12px;
      border-top: 1px dashed $bg-light;
      
      .contact-info {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 13px;
        color: #999;
      }
    }
  }
}

.pagination-box {
  display: flex;
  justify-content: center;
  padding: 24px 0;
}

@media (max-width: 992px) {
  .xunwu-grid { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 576px) {
  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }
  .xunwu-grid { grid-template-columns: 1fr; }
  .search-box {
    flex-direction: column;
    .type-select { width: 100%; }
  }
}
</style>