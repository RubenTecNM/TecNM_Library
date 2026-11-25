import type { RouteRecordRaw } from 'vue-router'

export const attendanceRoutes: RouteRecordRaw[] = [
  {
    path: 'attendance',
    alias: ['registro-de-asistencia'],
    name: 'attendance',
    component: () => import('./views/AttendanceView.vue'),
    meta: { title: 'Registro de Asistencia' },
  },
]
