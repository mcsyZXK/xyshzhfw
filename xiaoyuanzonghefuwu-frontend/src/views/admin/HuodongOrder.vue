<template>
  <div class="admin-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">📋</span>
          报名管理
        </h1>
        <p>管理活动报名记录</p>
      </div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-section">
      <div class="search-card">
        <el-input
          v-model="searchForm.huodongName"
          placeholder="搜索活动名称..."
          clearable
          class="search-input"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <span class="search-emoji">🔍</span>
          </template>
        </el-input>
        <el-button type="primary" class="search-btn" @click="handleSearch">
          <span class="btn-emoji">🔎</span>
          搜索
        </el-button>
        <el-button class="reset-btn" @click="resetSearch">
          <span class="btn-emoji">🔄</span>
          重置
        </el-button>
      </div>
    </div>

    <!-- 数据表格 -->
    <div class="table-section">
      <el-card class="table-card" shadow="never">
        <el-table :data="orderList" v-loading="loading" style="width: 100%">
          <el-table-column prop="huodongName" label="活动名称" min-width="180">
            <template #default="{ row }">
              <div class="name-cell">
                <span class="name-emoji">🎉</span>
                <span>{{ row.huodongName }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="yonghuName" label="报名用户" width="120" align="center">
            <template #default="{ row }">
              <div class="user-cell">
                <span>👤</span>
                <span>{{ row.yonghuName }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="yonghuPhone" label="联系电话" width="150" align="center" />
          <el-table-column label="报名时间" width="180" align="center">
            <template #default="{ row }">
              <span class="time-text">🕐 {{ row.insertTime }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="120" fixed="right" align="center">
            <template #default="{ row }">
              <el-popconfirm
                title="确定要取消该报名吗？"
                confirm-button-text="确定"
                cancel-button-text="取消"
                @confirm="handleDelete(row.id)"
              >
                <template #reference>
                  <el-button type="danger" size="small" plain>❌ 取消</el-button>
                </template>
              </el-popconfirm>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination-container">
          <el-pagination
            :current-page="currentPage"
            :page-size="pageSize"
            :total="total"
            layout="total, prev, pager, next, jumper"
            @current-change="handlePageChange"
          />
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getHuodongOrderList, deleteHuodongOrder } from '@/api/huodongOrder'

const loading = ref(false)
const orderList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const searchForm = reactive({
  huodongName: ''
})

onMounted(() => {
  handleSearch()
})

const handleSearch = async () => {
  loading.value = true
  try {
    const params = {
      page: currentPage.value,
      limit: pageSize.value
    }
    if (searchForm.huodongName) params.huodongName = searchForm.huodongName

    const res = await getHuodongOrderList(params)
    if (res && res.data) {
      orderList.value = res.data.list || res.data || []
      total.value = res.data.total || orderList.value.length
    }
  } catch (error) {
    console.error('获取报名列表失败:', error)
  } finally {
    loading.value = false
  }
}

const resetSearch = () => {
  searchForm.huodongName = ''
  currentPage.value = 1
  handleSearch()
}

const handlePageChange = (page) => {
  currentPage.value = page
  handleSearch()
}

const handleDelete = async (id) => {
  try {
    await deleteHuodongOrder([id])
    ElMessage.success('取消成功')
    handleSearch()
  } catch (error) {
    console.error('取消失败:', error)
  }
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$primary-light: #40916C;
$secondary: #FFB703;
$secondary-dark: #FB8500;
$bg-warm: #FEFAE0;
$bg-light: #E9EDC9;
$text-primary: #2D3436;
$accent-orange: #FB8500;

.admin-page {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

// 页面头部
.page-header {
  margin-bottom: 24px;
  padding: 24px 32px;
  background: linear-gradient(135deg, $accent-orange 0%, #E85D04 100%);
  border-radius: 24px;
  border: 3px solid $secondary;
  box-shadow: 8px 8px 0 rgba($accent-orange, 0.3);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    width: 150px;
    height: 150px;
    background: rgba(#fff, 0.15);
    border-radius: 50%;
    top: -30px;
    right: -30px;
  }

  .header-content {
    z-index: 1;

    h1 {
      font-size: 24px;
      font-weight: 800;
      color: #fff;
      margin: 0 0 8px 0;
      display: flex;
      align-items: center;
      gap: 8px;

      .emoji {
        font-size: 28px;
      }
    }

    p {
      font-size: 14px;
      color: rgba(#fff, 0.9);
      margin: 0;
    }
  }
}

// 搜索区域
.search-section {
  margin-bottom: 24px;
}

.search-card {
  display: flex;
  gap: 12px;
  padding: 20px 24px;
  background: #fff;
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  flex-wrap: wrap;

  .search-input {
    flex: 1;
    min-width: 200px;
    max-width: 320px;

    :deep(.el-input__wrapper) {
      border-radius: 10px;
      border: 2px solid $primary;
      box-shadow: none;
      background: $bg-warm;

      &:focus-within {
        border-color: $secondary;
        box-shadow: 0 0 0 3px rgba($secondary, 0.2);
      }
    }

    .search-emoji {
      font-size: 16px;
      margin-right: 4px;
    }
  }

  .search-btn, .reset-btn {
    border-radius: 10px;
    font-weight: 600;
    border: 2px solid transparent;
    transition: all 0.2s ease;

    .btn-emoji {
      margin-right: 4px;
    }
  }

  .search-btn {
    background: $primary;
    border-color: $primary-dark;
    box-shadow: 3px 3px 0 rgba($primary-dark, 0.3);

    &:hover {
      transform: translate(-2px, -2px);
      box-shadow: 5px 5px 0 rgba($primary-dark, 0.3);
    }
  }

  .reset-btn {
    background: #fff;
    border-color: $primary;
    color: $primary;

    &:hover {
      background: $bg-light;
    }
  }
}

// 表格区域
.table-section {
  .table-card {
    border-radius: 20px;
    border: 2px solid $primary;
    box-shadow: 4px 4px 0 rgba($primary, 0.15);

    :deep(.el-card__body) {
      padding: 0;
    }

    :deep(.el-table) {
      border-radius: 16px;

      th.el-table__cell {
        background: $bg-light;
        color: $text-primary;
        font-weight: 700;
        border-bottom: 2px solid $primary;
      }

      td.el-table__cell {
        border-bottom: 1px dashed $bg-light;
      }

      .el-table__row {
        transition: all 0.2s ease;

        &:hover {
          background: rgba($secondary, 0.05);
        }
      }
    }
  }

  .name-cell {
    display: flex;
    align-items: center;
    gap: 8px;

    .name-emoji {
      font-size: 16px;
    }
  }

  .user-cell {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
  }

  .time-text {
    color: #666;
    font-size: 13px;
  }
}

// 分页
.pagination-container {
  display: flex;
  justify-content: center;
  padding: 20px;
  border-top: 1px dashed $bg-light;

  :deep(.el-pagination) {
    .btn-prev, .btn-next, .el-pager li {
      border-radius: 8px;
      border: 2px solid $primary;
      background: #fff;
      color: $text-primary;
      font-weight: 600;
      margin: 0 4px;

      &:hover {
        background: $bg-light;
      }

      &.is-active {
        background: $primary;
        color: #fff;
        border-color: $primary-dark;
      }
    }
  }
}

// 响应式
@media (max-width: 768px) {
  .page-header {
    padding: 20px;

    .header-content h1 {
      font-size: 20px;
    }
  }

  .search-card {
    flex-direction: column;

    .search-input {
      max-width: none;
    }
  }
}
</style>