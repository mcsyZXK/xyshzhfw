<template>
  <div class="admin-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">💚</span>
          心理咨询师管理
        </h1>
        <p>管理心理咨询师信息</p>
      </div>
      <el-button type="primary" class="add-btn" @click="handleAdd">
        <span class="btn-emoji">➕</span>
        添加咨询师
      </el-button>
    </div>

    <!-- 搜索栏 -->
    <div class="search-section">
      <div class="search-card">
        <el-input
          v-model="searchForm.name"
          placeholder="搜索咨询师姓名..."
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
        <el-table :data="counselorList" v-loading="loading" style="width: 100%">
          <el-table-column prop="username" label="账号" min-width="120">
            <template #default="{ row }">
              <div class="name-cell">
                <span class="name-emoji">👤</span>
                <span>{{ row.username }}</span>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="xinlizixunshiName" label="姓名" min-width="100" />
          <el-table-column label="性别" width="80" align="center">
            <template #default="{ row }">
              <el-tag :type="row.sexTypes === 1 ? '' : 'danger'" size="small" effect="plain">
                {{ row.sexTypes === 1 ? '👦 男' : (row.sexTypes === 2 ? '👧 女' : '❓') }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="xinlizixunshiPhone" label="手机号" width="130" />
          <el-table-column prop="xinlizixunshiEmail" label="邮箱" min-width="180" />
          <el-table-column prop="xinlizixunshiZhiye" label="职业资格" width="120" />
          <el-table-column label="操作" width="160" fixed="right" align="center">
            <template #default="{ row }">
              <el-button type="primary" size="small" plain @click="handleEdit(row)">✏️ 编辑</el-button>
              <el-popconfirm
                title="确定要删除该咨询师吗？"
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
    <el-dialog v-model="dialogVisible" :title="isEdit ? '✏️ 编辑咨询师' : '➕ 添加咨询师'" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="账号" prop="username">
          <el-input v-model="form.username" :disabled="isEdit" placeholder="请输入账号" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!isEdit">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="姓名" prop="xinlizixunshiName">
          <el-input v-model="form.xinlizixunshiName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="手机号" prop="xinlizixunshiPhone">
          <el-input v-model="form.xinlizixunshiPhone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="xinlizixunshiEmail">
          <el-input v-model="form.xinlizixunshiEmail" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="职业资格" prop="xinlizixunshiZhiye">
          <el-input v-model="form.xinlizixunshiZhiye" placeholder="请输入职业资格" />
        </el-form-item>
        <el-form-item label="性别" prop="sexTypes">
          <el-select v-model="form.sexTypes" placeholder="请选择性别">
            <el-option label="👦 男" :value="1" />
            <el-option label="👧 女" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="咨询师介绍" prop="xinlizixunshiContent">
          <el-input v-model="form.xinlizixunshiContent" type="textarea" :rows="4" placeholder="请输入咨询师介绍" />
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
import { getCounselorList, saveCounselor, updateCounselor, deleteCounselor } from '@/api/xinlizixunshi'

const loading = ref(false)
const submitting = ref(false)
const counselorList = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const dialogVisible = ref(false)
const isEdit = ref(false)
const formRef = ref(null)

const searchForm = reactive({
  name: ''
})

const form = reactive({
  id: null,
  username: '',
  password: '',
  xinlizixunshiName: '',
  xinlizixunshiPhone: '',
  xinlizixunshiEmail: '',
  xinlizixunshiZhiye: '',
  sexTypes: 1,
  xinlizixunshiContent: ''
})

const rules = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  xinlizixunshiName: [{ required: true, message: '请输入姓名', trigger: 'blur' }]
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
    if (searchForm.name) params.xinlizixunshiName = searchForm.name

    const res = await getCounselorList(params)
    if (res && res.data) {
      counselorList.value = res.data.list || res.data || []
      total.value = res.data.total || counselorList.value.length
    }
  } catch (error) {
    console.error('获取咨询师列表失败:', error)
  } finally {
    loading.value = false
  }
}

const resetSearch = () => {
  searchForm.name = ''
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
    username: '',
    password: '',
    xinlizixunshiName: '',
    xinlizixunshiPhone: '',
    xinlizixunshiEmail: '',
    xinlizixunshiZhiye: '',
    sexTypes: 1,
    xinlizixunshiContent: ''
  })
  dialogVisible.value = true
}

const handleEdit = (row) => {
  isEdit.value = true
  Object.assign(form, {
    id: row.id,
    username: row.username,
    xinlizixunshiName: row.xinlizixunshiName,
    xinlizixunshiPhone: row.xinlizixunshiPhone,
    xinlizixunshiEmail: row.xinlizixunshiEmail,
    xinlizixunshiZhiye: row.xinlizixunshiZhiye,
    sexTypes: row.sexTypes,
    xinlizixunshiContent: row.xinlizixunshiContent
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
        await updateCounselor(form)
        ElMessage.success('修改成功')
      } else {
        await saveCounselor(form)
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
    await deleteCounselor([id])
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
$accent-pink: #FFAFCC;

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
  background: linear-gradient(135deg, $accent-pink 0%, #FF8FAB 100%);
  border-radius: 24px;
  border: 3px solid $secondary;
  box-shadow: 8px 8px 0 rgba($accent-pink, 0.3);
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
    border: 2px solid $accent-pink;
    color: #E05780;
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
          background: rgba($accent-pink, 0.05);
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