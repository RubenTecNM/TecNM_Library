# Bitácora Odeth — Sistema de Biblioteca TecNM Campus Monclova

> **Propósito:** Documentar de forma detallada cada cambio realizado en el proyecto (archivos creados, modificados o movidos, clases, métodos, cómo funciona la API y cómo se conecta el Frontend con el Backend) para tener referencia técnica clara y comprensible en todo momento.

---

## Entrada 1 — Buscador en tiempo real del módulo Inventario (Backend + Frontend)

**Fecha:** 2026-11-25  
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

---

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

---

### 3. Cambios detallados en el Backend (`backend/`)

Se aplicó el patrón **Thin Controller + Fat Service** indicado en `backend/AGENTS.md`: toda la lógica de consultas, validaciones y mapeo se movió fuera de `BooksController.cs` hacia un servicio dedicado inyectado por DI.

#### Archivo nuevo: `backend/Features/Books/BooksService.cs`
Define la interfaz `IBooksService` y su implementación `BooksService(TecNMDbContext db)`.

- **`SearchBooksAsync(BookSearchQuery searchQuery, CancellationToken cancellationToken)`**
  - Construye una consulta `AsNoTracking()` con `Include` sobre `Status`, `Shelf`, `BookAuthors -> Author` (solo activos) y `BookTopics -> Topic` (solo activos), usando `AsSplitQuery()` para evitar producto cartesiano entre múltiples colecciones.
  - Encadena `ApplyStatusFilter`, `ApplyRealtimeSearchFilter` y `ApplySorting`, ejecuta `ToListAsync(cancellationToken)` y transforma cada entidad a `BookDto` con `MapToDto`.
- **`ApplyRealtimeSearchFilter(IQueryable<Book> query, string? search, string? field)`**
  - Divide `search` por espacios en palabras únicas (hasta `MaxSearchTokens = 10` para evitar consultas abusivas).
  - Normaliza cada palabra con `NormalizeSearchText` (minúsculas + reemplazo de `á, é, í, ó, ú, ü` por `a, e, i, o, u, u`).
  - Por cada palabra agrega un `.Where(...)` generado por `BuildTokenPredicate`, de modo que un libro aparece si **todas** las palabras coinciden en algún campo.
- **`BuildTokenPredicate(string normalizedToken, string field)`**
  - Construye el árbol de expresiones LINQ (`Expression<Func<Book, bool>>`) que EF Core traduce a SQL en PostgreSQL sin usar SQL crudo.
  - Cuando `field` es `"all"`, busca coincidencias simultáneamente en:
    1. `Book.Title` (título)
    2. `Book.Author` (autor principal en columna)
    3. `Book.BookAuthors` (`Author.Name` y `Author.LastName` — coautores en tabla N:M)
    4. `Book.BookTopics` (`Topic.Name` — especialidad/temas en tabla N:M)
    5. `Book.Note` (edición, volumen, editorial)
    6. `Book.Dewey` (clasificación Dewey)
    7. `Book.Cutter` (clave Cutter)
    8. `Book.Folio` (folio / ID de inventario)
    9. `Book.Shelf.Name` (estante físico)
    10. `Book.Status.Name` (nombre del estado)
- **`BuildNormalizedContains(...)` + `record SearchParameter(string Value)`**
  - Aplica `LOWER` y `REPLACE` de vocales acentuadas sobre la columna en SQL y compara con `.Contains(...)`.
  - **Detalle técnico importante:** el término buscado se envuelve en `SearchParameter` (en lugar de `Expression.Constant(string)` directo) para que EF Core genere un **parámetro SQL real (`@__p_0`)** y reutilice el plan de consulta en caché en cada tecleo sin inflar memoria.
- **`BuildBookAuthorsMatch(...)` y `BuildBookTopicsMatch(...)`**
  - Construyen subconsultas `EXISTS` mediante `Enumerable.Any` validando `IdStatus == true` (compatible con el conversor `BitArray` de `BIT(1)` en PostgreSQL).
- **`ApplyStatusFilter(...)` y `ApplySorting(...)`**
  - Traducen claves legibles (`disponible`, `prestado`, `reparacion`, `baja`, `catalogo` o su ID numérico) y el criterio de ordenamiento (`dewey`, `status`, `barcode`/`folio`, `relevance`).
- **`GetMetricsAsync(CancellationToken cancellationToken)`**
  - Se optimizó para usar `GroupBy(b => b.StatusId)` directo en SQL en lugar de cargar todos los libros en memoria con `ToListAsync()`.
- **`CreateBookAsync(...)`, `UpdateStatusAsync(...)`, `SoftDeleteAsync(...)`, `GetBookByIdAsync(...)`, `GetShelvesAsync(...)`, `GetStatusesAsync(...)`**
  - Se movieron desde el controlador al servicio, agregando validación de existencia de `BookStatus` y `Shelf`, evitando insertar entidades navegacionales `AsNoTracking()` por accidente al guardar `Book`, y devolviendo mensajes de error claros en español de México.
- **`MapToDto(Book book)`**
  - Convierte la entidad a `BookDto`, completando el autor desde `BookAuthors` si la columna `Author` viniera vacía e incluyendo la lista de `Topics`.

#### Archivo modificado: `backend/Features/Books/BooksController.cs`
- **Qué se movió:** se retiró toda la lógica directa de `TecNMDbContext` y consultas LINQ hacia `BooksService.cs`.
- **Qué quedó:** ahora recibe `IBooksService` por constructor, expone las mismas rutas `/api/books`, propaga `CancellationToken` en todos los endpoints y se limita a devolver códigos HTTP (`Ok`, `CreatedAtAction`, `NotFound`, `StatusCode`).

