import { createRouter, createWebHistory } from 'vue-router'

import { homeRoutes } from '../../modules/home'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      component: () => import('../layouts/MainLayout.vue'),
      children: homeRoutes,
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'not-found',
      component: () => import('../../shared/views/NotFoundView.vue'),
    },
  ],
  scrollBehavior(to, _from, savedPosition) {
    return savedPosition ?? (to.hash ? { el: to.hash, top: 24 } : { top: 0 })
  },
})

router.afterEach((to) => {
  const title = typeof to.meta.title === 'string' ? to.meta.title : 'Proyecto'
  document.title = `${title} | TecNM`
})

export default router
