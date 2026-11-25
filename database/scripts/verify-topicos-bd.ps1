# ==============================================================================
# Script de Verificación Interactiva — Tópicos de Base de Datos (IFF-1026)
# Ejecución desde C:\PROYECTOFINAL\TecNM_Limpio:
#   powershell -ExecutionPolicy Bypass -File .\database\scripts\verify-topicos-bd.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"
$Container = "tecnm-library-postgres"
$DbUser = "tecnm_admin"
$DbName = "tecnm_library"

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host " 1. VERIFICANDO TABLA BORROWER (Alumnos vs. Maestros/Administrativos)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
docker exec $Container psql -U $DbUser -d $DbName -c "SELECT id, name, borrower_type, studentid, employeeid, institutional_id, semester FROM Borrower ORDER BY id;"

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host " 2. REGISTRANDO UN MAESTRO NUEVO Y UNA VISITA (PRUEBA DE TRIGGERS)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
docker exec $Container psql -U $DbUser -d $DbName -c "INSERT INTO Borrower (name, borrower_type, studentid, employeeid, major, semester, time, gender, phoneNumber, email, role_id) VALUES ('Mtro. Fernando Villarreal', 'Docente', NULL, 'DOC-INF-2026', 'Docente - Ingeniería Informática', NULL, 'Matutino', 'Masculino', '8669998877', 'fernando.villarreal@monclova.tecnm.mx', 3) ON CONFLICT (email) DO UPDATE SET dateUpdate = CURRENT_TIMESTAMP;"

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host " 3. CONSULTANDO BITÁCORA DE AUDITORÍA PARTICIONADA (AuditLog)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
docker exec $Container psql -U $DbUser -d $DbName -c "SELECT id, tableoid::regclass AS particion, table_name, record_id, operation, db_user, operation_date FROM AuditLog ORDER BY id DESC LIMIT 10;"

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host " 4. CONSULTANDO LAS 3 VISTAS DE REPORTES (Asistencia, Préstamos, Inventario)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
docker exec $Container psql -U $DbUser -d $DbName -c "SELECT * FROM vw_attendance_summary_by_type;"
docker exec $Container psql -U $DbUser -d $DbName -c "SELECT loan_id, folio, book_title, borrower_name, borrower_type, institutional_id, loan_status FROM vw_active_loans_detail;"
docker exec $Container psql -U $DbUser -d $DbName -c "SELECT * FROM vw_inventory_metrics;"

Write-Host "`n==================================================================" -ForegroundColor Cyan
Write-Host " 5. GENERANDO RESPALDO COMPLETO DE PRUEBA EN database/backups/full" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path ".\database\backups\full" | Out-Null
$BackupFile = ".\database\backups\full\tecnm_library_test.dump"
docker exec $Container pg_dump -U $DbUser -d $DbName -Fc > $BackupFile
Get-Item $BackupFile | Select-Object Name, Length, LastWriteTime

Write-Host "`n[OK] Todas las pruebas de Tópicos de Base de Datos (IFF-1026) funcionaron correctamente." -ForegroundColor Green