#### Archivo modificado: `backend/Features/Books/BookDtos.cs`
- Se agregó `IReadOnlyList<string>? Topics = null` al final de `BookDto` (manteniendo compatibilidad hacia atrás con todos los campos previos).
- Se agregó el record `BookSearchQuery(string? Search, string? Field, string? Status, string? SortBy)` para encapsular los parámetros de búsqueda.

#### Archivo modificado: `backend/Program.cs`
- Se importó `TecNM.Api.Features.Books` y se registró el servicio en inyección de dependencias:
  ```csharp
  builder.Services.AddScoped<IBooksService, BooksService>();
  ```

---

### 4. Cambios detallados en el Frontend (`frontend/src/modules/inventory/`)

Siguiendo la arquitectura de vertical slice de `frontend/AGENTS.md`, se separaron los tipos y el cliente HTTP del módulo de inventario para no mezclar lógica de red directamente dentro de la vista.

#### Archivo nuevo: `frontend/src/modules/inventory/types/inventory.ts`
Centraliza todos los tipos TypeScript del módulo:
- `BookStatusKey`, `InventorySortKey`, `StatusMeta`
- Contratos de API: `BookApiDto`, `BookMetricsApiDto`, `BookSearchParams`, `CreateBookPayload`, `UpdateBookStatusPayload`
- Modelos de vista: `BookItem` (ahora incluye `topics: string[]`) y `MetricsSummary`.

#### Archivo nuevo: `frontend/src/modules/inventory/api/inventoryApi.ts`
Cliente HTTP exclusivo del dominio de Inventario (usa la instancia compartida `http` de `frontend/src/shared/api/http.ts`):
- **`searchBooks(params: BookSearchParams, signal?: AbortSignal)`**: llama a `GET /books` enviando solo los query params activos (`search`, `field`, `status`, `sortBy`) y adjuntando `signal` para cancelar peticiones obsoletas.
- **`getInventoryMetrics(signal?: AbortSignal)`**: llama a `GET /books/metrics`.
- **`createBook(payload: CreateBookPayload)`**: llama a `POST /books`.
- **`updateBookStatus(bookId: number, payload: UpdateBookStatusPayload)`**: llama a `PUT /books/{bookId}/status`.

#### Archivo modificado: `frontend/src/modules/inventory/views/InventoryView.vue`
- **Reemplazo de llamadas directas a `http`:** ahora importa las funciones desde `../api/inventoryApi` y los tipos desde `../types/inventory`.
- **Nuevos estados reactivos:** `isSearching` (indica búsqueda en curso) y `searchError` (muestra errores de conexión con botón *Reintentar*).
- **`executeBackendSearch()`:**
  - Incrementa `latestSearchRequestId` y aborta cualquier `activeSearchController` pendiente antes de lanzar `searchBooks(...)`.
  - Actualiza `books.value` con lo que regresa el backend **incluso si devuelve 0 resultados (`[]`)** — esto corrigió un error previo donde una búsqueda sin coincidencias mantenía los libros anteriores en pantalla.
  - Ignora silenciosamente errores de cancelación (`axios.isCancel` / `AbortError`).
- **`scheduleRealtimeSearch()` y `runImmediateSearch()`:**
  - `watch(searchKeyword)` usa debounce de `220 ms` mientras escribes y dispara búsqueda inmediata si vacías la barra.
  - `watch([selectedStatus, sortBy])` y el submit del formulario (`@submit.prevent="runImmediateSearch"`) ejecutan búsqueda inmediata contra el backend.
- **Corrección de métricas globales (`displayMetrics` y `fetchMetrics`):**
  - Las 5 tarjetas superiores (`Total`, `Prestados`, `Reparación`, `En Baja`, `Catálogo`) ahora siempre muestran `baseMetrics` (obtenidas de `GET /api/books/metrics`) en lugar de recalcularse sobre el subconjunto filtrado de la búsqueda. También se refrescan tras crear un libro o cambiar estatus.
- **Limpieza de recursos (`onBeforeUnmount`):** limpia `searchDebounceTimer` y aborta `activeSearchController` si el usuario cambia de vista mientras hay una búsqueda en vuelo.
- **Fallback sin conexión (`normalizeOfflineText` + `filteredBooks`):** si el backend aún no está levantado (`usingApiData === false`), conserva el filtrado local insensible a acentos sobre el catálogo demo; cuando el backend está activo (`usingApiData === true`), muestra exactamente la lista devuelta por PostgreSQL.
- **Feedback visual en interfaz:** ícono giratorio `progress_activity` en el buscador y texto *"Buscando coincidencias..."* mientras consulta al servidor, más banner de error con botón **Reintentar**.

---

### 5. Validación ejecutada

- **Backend:** `dotnet build backend/TecNM.Api.csproj --no-restore` → **0 errores**.
- **Frontend:** `npm run build` (`vue-tsc --noEmit && vite build`) → **0 errores**.
- **Layout:** `node scripts/check-layout.mjs` → **aprobado**.
- **Cómo probar en vivo con Docker:**
  ```powershell
  cd C:\Users\odeth\TecNM_Library\TecNM_Library
  docker compose up -d --build
  ```
  Luego abrir `http://localhost:6050/inventory` y escribir términos como `calculo`, `stewart`, `redes`, `ross`, `005.1` o `FOL-TECNM-004` para ver el filtrado en tiempo real desde PostgreSQL.
