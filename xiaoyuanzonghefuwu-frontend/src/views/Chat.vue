<template>
  <div class="chat-page">
    <div class="chat-container">
      <!-- 聊天头部 -->
      <div class="chat-header">
        <div class="header-left">
          <el-button class="back-btn" @click="handleBack">
            <el-icon><ArrowLeft /></el-icon>
          </el-button>
          <div class="chat-info">
            <div class="chat-avatar">
              <el-avatar :size="44" :icon="User" />
            </div>
            <div class="chat-detail">
              <h3>{{ chatPartner }}</h3>
              <span class="online-status">🟢 在线</span>
            </div>
          </div>
        </div>
        <div class="header-actions">
          <el-button text @click="handleMore">
            <el-icon><MoreFilled /></el-icon>
          </el-button>
        </div>
      </div>

      <!-- 消息列表 -->
      <div class="message-list" ref="messageListRef">
        <div v-for="msg in messages" :key="msg.id" class="message-item" :class="msg.type">
          <div v-if="msg.type === 'received'" class="message-avatar">
            <el-avatar :size="36" :icon="User" />
          </div>
          <div class="message-content">
            <div class="message-bubble">
              {{ msg.content }}
            </div>
            <div class="message-time">{{ msg.time }}</div>
          </div>
          <div v-if="msg.type === 'sent'" class="message-status">
            <el-icon><CircleCheck /></el-icon>
          </div>
        </div>
        <el-empty v-if="messages.length === 0" description="暂无消息，开始聊天吧" />
      </div>

      <!-- 输入区域 -->
      <div class="input-area">
        <div class="input-tools">
          <el-button text @click="handleEmoji">
            <el-icon><StarFilled /></el-icon>
          </el-button>
          <el-button text @click="handleImage">
            <el-icon><Picture /></el-icon>
          </el-button>
          <el-button text @click="handleFile">
            <el-icon><Document /></el-icon>
          </el-button>
        </div>
        <div class="input-box">
          <el-input
            v-model="inputText"
            placeholder="输入消息..."
            :rows="2"
            type="textarea"
            class="chat-input"
            @keydown.enter.exact.prevent="handleSend"
          />
          <el-button type="primary" class="send-btn" @click="handleSend">
            <el-icon><Promotion /></el-icon>
          </el-button>
        </div>
      </div>
    </div>

    <!-- 快捷回复 -->
    <el-drawer v-model="showQuickReplies" title="快捷回复" size="300px">
      <div class="quick-reply-list">
        <div
          v-for="reply in quickReplies"
          :key="reply.id"
          class="quick-reply-item"
          @click="selectReply(reply.content)"
        >
          {{ reply.content }}
        </div>
      </div>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import {
  ArrowLeft, MoreFilled, StarFilled, Picture, Document, Promotion, CircleCheck, User
} from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { getChatList, addChat } from '@/api/chat'

const router = useRouter()
const messageListRef = ref(null)
const showQuickReplies = ref(false)

const chatPartner = ref('心理咨询师')
const inputText = ref('')

const messages = ref([])

const quickReplies = reactive([
  { id: 1, content: '你好' },
  { id: 2, content: '谢谢' },
  { id: 3, content: '好的，明白了' },
  { id: 4, content: '我再想想' },
  { id: 5, content: '谢谢老师，再见' },
])

onMounted(async () => {
  await loadMessages()
  scrollToBottom()
})

const scrollToBottom = () => {
  nextTick(() => {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  })
}

const handleBack = () => {
  router.back()
}

const handleMore = () => {
  showQuickReplies.value = true
}

const handleEmoji = () => {
  ElMessage.info('表情功能开发中')
}

const handleImage = () => {
  ElMessage.info('图片功能开发中')
}

const handleFile = () => {
  ElMessage.info('文件功能开发中')
}

const getCurrentUserId = () => {
  try {
    return Number(JSON.parse(localStorage.getItem('userInfo') || '{}')?.id || 0)
  } catch (error) {
    return 0
  }
}

const formatMsgTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  if (Number.isNaN(date.getTime())) return ''
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

const loadMessages = async () => {
  try {
    const res = await getChatList({
      page: 1,
      limit: 500,
      orderBy: 'insert_time',
      order: 'asc'
    })
    const chatRows = res?.data?.list || []
    messages.value = chatRows
      .flatMap(item => {
        const result = []
        if (item.chatIssue) {
          result.push({
            id: `${item.id}-issue`,
            type: 'sent',
            content: item.chatIssue,
            time: formatMsgTime(item.issueTime || item.insertTime),
            sortTime: new Date(item.issueTime || item.insertTime || 0).getTime()
          })
        }
        if (item.chatReply) {
          result.push({
            id: `${item.id}-reply`,
            type: 'received',
            content: item.chatReply,
            time: formatMsgTime(item.replyTime || item.insertTime),
            sortTime: new Date(item.replyTime || item.insertTime || 0).getTime()
          })
        }
        return result
      })
      .sort((a, b) => a.sortTime - b.sortTime)
      .map(({ sortTime, ...rest }) => rest)
  } catch (error) {
    console.error('获取聊天记录失败:', error)
  }
}

