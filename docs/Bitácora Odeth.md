# Bitácora Odeth — Sistema de Biblioteca TecNM Campus Monclova

> **Propósito:** Documentar en orden cronológico y con detalle técnico cada cambio realizado en el proyecto (archivos creados, modificados o movidos, clases, métodos, entidades de base de datos, rutas, cómo funciona la API y cómo se conecta el Frontend con el Backend).

---

## Línea Temporal (Índice Rápido)

| Entrada | Fecha | Commit | Área | Resumen |
| :---: | :---: | :---: | :--- | :--- |
| Base | 2026-11-11 a 15 | `f43c0a9`..`a894bdf` | Infra / BD / API | Plantilla TecNM, Docker (PostgreSQL + .NET 10 + Nginx), esquema inicial y primera API de libros |
| **1** | 2026-11-23 | `da86b5b`, `cbe01c8` | BD + Backend | Campos `gender` (con `CHECK`) y `semester` en `Borrower` |
| **2** | 2026-11-23 | `b71dcbb` | BD + Backend | Tablas y entidades `Service` y `Visit` (modelo 1 servicio por visita) |
| **3** | 2026-11-24 | `105decb` | BD + Backend | Catálogo `Role` (Admin, Bibliotecario, Lector) y relación `role_id` en `Borrower` |
| **4** | 2026-11-24 | `1f62088` | Frontend | Módulo **Inventario** en Vue 3 (`/inventory`), portadas 3D y modales |
| **5** | 2026-11-24 | `c1ecb67` | Frontend | Menú lateral compartido (`MainLayout.vue`) y módulo **Circulación y Préstamos** (`/circulation`) |
| **6** | 2026-11-24 | `fae24cb` | Frontend | Operaciones de Mostrador en Circulación y solución a colisión CSS con `.grid` |
| **7** | 2026-11-24 | `89095b0` | Frontend | Módulo **Registro de Asistencia** (`/attendance`) con gráficas SVG, matriz mensual y CSV |
| **8** | 2026-11-24 | `8e6a273` | Frontend | Rediseño de **Inventario** (5 métricas filtro rápido, 12 libros, cuadrículas aisladas) |
| *Merge* | 2026-11-24 | `45b2fb4` (PR #1) | Equipo | Integración de cambios de Rositapro (puertos 6050/6060, `Borrower` docente/admin, `AuditLog`, vistas y respaldos) |
| **9** | 2026-11-25 | `3879257` | Frontend | Módulo **Dashboard** como 4ta pestaña (`/dashboard`) con KPIs y gráficas interactivas |
| **10** | 2026-11-25 | `d6a31b7` | Frontend | Franja de 3 botones en Inventario y modales simples de Estante y Tema |
| **11** | 2026-11-25 | `5935d32` | Backend + Frontend | **Buscador de libros en tiempo real** (`BooksService`, API parametrizada y cliente reactivo) |
| **12** | 2026-11-25 | *pendiente* | Infra / Seguridad | Gestión estricta de credenciales vía `.env` (cero hardcoded en Compose) y volumen persistente en `db_replica` |
| **13** | 2026-11-26 | *pendiente* | Frontend | Limpieza del modal *Ficha Técnica* en Inventario (retiro de barra *Disponibilidad en Acervo* y subtítulo) |
| **14** | 2026-11-26 | *pendiente* | BD + Backend | Cálculo automático de turno (`Matutino`/`Vespertino`, corte `15:00`) desde `Visit.entryDate` y `Borrower.time` opcional |
| **15** | 2026-11-26 | *pendiente* | BD + Backend | Eliminación de columna `exitDate` en `Visit` (`database.sql`, `Visit.cs` y `TecNMDbContext.cs`) |
| **16** | 2026-11-26 | *pendiente* | Frontend | Rediseño completo de **Registro de Asistencia** (formulario *Nueva Visita*, historial filtrable por rango/presets y CSV) |

---

## Contexto Base (2026-11-11 a 2026-11-15)

**Commits de referencia:** `f43c0a9`, `b701ce6`, `dd3796a`, `841a852`, `a894bdf`

Sobre la plantilla institucional `TecNM_Project_Template` (sin login local, delegando autenticación a `TecNM_LoginControl`), se estableció la base del proyecto:
- **Contenedores (`compose.yaml`, `backend/Dockerfile`, `docker/nginx/Dockerfile`, `docker/nginx/nginx.conf`):** PostgreSQL 17.4, API .NET 10 y Nginx sobre Debian 13 como proxy inverso.
- **Base de datos inicial (`database.sql`):** tablas base `BookStatus`, `Shelf`, `Topic`, `Author`, `Book`, `Borrower`, `Loan`, `Book_Author` y `Book_Topic` con campos de auditoría obligatorios (`idUserCreate`, `dateCreate`, `idUserUpdate`, `dateUpdate`, `idUserDelete`, `dateDelete`, `idStatus BIT(1)`).
- **Backend inicial (`backend/Features/Books/` y `backend/Data/TecNMDbContext.cs`):** entidades EF Core con conversión de `BIT(1)` mediante `BitArray`, filtro global de soft-delete (`HasQueryFilter(e => e.IdStatus)`) y primer `BooksController` en `/api/books`.

---

## Entrada 1 — Campos `gender` y `semester` en `Borrower`

**Fecha:** 2026-11-23 | **Commits:** `da86b5b`, `cbe01c8`

### Qué se agregó y modificó
- **`database.sql`:**
  - Se agregó `gender VARCHAR(20) NOT NULL` en la tabla `Borrower` con restricción `CONSTRAINT chk_borrower_gender CHECK (gender IN ('Masculino', 'Femenino'))` para asegurar integridad de datos en reportes y gráficas por género.
  - Se agregó `semester VARCHAR(20) NULL` en `Borrower` (nullable para contemplar usuarios sin semestre como docentes/administrativos).
  - Se corrigió una coma faltante antes de la restricción `chk_borrower_gender` y se actualizaron los `INSERT` semilla de `Borrower` con sus valores de género y semestre.
- **`backend/Features/Books/Borrower.cs`:** se añadieron las propiedades `Gender` (`string`) y `Semester` (`string?`).
- **`backend/Data/TecNMDbContext.cs`:** se mapearon las columnas `gender` (`HasMaxLength(20).IsRequired()`) y `semester` (`HasMaxLength(20)`).

---

## Entrada 2 — Modelo de Registro de Visitas y Servicios (`Service` y `Visit`)

**Fecha:** 2026-11-23 | **Commit:** `b71dcbb`

### Cómo funciona el diseño
Se modeló el registro de asistencia a la biblioteca con relación **1 servicio por visita** (`Visit` referencia a `Borrower` y a `Service`), evitando tablas intermedias innecesarias y facilitando reportes por fecha, turno, género y carrera.

### Qué se agregó y modificó
- **`database.sql`:**
  - **Tabla `Service`:** catálogo con `id`, `name VARCHAR(100) NOT NULL UNIQUE`, `description` y campos de auditoría. Se poblaron los 4 servicios base: `1: Física`, `2: Virtual`, `3: Reunión`, `4: Clase`.
  - **Tabla `Visit`:** registra `borrower_id` (`FK -> Borrower`), `service_id` (`FK -> Service`), `entryDate`, `exitDate` (nullable mientras el usuario sigue en sala), `notes` y auditoría.
  - **Índices de consulta:** `idx_visit_service_entry (service_id, entryDate)` e `idx_visit_borrower_entry (borrower_id, entryDate)` para acelerar reportes por rango de fechas.
  - Datos semilla iniciales en `Visit` para pruebas.
- **`backend/Features/Books/Service.cs` (nuevo):** entidad `Service` con colección de navegación `Visits`.
- **`backend/Features/Books/Visit.cs` (nuevo):** entidad `Visit` con navegación a `Borrower` y `Service`.
- **`backend/Features/Books/Borrower.cs`:** se agregó colección `ICollection<Visit> Visits`.
- **`backend/Data/TecNMDbContext.cs`:** se registraron `DbSet<Service>` y `DbSet<Visit>`, sus relaciones `HasOne/WithMany`, índices compuestos, campos de auditoría y filtro de soft-delete en `Visit`.

---

## Entrada 3 — Catálogo de Roles (`Role`) y relación `role_id` en `Borrower`

**Fecha:** 2026-11-24 | **Commit:** `105decb`

### Qué se agregó y modificó
- **`database.sql`:**
  - **Tabla `Role`:** catálogo con `id`, `name VARCHAR(50) NOT NULL UNIQUE`, `description` y auditoría.
  - Roles iniciales: `1: Admin`, `2: Bibliotecario`, `3: Lector`.
  - En **`Borrower`**: se agregó `role_id INT NOT NULL DEFAULT 3` y la llave foránea `CONSTRAINT fk_borrower_role FOREIGN KEY (role_id) REFERENCES Role(id)`.
  - Se actualizaron los usuarios semilla de `Borrower` asignando roles (incluyendo un usuario de prueba con rol `Bibliotecario` y otro `Admin`).
- **`backend/Features/Books/Role.cs` (nuevo):** entidad `Role` con navegación `Borrowers`.
- **`backend/Features/Books/Borrower.cs`:** se agregaron `RoleId` (default `3`) y navegación `Role`.
- **`backend/Data/TecNMDbContext.cs`:** se registró `DbSet<Role>`, índice único en `name`, mapeo `role_id` con `HasDefaultValue(3)` y relación `1:N` entre `Role` y `Borrower`.

---

## Entrada 4 — Implementación inicial del módulo Frontend **Inventario** (Vue 3)

**Fecha:** 2026-11-24 | **Commit:** `1f62088`

### Qué se creó y configuró
- **`frontend/index.html`:** se cargaron los tokens de tema institucional TecNM en Tailwind (`primary: #002351`, `primary-container: #1b396a`, `tecnm-gold: #C5A059`, tipografías *Plus Jakarta Sans* e *Inter*) y la hoja de íconos *Material Symbols Outlined*.
- **Vertical slice `frontend/src/modules/inventory/`:**
  - `views/InventoryView.vue`: vista completa de gestión del acervo con buscador, tira de métricas, vista en cuadrícula/lista con portadas 3D (`.book-stage`, `.book-cover-3d`, `.gold-foil-text`) y 4 modales interactivos:
    1. **Ficha Técnica y Control de Ejemplar** (vista detallada de clasificación Dewey, Cutter, estante y disponibilidad).
    2. **Editar Ficha Técnica** (formulario completo con guardado reactivo).
    3. **Cambiar Estado del Ejemplar** (selector directo conectado a `PUT /api/books/{id}/status`).
    4. **Registrar Nuevo Ejemplar** (alta con folio autogenerado, vista previa de etiqueta topográfica y conexión a `POST /api/books`).
  - `routes.ts` e `index.ts`: ruta `/inventory` (con alias `/inventario`) cargada de forma diferida (*lazy-loading*).
- **`frontend/src/app/router/index.ts`:** redirección de `/` hacia `/inventory`.

---

## Entrada 5 — Menú lateral compartido (`MainLayout.vue`) y módulo **Circulación y Préstamos**

**Fecha:** 2026-11-24 | **Commit:** `c1ecb67`

### Qué se movió y reorganizó
- **`frontend/src/app/layouts/MainLayout.vue`:** se centralizó la barra lateral fija izquierda (`w-72 bg-primary`) y el menú desplegable móvil (*drawer*) para que todas las vistas compartan una sola navegación persistente sin duplicar el sidebar.
- **`frontend/src/modules/inventory/views/InventoryView.vue`:** se retiró el menú lateral duplicado para renderizarse dentro de `MainLayout.vue`.
- **Nuevo módulo `frontend/src/modules/circulation/`:**
  - `views/CirculationView.vue`, `routes.ts`, `index.ts`: vista operativa de préstamos y devoluciones con 4 tarjetas de métricas, pestañas operativas (*Todos*, *Activos*, *Por vencer*, *Vencidos*, *Devueltos*), filtros por texto/carrera, tabla interactiva con acciones de **Devolver**, **Renovar** y **Ver Ficha**, y panel lateral de **Devoluciones de Hoy**.
- **`frontend/src/app/router/index.ts`:** se registró `/circulation` (alias `/circulacion-y-prestamos`) como hijo de `MainLayout.vue`.

---

## Entrada 6 — Operaciones de Mostrador y solución de colisión CSS en **Circulación y Préstamos**

**Fecha:** 2026-11-24 | **Commit:** `fae24cb`

### Problema detectado y cómo se resolvió
- **Problema de diseño detectado:** el archivo global `frontend/src/shared/styles/global.css` define una regla sin capa `.grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }` que sobrescribía las utilidades de Tailwind (`grid-cols-1`, `grid-cols-4`, etc.), causando que las tarjetas de *Devoluciones de Hoy* se acomodaran en 2 columnas y se desbordaran horizontalmente.
- **Solución técnica adoptada para todo el proyecto:** no usar la clase `.grid` de Tailwind en las vistas; en su lugar definir clases CSS `scoped` dedicadas (ej. `.circulation-metrics-grid`) y `flex flex-col` para listas apiladas.
- **Mejora funcional en `CirculationView.vue`:**
  - Se retiró el campo de escáner de código de barras por solicitud funcional y se reemplazó por la barra de **Operaciones de Mostrador** con dos modales completos: **Procesar Préstamo** (validación de lector/libro y fecha límite) y **Registrar Devolución** (selección de préstamo activo y actualización instantánea de métricas y tabla).

---

## Entrada 7 — Módulo Frontend **Registro de Asistencia** (3ra pestaña)

**Fecha:** 2026-11-24 | **Commit:** `89095b0`

### Qué se agregó
- **Nuevo módulo `frontend/src/modules/attendance/`:**
  - `views/AttendanceView.vue`, `routes.ts`, `index.ts`.
  - **3 gráficas de dona SVG reactivas** calculadas dinámicamente (distribución por **Género**, **Turno** y **Carrera**).
  - **Matriz mensual estilo Excel** agrupada por semanas con subtotales automáticos y totales acumulados.
  - Filtros interactivos por día y carrera, **modal de Registro de Asistencia** (alta en vivo que recalcula gráficas y matriz) y botón de **Exportar a CSV/Excel**.
  - Cuadrículas aisladas con CSS `scoped` (`.attendance-metrics-grid`, etc.) para evitar colisiones con `global.css`.
- **`frontend/src/app/layouts/MainLayout.vue` y `router/index.ts`:** se activó la 3ra pestaña **Registro de Asistencia** apuntando a `/attendance` (alias `/registro-de-asistencia`).

---

## Entrada 8 — Rediseño visual de **Inventario** y cuadrículas aisladas

**Fecha:** 2026-11-24 | **Commit:** `8e6a273`

### Qué se modificó en `frontend/src/modules/inventory/views/InventoryView.vue`
- Se simplificó la barra de búsqueda del hero retirando la fila de filtros redundantes de estado.
- Se rediseñaron las **5 tarjetas de métricas** (`Total`, `Prestados`, `Reparación`, `En Baja`, `Catálogo`) con proporción `1.25fr / 1fr / 1fr / 1fr / 1fr` y comportamiento de **filtro rápido al hacer clic**.
- Se amplió el catálogo de respaldo local de 8 a **12 ejemplares** (`#4001` a `#4012`) con portadas 3D diferenciadas.
- Se simplificó el contador de resultados, se centró la barra de paginación y se aislaron todas las cuadrículas con clases `scoped` (`.inventory-metrics-grid`, `.inventory-books-grid`, `.inv-grid-2/3/4`).

---

## Hito de Integración en Equipo — Pull Request #1 (Rositapro)

**Fecha:** 2026-11-24 | **Commit:** `45b2fb4` (incluye `5e3311f`..`d1a3115`)

Se integraron a la rama principal los cambios de compañera (documentados a detalle en `docs/BITACORA_CAMBIOS.md`), manteniendo compatibilidad con las vistas y el backend:
- Estandarización de puertos: **Frontend/Nginx en `6050`** y **Backend .NET 10 en `6060`**.
- Evolución de `Borrower` para soportar Alumnos, Docentes y Administrativos (`borrower_type`, `studentid`, `employeeid` y columna generada `institutional_id`).
- Requerimientos de Tópicos de BD (`IFF-1026`): tabla particionada `AuditLog`, triggers automáticos `trg_audit_*`, vistas SQL de reporte (`vw_attendance_summary_by_type`, `vw_active_loans_detail`, `vw_inventory_metrics`), scripts de respaldo/restauración y esquema maestro-esclavo.

---

## Entrada 9 — Módulo Frontend **Dashboard** (4ta pestaña del menú)

**Fecha:** 2026-11-25 | **Commit:** `3879257`

### Qué se agregó
- **Nuevo módulo `frontend/src/modules/dashboard/`:**
  - `views/DashboardView.vue`, `routes.ts`, `index.ts`.
  - **Selector interactivo de periodo** (`Hoy`, `Semanal`, `Mensual`, `Ciclo`) que actualiza reactivamente todos los indicadores y gráficas.
  - **4 KPIs ejecutivos** (Asistencia, Préstamos activos, Tasa de devolución a tiempo y Acervo disponible).
  - **Gráfica de barras SVG semanal por turno** (Matutino vs. Vespertino), barras de demanda por las **7 ingenierías**, listado **Top 5 libros más solicitados**, **dona SVG de género** con enlace directo a `/attendance` y botón de **Exportar Informe CSV**.
  - Cuadrículas aisladas con clases `scoped` (`.dashboard-kpi-grid`, `.dashboard-two-col`).
- **`frontend/src/app/layouts/MainLayout.vue` y `router/index.ts`:** se agregó **Dashboard** como 4ta pestaña después de *Registro de Asistencia* y se registró `/dashboard`.

---

## Entrada 10 — Franja de 3 botones de altas y modales minimalistas en **Inventario**

**Fecha:** 2026-11-25 | **Commit:** `d6a31b7`

### Qué se cambió en `frontend/src/modules/inventory/views/InventoryView.vue`
- Se movió el botón de alta fuera de la barra de herramientas superior y se creó una **franja dedicada de 3 botones** (`.inventory-actions-grid`):
  1. `+ Registrar Nuevo Ejemplar`
  2. `+ Registrar Estante`
  3. `+ Registrar Temas`
- **Modal 4 — Registrar Nuevo Estante (`showEstanteModal`):** diseñado de forma estrictamente minimalista (alineado con la tabla `Shelf` de `database.sql`), mostrando únicamente el campo **Código del Estante** (`estanteCodigo`, placeholder `Ej. 1.3.2`) y los botones **Cancelar** / **Guardar Estante**, sin subtítulos, banners ni descripciones adicionales.
- **Modal 5 — Registrar Nuevo Tema (`showTemasModal`):** diseñado igualmente minimalista (alineado con la tabla `Topic`), mostrando únicamente el campo **Nombre del Tema** (`temaNombre`, placeholder `Ej. Inteligencia Artificial, Siderurgia`) y los botones **Cancelar** / **Guardar Tema**, sin campos extra.
- Se agregaron las funciones `openEstanteModal`, `closeEstanteModal`, `saveNewEstante`, `openTemasModal`, `closeTemasModal`, `saveNewTema`, cierre con tecla `Escape` y banner de confirmación (`feedbackMessage`).

---

## Entrada 11 — Buscador de libros en tiempo real del módulo Inventario (Backend + Frontend)

**Fecha:** 2026-11-25 | **Commit:** `5935d32`  
**Alcance:** Backend (`backend/`) y Frontend (`frontend/src/modules/inventory/`), manteniendo ambos proyectos estrictamente separados.

### 1. ¿Cómo funciona de punta a punta?

Cuando el usuario escribe en la barra de búsqueda de la vista **Inventario**, ocurre este flujo completo:

1. **Usuario escribe en el input (`InventoryView.vue`):** por ejemplo escribe `calculo stewart`.
2. **Debounce (espera inteligente de 220 ms):** en lugar de disparar una petición por cada tecla al instante (lo que saturaría el servidor), el frontend espera `220 ms` desde la última tecla presionada. Si el usuario borra todo el texto, presiona Enter o hace clic en **Buscar**, la búsqueda se ejecuta de inmediato (`0 ms`).
3. **Cancelación de peticiones anteriores (`AbortController`):** si todavía había una petición HTTP anterior viajando al backend, se cancela automáticamente antes de lanzar la nueva. Así se evita que una respuesta lenta anterior sobrescriba los resultados más recientes.
4. **Cliente HTTP del módulo (`inventoryApi.ts`):** construye la petición `GET /api/books` usando la instancia compartida de Axios (`shared/api/http.ts`) y envía los parámetros en la query string (por ejemplo: `GET /api/books?search=calculo+stewart&status=disponible&sortBy=dewey`).
5. **Proxy (Vite / Nginx):** redirige `/api/...` hacia el backend .NET en el puerto `6060`.
6. **Controlador delgado (`BooksController.cs`):** recibe la petición HTTP, empaqueta los parámetros en `BookSearchQuery` y delega el trabajo a `IBooksService` pasando también el `CancellationToken` de la petición.
7. **Servicio de negocio (`BooksService.cs`):** construye una consulta **LINQ asíncrona de EF Core** (sin SQL crudo), separa el texto en palabras (*tokens*), normaliza acentos y mayúsculas, y consulta PostgreSQL buscando coincidencias en todas las columnas y relaciones del libro.
8. **Respuesta JSON (`BookDto[]`):** el backend devuelve únicamente DTOs desacoplados (nunca entidades crudas de EF Core) con código `200 OK`.
9. **Actualización de la vista (`InventoryView.vue`):** los resultados del backend se mapean a tarjetas 3D y actualizan la cuadrícula/lista en tiempo real. Si el backend devuelve `[]`, la vista muestra el estado vacío *"No se encontraron ejemplares con los filtros actuales"* sin alterar las tarjetas de métricas totales superiores.

### 2. Cómo funciona la API de Inventario

#### `GET /api/books` — Búsqueda en tiempo real, filtrado y ordenamiento
Consulta los ejemplares activos (`idstatus = B'1'`) directamente en PostgreSQL.

| Parámetro (Query) | Tipo | Valor por defecto | Descripción |
| :--- | :--- | :--- | :--- |
| `search` | `string?` | `null` | Texto escrito por el usuario. Admite varias palabras separadas por espacio (ej. `sistemas tanenbaum`) e ignora mayúsculas y acentos (`á, é, í, ó, ú, ü`). |
| `field` | `string?` | `"all"` | Campo donde buscar: `all`, `title`, `author`, `dewey`, `cutter`, `folio` / `barcode`, `shelf` o `topic`. En la barra de inventario se usa `all`. |
| `status` | `string?` | `"all"` | Filtro por estado administrativo: `all`, `disponible` (`1`), `prestado` (`2`), `reparacion` (`3`), `baja` (`4`), `catalogo` (`5`). |
| `sortBy` | `string?` | `"dewey"` | Orden de resultados: `dewey` (Dewey + título), `status` (estatus + título), `barcode` / `folio` (folio + título) o `relevance` (título + Dewey). |

**Ejemplo de petición real:**
```http
GET /api/books?search=calculo+stewart&status=disponible&sortBy=dewey
Accept: application/json
```

**Ejemplo de respuesta (`200 OK`):**
```json
[
  {
    "id": 6,
    "title": "Cálculo de una Variable: Trascendentes Tempranas",
    "note": "8va Edición, Cengage Learning",
    "author": "James Stewart",
    "folio": "FOL-TECNM-006",
    "dewey": "515.3",
    "cutter": "S849c",
    "statusId": 1,
    "statusName": "Disponible",
    "shelfId": 5,
    "shelfName": "Estante C-1: Ciencias Básicas y Matemáticas Aplicadas",
    "availableText": "Disponible para consulta",
    "availabilityPercent": 80,
    "topics": ["Cálculo Diferencial e Integral"]
  }
]
```

#### Otros endpoints del controlador `BooksController` (`/api/books`)
| Método y Ruta | Función |
| :--- | :--- |
| `GET /api/books/{id}` | Obtiene el detalle de un libro específico (`200 OK` o `404 Not Found`). |
| `GET /api/books/metrics` | Devuelve los totales globales del acervo (`totalBooks`, `availableCount`, `borrowedCount`, `repairCount`, `discardCount`, `catalogCount`) agrupados en SQL. |
| `POST /api/books` | Registra un nuevo ejemplar validando obligatoriedad, folio único (`409 Conflict`) y existencia de estatus y estante. |
| `PUT /api/books/{id}/status` | Actualiza el estado administrativo (y nota opcional) de un libro. |
| `DELETE /api/books/{id}` | Aplica borrado lógico (*soft delete*) cambiando `IdStatus = false` y registrando `DateDelete`. |
| `GET /api/books/shelves` | Lista el catálogo activo de estantes ordenados por nombre. |
| `GET /api/books/statuses` | Lista el catálogo activo de estados de libros. |

### 3. Cambios detallados en el Backend (`backend/`)

Se aplicó el patrón **Thin Controller + Fat Service** indicado en `backend/AGENTS.md`: toda la lógica de consultas, validaciones y mapeo se movió fuera de `BooksController.cs` hacia un servicio dedicado inyectado por DI.

#### Archivo nuevo: `backend/Features/Books/BooksService.cs`
Define la interfaz `IBooksService` y su implementación `BooksService(TecNMDbContext db)`.

- **`SearchBooksAsync(BookSearchQuery searchQuery, CancellationToken cancellationToken)`:** construye una consulta `AsNoTracking()` con `Include` sobre `Status`, `Shelf`, `BookAuthors -> Author` (solo activos) y `BookTopics -> Topic` (solo activos), usando `AsSplitQuery()`. Encadena `ApplyStatusFilter`, `ApplyRealtimeSearchFilter` y `ApplySorting`, ejecuta `ToListAsync(cancellationToken)` y mapea cada entidad a `BookDto`.
- **`ApplyRealtimeSearchFilter(IQueryable<Book> query, string? search, string? field)`:** divide `search` por espacios en palabras únicas (máximo `MaxSearchTokens = 10`), normaliza acentos/mayúsculas con `NormalizeSearchText` y encadena un `.Where(...)` por cada palabra (búsqueda multipalabra).
- **`BuildTokenPredicate(string normalizedToken, string field)`:** construye el árbol de expresiones LINQ (`Expression<Func<Book, bool>>`) que EF Core traduce a SQL en PostgreSQL sin SQL crudo. En modo `"all"` busca coincidencias en: `Book.Title`, `Book.Author`, `Book.BookAuthors` (`Author.Name` / `LastName`), `Book.BookTopics` (`Topic.Name`), `Book.Note`, `Book.Dewey`, `Book.Cutter`, `Book.Folio`, `Book.Shelf.Name` y `Book.Status.Name`.
- **`BuildNormalizedContains(...)` + `record SearchParameter(string Value)`:** aplica `LOWER` y `REPLACE` de vocales acentuadas en SQL y envuelve el término buscado en `SearchParameter` para que EF Core genere un **parámetro SQL real (`@__p_0`)** y reutilice el plan de consulta en caché sin inflar memoria en cada tecleo.
- **`BuildBookAuthorsMatch(...)` y `BuildBookTopicsMatch(...)`:** generan subconsultas `EXISTS` con `Enumerable.Any` filtrando `IdStatus == true` (compatible con `BitArray` / `BIT(1)`).
- **`ApplyStatusFilter(...)` y `ApplySorting(...)`:** filtran por estado y ordenan por `dewey`, `status`, `barcode`/`folio` o `relevance`.
- **`GetMetricsAsync(CancellationToken cancellationToken)`:** usa `GroupBy(b => b.StatusId)` en SQL en lugar de cargar todos los libros en memoria.
- **`CreateBookAsync`, `UpdateStatusAsync`, `SoftDeleteAsync`, `GetBookByIdAsync`, `GetShelvesAsync`, `GetStatusesAsync`:** movidos del controlador al servicio, validando existencia de `BookStatus` y `Shelf` y evitando adjuntar entidades `AsNoTracking()` al insertar un nuevo `Book`.
- **`MapToDto(Book book)`:** construye el `BookDto` completando autor desde `BookAuthors` si falta e incluyendo la lista `Topics`.

#### Archivo modificado: `backend/Features/Books/BooksController.cs`
- Se retiró toda la lógica directa de `TecNMDbContext` y consultas LINQ hacia `BooksService.cs`.
- Ahora recibe `IBooksService` por constructor, propaga `CancellationToken` en todos los endpoints y se enfoca exclusivamente en transporte HTTP y códigos de respuesta.

#### Archivo modificado: `backend/Features/Books/BookDtos.cs`
- Se agregó `IReadOnlyList<string>? Topics = null` al final de `BookDto`.
- Se agregó `BookSearchQuery(string? Search, string? Field, string? Status, string? SortBy)`.

#### Archivo modificado: `backend/Program.cs`
- Se registró el servicio en inyección de dependencias: `builder.Services.AddScoped<IBooksService, BooksService>();`.

### 4. Cambios detallados en el Frontend (`frontend/src/modules/inventory/`)

#### Archivo nuevo: `frontend/src/modules/inventory/types/inventory.ts`
Centraliza los tipos TypeScript del módulo (`BookStatusKey`, `InventorySortKey`, `StatusMeta`, `BookApiDto`, `BookMetricsApiDto`, `BookSearchParams`, `CreateBookPayload`, `UpdateBookStatusPayload`, `BookItem` con `topics: string[]` y `MetricsSummary`).

#### Archivo nuevo: `frontend/src/modules/inventory/api/inventoryApi.ts`
Cliente HTTP exclusivo de Inventario basado en `shared/api/http.ts`:
- `searchBooks(params, signal?)` → `GET /books` con soporte de `AbortSignal`.
- `getInventoryMetrics(signal?)` → `GET /books/metrics`.
- `createBook(payload)` → `POST /books`.
- `updateBookStatus(bookId, payload)` → `PUT /books/{bookId}/status`.

#### Archivo modificado: `frontend/src/modules/inventory/views/InventoryView.vue`
- Consume `inventoryApi.ts` y `types/inventory.ts` en lugar de usar `http` directamente.
- Nuevos estados reactivos: `isSearching` y `searchError`.
- **`executeBackendSearch()`:** cancela peticiones anteriores con `AbortController`, protege contra respuestas fuera de orden (`latestSearchRequestId`) y actualiza `books.value` incluso si PostgreSQL devuelve `[]` (corrigiendo el bug anterior que ignoraba resultados vacíos).
- **`scheduleRealtimeSearch()` y `runImmediateSearch()`:** `watch(searchKeyword)` aplica debounce de `220 ms` al escribir y búsqueda inmediata al vaciar; `watch([selectedStatus, sortBy])` y el submit ejecutan búsqueda inmediata.
- **Métricas globales (`displayMetrics` / `fetchMetrics`):** mantienen siempre los totales globales del inventario desde `GET /api/books/metrics` aunque haya una búsqueda activa.
- **Limpieza (`onBeforeUnmount`):** limpia el timer y aborta peticiones en vuelo al salir de la vista.
- **Feedback visual:** ícono giratorio `progress_activity`, aviso *"Buscando coincidencias..."* y banner de error con botón **Reintentar**.

### 5. Validación ejecutada
- **Backend:** `dotnet build backend/TecNM.Api.csproj --no-restore` → **0 errores**.
- **Frontend:** `npm run build` (`vue-tsc --noEmit && vite build`) → **0 errores**.
- **Layout:** `node scripts/check-layout.mjs` → **aprobado**.
- **Cómo probar en vivo con Docker:**
  ```powershell
  cd C:\Users\odeth\TecNM_Library\TecNM_Library
  docker compose up -d --build
  ```
  Abrir `http://localhost:6050/inventory` y escribir términos como `calculo`, `stewart`, `redes`, `ross`, `005.1` o `FOL-TECNM-004` para comprobar el filtrado en tiempo real desde PostgreSQL.

---

## Entrada 12 — Gestión estricta de credenciales en `.env` y volumen persistente en réplica

**Fecha:** 2026-11-25  
**Alcance:** Infraestructura Docker (`compose.yaml`, `docker/docker-compose.yml`, `docker/docker-compose.replication.yml`) y plantillas de entorno (`.env.example`, `backend/.env.example`).

### 1. Qué problema se detectó en la auditoría
- Aunque el código fuente de C# y Vue ya estaba limpio de contraseñas y `.gitignore` ignoraba `.env`, los 3 archivos de Docker Compose subidos a Git contenían la contraseña de PostgreSQL y la cadena `ConnectionStrings__DefaultConnection` escritas en texto plano (*hardcoded*).
- Además, `.env.example` aún usaba variables viejas de la plantilla (`tecnm-template`, `TECNM_DB_PASSWORD`) sin correspondencia con `compose.yaml`.
- En `docker/docker-compose.replication.yml`, el contenedor `db_replica` no tenía volumen persistente declarado.

### 2. Qué se modificó archivo por archivo
- **`.env.example`:** actualizado como plantilla oficial (sin contraseñas reales) con las variables `COMPOSE_PROJECT_NAME`, `TECNM_FRONTEND_PORT`, `TECNM_BACKEND_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` (vacía para llenarse localmente), `ASPNETCORE_ENVIRONMENT` y `CORS_ALLOWED_ORIGINS`.
- **`backend/.env.example`:** alineado a `Database=tecnm_library;Username=tecnm_admin;Password=REPLACE_LOCAL_PASSWORD`.
- **`compose.yaml` y `docker/docker-compose.yml`:**
  - Se eliminaron todas las contraseñas y cadenas de conexión en texto plano.
  - Ahora exigen variables obligatorias desde `.env` mediante `${POSTGRES_DB:?...}`, `${POSTGRES_USER:?...}` y `${POSTGRES_PASSWORD:?...}` tanto en el servicio `db` como al armar `ConnectionStrings__DefaultConnection` en `backend`.
  - El `healthcheck` de PostgreSQL usa `pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB` (variables evaluadas dentro del contenedor) sin hardcodear usuario ni base de datos.
  - Los puertos (`TECNM_BACKEND_PORT`, `TECNM_FRONTEND_PORT`) y `CORS_ALLOWED_ORIGINS` también se leen desde `.env`.
- **`docker/docker-compose.replication.yml`:**
  - Se parametrizaron `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD` y `PGPASSWORD` desde `.env` en `db_master` y `db_replica`, junto con el `healthcheck`.
  - Se agregó el volumen persistente `postgres_replica_data:/var/lib/postgresql/data` (`tecnm-library-postgres-replica-data`) en `db_replica` para garantizar persistencia también en la réplica.
- **`.env` local (fuera de Git):** creado localmente en la raíz del proyecto e ignorado automáticamente por `.gitignore` para que `docker compose up -d` siga funcionando con el volumen existente de PostgreSQL.

### 3. Cómo levantar los servicios con `.env`
- **Entorno principal (desde la raíz del repo):**
  ```powershell
  docker compose up -d --build
  ```
- **Compose alterno o replicación (dentro de `docker/`):**
  ```powershell
  docker compose --env-file .env -f docker/docker-compose.replication.yml up -d
  ```

---

## Entrada 13 — Actualización del modal *Ficha Técnica* en Inventario

**Fecha:** 2026-11-26  
**Alcance:** Frontend (`frontend/src/modules/inventory/views/InventoryView.vue`).

### Qué se modificó
- **Modal *Ficha Técnica y Control de Ejemplar* (`showFichaModal`):**
  - Se eliminó el bloque de **Disponibilidad en Acervo** (texto de copias libres y barra de progreso verde), ya que cada registro de la tabla `Book` representa un ejemplar físico individual con su propio folio y estatus.
  - Se retiró el subtítulo *"TecNM Campus Monclova • Acervo Físico"* del encabezado del modal para dejar un header más limpio.
- **Lógica preservada sin cambios:** se mantuvo íntegro todo el funcionamiento del **buscador en tiempo real** conectado a `GET /api/books` (`executeBackendSearch`, debounce de `220 ms`, `AbortController`, filtros por estado, ordenamiento, indicadores de carga/error) y los modales minimalistas de *Registrar Nuevo Estante* y *Registrar Nuevo Tema*.

---

## Entrada 14 — Cálculo real de turno (`shift`) a partir de `Visit.entryDate` y `Borrower.time` opcional

**Fecha:** 2026-11-26  
**Alcance:** Base de datos (`database.sql`) y Backend (`backend/Features/Books/Borrower.cs`, `backend/Data/TecNMDbContext.cs`).

### Por qué se hizo este cambio
En el TecNM Campus Monclova las clases del turno matutino son de 7:00 AM a 3:00 PM y el vespertino inicia por la tarde. Anteriormente la vista `vw_attendance_summary_by_type` leía el turno desde `Borrower.time` (que además contenía valores como `'Tiempo Completo'` o `'Turno Completo'` para docentes y administrativos). Calcular el turno a partir de la hora exacta de entrada registrada en `Visit.entryDate` refleja la afluencia real de la biblioteca y garantiza siempre valores consistentes (`'Matutino'` o `'Vespertino'`) para todos los tipos de usuario.

### Qué se modificó archivo por archivo
- **`database.sql`:**
  - En la tabla **`Borrower`**: `time VARCHAR(50) NULL` pasó a ser opcional para no obligar a capturarlo en nuevos registros sin romper scripts existentes (como `database/scripts/verify-topicos-bd.ps1`).
  - En la vista **`vw_attendance_summary_by_type`**: se reemplazó `b.time AS shift` por una expresión calculada sobre `v.entryDate`:
    ```sql
    CASE
        WHEN EXTRACT(HOUR FROM v.entryDate) < 15 THEN 'Matutino'
        ELSE 'Vespertino'
    END AS shift
    ```
    - Antes de las **15:00 (3:00 PM)** → **`Matutino`**.
    - A partir de las **15:00 (3:00 PM)** en adelante → **`Vespertino`**.
- **`backend/Features/Books/Borrower.cs`:** se cambió la propiedad `Time` de `string` a `string?` (nullable).
- **`backend/Data/TecNMDbContext.cs`:** se retiró `.IsRequired()` del mapeo de `Borrower.Time` para mantener paridad exacta con `database.sql`.

### Nota para bases de datos ya inicializadas en Docker
Como PostgreSQL solo ejecuta `database.sql` al inicializar un volumen vacío, si ya tienes un contenedor levantado y quieres aplicar el cambio sin borrar datos puedes ejecutar el `ALTER TABLE` y el `CREATE OR REPLACE VIEW`, o recrear el volumen con `docker compose down -v && docker compose up -d`.

---

## Entrada 15 — Eliminación de `exitDate` en `Visit`

**Fecha:** 2026-11-26  
**Alcance:** Base de datos (`database.sql`) y Backend (`backend/Features/Books/Visit.cs`, `backend/Data/TecNMDbContext.cs`).

### Qué se modificó archivo por archivo
- **`database.sql`:**
  - Se eliminó la columna `exitDate TIMESTAMP NULL` de la definición de la tabla `Visit` (conservando `entryDate` como marca de tiempo de registro de la visita).
  - Se actualizaron los `INSERT INTO Visit` semilla removiendo la columna y sus valores.
- **`backend/Features/Books/Visit.cs`:** se eliminó la propiedad `ExitDate` (`DateTime?`).
- **`backend/Data/TecNMDbContext.cs`:** se retiró el mapeo `entity.Property(e => e.ExitDate).HasColumnName("exitdate")` para mantener paridad con `database.sql`.

---

## Entrada 16 — Rediseño completo de la vista **Registro de Asistencia**

**Fecha:** 2026-11-26  
**Alcance:** Frontend (`frontend/src/modules/attendance/views/AttendanceView.vue`).

### Qué se cambió en `AttendanceView.vue`
Se reemplazó la vista anterior (basada en donas y matriz mensual) por el nuevo diseño operativo de mostrador para registro diario e historial de visitas, integrado dentro del `MainLayout.vue` compartido (sin duplicar la barra lateral):

- **Encabezado institucional y banner superior:**
  - Barra superior con título *"Biblioteca Tec Monclova"* e indicador de estado *"Servicio Activo • Sala General"*.
  - Banner *"Registro de Asistencias y Visitas Diarias"* con periodo vigente (*Ago - Dic 2026*).
- **Tarjeta de captura *Nueva Visita*:**
  - **Fecha** (`type="date"`, inicializada a la fecha actual) y **Turno** (`Matutino` / `Vespertino`, seleccionado automáticamente con el corte institucional de las `15:00`) distribuidos con cuadrícula scoped `.attendance-date-shift-grid` (aislada de `.grid` de `global.css`).
  - **Nombre del Visitante** con búsqueda/autocompletado sobre el directorio local (`findMatchingVisitor`) por nombre o matrícula/clave de empleado.
  - **Servicio / Motivo** en botones tipo *pill*: `Presencial` (activo por defecto), `Virtual`, `Reunión`, `Clase`, `Mantenimiento` y `Otra`.
  - **Nota / Observaciones** opcional.
  - **Registrar grupo + Cantidad** (`1` a `60`, habilitado al marcar el checkbox).
  - Botón principal **Registrar Visita** (`handleRegisterVisit`) que inserta la visita al inicio del historial, actualiza contadores y muestra una notificación flotante (*toast* animado con `showToast`).
- **Tarjeta *Historial de Visitas Registradas*:**
  - **3 métricas reactivas del periodo:** `Total periodo`, `Matutino` y `Vespertino`.
  - **Barra de periodo de consulta:** selector de fechas *desde / al*, botón **Filtrar** (`applyDateFilter`), accesos rápidos **Hoy**, **Semana** y **Mes** (`setFilterPreset`), y botón **Exportar CSV** (`exportToCSV`) que descarga el archivo `.csv` con BOM UTF-8.
  - **Tabla interactiva (`#visitasTable`):** columnas `Fecha`, `Hora`, `Matrícula`, `Nombre` (con nota si existe), `Carrera`, `Servicio` (badge por color) y botón **Anular** (`handleDeleteVisit`), con paginación funcional de 6 registros por página.





