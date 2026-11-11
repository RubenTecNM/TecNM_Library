# Proyecto Web Backend

## Descripción
**Proyecto Web Backend** es una API RESTful desarrollada sobre el ecosistema .NET. Es una base agnóstica para incorporar la lógica y persistencia de cada microservicio mediante una arquitectura modular. Incluye health check y un DbContext sin entidades.

---

## Tecnologías Principales (Nivel Raíz)
- **Lenguaje y Runtime:** C# / .NET 10
- **Framework Web:** ASP.NET Core Web API
- **ORM / Persistencia:** Entity Framework Core 10
- **Base de Datos:** PostgreSQL (mediante Npgsql Entity Framework Core Provider)
- **Inyección de Dependencias & Configuración:** Contenedor nativo de .NET (`Microsoft.Extensions.DependencyInjection` / `Microsoft.Extensions.Configuration`)
- **Entorno de Ejecución:** Contenedores Linux / Docker

---

## Arquitectura Estructural (Vertical Slice / Screaming Architecture)

El proyecto organiza su código en función de capacidades y dominios de negocio (*Screaming Architecture*), en lugar de capas técnicas globales. Cada funcionalidad se encapsula en una rebanada vertical (*Vertical Slice*) independiente que incluye sus propias especificaciones bajo el enfoque **SDD (Spec-Driven Development)**.

```text
Proyecto Web Backend/
│
├── Core/
│   └── Entities/                     # Entidades de dominio compartidas (POCOs / Mapeo EF Core)
│
├── Data/
│   └── [App]DbContext.cs             # Configuración del DbContext y mapeo relacional
│
├── Modules/                          # Vertical Slices (Módulos por dominio de negocio)
│   ├── [FeatureModule]/              # Rebanada vertical de un dominio específico
│   │   ├── specs/                    # Especificaciones funcionales, requerimientos y SDD del módulo
│   │   ├── [Feature]Controller.cs    # Thin Controller: enrutamiento HTTP y códigos de respuesta
│   │   ├── [Feature]Service.cs       # Fat Service: lógica de negocio, validaciones y persistencia
│   │   └── [Feature]DTOs.cs          # Contratos de datos (Requests y Responses)
│   └── ...
├── Properties/                       # Perfiles de inicialización y configuración de runtime
├── appsettings.json                  # Configuración de variables de entorno y conexión
└── Program.cs                        # Punto de entrada, configuración de middleware y registro DI
```

### Principios de la Estructura
- **Spec-Driven Development (SDD):** Cada módulo contiene su carpeta `specs/` donde se definen reglas funcionales, contratos y criterios antes de la codificación o asistencia por IA.
- **Thin Controllers:** Responsabilidad única de transporte HTTP; sin lógica de negocio.
- **Fat Services:** Encapsulamiento completo de reglas de negocio, transacciones y consultas LINQ asíncronas.
- **Cero SQL en Código y Uso de Vistas de BD:** Prohibido escribir sentencias SQL en crudo (`raw SQL`, `FromSqlRaw` o cadenas embebidas) en el código. Las consultas estándar se realizan con LINQ asíncrono sobre EF Core. Las consultas complejas (múltiples joins, agregaciones pesadas, reportes) deben encapsularse en **Vistas de Base de Datos** (`CREATE VIEW` en PostgreSQL) y mapearse como entidades de vista en EF Core.
- **Prevención de Doble Petición e Idempotencia:** Cualquier acción mutativa (POST, PUT, DELETE) debe garantizar unicidad de ejecución sin dobles peticiones. El backend debe protegerse contra transacciones duplicadas o llamadas concurrentes con el mismo propósito (idempotencia en endpoints críticos).
- **DTOs Desacoplados:** Transferencia de datos mediante modelos dedicados por módulo, sin exponer entidades del ORM.
- **Nomenclatura de Base de Datos (snake_case):** Todo objeto de persistencia nuevo en PostgreSQL (tablas, columnas, índices, constraints, vistas) usa `snake_case` en minúsculas, tanto en scripts `CREATE` como en el mapeo de EF Core, para mantener paridad entre código y BD.
- **Idioma (Código vs. Usuario):** El código (clases, métodos, variables, DTOs, rutas y nombres de archivo) se escribe en inglés. Los textos dirigidos al usuario final (mensajes de error, validaciones y respuestas legibles) se escriben en español de México (es-MX). La API devuelve mensajes de negocio controlados, nunca trazas de excepción.
- **Aislamiento Modular:** Alta cohesión interna por módulo y mínimo acoplamiento transversal.

## Inicialización y extensiones

El esquema de cada microservicio se define en [`database.sql`](database.sql), ejecutado por PostgreSQL al inicializar un volumen nuevo. No se aplican migraciones ni se crean tablas desde el backend. Cada equipo completa el SQL y los mapeos EF o adapta ese mecanismo; ver [setup](docs/setup.md).
