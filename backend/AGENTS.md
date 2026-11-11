# Reglas de desarrollo backend

## Patrones de diseño

- Organizar por vertical slice: cada funcionalidad agrupa controller, servicio, DTOs y `specs/` en `Modules/<Feature>/`.
- Mantener controllers delgados: transporte HTTP, validación de entrada y códigos de respuesta. Encapsular reglas y consultas en servicios registrados mediante inyección de dependencias.
- Exponer DTOs en los contratos de API; no devolver entidades EF Core.
- Usar `Core/` solo para entidades realmente compartidas y `Data/` para persistencia y configuraciones EF Core.
- Mantener alta cohesión dentro de cada módulo y evitar dependencias innecesarias entre módulos.

## Especificaciones y documentación

- Aplicar SDD: actualizar la especificación correspondiente antes de cambiar comportamiento o contratos.
- Al preparar specs backend, verificar la disponibilidad de `grilling` y priorizarla para aclarar decisiones relevantes de negocio o contratos; omitir la entrevista si el cambio es simple y claro. Si falta, informar y seguir la guía de [instalación y uso](../CONTRIBUTING.md#skill-grilling); aclarar de todos modos las decisiones pendientes.
- Documentar requisitos, endpoints y criterios de aceptación en `specs/`, junto al módulo cuando corresponda.
- Reservar `AGENTS.md` para patrones y reglas de trabajo; no duplicar aquí contratos funcionales ni inventarios de funcionalidades.
- Consultar la [arquitectura backend](../BACKEND_ARCHITECTURE.md) y la [guía de setup](../docs/setup.md) al modificar estructura o persistencia.

## Implementación y persistencia

- Usar C# y .NET 10.
- Usar EF Core async y PostgreSQL. No agregar Repository sin necesidad real.
- Cero SQL en código (`raw SQL` / `FromSqlRaw`). Usar LINQ asíncrono; consultas complejas mediante vistas SQL mapeadas en EF Core.
- Acciones mutativas deben prevenir duplicados y aplicar idempotencia cuando corresponda.
- Conservar `ConnectionStrings__DefaultConnection` fuera de Git.
- `database.sql` en raíz pertenece al microservicio; mantenerlo alineado con entidades y estrategia de migraciones.
- Base de datos en `snake_case`; identificadores, archivos y rutas en inglés.
- Textos dirigidos al usuario en español de México. No devolver excepciones crudas.

## Validación

```bash
dotnet restore backend/TecNM.Api.csproj
dotnet build backend/TecNM.Api.csproj --no-restore
```

Verificar los criterios de aceptación de las specs afectadas. Con el backend en ejecución, usar `bash scripts/smoke-template.sh` para la comprobación HTTP básica.
