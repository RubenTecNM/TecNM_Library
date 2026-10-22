# Sistema de Diseño Institucional: Tecnológico Nacional de México (TecNM)
**Identificador de Proyecto:** `tecnm-institutional-design-system`
**Versión de Especificación:** 1.0.0
**Activo de Origen:** `colors.css` / Guía de Identidad Institucional Universitaria

---

## 1. Tema Visual, Identidad & Atmósfera Institucional

### Filosofía de Identidad Universitaria
El sistema materializa la **"Identidad Institucional, Excelencia Técnica y Solidez Académica"** del **Tecnológico Nacional de México (TecNM)**. Se trata de un lenguaje visual sobrio, accesible y de alta confianza diseñado específicamente para los portales universitarios, sistemas de control escolar, plataformas docentes y tableros de gestión administrativa de la comunidad tecnológica.

El diseño equilibra la dignidad histórica y el rigor de la máxima casa de estudios tecnológicos con la agilidad e interactividad digital contemporánea, fundamentándose en los colores heráldicos e institucionales del TecNM:
- **Azul Marino TecNM (`#1B396A`):** Representa la autoridad institucional, el rigor científico, la estabilidad y la solemnidad de la universidad.
- **Oro / Dorado TecNM (`#C5A059`):** Simboliza la excelencia formativa, el mérito académico y el prestigio de la comunidad estudiantil y docente.
- **Neutros Pizarra Disciplinados:** Aportan claridad, legibilidad y un entorno visual limpio libre de distracciones.

```
+-------------------------------------------------------------------------------+
|  MODO CLARO (Light Mode): Presencia Institucional & Claridad Académica       |
|  - Lienzo slate mist (#F4F6F9) con tarjetas en blanco puro (#FFFFFF)         |
|  - Azul Marino TecNM (#1B396A) como ancla de estructura e identidad superior  |
|  - Dorado TecNM (#C5A059) para acentos de distinción y acciones destacadas    |
|  - Sombras difusas y sutiles que brindan separación táctil limpia            |
+-------------------------------------------------------------------------------+
|  MODO OSCURO (Dark Mode): Cámara Técnica & Trabajo Prolongado                |
|  - Lienzo pizarra obsidiana (#0B111E) con tarjetas medianoche elevadas (#141E33)|
|  - Azul Cobalto Luminoso (#2B5EA7 / #3B74C4) para accesibilidad interactiva   |
|  - Dorado Champaña Radiante (#D4B06A) para acentos cálidos y alto contraste   |
|  - Bordes perimétricos luminosos de 1px que sustituyen sombras para elevación |
+-------------------------------------------------------------------------------+
```

### Densidad y Ritmo Espacial
- **Densidad de Información:** Media-compacta. Diseñada para optimizar el flujo de trabajo en consultas de expedientes, kárdex, cargas académicas y tableros analíticos sin saturación visual.
- **Atmósfera:** Institucional, sobria, confiable y pulcra. Transmite transparencia administrativa, rigor técnico y el prestigio universitario del TecNM.

---

## 2. Paleta de Colores Institucional & Roles (Arquitectura Dual)

### 2.1 Colores Primarios & Acento Institucional TecNM

| Token | Modo Claro (Light) | Modo Oscuro (Dark) | Rol Funcional & Significado Visual |
| :--- | :--- | :--- | :--- |
| `--color-primary` | **Azul Marino TecNM** (`#1B396A`) | **Azul Cobalto Luminoso** (`#2B5EA7`) | Color primario de identidad institucional; barras de navegación superior, botones principales y encabezados estructurados. |
| `--color-primary-dark` | **Azul Marino Imperial** (`#0F2548`) | **Azul Marino Obsidiana** (`#13233F`) | Máxima jerarquía estructural universitaria; pie de página institucional y paneles laterales colapsados. |
| `--color-primary-hover` | **Azul Cobalto Real** (`#244B88`) | **Azul Eléctrico Vibrante** (`#3B74C4`) | Estado interactivo hover para elementos primarios; amplifica el brillo al interactuar. |
| `--color-primary-subtle` | **Azul Cielo Suave** (`#EBF3FF`) | **Tinte Marino Sumergido** (`#172B4D`) | Fondo para filas de tablas académicas seleccionadas, chips interactivos activos y hover secundario. |
| `--color-primary-tint` | **Gradiente Azul Neblina** (`#E8EDF5`) | **Azul Medianoche Atenuado** (`#1B2E4E`) | Rellenos de tarjetas de métricas secundarias y transiciones suaves de gradientes. |
| `--color-accent` | **Dorado TecNM** (`#C5A059`) | **Dorado Champaña Radiante** (`#D4B06A`) | Acento de excelencia y distinción universitaria; botones de acción destacada (CTA), insignias de mérito y pines de atención. |
| `--color-accent-light` | **Crema Dorado Seda** (`#F7F3E9`) | **Sombra Ámbar Ahumada** (`#2A2418`) | Fondo sutil para destacar comunicados oficiales, recomendaciones académicas o avisos institucionales prioritarios. |

