<script setup lang="ts">
import axios from 'axios'
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import {
  createBook,
  createShelf,
  createTopic,
  getInventoryMetrics,
  getNextAvailableFolio,
  searchBooks,
  updateBook,
  updateBookStatus,
} from '../api/inventoryApi'
import type {
  BookApiDto,
  BookItem,
  BookStatusKey,
  InventorySearchField,
  InventorySortKey,
  MetricsSummary,
  StatusMeta,
} from '../types/inventory'

const STATUS_META: Record<BookStatusKey, StatusMeta> = {
  disponible: {
    id: 1,
    key: 'disponible',
    label: 'Disponible',
    cardLabel: 'Disponible',
    statusClass: 'bg-[#D1FAE5] text-[#15803D] border-[#15803D]/30',
    dotClass: 'bg-[#15803D]',
    pillBgClass: 'bg-[#D1FAE5] hover:bg-[#a7f3d0] text-[#15803D] border border-[#15803D]/30',
    badgeBgClass: 'bg-[#15803D]/15',
  },
  prestado: {
    id: 2,
    key: 'prestado',
    label: 'Prestado',
    cardLabel: 'Prestado',
    statusClass: 'bg-[#DBEAFE] text-[#1D4ED8] border-[#1D4ED8]/30',
    dotClass: 'bg-[#1D4ED8]',
    pillBgClass: 'bg-[#DBEAFE] hover:bg-[#bfdbfe] text-[#1D4ED8] border border-[#1D4ED8]/30',
    badgeBgClass: 'bg-[#1D4ED8]/15',
  },
  reparacion: {
    id: 3,
    key: 'reparacion',
    label: 'En reparación',
    cardLabel: 'En reparación',
    statusClass: 'bg-[#FEF3C7] text-[#D97706] border-[#D97706]/30',
    dotClass: 'bg-[#D97706]',
    pillBgClass: 'bg-[#FEF3C7] hover:bg-[#fde68a] text-[#D97706] border border-[#D97706]/30',
    badgeBgClass: 'bg-[#D97706]/15',
  },
  baja: {
    id: 4,
    key: 'baja',
    label: 'En proceso de baja',
    cardLabel: 'Proceso de baja',
    statusClass: 'bg-[#FEE2E2] text-[#DC2626] border-[#DC2626]/30',
    dotClass: 'bg-[#DC2626]',
    pillBgClass: 'bg-[#FEE2E2] hover:bg-[#fecaca] text-[#DC2626] border border-[#DC2626]/30',
    badgeBgClass: 'bg-[#DC2626]/15',
  },
  catalogo: {
    id: 5,
    key: 'catalogo',
    label: 'En catálogo',
    cardLabel: 'En catálogo',
    statusClass: 'bg-[#EDE9FE] text-[#7C3AED] border-[#7C3AED]/30',
    dotClass: 'bg-[#7C3AED]',
    pillBgClass: 'bg-[#EDE9FE] hover:bg-[#ddd6fe] text-[#7C3AED] border border-[#7C3AED]/30',
    badgeBgClass: 'bg-[#7C3AED]/15',
  },
}

const STATUS_BY_ID: Record<number, BookStatusKey> = {
  1: 'disponible',
  2: 'prestado',
  3: 'reparacion',
  4: 'baja',
  5: 'catalogo',
}

const DEFAULT_COVER_STYLES = [
  {
    coverIcon: 'functions',
    coverGradient: 'from-[#0c264d] via-[#001f47] to-[#04142d]',
    coverBorderColor: 'border-l-[#d2a858]',
    coverTagColor: 'text-[#f5d99b]',
    coverSubtitleColor: 'text-[#e0e8f8]',
    coverBarColor: 'bg-[#C5A059]',
    deweyBadgeClass: 'text-primary bg-blue-50 border-blue-100',
  },
  {
    coverIcon: 'precision_manufacturing',
    coverGradient: 'from-[#003b35] via-[#042421] to-[#011413]',
    coverBorderColor: 'border-l-[#C5A059]',
    coverTagColor: 'text-[#6bd8cb]',
    coverSubtitleColor: 'text-[#a9ede4]',
    coverBarColor: 'bg-[#89f5e7]',
    deweyBadgeClass: 'text-primary bg-blue-50 border-blue-100',
  },
  {
    coverIcon: 'local_fire_department',
    coverGradient: 'from-[#3b1900] via-[#241100] to-[#120800]',
    coverBorderColor: 'border-l-[#e6aa3e]',
    coverTagColor: 'text-amber-300',
    coverSubtitleColor: 'text-[#fcd8a2]',
    coverBarColor: 'bg-amber-400',
    deweyBadgeClass: 'text-primary bg-amber-50 border-amber-200',
  },
  {
    coverIcon: 'terminal',
    coverGradient: 'from-[#121e3d] via-[#091326] to-[#040812]',
    coverBorderColor: 'border-l-[#C5A059]',
    coverTagColor: 'text-[#a8c3f8]',
    coverSubtitleColor: 'text-[#cadbff]',
    coverBarColor: 'bg-blue-400',
    deweyBadgeClass: 'text-primary bg-purple-50 border-purple-200',
  },
  {
    coverIcon: 'memory',
    coverGradient: 'from-[#101b3b] via-[#091024] to-[#02050f]',
    coverBorderColor: 'border-l-[#C5A059]',
    coverTagColor: 'text-[#f5d99b]',
    coverSubtitleColor: 'text-[#d6e3ff]',
    coverBarColor: 'bg-[#C5A059]',
    deweyBadgeClass: 'text-primary bg-amber-50 border-amber-200',
  },
  {
    coverIcon: 'mode_heat',
    coverGradient: 'from-[#421b00] via-[#240e00] to-[#120700]',
    coverBorderColor: 'border-l-[#e6a540]',
    coverTagColor: 'text-[#ffd387]',
    coverSubtitleColor: 'text-[#fed699]',
    coverBarColor: 'bg-amber-400',
    deweyBadgeClass: 'text-rose-800 bg-rose-50 border-rose-200',
  },
  {
    coverIcon: 'blur_on',
    coverGradient: 'from-[#021f47] via-[#01142e] to-[#000a17]',
    coverBorderColor: 'border-l-[#C5A059]',
    coverTagColor: 'text-[#f5d99b]',
    coverSubtitleColor: 'text-[#d6e3ff]',
    coverBarColor: 'bg-[#C5A059]',
    deweyBadgeClass: 'text-primary bg-blue-50 border-blue-100',
  },
  {
    coverIcon: 'trending_up',
    coverGradient: 'from-[#3b2a05] via-[#241a02] to-[#120d00]',
    coverBorderColor: 'border-l-[#d2a858]',
    coverTagColor: 'text-[#f5d99b]',
    coverSubtitleColor: 'text-[#f2e1bd]',
    coverBarColor: 'bg-[#C5A059]',
    deweyBadgeClass: 'text-primary bg-amber-50 border-amber-200',
  },
]

