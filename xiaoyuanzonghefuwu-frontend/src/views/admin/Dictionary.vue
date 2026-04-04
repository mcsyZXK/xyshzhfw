<template>
  <div class="admin-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">📚</span>
          字典管理
        </h1>
        <p>管理系统数据字典</p>
      </div>
      <el-button type="primary" class="add-btn" @click="handleAdd">
        <span class="btn-emoji">➕</span>
        添加字典
      </el-button>
    </div>

    <!-- 搜索栏 -->
    <div class="search-section">
      <div class="search-card">
        <el-input
          v-model="searchForm.dicCode"
          placeholder="搜索字典编码..."
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
        <el-table :data="dictionaryList" v-loading="loading" style="width: 100%">
          <el-table-column prop="dicCode" label="字典编码" width="150">
            <template #default="{ row }">
              <el-tag effect="plain">{{ row.dicCode }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="dicName" label="字典名称" width="150" />
          <el-table-column prop="codeIndex" label="编码值" width="100" align="center" />
          <el-table-column prop="indexName" label="编码名称" width="150" />
          <el-table-column prop="superId" label="父级 ID" width="100" align="center" />
          <el-table-column prop="beizhu" label="备注" min-width="150" />
          <el-table-column label="操作" width="160" fixed="right" align="center">
            <template #default="{ row }">
              <el-button type="primary" size="small" plain @click="handleEdit(row)">✏️ 编辑</el-button>
              <el-popconfirm
                title="确定要删除该字典吗？"
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
    <el-dialog v-model="dialogVisible" :title="isEdit ? '✏️ 编辑字典' : '➕ 添加字典'" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="字典编码" prop="dicCode">
          <el-input v-model="form.dicCode" :disabled="isEdit" placeholder="如：sex, huodong" />
        </el-form-item>
        <el-form-item label="字典名称" prop="dicName">
          <el-input v-model="form.dicName" placeholder="如：性别，活动类型" />
        </el-form-item>
        <el-form-item label="编码值" prop="codeIndex">
          <el-input-number v-model="form.codeIndex" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="编码名称" prop="indexName">
          <el-input v-model="form.indexName" placeholder="如：男，学术讲座" />
        </el-form-item>
        <el-form-item label="父级 ID" prop="superId">
          <el-input-number v-model="form.superId" :min="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注" prop="beizhu">
          <el-input v-model="form.beizhu" type="textarea" :rows="3" placeholder="备注信息" />
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
import { getDictionaryList, saveDictionary, updateDictionary, deleteDictionary } from '@/api/dictionary'

const loading = ref(false)
const submitting = ref(false)
const dictionaryList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)

const searchForm = reactive({
  dicCode: ''
})

const form = reactive({
  id: null,
  dicCode: '',
  dicName: '',
  codeIndex: 0,
  indexName: '',
  superId: 0,
  beizhu: ''
})

const rules = {
  dicCode: [{ required: true, message: '请输入字典编码', trigger: 'blur' }],
  dicName: [{ required: true, message: '请输入字典名称', trigger: 'blur' }],
  codeIndex: [{ required: true, message: '请输入编码值', trigger: 'blur' }],
  indexName: [{ required: true, message: '请输入编码名称', trigger: 'blur' }]
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
    if (searchForm.dicCode) params.dicCode = searchForm.dicCode

    const res = await getDictionaryList(params)
    if (res && res.data) {
      dictionaryList.value = res.data.list || res.data || []
      total.value = res.data.total || dictionaryList.value.length
    }
  } catch (error) {
    console.error('获取字典列表失败:', error)
  } finally {
    loading.value = false
  }
}

const resetSearch = () => {
  searchForm.dicCode = ''
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
    dicCode: '',
    dicName: '',
    codeIndex: 0,
    indexName: '',
    superId: 0,
    beizhu: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, {
    id: row.id,
    dicCode: row.dicCode,
    dicName: row.dicName,
    codeIndex: row.codeIndex,
    indexName: row.indexName,
    superId: row.superId,
    beizhu: row.beizhu
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
        await updateDictionary(form)
        ElMessage.success('修改成功')
      } else {
        await saveDictionary(form)
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
    await deleteDictionary([id])
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
  background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
  border-radius: 24px;
  border: 3px solid $secondary;
  box-shadow: 8px 8px 0 rgba($primary, 0.3);
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    width: 150px;
    height: 150px;
    background: rgba($secondary, 0.1);
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
          background: rgba($primary, 0.05);
        }
      }
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