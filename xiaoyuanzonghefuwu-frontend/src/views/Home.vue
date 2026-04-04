<template>
  <div class="home-page">
    <!-- 欢迎横幅 - 不对称设计 -->
    <div class="welcome-banner">
      <div class="banner-content">
        <div class="banner-text">
          <h1>🎓 校园生活<br>从这里开始</h1>
          <p>一站式服务平台，让校园生活更便捷</p>
        </div>
        <div class="banner-illustration">
          <div class="illustration-box">
            <span class="big-emoji">🏫</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 功能卡片 - 不对称网格 -->
    <div class="feature-section">
      <h2 class="section-heading">
        <span class="emoji">✨</span>
        发现精彩
      </h2>
      
      <div class="feature-grid">
        <!-- 大卡片 -->
        <el-card class="feature-card large" shadow="hover" @click="$router.push('/huodong')">
          <div class="card-emoji">🎪</div>
          <h3>校园活动</h3>
          <p>下课逛逛，发现精彩</p>
          <div class="card-tag">热门</div>
        </el-card>

        <el-card class="feature-card" shadow="hover" @click="$router.push('/wupin')">
          <div class="card-emoji">📦</div>
          <h3>二手物品</h3>
          <p>淘点好书，省点零花</p>
        </el-card>

        <el-card class="feature-card" shadow="hover" @click="$router.push('/xunwu')">
          <div class="card-emoji">🔍</div>
          <h3>失物招领</h3>
          <p>丢了东西？别着急</p>
        </el-card>

        <el-card class="feature-card" shadow="hover" @click="$router.push('/forum')">
          <div class="card-emoji">💬</div>
          <h3>校园论坛</h3>
          <p>有话要说？来聊聊</p>
        </el-card>

        <el-card class="feature-card" shadow="hover" @click="$router.push('/wupin')">
          <div class="card-emoji">📸</div>
          <h3>发布闲置</h3>
          <p>拍照上架，更快出</p>
        </el-card>

        <el-card class="feature-card" shadow="hover" @click="$router.push('/profile')">
          <div class="card-emoji">🧭</div>
          <h3>我的中心</h3>
          <p>查看资料和动态</p>
        </el-card>
      </div>
    </div>

    <!-- 个人中心和管理入口 -->
    <div class="quick-section">
      <h2 class="section-heading">
        <span class="emoji">🚀</span>
        快速入口
      </h2>
      
      <div class="quick-grid">
        <el-card class="quick-card" shadow="hover" @click="$router.push('/profile')">
          <div class="quick-icon">👤</div>
          <span>个人中心</span>
        </el-card>
        
        <el-card v-if="isAdmin" class="quick-card admin" shadow="hover" @click="$router.push('/admin')">
          <div class="quick-icon">⚙️</div>
          <span>后台管理</span>
        </el-card>
      </div>
    </div>

    <!-- 最新动态 -->
    <div class="latest-section">
      <el-row :gutter="24">
        <el-col :xs="24" :sm="12">
          <el-card class="section-card">
            <template #header>
              <div class="card-header">
                <span>🔥 最新活动</span>
                <el-button text type="primary" @click="$router.push('/huodong')">更多</el-button>
              </div>
            </template>
            <el-empty v-if="latestHuodong.length === 0" description="还没有活动哦" />
            <div v-else class="latest-list">
              <div
                v-for="item in latestHuodong"
                :key="item.id"
                class="latest-item"
                @click="$router.push(`/huodong/${item.id}`)"
              >
                <div class="item-dot"></div>
                <div class="item-content">
                  <div class="item-title">{{ item.huodongName }}</div>
                  <div class="item-meta">
                    <el-icon><Clock /></el-icon>
                    {{ formatTime(item.kaishiTime) }}
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>

        <el-col :xs="24" :sm="12">
          <el-card class="section-card">
            <template #header>
              <div class="card-header">
                <span>💭 最新帖子</span>
                <el-button text type="primary" @click="$router.push('/forum')">更多</el-button>
              </div>
            </template>
            <el-empty v-if="latestForum.length === 0" description="还没有帖子哦" />
            <div v-else class="latest-list">
              <div
                v-for="item in latestForum"
                :key="item.id"
                class="latest-item"
                @click="$router.push(`/forum/${item.id}`)"
              >
                <div class="item-dot"></div>
                <div class="item-content">
                  <div class="item-title">{{ item.forumName }}</div>
                  <div class="item-meta">
                    <el-icon><Clock /></el-icon>
                    {{ formatTime(item.insertTime) }}
                  </div>
                </div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getHuodongList } from '@/api/huodong'
