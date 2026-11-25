#!/usr/bin/env bash
# ==============================================================================
# Restauración y Recuperación ante Desastres (Disaster Recovery) — PostgreSQL 17.4
# Asignatura: Tópicos de Base de Datos (IFF-1026) — TecNM Campus Monclova
# ==============================================================================
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Uso: bash database/scripts/restore-disaster-recovery.sh <ruta_archivo_dump>" >&2
  exit 1
fi

BACKUP_FILE="$1"
CONTAINER_NAME="${DB_CONTAINER:-tecnm-library-postgres}"
DB_NAME="${POSTGRES_DB:-tecnm_library}"
DB_USER="${POSTGRES_USER:-tecnm_admin}"

if [ ! -f "${BACKUP_FILE}" ]; then
  echo "Error: No existe el archivo de respaldo ${BACKUP_FILE}" >&2
  exit 1
fi

if [ -f "${BACKUP_FILE}.sha256" ]; then
  echo "[1/4] Verificando integridad SHA-256 del respaldo..."
  sha256sum -c "${BACKUP_FILE}.sha256"
fi

echo "[2/4] Terminando conexiones activas hacia ${DB_NAME}..."
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${DB_NAME}' AND pid <> pg_backend_pid();"

echo "[3/4] Restaurando base de datos desde ${BACKUP_FILE} (pg_restore --clean)..."
cat "${BACKUP_FILE}" | docker exec -i "${CONTAINER_NAME}" pg_restore -U "${DB_USER}" -d "${DB_NAME}" --clean --if-exists --no-owner

echo "[4/4] Validando integridad post-recuperación (conteo de tablas críticas)..."
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -c \
  "SELECT 'Book' AS tabla, COUNT(*) AS registros FROM Book UNION ALL SELECT 'Borrower', COUNT(*) FROM Borrower UNION ALL SELECT 'Loan', COUNT(*) FROM Loan UNION ALL SELECT 'Visit', COUNT(*) FROM Visit;"

echo "OK: Recuperación ante desastres completada exitosamente."
