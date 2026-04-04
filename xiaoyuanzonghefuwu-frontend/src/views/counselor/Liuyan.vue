<template>
  <div class="counselor-liuyan">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span class="title">留言管理</span>
          <el-input
            v-model="searchForm.xinlizixunshiLiuyanText"
            placeholder="搜索留言内容"
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
        <el-table-column label="用户" width="120">
          <template #default="{ row }">
            {{ getUserDisplayName(row) }}
          </template>
        </el-table-column>
        <el-table-column prop="xinlizixunshiLiuyanText" label="留言内容" min-width="250" show-overflow-tooltip />
        <el-table-column prop="replyText" label="回复内容" min-width="200" show-overflow-tooltip />
        <el-table-column prop="insertTime" label="留言时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" text size="small" @click="handleReply(row)">
              {{ row.replyText ? '查看回复' : '回复' }}
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
    <el-dialog v-model="dialogVisible" :title="currentRow.replyText ? '查看回复' : '回复留言'" width="600px">
      <el-form :model="replyForm" label-width="80px">
        <el-form-item label="用户">
          <span>{{ getUserDisplayName(currentRow) }}</span>
        </el-form-item>
        <el-form-item label="留言内容">
          <div class="liuyan-content">{{ currentRow.xinlizixunshiLiuyanText }}</div>
        </el-form-item>
        <el-form-item label="回复内容" v-if="!currentRow.replyText">
          <el-input
            v-model="replyForm.replyText"
            type="textarea"
            :rows="4"
            placeholder="请输入回复内容"
          />
        </el-form-item>
        <el-form-item label="回复内容" v-else>
          <div class="liuyan-content">{{ currentRow.replyText }}</div>
        </el-form-item>
      </el-form>
      <template #footer v-if="!currentRow.replyText">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="submitReply">提交回复</el-button>
      </template>
      <template #footer v-else>
        <el-button @click="dialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { Search } from '@element-plus/icons-vue'
import { getXinlizixunshiLiuyanList, updateXinlizixunshiLiuyan } from '@/api/xinlizixunshi'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const page = ref(1)
const limit = ref(10)

const searchForm = reactive({
  xinlizixunshiLiuyanText: ''
})

const dialogVisible = ref(false)
const currentRow = ref({})
const replyForm = reactive({
  replyText: ''
})

const getUserDisplayName = (row = {}) => {
  if (row.yonghuName) return row.yonghuName
  return '-'
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
    if (searchForm.xinlizixunshiLiuyanText) {
      params.xinlizixunshiLiuyanText = searchForm.xinlizixunshiLiuyanText
    }
    const res = await getXinlizixunshiLiuyanList(params)
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
  replyForm.replyText = row.replyText || ''
  dialogVisible.value = true
}

const submitReply = async () => {
  if (!replyForm.replyText) {
    ElMessage.warning('请输入回复内容')
    return
  }
  try {
    await updateXinlizixunshiLiuyan({
      id: currentRow.value.id,
      replyText: replyForm.replyText
    })
    ElMessage.success('回复成功')
    dialogVisible.value = false
    loadData()
  } catch (error) {
    ElMessage.error('回复失败')
  }
}

onMounted(() => {
  loadData()
})
</script>

<style lang="scss" scoped>
.counselor-liuyan {
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

  .liuyan-content {
    padding: 12px;
    background-color: #f1f5f9;
    border-radius: 8px;
    color: #334155;
    max-height: 150px;
    overflow-y: auto;
  }
}
</style>