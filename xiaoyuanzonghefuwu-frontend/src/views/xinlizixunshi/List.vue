<template>
  <div class="zixunshi-page">
    <div class="page-header">
      <h1>心理咨询师</h1>
      <p>专业心理咨询师，为你排忧解难</p>
    </div>

    <div class="search-bar">
      <el-input
        v-model="searchForm.xinlizixunshiName"
        placeholder="搜索咨询师姓名"
        clearable
        style="width: 200px"
        @clear="handleSearch"
      />
      <el-button type="primary" @click="handleSearch">
        <el-icon><Search /></el-icon>
        搜索
      </el-button>
    </div>

    <div class="zixunshi-list">
      <div v-loading="loading" class="list-content">
        <el-empty v-if="!loading && zixunshiList.length === 0" description="暂无咨询师" />
        
        <div v-else class="card-grid">
          <el-card
            v-for="item in zixunshiList"
            :key="item.id"
            class="zixunshi-card"
            shadow="hover"
            @click="viewDetail(item.id)"
          >
            <div class="card-avatar">
              <el-icon :size="60"><User /></el-icon>
            </div>
            <div class="card-content">
              <h3 class="card-title">{{ item.xinlizixunshiName }}</h3>
              <div class="card-info">
                <div class="info-item">
                  <el-icon><Phone /></el-icon>
                  <span>{{ item.xinlizixunshiPhone || '未留电话' }}</span>
                </div>
                <div class="info-item">
                  <el-icon><Message /></el-icon>
                  <span>{{ item.xinlizixunshiEmail || '未留邮箱' }}</span>
                </div>
              </div>
              <div class="card-content-text">{{ item.xinlizixunshiContent || '暂无介绍' }}</div>
            </div>
          </el-card>
        </div>
      </div>

      <div class="pagination-container">
        <el-pagination
          :current-page="currentPage"
          :page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { getXinlizixunshiList } from '@/api/xinlizixunshi'

const router = useRouter()
const loading = ref(false)

const searchForm = reactive({
  xinlizixunshiName: ''
})

const zixunshiList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

onMounted(() => {
  handleSearch()
})

const handleSearch = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      limit: pageSize.value,
      orderBy: 'id'
    }
    if (searchForm.xinlizixunshiName) {
      params.xinlizixunshiName = searchForm.xinlizixunshiName
    }
    
    const res = await getXinlizixunshiList(params)
    if (res && res.data) {
      zixunshiList.value = res.data.list || res.data || []
      total.value = res.data.total || zixunshiList.value.length
    }
  } catch (error) {
    console.error('获取咨询师列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  handleSearch()
}

const handlePageChange = (page) => {
  currentPage.value = page
  handleSearch()
}

const viewDetail = (id) => {
  router.push(`/xinlizixunshi/${id}`)
}

const formatTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  return `${date.getMonth() + 1}/${date.getDate()} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}
</script>

<style lang="scss" scoped>
.zixunshi-page {
  .page-header {
    margin-bottom: 20px;
    h1 { font-size: 28px; font-weight: 600; color: #333; margin-bottom: 8px; }
    p { color: #666; font-size: 14px; }
  }

  .search-bar {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }

  .zixunshi-list {
    .list-content { min-height: 400px; }

    .card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 20px;
    }

    .zixunshi-card {
      cursor: pointer;
      transition: all 0.3s ease;
      border-radius: 12px;
      text-align: center;
      padding: 30px 20px;

      &:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
      }

      .card-avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        color: #fff;
      }

      .card-content {
        .card-title {
          font-size: 18px;
          font-weight: 600;
          color: #333;
          margin-bottom: 15px;
        }

        .card-info {
          margin-bottom: 15px;
          .info-item {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            font-size: 13px;
            color: #666;
            margin-bottom: 8px;
          }
        }

        .card-content-text {
          font-size: 14px;
          color: #666;
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-line-clamp: 3;
          -webkit-box-orient: vertical;
        }
      }
    }

    .pagination-container {
      display: flex;
      justify-content: flex-end;
      margin-top: 20px;
    }
  }
}
</style>