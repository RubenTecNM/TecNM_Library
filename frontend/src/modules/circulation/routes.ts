import type { RouteRecordRaw } from 'vue-router'

export const circulationRoutes: RouteRecordRaw[] = [
  {
    path: 'circulation',
    alias: ['circulacion-y-prestamos'],
    name: 'circulation',
    component: () => import('./views/CirculationView.vue'),
    meta: { title: 'Circulación y Préstamos' },
  },
]
