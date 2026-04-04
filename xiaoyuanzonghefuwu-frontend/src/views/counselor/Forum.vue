<template>
  <div class="counselor-forum">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">帖子管理</span>
          <el-button type="primary" @click="handleCreate">
            <el-icon><Plus /></el-icon>
            发布帖子
          </el-button>
        </div>
      </template>

      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="forumName" label="帖子标题" min-width="200" />
        <el-table-column prop="forumContent" label="帖子内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="forumTypes" label="类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.forumTypes === 1 ? 'success' : 'info'">
              {{ row.forumTypes === 1 ? '帖子' : '回复' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="insertTime" label="发布时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" text size="small" @click="handleView(row)">查看</el-button>
            <el-button type="danger" text size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination
          :current-page="page"
          :page-size="limit"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          @update:current-page="page = $event"
          @update:page-size="limit = $event"
        />
      </div>
    </el-card>

    <!-- 发布/查看帖子对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px">
      <el-form :model="postForm" label-width="80px" v-if="dialogMode === 'create'">
        <el-form-item label="帖子标题">
          <el-input v-model="postForm.forumName" placeholder="请输入帖子标题" />
        </el-form-item>
        <el-form-item label="帖子类型">
          <el-select v-model="postForm.forumTypes" placeholder="请选择类型">
            <el-option label="帖子" :value="1" />
            <el-option label="回复" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item label="帖子内容">
          <el-input v-model="postForm.forumContent" type="textarea" :rows="6" placeholder="请输入帖子内容" />
        </el-form-item>
      </el-form>
      <div v-else class="post-detail">
        <h3>{{ currentRow.forumName }}</h3>
        <div class="meta">
          <span>发布时间：{{ currentRow.insertTime }}</span>
          <span>类型：{{ currentRow.forumTypes === 1 ? '帖子' : '回复' }}</span>
        </div>
        <div class="content">{{ currentRow.forumContent }}</div>
      </div>
      <template #footer v-if="dialogMode === 'create'">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">发布</el-button>
      </template>
      <template #footer v-else>
        <el-button @click="dialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { Plus } from '@element-plus/icons-vue'
import { getForumList, deleteForum, saveForum } from '@/api/forum'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const limit = ref(10)

const dialogVisible = ref(false)
const dialogMode = ref('create')
const currentRow = ref({})
const postForm = reactive({
  forumName: '',
  forumContent: '',
  forumTypes: 1
})

const dialogTitle = computed(() => {
  return dialogMode.value === 'create' ? '发布帖子' : '查看帖子'
})

const loadData = async () => {
  loading.value = true
  try {
    const res = await getForumList({
      page: page.value,
      limit: limit.value,
      orderBy: 'insert_time',
      order: 'desc'
    })
    tableData.value = res.data.list || []
    total.value = res.data.total || 0
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

const handleCreate = () => {
  dialogMode.value = 'create'
  postForm.forumName = ''
  postForm.forumContent = ''
  postForm.forumTypes = 1
  dialogVisible.value = true
}

const handleView = (row) => {
  dialogMode.value = 'view'
  currentRow.value = row
  dialogVisible.value = true
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm('确定要删除该帖子吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await deleteForum({ id: row.id })
    ElMessage.success('删除成功')
    loadData()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!postForm.forumName) {
    ElMessage.warning('请输入帖子标题')
    return
  }
  if (!postForm.forumContent) {
    ElMessage.warning('请输入帖子内容')
    return
  }
  try {
    await saveForum(postForm)
    ElMessage.success('发布成功')
    dialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error('发布失败')
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.counselor-forum {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .title {
      font-size: 16px;
      font-weight: 600;
      color: #1e293b;
    }
  }

  .pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
  }

  .post-detail {
    h3 {
      font-size: 18px;
      font-weight: 600;
      color: #1e293b;
      margin-bottom: 16px;
    }

    .meta {
      display: flex;
      gap: 20px;
      font-size: 13px;
      color: #64748b;
      margin-bottom: 20px;
    }

    .content {
      padding: 16px;
      background-color: #f1f5f9;
      border-radius: 8px;
      color: #334155;
      line-height: 1.6;
      white-space: pre-wrap;
    }
  }
}
</style>