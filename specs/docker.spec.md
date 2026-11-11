# Arranque Docker TecNM

## Contrato

- Un Compose con `frontend`, `backend` y `db`; proyecto predeterminado `tecnm-template`.
- Frontend Vue compilado con Node dentro de Docker y servido con Nginx HTTPS. `/api` se reenvía al backend.
- Backend .NET 10 compilado en Docker, runtime separado y HTTPS.
- PostgreSQL sin puerto publicado; comparte red `internal: true` únicamente con backend.
- Volumen `postgres_data` persistente; base `tecnm_template`, usuario `tecnm_app`.
- Puerto frontend 5173 y backend 7001, publicados solo en `127.0.0.1`; configurables por flags y `.env`.
- Certificado autofirmado y contraseña PostgreSQL generados fuera de Git.

## Inicialización SQL

- Requerir archivo regular `database.sql` en raíz antes de construir o arrancar servicios.
- Montarlo de solo lectura en `/docker-entrypoint-initdb.d/01-schema.sql`.
- La imagen PostgreSQL ejecuta ese SQL una vez durante la inicialización de un directorio de datos vacío.
- Archivo con solo comentarios es válido; no crea tablas de aplicación.
- No cargar semillas adicionales, comprobar tablas de negocio, usar `EnsureCreated` ni aplicar migraciones automáticas.
- Volumen existente: conservar datos y esquema, sin volver a aplicar SQL. Editar el archivo no migra una base existente.
- El equipo de cada microservicio rellena el SQL o adapta el mecanismo. Ver [guía de setup](../docs/setup.md).

## Script

`bash scripts/setup-dev.sh [--frontend-port N] [--backend-port N] [--project-name tecnm-nombre] [--check-ports]`.

- Requiere Docker Compose, Python 3 y OpenSSL; valida herramientas, daemon, nombre y puertos distintos entre 1 y 65535.
- Verifica puertos IPv4/IPv6; permite reutilizar los de sus propios contenedores.
- Puerto ocupado: avisa y propone alternativa. En terminal permite elegir; sin terminal termina con código 2. No mata procesos ni cambia puertos silenciosamente.
- `--check-ports`: solo comprueba puertos, sin escribir configuración ni cambiar contenedores.
- Preserva contraseña existente y ajustes ajenos en `.env`.
- Construye, repite comprobación de puertos e inicia servicios por healthchecks.
- Error Docker: muestra aviso y comando de logs; conserva volumen. No reintenta SQL ni repara inicializaciones parciales.

## Aceptación

1. Arranque con SQL de comentarios: tres servicios saludables, página pública y health check disponible.
2. SQL de un microservicio se carga en un volumen nuevo sin exigir tablas institucionales.
3. Reiniciar conserva datos; cambiar SQL no lo ejecuta de nuevo.
4. SQL ausente o directorio: fallo claro antes de crear configuración o contenedores.
5. Conservar comprobaciones de puertos y aislamiento de PostgreSQL.
