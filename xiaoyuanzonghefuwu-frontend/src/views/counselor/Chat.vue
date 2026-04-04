<template>
  <div class="counselor-chat">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">咨询管理</span>
          <el-input
            v-model="searchForm.chatIssue"
            placeholder="搜索咨询内容"
            style="width: 200px"
            clearable
            @clear="handleSearch"
          >
            <template #append>
              <el-button @click="handleSearch">
                <el-icon><Search /></el-icon>
              </el-button>
            </template>
          </el-input>
        </div>
      </template>

      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="yonghuName" label="用户" width="120" />
        <el-table-column prop="chatIssue" label="咨询内容" min-width="250" show-overflow-tooltip />
        <el-table-column prop="zhuangtaiTypes" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.zhuangtaiTypes)">
              {{ getStatusText(row.zhuangtaiTypes) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="insertTime" label="咨询时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" text size="small" @click="handleReply(row)">
              {{ row.zhuangtaiTypes === 0 ? '回复' : '查看' }}
            </el-button>
            <el-button type="success" text size="small" @click="handleMarkAsDone(row)" v-if="row.zhuangtaiTypes !== 2">
              标记完成
            </el-button>
            <el-button type="danger" text size="small" @click="handleDelete(row)">
              删除
            </el-button>
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

    <!-- 回复对话框 -->
    <el-dialog v-model="dialogVisible" title="回复咨询" width="600px">
      <el-form :model="replyForm" label-width="80px">
        <el-form-item label="用户">
          <span>{{ currentRow.yonghuName }}</span>
        </el-form-item>
        <el-form-item label="咨询内容">
          <div class="chat-content">{{ currentRow.chatIssue }}</div>
        </el-form-item>
        <el-form-item label="回复内容">
          <el-input
            v-model="replyForm.chatReply"
            type="textarea"
            :rows="4"
            placeholder="请输入回复内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReply">提交回复</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { getChatList, updateChat, deleteChat } from '@/api/chat'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const limit = ref(10)

const searchForm = reactive({
  chatIssue: ''
})

const dialogVisible = ref(false)
const currentRow = ref({})
const replyForm = reactive({
  chatReply: ''
})

const getStatusType = (status) => {
  const types = {
    0: 'warning',
    1: 'success',
    2: 'info'
  }
  return types[status] || 'info'
}

const getStatusText = (status) => {
  const texts = {
    0: '待回复',
    1: '已回复',
    2: '已处理'
  }
  return texts[status] || '未知'
}

const loadData = async () => {
  loading.value = true
  try {
    const params = {
      page: page.value,
      limit: limit.value,
      orderBy: 'insert_time',
      order: 'desc'
    }
    if (searchForm.chatIssue) {
      params.chatIssue = searchForm.chatIssue
    }
    const res = await getChatList(params)
    tableData.value = res.data.list || []
    total.value = res.data.total || 0
  } catch (error) {
    ElMessage.error('加载数据失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  page.value = 1
  loadData()
}

const handleSizeChange = () => {
  loadData()
}

const handleCurrentChange = () => {
  loadData()
}

const handleReply = (row) => {
  currentRow.value = row
  replyForm.chatReply = row.chatReply || ''
  dialogVisible.value = true
}

const submitReply = async () => {
  if (!replyForm.chatReply) {
    ElMessage.warning('请输入回复内容')
    return
  }
  try {
    await updateChat({
      id: currentRow.value.id,
      chatReply: replyForm.chatReply,
      zhuangtaiTypes: 1,
      replyTime: new Date().toISOString().slice(0, 19).replace('T', ' ')
    })
    ElMessage.success('回复成功')
    dialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error('回复失败')
  }
}

const handleMarkAsDone = async (row) => {
  try {
    await updateChat({
      id: row.id,
      zhuangtaiTypes: 2
    })
    ElMessage.success('已标记为完成')
    loadData()
  } catch (error) {
    ElMessage.error('操作失败')
  }
}

const handleDelete = (row) => {
  ElMessageBox.confirm('确定要删除该咨询记录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteChat([row.id])
      ElMessage.success('删除成功')
      loadData()
    } catch (error) {
      ElMessage.error('删除失败')
    }
  }).catch(() => {})
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.counselor-chat {
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

  .chat-content {
    padding: 12px;
    background-color: #f1f5f9;
    border-radius: 8px;
    color: #334155;
  }
}
</style>