const initialBooks: BookItem[] = [
  {
    id: 1,
    title: 'Cálculo de una Variable y Trascendentes Tempranas',
    author: 'James Stewart, Daniel K. Clegg, Saleem Watson',
    shelf: '1.1.1',
    shelfId: 1,
    dewey: 'QA303.2',
    cutter: '.S74 2023',
    note: '8va Edición • Volumen 1 • Cengage Learning',
    folio: '5000',
    available: '6 de 8 copias libres',
    barWidth: 75,
    code: 'QA303.2',
    shortTitle: 'CÁLCULO',
    coverSubtitle: 'Trascendentes',
    coverAuthor: 'J. Stewart',
    coverEdition: '8ª Ed.',
    status: 'disponible',
    recommendation:
      'Obra inventariada para el tronco común en Ciencias Básicas del TecNM Campus Monclova. Ejemplar auditado en el ciclo semestral vigente sin extravíos.',
    topics: ['Cálculo Diferencial e Integral'],
    ...DEFAULT_COVER_STYLES[0],
  },
  {
    id: 2,
    title: 'Mecatrónica: Control Electrónico',
    author: 'William Bolton',
    shelf: '9.2.3',
    shelfId: 2,
    dewey: 'TJ223',
    cutter: '.B65',
    note: '6ta Edición • Control Industrial',
    folio: '5001',
    available: 'En préstamo (1 ejemplar)',
    barWidth: 25,
    code: 'TJ223',
    shortTitle: 'MECATRÓNICA',
    coverSubtitle: 'Control Industrial',
    coverAuthor: 'W. Bolton',
    coverEdition: '6ª Ed.',
    status: 'prestado',
    recommendation:
      'Préstamo activo a estudiante de Ingeniería Mecatrónica. Vencimiento estipulado en mostrador del Edificio A.',
    topics: ['Mecatrónica'],
    ...DEFAULT_COVER_STYLES[1],
  },
  {
    id: 3,
    title: 'Introducción a la Metalurgia Física',
    author: 'Sidney H. Avner',
    shelf: '2.1.4',
    shelfId: 3,
    dewey: 'TN665',
    cutter: '.A86',
    note: 'Edición Especial • Siderurgia',
    folio: '5002',
    available: '3 de 4 copias libres',
    barWidth: 75,
    code: 'TN665',
    shortTitle: 'SIDERURGIA',
    coverSubtitle: 'Metalurgia Acero',
    coverAuthor: 'Avner & Peña',
    coverEdition: 'Ed. Mcv',
    status: 'disponible',
    recommendation:
      'Colección regional insignia del acervo de Monclova. Material de consulta para residencias e industria siderúrgica.',
    topics: ['Siderurgia'],
    ...DEFAULT_COVER_STYLES[2],
  },
  {
    id: 4,
    title: 'Estructuras de Datos y Algoritmos',
    author: 'Mark Allen Weiss',
    shelf: '5.3.2',
    shelfId: 4,
    dewey: 'QA76.73',
    cutter: '.W45',
    note: '4ta Edición 2024 • Software',
    folio: '5003',
    available: 'En revisión de catalogación',
    barWidth: 100,
    code: 'QA76.73',
    shortTitle: 'ESTRUCTURAS',
    coverSubtitle: 'Python & C++',
    coverAuthor: 'M. Weiss',
    coverEdition: 'Pearson',
    status: 'catalogo',
    recommendation:
      'Nuevo título ingresado en catálogo para Ingeniería en Sistemas Computacionales e Informática ITSM.',
    topics: ['Algoritmos y Estructuras de Datos'],
    ...DEFAULT_COVER_STYLES[3],
  },
  {
    id: 5,
    title: 'Análisis de Circuitos en Ingeniería',
    author: 'William H. Hayt',
    shelf: '3.1.2',
    shelfId: 5,
    dewey: 'TK454',
    cutter: '.H39',
    note: '9na Edición • Redes y Señales',
    folio: '5004',
    available: 'En taller de encuadernación',
    barWidth: 40,
    code: 'TK454',
    shortTitle: 'CIRCUITOS',
    coverSubtitle: 'Ingeniería Eléctrica',
    coverAuthor: 'Hayt et al.',
    coverEdition: '9ª Ed.',
    status: 'reparacion',
    recommendation:
      'Ejemplar transferido al taller de encuadernación por desprendimiento de lomo. Entrega estimada en 3 días hábiles.',
    topics: ['Ingeniería Eléctrica'],
    ...DEFAULT_COVER_STYLES[4],
  },
  {
    id: 6,
    title: 'Termodinámica Técnica',
    author: 'Yunus A. Çengel',
    shelf: '7.2.1',
    shelfId: 6,
    dewey: 'TJ265',
    cutter: '.C46',
    note: '9na Edición • Enfoque Industrial',
    folio: '5005',
    available: '0 disponibles (Baja definitiva)',
    barWidth: 10,
    code: 'TJ265',
    shortTitle: 'TERMODINÁMICA',
    coverSubtitle: 'Ingenierías',
    coverAuthor: 'Çengel',
    coverEdition: 'McGraw-Hill',
    status: 'baja',
    recommendation:
      'Propuesta de baja técnica por deterioro físico total. Pendiente acta de Comité de Adquisiciones y Descarte.',
    topics: ['Termodinámica'],
    ...DEFAULT_COVER_STYLES[5],
  },
  {
    id: 7,
    title: 'Física Universitaria Moderna',
    author: 'Hugh D. Young',
    shelf: '1.2.4',
    shelfId: 1,
    dewey: 'QC21.3',
    cutter: '.Y68',
    note: '14va Edición • Volúmenes 1 y 2',
    folio: '5006',
    available: '8 de 10 copias libres',
    barWidth: 80,
    code: 'QC21.3',
    shortTitle: 'FÍSICA',
    coverSubtitle: 'Universitaria',
    coverAuthor: 'Young',
    coverEdition: '14ª Ed.',
    status: 'disponible',
    recommendation:
      'Volumen con alta rotación en sala general de estudio. Sellos y firmas verificados.',
    topics: ['Física'],
    ...DEFAULT_COVER_STYLES[6],
  },
  {
    id: 8,
    title: 'Evaluación de Proyectos',
    author: 'Gabriel Baca Urbina',
    shelf: '4.1.3',
    shelfId: 6,
    dewey: 'HD69.P75',
    cutter: '.B33',
    note: '7ma Edición • Formulación y Evaluación',
    folio: '5007',
    available: '3 de 4 copias libres',
    barWidth: 75,
    code: 'HD69.P75',
    shortTitle: 'PROYECTOS',
    coverSubtitle: 'Inversión & Planta',
    coverAuthor: 'G. Baca',
    coverEdition: '7ª Ed.',
    status: 'disponible',
    recommendation:
      'Libro de texto base para residencias profesionales y materias de formulación de proyectos en Gestión Empresarial e Industrial.',
    topics: ['Administración y Gestión de Proyectos'],
    ...DEFAULT_COVER_STYLES[7],
  },
  {
    id: 9,
    title: 'Inteligencia Artificial: Un Enfoque Moderno',
    author: 'Stuart Russell & Peter Norvig',
    shelf: '3.2.1',
    shelfId: 3,
    dewey: 'QA76.87',
    cutter: '.R87',
    note: '3ra Edición • Pearson Educación',
    folio: '5008',
    available: '4 de 5 copias libres',
    barWidth: 80,
    code: 'QA76.87',
    shortTitle: 'I. ARTIFICIAL',
    coverSubtitle: 'Enfoque Moderno',
    coverAuthor: 'Russell & Norvig',
    coverEdition: '3ª Ed.',
    status: 'disponible',
    recommendation:
      'Texto de referencia para Inteligencia Artificial, Aprendizaje Automático y Sistemas Inteligentes en Ingeniería Informática y Sistemas.',
    topics: ['Inteligencia Artificial y Aprendizaje Automático'],
    coverIcon: 'smart_toy',
    coverGradient: 'from-[#003b35] via-[#042421] to-[#011413]',
    coverBorderColor: 'border-l-[#d2a858]',
    coverTagColor: 'text-[#89f5e7]',
    coverSubtitleColor: 'text-[#eed394]',
    coverBarColor: 'bg-[#89f5e7]',
    deweyBadgeClass: 'text-primary bg-blue-50 border-blue-100',
  },
  {
    id: 10,
    title: 'Química General y Orgánica',
    author: 'Raymond Chang',
    shelf: '6.1.2',
    shelfId: 5,
    dewey: 'QD31.3',
    cutter: '.C43',
    note: '11va Edición • McGraw-Hill',
    folio: '5009',
    available: 'En préstamo (1 ejemplar)',
    barWidth: 25,
    code: 'QD31.3',
    shortTitle: 'QUÍMICA',
    coverSubtitle: 'General y Orgánica',
    coverAuthor: 'R. Chang',
    coverEdition: '11ª Ed.',
    status: 'prestado',
    recommendation:
      'Bibliografía fundamental para Química de tronco común en ingenierías del TecNM Campus Monclova.',
    topics: ['Química'],
    coverIcon: 'science',
    coverGradient: 'from-[#0c264d] via-[#001f47] to-[#04142d]',
    coverBorderColor: 'border-l-[#C5A059]',
    coverTagColor: 'text-[#ecd49c]',
    coverSubtitleColor: 'text-[#cadbff]',
    coverBarColor: 'bg-[#C5A059]',
    deweyBadgeClass: 'text-primary bg-blue-50 border-blue-100',
  },
  {
    id: 11,
    title: 'Investigación de Operaciones',
    author: 'Hamdy A. Taha',
    shelf: '4.3.2',
    shelfId: 6,
    dewey: 'T57.6',
    cutter: '.T34',
    note: '9na Edición • Optimización e Industria',
    folio: '5010',
    available: '5 de 6 copias libres',
    barWidth: 83,
    code: 'T57.6',
    shortTitle: 'OPERACIONES',
    coverSubtitle: 'Investigación & Mod.',
    coverAuthor: 'H. A. Taha',
    coverEdition: '9ª Ed.',
    status: 'disponible',
    recommendation:
      'Obra base para programación lineal, modelos de redes y optimización en Ingeniería Industrial y Gestión Empresarial.',
    topics: ['Investigación de Operaciones'],
    coverIcon: 'analytics',
    coverGradient: 'from-[#3b2a05] via-[#241a02] to-[#120d00]',
    coverBorderColor: 'border-l-[#d2a858]',
    coverTagColor: 'text-[#f5d99b]',
    coverSubtitleColor: 'text-[#f2e1bd]',
    coverBarColor: 'bg-[#C5A059]',
    deweyBadgeClass: 'text-primary bg-amber-50 border-amber-200',
  },
  {
    id: 12,
    title: 'Sistemas Digitales: Principios y Aplicaciones',
    author: 'Ronald J. Tocci, Neal S. Widmer',
    shelf: '2.4.1',
    shelfId: 4,
    dewey: 'TK7868',
    cutter: '.T63',
    note: '10ma Edición • Lógica Digital y Circuitos',
    folio: '5011',
    available: 'En revisión de catalogación',
    barWidth: 100,
    code: 'TK7868',
    shortTitle: 'SISTEMAS DIG.',
    coverSubtitle: 'Lógica y Microproc.',
    coverAuthor: 'R. J. Tocci',
    coverEdition: '10ª Ed.',
    status: 'catalogo',
    recommendation:
      'Ejemplar reciente en revisión catalográfica para Electrónica, Mecatrónica y Sistemas Computacionales.',
    topics: ['Sistemas Digitales'],
    coverIcon: 'memory',
    coverGradient: 'from-[#121e3d] via-[#091326] to-[#040812]',
    coverBorderColor: 'border-l-[#C5A059]',
    coverTagColor: 'text-[#a8c3f8]',
    coverSubtitleColor: 'text-[#cadbff]',
    coverBarColor: 'bg-blue-400',
    deweyBadgeClass: 'text-primary bg-purple-50 border-purple-200',
  },
]

const SEARCH_DEBOUNCE_MS = 220

const books = ref<BookItem[]>(initialBooks.map((item) => ({ ...item, topics: [...item.topics] })))
const searchKeyword = ref('')
const searchField = ref<InventorySearchField>('all')
const selectedStatus = ref<'all' | BookStatusKey>('all')
const sortBy = ref<InventorySortKey>('dewey')
const layoutMode = ref<'grid' | 'list'>('grid')
const currentPage = ref(1)
const isSubmitting = ref(false)
const isSearching = ref(false)
const searchError = ref('')
const usingApiData = ref(false)

let searchDebounceTimer: ReturnType<typeof setTimeout> | null = null
let activeSearchController: AbortController | null = null
let latestSearchRequestId = 0

const baseMetrics = ref<MetricsSummary>({
  totalBooks: 5240,
  borrowedCount: 85,
  repairCount: 14,
  discardCount: 6,
  catalogCount: 42,
})

// Modals state
const activeBookId = ref<number>(1)
const showFichaModal = ref(false)
const showEditarFichaModal = ref(false)
const showCambiarEstadoModal = ref(false)
const showNewBookModal = ref(false)
const showEstanteModal = ref(false)
const showTemasModal = ref(false)
const feedbackMessage = ref('')

const estanteCodigo = ref('')
const temaNombre = ref('')

const directStatusSelection = ref<BookStatusKey>('disponible')

const editForm = ref({
  folio: '',
  status: 'disponible' as BookStatusKey,
  title: '',
  author: '',
  note: '',
  dewey: '',
  cutter: '',
  shelf: '',
  recommendation: '',
})

