# Bitácora de Cambios del Proyecto (Sistema de Biblioteca — TecNM Campus Monclova).......


> **Propósito de este documento:** Registrar de forma clara y detallada cada cambio, archivo modificado y nueva funcionalidad implementada para que todo el equipo (Odeth y compañera) tenga visibilidad exacta de qué se modificó antes y después de subir cambios al repositorio.

---

## 1. Configuración de Puertos, Docker y Entorno

### 1.1. Estandarización de Puertos (Frontend: `6050` | Backend: `6060`)
Se invirtieron y estandarizaron los puertos en todo el proyecto para que el **Frontend** corra siempre en el puerto **`6050`** y el **Backend** en el puerto **`6060`**:

| Archivo Modificado | Qué se cambió |
| :--- | :--- |
| `compose.yaml` y `docker/docker-compose.yml` | • `backend`: se cambió `ASPNETCORE_URLS` a `http://+:6060`, se publicó el puerto `"6060:6060"`, `expose: "6060"` y se ajustó `Cors__AllowedOrigins` a `http://localhost:6050,http://127.0.0.1:6050`.<br>• `nginx`: se cambió el puerto publicado a `"6050:6050"` y el contexto de build a la raíz para compilar y servir el frontend de Vue 3. |
| `backend/Dockerfile` | Se actualizó `ASPNETCORE_URLS=http://+:6060` y `EXPOSE 6060`. |
| `docker/nginx/Dockerfile` | Se agregó una etapa multi-stage (`node:24-alpine`) que compila `frontend/` (`npm ci && npm run build`) y copia `/app/dist` a `/usr/share/nginx/html` dentro del contenedor Debian 13 con Nginx, exponiendo el puerto `6050`. |
| `docker/nginx/nginx.conf` | • `listen 6050;` sirviendo los estáticos de Vue (`/usr/share/nginx/html`) con soporte SPA (`try_files $uri $uri/ /index.html`).<br>• Proxy inverso en `/api/` y `/health` apuntando a `backend:6060`. |
| `frontend/Dockerfile` y `frontend/docker/default.conf` | Se actualizó `EXPOSE 6050`, `listen 6050 ssl;` y `proxy_pass https://backend:6060;`. |
| `frontend/vite.config.ts` | Se cambió el puerto del servidor de desarrollo de `5173` a `6050` (manteniendo el proxy `/api` hacia `http://localhost:6060`). |
| `backend/Program.cs`, `backend/appsettings.json`, `backend/appsettings.Development.json` | Se actualizaron los orígenes CORS permitidos de `5173` a `6050`. |
| `backend/Properties/launchSettings.json` | Se actualizó `applicationUrl` a `https://localhost:6060;http://localhost:6060`. |
| `.env.example`, `scripts/setup-dev.py`, `scripts/check-dev-ports.py`, `scripts/smoke-template.sh` | Se actualizaron los puertos predeterminados a `6050` (frontend) y `6060` (backend). |
| `README.md`, `docs/setup.md`, `specs/docker.spec.md`, `CONTRIBUTING.md` | Se actualizaron todas las tablas de puertos y comandos de documentación a `6050` y `6060`. |

### 1.2. Corrección de Errores y Descarga de Dependencias / Skills
| Elemento | Acción realizada |
| :--- | :--- |
| `frontend/tsconfig.json` | Se restauró la llave de apertura `{` en la línea 1 que faltaba y causaba error de sintaxis JSON. |
| Dependencias Frontend y Backend | Se ejecutó `npm --prefix frontend ci` y `dotnet restore backend/TecNM.Api.csproj`, verificando que ambos compilan con **0 errores**. |
| Skills de Agente (`.agents/skills/`) | Se instalaron las skills `grilling` (requerida por `CONTRIBUTING.md`), `caveman` y `ponytail`. |

---

## 2. Cambios Implementados para **Tópicos de Base de Datos (`IFF-1026`)** y Solución de `Borrower` (Alumnos vs. Docentes/Administrativos)

### 2.1. Solución en `Borrower` para cuando se registra un Maestro (Docente) o Administrativo
**Problema detectado por Odeth:** En `Borrower` solo existía `studentid NOT NULL UNIQUE`, pero cuando un **Maestro (Docente)** o **Administrativo** se registra o registra su visita a la biblioteca, no tiene número de control de alumno sino **Clave de Empleado / Nómina**, además de que necesitábamos distinguir en la base de datos si el visitante/lector es `Alumno`, `Docente` o `Administrativo`.

**Cómo se resolvió (en `database.sql`, `backend/Features/Books/Borrower.cs` y `backend/Data/TecNMDbContext.cs`):**
1. **`borrower_type VARCHAR(20) NOT NULL DEFAULT 'Alumno'`**:
   - Restricción `chk_borrower_type`: solo permite `'Alumno'`, `'Docente'` o `'Administrativo'`.
   - Permite que el módulo de **Registro de Asistencia (`Visit`)** de Odeth distinga exactamente cuántas visitas son de Alumnos, cuántas de Docentes y cuántas de Administrativos.
