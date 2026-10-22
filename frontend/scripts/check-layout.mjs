import assert from 'node:assert/strict'
import { createServer } from 'vite'
import vue from '@vitejs/plugin-vue'
import { createSSRApp, h } from 'vue'
import { renderToString } from 'vue/server-renderer'
import { createMemoryHistory, createRouter } from 'vue-router'

const server = await createServer({
  configFile: false,
  plugins: [vue()],
  server: { middlewareMode: true, hmr: false, ws: false },
  optimizeDeps: { noDiscovery: true, include: [] },
})

try {
  const { default: Shell } = await server.ssrLoadModule('/src/shared/components/UiShell.vue')
  for (const showHeader of [true, false]) {
    for (const showSidebar of [true, false]) {
      const html = await renderToString(createSSRApp({
        render: () => h(Shell, { showHeader, showSidebar }, {
          header: () => h('header', 'Header'),
          sidebar: () => h('aside', 'Sidebar'),
          default: () => h('p', 'Contenido'),
        }),
      }))
      assert.equal(html.includes('<header>'), showHeader)
      assert.equal(html.includes('<aside>'), showSidebar)
      assert.equal(html.includes('layout--content-only'), !showSidebar)
      assert.ok(html.includes('Contenido'))
    }
  }

  for (const component of ['UiHeader', 'UiSidebar']) {
    const { default: Navigation } = await server.ssrLoadModule(`/src/shared/components/${component}.vue`)
    for (const showTitle of [true, false]) {
      for (const showLogo of [true, false]) {
        const router = createRouter({ history: createMemoryHistory(), routes: [{ path: '/', component: { render: () => null } }] })
        const app = createSSRApp({ render: () => h(Navigation, {
          title: 'TecNM', showTitle, showLogo,
          items: [{ label: 'Inicio', to: '/' }, { label: 'Biblioteca', children: [{ label: 'Cuenta', to: '/#cuenta' }] }],
        }) })
        app.use(router)
        await router.push('/#cuenta')
        const html = await renderToString(app)
        assert.equal(/<span[^>]*>TecNM/.test(html), showTitle)
        assert.equal(html.includes('<img'), showLogo)
        assert.ok(html.includes('<details'))
        assert.ok(html.includes('href="/#cuenta" class="active" aria-current="location"'))
        assert.ok(html.includes('href="/"'))
      }
    }
  }
  console.log('Layout: cuatro composiciones, marca independiente y grupos correctos.')
} finally {
  await server.close()
}