function normalizeFolioValue(value: string): string {
  return value.trim().replace(/^#+/, '').trim()
}

function computeNextLocalConsecutiveFolio(): string {
  const usedNumbers = new Set<number>()
  for (const book of books.value) {
    const cleaned = normalizeFolioValue(book.folio)
    const num = Number.parseInt(cleaned, 10)
    if (!Number.isNaN(num) && num >= 5000) {
      usedNumbers.add(num)
    }
  }
  let candidate = 5000
  while (usedNumbers.has(candidate)) {
    candidate += 1
  }
  return String(candidate)
}

function folioAlreadyExists(folioCandidate: string, excludeBookId?: number): boolean {
  const cleanCandidate = normalizeFolioValue(folioCandidate).toLowerCase()
  if (!cleanCandidate) return false
  return books.value.some(
    (b) => b.id !== excludeBookId && normalizeFolioValue(b.folio).toLowerCase() === cleanCandidate,
  )
}

const createEmptyNewBookForm = (suggestedFolio?: string) => ({
  folio: suggestedFolio ?? computeNextLocalConsecutiveFolio(),
  title: '',
  author: '',
  shelf: '1.1.1',
  dewey: 'QA303.2',
  cutter: '.S74 2025',
  note: '',
  status: 'disponible' as BookStatusKey,
})

const newBookForm = ref(createEmptyNewBookForm())

const activeBook = computed<BookItem | undefined>(() =>
  books.value.find((book) => book.id === activeBookId.value),
)

const displayMetrics = computed<MetricsSummary>(() => baseMetrics.value)

function normalizeOfflineText(value: string): string {
  return value
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
}

const filteredBooks = computed(() => {
  const rawQuery = searchKeyword.value.trim()
  const normalizedQuery = normalizeOfflineText(rawQuery)
  const normalizedFolioQuery = normalizeOfflineText(normalizeFolioValue(rawQuery))
  const tokens = normalizedQuery.split(/\s+/).filter(Boolean)

  const list = books.value.filter((book) => {
    const matchesStatus = selectedStatus.value === 'all' || book.status === selectedStatus.value
    if (!matchesStatus) return false
    if (tokens.length === 0) return true

    const normTitle = normalizeOfflineText(book.title)
    const normDewey = normalizeOfflineText(book.dewey)
    const normFolio = normalizeOfflineText(normalizeFolioValue(book.folio))
    const normAuthor = normalizeOfflineText(book.author)
    const normNote = normalizeOfflineText(book.note)
    const normCutter = normalizeOfflineText(book.cutter)
    const normShelf = normalizeOfflineText(book.shelf)
    const normTopics = normalizeOfflineText(book.topics.join(' '))

    if (searchField.value === 'title') {
      return tokens.every((token) => normTitle.includes(token))
    }
    if (searchField.value === 'dewey') {
      return normDewey.includes(normalizedQuery)
    }
    if (searchField.value === 'folio') {
      return Boolean(normalizedFolioQuery) && normFolio.includes(normalizedFolioQuery)
    }

    return tokens.every(
      (token) =>
        normTitle.includes(token) ||
        normDewey.includes(token) ||
        normFolio.includes(token.replace(/^#+/, '')) ||
        normAuthor.includes(token) ||
        normNote.includes(token) ||
        normCutter.includes(token) ||
        normShelf.includes(token) ||
        normTopics.includes(token),
    )
  })

  const sorted = [...list]
  if (sortBy.value === 'status') {
    sorted.sort((a, b) => STATUS_META[a.status].id - STATUS_META[b.status].id || a.title.localeCompare(b.title))
  } else if (sortBy.value === 'barcode') {
    sorted.sort((a, b) => {
      const na = Number.parseInt(normalizeFolioValue(a.folio), 10)
      const nb = Number.parseInt(normalizeFolioValue(b.folio), 10)
      if (!Number.isNaN(na) && !Number.isNaN(nb)) return na - nb
      return a.folio.localeCompare(b.folio)
    })
  } else if (sortBy.value === 'relevance') {
    sorted.sort((a, b) => a.title.localeCompare(b.title))
  } else if (sortBy.value === 'dewey') {
    sorted.sort((a, b) => a.dewey.localeCompare(b.dewey))
  }
  return sorted
})

const ITEMS_PER_PAGE = 4

const totalPages = computed(() =>
  Math.max(1, Math.ceil(filteredBooks.value.length / ITEMS_PER_PAGE)),
)

const visiblePageNumbers = computed(() =>
  Array.from({ length: totalPages.value }, (_, index) => index + 1),
)

const paginatedBooks = computed(() => {
  const safePage = Math.min(Math.max(1, currentPage.value), totalPages.value)
  const start = (safePage - 1) * ITEMS_PER_PAGE
  return filteredBooks.value.slice(start, start + ITEMS_PER_PAGE)
})

watch(filteredBooks, () => {
  if (currentPage.value > totalPages.value) {
    currentPage.value = totalPages.value
  }
})

function toggleStatusFilter(status: 'all' | BookStatusKey) {
  selectedStatus.value = selectedStatus.value === status ? 'all' : status
}

function availabilityByStatus(status: BookStatusKey): { text: string; width: number } {
  switch (status) {
    case 'disponible':
      return { text: 'Disponible para consulta', width: 80 }
    case 'prestado':
      return { text: 'En préstamo activo', width: 25 }
    case 'reparacion':
      return { text: 'En taller de encuadernación', width: 40 }
    case 'baja':
      return { text: '0 disponibles (Baja)', width: 10 }
    case 'catalogo':
      return { text: 'En revisión de catalogación', width: 100 }
  }
}

function buildShortTitle(title: string): string {
  const words = title.trim().split(/\s+/).filter(Boolean)
  const significant = words.find((word) => word.length > 3) ?? words[0] ?? 'OBRA'
  return significant.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ0-9]/g, '').slice(0, 13).toUpperCase() || 'OBRA'
}

function mapApiBook(item: BookApiDto, idx: number): BookItem {
  const style = DEFAULT_COVER_STYLES[idx % DEFAULT_COVER_STYLES.length]
  const statusId = Number(item.statusId ?? 1)
  const status = STATUS_BY_ID[statusId] ?? 'disponible'
  const title = item.title || 'Sin título'
  const author = item.author || 'Autor institucional'
  const shelfRaw = item.shelfName || 'General'
  const shelfClean = shelfRaw.replace(/^Estante\s+/i, '')
  const dewey = item.dewey || '000'
  const fallbackAvailability = availabilityByStatus(status)
  const topics = Array.isArray(item.topics) ? item.topics : []

  return {
    id: Number(item.id ?? idx + 1),
    title,
    author,
    note: item.note || 'Acervo institucional TecNM Monclova',
    folio: normalizeFolioValue(item.folio || `${5000 + idx}`),
    dewey,
    cutter: item.cutter || '',
    shelf: shelfClean,
    shelfId: Number(item.shelfId ?? 1),
    status,
    available: item.availableText || fallbackAvailability.text,
    barWidth: Number(item.availabilityPercent ?? fallbackAvailability.width),
    code: dewey,
    shortTitle: buildShortTitle(title),
    coverSubtitle: shelfClean.slice(0, 18),
    coverAuthor: author.split(/[•,]/)[0]?.trim().slice(0, 14) || 'TecNM',
    coverEdition: 'Acervo',
    recommendation:
      topics.length > 0
        ? `Temas asociados: ${topics.join(', ')}. Ejemplar registrado en la base de datos del Sistema de Biblioteca TecNM Campus Monclova.`
        : 'Ejemplar registrado en la base de datos del Sistema de Biblioteca TecNM Campus Monclova.',
    topics,
    ...style,
  }
}

async function fetchMetrics() {
  try {
    const metrics = await getInventoryMetrics()
    baseMetrics.value = {
      totalBooks: Number(metrics.totalBooks ?? 0),
      borrowedCount: Number(metrics.borrowedCount ?? 0),
      repairCount: Number(metrics.repairCount ?? 0),
      discardCount: Number(metrics.discardCount ?? 0),
      catalogCount: Number(metrics.catalogCount ?? 0),
    }
  } catch {
    // Mantiene métricas base cuando el backend no está accesible
  }
}

async function executeBackendSearch() {
  const requestId = ++latestSearchRequestId

  activeSearchController?.abort()
  const controller = new AbortController()
  activeSearchController = controller

  isSearching.value = true
  searchError.value = ''

  try {
    const results = await searchBooks(
      {
        search: searchKeyword.value,
        field: searchField.value,
        status: selectedStatus.value,
        sortBy: sortBy.value,
      },
      controller.signal,
    )

    if (requestId !== latestSearchRequestId) {
      return
    }

    books.value = results.map((item, idx) => mapApiBook(item, idx))
    usingApiData.value = true
    currentPage.value = 1

    if (books.value.length > 0 && !books.value.some((book) => book.id === activeBookId.value)) {
      activeBookId.value = books.value[0].id
    }
  } catch (error) {
    if (axios.isCancel(error) || (error as { name?: string })?.name === 'AbortError') {
      return
    }

    if (requestId !== latestSearchRequestId) {
      return
    }

    if (usingApiData.value) {
      searchError.value = 'No se pudo consultar el inventario en el servidor. Intenta de nuevo.'
    }
  } finally {
    if (requestId === latestSearchRequestId) {
      isSearching.value = false
    }
  }
}

function scheduleRealtimeSearch() {
  if (searchDebounceTimer !== null) {
    clearTimeout(searchDebounceTimer)
  }
  searchDebounceTimer = setTimeout(() => {
    searchDebounceTimer = null
    void executeBackendSearch()
  }, SEARCH_DEBOUNCE_MS)
}

function runImmediateSearch() {
  if (searchDebounceTimer !== null) {
    clearTimeout(searchDebounceTimer)
    searchDebounceTimer = null
  }
  void executeBackendSearch()
}

function setStatusFilter(status: 'all' | BookStatusKey) {
  selectedStatus.value = status
}

function clearSearch() {
  if (!searchKeyword.value) {
    return
  }
  searchKeyword.value = ''
}

function resetFilters() {
  const hadChanges = searchKeyword.value !== '' || selectedStatus.value !== 'all'
  searchKeyword.value = ''
  selectedStatus.value = 'all'
  if (!hadChanges) {
    runImmediateSearch()
  }
}

function openFichaModal(id: number) {
  activeBookId.value = id
  showFichaModal.value = true
}

function closeFichaModal() {
  showFichaModal.value = false
}

function openCambiarEstadoModal() {
  if (!activeBook.value) return
  directStatusSelection.value = activeBook.value.status
  showCambiarEstadoModal.value = true
}

function closeCambiarEstadoModal() {
  showCambiarEstadoModal.value = false
}

async function applyDirectStatusChange() {
  if (isSubmitting.value || !activeBook.value) return
  isSubmitting.value = true
  try {
    const newStatus = directStatusSelection.value
    const statusId = STATUS_META[newStatus].id

    try {
      await updateBookStatus(activeBook.value.id, {
        statusId,
        note: activeBook.value.note,
      })
      void fetchMetrics()
    } catch {
      // Continúa actualizando estado local si la API no está conectada
    }

    const updatedAvailability = availabilityByStatus(newStatus)
    activeBook.value.status = newStatus
    activeBook.value.available = updatedAvailability.text
    activeBook.value.barWidth = updatedAvailability.width
    showCambiarEstadoModal.value = false
  } finally {
    isSubmitting.value = false
  }
}

function openEditarFichaModal() {
  if (!activeBook.value) return
  editForm.value = {
    folio: activeBook.value.folio,
    status: activeBook.value.status,
    title: activeBook.value.title,
    author: activeBook.value.author,
    note: activeBook.value.note,
    dewey: activeBook.value.dewey,
    cutter: activeBook.value.cutter,
    shelf: activeBook.value.shelf,
    recommendation: activeBook.value.recommendation,
  }
  showEditarFichaModal.value = true
}

function closeEditarFichaModal() {
  showEditarFichaModal.value = false
}

async function saveFichaEdits() {
  if (isSubmitting.value || !activeBook.value) return
  isSubmitting.value = true
  try {
    const previousStatus = activeBook.value.status
    const nextStatus = editForm.value.status
    const cleanedFolio = normalizeFolioValue(editForm.value.folio)

    if (cleanedFolio && folioAlreadyExists(cleanedFolio, activeBook.value.id)) {
      searchError.value = `El folio ${cleanedFolio} ya existe en el inventario. No se permiten folios duplicados.`
      return
    }

    try {
      await updateBook(activeBook.value.id, {
        title: editForm.value.title.trim(),
        author: editForm.value.author.trim(),
        note: editForm.value.note.trim(),
        folio: cleanedFolio || normalizeFolioValue(activeBook.value.folio),
        dewey: editForm.value.dewey.trim(),
        cutter: editForm.value.cutter.trim(),
        statusId: STATUS_META[nextStatus].id,
        shelfName: editForm.value.shelf.trim(),
      })
      void fetchMetrics()
    } catch {
      // Continúa actualizando estado local si la API no está conectada
    }

    activeBook.value.title = editForm.value.title.trim()
    activeBook.value.author = editForm.value.author.trim()
    activeBook.value.note = editForm.value.note.trim()
    activeBook.value.dewey = editForm.value.dewey.trim()
    activeBook.value.cutter = editForm.value.cutter.trim()
    activeBook.value.shelf = editForm.value.shelf.trim()
    activeBook.value.status = nextStatus
    activeBook.value.recommendation = editForm.value.recommendation.trim()
    activeBook.value.code = activeBook.value.dewey
    activeBook.value.shortTitle = buildShortTitle(activeBook.value.title)

    if (previousStatus !== nextStatus) {
      const updatedAvailability = availabilityByStatus(nextStatus)
      activeBook.value.available = updatedAvailability.text
      activeBook.value.barWidth = updatedAvailability.width
    }

    feedbackMessage.value = `Ficha del ejemplar (Folio ${activeBook.value.folio}) actualizada correctamente.`
    showEditarFichaModal.value = false
  } finally {
    isSubmitting.value = false
  }
}

async function assignUniqueNextFolio() {
  let suggested = computeNextLocalConsecutiveFolio()
  try {
    const apiNext = await getNextAvailableFolio()
    if (apiNext?.nextFolio) {
      const candidate = normalizeFolioValue(apiNext.nextFolio)
      if (!folioAlreadyExists(candidate)) {
        suggested = candidate
      }
    }
  } catch {
    // Usa el siguiente consecutivo disponible local >= 5000
  }
  newBookForm.value = createEmptyNewBookForm(suggested)
}

function openNewBookModal() {
  newBookForm.value = createEmptyNewBookForm()
  showNewBookModal.value = true
  void assignUniqueNextFolio()
}

function closeNewBookModal() {
  showNewBookModal.value = false
}

async function saveNewBook(keepOpen = false) {
  if (isSubmitting.value) return
  const title = newBookForm.value.title.trim()
  const author = newBookForm.value.author.trim()
  if (!title || !author) return

  isSubmitting.value = true
  searchError.value = ''
  try {
    const status = newBookForm.value.status
    const statusId = STATUS_META[status].id
    let folio = normalizeFolioValue(newBookForm.value.folio) || computeNextLocalConsecutiveFolio()

    // Validar que el folio sea >= 5000 y que NO exista ya en el sistema antes de asignarlo
    const numericFolio = Number.parseInt(folio, 10)
    if (Number.isNaN(numericFolio) || numericFolio < 5000 || folioAlreadyExists(folio)) {
      folio = computeNextLocalConsecutiveFolio()
    }

    const dewey = newBookForm.value.dewey.trim() || 'QA303.2'
    const cutter = newBookForm.value.cutter.trim() || '.S74 2025'
    const shelf = newBookForm.value.shelf.trim() || '1.1.1'
    const note = newBookForm.value.note.trim() || 'Nuevo ingreso • Acervo TecNM Monclova'
    const availability = availabilityByStatus(status)
    const style = DEFAULT_COVER_STYLES[books.value.length % DEFAULT_COVER_STYLES.length]

    let createdId = Math.max(0, ...books.value.map((b) => b.id)) + 1

    try {
      const created = await createBook({
        title,
        author,
        note,
        folio,
        dewey,
        cutter,
        statusId,
        shelfId: 1,
        shelfName: shelf,
      })
      if (created?.id) {
        createdId = Number(created.id)
      }
      if (created?.folio) {
        folio = normalizeFolioValue(created.folio)
      }
      void fetchMetrics()
    } catch {
      // Mantiene el alta local si el backend no responde
    }

    const createdBook: BookItem = {
      id: createdId,
      title,
      author,
      note,
      folio,
      dewey,
      cutter,
      shelf,
      shelfId: 1,
      status,
      available: availability.text,
      barWidth: availability.width,
      code: dewey,
      shortTitle: buildShortTitle(title),
      coverSubtitle: shelf,
      coverAuthor: author.split(/[•,]/)[0]?.trim().slice(0, 14) || 'TecNM',
      coverEdition: '2025',
      recommendation: 'Ejemplar incorporado recientemente al acervo físico del TecNM Campus Monclova.',
      topics: [],
      ...style,
    }

    books.value.unshift(createdBook)
    feedbackMessage.value = `Ejemplar "${title}" registrado con Folio consecutivo ${folio}.`
    if (!usingApiData.value) {
      baseMetrics.value.totalBooks += 1
    }

    if (keepOpen) {
      await assignUniqueNextFolio()
    } else {
      showNewBookModal.value = false
    }
  } finally {
    isSubmitting.value = false
  }
}

function openEstanteModal() {
  estanteCodigo.value = ''
  showEstanteModal.value = true
}

function closeEstanteModal() {
  showEstanteModal.value = false
}

async function saveNewEstante() {
  if (isSubmitting.value) return
  const codigo = estanteCodigo.value.trim()
  if (!codigo) return

  isSubmitting.value = true
  try {
    try {
      await createShelf(codigo)
    } catch {
      // Continúa en modo local si el backend no está disponible
    }
    showEstanteModal.value = false
    feedbackMessage.value = `Estante "${codigo}" registrado correctamente en el catálogo.`
  } finally {
    isSubmitting.value = false
  }
}

function openTemasModal() {
  temaNombre.value = ''
  showTemasModal.value = true
}

function closeTemasModal() {
  showTemasModal.value = false
}

async function saveNewTema() {
  if (isSubmitting.value) return
  const nombre = temaNombre.value.trim()
  if (!nombre) return

  isSubmitting.value = true
  try {
    try {
      await createTopic(nombre)
    } catch {
      // Continúa en modo local si el backend no está disponible
    }
    showTemasModal.value = false
    feedbackMessage.value = `Tema "${nombre}" registrado correctamente en el catálogo.`
  } finally {
    isSubmitting.value = false
  }
}

function handleEscapeKey(event: KeyboardEvent) {
  if (event.key !== 'Escape') return
  if (showCambiarEstadoModal.value) {
    closeCambiarEstadoModal()
  } else if (showEditarFichaModal.value) {
    closeEditarFichaModal()
  } else if (showNewBookModal.value) {
    closeNewBookModal()
  } else if (showEstanteModal.value) {
    closeEstanteModal()
  } else if (showTemasModal.value) {
    closeTemasModal()
  } else if (showFichaModal.value) {
    closeFichaModal()
  }
}

watch(searchKeyword, (value) => {
  if (!value.trim()) {
    runImmediateSearch()
    return
  }
  scheduleRealtimeSearch()
})

watch([selectedStatus, sortBy, searchField], () => {
  runImmediateSearch()
})

onMounted(() => {
  void Promise.all([executeBackendSearch(), fetchMetrics()])
  window.addEventListener('keydown', handleEscapeKey)
})

onBeforeUnmount(() => {
  if (searchDebounceTimer !== null) {
    clearTimeout(searchDebounceTimer)
  }
  activeSearchController?.abort()
  window.removeEventListener('keydown', handleEscapeKey)
})
</script>

<template>
  <main class="inventory-view w-full flex-1 bg-[#f5f7fc]">
        <!-- Top Hero Banner Section -->
        <section class="relative w-full bg-gradient-to-b from-[#001838] via-[#00285a] to-[#0c3770] px-4 sm:px-space-xl pt-7 pb-7 text-on-primary overflow-hidden shadow-md">
          <div class="absolute inset-0 opacity-10 bg-[radial-gradient(#C5A059_1px,transparent_1px)] [background-size:24px_24px] pointer-events-none"></div>
          <div class="absolute -right-20 -top-24 w-96 h-96 rounded-full bg-[#C5A059]/10 blur-3xl pointer-events-none"></div>
          <div class="absolute -left-20 bottom-0 w-80 h-80 rounded-full bg-blue-500/10 blur-3xl pointer-events-none"></div>

          <div class="relative max-w-[1600px] mx-auto flex flex-col gap-4">
            <div class="flex flex-col lg:flex-row items-center justify-between gap-4 text-center lg:text-left">
              <div class="flex flex-col gap-1 max-w-3xl">
                <div class="flex items-center justify-center lg:justify-start gap-2">
                  <span class="hidden sm:inline-block text-white/40 text-xs">•</span>
                  <span class="hidden sm:inline-block font-citation-code text-xs text-white/70">
                    Módulo de Bibliotecarios
                  </span>
                </div>
                <div class="flex flex-wrap items-baseline justify-center lg:justify-start gap-2 mt-0.5">
                  <h1 class="font-display-hero !text-[30px] lg:!text-[36px] font-extrabold text-white tracking-tight !leading-none">
                    Biblioteca
                  </h1>
                  <span class="font-headline-md text-[20px] lg:text-[24px] font-semibold text-[#ecd49c] tracking-wide">
                    Tec Monclova
                  </span>
                </div>
                <p class="font-body-md text-xs !text-[#c3d5f5] !max-w-2xl leading-relaxed">
                  Panel Administrativo de Control y Catalogación del Acervo Físico. Gestione estados de disponibilidad, control técnico de ejemplares, mantenimiento de volúmenes y fichas topográficas Dewey.
                </p>
              </div>
            </div>

            <div class="bg-white/95 backdrop-blur-md p-3.5 rounded-2xl shadow-lg border border-white/40 text-on-surface">
              <form class="flex flex-col lg:flex-row items-stretch gap-2.5" @submit.prevent="runImmediateSearch">
                <div class="relative min-w-[235px]">
                  <select
                    id="searchFieldSelector"
                    v-model="searchField"
                    class="inventory-select w-full !h-11 !min-h-0 !pl-3.5 !pr-10 !py-0 bg-slate-100 text-primary font-label-md !text-xs font-bold !rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-tecnm-gold cursor-pointer"
                    aria-label="Campo de búsqueda"
                  >
                    <option value="all">Todo (Título, Dewey, Folio)</option>
                    <option value="title">Solo Título de la Obra</option>
                    <option value="dewey">Código Dewey (CDD)</option>
                    <option value="folio">Folio (5000+)</option>
                  </select>
                </div>
                <div class="relative flex-1 flex items-center">
                  <span
                    :class="[
                      'material-symbols-outlined absolute left-4 text-primary text-xl pointer-events-none',
                      isSearching ? 'animate-spin' : '',
                    ]"
                  >
                    {{ isSearching ? 'progress_activity' : 'search' }}
                  </span>
                  <input
                    id="searchKeyword"
                    v-model="searchKeyword"
                    class="inventory-input w-full !h-11 !min-h-0 !pl-11 !pr-10 !py-0 bg-slate-50 text-on-surface font-body-md !text-xs placeholder:text-slate-400 !rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-tecnm-gold focus:bg-white transition-all shadow-inner"
                    placeholder="Buscar por título (con o sin acentos), código Dewey o folio (5000+)..."
                    type="text"
                    autocomplete="off"
                    aria-label="Buscar en el inventario"
                  />
                  <button
                    v-if="searchKeyword"
                    class="absolute right-3 p-1 text-slate-400 hover:text-primary rounded-full transition-colors"
                    title="Borrar búsqueda"
                    type="button"
                    @click="clearSearch"
                  >
                    <span class="material-symbols-outlined text-base">cancel</span>
                  </button>
                </div>
                <button
                  class="h-11 px-7 bg-gradient-to-r from-primary to-[#184580] hover:from-[#001738] hover:to-primary text-white font-headline-sm text-xs rounded-xl transition-all flex items-center justify-center gap-2 shadow-md shadow-primary/30 active:scale-95 border border-white/20 shrink-0"
                  type="submit"
                >
                  <span class="material-symbols-outlined text-tecnm-gold-light text-lg">search</span>
                  <span class="font-bold tracking-wide">Buscar</span>
                </button>
              </form>
            </div>
          </div>
        </section>

        <!-- Metric & Inventory Quick Status Strip -->
        <section class="w-full px-4 sm:px-space-xl pt-5 pb-1 relative z-20">
          <div class="max-w-[1600px] mx-auto inventory-metrics-grid">
            <!-- Metric 1: Total -->
            <button
              type="button"
              :class="[
                'bg-white p-4 rounded-2xl shadow-sm border text-left flex items-center gap-3.5 hover:border-tecnm-gold/50 transition-all',
                selectedStatus === 'all' ? 'border-primary/40 ring-2 ring-primary/15' : 'border-slate-200/80',
              ]"
              @click="setStatusFilter('all')"
            >
              <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-[#002351] to-[#1b396a] text-[#ecd49c] flex items-center justify-center shrink-0 shadow-sm">
                <span class="material-symbols-outlined text-[24px]">menu_book</span>
              </div>
              <div class="flex flex-col min-w-0">
                <span class="font-headline-md text-xl xl:text-2xl text-primary font-bold leading-tight tracking-tight whitespace-nowrap">
                  {{ displayMetrics.totalBooks.toLocaleString('es-MX') }}
                </span>
                <span class="font-label-md text-[11px] xl:text-xs font-semibold text-slate-500 uppercase tracking-wider mt-0.5 whitespace-nowrap">
                  Total
                </span>
              </div>
            </button>

            <!-- Metric 2: Prestados -->
            <button
              type="button"
              :class="[
                'bg-white p-4 rounded-2xl shadow-sm border text-left flex items-center gap-3.5 hover:border-blue-400/50 transition-all',
                selectedStatus === 'prestado' ? 'border-[#1D4ED8] ring-2 ring-[#1D4ED8]/20' : 'border-slate-200/80',
              ]"
              @click="toggleStatusFilter('prestado')"
            >
              <div class="w-10 h-10 rounded-xl bg-[#DBEAFE] text-[#1D4ED8] flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[20px]">sync_alt</span>
              </div>
              <div class="flex flex-col min-w-0">
                <span class="font-headline-md text-xl xl:text-2xl text-[#1D4ED8] font-bold leading-tight tracking-tight whitespace-nowrap">
                  {{ displayMetrics.borrowedCount }}
                </span>
                <span class="font-label-md text-[11px] xl:text-xs font-semibold text-slate-500 uppercase tracking-wider mt-0.5 whitespace-nowrap">
                  Prestados
                </span>
              </div>
            </button>

            <!-- Metric 3: Reparación -->
            <button
              type="button"
              :class="[
                'bg-white p-4 rounded-2xl shadow-sm border text-left flex items-center gap-3.5 hover:border-amber-400/50 transition-all',
                selectedStatus === 'reparacion' ? 'border-[#D97706] ring-2 ring-[#D97706]/20' : 'border-slate-200/80',
              ]"
              @click="toggleStatusFilter('reparacion')"
            >
              <div class="w-10 h-10 rounded-xl bg-[#FEF3C7] text-[#D97706] flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[20px]">build_circle</span>
              </div>
              <div class="flex flex-col min-w-0">
                <span class="font-headline-md text-xl xl:text-2xl text-[#D97706] font-bold leading-tight tracking-tight whitespace-nowrap">
                  {{ displayMetrics.repairCount }}
                </span>
                <span class="font-label-md text-[11px] xl:text-xs font-semibold text-slate-500 uppercase tracking-wider mt-0.5 whitespace-nowrap">
                  Reparación
                </span>
              </div>
            </button>

            <!-- Metric 4: En Baja -->
            <button
              type="button"
              :class="[
                'bg-white p-4 rounded-2xl shadow-sm border text-left flex items-center gap-3.5 hover:border-rose-400/50 transition-all',
                selectedStatus === 'baja' ? 'border-[#DC2626] ring-2 ring-[#DC2626]/20' : 'border-slate-200/80',
              ]"
              @click="toggleStatusFilter('baja')"
            >
              <div class="w-10 h-10 rounded-xl bg-[#FEE2E2] text-[#DC2626] flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[20px]">delete_forever</span>
              </div>
              <div class="flex flex-col min-w-0">
                <span class="font-headline-md text-xl xl:text-2xl text-[#DC2626] font-bold leading-tight tracking-tight whitespace-nowrap">
                  {{ displayMetrics.discardCount }}
                </span>
                <span class="font-label-md text-[11px] xl:text-xs font-semibold text-slate-500 uppercase tracking-wider mt-0.5 whitespace-nowrap">
                  En Baja
                </span>
              </div>
            </button>

            <!-- Metric 5: Catálogo -->
            <button
              type="button"
              :class="[
                'bg-white p-4 rounded-2xl shadow-sm border text-left flex items-center gap-3.5 hover:border-purple-400/50 transition-all inventory-metric-last',
                selectedStatus === 'catalogo' ? 'border-[#7C3AED] ring-2 ring-[#7C3AED]/20' : 'border-slate-200/80',
              ]"
              @click="toggleStatusFilter('catalogo')"
            >
              <div class="w-10 h-10 rounded-xl bg-[#EDE9FE] text-[#7C3AED] flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[20px]">auto_stories</span>
              </div>
              <div class="flex flex-col min-w-0">
                <span class="font-headline-md text-xl xl:text-2xl text-[#7C3AED] font-bold leading-tight tracking-tight whitespace-nowrap">
                  {{ displayMetrics.catalogCount }}
                </span>
                <span class="font-label-md text-[11px] xl:text-xs font-semibold text-slate-500 uppercase tracking-wider mt-0.5 whitespace-nowrap">
                  Catálogo
                </span>
              </div>
            </button>
          </div>
        </section>

        <!-- Main Catalog Area: Full Width Grid -->
        <section class="w-full px-4 sm:px-space-xl py-7">
          <div class="max-w-[1600px] mx-auto flex flex-col gap-6">
            <!-- Toolbar & Controls -->
            <div class="bg-white p-4 rounded-xl shadow-[0_2px_12px_rgba(0,35,81,0.04)] border border-slate-100 flex flex-col md:flex-row items-center justify-between gap-space-md">
              <div class="flex items-center gap-space-sm w-full md:w-auto">
                <span
                  :class="[
                    'w-2.5 h-2.5 rounded-full shrink-0',
                    isSearching ? 'bg-amber-500 ring-4 ring-amber-100' : 'bg-emerald-500 ring-4 ring-emerald-100',
                  ]"
                ></span>
                <p class="font-body-md text-sm !text-slate-700 !max-w-none" aria-live="polite">
                  <template v-if="isSearching">Buscando coincidencias...</template>
                  <template v-else>
                    Mostrando <span class="font-bold text-primary">{{ filteredBooks.length }}</span> obras registradas
                  </template>
                </p>
              </div>

              <div class="flex items-center flex-wrap gap-2.5 w-full md:w-auto justify-end">
                <div class="flex items-center gap-2">
                  <label class="font-label-sm text-xs text-slate-500 font-semibold whitespace-nowrap" for="sortSelector">
                    Ordenar:
                  </label>
                  <select
                    id="sortSelector"
                    v-model="sortBy"
                    class="inventory-select !w-auto min-w-[255px] !h-9 !min-h-0 !pl-3.5 !pr-10 !py-0 bg-slate-50 text-slate-800 font-label-md !text-xs !rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary cursor-pointer"
                  >
                    <option value="dewey">Clasificación Dewey Ascendente</option>
                    <option value="status">Estado Administrativo</option>
                    <option value="relevance">Plan de Estudios Tec Monclova</option>
                    <option value="barcode">Número de Inventario</option>
                  </select>
                </div>

                <div class="flex items-center bg-slate-100 rounded-lg p-1 border border-slate-200">
                  <button
                    type="button"
                    :class="[
                      'p-1.5 rounded transition-colors',
                      layoutMode === 'grid' ? 'bg-white text-primary shadow-sm' : 'text-slate-500 hover:text-slate-800',
                    ]"
                    title="Vista Cuadrícula"
                    aria-label="Vista Cuadrícula"
                    @click="layoutMode = 'grid'"
                  >
                    <span class="material-symbols-outlined text-lg leading-none">grid_view</span>
                  </button>
                  <button
                    type="button"
                    :class="[
                      'p-1.5 rounded transition-colors',
                      layoutMode === 'list' ? 'bg-white text-primary shadow-sm' : 'text-slate-500 hover:text-slate-800',
                    ]"
                    title="Vista Detallada"
                    aria-label="Vista Detallada"
                    @click="layoutMode = 'list'"
                  >
                    <span class="material-symbols-outlined text-lg leading-none">view_agenda</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- 3-Button Catalog Management Strip -->
            <div class="inventory-actions-grid w-full">
              <button
                type="button"
                class="h-12 px-5 bg-primary-container hover:bg-[#184580] text-white rounded-xl font-label-md text-xs font-semibold flex items-center justify-center gap-2 shadow-sm transition-all active:scale-[0.99] border border-white/10"
                @click="openNewBookModal"
              >
                <span class="material-symbols-outlined text-[20px] text-tecnm-gold-light">add_circle</span>
                <span>+ Registrar Nuevo Ejemplar</span>
              </button>
              <button
                type="button"
                class="h-12 px-5 bg-primary-container hover:bg-[#184580] text-white rounded-xl font-label-md text-xs font-semibold flex items-center justify-center gap-2 shadow-sm transition-all active:scale-[0.99] border border-white/10"
                @click="openEstanteModal"
              >
                <span class="material-symbols-outlined text-[20px] text-tecnm-gold-light">shelves</span>
                <span>+ Registrar Estante</span>
              </button>
              <button
                type="button"
                class="h-12 px-5 bg-primary-container hover:bg-[#184580] text-white rounded-xl font-label-md text-xs font-semibold flex items-center justify-center gap-2 shadow-sm transition-all active:scale-[0.99] border border-white/10"
                @click="openTemasModal"
              >
                <span class="material-symbols-outlined text-[20px] text-tecnm-gold-light">label</span>
                <span>+ Registrar Temas</span>
              </button>
            </div>

            <!-- Search Error Banner -->
            <div
              v-if="searchError"
              class="px-4 py-3 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 text-xs font-medium flex items-center justify-between gap-3"
              role="alert"
            >
              <span class="flex items-center gap-2">
                <span class="material-symbols-outlined text-[18px]">error</span>
                <span>{{ searchError }}</span>
              </span>
              <button
                type="button"
                class="px-2.5 py-1 rounded-lg bg-rose-100 hover:bg-rose-200 font-semibold transition-colors"
                @click="runImmediateSearch"
              >
                Reintentar
              </button>
            </div>

            <!-- Feedback Banner -->
            <div
              v-if="feedbackMessage"
              class="px-4 py-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-medium flex items-center justify-between gap-3"
              role="status"
            >
              <span class="flex items-center gap-2">
                <span class="material-symbols-outlined text-[18px]">check_circle</span>
                <span>{{ feedbackMessage }}</span>
              </span>
              <button
                type="button"
                class="p-1 rounded hover:bg-emerald-100"
                aria-label="Cerrar aviso"
                @click="feedbackMessage = ''"
              >
                <span class="material-symbols-outlined text-[16px]">close</span>
              </button>
            </div>

            <!-- Empty state when search/filter matches 0 books -->
            <div
              v-if="filteredBooks.length === 0"
              class="bg-white rounded-2xl p-10 border border-slate-200 text-center flex flex-col items-center gap-3 shadow-sm"
            >
              <span class="material-symbols-outlined text-4xl text-slate-400">search_off</span>
              <p class="font-headline-sm text-base text-primary font-bold">
                No se encontraron ejemplares con los filtros actuales
              </p>
              <p class="text-xs !text-slate-500">
                Prueba con otro término de búsqueda o restablece el filtro de estado.
              </p>
              <button
                type="button"
                class="mt-1 px-4 py-2 bg-primary text-white rounded-lg text-xs font-semibold hover:bg-[#184580] transition-colors"
                @click="resetFilters"
              >
                Mostrar todo el inventario
              </button>
            </div>

            <!-- 4-Column Responsive Grid or 1-Column List -->
            <div
              v-else
              :class="[
                'transition-all duration-300',
                layoutMode === 'list' ? 'inventory-books-list' : 'inventory-books-grid',
              ]"
            >
              <article
                v-for="book in paginatedBooks"
                :key="book.id"
                class="book-card group relative bg-white rounded-2xl p-4 shadow-[0_4px_18px_rgba(0,35,81,0.06)] hover:shadow-[0_20px_35px_-8px_rgba(0,35,81,0.18)] border border-slate-200 hover:border-tecnm-gold/60 cursor-pointer flex flex-col justify-between overflow-visible transition-all duration-300"
                @click="openFichaModal(book.id)"
              >
                <div>
                  <div class="flex items-center justify-between mb-3">
                    <span
                      :class="[
                        'px-2.5 py-0.5 rounded-full text-[11px] font-bold border flex items-center gap-1.5 shadow-sm',
                        STATUS_META[book.status].statusClass,
                      ]"
                    >
                      <span :class="['w-1.5 h-1.5 rounded-full', STATUS_META[book.status].dotClass]"></span>
                      <span>{{ STATUS_META[book.status].cardLabel }}</span>
                    </span>
                    <span class="font-citation-code text-[11px] font-bold text-primary bg-slate-100 px-2 py-0.5 rounded">
                      {{ book.folio }}
                    </span>
                  </div>

                  <div class="flex gap-3.5 items-start">
                    <div class="book-stage shrink-0">
                      <div
                        :class="[
                          'book-cover-3d relative w-[90px] h-32 rounded-r-md rounded-l-[2px] shadow-[5px_7px_16px_rgba(0,25,60,0.35)] bg-gradient-to-br flex flex-col justify-between p-2 text-white border-l-4 border-y border-r border-white/20 overflow-hidden',
                          book.coverGradient,
                          book.coverBorderColor,
                          book.status === 'baja' ? 'opacity-90' : '',
                        ]"
                      >
                        <div class="book-spine-lighting absolute inset-0 pointer-events-none z-20"></div>
                        <div class="relative z-10 flex justify-between items-start">
                          <span :class="['font-citation-code text-[7px] font-bold tracking-widest', book.coverTagColor]">
                            ITSM
                          </span>
                          <span :class="['material-symbols-outlined text-[11px]', book.coverTagColor]">
                            {{ book.coverIcon }}
                          </span>
                        </div>
                        <div class="relative z-10 my-auto text-center">
                          <p
                            :class="[
                              'font-headline-sm text-[9px] leading-tight font-extrabold tracking-wider drop-shadow',
                              book.id === 2 ? '!text-white' : 'gold-foil-text',
                            ]"
                          >
                            {{ book.shortTitle }}
                          </p>
                          <p :class="['font-label-sm text-[6.5px] tracking-tight mt-0.5', book.coverSubtitleColor]">
                            {{ book.coverSubtitle }}
                          </p>
                          <div :class="['w-6 h-0.5 mx-auto mt-1 rounded-full', book.coverBarColor]"></div>
                        </div>
                        <div class="relative z-10 flex items-center justify-between text-[6.5px] text-white/80 border-t border-white/15 pt-1 font-citation-code">
                          <span class="truncate max-w-[46px]">{{ book.coverAuthor }}</span>
                          <span>{{ book.coverEdition }}</span>
                        </div>
                      </div>
                    </div>

                    <div class="flex flex-col min-w-0 flex-1">
                      <h3 class="font-headline-sm !text-[14px] leading-snug text-primary group-hover:text-[#184580] line-clamp-2 transition-colors font-bold">
                        {{ book.title }}
                      </h3>
                      <p class="font-body-md text-[11.5px] !text-slate-600 mt-0.5 line-clamp-1">
                        <span class="font-semibold text-primary">Autor:</span> {{ book.author }}
                      </p>
                      <p class="font-citation-code text-[10px] !text-slate-500 mt-1 line-clamp-1">
                        {{ book.note }}
                      </p>
                      <div class="mt-2 flex flex-wrap items-center gap-1">
                        <span
                          :class="[
                            'font-citation-code text-[10px] font-semibold px-1.5 py-0.5 rounded border',
                            book.deweyBadgeClass,
                          ]"
                        >
                          Dewey: {{ book.dewey }}
                        </span>
                        <span class="font-citation-code text-[10px] text-slate-700 bg-slate-100 px-1.5 py-0.5 rounded">
                          Cutter: {{ book.cutter }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="mt-3 pt-2.5 border-t border-slate-100 flex items-center justify-between text-slate-600">
                  <div class="flex items-center gap-1 font-body-sm text-[11px] min-w-0">
                    <span
                      :class="[
                        'material-symbols-outlined text-[14px] shrink-0',
                        book.status === 'baja' ? 'text-rose-600' : 'text-tecnm-gold',
                      ]"
                    >
                      shelves
                    </span>
                    <span class="font-semibold text-slate-700 truncate">Estante {{ book.shelf }}</span>
                  </div>
                  <button
                    type="button"
                    class="px-2.5 py-1 bg-primary/10 hover:bg-primary hover:text-white text-primary font-label-sm text-[11px] font-semibold rounded-lg transition-all flex items-center gap-1 shrink-0"
                    @click.stop="openFichaModal(book.id)"
                  >
                    <span>Ficha</span>
                    <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
                  </button>
                </div>
              </article>
            </div>

            <!-- Pagination Strip -->
            <div
              v-if="filteredBooks.length > 0"
              class="mt-8 flex flex-col md:flex-row items-center justify-center gap-4 pt-5 border-t border-slate-200"
            >
              <div class="flex items-center justify-center flex-wrap gap-1.5">
                <button
                  type="button"
                  class="p-2 rounded-lg bg-white border border-slate-200 hover:bg-slate-50 text-slate-500 disabled:opacity-40 cursor-pointer disabled:cursor-not-allowed"
                  :disabled="currentPage <= 1"
                  aria-label="Página anterior"
                  @click="currentPage = Math.max(1, currentPage - 1)"
                >
                  <span class="material-symbols-outlined text-base">chevron_left</span>
                </button>
                <button
                  v-for="page in visiblePageNumbers"
                  :key="page"
                  type="button"
                  :class="[
                    'w-9 h-9 rounded-lg font-label-md text-xs transition-colors cursor-pointer',
                    currentPage === page
                      ? 'bg-primary text-white font-bold shadow-sm'
                      : 'bg-white hover:bg-slate-100 text-slate-700 border border-slate-200',
                  ]"
                  @click="currentPage = page"
                >
                  {{ page }}
                </button>
                <button
                  type="button"
                  class="p-2 rounded-lg bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 disabled:opacity-40 cursor-pointer disabled:cursor-not-allowed"
                  :disabled="currentPage >= totalPages"
                  aria-label="Página siguiente"
                  @click="currentPage = Math.min(totalPages, currentPage + 1)"
                >
                  <span class="material-symbols-outlined text-base">chevron_right</span>
                </button>
                <span class="ml-3 font-body-sm text-xs text-slate-500 font-medium">
                  Página {{ currentPage }} de {{ totalPages }} (Mostrando {{ paginatedBooks.length }} de {{ filteredBooks.length }} ejemplares)
                </span>
              </div>
            </div>
          </div>
        </section>

        <!-- Modal: Ficha Técnica y Control de Ejemplar -->
        <div
          v-if="showFichaModal && activeBook"
          class="fixed inset-0 z-50 bg-[#001838]/70 backdrop-blur-sm flex items-center justify-center p-4 transition-all"
          role="dialog"
          aria-modal="true"
          aria-labelledby="fichaModalTitle"
          @click.self="closeFichaModal"
        >
          <div class="bg-white max-w-2xl w-full rounded-2xl shadow-2xl border border-slate-200 flex flex-col overflow-hidden max-h-[90vh]">
            <div class="bg-[#002351] text-white px-6 py-4 flex items-center justify-between border-b border-[#C5A059]/40">
              <div class="flex items-center gap-2.5">
                <span class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-tecnm-gold">
                  <span class="material-symbols-outlined text-lg">menu_book</span>
                </span>
                <h3 id="fichaModalTitle" class="font-headline-sm !text-sm font-bold tracking-wide text-white">
                  Ficha Técnica y Control de Ejemplar
                </h3>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
                title="Cerrar Ficha"
                aria-label="Cerrar Ficha"
                @click="closeFichaModal"
              >
                <span class="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <div class="p-6 overflow-y-auto flex flex-col gap-5">
              <div class="flex flex-col sm:flex-row items-start sm:items-center gap-4 p-4 rounded-xl bg-slate-50 border border-slate-200">
                <div class="w-20 h-28 rounded-r-md rounded-l-[2px] bg-gradient-to-br from-[#002351] to-[#12396e] text-white p-2 flex flex-col justify-between shadow border-l-4 border-l-[#C5A059] shrink-0">
                  <span class="font-citation-code text-[8px] font-bold text-tecnm-gold">
                    {{ activeBook.code }}
                  </span>
                  <p class="font-headline-sm text-[10px] leading-tight font-extrabold gold-foil-text text-center">
                    {{ activeBook.shortTitle }}
                  </p>
                  <span class="text-[7px] text-[#c7d9fb] text-center font-citation-code">ITSM</span>
                </div>
                <div class="flex flex-col min-w-0 flex-1">
                  <div class="flex items-center flex-wrap gap-2 mb-1">
                    <span class="px-2 py-0.5 rounded text-[11px] font-bold bg-primary text-white font-citation-code">
                      Folio: {{ activeBook.folio }}
                    </span>
                    <span
                      :class="[
                        'px-2.5 py-0.5 rounded-full text-xs font-bold border flex items-center gap-1.5',
                        STATUS_META[activeBook.status].statusClass,
                      ]"
                    >
                      <span :class="['w-2 h-2 rounded-full', STATUS_META[activeBook.status].dotClass]"></span>
                      <span>{{ STATUS_META[activeBook.status].label }}</span>
                    </span>
                  </div>
                  <h4 class="font-headline-sm text-base text-primary font-bold leading-snug">
                    {{ activeBook.title }}
                  </h4>
                  <p class="font-body-md text-xs !text-slate-600 mt-1">{{ activeBook.author }}</p>
                  <p class="font-citation-code text-xs !text-slate-500 mt-0.5">{{ activeBook.note }}</p>
                </div>
              </div>

              <div class="inv-grid-3">
                <div class="bg-slate-50 p-3 rounded-xl border border-slate-200">
                  <span class="text-slate-400 font-medium text-[10.5px] uppercase tracking-wider block">
                    Código Dewey:
                  </span>
                  <span class="font-citation-code font-bold text-primary text-xs mt-1 block">
                    {{ activeBook.dewey }}
                  </span>
                </div>
                <div class="bg-slate-50 p-3 rounded-xl border border-slate-200">
                  <span class="text-slate-400 font-medium text-[10.5px] uppercase tracking-wider block">
                    Clave Cutter:
                  </span>
                  <span class="font-citation-code font-bold text-slate-800 text-xs mt-1 block">
                    {{ activeBook.cutter }}
                  </span>
                </div>
                <div class="bg-slate-50 p-3 rounded-xl border border-slate-200">
                  <span class="text-slate-400 font-medium text-[10.5px] uppercase tracking-wider block">
                    Estante Físico:
                  </span>
                  <span class="font-citation-code font-bold text-primary text-xs mt-1 flex items-center gap-1">
                    <span class="material-symbols-outlined text-xs text-tecnm-gold">shelves</span>
                    {{ activeBook.shelf }}
                  </span>
                </div>
              </div>

              <div class="p-3 rounded-xl bg-amber-50/70 border border-amber-200 text-xs text-slate-700 leading-relaxed">
                <p class="font-bold !text-slate-900 mb-1 flex items-center gap-1">
                  <span class="material-symbols-outlined text-sm text-tecnm-gold">sticky_note_2</span>
                  Nota Interna de Catalogación ITSM:
                </p>
                <span>{{ activeBook.recommendation }}</span>
              </div>

              <div class="flex flex-col gap-2 pt-1">
                <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider">
                  Acciones del Ejemplar:
                </span>
                <div class="inv-grid-2">
                  <button
                    type="button"
                    class="h-11 px-4 bg-primary hover:bg-[#184580] text-white font-label-sm text-xs font-bold rounded-xl flex items-center justify-center gap-2 transition-colors shadow-md hover:shadow-lg active:scale-[0.99]"
                    @click="openCambiarEstadoModal"
                  >
                    <span class="material-symbols-outlined text-lg text-tecnm-gold-light">published_with_changes</span>
                    <span>Cambiar Estado</span>
                  </button>
                  <button
                    type="button"
                    class="h-11 px-4 bg-white hover:bg-slate-50 text-primary border-2 border-primary/25 hover:border-primary font-label-sm text-xs font-bold rounded-xl flex items-center justify-center gap-2 transition-all shadow-sm active:scale-[0.99]"
                    @click="openEditarFichaModal"
                  >
                    <span class="material-symbols-outlined text-lg text-primary">edit_square</span>
                    <span>Editar Ficha</span>
                  </button>
                </div>
              </div>
            </div>

            <div class="bg-slate-50 px-6 py-3 border-t border-slate-200 flex justify-end">
              <button
                type="button"
                class="px-5 py-2 bg-slate-200 hover:bg-slate-300 text-slate-800 font-label-sm text-xs font-bold rounded-xl transition-colors"
                @click="closeFichaModal"
              >
                Cerrar Ficha
              </button>
            </div>
          </div>
        </div>

        <!-- Modal 1: Editar Ficha Técnica -->
        <div
          v-if="showEditarFichaModal"
          class="fixed inset-0 z-50 bg-[#001838]/70 backdrop-blur-sm flex items-center justify-center p-4 transition-all"
          role="dialog"
          aria-modal="true"
          aria-labelledby="editarFichaTitle"
          @click.self="closeEditarFichaModal"
        >
          <div class="bg-white max-w-2xl w-full rounded-2xl shadow-2xl border border-slate-200 flex flex-col overflow-hidden max-h-[92vh]">
            <div class="bg-[#002351] text-white px-6 py-4 flex items-center justify-between border-b border-[#C5A059]/40">
              <div class="flex items-center gap-2.5">
                <span class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-tecnm-gold">
                  <span class="material-symbols-outlined text-lg">edit_note</span>
                </span>
                <div>
                  <h3 id="editarFichaTitle" class="font-headline-sm !text-sm font-bold tracking-wide text-white">
                    Editar Ficha Técnica
                  </h3>
                  <p class="font-label-sm text-[11px] !text-[#acc7ff]">
                    Actualización de información bibliográfica y catalogación ITSM
                  </p>
                </div>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
                title="Cerrar"
                aria-label="Cerrar"
                @click="closeEditarFichaModal"
              >
                <span class="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <form class="p-6 overflow-y-auto flex flex-col gap-4 text-xs" @submit.prevent="saveFichaEdits">
              <div class="inv-grid-2">
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="editFolio">
                    Folio / Número de Inventario:
                  </label>
                  <input
                    id="editFolio"
                    v-model="editForm.folio"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-slate-100 text-slate-600 !rounded-lg border border-slate-200 font-citation-code font-bold cursor-not-allowed !text-xs"
                    readonly
                    type="text"
                  />
                </div>
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="editStatus">Estatus Actual:</label>
                  <select
                    id="editStatus"
                    v-model="editForm.status"
                    class="inventory-select w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-semibold focus:ring-2 focus:ring-primary focus:border-primary !text-xs cursor-pointer"
                  >
                    <option value="disponible">Disponible</option>
                    <option value="prestado">Prestado</option>
                    <option value="reparacion">En reparación</option>
                    <option value="baja">En proceso de baja</option>
                    <option value="catalogo">En catálogo</option>
                  </select>
                </div>
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-1" for="editTitle">Título de la Obra:</label>
                <input
                  id="editTitle"
                  v-model="editForm.title"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  required
                  type="text"
                />
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-1" for="editAuthor">Autor(es):</label>
                <input
                  id="editAuthor"
                  v-model="editForm.author"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  required
                  type="text"
                />
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-1" for="editNote">
                  Nota / Volumen / Edición / Editorial:
                </label>
                <input
                  id="editNote"
                  v-model="editForm.note"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  required
                  type="text"
                />
              </div>

              <div class="inv-grid-3">
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="editDewey">Clasificación Dewey:</label>
                  <input
                    id="editDewey"
                    v-model="editForm.dewey"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    required
                    type="text"
                  />
                </div>
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="editCutter">Clave Cutter-Sanborn:</label>
                  <input
                    id="editCutter"
                    v-model="editForm.cutter"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    required
                    type="text"
                  />
                </div>
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="editShelf">Estante Físico:</label>
                  <input
                    id="editShelf"
                    v-model="editForm.shelf"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    required
                    type="text"
                  />
                </div>
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-1" for="editRecommendation">
                  Nota Interna de Catalogación:
                </label>
                <textarea
                  id="editRecommendation"
                  v-model="editForm.recommendation"
                  class="inventory-input w-full !p-2.5 bg-white text-slate-800 !rounded-lg border border-slate-300 font-normal focus:ring-2 focus:ring-primary focus:border-primary !text-xs leading-relaxed"
                  rows="2"
                ></textarea>
              </div>

              <div class="pt-3 border-t border-slate-200 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold transition-colors"
                  :disabled="isSubmitting"
                  @click="closeEditarFichaModal"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  class="px-6 py-2.5 rounded-xl bg-primary hover:bg-[#184580] text-white font-bold transition-all shadow-md flex items-center gap-1.5 active:scale-95 disabled:opacity-60"
                  :disabled="isSubmitting"
                >
                  <span class="material-symbols-outlined text-sm text-tecnm-gold-light">save</span>
                  <span>Guardar Cambios</span>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Modal 2: Cambiar Estado Directo -->
        <div
          v-if="showCambiarEstadoModal && activeBook"
          class="fixed inset-0 z-50 bg-[#001838]/70 backdrop-blur-sm flex items-center justify-center p-4 transition-all"
          role="dialog"
          aria-modal="true"
          aria-labelledby="cambiarEstadoTitle"
          @click.self="closeCambiarEstadoModal"
        >
          <div class="bg-white max-w-md w-full rounded-2xl shadow-2xl border border-slate-200 flex flex-col overflow-hidden">
            <div class="bg-[#002351] text-white px-6 py-4 flex items-center justify-between border-b border-[#C5A059]/40">
              <div class="flex items-center gap-2.5">
                <span class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-tecnm-gold">
                  <span class="material-symbols-outlined text-lg">published_with_changes</span>
                </span>
                <div>
                  <h3 id="cambiarEstadoTitle" class="font-headline-sm !text-sm font-bold tracking-wide text-white">
                    Cambiar Estado del Ejemplar
                  </h3>
                  <p class="font-label-sm text-[11px] !text-[#acc7ff]">
                    Actualización directa del inventario TecNM
                  </p>
                </div>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
                title="Cerrar"
                aria-label="Cerrar"
                @click="closeCambiarEstadoModal"
              >
                <span class="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <div class="p-6 flex flex-col gap-4 text-xs">
              <div class="p-3 bg-slate-50 rounded-xl border border-slate-200">
                <span class="text-slate-500 font-medium block">Ejemplar seleccionado:</span>
                <p class="font-bold !text-primary text-sm mt-0.5">{{ activeBook.title }}</p>
                <span class="font-citation-code text-[11px] text-slate-500 font-semibold">
                  Folio: {{ activeBook.folio }}
                </span>
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-2" for="ceSelectStatus">
                  Selecciona el nuevo estado administrativo:
                </label>
                <div class="relative">
                  <select
                    id="ceSelectStatus"
                    v-model="directStatusSelection"
                    class="inventory-select w-full !h-11 !min-h-0 !pl-4 !pr-10 !py-0 bg-white text-slate-800 !text-xs font-semibold !rounded-xl border-2 border-primary/20 focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary cursor-pointer appearance-none shadow-sm"
                  >
                    <option value="disponible">🟢 Disponible (Para consulta y préstamo)</option>
                    <option value="prestado">🔵 Prestado (En circulación activa)</option>
                    <option value="reparacion">🟡 En reparación (Taller de encuadernación)</option>
                    <option value="baja">🔴 En proceso de baja (Descarte definitivo)</option>
                    <option value="catalogo">🟣 En catálogo (Revisión técnica)</option>
                  </select>
                  <div class="absolute inset-y-0 right-3 flex items-center pointer-events-none text-primary">
                    <span class="material-symbols-outlined text-lg">arrow_drop_down</span>
                  </div>
                </div>
              </div>

              <p class="!text-slate-500 text-[11px] leading-relaxed bg-blue-50/70 p-3 rounded-xl border border-blue-100 flex items-start gap-2">
                <span class="material-symbols-outlined text-base text-primary shrink-0">info</span>
                <span>El cambio surtirá efecto de inmediato en las métricas del sistema y en la tarjeta física del acervo.</span>
              </p>

              <div class="pt-3 border-t border-slate-200 flex items-center justify-end gap-2.5">
                <button
                  type="button"
                  class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold transition-colors"
                  :disabled="isSubmitting"
                  @click="closeCambiarEstadoModal"
                >
                  Cancelar
                </button>
                <button
                  type="button"
                  class="px-6 py-2.5 rounded-xl bg-primary hover:bg-[#184580] text-white font-bold transition-all shadow-md flex items-center gap-1.5 active:scale-95 disabled:opacity-60"
                  :disabled="isSubmitting"
                  @click="applyDirectStatusChange"
                >
                  <span class="material-symbols-outlined text-sm text-tecnm-gold-light">check</span>
                  <span>Aplicar Nuevo Estado</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal 3: Registro de Nuevo Ejemplar -->
        <div
          v-if="showNewBookModal"
          class="fixed inset-0 z-50 bg-[#001838]/60 backdrop-blur-sm flex items-center justify-center p-4"
          role="dialog"
          aria-modal="true"
          aria-labelledby="nuevoEjemplarTitle"
          @click.self="closeNewBookModal"
        >
          <div class="bg-white max-w-3xl w-full rounded-2xl shadow-2xl border border-slate-200 flex flex-col overflow-hidden max-h-[92vh]">
            <div class="bg-[#002351] text-white px-6 py-4 flex items-center justify-between border-b border-[#C5A059]/40">
              <div class="flex items-center gap-2.5">
                <span class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-tecnm-gold">
                  <span class="material-symbols-outlined text-lg">library_add</span>
                </span>
                <div>
                  <h3 id="nuevoEjemplarTitle" class="font-headline-sm !text-sm font-bold tracking-wide text-white">
                    Registrar Nuevo Ejemplar
                  </h3>
                  <p class="font-label-sm text-[11px] !text-[#acc7ff]">
                    Sistema Integral de Gestión Bibliotecaria • TecNM Campus Monclova
                  </p>
                </div>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
                title="Cerrar"
                aria-label="Cerrar"
                @click="closeNewBookModal"
              >
                <span class="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <div class="bg-gradient-to-r from-slate-50 via-blue-50/40 to-slate-50 border-b border-slate-200 px-6 py-3.5 flex flex-col sm:flex-row items-center justify-between gap-3">
              <div class="flex items-center gap-3">
                <div class="w-12 h-16 rounded-r bg-primary text-white p-1.5 flex flex-col justify-between shadow-sm border-l-2 border-l-[#C5A059] shrink-0 text-center">
                  <span class="font-citation-code text-[6.5px] font-bold text-tecnm-gold">ITSM</span>
                  <span class="material-symbols-outlined text-[14px] text-white/80 mx-auto">auto_stories</span>
                  <span class="text-[6px] text-[#c7d9fb] font-citation-code">2025</span>
                </div>
                <div class="flex flex-col">
                  <div class="flex items-center gap-1.5">
                    <span class="px-2 py-0.5 rounded text-[10.5px] font-bold bg-primary text-white font-citation-code">
                      Folio Asignado: {{ newBookForm.folio }}
                    </span>
                    <span class="px-2 py-0.5 rounded text-[10.5px] font-semibold bg-emerald-100 text-emerald-800 border border-emerald-200">
                      Nuevo Ingreso
                    </span>
                  </div>
                  <p class="text-xs !text-slate-600 mt-1 font-medium">
                    Etiqueta Topográfica Dewey:
                    <span class="font-citation-code font-bold text-primary">{{ newBookForm.dewey || '—' }}</span> •
                    Cutter:
                    <span class="font-citation-code font-bold text-slate-800">{{ newBookForm.cutter || '—' }}</span> •
                    Estante:
                    <span class="font-citation-code font-bold text-primary">{{ newBookForm.shelf || '—' }}</span>
                  </p>
                </div>
              </div>
              <span class="text-[11px] text-slate-500 bg-white px-2.5 py-1 rounded-lg border border-slate-200 shrink-0 font-medium">
                Asignación automática de inventario
              </span>
            </div>

            <form class="p-6 overflow-y-auto flex flex-col gap-4 text-xs" @submit.prevent="saveNewBook(false)">
              <div class="inv-grid-3">
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="newFolio">Folio / No. Inventario:</label>
                  <input
                    id="newFolio"
                    v-model="newBookForm.folio"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-slate-100 text-slate-600 !rounded-lg border border-slate-200 font-citation-code font-bold cursor-not-allowed !text-xs"
                    readonly
                    type="text"
                  />
                </div>
                <div class="sm:col-span-2">
                  <label class="block font-bold text-slate-700 mb-1" for="newTitle">
                    Título de la Obra: <span class="text-rose-600">*</span>
                  </label>
                  <input
                    id="newTitle"
                    v-model="newBookForm.title"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    placeholder="Ej. Cálculo de una Variable y Trascendentes Tempranas"
                    required
                    type="text"
                  />
                </div>
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-1" for="newAuthor">
                  Autor(es): <span class="text-rose-600">*</span>
                </label>
                <input
                  id="newAuthor"
                  v-model="newBookForm.author"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  placeholder="Ej. James Stewart, Daniel K. Clegg, Saleem Watson"
                  required
                  type="text"
                />
              </div>

              <div class="inv-grid-3">
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="newShelf">
                    Estante Físico: <span class="text-rose-600">*</span>
                  </label>
                  <input
                    id="newShelf"
                    v-model="newBookForm.shelf"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    placeholder="Ej. 1.1.1 (Pabellón.Fila.Nivel)"
                    required
                    type="text"
                  />
                </div>
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="newDewey">
                    Clasificación Dewey (CDD): <span class="text-rose-600">*</span>
                  </label>
                  <input
                    id="newDewey"
                    v-model="newBookForm.dewey"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    placeholder="Ej. QA303.2, TK454, TJ265"
                    required
                    type="text"
                  />
                </div>
                <div>
                  <label class="block font-bold text-slate-700 mb-1" for="newCutter">
                    Clave Cutter-Sanborn: <span class="text-rose-600">*</span>
                  </label>
                  <input
                    id="newCutter"
                    v-model="newBookForm.cutter"
                    class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                    placeholder="Ej. .S74 2023, .H39"
                    required
                    type="text"
                  />
                </div>
              </div>

              <div>
                <label class="block font-bold text-slate-700 mb-1" for="newNote">
                  Nota (Volumen, Edición y Detalles):
                </label>
                <input
                  id="newNote"
                  v-model="newBookForm.note"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  placeholder="Ej. 9na Edición • Volumen 1 (Cálculo Multivariable) • McGraw-Hill"
                  type="text"
                />
              </div>

              <div>
                <span class="block font-bold text-slate-700 mb-1.5">Estatus Inicial del Ejemplar:</span>
                <div class="inv-grid-4">
                  <label class="flex items-center gap-2 p-2 rounded-lg border border-emerald-200 bg-emerald-50/60 cursor-pointer hover:bg-emerald-100/50 transition-colors">
                    <input v-model="newBookForm.status" class="text-primary focus:ring-primary" name="nuevo_status" type="radio" value="disponible" />
                    <span class="font-bold text-[#15803D] text-[11px]">Disponible</span>
                  </label>
                  <label class="flex items-center gap-2 p-2 rounded-lg border border-purple-200 bg-purple-50/60 cursor-pointer hover:bg-purple-100/50 transition-colors">
                    <input v-model="newBookForm.status" class="text-primary focus:ring-primary" name="nuevo_status" type="radio" value="catalogo" />
                    <span class="font-bold text-[#7C3AED] text-[11px]">En catalogación</span>
                  </label>
                  <label class="flex items-center gap-2 p-2 rounded-lg border border-amber-200 bg-amber-50/60 cursor-pointer hover:bg-amber-100/50 transition-colors">
                    <input v-model="newBookForm.status" class="text-primary focus:ring-primary" name="nuevo_status" type="radio" value="reparacion" />
                    <span class="font-bold text-[#D97706] text-[11px]">En reparación</span>
                  </label>
                  <label class="flex items-center gap-2 p-2 rounded-lg border border-blue-200 bg-blue-50/60 cursor-pointer hover:bg-blue-100/50 transition-colors">
                    <input v-model="newBookForm.status" class="text-primary focus:ring-primary" name="nuevo_status" type="radio" value="prestado" />
                    <span class="font-bold text-[#1D4ED8] text-[11px]">Prestado</span>
                  </label>
                </div>
              </div>

              <div class="pt-3 border-t border-slate-200 flex items-center justify-end gap-2.5 mt-2">
                <button
                  type="button"
                  class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold transition-colors"
                  :disabled="isSubmitting"
                  @click="closeNewBookModal"
                >
                  Cancelar
                </button>
                <button
                  type="button"
                  class="px-4 py-2.5 rounded-xl border border-primary/30 text-primary hover:bg-primary/5 font-bold transition-colors disabled:opacity-60"
                  :disabled="isSubmitting"
                  @click="saveNewBook(true)"
                >
                  Guardar y añadir otro
                </button>
                <button
                  type="submit"
                  class="px-6 py-2.5 rounded-xl bg-primary hover:bg-[#184580] text-white font-bold transition-all shadow-md flex items-center gap-1.5 active:scale-95 disabled:opacity-60"
                  :disabled="isSubmitting"
                >
                  <span class="material-symbols-outlined text-sm text-tecnm-gold-light">check</span>
                  <span>Guardar</span>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Modal 4: Registrar Nuevo Estante -->
        <div
          v-if="showEstanteModal"
          class="fixed inset-0 z-50 bg-[#001838]/60 backdrop-blur-sm flex items-center justify-center p-4"
          role="dialog"
          aria-modal="true"
          aria-labelledby="estanteModalTitle"
          @click.self="closeEstanteModal"
        >
          <div class="bg-white max-w-lg w-full rounded-2xl shadow-2xl border border-slate-200 flex flex-col overflow-hidden max-h-[92vh]">
            <div class="bg-[#002351] text-white px-6 py-4 flex items-center justify-between border-b border-[#C5A059]/40">
              <div class="flex items-center gap-2.5">
                <span class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-tecnm-gold">
                  <span class="material-symbols-outlined text-lg">shelves</span>
                </span>
                <h3 id="estanteModalTitle" class="font-headline-sm !text-sm font-bold tracking-wide text-white">
                  Registrar Nuevo Estante
                </h3>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
                title="Cerrar"
                aria-label="Cerrar"
                @click="closeEstanteModal"
              >
                <span class="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <form class="p-6 flex flex-col gap-4 text-xs" @submit.prevent="saveNewEstante">
              <div>
                <label class="block font-bold text-slate-700 mb-1" for="estanteCodigo">
                  Código del Estante: <span class="text-rose-600">*</span>
                </label>
                <input
                  id="estanteCodigo"
                  v-model="estanteCodigo"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-bold focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  placeholder="Ej. 1.3.2"
                  required
                  type="text"
                />
              </div>

              <div class="pt-3 border-t border-slate-200 flex items-center justify-end gap-2.5 mt-2">
                <button
                  type="button"
                  class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold transition-colors"
                  :disabled="isSubmitting"
                  @click="closeEstanteModal"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  class="px-6 py-2.5 rounded-xl bg-primary hover:bg-[#184580] text-white font-bold transition-all shadow-md flex items-center gap-1.5 active:scale-95 disabled:opacity-60"
                  :disabled="isSubmitting"
                >
                  <span class="material-symbols-outlined text-sm text-tecnm-gold-light">check</span>
                  <span>Guardar Estante</span>
                </button>
              </div>
            </form>
          </div>
        </div>

        <!-- Modal 5: Registrar Nuevo Tema -->
        <div
          v-if="showTemasModal"
          class="fixed inset-0 z-50 bg-[#001838]/60 backdrop-blur-sm flex items-center justify-center p-4"
          role="dialog"
          aria-modal="true"
          aria-labelledby="temasModalTitle"
          @click.self="closeTemasModal"
        >
          <div class="bg-white max-w-lg w-full rounded-2xl shadow-2xl border border-slate-200 flex flex-col overflow-hidden max-h-[92vh]">
            <div class="bg-[#002351] text-white px-6 py-4 flex items-center justify-between border-b border-[#C5A059]/40">
              <div class="flex items-center gap-2.5">
                <span class="w-8 h-8 rounded-lg bg-white/10 flex items-center justify-center text-tecnm-gold">
                  <span class="material-symbols-outlined text-lg">label</span>
                </span>
                <h3 id="temasModalTitle" class="font-headline-sm !text-sm font-bold tracking-wide text-white">
                  Registrar Nuevo Tema
                </h3>
              </div>
              <button
                type="button"
                class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center transition-colors"
                title="Cerrar"
                aria-label="Cerrar"
                @click="closeTemasModal"
              >
                <span class="material-symbols-outlined text-lg">close</span>
              </button>
            </div>

            <form class="p-6 flex flex-col gap-4 text-xs" @submit.prevent="saveNewTema">
              <div>
                <label class="block font-bold text-slate-700 mb-1" for="temaNombre">
                  Nombre del Tema: <span class="text-rose-600">*</span>
                </label>
                <input
                  id="temaNombre"
                  v-model="temaNombre"
                  class="inventory-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-medium focus:ring-2 focus:ring-primary focus:border-primary !text-xs"
                  placeholder="Ej. Inteligencia Artificial, Siderurgia"
                  required
                  type="text"
                />
              </div>

              <div class="pt-3 border-t border-slate-200 flex items-center justify-end gap-2.5 mt-2">
                <button
                  type="button"
                  class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-100 font-bold transition-colors"
                  :disabled="isSubmitting"
                  @click="closeTemasModal"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  class="px-6 py-2.5 rounded-xl bg-primary hover:bg-[#184580] text-white font-bold transition-all shadow-md flex items-center gap-1.5 active:scale-95 disabled:opacity-60"
                  :disabled="isSubmitting"
                >
                  <span class="material-symbols-outlined text-sm text-tecnm-gold-light">check</span>
                  <span>Guardar Tema</span>
                </button>
              </div>
            </form>
          </div>
        </div>
      </main>
