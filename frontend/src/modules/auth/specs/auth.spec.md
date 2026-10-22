# Auth frontend

Contrato compartido: [spec raíz de autenticación](../../../../../specs/auth.spec.md).

Este archivo añade responsabilidades frontend. Contratos HTTP, DTOs, cookies y códigos viven solo en spec raíz.

## Responsabilidades

- `shared/api/http.ts`: configurar URL, `withCredentials` e interceptor `401`.
- Interceptor: limpiar `session_exp` y navegar a `/login` en peticiones protegidas. No interceptar login como sesión vencida.
- `authApi.ts`: exponer `login`, `logout` y `me` con tipos.
- `routes.ts`: declarar `/login` pública y `/` protegida con lazy loading.
- Guard: analizar `session_exp`; redirigir si falta, no es timestamp válido o venció.
- `LoginView`: formulario accesible, validación básica, carga y error genérico.
- `SessionView`: obtener `/me`, mostrar usuario y permitir logout con componentes y tokens institucionales.
- `index.ts`: exponer solo rutas y contratos requeridos fuera del slice.

## Estado y seguridad

- No guardar JWT en memoria, Web Storage ni estado global.
- No inferir autorización desde `session_exp`.
- Evitar Pinia. Estado local basta para dos vistas.
- Prevenir dobles peticiones: bloquear reentrancia en submit y logout con guardas tempranas (`isSubmitting`, `isLoggingOut`).
- Borrar marca local aunque logout falle por red o sesión ausente.
- Evitar redirección circular cuando login devuelve `401`.

## Verificación local

- Probar guard con cookie ausente, inválida, vigente y vencida.
- Probar interceptor `401` protegido y excepción de login.
- Probar estados de formulario: inicial, envío, error y éxito.
- Ejecutar flujo visual y casos compartidos desde [spec raíz](../../../../../specs/auth.spec.md).

## Contrato de interfaz

- Usar diseño exacto de `frontend/DESIGN.md` y `frontend/dummy/index.html`, incluidos temas claro y oscuro.
- `LoginView` muestra únicamente acceso institucional mediante `LoginForm`.
- `SessionView` muestra bienvenida, datos reales de `/me`, logout y catálogo de componentes tras iniciar sesión.
- Identidad visible: TecNM, Tecnológico Nacional de México, Campus Monclova.
- Mantener labels visibles, `autocomplete="username"` y `autocomplete="current-password"`; permitir pegado y administradores de contraseñas.
- Comunicar validación, carga y errores mediante texto claro y una región `aria-live`.
- Todos los controles interactivos miden al menos 44 px y muestran foco visible de 2 px.
- La composición funciona desde 375 px y respeta `prefers-reduced-motion`.
- Vite sirve desarrollo por HTTPS en `https://localhost:5173` para aceptar cookies `Secure`.

## Integración con layout

- Exportar rutas públicas y autenticadas por separado; router raíz agrega MainLayout como padre protegido.
- SessionView contiene bienvenida y catálogo, sin header/sidebar propios.
- LogoutButton expuesto por Auth para acción persistente del layout; conserva cierre local incluso si falla API.

- SessionView compone bienvenida y catálogo dentro de UiBasePage en modo fluid, aprovechando ancho disponible junto a sidebar.
