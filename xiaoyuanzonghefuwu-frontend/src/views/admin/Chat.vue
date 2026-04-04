<template>
  <div class="admin-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">💬</span>
          咨询记录管理
        </h1>
        <p>管理在线咨询聊天记录</p>
      </div>
    </div>

    <!-- 搜索栏 -->
    <div class="search-section">
      <div class="search-card">
        <el-select v-model="searchForm.chatTypes" placeholder="选择消息类型" clearable class="search-select">
          <el-option label="👤 用户发送" :value="1" />
          <el-option label="🤖 管理员发送" :value="2" />
        </el-select>
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
        <el-table :data="chatList" v-loading="loading" style="width: 100%">
          <el-table-column prop="yonghuName" label="用户姓名" width="120" align="center">
            <template #default="{ row }">
              <div class="user-cell">
                <span>👤</span>
                <span>{{ row.yonghuName }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="发送者" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="row.chatTypes === 1 ? 'success' : 'primary'" effect="plain">
                {{ row.chatTypes === 1 ? '👤 用户' : '🤖 管理员' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="聊天内容" min-width="300" show-overflow-tooltip>
            <template #default="{ row }">
              <div class="chat-content">
                <span v-if="row.chatTypes === 1" class="user-msg">💬 {{ row.chatIssue || '-' }}</span>
                <span v-else class="admin-msg">🤖 {{ row.chatReply || '-' }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="insertTime" label="聊天时间" width="180" align="center">
            <template #default="{ row }">
              <span class="time-text">🕐 {{ row.insertTime }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="100" fixed="right" align="center">
            <template #default="{ row }">
              <el-popconfirm
                title="确定要删除该记录吗？"
                confirm-button-text="删除"
                cancel-button-text="取消"
                @confirm="handleDelete(row.id)"
              >
                <template #reference>
                  <el-button type="danger" size="small" plain>🗑️ 删除</el-button>
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
import { getChatList, deleteChat } from '@/api/chat'

const loading = ref(false)
const chatList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const searchForm = reactive({
  chatTypes: null
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
    if (searchForm.chatTypes) params.chatTypes = searchForm.chatTypes

    const res = await getChatList(params)
    if (res && res.data) {
      chatList.value = res.data.list || res.data || []
      total.value = res.data.total || chatList.value.length
    }
  } catch (error) {
    console.error('获取聊天记录失败:', error)
  } finally {
    loading.value = false
  }
}

const resetSearch = () => {
  searchForm.chatTypes = null
  currentPage.value = 1
  handleSearch()
}

const handlePageChange = (page) => {
  currentPage.value = page
  handleSearch()
}

const handleDelete = async (id) => {
  try {
    await deleteChat([id])
    ElMessage.success('删除成功')
    handleSearch()
  } catch (error) {
    console.error('删除失败:', error)
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
$accent-mint: #74C69D;

.admin-page {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

// 页面头部
.page-header {
  margin-bottom: 24px;
  padding: 24px 32px;
  background: linear-gradient(135deg, $accent-mint 0%, #52B788 100%);
  border-radius: 24px;
  border: 3px solid $secondary;
  box-shadow: 8px 8px 0 rgba($accent-mint, 0.3);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    width: 150px;
    height: 150px;
    background: rgba(#fff, 0.2);
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

  .search-select {
    width: 200px;

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
          background: rgba($accent-mint, 0.05);
        }
      }
    }
  }

  .user-cell {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
  }

  .chat-content {
    .user-msg {
      color: $text-primary;
    }

    .admin-msg {
      color: #666;
    }
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

    .search-select {
      width: 100%;
    }
  }
}
</style>