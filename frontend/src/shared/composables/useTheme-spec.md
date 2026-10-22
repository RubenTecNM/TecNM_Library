# useTheme

## Propósito

`useTheme` comparte modo claro u oscuro entre componentes Vue. Mantiene una única ref de módulo llamada `dark`.
Todas las llamadas a `useTheme()` reciben mismo estado mientras aplicación está cargada.

## Comportamiento

- Estado inicial usa `window.matchMedia('(prefers-color-scheme: dark)')`.
- `dark=true` asigna `data-theme="dark"` a `document.documentElement`.
- `dark=false` asigna `data-theme="light"`.
- Watch se ejecuta inmediatamente; tema queda aplicado al cargar módulo.
- Tokens de `global.css` responden a atributo `data-theme`.
- Estado no se guarda en cookies ni Web Storage. Recargar aplicación vuelve a preferencia del sistema.
- Cambios posteriores de preferencia del sistema no sustituyen elección activa. Agregar sincronización solo si producto lo requiere.

## Uso

```vue
<script setup lang="ts">
import { UiToggle } from '@/shared/components'
import { useTheme } from '@/shared/composables/useTheme'

const { dark } = useTheme()
</script>

<template>
  <UiToggle v-model="dark" type="switch" label="Modo oscuro" />
</template>
```

Usar `dark` directamente con `v-model`. No crear otra ref local ni modificar `data-theme` desde vistas.
MainLayout debe alojar control global de tema para conservarlo durante navegación.

## Límites

- Composable requiere navegador porque usa `window` y `document` al importar módulo.
- Si proyecto agrega SSR, proteger acceso al DOM y aplicar tema inicial desde servidor.
- Persistencia de preferencia queda fuera de alcance actual.