---

### 2.2 Superficies, Fondos & Lienzo (Canvas)

| Token | Modo Claro (Light) | Modo Oscuro (Dark) | Rol Funcional & Tratamiento Visual |
| :--- | :--- | :--- | :--- |
| `--color-bg-main` | **Gris Pizarra Neblina** (`#F4F6F9`) | **Vacío Pizarra Obsidiana** (`#0B111E`) | Fondo base de las aplicaciones institucionales. En claro evoca papel técnico y pulcritud académica; en oscuro, un espacio anti-fatiga visual. |
| `--color-bg-light` | **Blanco Hielo Porcelana** (`#F8FAFC`) | **Pizarra Marina Profunda** (`#101A2C`) | Fondo alternativo para barras laterales de navegación, subpaneles y bandas intercaladas en tablas académicas. |
| `--color-surface-white` | **Blanco Puro Institucional** (`#FFFFFF`) | **Pizarra Nocturna Elevada** (`#141E33`) | Superficie para tarjetas de trámites, modales de gestión escolar, menús flotantes y diálogos emergentes. |
| `--color-white` | **Blanco Puro Inmutable** (`#FFFFFF`) | **Blanco Puro Inmutable** (`#FFFFFF`) | Blanco absoluto preservado para texto invertido sobre azul marino o imagotipo vectorial del TecNM. |

---

### 2.3 Bordes, Separadores & Contornos

| Token | Modo Claro (Light) | Modo Oscuro (Dark) | Rol Funcional & Tratamiento Visual |
| :--- | :--- | :--- | :--- |
| `--color-border` | **Borde Pizarra Sutil** (`#E2E8F0`) | **Borde Pizarra Profundo** (`#1E2C44`) | Borde estándar para tarjetas, divisores horizontales y contenedores de datos. |
| `--color-border-light` | **Línea Fina Tenue** (`#F1F5F9`) | **Línea Fina Nocturna** (`#162338`) | Separadores de bajo contraste entre filas de asignaturas, listas de alumnos o celdas de datos. |
| `--color-border-medium` | **Plata Pizarra Definido** (`#CBD5E1`) | **Acero Nocturno Definido** (`#2E3F5E`) | Bordes de campos de formulario, checkboxes desmarcados y marcos interactivos base. |
| `--color-border-focus` | **Anillo de Foco Azul TecNM** (`#1B396A`) | **Anillo de Foco Azul Cielo** (`#60A5FA`) | Anillo indicador de accesibilidad y foco activo en formularios y elementos accionables con teclado. |

---

### 2.4 Escala de Grises & Cimientos Neutros

