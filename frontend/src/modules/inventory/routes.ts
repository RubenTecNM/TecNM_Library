import type { RouteRecordRaw } from 'vue-router'

export const inventoryRoutes: RouteRecordRaw[] = [
  {
    path: 'inventory',
    alias: ['inventario'],
    name: 'inventory',
    component: () => import('./views/InventoryView.vue'),
    meta: { title: 'Inventario' },
  },
]
