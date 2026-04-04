<template>
  <div class="admin-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">🔍</span>
          失物招领管理
        </h1>
        <p>管理校园失物招领信息</p>
      </div>
      <el-button type="primary" class="add-btn" @click="handleAdd">
        <span class="btn-emoji">➕</span>
        新增信息
      </el-button>
    </div>

    <!-- 搜索栏 -->
    <div class="search-section">
      <div class="search-card">
        <el-input
          v-model="searchForm.xunwuName"
          placeholder="搜索物品名称..."
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
        <el-table :data="xunwuList" v-loading="loading" style="width: 100%">
          <el-table-column prop="xunwuName" label="物品名称" min-width="160">
            <template #default="{ row }">
              <div class="name-cell">
                <span class="name-emoji">{{ isXunwu(row) ? '🔎' : '🎁' }}</span>
                <span>{{ row.xunwuName }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column label="类型" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="isXunwu(row) ? 'primary' : 'success'" effect="plain">
                {{ row.xunwuValue || (isXunwu(row) ? '寻物' : '招领') }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="时间" width="180" align="center">
            <template #default="{ row }">
              <span>{{ formatDateTime(row.diushiTime) }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="diushiAddress" label="地点" min-width="140" />
          <el-table-column label="操作" width="160" fixed="right" align="center">
            <template #default="{ row }">
              <el-button type="primary" size="small" plain @click="handleEdit(row)">✏️ 编辑</el-button>
              <el-popconfirm
                title="确定要删除该信息吗？"
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

    <!-- 对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '✏️ 编辑信息' : '➕ 新增信息'" width="600px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="物品名称" required>
          <el-input v-model="form.xunwuName" placeholder="请输入物品名称" />
        </el-form-item>
        <el-form-item label="类型" required>
          <el-radio-group v-model="form.xunwuTypes">
            <el-radio :label="1">🔎 寻物</el-radio>
            <el-radio :label="2">🎁 招领</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="时间" required>
          <el-input v-model="form.diushiTime" placeholder="请输入时间（yyyy-MM-dd HH:mm:ss）" />
        </el-form-item>
        <el-form-item label="地点" required>
          <el-input v-model="form.diushiAddress" placeholder="请输入丢失/拾取地点" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="form.lianxirenName" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="form.lianxirenPhone" placeholder="请输入联系人电话" />
        </el-form-item>
        <el-form-item label="详情">
          <el-input v-model="form.xunwuContent" type="textarea" :rows="4" placeholder="请输入详情" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getXunwuList, saveXunwu, updateXunwu, deleteXunwu } from '@/api/xunwu'

const loading = ref(false)
const submitting = ref(false)
const xunwuList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)

const searchForm = reactive({
  xunwuName: ''
})

const form = reactive({
  id: null,
  xunwuName: '',
  xunwuTypes: 1,
  diushiTime: '',
  diushiAddress: '',
  lianxirenName: '',
  lianxirenPhone: '',
  xunwuContent: ''
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
    if (searchForm.xunwuName) params.xunwuName = searchForm.xunwuName

    const res = await getXunwuList(params)
    if (res && res.data) {
      xunwuList.value = res.data.list || res.data || []
      total.value = res.data.total || xunwuList.value.length
    }
  } catch (error) {
    console.error('获取列表失败:', error)
  } finally {
    loading.value = false
  }
}

const resetSearch = () => {
  searchForm.xunwuName = ''
  currentPage.value = 1
  handleSearch()
}

const handlePageChange = (page) => {
  currentPage.value = page
  handleSearch()
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(form, {
    id: null,
    xunwuName: '',
    xunwuTypes: 1,
    diushiTime: '',
    diushiAddress: '',
    lianxirenName: '',
    lianxirenPhone: '',
    xunwuContent: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, row)
  dialogVisible.value = true
}

const handleDelete = async (id) => {
  try {
    await deleteXunwu([id])
    ElMessage.success('删除成功')
    handleSearch()
  } catch (error) {
    console.error('删除失败:', error)
  }
}

const handleSubmit = async () => {
  submitting.value = true
  try {
    if (isEdit.value) {
      await updateXunwu(form)
    } else {
      await saveXunwu(form)
    }
    ElMessage.success(isEdit.value ? '修改成功' : '添加成功')
    dialogVisible.value = false
    handleSearch()
  } catch (error) {
    console.error('提交失败:', error)
  } finally {
    submitting.value = false
  }
}

const isXunwu = (row) => Number(row?.xunwuTypes) === 1

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  const date = new Date(dateTime)
  if (Number.isNaN(date.getTime())) return String(dateTime)
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hour = String(date.getHours()).padStart(2, '0')
  const minute = String(date.getMinutes()).padStart(2, '0')
  return `${month}-${day} ${hour}:${minute}`
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

.admin-page {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

// 页面头部
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 24px 32px;
  background: linear-gradient(135deg, $secondary 0%, $secondary-dark 100%);
  border-radius: 24px;
  border: 3px solid $primary;
  box-shadow: 8px 8px 0 rgba($secondary, 0.3);
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

  .add-btn {
    border-radius: 12px;
    font-weight: 600;
    background: #fff;
    border: 2px solid $secondary-dark;
    color: $secondary-dark;
    box-shadow: 3px 3px 0 rgba(0, 0, 0, 0.15);
    transition: all 0.2s ease;

    .btn-emoji {
      margin-right: 4px;
    }

    &:hover {
      transform: translate(-2px, -2px);
      box-shadow: 5px 5px 0 rgba(0, 0, 0, 0.15);
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
    flex-direction: column;
    gap: 16px;

    .header-content {
      text-align: center;

      h1 {
        font-size: 20px;
        justify-content: center;
      }
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
