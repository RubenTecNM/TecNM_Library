# Guía de Tópicos de Base de Datos (IFF-1026) — Sistema de Biblioteca

Este documento describe cómo el módulo de **Biblioteca Central** del TecNM Campus Monclova cumple con todos los requerimientos curriculares de **Tópicos de Base de Datos (`IFF-1026`)**.

---

## 1. Modelo Normalizado (3FN), Desacoplamiento de `TecNM_LoginControl` y Manejo de Alumnos vs. Docentes/Administrativos

### ¿Cómo se maneja cuando se registra un Alumno vs. un Maestro (Docente) o Administrativo?
En la tabla [`Borrower`](../database.sql), los usuarios de la biblioteca pueden ser **Alumnos**, **Docentes (Maestros)** o **Administrativos**:
- **`borrower_type VARCHAR(20) NOT NULL DEFAULT 'Alumno'`**: Distingue el tipo de usuario institucional (`'Alumno'`, `'Docente'`, `'Administrativo'`).
- **`studentid VARCHAR(30) NULL UNIQUE`**: Almacena el **Número de Control** exclusivamente cuando el usuario es `'Alumno'` (ej. `21280541`).
- **`employeeid VARCHAR(30) NULL UNIQUE`**: Almacena la **Clave de Empleado / Nómina** exclusivamente cuando el usuario es `'Docente'` o `'Administrativo'` (ej. `DOC-ISC-014`, `ADM-BIB-003`).
- **`institutional_id VARCHAR(30) GENERATED ALWAYS AS (COALESCE(studentid, employeeid)) STORED UNIQUE`**: Columna generada automáticamente por PostgreSQL que expone la **Llave Foránea Lógica Institucional** hacia `TecNM_LoginControl`, sin importar si la persona es alumno o docente.
- **Restricción de integridad (`chk_borrower_identifier_by_type`)**:
  - Si `borrower_type = 'Alumno'`: exige `studentid IS NOT NULL` y `employeeid IS NULL`.
  - Si `borrower_type IN ('Docente', 'Administrativo')`: exige `employeeid IS NOT NULL`, `studentid IS NULL` y `semester IS NULL` (ya que los maestros y administrativos no cursan un semestre; en `major` registran su Departamento o Academia de adscripción).

---

## 2. Bitácoras Activas de Auditoría (Triggers) y Particionamiento

En [`database.sql`](../database.sql) (secciones 13 y 14):
- **Tabla `AuditLog` particionada por rango (`PARTITION BY RANGE (operation_date)`)**:
  - Particiones activas: `AuditLog_2026_H1`, `AuditLog_2026_H2` y `AuditLog_Default`.
- **Función PL/pgSQL `fn_register_audit_log()` y Triggers (`AFTER INSERT OR UPDATE OR DELETE`)**:
  - Activos sobre las entidades críticas: `Book`, `Loan`, `Borrower`, `Visit` y `BookStatus`.
  - Registran automáticamente: tabla, ID del registro, operación (`INSERT`, `UPDATE`, `DELETE`), ID de usuario institucional, usuario de motor PostgreSQL, fecha/hora exacta, y el estado previo (`old_data` en `JSONB`) y nuevo (`new_data` en `JSONB`).

---

## 3. Esquema de Replicación Maestro-Esclavo y Vistas de Reportes

- **Instancia Maestro (`db` / Primary)**: Recibe todas las transacciones de escritura (`INSERT`, `UPDATE`, `DELETE`).
- **Instancia Esclavo (`db_replica` / Standby)**: Configurada mediante replicación por streaming (`pg_basebackup` + `standby.signal`) en [`docker/docker-compose.replication.yml`](../docker/docker-compose.replication.yml) para absorber la lectura de reportes y dashboards sin afectar la transaccionalidad del nodo maestro.
- **Vistas SQL de Reporte en [`database.sql`](../database.sql)**:
  - `vw_attendance_summary_by_type`: Resumen de visitas agrupado por fecha, tipo de usuario (`Alumno`, `Docente`, `Administrativo`), género, turno, carrera/departamento y servicio.
  - `vw_active_loans_detail`: Detalle de préstamos activos/vencidos con `institutional_id` y tipo de prestatario.
  - `vw_inventory_metrics`: Contadores consolidados del acervo por estado.

---

## 4. Políticas de Respaldo Automatizado y Recuperación ante Desastres (*Disaster Recovery*)

Ubicación de los scripts: [`database/scripts/`](../database/scripts/)

| Script | Tipo | Comando de ejecución |Objetivo (RPO / RTO) |
| :--- | :--- | :--- | :--- |
| `backup-full.sh` | Respaldo Completo (`pg_dump -Fc` + SHA-256 + retención de 7 copias) | `bash database/scripts/backup-full.sh` | **RPO:** 24 h (combinado con WAL: < 15 min) |
| `backup-incremental.sh` | Respaldo Incremental (`pg_switch_wal` + `pg_basebackup` + delta CSV de `AuditLog`) | `bash database/scripts/backup-incremental.sh` | **RPO:** < 15 minutos |
| `restore-disaster-recovery.sh` | Restauración y verificación de integridad post-desastre (`pg_restore --clean`) | `bash database/scripts/restore-disaster-recovery.sh <archivo.dump>` | **RTO:** < 10 minutos |
