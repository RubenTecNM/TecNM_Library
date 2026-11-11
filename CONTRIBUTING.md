# Contribuir al template TecNM

Esta guía aplica al trabajo conjunto desde la raíz del repositorio. Adapta el flujo Organic Driven Development (ODD) compartido como ejemplo y lo combina con SDD.

ODD organiza el trabajo: acordar el alcance, explorar, implementar, verificar y registrar lo aprendido. SDD define el comportamiento esperado: requisitos, contratos y criterios de aceptación en specs. Para un cambio funcional, ODD guía el proceso y SDD indica qué debe cumplir el resultado.

## Camino rápido

1. Revisar `git status` y la rama actual. Leer [README.md](README.md), [AGENTS.md](AGENTS.md) y las reglas del área afectada: [backend](backend/AGENTS.md) o [frontend](frontend/AGENTS.md).
2. Definir objetivo, alcance, restricciones y resultado comprobable. Explorar código y documentación; resolver incertidumbres que afecten comportamiento, datos o contratos.
3. Actualizar la spec correspondiente y hacer el cambio mínimo. Ajustar juntos código, contratos y manuales afectados.
4. Ejecutar las verificaciones pertinentes. Registrar resultados, fallos y aquello que no se pudo comprobar.
5. Revisar el diff y preparar una contribución enfocada. Al cerrar, explicar el resultado, sus límites y los pendientes.

## Flujo ODD con SDD

### Autorizar

Definir el resultado y alcance autorizado. La investigación y las propuestas son de solo lectura; una petición clara de implementación autoriza los cambios necesarios dentro de su alcance. Aclarar decisiones de producto, cambios de alcance u operaciones que requieran autorización antes de ejecutarlos.

### Explorar y delimitar

Usar la implementación actual y sus specs para entender el estado del proyecto. Un plan o propuesta pendiente no prueba que una funcionalidad exista. Si código y documentación discrepan, identificar la diferencia antes de cambiar comportamiento.

Avanzar con las decisiones técnicas rutinarias que entren en el alcance autorizado. Preguntar cuando falte una decisión de producto, contrato o autorización que cambie ese alcance.

### Especificar e implementar

- Se recomienda usar la skill `grilling` para preparar y construir specs cuando existan decisiones relevantes por aclarar; investigar primero los hechos disponibles y consultar al usuario sobre las decisiones pendientes. Un cambio simple y claro puede omitir la entrevista.
- Documentar requisitos, contratos y criterios de aceptación en `specs/`, junto al módulo cuando corresponda.
- Actualizar contratos compartidos antes de modificar sus consumidores. Revisar backend y frontend en cambios de API.
- Conservar los `AGENTS.md` como reglas de trabajo y patrones de diseño; evitar duplicar en ellos requisitos funcionales.
- Mantener cambios pequeños y enfocados; reutilizar componentes y patrones existentes.
- Para un fallo determinista, reproducirlo con una prueba de regresión aplicable y verificar la corrección. No crear pruebas de comportamiento para cambios solo documentales.

### Dar seguimiento y cerrar

Si el trabajo es extenso o requiere continuidad, usar `odd/tasks/<feature>.md` y la [plantilla](odd/tasks/TEMPLATE.md) para registrar objetivo, requisitos y specs de referencia, tareas, decisiones, verificaciones y pendientes. Consultar [odd/README.md](odd/README.md). Los cambios pequeños no requieren un plan separado.

Al terminar, indicar qué cambió, qué verificaciones se ejecutaron y sus resultados, riesgos o limitaciones y el siguiente paso si queda trabajo pendiente. Separar resultados comprobados de suposiciones; un build no sustituye una prueba funcional pertinente.

### Skill grilling

Cada agente debe verificar si `grilling` está disponible en su entorno antes de preparar specs y priorizar su uso cuando necesite aclarar decisiones relevantes. Para instalarla:

```bash
npx skills add https://github.com/mattpocock/skills --skill grilling
```

Si no está disponible, el agente debe informarlo y compartir este comando. Mientras tanto, debe investigar el contexto y preguntar por las decisiones que no pueda resolver por su cuenta. Seguir las instrucciones de la skill cuando se utilice, incluyendo las rondas de preguntas y la confirmación del entendimiento antes de implementar.