| Escala | Tono Modo Claro | Tono Modo Oscuro | Uso Semántico |
| :--- | :--- | :--- | :--- |
| `--color-gray-50` | `#F8FAFC` *(Frost Tint)* | `#0D1524` *(Abyssal Slate)* | Fondos sutiles, hover en menús secundarios. |
| `--color-gray-100` | `#F1F5F9` *(Porcelain Gray)* | `#131E31` *(Deep Slate Level 1)* | Contenedores anidados y tooltips secundarios. |
| `--color-gray-200` | `#E2E8F0` *(Mist Border)* | `#1C2B44` *(Deep Slate Level 2)* | Líneas divisorias y bordes de componentes. |
| `--color-gray-300` | `#CBD5E1` *(Silver Slate)* | `#2A3B5A` *(Steel Slate)* | Estados desactivados y bordes interactivos base. |
| `--color-gray-400` | `#94A3B8` *(Pewter Slate)* | `#64748B` *(Dampened Steel)* | Iconos inactivos y textos de ayuda complementarios. |
| `--color-gray-500` | `#64748B` *(Slate Neutral)* | `#94A3B8` *(Brightened Pewter)* | Iconografía estándar y subtítulos técnicos. |
| `--color-gray-600` | `#475569` *(Charcoal Slate)* | `#CBD5E1` *(Luminous Slate)* | Etiquetas de campos de formulario y valores de metadatos. |
| `--color-gray-700` | `#334155` *(Deep Slate)* | `#E2E8F0` *(Pristine Mist Text)* | Encabezados de tarjetas y textos secundarios de alto contraste. |
| `--color-gray-800` | `#1E293B` *(Dark Obsidian)* | `#F8FAFC` *(Pure Bright Text)* | Tipografía principal y datos de alta prioridad. |

---

### 2.5 Tipografía & Jerarquía de Texto

| Token | Modo Claro (Light) | Modo Oscuro (Dark) | Rol Funcional & Legibilidad |
| :--- | :--- | :--- | :--- |
| `--color-text-primary` | **Carbón Pizarra Profundo** (`#1E293B`) | **Blanco Neblina Luminoso** (`#F8FAFC`) | Títulos principales, números de control, matrículas y datos clave de lectura (Ratio > 12:1). |
| `--color-text-secondary` | **Acero Pizarra Equilibrado** (`#64748B`) | **Plata Pizarra Claro** (`#94A3B8`) | Subtítulos, descripciones de módulos y encabezados de columnas en tablas. |
| `--color-text-muted` | **Gris Peltre Suave** (`#94A3B8`) | **Pizarra Carbón Atenuado** (`#64748B`) | Textos de marcador de posición (placeholders), marcas de tiempo y notas secundarias. |
| `--color-text-inverse` | **Blanco Contraste Puro** (`#FFFFFF`) | **Obsidiana Medianoche** (`#0B111E`) | Texto sobre botones institucionales primarios, badges oscuros en claro o botones claros en modo oscuro. |

---

### 2.6 Retroalimentación Semántica & Estados Operativos

#### Success (Éxito / Aprobado / Trámite Concluido)
* **Light Mode:**
  - Base: **Vibrant Emerald** (`#22C55E`) - Indicadores luminosos y marcas de verificación.
  - Strong / Action: **Deep Forest Green** (`#15803D`) / Hover: **Dark Pine** (`#166534`) - Botones de confirmación y acreditación.
  - Background Tint: **Mint Mist** (`#F0FDF4`) / Badge BG: **Soft Jade Tint** (`#D1FAE5`).
  - Text & Border: **Deep Sea Pine** (`#065F46`) con **Pastel Emerald Border** (`#A7F3D0`).
* **Dark Mode:**
  - Base: **Luminous Spring Mint** (`#4ADE80`) - Gran contraste contra fondos oscuros.
  - Strong / Action: **Rich Emerald** (`#16A34A`) / Hover: **Bright Emerald** (`#22C55E`).
  - Background Tint: **Deep Cypress Shadow** (`#0A261A`) / Badge BG: **Smoked Jade** (`#0C3825`).
  - Text & Border: **Vibrant Seafoam** (`#6EE7B7`) con **Emerald Rim** (`#15803D`).

#### Warning (Advertencia / En Revisión / Trámite Pendiente)
* **Light Mode:**
  - Base: **Warm Amber Flare** (`#F59E0B`) / Dark: **Rich Goldenrod** (`#D97706`).
  - Background Tint: **Golden Mist** (`#FFFBEB`) / Badge BG: **Sunlit Amber Tint** (`#FEF3C7`).
  - Text & Border: **Burnished Ochre** (`#92400E`) con **Mellow Topaz Border** (`#FDE68A`).
* **Dark Mode:**
  - Base: **Radiant Warm Amber** (`#FBBF24`) - Máxima visibilidad nocturna.
  - Strong / Action: **Golden Ochre** (`#D97706`) / Hover: **Bright Amber** (`#F59E0B`).
  - Background Tint: **Deep Toffee Shadow** (`#2C1A06`) / Badge BG: **Smoked Amber** (`#3D2509`).
  - Text & Border: **Sunlit Gold** (`#FCD34D`) con **Amber Rim** (`#92400E`).

