#!/usr/bin/env bash
# ==============================================================================
# Respaldo Incremental / Archivado WAL (Write-Ahead Logging) — PostgreSQL 17.4
# Asignatura: Tópicos de Base de Datos (IFF-1026) — TecNM Campus Monclova
# ==============================================================================
set -euo pipefail

CONTAINER_NAME="${DB_CONTAINER:-tecnm-library-postgres}"
DB_NAME="${POSTGRES_DB:-tecnm_library}"
DB_USER="${POSTGRES_USER:-tecnm_admin}"
INCREMENTAL_DIR="${BACKUP_DIR:-./database/backups/incremental}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TARGET_DIR="${INCREMENTAL_DIR}/wal_${TIMESTAMP}"

mkdir -p "${TARGET_DIR}"

echo "[1/3] Forzando rotación de segmento WAL actual (pg_switch_wal)..."
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" -c "SELECT pg_switch_wal();"

echo "[2/3] Extrayendo respaldo base + segmentos WAL incrementales (pg_basebackup)..."
docker exec "${CONTAINER_NAME}" pg_basebackup -U "${DB_USER}" -D "/tmp/basebackup_${TIMESTAMP}" -Ft -z -X fetch -P
docker cp "${CONTAINER_NAME}:/tmp/basebackup_${TIMESTAMP}/." "${TARGET_DIR}/"
docker exec "${CONTAINER_NAME}" rm -rf "/tmp/basebackup_${TIMESTAMP}"

echo "[3/3] Exportando diferencial de bitácora de auditoría (AuditLog) de las últimas 24 horas..."
docker exec "${CONTAINER_NAME}" psql -U "${DB_USER}" -d "${DB_NAME}" \
  -c "\copy (SELECT * FROM AuditLog WHERE operation_date >= NOW() - INTERVAL '24 hours') TO STDOUT WITH CSV HEADER" \
  > "${TARGET_DIR}/auditlog_delta_${TIMESTAMP}.csv"

echo "OK: Respaldo incremental y segmentos WAL almacenados en ${TARGET_DIR}"
