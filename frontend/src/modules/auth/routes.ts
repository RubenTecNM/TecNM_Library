import type { RouteRecordRaw } from 'vue-router'

export const authRoutes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'login',
    component: () => import('./views/LoginView.vue'),
  },
]

export const authenticatedAuthRoutes: RouteRecordRaw[] = [
  {
    path: '',
    name: 'session',
    component: () => import('./views/SessionView.vue'),
    meta: { requiresAuth: true },
  },
]
