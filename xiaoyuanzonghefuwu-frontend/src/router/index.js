import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { title: '登录' }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('@/views/Register.vue'),
    meta: { title: '注册' }
  },
  {
    path: '/counselor',
    name: 'CounselorLayout',
    component: () => import('@/layouts/CounselorLayout.vue'),
    redirect: '/counselor/dashboard',
    meta: { title: '咨询师端', requiresAuth: true },
    children: [
      {
        path: 'dashboard',
        name: 'CounselorDashboard',
        component: () => import('@/views/counselor/Dashboard.vue'),
        meta: { title: '咨询师工作台', requiresAuth: true }
      },
      {
        path: 'chat',
        name: 'CounselorChat',
        component: () => import('@/views/counselor/Chat.vue'),
        meta: { title: '咨询管理', requiresAuth: true }
      },
      {
        path: 'liuyan',
        name: 'CounselorLiuyan',
        component: () => import('@/views/counselor/Liuyan.vue'),
        meta: { title: '留言管理', requiresAuth: true }
      },
      {
        path: 'forum',
        name: 'CounselorForum',
        component: () => import('@/views/counselor/Forum.vue'),
        meta: { title: '帖子管理', requiresAuth: true }
      },
      {
        path: 'profile',
        name: 'CounselorProfile',
        component: () => import('@/views/counselor/Profile.vue'),
        meta: { title: '个人信息', requiresAuth: true }
      }
    ]
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/layouts/MainLayout.vue'),
    redirect: '/login',
    children: [
      {
        path: '/home',
        name: 'Home',
        component: () => import('@/views/Home.vue'),
        meta: { title: '首页' }
      },
      {
        path: '/huodong',
        name: 'Huodong',
        component: () => import('@/views/huodong/List.vue'),
        meta: { title: '活动列表' }
      },
      {
        path: '/huodong/:id',
        name: 'HuodongDetail',
        component: () => import('@/views/huodong/Detail.vue'),
        meta: { title: '活动详情' }
      },
      {
        path: '/wupin',
        name: 'Wupin',
        component: () => import('@/views/wupin/List.vue'),
        meta: { title: '二手物品' }
      },
      {
        path: '/wupin/:id',
        name: 'WupinDetail',
        component: () => import('@/views/wupin/Detail.vue'),
        meta: { title: '物品详情' }
      },
      {
        path: '/xunwu',
        name: 'Xunwu',
        component: () => import('@/views/xunwu/List.vue'),
        meta: { title: '失物招领' }
      },
      {
        path: '/xunwu/:id',
        name: 'XunwuDetail',
        component: () => import('@/views/xunwu/Detail.vue'),
        meta: { title: '寻物详情' }
      },
      {
        path: '/forum',
        name: 'Forum',
        component: () => import('@/views/forum/List.vue'),
        meta: { title: '校园论坛' }
      },
      {
        path: '/forum/:id(\\d+)',
        name: 'ForumDetail',
        component: () => import('@/views/forum/Detail.vue'),
        meta: { title: '帖子详情' }
      },
      {
        path: '/profile',
        name: 'Profile',
        component: () => import('@/views/user/Profile.vue'),
        meta: { title: '个人中心' }
      },
      {
        path: '/admin',
        name: 'Admin',
        redirect: '/admin/user',
        meta: { title: '后台管理', requiresAuth: true, requiresAdmin: true },
        children: [
          {
            path: '/admin/user',
            name: 'AdminUser',
            component: () => import('@/views/admin/User.vue'),
            meta: { title: '用户管理' }
          },
          {
            path: '/admin/huodong',
            name: 'AdminHuodong',
            component: () => import('@/views/admin/Huodong.vue'),
            meta: { title: '活动管理' }
          },
          {
            path: '/admin/wupin',
            name: 'AdminWupin',
            component: () => import('@/views/admin/Wupin.vue'),
            meta: { title: '物品管理' }
          },
          {
            path: '/admin/xunwu',
            name: 'AdminXunwu',
            component: () => import('@/views/admin/Xunwu.vue'),
            meta: { title: '失物招领管理' }
          },
          {
            path: '/admin/forum',
            name: 'AdminForum',
            component: () => import('@/views/admin/Forum.vue'),
            meta: { title: '论坛管理' }
          },
          {
            path: '/admin/dashboard',
            name: 'AdminDashboard',
            component: () => import('@/views/admin/Dashboard.vue'),
            meta: { title: '管理首页' }
          },
          {
            path: '/admin/order',
            name: 'AdminOrder',
            component: () => import('@/views/admin/HuodongOrder.vue'),
            meta: { title: '报名管理' }
          },
          {
            path: '/admin/huodongorder',
            name: 'AdminHuodongOrder',
            component: () => import('@/views/admin/HuodongOrder.vue'),
            meta: { title: '报名管理' }
          },
          {
            path: '/admin/dictionary',
            name: 'AdminDictionary',
            component: () => import('@/views/admin/Dictionary.vue'),
            meta: { title: '字典管理' }
          },
          {
            path: '/admin/config',
            name: 'AdminConfig',
            component: () => import('@/views/admin/Config.vue'),
            meta: { title: '配置管理' }
          }
        ]
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  document.title = `${to.meta.title || '校园生活综合服务系统'}`

  const token = localStorage.getItem('token')
  const role = localStorage.getItem('role')
  const userRole = localStorage.getItem('userRole')

  if (to.meta.requiresAuth && !token) {
    next('/login')
    return
  }

  if (to.path.startsWith('/admin')) {
    if (!token) {
      next('/login')
      return
    }
    if (role !== '管理员') {
      next('/home')
      return
    }
  }

  if (to.path.startsWith('/counselor')) {
    if (!token) {
      next('/login')
      return
    }
    if (userRole !== 'xinlizixunshi') {
      next('/home')
      return
    }
  }

  next()
})

export default router