import { getForumList } from '@/api/forum'

const latestHuodong = ref([])
const latestForum = ref([])
const isAdmin = ref(false)

onMounted(async () => {
  const role = localStorage.getItem('role')
  isAdmin.value = role === '管理员'

  try {
    const res = await getHuodongList({ page: 1, limit: 4, orderBy: 'id' })
    if (res && res.data) {
      latestHuodong.value = res.data.list || res.data || []
    }
  } catch (error) {
    console.error('获取活动失败:', error)
  }

  try {
    const res = await getForumList({ page: 1, limit: 4, orderBy: 'id' })
    if (res && res.data) {
      latestForum.value = res.data.list || res.data || []
    }
  } catch (error) {
    console.error('获取帖子失败:', error)
  }
})

const formatTime = (time) => {
  if (!time) return ''
  const date = new Date(time)
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${month}/${day} ${hours}:${minutes}`
}
</script>

<style lang="scss" scoped>
$primary: #2D6A4F;
$primary-dark: #1D4E3A;
$primary-light: #40916C;
$secondary: #FFB703;
$secondary-dark: #FB8500;
$accent-blue: #89C2D9;
$accent-pink: #FFAFCC;
$accent-mint: #74C69D;
$bg-warm: #FEFAE0;
$text-primary: #2D3436;

.home-page {
  padding: 0;
  max-width: 1200px;
  margin: 0 auto;
}

// 欢迎横幅
.welcome-banner {
  margin-bottom: 32px;
  
  .banner-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 32px;
    background: linear-gradient(135deg, $primary 0%, $primary-dark 100%);
    border-radius: 24px;
    padding: 40px;
    border: 3px solid $secondary;
    box-shadow: 8px 8px 0 rgba($primary, 0.3);
    position: relative;
    overflow: hidden;
    
    &::before {
      content: '';
      position: absolute;
      width: 200px;
      height: 200px;
      background: rgba($secondary, 0.1);
      border-radius: 50%;
      top: -50px;
      right: -50px;
    }
    
    &::after {
      content: '';
      position: absolute;
      width: 100px;
      height: 100px;
      background: rgba($accent-blue, 0.15);
      border-radius: 50%;
      bottom: 20px;
      left: 20px;
    }
  }
  
  .banner-text {
    flex: 1;
    z-index: 1;
    
    h1 {
      font-size: 36px;
      font-weight: 800;
      color: #fff;
      margin: 0 0 12px 0;
      line-height: 1.3;
    }
    
    p {
      font-size: 16px;
      color: rgba(#fff, 0.9);
      margin: 0;
    }
  }
  
  .banner-illustration {
    .illustration-box {
      width: 120px;
      height: 120px;
      background: rgba(#fff, 0.2);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      border: 4px solid rgba($secondary, 0.5);
      animation: float 3s ease-in-out infinite;
    }
    
    .big-emoji {
      font-size: 64px;
    }
  }
}

// 功能区域
.feature-section {
  margin-bottom: 32px;
}

.section-heading {
  font-size: 22px;
  font-weight: 700;
  color: $text-primary;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
  
  .emoji {
    font-size: 24px;
  }
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(2, 1fr);
  gap: 20px;
  
  .feature-card {
    border-radius: 20px;
    border: 2px solid $primary;
    box-shadow: 4px 4px 0 rgba($primary, 0.15);
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    text-align: center;
    padding: 24px 16px;
    position: relative;
    background: #fff;
    
    &:hover {
      transform: translateY(-6px) rotate(-2deg);
      box-shadow: 8px 8px 0 rgba($primary, 0.2);
    }
    
    &.large {
      grid-row: span 2;
      background: linear-gradient(135deg, $bg-warm 0%, #E9EDC9 100%);
      
      .card-emoji {
        font-size: 72px;
        margin-bottom: 16px;
      }
      
      h3 {
        font-size: 20px;
      }
      
      .card-tag {
        position: absolute;
        top: 12px;
        right: 12px;
        background: $secondary-dark;
        color: #fff;
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
      }
    }
    
    .card-emoji {
      font-size: 48px;
      margin-bottom: 12px;
    }
    
    h3 {
      font-size: 16px;
      font-weight: 700;
      color: $text-primary;
      margin: 0 0 8px 0;
    }
    
    p {
      font-size: 13px;
      color: #888;
      margin: 0;
    }
  }
}

// 快速入口
.quick-section {
  margin-bottom: 32px;
}

.quick-grid {
  display: flex;
  gap: 16px;
  
  .quick-card {
    flex: 1;
    max-width: 200px;
    border-radius: 16px;
    border: 2px solid $primary;
    box-shadow: 4px 4px 0 rgba($primary, 0.15);
    cursor: pointer;
    transition: all 0.3s ease;
    text-align: center;
    padding: 20px;
    background: #fff;
    
    &:hover {
      transform: translateY(-4px);
      box-shadow: 6px 6px 0 rgba($primary, 0.2);
    }
    
    &.admin {
      background: linear-gradient(135deg, $accent-blue 0%, #6BA3C4 100%);
      border-color: #5a8fa8;
      
      span {
        color: #fff;
      }
    }
    
    .quick-icon {
      font-size: 40px;
      margin-bottom: 8px;
    }
    
    span {
      font-size: 15px;
      font-weight: 600;
      color: $text-primary;
    }
  }
}

// 最新动态
.latest-section {
  .section-card {
    border-radius: 20px;
    border: 2px solid $primary;
    box-shadow: 4px 4px 0 rgba($primary, 0.15);
    margin-bottom: 24px;
    background: #fff;
    
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-weight: 700;
      color: $text-primary;
    }
  }
  
  .latest-list {
    .latest-item {
      display: flex;
      align-items: flex-start;
      gap: 12px;
      padding: 12px 0;
      border-bottom: 1px dashed $bg-warm;
      cursor: pointer;
      transition: background 0.2s;
      
      &:last-child {
        border-bottom: none;
      }
      
      &:hover {
        .item-title {
          color: $primary;
        }
      }
      
      .item-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background: $secondary;
        margin-top: 6px;
        flex-shrink: 0;
      }
      
      .item-content {
        flex: 1;
        
        .item-title {
          font-size: 14px;
          font-weight: 600;
          color: $text-primary;
          margin-bottom: 6px;
          transition: color 0.2s;
          display: -webkit-box;
          -webkit-line-clamp: 1;
          -webkit-box-orient: vertical;
          overflow: hidden;
        }
        
        .item-meta {
          display: flex;
          align-items: center;
          gap: 4px;
          font-size: 12px;
          color: #999;
        }
      }
    }
  }
}

// 响应式
@media (max-width: 992px) {
  .feature-grid {
    grid-template-columns: repeat(2, 1fr);
    
    .feature-card.large {
      grid-row: span 1;
    }
  }
}

@media (max-width: 576px) {
  .banner-content {
    flex-direction: column;
    text-align: center;
    padding: 24px !important;
  }
  
  .banner-text h1 {
    font-size: 26px;
  }
  
  .feature-grid {
    grid-template-columns: 1fr;
  }
  
  .quick-grid {
    flex-direction: column;
    
    .quick-card {
      max-width: none;
    }
  }
}
</style>
