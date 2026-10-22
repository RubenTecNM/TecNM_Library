# Plan de implementación: plantilla TecNM con autenticación local

## 1. Alcance

Se crearán dos proyectos independientes en `backend/` y `frontend/`, siguiendo las arquitecturas vertical slice documentadas en este repositorio.

La prueba funcional será un flujo de autenticación local completo:

1. PostgreSQL valida un usuario sembrado.
2. La API emite `auth_token` y `session_exp` como cookies.
3. Vue protege la ruta privada con `session_exp`.
4. La API valida el JWT de `auth_token` en cada petición protegida.
5. El cierre de sesión elimina ambas cookies.

No se implementarán OAuth/OIDC, refresh tokens, registro, recuperación de contraseña, Pinia ni librerías que el ejemplo no use. Son extensiones futuras, no requisitos de esta prueba.

## 2. Estructura objetivo

```text
.
├── database.sql
├── specs/
│   └── auth.spec.md                 # Contrato compartido y fuente de verdad
├── backend/
│   ├── AGENTS.md
│   ├── TecNM.Api.csproj
│   ├── Program.cs
│   ├── appsettings.json
│   ├── appsettings.Development.json
│   ├── Core/
│   │   └── Entities/
│   │       └── User.cs
│   ├── Data/
│   │   └── TecNMDbContext.cs
│   ├── Modules/
│   │   └── Auth/
│   │       ├── specs/
│   │       │   └── auth.spec.md     # Reglas backend y enlace al contrato raíz
│   │       ├── AuthController.cs
│   │       ├── AuthService.cs
│   │       └── AuthDTOs.cs
│   └── Properties/
│       └── launchSettings.json
└── frontend/
    ├── AGENTS.md
    ├── .env.example
    ├── index.html
    ├── package.json
    ├── tsconfig.json
    ├── vite.config.ts
    └── src/
        ├── app/
        │   ├── App.vue
        │   ├── main.ts
        │   └── router/
        │       └── index.ts
        ├── modules/
        │   └── auth/
        │       ├── specs/
        │       │   └── auth.spec.md # Reglas frontend y enlace al contrato raíz
        │       ├── api/
        │       │   └── authApi.ts
        │       ├── types/
        │       │   └── auth.ts
        │       ├── views/
        │       │   ├── LoginView.vue
        │       │   └── SessionView.vue
        │       ├── routes.ts
        │       └── index.ts
        └── shared/
            ├── api/
            │   └── http.ts
            └── styles/
                └── global.css
```

Los directorios opcionales descritos en `FRONTEND_ARCHITECTURE.md` se crearán cuando exista código que alojar. No se agregarán carpetas vacías.

## 3. Orden de trabajo SDD

### Fase 1: contexto y especificación

1. Crear `backend/AGENTS.md` con objetivo, comandos, reglas .NET, mapa de `Core/`, `Data/` y `Modules/Auth/`.
2. Crear `frontend/AGENTS.md` con objetivo, comandos, reglas Vue/TypeScript y mapa de `src/app`, `src/shared` y `src/modules/auth`.
3. Redactar primero `specs/auth.spec.md` con contratos compartidos, endpoints, cookies, casos de error y usuarios demo.
4. Crear las especificaciones locales de cada slice. Solo referencian el contrato compartido y añaden responsabilidades propias; no duplican contratos.
5. Registrar cada especificación y módulo en el `AGENTS.md` correspondiente.

Ningún archivo C#, Vue o TypeScript se escribirá antes de completar esta fase.

### Fase 2: base de datos local

Crear `database.sql` idempotente con:

- Tabla `users`.
- Columnas `id UUID`, `username`, `email`, `password`, `name`, `role`, `is_active` y `created_at`.
- Llaves únicas para `username` y `email`.
- Restricciones `NOT NULL` y validación básica de `role`.
- Dos usuarios demo activos: `admin` con rol `Admin` y `usuario` con rol `User`.
- Hashes compatibles con `PasswordHasher<User>`; nunca contraseñas en texto plano dentro de la tabla.

Carga prevista:

```bash
sudo -u postgres createdb tecnm_template
sudo -u postgres psql -d tecnm_template -f database.sql
```

Antes de crear la base se comprobará si ya existe. Si existe, solo se aplicará el SQL idempotente. La conexión de la API se pasará mediante `ConnectionStrings__DefaultConnection`; no se guardará una contraseña real en Git.

### Fase 3: backend .NET 10

Crear API mínima con controladores y únicamente estos paquetes directos:

- `Microsoft.AspNetCore.Authentication.JwtBearer`
- `Microsoft.Extensions.Identity.Core`
- `Microsoft.EntityFrameworkCore.Design`
- `Npgsql.EntityFrameworkCore.PostgreSQL`

`Program.cs` configurará:

- Controllers y DI.
- `TecNMDbContext` con PostgreSQL.
- CORS con origen frontend explícito y credenciales.
- JWT HMAC-SHA256 con `iss`, `aud`, firma y expiración obligatorios.
- `JwtBearerEvents.OnMessageReceived` para leer JWT desde cookie `auth_token`.
- Orden de middleware: HTTPS, CORS, autenticación, autorización y controllers.
- `AuthService` y `PasswordHasher<User>`.

El módulo `Modules/Auth/` contendrá:

- `AuthController`: transporte HTTP, cookies y códigos de estado.
- `AuthService`: consulta async, validación de hash, creación de claims/JWT y lectura del usuario actual.
- `AuthDTOs`: requests y responses; ninguna entidad EF saldrá por la API.

Endpoints:

```text
POST /api/auth/login   público; valida credenciales, crea cookies, devuelve usuario
POST /api/auth/logout  público e idempotente; elimina cookies, devuelve 204
GET  /api/auth/me      protegido; devuelve claims del usuario, o 401
```

Cookies:

- `auth_token`: `HttpOnly`, `Secure`, `SameSite=Lax`, `Path=/`, duración fija de 8 horas.
- `session_exp`: accesible desde JavaScript, `Secure`, `SameSite=Lax`, `Path=/`, misma expiración.
- Desarrollo ejecutará API y Vite con HTTPS para conservar `Secure=true`.
- Logout usará las mismas opciones de ruta y seguridad al eliminar cookies.

Configuración:

- `Jwt:Issuer`, `Jwt:Audience` y `Jwt:LifetimeHours` en `appsettings.json`.
- `Jwt__SecretKey` y conexión PostgreSQL mediante variables de entorno o user-secrets.
- La API fallará al iniciar si falta o es débil el secreto JWT.

### Fase 4: frontend Vue 3 + Vite

Crear SPA TypeScript con `npm create vite` y solo dependencias usadas:

- `vue-router`
- `axios`
- Soporte HTTPS mínimo para Vite si el certificado local no puede reutilizarse directamente.

No se instalarán Chart.js, SheetJS, jsPDF, Lucide ni Pinia porque el login no los usa.

Implementación:

- `shared/api/http.ts`: cliente Axios con `withCredentials: true`, URL configurable e interceptor de respuestas `401`.
- El interceptor borra `session_exp` y lleva a `/login`, excepto cuando la petición ya corresponde al login.
- `modules/auth/api/authApi.ts`: funciones `login`, `logout` y `me`.
- `modules/auth/routes.ts`: `/login` pública y `/` protegida, ambas con lazy loading.
- Router raíz: agrega rutas exportadas por el módulo.
- Guard: analiza `session_exp`; una marca ausente, inválida o vencida redirige a `/login`.
- `LoginView.vue`: formulario accesible, estado de carga, error de credenciales y envío funcional.
- `SessionView.vue`: muestra usuario obtenido desde `/me` y permite cerrar sesión.
- CSS nativo con tokens semánticos básicos y diseño responsive.

El frontend nunca leerá ni guardará `auth_token`.

## 4. Contrato que fijará `specs/auth.spec.md`

### DTOs

```text
LoginRequest
  username: string, requerido, sin espacios externos
  password: string, requerido

UserResponse
  id: UUID
  username: string
  email: string
  name: string
  role: "Admin" | "User"
```

`POST /api/auth/login` devolverá `200 UserResponse`, `400` para payload inválido y `401` para credenciales incorrectas o usuario inactivo. El mensaje `401` será genérico para no revelar cuentas existentes.

`GET /api/auth/me` devolverá `200 UserResponse` o `401`.

`POST /api/auth/logout` devolverá siempre `204` y cookies expiradas.

Claims JWT: `sub`, `email`, `name`, `role`, `exp`, `iss` y `aud`. Se añadirá `username` para reconstruir `UserResponse` sin una segunda consulta en `/me`.

Las credenciales demo se documentarán como datos exclusivos de desarrollo. La contraseña común se elegirá al implementar y sus hashes se generarán con el hasher real de .NET.

## 5. Verificación

### Comprobaciones automáticas

```bash
dotnet restore backend/TecNM.Api.csproj
dotnet build backend/TecNM.Api.csproj --no-restore
npm --prefix frontend install
npm --prefix frontend run build
```

Se añadirá una sola prueba de humo ejecutable con `curl` para cubrir el camino crítico:

1. Login inválido devuelve `401`.
2. Login válido devuelve `200` y ambas cookies.
3. `/me` con cookie devuelve usuario esperado.
4. Logout devuelve `204`.
5. `/me` después de logout devuelve `401`.

También se comprobarán los usuarios directamente en PostgreSQL y el flujo visual en navegador.

## 6. Criterios de aceptación

- Estructura coincide con `BACKEND_ARCHITECTURE.md` y `FRONTEND_ARCHITECTURE.md`.
- Cada proyecto tiene `AGENTS.md` actualizado.
- Especificaciones existen antes del código y son fuente de verdad.
- Login usa PostgreSQL y hash seguro, no usuarios codificados en C#.
- JWT solo viaja en cookie `auth_token` `HttpOnly`.
- `session_exp` solo ayuda al guard; backend conserva autoridad final.
- Los tres endpoints cumplen contratos y códigos documentados.
- Frontend usa credenciales, maneja `401` y protege ruta privada.
- Backend compila, frontend construye y prueba de humo pasa.
- Base PostgreSQL local queda cargada con usuarios demo.

## 7. Decisiones deliberadamente mínimas

- SQL inicial en vez de migraciones EF para esta prueba, porque `database.sql` es requisito explícito.
- Axios solo porque se pidió interceptor; `fetch` no ofrece interceptores nativos.
- Sin store global: dos vistas no justifican Pinia.
- Sin capas Repository o interfaces de una sola implementación.
- Sin proveedores federados hasta que exista configuración y requisito de integración.