2. **Separación en 3FN de `studentid` y `employeeid` + Llave Foránea Lógica `institutional_id`**:
   - **`studentid VARCHAR(30) NULL UNIQUE`**: Número de Control (exclusivo para `'Alumno'`).
   - **`employeeid VARCHAR(30) NULL UNIQUE`**: Clave de Empleado / Nómina (exclusivo para `'Docente'` y `'Administrativo'`, ej. `'DOC-ISC-014'`, `'ADM-BIB-003'`).
   - **`institutional_id VARCHAR(30) GENERATED ALWAYS AS (COALESCE(studentid, employeeid)) STORED UNIQUE`**: Columna calculada automáticamente por PostgreSQL que devuelve siempre el identificador institucional único (ya sea número de control o clave de empleado) y actúa como **Llave Foránea Lógica hacia `TecNM_LoginControl`**.
   - **Restricción `chk_borrower_identifier_by_type`**:
     - Si `borrower_type = 'Alumno'` → exige `studentid IS NOT NULL AND employeeid IS NULL`.
     - Si `borrower_type IN ('Docente', 'Administrativo')` → exige `employeeid IS NOT NULL AND studentid IS NULL AND semester IS NULL` (los docentes y administrativos no tienen semestre).
3. **Actualización en Backend C# (`Borrower.cs` y `TecNMDbContext.cs`)**:
   - Se agregaron las propiedades `BorrowerType` (`borrower_type`), `EmployeeId` (`employeeid`), `InstitutionalId` (`institutional_id`, generada por BD) y se marcó `StudentId` como nullable (`string?`) manteniendo compatibilidad total con el resto del backend.

### 2.2. Auditoría Activa de Transacciones (Triggers), Particionamiento y Vistas en `database.sql`
| Elemento Agregado en `database.sql` | Descripción |
| :--- | :--- |
| **Tabla `AuditLog` Particionada por Rango (`PARTITION BY RANGE (operation_date)`)** | Bitácora activa de auditoría con particiones semestrales (`AuditLog_2026_H1`, `AuditLog_2026_H2` y `AuditLog_Default`). |
| **Función `fn_register_audit_log()` y Triggers (`trg_audit_*`)** | Triggers `AFTER INSERT OR UPDATE OR DELETE` sobre las tablas críticas `Book`, `Loan`, `Borrower`, `Visit` y `BookStatus`. Guardan automáticamente tabla, ID de registro, operación, usuario institucional, usuario de motor PostgreSQL, fecha/hora y detalle `JSONB` con estado anterior (`old_data`) y nuevo (`new_data`). |
| **Vistas SQL (`vw_attendance_summary_by_type`, `vw_active_loans_detail`, `vw_inventory_metrics`)** | Vistas de base de datos optimizadas para reportes de asistencia (separando Alumnos, Docentes y Administrativos), préstamos activos/vencidos e inventario. |

### 2.3. Scripts Automatizados de Respaldo, Restauración (*Disaster Recovery*) y Replicación Maestro-Esclavo
| Archivo Nuevo | Función |
| :--- | :--- |
| `database/scripts/backup-full.sh` | Script automatizado de respaldo completo (`pg_dump -Fc`) con verificación de integridad `SHA-256` y política de retención de 7 copias. |
| `database/scripts/backup-incremental.sh` | Script automatizado de respaldo incremental (`pg_switch_wal` + `pg_basebackup`) y exportación diferencial de `AuditLog`. |
| `database/scripts/restore-disaster-recovery.sh` | Script automatizado de restauración y recuperación ante desastres (`pg_restore --clean`) con validación post-recuperación. |
| `docker/docker-compose.replication.yml` | Orquestación de esquema Maestro-Esclavo (`db_master` con `wal_level=replica` y `db_replica` con `hot_standby=on`) para lectura de reportes sin afectar la transaccionalidad. |
| `database/scripts/verify-topicos-bd.ps1` | Script automatizado en PowerShell para comprobar en vivo `Borrower` (Alumnos/Docentes), Triggers de Auditoría (`AuditLog`), Particiones, Vistas y Respaldo en Windows. |
| `docs/TOPICOS_BASE_DE_DATOS.md` | Documentación técnica completa de todos los puntos de la asignatura `IFF-1026` lista para la defensa técnica en plenaria. |

---

## 3. Implementación de Backend y Reglas de Negocio para **Inventario** y **Circulación y Préstamos** (Sin tocar módulos de Odeth)

