# Contexto frontend

## Skills obligatorias

Antes de proceder con cualquier indicación del usuario, intentar cargar estas skills:

1. `caveman`: respuestas y documentación concisas.
2. `ponytail`: implementación mínima, mantenible y sin sobreingeniería.
3. `frontend-design`: diseño visual intencional y coherente con identidad TecNM.
4. `ui-ux-pro-max`: consistencia UI/UX, accesibilidad y responsive.

Usar las cuatro durante trabajo frontend. Si alguna no existe o no puede cargarse, informar al usuario y preguntar si desea proceder sin ella. No iniciar cambios hasta recibir respuesta.

## Objetivo

Construir SPA Vue 3 con TypeScript. Primer slice: login local, guard preventivo, sesión visible y logout.

## Lectura obligatoria

1. [Arquitectura frontend](../FRONTEND_ARCHITECTURE.md)
2. [Estándar de autenticación](../AUTH.md)
3. [Contrato canónico de autenticación](../specs/auth.spec.md)
4. [Spec local de Auth](./src/modules/auth/specs/auth.spec.md)

## Reglas

- Aplicar SDD. Actualizar spec antes de código.
- Priorizar siempre componentes existentes en `src/shared/components/`. Buscar, reutilizar y componer antes de crear componente o CSS local.
- Extender componente compartido cuando necesidad sea genérica para varias vistas. Mantener lógica exclusiva dentro del módulo correspondiente.
- Usar `UiBasePage` como raíz de contenido en todas las vistas de página, públicas o autenticadas.
- Usar `UiBasePage` con `fluid=true` por defecto para ocupar ancho disponible de lado a lado.
- Usar modo centrado solo cuando usuario o spec lo indique, o cuando contenido requiera lectura estrecha tipo artículo o formulario compacto.
- Usar Vue 3, Composition API, `<script setup lang="ts">`, TypeScript y Vite.
- Organizar por vertical slice. Exponer API pública mediante `index.ts`.
- Mantener rutas del módulo en `routes.ts` y cargar vistas de forma diferida.
- Centralizar Axios e interceptores en `src/shared/api/`.
- Usar `withCredentials: true`. Nunca leer ni guardar `auth_token`.
- Usar `session_exp` solo como guard preventivo. API conserva autoridad.
- Prevenir dobles peticiones: toda acción debe ser única. Bloquear reentrancia en manejadores/composables (`if (isSubmitting.value) return;`) y deshabilitar controles durante el procesamiento (`loading`, `disabled`).
- Usar CSS nativo y tokens semánticos. Mantener formulario accesible y responsive.
- No agregar Pinia ni dependencias sin uso directo.
- Cambiar contrato compartido primero cuando cambie API, cookie, DTO o error.
- Código en inglés: componentes, composables, tipos, variables, archivos y rutas (`LoginForm.vue`, `useAuth`, `UserResponse`).
- Textos visibles al usuario en español de México (es-MX): etiquetas, títulos, botones, placeholders, mensajes de error y de estado (`"Credenciales incorrectas"`, `"Iniciar sesión"`).
- No mezclar idiomas en la misma cadena. No dejar texto placeholder en inglés en la UI.

## Comandos previstos

```bash
pnpm --prefix frontend install
pnpm --prefix frontend run dev -- --host
pnpm --prefix frontend run build
```

Verificación visual prevista: login, error genérico, carga, sesión, logout, redirección por expiración y responsive.

## Mapa

- [`src/app/`](./src/app/): arranque SPA y router agregador.
- [`src/shared/api/`](./src/shared/api/): Axios base e interceptor `401`.
- [`src/shared/styles/`](./src/shared/styles/): tokens y estilos globales.
- [`src/shared/composables/`](./src/shared/composables/): estado reactivo transversal; [spec de tema](./src/shared/composables/useTheme-spec.md).
- [`src/modules/auth/`](./src/modules/auth/): API, tipos, rutas y vistas del slice.
- [`src/modules/auth/specs/`](./src/modules/auth/specs/): contexto frontend de Auth.
- [Contrato raíz](../specs/auth.spec.md): única fuente de verdad compartida.

- [`src/shared/components/`](./src/shared/components/): biblioteca visual reutilizable; [spec](./src/shared/components/specs/components.spec.md).

- [`src/app/layouts/`](./src/app/layouts/MAINLAYOUT.md): MainLayout persistente; configuración independiente de header, sidebar, marca y navegación.
