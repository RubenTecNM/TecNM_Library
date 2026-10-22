# Estándar de Autenticación y Gestión de Sesiones

## Visión General
El sistema utiliza autenticación basada en **JWT (JSON Web Token)** firmado y gestionado exclusivamente por el backend, transportado mediante cookies de navegador seguras.

---

## 1. Mecanismo de Almacenamiento y Cookies

El backend emite dos cookies tras una autenticación exitosa:

| Cookie | Tipo | Propósito |
| :--- | :--- | :--- |
| `auth_token` | `HttpOnly`, `Secure`, `SameSite=Lax` | JWT firmado con `SecretKey`. Inaccesible por JavaScript (protección anti-XSS). |
| `session_exp` | No-`HttpOnly`, `Secure`, `SameSite=Lax` | Timestamp Unix de expiración. Leído por Vue Router para UX preventiva. |

---

## 2. Ciclo de Vida de la Sesión

- **Duración Fija:** Tiempo de vida estándar (ej. 8 horas) sin *Refresh Token*.
- **Expiración:** Al vencer el tiempo, el token es inválido y el usuario debe iniciar sesión nuevamente.
- **Cierre de Sesión:** Endpoint `POST /api/auth/logout` invalida y elimina las cookies en el cliente.

---

## 3. Proveedores de Identidad (Autoridad Unificada)

El backend actúa como el único emisor de tokens institucionales, soportando múltiples métodos de acceso:

1. **Credenciales Locales (Usuario / Contraseña):**
   - Validación de hash en base de datos.
   - Emisión directa de cookies con JWT institucional.

2. **Federación OAuth / OIDC (Microsoft Entra ID, Google):**
   - El proveedor autentica y redirige al callback del backend.
   - Backend valida firma externa y busca/aprovisiona al usuario en BD local.
   - Backend emite las **mismas cookies con JWT institucional**.
   - *Resultado:* El resto del sistema (módulos backend y frontend) opera de forma idéntica sin importar el origen del usuario.

---

## 4. Responsabilidades por Capa

### Backend (.NET 10)
- **Firma & Secreto:** Custodia `SecretKey` (HMAC-SHA256).
- **Claims Estándar:** `sub` (UserId), `email`, `name`, `role`, `exp`, `iss`, `aud`.
- **Validación:** Middleware de autenticación valida firma en cada endpoint protegido.
- **Respuestas:** Retorna `401 Unauthorized` si el token falta, expiró o está alterado.
- **Idempotencia y Unicidad:** Endpoints como logout son estrictamente idempotentes. Las acciones mutativas garantizan ejecución única frente a reintentos o llamadas concurrentes.

### Frontend (Vue 3 + TypeScript)
- **Transporte:** Cliente HTTP (`shared/api/`) configurado con `withCredentials: true`.
- **Interceptor 401:** Captura respuestas `401` en peticiones protegidas, limpia estado local y redirige a `/login`.
- **Router Guards:** Valida la presencia y vigencia de `session_exp` antes de renderizar rutas protegidas.
- **Prevención de Doble Envío:** Formularios y acciones (login, logout) implementan guardas de reentrancia y deshabilitan botones/controles durante el procesamiento para evitar peticiones duplicadas.
