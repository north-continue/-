import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue')
  },
  {
    path: '/',
    name: 'Layout',
    component: () => import('@/views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue'),
        meta: { title: '工作台' }
      },
      {
        path: 'items',
        name: 'Items',
        component: () => import('@/views/items/ItemList.vue'),
        meta: { title: '物品管理' }
      },
      {
        path: 'items/:id',
        name: 'ItemDetail',
        component: () => import('@/views/items/ItemDetail.vue'),
        meta: { title: '物品详情' }
      },
      {
        path: 'inbound',
        name: 'Inbound',
        component: () => import('@/views/inbound/InboundManagement.vue'),
        meta: { title: '入库管理' }
      },
      {
        path: 'outstock',
        name: 'OutStock',
        component: () => import('@/views/inventory/OutStock.vue'),
        meta: { title: '出库管理' }
      },
      {
        path: 'borrow',
        name: 'Borrow',
        component: () => import('@/views/borrow/BorrowList.vue'),
        meta: { title: '借用管理' }
      },
      {
        path: 'repair',
        name: 'Repair',
        component: () => import('@/views/repair/RepairList.vue'),
        meta: { title: '报废报修' }
      },
      {
        path: 'inventory',
        name: 'Inventory',
        component: () => import('@/views/inventory/InventoryCheck.vue'),
        meta: { title: '盘点管理' }
      },
      {
        path: 'statistics',
        name: 'Statistics',
        component: () => import('@/views/Statistics.vue'),
        meta: { title: '数据统计' }
      },
      {
        path: 'system',
        name: 'System',
        component: () => import('@/views/system/UserManage.vue'),
        meta: { title: '系统管理' }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.path === '/login') {
    next()
  } else {
    if (!token) {
      next('/login')
    } else {
      next()
    }
  }
})

export default router
