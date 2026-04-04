<template>
  <div class="huodong-list-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <div class="header-text">
          <h1>🎪 校园活动</h1>
          <p>下课逛逛，发现精彩</p>
        </div>
        <el-button type="primary" class="publish-btn" v-if="isAdmin" @click="handlePublish">
          <el-icon><Plus /></el-icon>发布活动
        </el-button>
      </div>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <div class="search-box">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索活动..."
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

    <!-- 活动列表 -->
    <div class="activity-grid">
      <el-card
        v-for="item in activityList"
        :key="item.id"
        class="activity-card"
        shadow="hover"
        @click="handleDetail(item.id)"
      >
        <div class="card-image">
          <div class="image-placeholder">🎪</div>
          <div class="card-status" v-if="item.status">{{ item.status }}</div>
        </div>
        <div class="card-content">
          <h3 class="card-title">{{ item.huodongName }}</h3>
          <p class="card-desc">{{ item.huodongContent || '暂无描述' }}</p>
          <div class="card-meta">
            <div class="meta-item">
              <el-icon><Clock /></el-icon>
              <span>{{ formatTime(item.kaishiTime) }}</span>
            </div>
            <div class="meta-item">
              <el-icon><Location /></el-icon>
              <span>{{ item.huodongLocation || '未定' }}</span>
            </div>
          </div>
          <div class="card-footer">
            <el-tag size="small" type="success">报名中</el-tag>
            <span class="view-count">
              <el-icon><View /></el-icon>
              {{ item.clicknum || 0 }}
            </span>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 空状态 -->
    <el-empty v-if="activityList.length === 0" description="还没有活动哦">
      <el-button type="primary" v-if="isAdmin" @click="handlePublish">发布第一个活动</el-button>
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
import { getHuodongList } from '@/api/huodong'
import { Search, Plus, Clock, Location, View } from '@element-plus/icons-vue'

const router = useRouter()
const isAdmin = ref(false)

const searchForm = reactive({
  name: ''
})

const activityList = ref([])
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
    const res = await getHuodongList({
      page: currentPage.value,
      limit: pageSize.value,
      huodongName: searchForm.name || ''
    })
    
    if (res && res.data) {
      activityList.value = res.data.list || res.data || []
      total.value = res.data.total || activityList.value.length
    }
  } catch (error) {
    console.error('获取活动列表失败:', error)
  }
}

const handleSearch = () => {
  currentPage.value = 1
  fetchList()
}

const handleSizeChange = () => {
  fetchList()
}

const handleCurrentChange = () => {
  fetchList()
}

const handleDetail = (id) => {
  router.push(`/huodong/${id}`)
}

const handlePublish = () => {
  router.push('/admin/huodong')
}

const formatTime = (time) => {
  if (!time) return '时间待定'
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

.huodong-list-page {
  max-width: 1200px;
  margin: 0 auto;
}

// 页面头部
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

// 搜索卡片
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

// 活动网格
.activity-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
  margin-bottom: 24px;
}

// 活动卡片
.activity-card {
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
    
    .image-placeholder {
      font-size: 72px;
    }
    
    .card-status {
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
        
        .el-icon {
          color: $primary;
        }
      }
    }
    
    .card-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 12px;
      border-top: 1px dashed $bg-light;
      
      .view-count {
        display: flex;
        align-items: center;
        gap: 4px;
        font-size: 13px;
        color: #999;
      }
    }
  }
}

// 分页
.pagination-box {
  display: flex;
  justify-content: center;
  padding: 24px 0;
}

// 响应式
@media (max-width: 992px) {
  .activity-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 576px) {
  .header-content {
    flex-direction: column;
    text-align: center;
    gap: 16px;
  }
  
  .activity-grid {
    grid-template-columns: 1fr;
  }
  
  .search-box {
    flex-direction: column;
  }
}
</style>