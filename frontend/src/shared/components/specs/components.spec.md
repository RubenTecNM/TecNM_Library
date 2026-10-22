# Componentes institucionales

## Propósito y fuentes

Esta carpeta contiene biblioteca UI compartida del frontend. Toda vista debe reutilizar estos componentes antes de crear estilos o controles locales.

Fuentes visuales obligatorias:

- `frontend/DESIGN.md`: colores, tipografía, espaciado, geometría, elevación y temas.
- `frontend/dummy/index.html`: referencia visual interactiva.
- `frontend/src/modules/auth/views/SessionView.vue`: catálogo integrado con componentes reales.
- `frontend/src/shared/styles/global.css`: tokens y estilos comunes.

Conservar identidad TecNM, soporte claro/oscuro y CSS nativo. No agregar dependencias para comportamiento cubierto por Vue, HTML o CSS.

## Uso obligatorio

- Importar componentes desde `frontend/src/shared/components/index.ts`.
- Buscar primero un componente existente. Extender API genérica cuando varias vistas requieran mismo comportamiento.
- No copiar estructura o CSS de un componente compartido dentro de una vista.
- Usar props tipadas para configuración, slots para contenido y eventos o `v-model` para estado controlado.
- Mantener labels visibles, foco visible, controles de al menos 44 px y semántica HTML nativa.
- Verificar responsive desde 375 px, temas claro/oscuro y `prefers-reduced-motion`.
- No crear abstracciones para un solo caso si composición de componentes existentes resuelve necesidad.

## Página base

Todas las vistas de página, públicas o autenticadas, deben usar `UiBasePage` como contenedor de contenido raíz.

```vue
<UiBasePage fluid title="Bienvenida" description="Tu plataforma institucional">
  <UiCard title="Contenido">...</UiCard>
</UiBasePage>
```

- `fluid=true`: opción prioritaria. Ocupa todo ancho disponible junto al shell, sin límite adicional en pantallas ultraanchas.
- `fluid=false`: centra contenido y limita ancho a 960 px.
- `--page-max-width`: cambia límite del modo centrado. Ejemplo: `style="--page-max-width: 1200px"`.
- `title` y `description`: generan encabezado mediante `UiPageHeader`.
- Slot `header`: reemplaza encabezado completo.
- Slot `actions`: agrega acciones al encabezado predeterminado.
- `UiBasePage` no crea otro `main`. Layout propietario debe aportar landmark principal.
- Usar modo centrado solo cuando requerimiento solicite lectura estrecha, formulario compacto o contenido tipo artículo.

`SessionView` usa `fluid=true` y demuestra ancho completo.

## Catálogo y contratos

### Acciones y selección

- `UiButton`: `variant="primary|accent|secondary|danger"`, `loading`, `disabled`, `type`. Contenido mediante slot. Tipo predeterminado: `button`.
- `UiChip`: `pressed` y evento `click`. Vista controla selección.
- `UiToggle`: `v-model` boolean, `label`, `type="checkbox|switch"`.
- `UiRadio`: `v-model` string, `value`, `name`, `label`.
- `UiRange`: `v-model` number, `label`, `min`, `max`; acepta atributos nativos como `step`.

### Formularios y feedback

- `UiField`: `v-model` string, `label`, `error`, `hint`, `as="input|select|textarea"`.
- `UiField.options`: arreglo `{ value, label }[]` para select. Slot `options` permite opciones personalizadas.
- `UiField` reenvía atributos nativos al control y expone método `focus()`.
- `UiAlert`: `tone="success|warning|danger|info"`, `title` y contenido mediante slot.
- `UiToast`: expone `show(texto)` mediante ref. Muestra aviso durante cuatro segundos en región accesible.
- `UiDialog`: `v-model` boolean, `title`, slot principal y slot `actions`. Escape cierra y foco vuelve al elemento previo.

### Contenido y datos

- `UiCard`: `title`, `description`, `metric`, `elevation="card|floating"`; slots principal y `header`.
- `UiBadge`: `tone="success|warning|danger|info|purple"`.
- `UiMetric`: `label`, `value`, `description`.
- `UiCallout`: `title` y contenido mediante slot.
- `UiTable`: `label`, `columns: { key, label }[]`, `rows` con `id`, `selected` opcional.
- Slots `cell-<key>` de `UiTable` reciben `row` y `value`.
- `UiColorPalette`: `tokens: { token, label }[]`, `theme`, `compact`. Lee valores del tema CSS activo.
- `UiDisclosure`: `title` y contenido desplegable.
- `UiDivider`: separador semántico.
- `UiTypeSample`: contenedor de muestra tipográfica.
- `UiText`: `as`, `variant="default|body|display|caption|eyebrow"`.
- `UiPageHeader`: `title`, `description`, `version`, `eyebrow` y slot de acciones.
- `UiLayout`: `kind="stack|grid|row|fields"`, `as` para elemento semántico.

Ejemplo mínimo:

```vue
<script setup lang="ts">
import { ref } from 'vue'
import { UiBasePage, UiButton, UiCard, UiField } from '@/shared/components'

const name = ref('')
</script>

<template>
  <UiBasePage fluid title="Proyecto">
    <UiCard title="Datos generales">
      <UiField v-model="name" label="Nombre" required />
      <UiButton>Guardar cambios</UiButton>
    </UiCard>
  </UiBasePage>
</template>
```

## Layout persistente

- `MainLayout` vive en ruta padre autenticada. `RouterView` cambia únicamente contenido. Login queda fuera.
- `UiShell` acepta `showHeader` y `showSidebar`; permite ambos, cualquiera o ninguno.
- `UiHeader` y `UiSidebar` son independientes. Ambos aceptan `showTitle`, `showLogo`, `title`, `subtitle` y `logo`.
- Logo predeterminado: `shared/assets/tecnm-isologo.svg`.
- Navegación acepta enlaces `{ label, to }` y grupos `{ label, children }` sin destino propio.
- `to` acepta cualquier `RouteLocationRaw` de Vue Router.
- Desplegables funcionan con teclado; Escape cierra grupo. Estado lateral permanece entre páginas hijas.
- Configuración y guía completa: `frontend/src/app/layouts/MAINLAYOUT.md`.

## Barra lateral en escritorio

- Sidebar queda al borde izquierdo de ventana.
- Usa `position: sticky`, altura de viewport y desplazamiento propio cuando navegación desborda.
- En móvil vuelve al flujo normal y usa altura natural.
- `UiShell` no limita ancho de página. Cada vista decide mediante `UiBasePage`.

## Integración actual

- `LoginView`: acceso institucional, validación, estados de carga y errores.
- `SessionView`: datos reales de usuario, logout y catálogo de componentes.
- `MainLayout`: navegación persistente y tema.
- No almacenar JWT en componentes. Auth conserva contrato de cookies y API.

## Verificación

- Ejecutar `npm --prefix frontend run build`.
- Ejecutar `node scripts/check-layout.mjs` desde `frontend` para validar combinaciones de shell y navegación.