#### Danger (Peligro / Rechazado / Error de Validación)
* **Light Mode:**
  - Base: **Crisp Crimson** (`#EF4444`) - Alertas críticas, contornos de error y avisos de no acreditación.
  - Strong / Action: **Vivid Ruby Red** (`#DC2626`) / Hover: **Intense Garnet** (`#B91C1C`).
  - Background Tint: **Rose Petal Mist** (`#FEF2F2`) / Badge BG: **Soft Coral Tint** (`#FEE2E2`).
  - Text & Border: **Deep Burgundy Danger** (`#991B1B`) con **Blush Crimson Border** (`#FECACA`).
* **Dark Mode:**
  - Base: **Bright Coral Rose** (`#F87171`) - Alta legibilidad sobre slate profundo.
  - Strong / Action: **Vivid Crimson** (`#EF4444`) / Hover: **Bright Rose** (`#F87171`).
  - Background Tint: **Deep Mahogany Shadow** (`#2D0E11`) / Badge BG: **Smoked Coral** (`#401418`).
  - Text & Border: **Blush Rose Red** (`#FCA5A5`) con **Ruby Rim** (`#991B1B`).

#### Info (Informativo / En Proceso / Comunicado Escolar)
* **Light Mode:**
  - Base: **Luminous Cerulean** (`#3B82F6`).
  - Background Tint: **Frosted Sky Mist** (`#EFF6FF`) / Badge BG: **Soft Azure Tint** (`#E0F2FE`).
  - Text & Border: **Deep Ocean Navy** (`#075985`) con **Ice Blue Border** (`#BFDBFE`).
* **Dark Mode:**
  - Base: **Vibrant Sky Cyan** (`#60A5FA`).
  - Background Tint: **Abyssal Blue Shadow** (`#0C203B`) / Badge BG: **Smoked Azure** (`#132E52`).
  - Text & Border: **Frosted Sky Blue** (`#93C5FD`) con **Cerulean Rim** (`#1D4ED8`).

#### Specialized / Purple (Estados Especiales / Auditoría / Registro Académico)
* **Light Mode:**
  - Base: **Royal Iris Violet** (`#8B5CF6`).
  - Background: **Soft Lavender Tint** (`#EDE9FE`) / Text: **Deep Velvet Plum** (`#5B21B6`).
* **Dark Mode:**
  - Base: **Radiant Violet Orchid** (`#A78BFA`).
  - Background: **Deep Amethyst Shadow** (`#221340`) / Text: **Luminous Lavender** (`#DDD6FE`).

---

### 2.7 Tokens Estructurales del Cascarón (Shell)

| Token | Modo Claro (Light) | Modo Oscuro (Dark) | Fundamento Institucional |
| :--- | :--- | :--- | :--- |
| `--color-header-bg` | **Azul Marino TecNM** (`#1B396A`) | **Midnight Horizon Slate** (`#0F1829`) | En modo claro proyecta solemnidad, autoridad y el sello de identidad oficial del Tecnológico Nacional de México con anclaje superior; en oscuro se funde con la interfaz preservando sobriedad con borde inferior definido. |
| `--color-footer-bg` | **Azul Marino Imperial** (`#0F2548`) | **Obsidian Anchor Black** (`#080D18`) | Cierre visual inferior con el mayor peso tonal de la composición, destinado a créditos universitarios, enlaces legales y datos del campus. |

---

## 3. Reglas Tipográficas

### Jerarquía de Fuentes & Familias
* **Familia Primaria:** Sans-Serif geométrica contemporánea con remates limpios y proporciones humanas (p. ej. *Inter*, *Plus Jakarta Sans* o *Roboto*), óptima para lectura prolongada en pantallas de consulta escolar y tableros de gestión.
* **Acentos Tipográficos Institucionales (Opcional):** Serif moderna de corte solemne para diplomas, títulos de actas oficiales o documentos formales (p. ej. *Cinzel* o *Merriweather* para portadas y encabezados solemnes).

### Escalas Tipográficas & Disciplina de Pesos
* **Display & Encabezados Principales (H1):**
  - Peso: `font-bold` (700) o `font-semibold` (600).
  - Letter-spacing: `tracking-tight` (-0.025em).
  - Color: `--color-text-primary` (`#1E293B` en claro / `#F8FAFC` en oscuro).
