<template>
  <div class="admin-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">⚙️</span>
          系统配置
        </h1>
        <p>管理系统配置参数</p>
      </div>
      <el-button type="primary" class="add-btn" @click="handleAdd">
        <span class="btn-emoji">➕</span>
        添加配置
      </el-button>
    </div>

    <!-- 数据表格 -->
    <div class="table-section">
      <el-card class="table-card" shadow="never">
        <el-table :data="configList" v-loading="loading" style="width: 100%">
          <el-table-column prop="name" label="配置名称" width="200">
            <template #default="{ row }">
              <div class="name-cell">
                <span class="name-emoji">🔧</span>
                <span>{{ row.name }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="value" label="配置值" min-width="300" show-overflow-tooltip />
          <el-table-column label="操作" width="160" fixed="right" align="center">
            <template #default="{ row }">
              <el-button type="primary" size="small" plain @click="handleEdit(row)">✏️ 编辑</el-button>
              <el-popconfirm
                title="确定要删除该配置吗？"
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

    <!-- 添加/编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '✏️ 编辑配置' : '➕ 添加配置'" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="配置名称" prop="name">
          <el-input v-model="form.name" :disabled="isEdit" placeholder="如：siteName" />
        </el-form-item>
        <el-form-item label="配置值" prop="value">
          <el-input v-model="form.value" type="textarea" :rows="4" placeholder="配置值" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getConfigList, saveConfig, updateConfig, deleteConfig } from '@/api/dictionary'

const loading = ref(false)
const submitting = ref(false)
const configList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)

const form = reactive({
  id: null,
  name: '',
  value: ''
})

const rules = {
  name: [{ required: true, message: '请输入配置名称', trigger: 'blur' }],
  value: [{ required: true, message: '请输入配置值', trigger: 'blur' }]
}

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

    const res = await getConfigList(params)
    if (res && res.data) {
      configList.value = res.data.list || res.data || []
      total.value = res.data.total || configList.value.length
    }
  } catch (error) {
    console.error('获取配置列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handlePageChange = (page) => {
  currentPage.value = page
  handleSearch()
}

const handleAdd = () => {
  isEdit.value = false
  Object.assign(form, {
    id: null,
    name: '',
    value: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, {
    id: row.id,
    name: row.name,
    value: row.value
  })
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    submitting.value = true
    try {
      if (isEdit.value) {
        await updateConfig(form)
        ElMessage.success('修改成功')
      } else {
        await saveConfig(form)
        ElMessage.success('添加成功')
      }
      dialogVisible.value = false
      handleSearch()
    } catch (error) {
      console.error('操作失败:', error)
    } finally {
      submitting.value = false
    }
  })
}

const handleDelete = async (id) => {
  try {
    await deleteConfig([id])
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
$accent-blue: #89C2D9;

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
  background: linear-gradient(135deg, #6B7280 0%, #4B5563 100%);
  border-radius: 24px;
  border: 3px solid $secondary;
  box-shadow: 8px 8px 0 rgba(#6B7280, 0.3);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    width: 150px;
    height: 150px;
    background: rgba(#fff, 0.1);
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
    background: $secondary;
    border: 2px solid $secondary-dark;
    color: $text-primary;
    box-shadow: 3px 3px 0 rgba($secondary-dark, 0.3);
    transition: all 0.2s ease;

    .btn-emoji {
      margin-right: 4px;
    }

    &:hover {
      transform: translate(-2px, -2px);
      box-shadow: 5px 5px 0 rgba($secondary-dark, 0.3);
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
          background: rgba(#6B7280, 0.05);
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
}
</style>