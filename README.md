# TecNM Campus Monclova — Plantilla Base de Proyectos

Este repositorio sirve como la **plantilla oficial de referencia (template)** para el desarrollo de todas las aplicaciones web y servicios del **TecNM Campus Monclova**.

Su propósito es estandarizar la arquitectura, calidad de código y patrones de diseño en el desarrollo de software institucional, asegurando mantenibilidad, escalabilidad e interoperabilidad entre proyectos.

---

## 🤖 Desarrollo Guiado por Especificaciones (Spec-Driven Development - SDD)

El trabajo y colaboración con **Agentes de Inteligencia Artificial** en este ecosistema se rige estrictamente bajo **SDD (Spec-Driven Development)**:

1. **Especificación Primero:** Antes de generar o modificar código en cualquier módulo, se deben redactar o actualizar los documentos en su carpeta local `specs/`.
2. **Contexto Aislado:** Las especificaciones funcionales, casos de uso, contratos y criterios de aceptación residen dentro del propio módulo/slice para dar contexto preciso a los agentes.
3. **Validación Continua:** Los agentes implementan código y pruebas contrastando directamente contra las especificaciones del slice correspondiente.
4. **Regla de Redacción:** Toda especificación y documentación generada por IA debe redactarse utilizando la skill **caveman** para garantizar máxima concisión técnica y eliminar contenido redundante.

### Centralización y Contexto Maestro (`AGENTS.md`)

Para inicializar y mantener la sincronización del contexto global, cada repositorio/proyecto (Backend y Frontend por separado) debe contar con un archivo **`AGENTS.md`** en su raíz:

- **Punto de Entrada del Agente:** Es el primer documento que la IA debe consultar para comprender el sistema.
- **Contenido Requerido:**
  - Resumen y objetivos del proyecto.
  - Reglas operativas, convenciones de código y estándares del campus.
  - Índice / mapa centralizado que referencia a todos los módulos (`Modules/` o `src/modules/`), sus componentes clave y sus carpetas `specs/`.
- **Mantenimiento:** Al inicializar un proyecto o crear un nuevo slice/módulo, debe registrarse y enlazarse inmediatamente en `AGENTS.md`.

### Skills Recomendadas para Agentes

Se recomienda el uso de las siguientes skills para optimizar el flujo de desarrollo, diseño e implementación:

- **caveman:** Reducción de ruido y documentación ultra concisa. *(Obligatoria para generar specs)*.
- **frontend-design:** Dirección estética y diseño visual intencional.
- **ui-ux-pro-max:** Sistema de diseño UI/UX, patrones de interacción, accesibilidad y paletas.
- **ponytail:** Simplicidad pragmática y código minimalista (evita sobreingeniería).

#### Comandos de Instalación de Skills

```bash
npx skills add https://github.com/juliusbrussee/caveman --skill caveman
npx skills add https://github.com/anthropics/skills --skill frontend-design
npx skills add https://github.com/nextlevelbuilder/ui-ux-pro-max-skill --skill ui-ux-pro-max
npx skills add https://github.com/dietrichgebert/ponytail --skill ponytail
```

---

## 🏛️ Especificaciones y Arquitecturas

El proyecto se rige por los siguientes estándares arquitectónicos:

- **[Estándar de Autenticación y Sesiones](./AUTH.md):** Especificación de seguridad, cookies `HttpOnly`, ciclo de vida del JWT y soporte para login local y federado (Microsoft Entra / Google).
- **[Arquitectura Backend (.NET 10)](./BACKEND_ARCHITECTURE.md):** Estructura y lineamientos para la API REST, persistencia con EF Core y PostgreSQL, y módulos de negocio con especificaciones locales.
- **[Arquitectura Frontend (Vue 3 + TypeScript)](./FRONTEND_ARCHITECTURE.md):** Estructura y lineamientos para la aplicación SPA con Vite, rutas modulares descentralizadas, componentes reutilizables y especificaciones por slice.

---

## 🌐 Convenciones Transversales

- **Nomenclatura de Base de Datos:** `snake_case` en tablas, columnas, índices, constraints y vistas de PostgreSQL.
- **Idioma del Código:** inglés para todo identificador, archivo, ruta y API.
- **Idioma de la Interfaz:** español de México (es-MX) para todo texto visible al usuario, mensajes de error y de estado.

---

## 📋 Planes de Implementación (`plans/`)

Las hojas de ruta, fases de ejecución técnica y planes de trabajo generados para agentes o desarrolladores se centralizan en el directorio `plans/`:

- **[01. Plan de Autenticación Local](./plans/01-auth-implementation.md):** Plan inicial de construcción del esqueleto Backend, Frontend y flujo de autenticación local con PostgreSQL y JWT en cookies.
