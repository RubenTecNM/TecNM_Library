import type { BrandOptions, NavigationItem } from '../../shared/components/navigation'

// Cambiar estas opciones por aplicación. Header y sidebar son independientes.
export const mainLayoutConfig = {
  showHeader: false,
  showSidebar: true,
  header: { title: 'TecNM', subtitle: 'Campus Monclova', showTitle: true, showLogo: false } satisfies BrandOptions,
  sidebar: { title: 'TecNM', subtitle: 'Campus Monclova', showTitle: true, showLogo: false } satisfies BrandOptions,
}

export const headerNavigation: NavigationItem[] = [
  { label: 'Inicio', to: '/' },
]

export const sidebarNavigation: NavigationItem[] = [
  { label: 'Inicio', to: '/' },
]
