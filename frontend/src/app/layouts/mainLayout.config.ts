import type { BrandOptions, NavigationItem } from '../../shared/components/navigation'

// Cambiar estas opciones por aplicación. Header y sidebar son independientes.
export const mainLayoutConfig = {
  showHeader: false,
  showSidebar: true,
  header: { title: 'TecNM', subtitle: 'Campus Monclova', showTitle: true, showLogo: false } satisfies BrandOptions,
  sidebar: { title: 'TecNM', subtitle: 'Plataforma institucional', showTitle: true, showLogo: false } satisfies BrandOptions,
}

export const headerNavigation: NavigationItem[] = [
  { label: 'Inicio', to: '/' },
  { label: 'Componentes', children: [
    { label: 'Paleta', to: '/#colores' },
    { label: 'Controles', to: '/#controles' },
    { label: 'Mensajes', to: '/#mensajes' },
  ] },
  { label: 'Ejemplo de datos', to: '/#datos' },
]

export const sidebarNavigation: NavigationItem[] = [
  { label: 'Mi cuenta', to: '/#cuenta' },
  { label: 'Biblioteca visual', children: [
    { label: 'Colores', to: '/#colores' },
    { label: 'Botones', to: '/#botones' },
    { label: 'Controles', to: '/#controles' },
    { label: 'Mensajes y estados', to: '/#mensajes' },
  ] },
  { label: 'Datos y presentación', children: [
    { label: 'Tarjetas y datos', to: '/#datos' },
    { label: 'Tabla', to: '/#tabla' },
    { label: 'Tipografía', to: '/#tipografia' },
    { label: 'Elevación', to: '/#elevacion' },
  ] },
]