</template>

<style scoped>
.inventory-select {
  padding-left: 0.875rem !important;
  padding-right: 2.5rem !important;
  background-position: right 0.75rem center !important;
}

/* Isolated grids to avoid collision with global.css .grid */
.inventory-metrics-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}

.inventory-metric-last {
  grid-column: span 2 / span 2;
}

@media (min-width: 640px) {
  .inventory-metrics-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .inventory-metric-last {
    grid-column: span 1 / span 1;
  }
}

@media (min-width: 1024px) {
  .inventory-metrics-grid {
    grid-template-columns: 1.25fr 1fr 1fr 1fr 1fr;
  }
}

.inventory-actions-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 0.75rem;
}

@media (min-width: 768px) {
  .inventory-actions-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

.inventory-books-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1.25rem;
}

@media (min-width: 640px) {
  .inventory-books-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1024px) {
  .inventory-books-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (min-width: 1280px) {
  .inventory-books-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

.inventory-books-list {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1rem;
}

.inv-grid-2,
.inv-grid-3 {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 0.75rem;
}

.inv-grid-4 {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 0.5rem;
}

@media (min-width: 640px) {
  .inv-grid-2 {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .inv-grid-3 {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .inv-grid-4 {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

/* 3D Book Jacket Perspective & Realistic Physics */
.book-stage {
  perspective: 700px;
}

.book-cover-3d {
  transform-style: preserve-3d;
  transition: transform 0.35s cubic-bezier(0.2, 0.8, 0.2, 1), box-shadow 0.35s cubic-bezier(0.2, 0.8, 0.2, 1);
  transform: rotateY(-6deg) rotateX(2deg);
}

.book-card:hover .book-cover-3d {
  transform: rotateY(-14deg) rotateX(3deg) translateY(-5px) scale(1.02);
  box-shadow: 14px 18px 28px -6px rgba(0, 35, 81, 0.4), 0 0 16px -2px rgba(197, 160, 89, 0.3);
}

.book-spine-lighting {
  background: linear-gradient(
    90deg,
    rgba(255, 255, 255, 0.25) 0%,
    rgba(255, 255, 255, 0.05) 3%,
    rgba(0, 0, 0, 0.4) 6%,
    transparent 14%
  );
}

.gold-foil-text {
  background: linear-gradient(135deg, #fff3d6 0%, #d8b168 45%, #fbf0d9 70%, #9b752a 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

@media (prefers-reduced-motion: reduce) {
  .book-cover-3d,
  .book-card:hover .book-cover-3d {
    transition: none;
    transform: none;
  }
}
</style>
