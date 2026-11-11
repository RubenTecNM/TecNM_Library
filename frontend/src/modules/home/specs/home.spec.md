# Inicio del template

## Alcance

Página pública de bienvenida sin datos ni operaciones de negocio.

- `/` usa `MainLayout` persistente y `UiBasePage` con `fluid=true`.
- Mostrar título del proyecto y mensaje neutro; reutilizar componentes institucionales.
- Conservar navegación de inicio y selector de tema claro/oscuro.
- No realiza peticiones automáticas a APIs de dominio.
- Rutas de módulos se exportan por `index.ts` y se cargan de forma diferida.
- Textos en español de México; identidad TecNM y diseño responsive existentes.

## Aceptación

Compilación TypeScript/Vue correcta. Inicio público con título, mensaje de bienvenida y selector de tema. Layout funciona con header, sidebar, ambos o ninguno.
