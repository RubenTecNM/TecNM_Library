# Reglas de desarrollo frontend

## Patrones de diseño

- Usar Vue 3, Composition API, `<script setup lang="ts">`, TypeScript y Vite.
- Organizar por vertical slice: cada módulo reúne sus vistas, componentes, composables, tipos, clientes HTTP y `specs/` según necesite.
- Exponer la API pública del módulo mediante `index.ts`; evitar importar detalles internos desde otros módulos.
- Mantener rutas del módulo en `routes.ts` y cargar vistas de forma diferida desde el router agregador.
- Mantener estado y lógica específicos dentro del módulo. Usar `shared/` para comportamiento realmente transversal.
- Centralizar la instancia Axios y el tratamiento HTTP común en `src/shared/api/`; ubicar llamadas de dominio en el módulo correspondiente.
- Favorecer composición: props tipadas para configuración, slots para contenido y eventos o `v-model` para estado controlado.

## Especificaciones y documentación

- Aplicar SDD: actualizar la especificación correspondiente antes de cambiar comportamiento o contratos.
- Al preparar specs frontend, verificar la disponibilidad de `grilling` y priorizarla para aclarar decisiones relevantes de producto, flujos o contratos; omitir la entrevista si el cambio es simple y claro. Si falta, informar y seguir la guía de [instalación y uso](../CONTRIBUTING.md#skill-grilling); aclarar de todos modos las decisiones pendientes.
- Documentar requisitos, flujos y criterios de aceptación en specs cercanas al código; usar nombres `*.spec.md`.
- Reservar `AGENTS.md` para patrones y reglas de trabajo; no duplicar aquí contratos funcionales ni inventarios de funcionalidades.
- Consultar la [arquitectura frontend](../FRONTEND_ARCHITECTURE.md) al cambiar estructura y el [sistema de diseño](./DESIGN.md) al modificar UI.

## Componentes e interfaz

- Buscar y reutilizar componentes de `src/shared/components/` antes de crear controles o CSS locales. Extender su API cuando la necesidad sea compartida por varias vistas.
- Evitar duplicar estructura o estilos de componentes existentes; mantener lógica exclusiva en el módulo correspondiente.
- Usar `UiBasePage` como raíz del contenido de las páginas dentro del layout, con `fluid=true` por defecto. Usar modo centrado cuando lo requiera la spec o el contenido.
- Usar CSS nativo y tokens semánticos; conservar coherencia visual TecNM y soporte claro/oscuro.
- Mantener semántica HTML, etiquetas visibles, navegación por teclado, foco visible y diseño responsive desde 375 px. Respetar `prefers-reduced-motion`.
- Prevenir envíos duplicados: bloquear reentrancia en operaciones asíncronas mutativas y deshabilitar controles mientras se procesan.
- No agregar gestión global de estado ni dependencias sin uso directo que lo justifique.

## Convenciones

- Escribir identificadores, componentes, composables, tipos, archivos y rutas en inglés.
- Escribir textos visibles al usuario en español de México (es-MX), sin mezclar idiomas en una misma cadena.
- Usar rutas de importación compatibles con la configuración real de TypeScript y Vite; no asumir alias inexistentes.
- Mantener credenciales y configuración sensible fuera de Git.

## Validación

Ejecutar desde la raíz del repositorio:

```bash
npm --prefix frontend run build
(cd frontend && node scripts/check-layout.mjs)
```

Verificar los criterios de aceptación de las specs afectadas. Para cambios visuales, revisar responsive, accesibilidad y ambos temas.
