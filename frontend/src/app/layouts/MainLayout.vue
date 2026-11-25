<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

interface NavItem {
  label: string
  icon: string
  to?: string
  routeName?: string
}

const route = useRoute()
const mobileMenuOpen = ref(false)

const navItems: NavItem[] = [
  {
    label: 'Inventario',
    icon: 'shelves',
    to: '/inventory',
    routeName: 'inventory',
  },
  {
    label: 'Circulación y Préstamos',
    icon: 'sync_alt',
    to: '/circulation',
    routeName: 'circulation',
  },
  {
    label: 'Registro de Asistencia',
    icon: 'checklist',
  },
]

function isActive(item: NavItem): boolean {
  if (!item.routeName) return false
  return route.name === item.routeName
}

function closeMobileMenu() {
  mobileMenuOpen.value = false
}

function handleEscape(event: KeyboardEvent) {
  if (event.key === 'Escape' && mobileMenuOpen.value) {
    mobileMenuOpen.value = false
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleEscape)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleEscape)
})
</script>

<template>
  <div class="min-h-screen bg-background font-body-md text-body-md text-on-surface antialiased selection:bg-tecnm-gold/30 selection:text-primary">
    <!-- Barra superior móvil (< lg) -->
    <div class="lg:hidden sticky top-0 z-40 bg-primary text-on-primary px-4 py-3 flex items-center justify-between shadow-md">
      <div class="flex items-center gap-2.5">
        <div class="w-9 h-9 rounded-lg bg-secondary flex items-center justify-center text-on-secondary font-headline-sm font-bold shadow-sm">
          TN
        </div>
        <div class="flex flex-col">
          <span class="font-headline-sm text-sm font-bold text-on-primary leading-tight">
            Tec Monclova
          </span>
          <span class="font-label-sm text-[10px] text-primary-fixed-dim uppercase tracking-wider">
            Sistema Bibliotecario
          </span>
        </div>
      </div>
      <button
        type="button"
        class="p-2 rounded-lg bg-primary-container text-on-primary"
        aria-label="Abrir menú de navegación"
        @click="mobileMenuOpen = !mobileMenuOpen"
      >
        <span class="material-symbols-outlined text-[22px]">
          {{ mobileMenuOpen ? 'close' : 'menu' }}
        </span>
      </button>
    </div>

    <!-- Fondo del menú móvil -->
    <div
      v-if="mobileMenuOpen"
      class="fixed inset-0 z-40 bg-[#001838]/60 backdrop-blur-xs lg:hidden"
      @click="closeMobileMenu"
    />

    <!-- Menú de navegación lateral persistente -->
    <aside
      :class="[
        'fixed left-0 top-0 bottom-0 w-72 bg-primary text-on-primary z-50 flex flex-col justify-between p-space-lg shadow-[0_1px_8px_rgba(0,0,0,0.06)] transition-transform duration-200',
        mobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0',
      ]"
    >
      <div class="flex flex-col gap-space-lg">
        <div class="flex items-center gap-space-sm pb-space-md border-b border-on-primary/10">
          <div class="w-10 h-10 rounded-lg bg-secondary flex items-center justify-center text-on-secondary font-headline-sm font-bold shadow-sm">
            TN
          </div>
          <div class="flex flex-col">
            <span class="font-headline-sm text-headline-sm font-bold text-on-primary leading-tight tracking-tight">
              Tec Monclova
            </span>
            <span class="font-label-sm text-label-sm text-primary-fixed-dim uppercase tracking-wider">
              TecNM • Sistema Bibliotecario
            </span>
          </div>
        </div>

        <div class="px-space-xs">
          <span class="font-label-sm text-label-sm text-primary-fixed-dim uppercase tracking-widest font-semibold">
            Módulos de Gestión
          </span>
        </div>

        <nav class="flex flex-col gap-space-xs" aria-label="Módulos de Gestión">
          <template v-for="item in navItems" :key="item.label">
            <RouterLink
              v-if="item.to"
              :to="item.to"
              :aria-current="isActive(item) ? 'page' : undefined"
              :class="[
                'flex items-center gap-space-md px-space-md py-space-sm rounded-lg transition-colors font-label-lg text-label-lg',
                isActive(item)
                  ? 'bg-primary-container text-on-primary font-semibold shadow-sm'
                  : 'text-on-primary-container hover:bg-primary-container hover:text-on-primary',
              ]"
              @click="closeMobileMenu"
            >
              <span class="material-symbols-outlined text-[20px]">{{ item.icon }}</span>
              <span>{{ item.label }}</span>
            </RouterLink>
            <a
              v-else
              href="#registro-de-asistencia"
              class="flex items-center gap-space-md px-space-md py-space-sm rounded-lg text-on-primary-container hover:bg-primary-container hover:text-on-primary transition-colors font-label-lg text-label-lg"
              title="Módulo próximamente disponible"
              @click.prevent="closeMobileMenu"
            >
              <span class="material-symbols-outlined text-[20px]">{{ item.icon }}</span>
              <span>{{ item.label }}</span>
            </a>
          </template>
        </nav>
      </div>

      <div class="pt-space-md border-t border-on-primary/10 flex flex-col gap-space-sm">
        <div class="flex items-center gap-space-sm">
          <div class="w-9 h-9 rounded-full bg-primary-container flex items-center justify-center text-on-primary border border-on-primary/20">
            <span class="material-symbols-outlined text-[18px]">admin_panel_settings</span>
          </div>
          <div class="flex flex-col overflow-hidden">
            <span class="font-label-md text-label-md text-on-primary font-medium truncate">
              Lic. M. Rodríguez
            </span>
            <span class="font-label-sm text-label-sm text-primary-fixed-dim truncate">
              Administradora del Sistema
            </span>
          </div>
        </div>
        <div class="flex items-center justify-between text-primary-fixed-dim font-label-sm text-label-sm pt-space-xs">
          <span class="flex items-center gap-1">
            <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
            En línea
          </span>
          <span
            class="material-symbols-outlined text-[18px] cursor-pointer hover:text-on-primary transition-colors"
            title="Cerrar sesión"
          >
            logout
          </span>
        </div>
      </div>
    </aside>

    <!-- Contenedor principal de vistas -->
    <div class="lg:pl-72 flex flex-col min-h-screen">
      <RouterView />
    </div>
  </div>
</template>