* **Encabezados de Sección (H2, H3):**
  - Peso: `font-semibold` (600).
  - Letter-spacing: `tracking-normal`.
  - Color: `--color-text-primary`.
* **Micro-Encabezados & Sobretítulos (Eyebrows):**
  - Estilo: Mayúsculas sostenidas (`uppercase`).
  - Peso: `font-bold` (700) con espaciado amplio `tracking-wider` (+0.05em).
  - Color: `--color-accent` (`#C5A059` en claro / `#D4B06A` en oscuro).
* **Cuerpo de Texto (Párrafos, Tablas, Contenidos Académicos):**
  - Peso: `font-normal` (400) o `font-medium` (500) para lectura cómoda de planes de estudio y expedientes.
  - Altura de línea: `leading-relaxed` (1.6) para asegurar confort visual.
  - Color: `--color-text-secondary` (`#64748B` en claro / `#94A3B8` en oscuro).
* **Metadatos & Leyendas de Apoyo:**
  - Tamaño: 12px / 0.75rem.
  - Color: `--color-text-muted` (`#94A3B8` en claro / `#64748B` en oscuro).

---

## 4. Geometría, Formas & Elevación

### 4.1 Geometría Física & Radios de Borde (Border Radius)
* **Contenedores y Tarjetas:** **Esquinas Suavemente Curvadas** (`rounded-xl` / 12px). Suavidad moderna que preserva la disciplina arquitectónica institucional.
* **Campos de Entrada y Selectores:** **Bordes Sutilmente Redondeados** (`rounded-lg` / 8px). Equilibrio ideal entre contención y ergonomía en captura de datos.
* **Botones de Acción:** **Bordes Sutilmente Redondeados** (`rounded-lg` / 8px) para botones estándar; **Píldora Completa** (`rounded-full`) reservada para filtros rápidos y chips de periodo o estatus.
* **Badges y Etiquetas de Estado:** **Cápsulas Sutiles** (`rounded-md` / 6px) con bordes delgados de 1px.

---

### 4.2 Profundidad, Elevación & Tratamiento de Luz

#### Modo Claro (Light Mode)
* **Estrategia:** Sombras suaves y difusas en capas progresivas que simulan luz natural cenital.
  - **Capa 0 (Canvas):** Plano base `#F4F6F9`.
  - **Capa 1 (Tarjetas estándar):** Relleno `#FFFFFF` con `box-shadow: 0 1px 3px rgba(15, 37, 72, 0.05), 0 1px 2px rgba(15, 37, 72, 0.03)` y borde perimetral sutil (`#E2E8F0`).
  - **Capa 2 (Dropdowns, Paneles flotantes):** `box-shadow: 0 10px 15px -3px rgba(15, 37, 72, 0.08), 0 4px 6px -2px rgba(15, 37, 72, 0.04)`.
  - **Capa 3 (Modales de diálogo y trámites):** `box-shadow: 0 20px 25px -5px rgba(15, 37, 72, 0.15)`.

#### Modo Oscuro (Dark Mode)
* **Estrategia:** Elevación mediante **Iluminación de Borde y Luminancia Superficial** (en interfaces oscuras, las sombras difusas son invisibles; la elevación se logra aclarando sutilmente la superficie y trazando bordes de luz tenue).
  - **Capa 0 (Canvas):** Pizarra Obsidiana `#0B111E`.
  - **Capa 1 (Tarjetas estándar):** Superficie `#141E33` con borde perimétrico tenue de 1px en `#1E2C44`.
  - **Capa 2 (Dropdowns y Tarjetas flotantes):** Superficie `#1A2844` con borde en `#2A3E63` y sombra de penumbra `box-shadow: 0 12px 24px rgba(0, 0, 0, 0.45)`.
  - **Capa 3 (Modales de diálogo):** Superficie `#1E2F50` con borde definido `#334C79` sobre telón de fondo oscuro translúcido (`rgba(5, 8, 15, 0.8)`).

---

## 5. Estilos de Componentes (Especificaciones en Modo Dual)

### 5.1 Botones (Controles Interactivos)

