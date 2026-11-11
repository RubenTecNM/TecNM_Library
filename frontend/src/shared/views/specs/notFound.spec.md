# Vista 404: Página no encontrada

## Propósito

Capturar rutas no coincidentes en la aplicación y proveer navegación de retorno al usuario.

## Requisitos

- Componente: `NotFoundView.vue`.
- Ruta en router: `/:pathMatch(.*)*`.
- Acceso: público.
- Contenedor: diseño autocontenido con encabezado institucional, selector de tema y pie de página.
- Componentes UI compartidos: `UiCard`, `UiPageHeader`, `UiButton`, `UiText`, `UiToggle`.
- Textos (es-MX):
  - Título: `404 · Página no encontrada`
  - Descripción: `La ruta solicitada no existe, fue movida o no está disponible.`
  - Botón: `Volver al inicio` -> redirige a `/`
- Soporte: tema claro y oscuro reactivo (`useTheme`), responsive móvil (375 px a escritorio).
