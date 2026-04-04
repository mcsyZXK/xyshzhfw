<template>
  <div class="dashboard-page">
    <!-- 页面头部 - 与用户端风格一致 -->
    <div class="page-header">
      <div class="header-content">
        <h1>
          <span class="emoji">📊</span>
          数据看板
        </h1>
        <p>实时掌握系统运行状态</p>
      </div>
      <div class="header-decoration">
        <div class="deco-circle"></div>
      </div>
    </div>

    <!-- 统计卡片 - 不对称网格 -->
    <div class="stats-section">
      <div class="stats-grid">
        <!-- 大卡片 -->
        <div class="stat-card large stat-users">
          <div class="stat-emoji">👥</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.userCount }}</div>
            <div class="stat-label">总用户数</div>
          </div>
          <div class="stat-trend trend-up">
            <span>↑ 12%</span>
          </div>
          <div class="card-tag">活跃</div>
        </div>

        <div class="stat-card stat-activities">
          <div class="stat-emoji">🎪</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.activityCount }}</div>
            <div class="stat-label">活动总数</div>
          </div>
          <div class="stat-trend trend-up">
            <span>↑ 5%</span>
          </div>
        </div>

        <div class="stat-card stat-items">
          <div class="stat-emoji">📦</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.itemCount }}</div>
            <div class="stat-label">二手物品</div>
          </div>
          <div class="stat-trend trend-down">
            <span>↓ 3%</span>
          </div>
        </div>

        <div class="stat-card stat-posts">
          <div class="stat-emoji">💬</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.postCount }}</div>
            <div class="stat-label">论坛帖子</div>
          </div>
          <div class="stat-trend trend-up">
            <span>↑ 8%</span>
          </div>
        </div>

        <div class="stat-card stat-lost">
          <div class="stat-emoji">🔍</div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.lostCount }}</div>
            <div class="stat-label">失物招领</div>
          </div>
          <div class="stat-trend trend-up">
            <span>↑ 2%</span>
          </div>
        </div>

      </div>
    </div>

    <!-- 图表区域 - 卡片样式 -->
    <div class="charts-section">
      <h2 class="section-heading">
        <span class="emoji">📈</span>
        数据趋势
      </h2>

      <div class="charts-grid">
        <div class="chart-card">
          <div class="chart-header">
            <h3>近 7 天用户增长</h3>
          </div>
          <div class="chart-body" ref="userChartRef"></div>
        </div>

        <div class="chart-card">
          <div class="chart-header">
            <h3>近 7 天活动报名</h3>
          </div>
          <div class="chart-body" ref="activityChartRef"></div>
        </div>
      </div>
    </div>

    <!-- 热门排行 -->
    <div class="rankings-section">
      <h2 class="section-heading">
        <span class="emoji">🏆</span>
        热门排行
      </h2>

      <div class="rankings-grid">
        <div class="ranking-card">
          <div class="chart-header">
            <h3>🔥 热门活动</h3>
          </div>
          <div class="ranking-list">
            <div v-for="(item, index) in hotActivities" :key="item.id" class="ranking-item">
              <span class="rank-num" :class="'rank-' + (index + 1)">{{ index + 1 }}</span>
              <span class="rank-name">{{ item.name }}</span>
              <span class="rank-value">{{ item.views }}次浏览</span>
            </div>
          </div>
        </div>

        <div class="ranking-card">
          <div class="chart-header">
            <h3>💬 热门帖子</h3>
          </div>
          <div class="ranking-list">
            <div v-for="(item, index) in hotPosts" :key="item.id" class="ranking-item">
              <span class="rank-num" :class="'rank-' + (index + 1)">{{ index + 1 }}</span>
              <span class="rank-name">{{ item.title }}</span>
              <span class="rank-value">{{ item.replies }}条回复</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from 'vue'
