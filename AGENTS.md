# Reglas compartidas de desarrollo

## Alcance y lectura

Este archivo aplica a todo el repositorio. El trabajo se coordina desde esta raíz, con backend y frontend como partes del mismo proyecto.

- Leer [README.md](README.md) y [CONTRIBUTING.md](CONTRIBUTING.md) antes de cambiar archivos.
- Para `backend/`, leer también [backend/AGENTS.md](backend/AGENTS.md).
- Para `frontend/`, leer también [frontend/AGENTS.md](frontend/AGENTS.md).
- Para setup, Compose o SQL, consultar [docs/setup.md](docs/setup.md) y [specs/docker.spec.md](specs/docker.spec.md).
- Las reglas locales especializan las compartidas dentro de su área. En cambios transversales, consultar ambas áreas y resolver contradicciones antes de implementar.
- Mantener aquí reglas de trabajo y coordinación. Los requisitos, contratos y criterios de aceptación pertenecen a las specs; los comandos y el flujo de contribución, a `CONTRIBUTING.md`.

## Flujo de trabajo

- Revisar rama, `git status` y cambios preexistentes. Conservar trabajo ajeno al alcance solicitado.
- Identificar objetivo, alcance, restricciones y resultado verificable. Explorar implementación y documentación antes de editar.
- Avanzar con las decisiones técnicas rutinarias dentro del alcance autorizado. Preguntar cuando una incertidumbre afecte producto, contratos, datos o autorización.
- Aplicar ODD para delimitar, explorar, implementar, verificar y cerrar el trabajo; seguir [odd/README.md](odd/README.md).
- Al preparar specs, verificar si la skill `grilling` está disponible en el entorno y priorizar su uso cuando falten decisiones relevantes de producto, reglas de negocio o contratos. Investigar primero los hechos disponibles y consultar al usuario sobre las decisiones pendientes.
- Omitir la entrevista cuando el cambio sea simple y sus requisitos estén claros. Si la skill falta, informarlo, indicar el comando de instalación de [CONTRIBUTING.md](CONTRIBUTING.md#skill-grilling) y aclarar igualmente las decisiones necesarias con el usuario.
- Aplicar SDD dentro de ese flujo: actualizar la spec correspondiente antes de modificar comportamiento o contratos. Usar specs raíz para acuerdos compartidos y specs cercanas al código para detalles locales.
- Hacer el cambio más pequeño que resuelva el objetivo, respetando la arquitectura y los componentes existentes.
- Para trabajo extenso o que requiera continuidad, registrar tareas, decisiones y evidencia en `odd/tasks/<feature>.md` con la [plantilla](odd/tasks/TEMPLATE.md). No exigir seguimiento formal para cambios triviales.
- Actualizar documentación y referencias afectadas junto con el cambio. Distinguir lo implementado de propuestas y planes pendientes.

## Coordinación y convenciones

- Mantener el template agnóstico: las funcionalidades de negocio pertenecen a cada proyecto derivado. No agregar dependencias de dominio como requisito del arranque base.
- Cuando cambie una API, actualizar primero su contrato compartido y revisar DTOs backend, cliente frontend, errores y verificaciones afectados.
- Cuando cambie persistencia, revisar conjuntamente SQL, mapeos EF Core, setup, Compose y documentación. Editar `database.sql` no migra volúmenes existentes.
- Escribir identificadores, archivos y rutas en inglés; objetos PostgreSQL en `snake_case`; interfaz, errores y documentación en español de México.
- Mantener secretos, datos personales, archivos `.env`, claves TLS y respaldos fuera de Git. Usar ejemplos saneados.
- Evitar dependencias nuevas, abstracciones o refactors que no sean necesarios para el objetivo.

## Verificación y cierre

- Elegir verificaciones según el alcance; seguir [CONTRIBUTING.md](CONTRIBUTING.md#verificación-por-alcance) y los criterios de las specs afectadas.
- Para un fallo reproducible, añadir una prueba de regresión aplicable. En cambios solo documentales, comprobar rutas, comandos, afirmaciones y formato.
- Usar recursos aislados para pruebas con estado. No usar bases reales, migraciones, restauraciones ni despliegues como comprobaciones rutinarias.
- No descartar cambios preexistentes ni ejecutar operaciones destructivas sin autorización. Hacer commits, push, PR o publicaciones solo cuando la instrucción del usuario los autorice.
- Reportar qué cambió, verificaciones ejecutadas y resultados, límites y pendientes. No presentar un build como prueba funcional ni una comprobación no ejecutada como aprobada.