* **Botón Primario Institucional (Acción Principal):**
  - *Light Mode:* Relleno **Azul Marino TecNM** (`#1B396A`), texto blanco puro (`#FFFFFF`). En hover: **Azul Cobalto Real** (`#244B88`).
  - *Dark Mode:* Relleno **Azul Cobalto Luminoso** (`#2B5EA7`), texto blanco puro (`#FFFFFF`). En hover: **Azul Eléctrico Vibrante** (`#3B74C4`).
  - *Forma:* Esquinas suavemente redondeadas (`rounded-lg`), tipografía semi-negrita con padding horizontal generoso (`px-5 py-2.5`).

* **Botón de Acento Dorado (CTA Destacado / Convocatorias / Trámites Clave):**
  - *Light Mode:* Relleno **Dorado TecNM** (`#C5A059`), texto blanco puro (`#FFFFFF`), hover oscurecido al 10%.
  - *Dark Mode:* Relleno **Dorado Champaña Radiante** (`#D4B06A`), texto **Obsidiana Medianoche** (`#0B111E`) para máximo contraste legible, hover con resplandor dorado.

* **Botón Secundario / Contorno (Outline):**
  - *Light Mode:* Fondo transparente o `#FFFFFF`, borde perimetral en `#CBD5E1`, texto `--color-text-primary` (`#1E293B`), hover con tinte sutil `#F1F5F9`.
  - *Dark Mode:* Fondo `#141E33`, borde en `#2E3F5E`, texto `#F8FAFC`, hover con tinte `#1B2B48`.

* **Botón Fantasma / Destructivo (Bajas / Cancelaciones):**
  - *Light Mode:* Sin fondo; texto rojo rubí (`#DC2626`), hover con fondo suave `#FEF2F2`.
  - *Dark Mode:* Sin fondo; texto rojo coral brillante (`#F87171`), hover con fondo sutil `#2D0E11`.

---

### 5.2 Tarjetas & Contenedores de Datos

* **Tarjeta de Contenido Estándar:**
  - *Light Mode:* Fondo blanco inmaculado (`#FFFFFF`), borde de 1px `#E2E8F0`, esquinas redondeadas de 12px, sombra levísima.
  - *Dark Mode:* Fondo pizarra nocturna (`#141E33`), borde perimetral sutil `#1E2C44`, esquinas de 12px, sin sombra o con halo oscuro profundo.

* **Tarjetas de Indicadores & Métricas Institucionales (KPIs):**
  - Incorporan una barra lateral o borde superior de 4px con el color de acento dorado (`#C5A059` / `#D4B06A`) o primario azul marino (`#1B396A` / `#2B5EA7`).
  - La cifra principal (p. ej., matrícula activa, promedio general, créditos cursados) se renderiza en tamaño Display (28px - 36px) con `font-bold` en `--color-text-primary`.

* **Tablas de Datos Académicos (Kárdex, Listados de Asignaturas y Alumnos):**
  - *Header Row:* Fondo sutil (`#F8FAFC` en claro / `#101A2C` en oscuro), texto en mayúsculas pequeñas `tracking-wider` con color `--color-text-secondary`.
  - *Borders:* Divisores horizontales de 1px (`#F1F5F9` en claro / `#162338` en oscuro).
  - *Hover Row:* Tinte suave interactivo (`#EBF3FF` en claro / `#172B4D` en oscuro).

---

### 5.3 Formularios & Entradas de Datos

* **Campos de Texto & Selectores:**
  - *Light Mode:* Fondo blanco (`#FFFFFF`), borde estándar `#CBD5E1`, texto `#1E293B`, placeholder `#94A3B8`.
  - *Dark Mode:* Fondo pizarra nocturna (`#101A2C`), borde `#2A3B5A`, texto `#F8FAFC`, placeholder `#64748B`.
  - *Estado Foco (Focus State):* Borde primario (`#1B396A` en claro / `#60A5FA` en oscuro) con un anillo difuso de 3px (`ring-2 ring-primary/20`).
  - *Estado Error:* Borde rojo carmesí (`#EF4444`) con anillo sutil de peligro y texto explicativo en `--color-danger`.

---

### 5.4 Badges & Pastillas de Estado