import * as echarts from 'echarts'
import { getUserList } from '@/api/user'
import { getHuodongList } from '@/api/huodong'
import { getWupinList } from '@/api/wupin'
import { getForumList } from '@/api/forum'
import { getXunwuList } from '@/api/xunwu'
import { getHuodongOrderList } from '@/api/huodongOrder'

const MAX_FETCH_LIMIT = 10000

const stats = reactive({
  userCount: 0,
  activityCount: 0,
  itemCount: 0,
  postCount: 0,
  lostCount: 0
})

const hotActivities = ref([])
const hotPosts = ref([])
const chartLabels = ref([])
const userTrend = ref([])
const orderTrend = ref([])

const userChartRef = ref(null)
const activityChartRef = ref(null)
let userChartInstance = null
let activityChartInstance = null

onMounted(async () => {
  await loadDashboardData()
  nextTick(() => {
    initCharts()
  })
})

const toList = (res) => res?.data?.list || []
const toTotal = (res) => Number(res?.data?.total || 0)

const formatDateKey = (value) => {
  if (!value) return ''
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return ''
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${date.getFullYear()}-${month}-${day}`
}

const getLast7DateKeys = () => {
  const keys = []
  const today = new Date()
  for (let i = 6; i >= 0; i -= 1) {
    const date = new Date(today)
    date.setHours(0, 0, 0, 0)
    date.setDate(today.getDate() - i)
    keys.push(formatDateKey(date))
  }
  return keys
}

const aggregateByDate = (list, timeField, dateKeys) => {
  const counter = {}
  dateKeys.forEach(key => {
    counter[key] = 0
  })
  list.forEach(item => {
    const key = formatDateKey(item[timeField])
    if (counter[key] !== undefined) {
      counter[key] += 1
    }
  })
  return dateKeys.map(key => counter[key])
}

const loadDashboardData = async () => {
  await Promise.all([
    fetchStats(),
    fetchHotRankings(),
    fetchTrendData()
  ])
}

const fetchStats = async () => {
  try {
    const [
      userRes,
      huodongRes,
      wupinRes,
      forumRes,
      xunwuRes
    ] = await Promise.all([
      getUserList({ page: 1, limit: 1 }),
      getHuodongList({ page: 1, limit: 1 }),
      getWupinList({ page: 1, limit: 1 }),
      getForumList({ page: 1, limit: 1 }),
      getXunwuList({ page: 1, limit: 1 })
    ])

    stats.userCount = toTotal(userRes)
    stats.activityCount = toTotal(huodongRes)
    stats.itemCount = toTotal(wupinRes)
    stats.postCount = toTotal(forumRes)
    stats.lostCount = toTotal(xunwuRes)
  } catch (error) {
    console.error('获取看板统计失败:', error)
  }
}

const fetchHotRankings = async () => {
  try {
    const [hotActivityRes, forumRes] = await Promise.all([
      getHuodongList({ page: 1, limit: 5, orderBy: 'huodong_clicknum' }),
      getForumList({ page: 1, limit: MAX_FETCH_LIMIT, orderBy: 'id' })
    ])

    hotActivities.value = toList(hotActivityRes).map(item => ({
      id: item.id,
      name: item.huodongName,
      views: Number(item.huodongClicknum || 0)
    }))

    const forumItems = toList(forumRes)
    const replyCountMap = forumItems.reduce((map, item) => {
      const superId = Number(item.superIds || 0)
      if (superId > 0) {
        map[superId] = (map[superId] || 0) + 1
      }
      return map
    }, {})

    hotPosts.value = forumItems
      .filter(item => Number(item.superIds || 0) === 0)
      .map(item => ({
        id: item.id,
        title: item.forumName,
        replies: replyCountMap[item.id] || 0,
        insertTime: item.insertTime
      }))
      .sort((a, b) => {
        if (b.replies !== a.replies) return b.replies - a.replies
        return new Date(b.insertTime || 0) - new Date(a.insertTime || 0)
      })
      .slice(0, 5)
  } catch (error) {
    console.error('获取热门排行失败:', error)
  }
}

const fetchTrendData = async () => {
  try {
    const dateKeys = getLast7DateKeys()
    chartLabels.value = dateKeys.map(key => key.slice(5))

    const [userRes, orderRes] = await Promise.all([
      getUserList({ page: 1, limit: MAX_FETCH_LIMIT, orderBy: 'create_time' }),
      getHuodongOrderList({ page: 1, limit: MAX_FETCH_LIMIT, orderBy: 'insert_time' })
    ])

    userTrend.value = aggregateByDate(toList(userRes), 'createTime', dateKeys)
    orderTrend.value = aggregateByDate(toList(orderRes), 'insertTime', dateKeys)
  } catch (error) {
    console.error('获取趋势数据失败:', error)
  }
}

const initCharts = () => {
  // 用户增长图表
  if (userChartRef.value) {
    if (userChartInstance) {
      userChartInstance.dispose()
    }
    userChartInstance = echarts.init(userChartRef.value)
    userChartInstance.setOption({
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: chartLabels.value
      },
      yAxis: {
        type: 'value'
      },
      series: [{
        name: '新增用户',
        type: 'line',
        smooth: true,
        data: userTrend.value,
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(64, 158, 255, 0.5)' },
            { offset: 1, color: 'rgba(64, 158, 255, 0.05)' }
          ])
        },
        itemStyle: {
          color: '#409EFF'
        }
      }]
    })
  }

  // 活动报名图表
  if (activityChartRef.value) {
    if (activityChartInstance) {
      activityChartInstance.dispose()
    }
    activityChartInstance = echarts.init(activityChartRef.value)
    activityChartInstance.setOption({
      tooltip: {
        trigger: 'axis'
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
      },
      xAxis: {
        type: 'category',
        boundaryGap: false,
        data: chartLabels.value
      },
      yAxis: {
        type: 'value'
      },
      series: [{
        name: '报名人数',
        type: 'line',
        smooth: true,
        data: orderTrend.value,
        areaStyle: {
          color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
            { offset: 0, color: 'rgba(103, 194, 58, 0.5)' },
            { offset: 1, color: 'rgba(103, 194, 58, 0.05)' }
          ])
        },
        itemStyle: {
          color: '#67C23A'
        }
      }]
    })
  }
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
$bg-light: #E9EDC9;
$text-primary: #2D3436;

.dashboard-page {
  padding: 0;
  max-width: 1400px;
  margin: 0 auto;
}

// 页面头部
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
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
    width: 200px;
    height: 200px;
    background: rgba($secondary, 0.1);
    border-radius: 50%;
    top: -50px;
    right: -50px;
  }

  .header-content {
    z-index: 1;

    h1 {
      font-size: 28px;
      font-weight: 800;
      color: #fff;
      margin: 0 0 8px 0;
      display: flex;
      align-items: center;
      gap: 8px;

      .emoji {
        font-size: 32px;
      }
    }

    p {
      font-size: 15px;
      color: rgba(#fff, 0.9);
      margin: 0;
    }
  }

  .header-decoration {
    .deco-circle {
      width: 80px;
      height: 80px;
      background: rgba(#fff, 0.15);
      border-radius: 50%;
      border: 4px solid rgba($secondary, 0.4);
      animation: pulse 2s ease-in-out infinite;
    }
  }
}

// 区块标题
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

// 统计卡片区域
.stats-section {
  margin-bottom: 32px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  grid-template-rows: repeat(2, 1fr);
  gap: 20px;
}

.stat-card {
  background: #fff;
  border-radius: 20px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  padding: 24px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  position: relative;
  overflow: hidden;

  &:hover {
    transform: translateY(-6px) rotate(-1deg);
    box-shadow: 8px 8px 0 rgba($primary, 0.2);
  }

  &.large {
    grid-row: span 2;
    background: linear-gradient(135deg, $bg-warm 0%, #E9EDC9 100%);
    justify-content: center;
    text-align: center;

    .stat-emoji {
      font-size: 64px;
      margin-bottom: 8px;
    }

    .stat-value {
      font-size: 48px;
    }

    .card-tag {
      position: absolute;
      top: 12px;
      right: 12px;
      background: $secondary-dark;
      color: #fff;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 12px;
      font-weight: 700;
    }
  }

  .stat-emoji {
    font-size: 40px;
  }

  .stat-content {
    .stat-value {
      font-size: 32px;
      font-weight: 800;
      color: $text-primary;
      line-height: 1;
    }

    .stat-label {
      font-size: 14px;
      color: #666;
      margin-top: 4px;
    }
  }

  .stat-trend {
    font-size: 13px;
    font-weight: 600;

    &.trend-up {
      color: $accent-mint;
    }

    &.trend-down {
      color: #F56C6C;
    }
  }

  // 不同模块的渐变背景
  &.stat-users .stat-emoji { color: #667eea; }
  &.stat-activities .stat-emoji { color: $secondary-dark; }
  &.stat-items .stat-emoji { color: $accent-blue; }
  &.stat-posts .stat-emoji { color: $accent-mint; }
  &.stat-lost .stat-emoji { color: $accent-pink; }
}

// 图表区域
.charts-section {
  margin-bottom: 32px;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.chart-card {
  background: #fff;
  border-radius: 20px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  padding: 24px;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 6px 6px 0 rgba($primary, 0.2);
  }

  .chart-header {
    margin-bottom: 16px;

    h3 {
      font-size: 16px;
      font-weight: 700;
      color: $text-primary;
    }
  }

  .chart-body {
    height: 280px;
  }
}

// 热门排行
.rankings-section {
  margin-bottom: 32px;
}

.rankings-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.ranking-card {
  background: #fff;
  border-radius: 20px;
  border: 2px solid $primary;
  box-shadow: 4px 4px 0 rgba($primary, 0.15);
  padding: 24px;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 6px 6px 0 rgba($primary, 0.2);
  }

  .chart-header {
    margin-bottom: 16px;

    h3 {
      font-size: 16px;
      font-weight: 700;
      color: $text-primary;
    }
  }

  .ranking-list {
    .ranking-item {
      display: flex;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px dashed $bg-light;
      transition: all 0.2s ease;

      &:last-child {
        border-bottom: none;
      }

      &:hover {
        .rank-name {
          color: $primary;
        }
      }

      .rank-num {
        width: 28px;
        height: 28px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
        font-weight: 700;
        color: #999;
        background: #f5f5f5;
        margin-right: 12px;
        flex-shrink: 0;

        &.rank-1 {
          background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
          color: #fff;
          box-shadow: 2px 2px 0 rgba(255, 215, 0, 0.3);
        }

        &.rank-2 {
          background: linear-gradient(135deg, #C0C0C0 0%, #E8E8E8 100%);
          color: #fff;
        }

        &.rank-3 {
          background: linear-gradient(135deg, #CD7F32 0%, #E8A87C 100%);
          color: #fff;
        }
      }

      .rank-name {
        flex: 1;
        font-size: 14px;
        font-weight: 500;
        color: $text-primary;
        transition: color 0.2s;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .rank-value {
        font-size: 13px;
        color: #999;
        flex-shrink: 0;
      }
    }
  }
}

// 动画
@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.1);
    opacity: 0.8;
  }
}

// 响应式
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .charts-grid,
  .rankings-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 992px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);

    .stat-card.large {
      grid-row: span 1;
    }
  }
}

@media (max-width: 576px) {
  .page-header {
    padding: 20px;
    flex-direction: column;
    text-align: center;

    .header-content h1 {
      font-size: 22px;
    }
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .section-heading {
    font-size: 18px;
  }
}
</style>
