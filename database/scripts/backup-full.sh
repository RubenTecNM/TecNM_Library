#!/usr/bin/env bash
# ==============================================================================
# Respaldo Completo Automatizado (Full Backup) — PostgreSQL 17.4
# Asignatura: Tópicos de Base de Datos (IFF-1026) — TecNM Campus Monclova
# ==============================================================================
set -euo pipefail

CONTAINER_NAME="${DB_CONTAINER:-tecnm-library-postgres}"
DB_NAME="${POSTGRES_DB:-tecnm_library}"
DB_USER="${POSTGRES_USER:-tecnm_admin}"
BACKUP_DIR="${BACKUP_DIR:-./database/backups/full}"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_full_${TIMESTAMP}.dump"

mkdir -p "${BACKUP_DIR}"

echo "[1/3] Iniciando respaldo completo (pg_dump formato custom comprimido) de ${DB_NAME}..."
docker exec "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" -Fc > "${BACKUP_FILE}"

echo "[2/3] Generando suma de verificación SHA-256..."
sha256sum "${BACKUP_FILE}" > "${BACKUP_FILE}.sha256"

echo "[3/3] Aplicando política de retención (conservar últimos 7 respaldos completos)..."
ls -1t "${BACKUP_DIR}"/${DB_NAME}_full_*.dump 2>/dev/null | tail -n +8 | xargs -r rm -f

echo "OK: Respaldo completo generado en ${BACKUP_FILE}"
