# Proyecto Web Frontend

## ¿Qué es este proyecto?
Es una aplicación web de tipo **Single-Page Application (SPA)**. Es una base agnóstica para incorporar los módulos que defina cada proyecto. Incluye inicio público, layout persistente, tema y componentes compartidos.

---

## Tecnologías Principales a Nivel Raíz

- **Framework:** [Vue 3](https://vuejs.org/) (Composition API con `<script setup lang="ts">`)
- **Lenguaje & Tipado:** [TypeScript](https://www.typescriptlang.org/)
- **Empaquetador & Entorno de Construcción:** [Vite](https://vitejs.dev/)
- **Enrutamiento:** [Vue Router](https://router.vuejs.org/)
- **Cliente HTTP:** Axios con base URL configurable
- **Estilos & UI:** CSS nativo basado en tokens de diseño semánticos globales y soporte de temas (Dark / Light)
---

## Arquitectura Estructural (Vertical Slice / Screaming Architecture)

El proyecto adopta el patrón **Vertical Slice** bajo los principios de **Screaming Architecture**. En lugar de organizar el código por capas técnicas globales (e.g. separar todos los controladores o todos los componentes juntos), el sistema se divide verticalmente por **dominios de negocio autónomos**. Cada slice o módulo contiene todas las capas y especificaciones (**SDD**) necesarias para su funcionamiento, minimizando el acoplamiento y facilitando la escalabilidad.

### Mapa Estructural

```text
root/
├── public/                 # Recursos estáticos globales servidos directamente
├── docker/                 # Archivos de configuración para contenedores (dev / prod)
├── src/
│   ├── app/                # Inicialización y configuración raíz del SPA
│   │   ├── layouts/        # MainLayout persistente y configuración de navegación
│   │   ├── router/         # Configuración central y agregación de rutas modulares
│   │   ├── App.vue         # Componente raíz de la aplicación
│   │   └── main.ts         # Punto de entrada / bootstrap de Vue
│   │
│   ├── modules/            # Slices Verticales de Dominio (Screaming Architecture)
│   │   └── <feature-slice>/# Módulo autónomo de negocio (ej. billing, contracts, etc.)
│   │       ├── specs/      # Especificaciones funcionales, requerimientos y SDD del módulo
│   │       ├── api/        # Clientes HTTP y llamadas a endpoints del dominio
│   │       ├── components/ # Componentes de UI internos y tests co-localizados (*.spec.ts)
│   │       ├── composables/# Lógica reactiva y hooks específicos de la feature
│   │       ├── stores/     # Gestión de estado del módulo (Pinia / Reactividad local)
│   │       ├── styles/     # Estilos y reglas CSS locales del módulo
│   │       ├── types/      # Contratos de tipos, interfaces y DTOs del dominio
│   │       ├── views/      # Vistas y páginas principales de la funcionalidad
│   │       ├── routes.ts   # Definición de rutas y lazy loading del módulo
│   │       └── index.ts    # Barrel export / API pública expuesta por el módulo
│   │
│   └── shared/             # Capa transversal compartida (Cross-Cutting Concerns)
│       ├── api/            # Cliente HTTP base (instancia base y configuración HTTP)
│       ├── assets/         # Recursos multimedia compartidos (logos, fuentes, gráficos)
│       ├── components/     # Componentes del Design System (Botones, Modales, Tablas, etc.)
│       ├── composables/    # Hooks reactivos reutilizables (useTheme y extensiones del proyecto)
│       ├── styles/         # Tokens semánticos globales, resets y variables de diseño
│       ├── types/          # Tipos e interfaces globales compartidas
│       ├── utils/          # Utilidades comunes (formatos de fecha, exportadores PDF/Excel)
│       └── views/          # Vistas genéricas compartidas (Errores 404, 500, vistas base)
│
├── .env.example            # Plantilla de variables de entorno requeridas
├── index.html              # Documento HTML principal montado por Vite
├── package.json            # Manifiesto de dependencias y scripts de desarrollo/construcción
├── tsconfig.json           # Configuración de compilación de TypeScript
└── vite.config.ts          # Configuración del bundler Vite y resolución de alias
```

### Principios de la Estructura

- **Spec-Driven Development (SDD):** Cada slice aloja su carpeta `specs/` con requerimientos de negocio y diseño UI antes de codificar con IA.
- **Enrutamiento Descentralizado:** Cada slice define sus propias rutas (`routes.ts`) con lazy loading, desacoplando la configuración central del router.
- **Límites Modulares (Public API):** Uso de `index.ts` en cada módulo para exponer únicamente los componentes, tipos o rutas autorizadas para el consumo externo.
- **Estado Encapsulado:** Los stores y composables residen en el módulo correspondiente, evitando estados globales innecesarios.
- **Cliente HTTP Centralizado:** Instancia Axios en `shared/api/`. Cada proyecto añade el tratamiento de errores y transporte que requieran sus contratos.
- **Prevención de Doble Petición (Unicidad de Acción):** Toda acción o mutación iniciada por el usuario debe ejecutarse de forma única sin permitir dobles peticiones. Las vistas y componentes deben deshabilitar visual y funcionalmente los elementos de disparo (`disabled`, `loading`) mientras la operación esté en curso, e incluir guardas de reentrancia en manejadores/composables (`if (isSubmitting.value) return;`) para evitar peticiones duplicadas por clics rápidos o eventos concurrentes.
- **Co-localización de Tests:** Archivos de prueba (`*.spec.ts`) ubicados junto a sus respectivos componentes o utilidades para preservar la autonomía del slice.
- **Idioma (Código vs. Interfaz):** Identificadores, componentes, composables, tipos y nombres de archivo se escriben en inglés. Todo texto presentado al usuario (etiquetas, botones, mensajes de error y de estado) se escribe en español de México (es-MX), sin mezclar idiomas en una misma cadena.
