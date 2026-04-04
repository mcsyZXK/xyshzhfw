<template>
  <el-card class="realtime-chat-card">
    <template #header>
      <div class="chat-header">
        <span class="chat-title">实时交流</span>
        <div class="chat-status-group">
          <span class="chat-status" :class="statusClass">{{ statusText }}</span>
          <el-button link type="primary" @click="reconnect">重连</el-button>
        </div>
      </div>
    </template>

    <div class="chat-body" ref="messageListRef">
      <div
        v-for="item in messages"
        :key="item.id"
        class="chat-item"
        :class="item.type"
      >
        <template v-if="item.type === 'system'">
          <div class="system-text">{{ item.content }}</div>
        </template>
        <template v-else>
          <div class="chat-meta">
            <span class="sender">{{ item.senderName }}</span>
            <span class="time">{{ item.sendTime }}</span>
          </div>
          <div class="chat-content">{{ item.content }}</div>
        </template>
      </div>

      <el-empty v-if="messages.length === 0" description="还没有交流内容" />
    </div>

    <div class="chat-input-wrap">
      <el-input
        v-model="inputText"
        placeholder="输入内容，按 Enter 发送"
        @keydown.enter.exact.prevent="sendMessage"
      />
      <el-button type="primary" :disabled="!isConnected" @click="sendMessage">发送</el-button>
    </div>
  </el-card>
</template>

<script setup>
import { computed, nextTick, onBeforeUnmount, ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  wupinId: {
    type: [Number, String],
    required: true
  }
})

const socketRef = ref(null)
const socketVersion = ref(0)
const unmounted = ref(false)
const connectState = ref('idle')
const messages = ref([])
const inputText = ref('')
const messageListRef = ref(null)

const isConnected = computed(() => connectState.value === 'connected')

const statusText = computed(() => {
  if (connectState.value === 'connecting') return '连接中'
  if (connectState.value === 'connected') return '在线'
  if (connectState.value === 'error') return '异常'
  if (connectState.value === 'closed') return '已断开'
  return '未连接'
})

const statusClass = computed(() => `state-${connectState.value}`)

const currentUser = computed(() => {
  try {
    const raw = localStorage.getItem('userInfo')
    if (!raw) return { userId: 0, username: '我' }
    const data = JSON.parse(raw)
    const userId = Number(data.userId || data.userid || data.id || 0)
    const username = data.username || data.yonghuName || `用户${userId || ''}`
    return { userId, username }
  } catch (e) {
    return { userId: 0, username: '我' }
  }
})

const wsUrl = computed(() => {
  const token = localStorage.getItem('token')
  const currentWupinId = Number(props.wupinId || 0)
  if (!token || !currentWupinId) return ''
  const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws'
  return `${protocol}://${window.location.host}/xiaoyuanzonghefuwu/ws/wupin-chat?token=${encodeURIComponent(token)}&wupinId=${currentWupinId}`
})

const connect = () => {
  if (!wsUrl.value || unmounted.value) return
  closeSocket()
  connectState.value = 'connecting'
  const version = socketVersion.value + 1
  socketVersion.value = version
  const ws = new WebSocket(wsUrl.value)
  socketRef.value = ws

  ws.onopen = () => {
    if (unmounted.value || socketVersion.value !== version || socketRef.value !== ws) return
    connectState.value = 'connected'
  }

  ws.onmessage = (event) => {
    if (unmounted.value || socketVersion.value !== version || socketRef.value !== ws) return
    handleMessage(event.data)
  }

  ws.onerror = () => {
    if (unmounted.value || socketVersion.value !== version || socketRef.value !== ws) return
    connectState.value = 'error'
  }

  ws.onclose = () => {
    if (unmounted.value || socketVersion.value !== version || socketRef.value !== ws) return
    if (connectState.value !== 'idle') {
      connectState.value = 'closed'
    }
    socketRef.value = null
  }
}

const reconnect = () => {
  connect()
}

const closeSocket = () => {
  if (socketRef.value) {
    const ws = socketRef.value
    ws.onopen = null
    ws.onmessage = null
    ws.onerror = null
    ws.onclose = null
    try {
      ws.close()
    } catch (e) {
      // ignore
    }
    socketRef.value = null
  }
}

const sendMessage = () => {
  const content = inputText.value.trim()
  if (!content) {
    ElMessage.warning('请输入消息内容')
    return
  }
  if (!isConnected.value || !socketRef.value) {
    ElMessage.warning('连接未就绪，请稍后再试')
    return
  }
  socketRef.value.send(JSON.stringify({ content }))
  inputText.value = ''
}

const handleMessage = (raw) => {
  let payload
  try {
    payload = JSON.parse(raw)
  } catch (e) {
    return
  }

  if (payload.type === 'error') {
    ElMessage.error(payload.message || '实时连接异常')
    return
  }

  if (payload.type === 'system') {
    addMessage({
      type: 'system',
      content: payload.content || '',
      sendTime: payload.sendTime || ''
    })
    return
  }

  if (payload.type === 'chat') {
    const mine = Number(payload.senderUserId || 0) === Number(currentUser.value.userId || 0)
    addMessage({
      type: mine ? 'mine' : 'other',
      senderName: mine ? '我' : (payload.senderName || '对方'),
      content: payload.content || '',
      sendTime: payload.sendTime || ''
    })
  }
}

const addMessage = (message) => {
  messages.value.push({
    id: `${Date.now()}-${Math.random()}`,
    ...message
  })
  if (messages.value.length > 200) {
    messages.value.shift()
  }
  nextTick(() => {
    if (messageListRef.value) {
      messageListRef.value.scrollTop = messageListRef.value.scrollHeight
    }
  })
}

watch(
  () => props.wupinId,
  (val) => {
    if (Number(val || 0) > 0) {
      connect()
    }
  },
  { immediate: true }
)

onBeforeUnmount(() => {
  unmounted.value = true
  closeSocket()
})
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$bg-warm: #FEFAE0;
$bg-light: #E9EDC9;

.realtime-chat-card {
  border-radius: 16px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  margin-bottom: 24px;
  background: #fff;
}

.chat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.chat-title {
  font-size: 16px;
  font-weight: 700;
  color: #2D3436;
}

.chat-status-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-status {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
  color: #fff;
}

.state-connecting {
  background: #d98e04;
}

.state-connected {
  background: #2D6A4F;
}

.state-error {
  background: #c1121f;
}

.state-closed {
  background: #6c757d;
}

.state-idle {
  background: #6c757d;
}

.chat-body {
  max-height: 280px;
  overflow-y: auto;
  padding: 8px;
  background: linear-gradient(180deg, $bg-warm 0%, $bg-light 100%);
  border-radius: 10px;
}

.chat-item {
  margin-bottom: 10px;
}

.chat-item.system {
  text-align: center;
}

.system-text {
  display: inline-block;
  font-size: 12px;
  color: #666;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 10px;
  padding: 2px 10px;
}

.chat-item.mine .chat-content {
  background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
  color: #fff;
  margin-left: auto;
}

.chat-item.other .chat-content {
  background: #fff;
  color: #2D3436;
  border: 1px solid $primary;
}

.chat-meta {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #666;
  margin-bottom: 4px;
}

.chat-content {
  max-width: 90%;
  padding: 8px 10px;
  border-radius: 10px;
  line-height: 1.5;
  font-size: 14px;
  word-break: break-word;
}

.chat-input-wrap {
  margin-top: 12px;
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 8px;
}
</style>