> **Garantía de Aislamiento:** No se modificó ningún archivo de `frontend/src/modules/attendance/` ni `frontend/src/modules/dashboard/`. Todo se implementó respetando estrictamente la arquitectura multicapa y Vertical Slice solicitada por los profesores (**Thin Controllers + Fat Services + DTOs desacoplados + Cero SQL crudo en C#**).

### 3.1. Cumplimiento de las 5 Reglas de Negocio Acordadas con Odeth
| Regla de Negocio | Implementación en Base de Datos, Backend (.NET 10) y Frontend (Vue 3) |
| :--- | :--- |
| **1. Folios de libros asignados a partir del `5000` en adelante (consecutivos y sin duplicados)** | • En `database.sql` y `InventoryView.vue`, todos los folios inician en `5000` (`5000`, `5001`, `5002`...).<br>• En `BookService.cs` se creó `GetNextAvailableFolioAsync()` y el endpoint `GET /api/books/next-folio`, que inspecciona todos los folios en PostgreSQL y calcula el siguiente número consecutivo disponible a partir del `5000`.<br>• Antes de asignar o guardar un folio (`CreateBookAsync` y `UpdateBookAsync`), el servicio verifica si el folio ya existe en la BD; si existe, evita duplicados (`409 Conflict`) e informa cuál es el siguiente consecutivo libre. |
| **2. Plazo de entrega de 3 días y renovación por +3 días** | • En `CirculationService.cs`, al registrar un préstamo nuevo (`POST /api/circulation/loans`), la fecha límite de entrega se asigna exactamente a **3 días** (`StartDate.AddDays(3)`).<br>• Al renovar un préstamo (`PUT /api/circulation/loans/{id}/renew`), se suman **+3 días adicionales** al plazo de entrega (`DueDate.AddDays(3)`). |
| **3. Sin multas monetarias → Alertas de Estudiantes con Bloqueo de Inscripción** | • Se eliminaron todas las multas en dinero (`$ MXN`).<br>• Todo préstamo vencido activa automáticamente el estado **`Bloqueo de Inscripción`** (`HasEnrollmentBlock = true`).<br>• En `CirculationView.vue` se implementó el **Panel de Alertas Activas: Estudiantes con Bloqueo de Inscripción**, que muestra matrícula, nombre, carrera, folio adeudado, días de retraso y el botón directo **"Recibir y Liberar"** para facilitar la liberación del bloqueo al devolver el libro. Además, el sistema impide prestar nuevos libros a un estudiante que tenga bloqueo de inscripción activo. |
| **4. Catálogo Oficial de 7 Tipos de Servicios (`Service`)** | • En `database.sql` se actualizó la tabla `Service` con los 7 tipos oficiales: **`Presencial`**, **`Física`**, **`Virtual`** *(uso de computadoras)*, **`Reunión`** *(directivos, maestros)*, **`Clase`**, **`Mantenimiento`** y **`Otra`**. |
| **5. Barra de búsqueda en Inventario insensible a acentos/mayúsculas/minúsculas + búsqueda por Título, Dewey y Folio** | • En `BookService.cs` (`NormalizeSearchText` con Unicode `FormD`) y en `InventoryView.vue` (`normalizeOfflineText`), la búsqueda ignora acentos/tildes y mayúsculas/minúsculas (ej. buscar `calculo` o `CALCULO` encuentra *"Cálculo de una Variable"*).<br>• Se agregó el selector de campo en la barra de búsqueda del Inventario para filtrar por **Todo (Título, Dewey, Folio)**, **Solo Título de la Obra**, **Código Dewey (CDD)** o **Folio (`5000+`)**. |

### 3.2. Archivos Creados o Modificados en esta Etapa
- **Base de Datos**:
  - `database.sql` (folios `5000`..`5007`, préstamos a 3 días y catálogo `Service` con los 7 tipos de servicio).
- **Backend (`.NET 10` — Thin Controllers + Fat Services + DTOs)**:
  - `backend/Features/Books/BookDtos.cs`, `backend/Features/Books/BookService.cs`, `backend/Features/Books/BooksController.cs`
  - `backend/Features/Circulation/CirculationDtos.cs`, `backend/Features/Circulation/CirculationService.cs`, `backend/Features/Circulation/CirculationController.cs`
  - `backend/Program.cs` (registro en contenedor de Inyección de Dependencias de `IBookService` e `ICirculationService`).
- **Frontend (`Vue 3 + TypeScript`)**:
  - `frontend/src/modules/inventory/types/inventory.ts`, `frontend/src/modules/inventory/api/inventoryApi.ts`, `frontend/src/modules/inventory/views/InventoryView.vue`
  - `frontend/src/modules/circulation/types/circulation.ts`, `frontend/src/modules/circulation/api/circulationApi.ts`, `frontend/src/modules/circulation/views/CirculationView.vue`