## Entorno y persistencia

Seguir los prerrequisitos y comandos del [README](README.md) y la [guía de setup](docs/setup.md). Docker Compose administra PostgreSQL, backend y frontend; la ejecución manual requiere herramientas y una conexión de base propias.

`database.sql` en raíz pertenece al microservicio derivado. Su equipo debe completarlo o adaptar el mecanismo de inicialización. Solo se ejecuta al inicializar un volumen nuevo: editarlo y repetir el setup no migra una base existente.

Evitar conversiones masivas de finales de línea y cambios a `core.autocrlf` para resolver avisos aislados. Revisar el diff y conservar LF en scripts `.sh`. Una política compartida de normalización debe definirse en `.gitattributes` como un cambio explícito, no asumirse a partir de la configuración de un equipo.

## Verificación por alcance

Ejecutar desde la raíz y elegir las comprobaciones que correspondan al cambio; no es necesario reconstruir todo para editar documentación.

| Alcance | Comprobaciones |
| --- | --- |
| Solo documentación | Revisar enlaces y rutas locales, comandos contra la configuración real, afirmaciones y `git diff --check` |
| Backend | `dotnet build backend/TecNM.Api.csproj` y casos de aceptación de las specs afectadas |
| Frontend | `npm --prefix frontend run build`, comprobación del layout y casos de las specs afectadas |
| Interfaz visual | Revisar navegación, accesibilidad, responsive y temas claro/oscuro |
| Setup o Compose | Comprobar puertos, pruebas del setup, configuración Compose y sintaxis de scripts modificados |
| API o cambios transversales | Verificar backend y consumidores, respuestas HTTP y casos de aceptación del contrato |

Instalar dependencias frontend con `npm --prefix frontend ci` cuando sea necesario. Para cambios de UI, ejecutar también:

```bash
(cd frontend && node scripts/check-layout.mjs)
```

Para setup e infraestructura:

```bash
python3 scripts/check-dev-ports.py
python3 scripts/check-setup.py
bash -n scripts/setup-dev.sh scripts/smoke-template.sh
# Con la configuración .env preparada:
docker compose config --quiet
```

`check-setup.py` simula Docker; no demuestra que PostgreSQL haya ejecutado el SQL. Verificar cambios de inicialización en un proyecto y volumen aislados cuando corresponda.

Con el backend disponible, ejecutar la comprobación HTTP básica; ajustar la URL si se cambió el puerto:

```bash
API_URL=https://localhost:7001 bash scripts/smoke-template.sh
```

Esta prueba requiere curl y Python 3. Comprueba el health check y un `404` para una ruta no registrada; añadir las verificaciones funcionales que necesite cada módulo.

## Seguridad y operaciones

- No subir secretos, credenciales, datos personales, `.env`, claves TLS ni respaldos. Usar los `.env.example` saneados para documentar configuración.
- Probar cambios con estado en recursos aislados. No ejecutar operaciones sobre bases reales, migraciones, restauraciones, borrado de volúmenes o despliegues como una prueba rutinaria; requieren alcance y autorización definidos.
- Conservar cambios preexistentes ajenos a la tarea. No usar operaciones Git que los descarten.
- Hacer commits, push y abrir PR cuando formen parte del trabajo autorizado. Pedir autorización antes de ampliar el alcance a publicación u operaciones destructivas.

## Contribuciones desde un fork

1. Crear una rama de trabajo en el fork desde la rama base correspondiente; evitar mezclar cambios ajenos a la contribución.
2. Revisar el diff, incluir los archivos necesarios y excluir secretos y artefactos generados.
3. Crear commits enfocados y subir la rama al fork cuando esté autorizado.
4. Abrir el PR hacia la rama base del repositorio original, comprobando ambos destinos en GitHub.
5. Describir el problema y el comportamiento resultante, el alcance, las verificaciones y sus resultados. Declarar cambios de contrato o persistencia, migraciones necesarias y comprobaciones no ejecutadas.

Resolver observaciones manteniendo código, specs y documentación alineados. No marcar el trabajo como completo si falta una comprobación aplicable; registrar el pendiente y su motivo.