| Estado Académico / Operativo | Modo Claro (Fondo / Borde / Texto) | Modo Oscuro (Fondo / Borde / Texto) |
| :--- | :--- | :--- |
| **Acreditado / Activo / Éxito** | `#D1FAE5` / `#A7F3D0` / `#065F46` | `#0C3825` / `#15803D` / `#6EE7B7` |
| **En Trámite / Pendiente / Alerta** | `#FEF3C7` / `#FDE68A` / `#92400E` | `#3D2509` / `#92400E` / `#FCD34D` |
| **No Acreditado / Baja / Error** | `#FEE2E2` / `#FECACA` / `#991B1B` | `#401418` / `#991B1B` / `#FCA5A5` |
| **Informativo / En Proceso** | `#E0F2FE` / `#BFDBFE` / `#075985` | `#132E52` / `#1D4ED8` / `#93C5FD` |
| **Especial / Auditoría Escolar** | `#EDE9FE` / `#DDD6FE` / `#5B21B6` | `#221340` / `#5B21B6` / `#DDD6FE` |

---

## 6. Principios de Maquetación & Estructura (Layout)

### Escala Espacial & Espaciado
- Basado en múltiplos de **4px / 8px** (8px, 12px, 16px, 24px, 32px, 48px, 64px).
- **Separación entre Tarjetas:** 24px (`gap-6`) para crear holgura visual sin dispersión.
- **Padding Interno de Tarjetas:** 20px a 24px (`p-5` o `p-6`).
- **Márgenes de Pantalla:** 32px (`px-8`) en escritorio, 16px (`px-4`) en dispositivos móviles.

### Cascarón Estructural Institucional
- **Barra Superior Institucional (Header Bar):** 
  - *Claro:* Fondo institucional Azul Marino TecNM (`#1B396A`) con texto blanco inverso (`#FFFFFF`), proyectando identidad oficial universitaria, solemnidad y anclaje superior con espacio para el imagotipo oficial del TecNM.
  - *Oscuro:* Fondo pizarra medianoche (`#0F1829`) con línea divisoria inferior de 1px en `#1E2C44`.
- **Barra Lateral de Navegación (Sidebar / Rail):**
  - Fondo alternativo (`#F8FAFC` en claro / `#101A2C` en oscuro). Módulos activos destacados con fondo sutil (`#EBF3FF` / `#172B4D`) y pestaña lateral izquierda de 3px en Azul Marino TecNM o Dorado Institucional.
- **Pie de Página Institucional (Footer):**
  - Ancla visual en Azul Marino Imperial (`#0F2548` en claro / `#080D18` en oscuro) para información institucional, campus, derechos reservados y enlaces oficiales del TecNM.

---

## 7. Directivas de Prompting para Google Stitch & Generadores de UI

Al generar nuevas pantallas o módulos para el **TecNM** con **Google Stitch** u otras herramientas de generación asistida, utiliza las siguientes directivas descriptivas según el tema deseado:

### Directiva para Pantallas en Modo Claro:
> *"Generate a clean, high-density institutional university dashboard for TecNM (Tecnológico Nacional de México) in crisp daylight palette. Use a cool slate mist background (#F4F6F9) and pure white cards (#FFFFFF) with subtly rounded corners (12px) and whisper-soft diffused shadows. Structural headers should be anchored in deep institutional TecNM navy (#1B396A), while high-priority call-to-actions, merit badges, and institutional highlights feature warm burnished TecNM gold (#C5A059). Typography must use high-contrast dark charcoal slate (#1E293B) for headlines and balanced steel slate (#64748B) for body data. Form fields must have crisp light slate borders (#CBD5E1) with a deep navy focus glow."*

### Directiva para Pantallas en Modo Oscuro:
> *"Generate a sophisticated institutional university dashboard for TecNM (Tecnológico Nacional de México) in deep dark mode. Use an obsidian slate void background (#0B111E) and elevated midnight slate cards (#141E33) framed with subtle 1px luminous slate rims (#1E2C44). Primary interactive controls must glow in luminous cobalt azure (#2B5EA7 / #3B74C4) and institutional accents in radiant champagne gold (#D4B06A). Headings must be rendered in crisp pure mist (#F8FAFC) and secondary metrics in silver slate (#94A3B8). Status indicators must utilize deep smoked containers with vibrant pastel text."*
