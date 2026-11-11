# Template agnóstico TecNM

## Alcance

Base técnica para aplicaciones y microservicios: .NET 10, EF Core, PostgreSQL, Vue 3, TypeScript y componentes institucionales. Cada proyecto define su dominio.

- Backend conserva configuración, DbContext sin entidades y health check público.
- Frontend conserva shell, tema y componentes reutilizables; muestra una página inicial pública y neutra.
- Los módulos y datos de negocio se definen en cada proyecto.
- `database.sql` en raíz es el punto de entrada para inicializar PostgreSQL; inicialmente solo contiene comentarios.
- Setup conserva HTTPS, comprobación de puertos, contenedores separados y persistencia. No depende de tablas concretas.

## Responsabilidad de cada proyecto

Definir módulos, entidades, esquema SQL, migraciones e integraciones. Actualizar specs antes de cambiar comportamiento o contratos. Los `AGENTS.md` contienen patrones de diseño y reglas de desarrollo; los requisitos funcionales pertenecen a las specs.

## Trabajo desde la raíz

- `AGENTS.md` raíz define reglas compartidas y cómo coordinar cambios entre backend, frontend e infraestructura.
- Los `AGENTS.md` de backend y frontend conservan las reglas técnicas de su área y complementan al de raíz.
- `CONTRIBUTING.md` documenta el flujo ODD, su relación con SDD, las verificaciones por alcance y la preparación de contribuciones desde un fork.
- `odd/` ofrece seguimiento opcional para trabajo extenso; las specs siguen siendo la fuente de requisitos y contratos.
- Los tres `AGENTS.md` indican verificar y priorizar la skill `grilling` al aclarar decisiones relevantes para specs; cambios simples y claros pueden omitir la entrevista.
- `CONTRIBUTING.md` recomienda `grilling` para preparar specs y documenta su instalación.
- Las guías deben describir rutas, comandos y configuración existentes, y distinguir recomendaciones de capacidades implementadas.

## Aceptación

1. Frontend compila y abre la página pública `/` con navegación y selector de tema.
2. Backend compila y responde `200 { "status": "ok" }` en `/api/health`.
3. Una ruta de API no registrada devuelve `404`.
4. PostgreSQL vacío inicia con el `database.sql` de comentarios, sin tablas de aplicación.
5. SQL propio se ejecuta al inicializar un volumen nuevo; reiniciar no vuelve a ejecutarlo ni borra datos existentes.
6. Desde el README se accede a las reglas raíz y a la guía de contribución; estas enlazan las instrucciones de cada área sin duplicar contratos funcionales.