const handleSend = async () => {
  if (!inputText.value.trim()) {
    ElMessage.warning('请输入消息内容')
    return
  }
  const yonghuId = getCurrentUserId()
  if (!yonghuId) {
    ElMessage.error('未获取到用户信息，请重新登录')
    return
  }
  try {
    await addChat({
      yonghuId,
      chatIssue: inputText.value.trim(),
      issueTime: new Date().toISOString().slice(0, 19).replace('T', ' '),
      zhuangtaiTypes: 0,
      chatTypes: 1
    })
    inputText.value = ''
    await loadMessages()
    scrollToBottom()
  } catch (error) {
    console.error('发送消息失败:', error)
  }
}

const selectReply = (content) => {
  inputText.value = content
  showQuickReplies.value = false
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$secondary: #FFB703;
$secondary-dark: #FB8500;
$bg-warm: #FEFAE0;
$bg-light: #E9EDC9;
$text-primary: #2D3436;

.chat-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: linear-gradient(180deg, $bg-warm 0%, $bg-light 100%);
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  max-width: 800px;
  margin: 0 auto;
  width: 100%;
  background: #fff;
  box-shadow: 0 0 20px rgba($primary, 0.1);
}

// 聊天头部
.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
  border-bottom: 3px solid $secondary;
  
  .header-left {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .back-btn {
    color: #fff;
    
    &:hover {
      background: rgba(#fff, 0.2);
    }
  }
  
  .chat-info {
    display: flex;
    align-items: center;
    gap: 12px;
    
    .chat-detail {
      h3 {
        font-size: 17px;
        font-weight: 700;
        color: #fff;
        margin: 0 0 4px 0;
      }
      
      .online-status {
        font-size: 12px;
        color: rgba(#fff, 0.8);
      }
    }
  }
}

// 消息列表
.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: $bg-warm;
  
  .message-item {
    display: flex;
    align-items: flex-end;
    gap: 10px;
    margin-bottom: 16px;
    
    &.sent {
      flex-direction: row-reverse;
      
      .message-content {
        align-items: flex-end;
      }
      
      .message-bubble {
        background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
        color: #fff;
        border-radius: 16px 4px 16px 16px;
      }
      
      .message-time {
        text-align: right;
      }
    }
    
    &.received {
      .message-bubble {
        background: #fff;
        color: $text-primary;
        border-radius: 4px 16px 16px 16px;
        border: 2px solid $primary;
      }
    }
    
    .message-avatar {
      flex-shrink: 0;
    }
    
    .message-content {
      display: flex;
      flex-direction: column;
      max-width: 70%;
      
      .message-bubble {
        padding: 12px 16px;
        font-size: 14px;
        line-height: 1.5;
        box-shadow: 2px 2px 0 rgba($primary, 0.1);
      }
      
      .message-time {
        font-size: 11px;
        color: #999;
        margin-top: 4px;
      }
    }
    
    .message-status {
      color: $primary;
      font-size: 16px;
    }
  }
}

// 输入区域
.input-area {
  border-top: 2px solid $bg-light;
  background: #fff;
  padding: 12px 16px;
  
  .input-tools {
    display: flex;
    gap: 8px;
    margin-bottom: 8px;
  }
  
  .input-box {
    display: flex;
    gap: 10px;
    align-items: flex-end;
    
    .chat-input {
      flex: 1;
      
      :deep(.el-textarea__inner) {
        border-radius: 20px;
        border: 2px solid $bg-light;
        padding: 10px 16px;
        resize: none;
        
        &:focus {
          border-color: $primary;
        }
      }
    }
    
    .send-btn {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
      display: flex;
      align-items: center;
      justify-content: center;
      
      &:hover {
        transform: scale(1.05);
      }
    }
  }
}

// 快捷回复
.quick-reply-list {
  .quick-reply-item {
    padding: 12px 16px;
    margin-bottom: 8px;
    background: $bg-warm;
    border-radius: 10px;
    cursor: pointer;
    font-size: 14px;
    color: $text-primary;
    border: 2px solid transparent;
    transition: all 0.2s;
    
    &:hover {
      border-color: $primary;
      background: #fff;
    }
  }
}
</style>
