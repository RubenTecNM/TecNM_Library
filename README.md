# TecNM Campus Monclova — Plantilla base de proyectos

Base agnóstica para aplicaciones web y microservicios institucionales. Incluye arquitectura modular, backend .NET 10 con EF Core/PostgreSQL, frontend Vue 3/TypeScript y componentes visuales TecNM.

Cada proyecto define su dominio, datos e integraciones. El template incluye una página pública de inicio, componentes reutilizables y un health check del backend.

## Arranque con Docker

Requisitos: Docker con Compose, Python 3 y OpenSSL. No requiere Node ni .NET en el host.

```bash
bash scripts/setup-dev.sh
```

| Servicio | Acceso predeterminado |
| --- | --- |
| `tecnm-template-frontend` | https://localhost:5173 |
| `tecnm-template-backend` | https://localhost:7001/api/health |
| `tecnm-template-postgres` | `db:5432`, solo en la red privada de datos |

Frontend y backend publican en `127.0.0.1`; el proxy frontend reenvía `/api` al backend. HTTPS usa un certificado local autofirmado generado en `.docker/certs/`; el navegador puede pedir aceptarlo.

```bash
bash scripts/setup-dev.sh --frontend-port 5180 --backend-port 7010
bash scripts/setup-dev.sh --frontend-port 5180 --backend-port 7010 --check-ports
docker compose ps
docker compose logs -f
docker compose stop
```

El script guarda puertos y contraseña PostgreSQL en `.env`. `--project-name tecnm-mi-servicio` permite separar contenedores y volumen por proyecto. Los conflictos de puertos se reportan antes de construir o arrancar.

## Base de datos de cada microservicio

El setup carga PostgreSQL desde **[`database.sql`](database.sql) en la raíz**, mediante el inicializador de la imagen PostgreSQL. El archivo incluido solo tiene comentarios: no crea tablas ni datos.

**Cada equipo debe completar ese SQL o modificar el mecanismo de inicialización** según su microservicio. El backend incluye un DbContext sin entidades para extenderlo con el modelo propio.

El SQL se ejecuta únicamente al inicializar un volumen nuevo. Editarlo y repetir el setup no modifica una base existente: esos cambios requieren la estrategia de migraciones elegida por el proyecto. El volumen `postgres_data` conserva los datos entre reinicios.

Consultar [documentación del setup](docs/setup.md) para opciones, inicialización, errores SQL y persistencia.

## Desarrollo y verificación

```bash
# Con el stack activo:
API_URL=https://localhost:7001 bash scripts/smoke-template.sh

# Comprobaciones locales:
python3 scripts/check-dev-ports.py
python3 scripts/check-setup.py
npm --prefix frontend ci
npm --prefix frontend run build
(cd frontend && node scripts/check-layout.mjs)
dotnet build backend/TecNM.Api.csproj
```

Para ejecutar sin Docker, consultar los `.env.example` de backend/frontend. La ejecución manual del backend requiere una conexión PostgreSQL propia; el contenedor de base de datos no publica puerto.

## Arquitectura y contribución

- [Reglas compartidas de desarrollo](AGENTS.md): punto de entrada desde la raíz; complementa las reglas locales de backend y frontend.
- [Guía de contribución](CONTRIBUTING.md): flujo ODD con SDD, verificaciones por alcance y contribuciones desde un fork.
- [Alcance del template](specs/template.spec.md).
- [Arquitectura backend](BACKEND_ARCHITECTURE.md) y [reglas de desarrollo backend](backend/AGENTS.md).
- [Arquitectura frontend](FRONTEND_ARCHITECTURE.md) y [reglas de desarrollo frontend](frontend/AGENTS.md).
- [Sistema de diseño](frontend/DESIGN.md) y [componentes compartidos](frontend/src/shared/components/specs/components.spec.md).
- [Layout persistente](frontend/src/app/layouts/mainLayout.spec.md), [tema](frontend/src/shared/composables/useTheme.spec.md), [inicio](frontend/src/modules/home/specs/home.spec.md) y [página 404](frontend/src/shared/views/specs/notFound.spec.md).
- [Contrato Docker](specs/docker.spec.md) y [health check](specs/health.spec.md).

Aplicar SDD: actualizar la especificación correspondiente antes de modificar comportamiento o contratos. Documentar funcionalidades y criterios de aceptación en `specs/`; mantener los `AGENTS.md` centrados en patrones de diseño y reglas de desarrollo.

Convenciones: objetos PostgreSQL en `snake_case`; código, rutas y archivos en inglés; interfaz, errores y documentación en español de México. Reutilizar componentes antes de crear controles o estilos locales.

Leer primero el `AGENTS.md` raíz y después el de cada área afectada. Para cambios transversales, revisar ambos.
