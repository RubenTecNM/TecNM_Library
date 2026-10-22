# Auth backend

Contrato compartido: [spec raíz de autenticación](../../../../specs/auth.spec.md).

Este archivo añade responsabilidades backend. Contratos HTTP, DTOs, cookies y códigos viven solo en spec raíz.

## Responsabilidades

- `AuthController`: recibir HTTP, delegar lógica, escribir o eliminar cookies y devolver códigos acordados.
- `AuthService`: consultar usuario async con LINQ (sin raw SQL), rechazar usuario inactivo, validar hash y emitir JWT.
- `AuthService`: reconstruir usuario actual desde claims. No hacer segunda consulta en `/me`.
- `AuthDTOs`: definir entrada y salida sin filtrar entidad EF.
- `TecNMDbContext`: mapear usuarios y restricciones de persistencia.
- `Program`: registrar DI, DbContext, CORS, autenticación y autorización.

## Integración

- Leer `auth_token` mediante `JwtBearerEvents.OnMessageReceived`.
- Validar `iss`, `aud`, firma y expiración.
- Configurar CORS con origen frontend explícito y credenciales.
- Orden middleware: HTTPS, CORS, autenticación, autorización, controllers.
- Usar `PasswordHasher<User>`. Nunca comparar contraseña en texto plano.
- Fallar al iniciar si falta `Jwt__SecretKey` o no cumple fuerza mínima definida por implementación.

## Verificación local

- Probar service: credencial válida, contraseña inválida y usuario inactivo.
- Probar claims y expiración emitidos.
- Probar opciones de creación y eliminación de ambas cookies.
- Ejecutar casos compartidos desde [spec raíz](../../../../specs/auth.spec.md).
