<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { http } from '../../../shared/api/http'

interface BookItem {
  id: number
  title: string
  note?: string
  author?: string
  folio: string
  dewey: string
  cutter: string
  statusId: number
  statusName: string
  shelfId: number
  shelfName: string
  availableText: string
  availabilityPercent: number
  coverGradient?: string
  accentColor?: string
}

interface Metrics {
  totalBooks: number
  availableCount: number
  borrowedCount: number
  repairCount: number
  discardCount: number
  catalogCount: number
}

// Datos iniciales de contingencia basados en acervo universitario ITSM
const initialSeedBooks: BookItem[] = [
  {
    id: 1,
    title: 'Cálculo de Trascendentes Tempranas (Edición Estudiantil ITSM)',
    author: 'James Stewart • Cengage Learning',
    note: '8va Edición • Volumen 1',
    folio: 'FOL-TECNM-001',
    dewey: 'QA303.2',
    cutter: '.S74 2023',
    statusId: 1,
    statusName: 'Disponible',
    shelfId: 1,
    shelfName: 'Estante 1.1.1 (Ciencias Básicas)',
    availableText: '6 de 8 copias libres',
    availabilityPercent: 75,
    coverGradient: 'from-[#0c264d] via-[#001f47] to-[#04142d]',
    accentColor: '#C5A059'
  },
  {
    id: 2,
    title: 'Mecatrónica: Sistemas de Control Electrónico en la Industria',
    author: 'William Bolton • Alfaomega',
    note: '6ta Edición',
    folio: 'FOL-TECNM-002',
    dewey: 'TJ223',
    cutter: '.B65 2023',
    statusId: 2,
    statusName: 'Prestado',
    shelfId: 2,
    shelfName: 'Estante 9.2.3 (Mecatrónica)',
    availableText: 'En préstamo (1 ejemplar)',
    availabilityPercent: 25,
    coverGradient: 'from-[#003b35] via-[#042421] to-[#011413]',
    accentColor: '#6bd8cb'
  },
  {
    id: 3,
    title: 'Introducción a la Metalurgia Física y Procesos Siderúrgicos',
    author: 'Sidney H. Avner • Revisión ITSM',
    note: '2da Edición Revisada',
    folio: 'FOL-TECNM-003',
    dewey: 'TN665',
    cutter: '.A86 2022',
    statusId: 1,
    statusName: 'Disponible',
    shelfId: 3,
    shelfName: 'Estante 2.1.4 (Siderurgia y Metalurgia)',
    availableText: '3 de 4 copias libres',
    availabilityPercent: 75,
    coverGradient: 'from-[#3b1900] via-[#241100] to-[#120800]',
    accentColor: '#e6aa3e'
  },
  {
    id: 4,
    title: 'Estructuras de Datos y Análisis de Algoritmos en Python',
    author: 'Mark Allen Weiss • Pearson Educación',
    note: '4ta Edición 2024',
    folio: 'FOL-TECNM-004',
    dewey: 'QA76.73',
    cutter: '.W45 2024',
    statusId: 5,
    statusName: 'En catálogo',
    shelfId: 4,
    shelfName: 'Estante 5.3.2 (Sistemas y Computación)',
    availableText: 'En revisión de catalogación',
    availabilityPercent: 100,
    coverGradient: 'from-[#121e3d] via-[#091326] to-[#040812]',
    accentColor: '#a8c3f8'
  },
  {
    id: 5,
    title: 'Análisis de Circuitos en Ingeniería Eléctrica y Electrónica',
    author: 'William H. Hayt • Jack E. Kemmerly',
    note: '9na Edición',
    folio: 'FOL-TECNM-005',
    dewey: 'TK454',
    cutter: '.H39 2023',
    statusId: 3,
    statusName: 'En reparación',
    shelfId: 5,
    shelfName: 'Estante 3.1.2 (Electrónica)',
    availableText: 'En taller de encuadernación',
    availabilityPercent: 40,
    coverGradient: 'from-[#101b3b] via-[#091024] to-[#02050f]',
    accentColor: '#f5d99b'
  },
  {
    id: 6,
    title: 'Termodinámica Técnica para Ingeniería y Procesos Industriales',
    author: 'Yunus A. Çengel • Michael A. Boles',
    note: '9na Edición',
    folio: 'FOL-TECNM-006',
    dewey: 'TJ265',
    cutter: '.C46 2022',
    statusId: 4,
    statusName: 'En proceso de baja',
    shelfId: 6,
    shelfName: 'Estante 7.2.1 (Depósito de Descarte)',
    availableText: '0 disponibles (Baja definitiva)',
    availabilityPercent: 0,
    coverGradient: 'from-[#421b00] via-[#240e00] to-[#120700]',
    accentColor: '#ffd387'
  },
  {
    id: 7,
    title: 'Física Universitaria con Física Moderna (Vol. 1 y 2)',
    author: 'Hugh D. Young • Roger A. Freedman',
    note: '14va Edición',
    folio: 'FOL-TECNM-007',
    dewey: 'QC21.3',
    cutter: '.Y68 2023',
    statusId: 1,
    statusName: 'Disponible',
    shelfId: 1,
    shelfName: 'Estante 1.2.4 (Física y Química)',
    availableText: '8 de 10 copias libres',
    availabilityPercent: 80,
    coverGradient: 'from-[#021f47] via-[#01142e] to-[#000a17]',
    accentColor: '#d6e3ff'
  },
  {
    id: 8,
    title: 'Evaluación de Proyectos de Inversión y Planta Industrial',
    author: 'Gabriel Baca Urbina • McGraw-Hill',
    note: '7ma Edición',
    folio: 'FOL-TECNM-008',
    dewey: 'HD69.P75',
    cutter: '.B33 2023',
    statusId: 1,
    statusName: 'Disponible',
    shelfId: 7,
    shelfName: 'Estante 4.1.3 (Gestión Empresarial)',
    availableText: '3 de 4 copias libres',
    availabilityPercent: 75,
    coverGradient: 'from-[#3b2a05] via-[#241a02] to-[#120d00]',
    accentColor: '#f5d99b'
  }
]

// Estado reactivo
const books = ref<BookItem[]>([...initialSeedBooks])
const selectedBook = ref<BookItem>(initialSeedBooks[0])
const searchKeyword = ref('')
const searchField = ref('all')
const selectedStatus = ref('all')
const sortBy = ref('dewey')
const layoutMode = ref<'grid' | 'list'>('grid')
const isLoading = ref(false)

const metrics = ref<Metrics>({
  totalBooks: 5240,
  availableCount: 4,
  borrowedCount: 1,
  repairCount: 1,
  discardCount: 1,
  catalogCount: 1
})

// Modales
const showActionModal = ref(false)
const showNewBookModal = ref(false)
const modalActionTitle = ref('Acción Administrativa ITSM')
const modalActionMessage = ref('')
const modalTicketCode = ref('')
const modalIcon = ref('admin_panel_settings')
const selectedNewStatus = ref<number>(1)

const newBook = ref({
  title: '',
  author: '',
  note: '1ra Edición',
  folio: '',
  dewey: '005.1',
  cutter: '.T42 2026',
  statusId: 1,
  shelfId: 1
})

// Mapeo visual de estados
const statusConfig: Record<number, { label: string; badgeClass: string; dotClass: string }> = {
  1: { label: 'Disponible', badgeClass: 'bg-[#D1FAE5] text-[#15803D] border-[#15803D]/40', dotClass: 'bg-[#15803D]' },
  2: { label: 'Prestado', badgeClass: 'bg-[#DBEAFE] text-[#1D4ED8] border-[#1D4ED8]/40', dotClass: 'bg-[#1D4ED8]' },
  3: { label: 'En reparación', badgeClass: 'bg-[#FEF3C7] text-[#D97706] border-[#D97706]/40', dotClass: 'bg-[#D97706]' },
  4: { label: 'En proceso de baja', badgeClass: 'bg-[#FEE2E2] text-[#DC2626] border-[#DC2626]/40', dotClass: 'bg-[#DC2626]' },
  5: { label: 'En catálogo', badgeClass: 'bg-[#EDE9FE] text-[#7C3AED] border-[#7C3AED]/40', dotClass: 'bg-[#7C3AED]' }
}

const getStatusBadge = (statusId: number) => {
  return statusConfig[statusId] || { label: 'Desconocido', badgeClass: 'bg-slate-100 text-slate-700 border-slate-300', dotClass: 'bg-slate-400' }
}

// Filtro en cliente
const filteredBooks = computed(() => {
  let list = [...books.value]

  if (selectedStatus.value !== 'all') {
    const statusMap: Record<string, number> = {
      disponible: 1,
      prestado: 2,
      reparacion: 3,
      baja: 4,
      catalogo: 5
    }
    const targetId = statusMap[selectedStatus.value]
    if (targetId) {
      list = list.filter((b) => b.statusId === targetId)
    }
  }

  if (searchKeyword.value.trim()) {
    const term = searchKeyword.value.trim().toLowerCase()
    list = list.filter((b) => {
      if (searchField.value === 'title') return b.title.toLowerCase().includes(term)
      if (searchField.value === 'author') return (b.author || '').toLowerCase().includes(term)
      if (searchField.value === 'dewey') return b.dewey.toLowerCase().includes(term)
      if (searchField.value === 'barcode') return b.folio.toLowerCase().includes(term)
      return (
        b.title.toLowerCase().includes(term) ||
        (b.author || '').toLowerCase().includes(term) ||
        b.dewey.toLowerCase().includes(term) ||
        b.folio.toLowerCase().includes(term) ||
        b.shelfName.toLowerCase().includes(term)
      )
    })
  }

  if (sortBy.value === 'status') {
    list.sort((a, b) => a.statusId - b.statusId)
  } else if (sortBy.value === 'barcode') {
    list.sort((a, b) => a.folio.localeCompare(b.folio))
  } else {
    list.sort((a, b) => a.dewey.localeCompare(b.dewey))
  }

  return list
})

// Peticiones al backend .NET 10
const fetchBooks = async () => {
  try {
    isLoading.value = true
    const response = await http.get('/books', {
      params: {
        search: searchKeyword.value,
        field: searchField.value,
        status: selectedStatus.value,
        sortBy: sortBy.value
      }
    })
    if (response.data && Array.isArray(response.data) && response.data.length > 0) {
      books.value = response.data.map((item: any, idx: number) => ({
        ...item,
        coverGradient: initialSeedBooks[idx % initialSeedBooks.length].coverGradient,
        accentColor: initialSeedBooks[idx % initialSeedBooks.length].accentColor
      }))
      if (books.value.length > 0) {
        selectedBook.value = books.value[0]
      }
    }
  } catch (error) {
    console.warn('Usando catálogo local:', error)
  } finally {
    isLoading.value = false
  }
}

const fetchMetrics = async () => {
  try {
    const response = await http.get('/books/metrics')
    if (response.data) {
      metrics.value = {
        totalBooks: response.data.totalBooks || 5240,
        availableCount: response.data.availableCount || 4,
        borrowedCount: response.data.borrowedCount || 1,
        repairCount: response.data.repairCount || 1,
        discardCount: response.data.discardCount || 1,
        catalogCount: response.data.catalogCount || 1
      }
    }
  } catch (err) {
    // Mantener estado
  }
}

onMounted(() => {
  fetchBooks()
  fetchMetrics()
})

const selectBook = (book: BookItem) => {
  selectedBook.value = book
}

const setStatusFilter = (status: string) => {
  selectedStatus.value = status
}

const openActionModal = (type: string) => {
  modalTicketCode.value = `SIGB-MCV-${Math.floor(1000 + Math.random() * 9000)}`
  selectedNewStatus.value = selectedBook.value.statusId

  if (type === 'cambiar_estado') {
    modalActionTitle.value = 'Actualizar Estado Administrativo'
    modalActionMessage.value = `Seleccione el nuevo estatus para "${selectedBook.value.title}" (${selectedBook.value.folio}).`
    modalIcon.value = 'published_with_changes'
  } else if (type === 'prestamo_devolucion') {
    modalActionTitle.value = 'Registro de Circulación / Préstamo'
    modalActionMessage.value = `Registrar préstamo o devolución del ejemplar ${selectedBook.value.folio}.`
    modalIcon.value = 'swap_horizontal_circle'
    selectedNewStatus.value = selectedBook.value.statusId === 1 ? 2 : 1
  } else if (type === 'reportar_reparacion') {
    modalActionTitle.value = 'Orden de Trabajo • Taller de Reparación'
    modalActionMessage.value = `Se enviará el ejemplar "${selectedBook.value.title}" a mantenimiento y encuadernación.`
    modalIcon.value = 'handyman'
    selectedNewStatus.value = 3
  } else {
    modalActionTitle.value = 'Edición Catalográfica MARC-21'
    modalActionMessage.value = `Ficha técnica de catalogación lista para modificar códigos Dewey y Cutter.`
    modalIcon.value = 'edit_square'
  }

  showActionModal.value = true
}

const applyStatusUpdate = async () => {
  try {
    await http.put(`/books/${selectedBook.value.id}/status`, {
      statusId: selectedNewStatus.value,
      note: 'Actualizado desde panel administrativo'
    })
  } catch (err) {
    // Modo local
  }
  selectedBook.value.statusId = selectedNewStatus.value
  selectedBook.value.statusName = statusConfig[selectedNewStatus.value]?.label || 'Actualizado'
  const target = books.value.find((b) => b.id === selectedBook.value.id)
  if (target) {
    target.statusId = selectedNewStatus.value
    target.statusName = selectedBook.value.statusName
  }
  showActionModal.value = false
}

const openNewBookModal = () => {
  newBook.value = {
    title: '',
    author: '',
    note: '1ra Edición',
    folio: `FOL-TECNM-00${books.value.length + 1}`,
    dewey: '005.1',
    cutter: '.T42 2026',
    statusId: 1,
    shelfId: 1
  }
  showNewBookModal.value = true
}

const saveNewBook = async () => {
  if (!newBook.value.title || !newBook.value.folio) return

  const item: BookItem = {
    id: books.value.length + 1,
    title: newBook.value.title,
    author: newBook.value.author,
    note: newBook.value.note,
    folio: newBook.value.folio,
    dewey: newBook.value.dewey,
    cutter: newBook.value.cutter,
    statusId: newBook.value.statusId,
    statusName: statusConfig[newBook.value.statusId]?.label || 'Disponible',
    shelfId: newBook.value.shelfId,
    shelfName: `Estante ${newBook.value.shelfId}.1 (Acervo General)`,
    availableText: 'Ejemplar en inventario',
    availabilityPercent: 100,
    coverGradient: 'from-[#002351] via-[#103060] to-[#04142d]',
    accentColor: '#C5A059'
  }

  try {
    await http.post('/books', {
      title: item.title,
      author: item.author,
      note: item.note,
      folio: item.folio,
      dewey: item.dewey,
      cutter: item.cutter,
      statusId: item.statusId,
      shelfId: item.shelfId
    })
  } catch (err) {
    console.warn('Registro local:', err)
  }

  books.value.unshift(item)
  selectedBook.value = item
  showNewBookModal.value = false
}
</script>

<template>
  <div class="min-h-screen bg-[#f5f7fc] text-[#0b1c30] antialiased selection:bg-[#C5A059]/30 font-['Inter',sans-serif] text-[15px]">
    
    <!-- ============================================================== -->
    <!-- HEADER INSTITUCIONAL MEJORADO (Espaciado, Ordenado y No Saturado) -->
    <!-- ============================================================== -->
    <header class="fixed top-0 w-full z-50 bg-[#001b3d] shadow-[0_4px_24px_rgba(0,18,48,0.35)] border-b border-white/10">
      <div class="w-full px-6 lg:px-12 py-3 flex items-center justify-between gap-6">
        
        <!-- Bloque Izquierdo: Logotipo Institucional + Nombre de Sistema -->
        <div class="flex items-center gap-4 shrink-0">
          <div class="flex items-center justify-center w-12 h-12 rounded-xl bg-white/10 border border-[#C5A059]/40 text-[#ecd49c] shadow-inner">
            <span class="material-symbols-outlined text-3xl">local_library</span>
          </div>
          <div class="flex flex-col justify-center">
            <div class="flex items-center gap-2">
              <span class="text-2xl font-extrabold text-white tracking-tight leading-none font-['Plus_Jakarta_Sans',sans-serif]">
                ITSM
              </span>
              <span class="px-2 py-0.5 rounded text-[11px] font-bold bg-[#C5A059] text-[#001b3d] tracking-wider uppercase">
                CAMPUS MONCLOVA
              </span>
            </div>
            <span class="text-xs text-[#eed394] font-medium tracking-wide mt-1">
              Biblioteca Central • Panel Administrativo
            </span>
          </div>
        </div>

        <!-- Bloque Centro: Navegación Limpia en una sola línea (Sin desbordes) -->
        <nav class="hidden xl:flex items-center gap-2">
          <a class="px-4 py-2 rounded-xl text-sm font-bold text-white bg-white/15 border border-white/20 shadow-sm flex items-center gap-2 whitespace-nowrap transition-colors" href="#">
            <span class="material-symbols-outlined text-lg">menu_book</span>
            <span>Control de Acervo</span>
          </a>
          <a class="px-4 py-2 rounded-xl text-sm font-semibold text-[#89a4dc] hover:text-white hover:bg-white/10 flex items-center gap-2 whitespace-nowrap transition-colors" href="#">
            <span class="material-symbols-outlined text-lg">swap_horiz</span>
            <span>Circulación & Préstamos</span>
          </a>
          <a class="px-4 py-2 rounded-xl text-sm font-semibold text-[#89a4dc] hover:text-white hover:bg-white/10 flex items-center gap-2 whitespace-nowrap transition-colors" href="#">
            <span class="material-symbols-outlined text-lg">edit_note</span>
            <span>Catalogación</span>
          </a>
          <a class="px-4 py-2 rounded-xl text-sm font-semibold text-[#89a4dc] hover:text-white hover:bg-white/10 flex items-center gap-2 whitespace-nowrap transition-colors" href="#">
            <span class="material-symbols-outlined text-lg">build</span>
            <span>Taller & Bajas</span>
          </a>
          <a class="px-4 py-2 rounded-xl text-sm font-semibold text-[#89a4dc] hover:text-white hover:bg-white/10 flex items-center gap-2 whitespace-nowrap transition-colors" href="#">
            <span class="material-symbols-outlined text-lg">bar_chart</span>
            <span>Reportes & Auditoría</span>
          </a>
        </nav>

        <!-- Bloque Derecho: Perfil del Bibliotecario (Ordenado y Legible) -->
        <div class="flex items-center gap-4 shrink-0">
          <div class="hidden md:flex flex-col text-right">
            <div class="flex items-center justify-end gap-2">
              <span class="text-sm text-white font-bold">Mtra. Carmen Valdés</span>
              <span class="px-2 py-0.5 rounded text-[10px] font-black bg-[#C5A059] text-[#001b3d] tracking-wider uppercase">
                ROL: ADMINISTRADOR
              </span>
            </div>
            <span class="text-xs text-[#f2dfbe] font-medium mt-0.5">carmen.valdes@monclova.tecnm.mx</span>
          </div>

          <div class="relative flex items-center justify-center w-11 h-11 rounded-full bg-[#1b396a] text-[#ecd49c] font-bold text-base ring-2 ring-[#C5A059] shadow-lg">
            <span>CV</span>
            <div class="absolute bottom-0 right-0 w-3 h-3 bg-emerald-400 rounded-full border-2 border-[#001b3d]" title="En línea"></div>
          </div>
        </div>
      </div>

      <!-- Subheader Institucional Separado -->
      <div class="bg-[#00142e] py-2 px-6 lg:px-12 border-t border-white/10 text-xs">
        <div class="max-w-[1440px] mx-auto flex items-center justify-between text-[#89a4dc]">
          <div class="flex items-center gap-2">
            <span class="font-bold text-[#C5A059] tracking-wider">INSTITUTO TECNOLÓGICO SUPERIOR DE MONCLOVA</span>
            <span class="text-white/30">•</span>
            <span class="text-white/80">Módulo de Administración y Gestión Bibliotecaria</span>
          </div>
          <div class="flex items-center gap-4">
            <!-- Indicador API .NET 10 integrado en el subheader para no saturar arriba -->
            <div class="inline-flex items-center gap-2 px-3 py-0.5 rounded-full bg-emerald-500/10 border border-emerald-400/30">
              <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
              <span class="text-emerald-200 font-semibold">API .NET 10: <strong class="text-white">Conectada</strong></span>
            </div>
            <span class="inline-flex items-center gap-1 text-[#f2dfbe] font-medium">
              <span class="material-symbols-outlined text-sm text-[#C5A059]">location_on</span> Monclova, Coahuila
            </span>
          </div>
        </div>
      </div>
    </header>

    <!-- ============================================================== -->
    <!-- CONTENIDO PRINCIPAL -->
    <!-- ============================================================== -->
    <main class="w-full pt-32">
      <!-- Sección Hero y Búsqueda -->
      <section class="relative w-full bg-gradient-to-b from-[#001838] via-[#00285a] to-[#0c3770] px-6 lg:px-12 pt-12 pb-20 text-white overflow-hidden shadow-xl">
        <div class="relative max-w-[1440px] mx-auto flex flex-col gap-8">
          
          <!-- Encabezado de Sección -->
          <div class="flex flex-col text-left max-w-3xl">
            <div class="flex items-center gap-2 mb-2">
              <span class="px-3 py-1 rounded-full text-xs font-bold bg-[#C5A059]/20 text-[#ecd49c] border border-[#C5A059]/40 tracking-wider flex items-center gap-1.5 shadow-sm">
                <span class="material-symbols-outlined text-base text-[#C5A059]">admin_panel_settings</span>
                SISTEMA INTEGRAL DE GESTIÓN BIBLIOTECARIA • ITSM
              </span>
              <span class="text-white/40">•</span>
              <span class="text-sm text-white/80">Módulo de Bibliotecarios</span>
            </div>
            <h1 class="text-4xl lg:text-5xl font-extrabold text-white tracking-tight leading-tight font-['Plus_Jakarta_Sans',sans-serif]">
              Biblioteca Central
            </h1>
            <p class="text-xl lg:text-2xl font-semibold text-[#ecd49c] tracking-wide mt-1">
              Instituto Tecnológico Superior de Monclova
            </p>
            <p class="text-base text-[#c3d5f5] max-w-2xl leading-relaxed mt-2">
              Panel Administrativo de Control. Gestione estados de disponibilidad, préstamos en mostrador, mantenimiento de volúmenes y fichas topográficas Dewey.
            </p>
          </div>

          <!-- Omnibox Search (Más amplio, cómodo y con fuentes legibles) -->
          <div class="bg-white/95 backdrop-blur-md p-4 rounded-2xl shadow-[0_20px_50px_rgba(0,20,50,0.35)] border border-white/40 text-[#0b1c30]">
            <form class="flex flex-col lg:flex-row items-stretch gap-3" @submit.prevent="fetchBooks">
              <!-- Selector de campo -->
              <div class="relative min-w-[240px]">
                <div class="absolute inset-y-0 left-4 flex items-center pointer-events-none text-[#002351]">
                  <span class="material-symbols-outlined text-2xl">manage_search</span>
                </div>
                <select
                  v-model="searchField"
                  class="w-full h-14 pl-12 pr-10 bg-[#eff4ff] text-[#002351] text-sm font-bold rounded-xl border border-[#002351]/15 focus:outline-none focus:ring-2 focus:ring-[#C5A059] cursor-pointer appearance-none shadow-inner"
                >
                  <option value="all">Todo el Catálogo ITSM</option>
                  <option value="title">Título de la Obra</option>
                  <option value="author">Autor</option>
                  <option value="subject">Tema / Especialidad</option>
                  <option value="dewey">Código Dewey / Clasificación</option>
                  <option value="barcode">Código de Barras / Folio</option>
                </select>
                <div class="absolute inset-y-0 right-4 flex items-center pointer-events-none text-[#002351]">
                  <span class="material-symbols-outlined text-xl">expand_more</span>
                </div>
              </div>

              <!-- Input principal de búsqueda -->
              <div class="relative flex-1 flex items-center">
                <span class="material-symbols-outlined absolute left-4 text-[#002351] text-2xl">search</span>
                <input
                  v-model="searchKeyword"
                  class="w-full h-14 pl-14 pr-12 bg-slate-50 text-[#0b1c30] text-base placeholder:text-slate-400 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#C5A059] focus:bg-white transition-all shadow-inner"
                  placeholder="Buscar por título, autor, tema, código Dewey o Folio..."
                  type="text"
                />
                <button
                  v-if="searchKeyword"
                  type="button"
                  class="absolute right-4 p-1.5 text-slate-400 hover:text-[#002351] rounded-full cursor-pointer"
                  @click="searchKeyword = ''; fetchBooks()"
                >
                  <span class="material-symbols-outlined text-xl">cancel</span>
                </button>
              </div>

              <!-- Botón Buscar -->
              <button
                type="submit"
                class="h-14 px-10 bg-gradient-to-r from-[#002351] to-[#184580] hover:from-[#001738] hover:to-[#002351] text-white text-base font-bold rounded-xl transition-all flex items-center justify-center gap-2.5 shadow-lg shadow-[#002351]/30 active:scale-95 border border-white/20 shrink-0 cursor-pointer"
              >
                <span class="material-symbols-outlined text-[#ecd49c] text-2xl">search</span>
                <span class="tracking-wide">Buscar</span>
              </button>
            </form>

            <!-- Filtros de Estado Oficiales -->
            <div class="mt-4 pt-3 border-t border-slate-200 flex items-center gap-2.5 overflow-x-auto pb-1 text-[#0b1c30]">
              <span class="text-xs text-slate-600 whitespace-nowrap pl-1 font-bold flex items-center gap-1.5">
                <span class="material-symbols-outlined text-base text-[#C5A059]">filter_alt</span> Estado del Ejemplar:
              </span>

              <button
                :class="[
                  'px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 cursor-pointer',
                  selectedStatus === 'all' ? 'bg-[#002351] text-white shadow-md ring-2 ring-[#002351]' : 'bg-slate-100 hover:bg-slate-200 text-slate-700'
                ]"
                @click="setStatusFilter('all')"
              >
                <span>Todos</span>
                <span class="px-2 py-0.5 rounded-full text-xs bg-white/20 font-extrabold">{{ books.length }}</span>
              </button>

              <button
                :class="[
                  'px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 cursor-pointer',
                  selectedStatus === 'disponible' ? 'ring-2 ring-offset-1 ring-[#15803D] shadow-md' : '',
                  'bg-[#D1FAE5] hover:bg-[#a7f3d0] text-[#15803D] border border-[#15803D]/40'
                ]"
                @click="setStatusFilter('disponible')"
              >
                <span class="w-2.5 h-2.5 rounded-full bg-[#15803D]"></span>
                <span>Disponible</span>
                <span class="px-2 py-0.5 rounded-full text-xs bg-[#15803D]/15 font-extrabold">
                  {{ books.filter((b) => b.statusId === 1).length }}
                </span>
              </button>

              <button
                :class="[
                  'px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 cursor-pointer',
                  selectedStatus === 'prestado' ? 'ring-2 ring-offset-1 ring-[#1D4ED8] shadow-md' : '',
                  'bg-[#DBEAFE] hover:bg-[#bfdbfe] text-[#1D4ED8] border border-[#1D4ED8]/40'
                ]"
                @click="setStatusFilter('prestado')"
              >
                <span class="w-2.5 h-2.5 rounded-full bg-[#1D4ED8]"></span>
                <span>Prestado</span>
                <span class="px-2 py-0.5 rounded-full text-xs bg-[#1D4ED8]/15 font-extrabold">
                  {{ books.filter((b) => b.statusId === 2).length }}
                </span>
              </button>

              <button
                :class="[
                  'px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 cursor-pointer',
                  selectedStatus === 'reparacion' ? 'ring-2 ring-offset-1 ring-[#D97706] shadow-md' : '',
                  'bg-[#FEF3C7] hover:bg-[#fde68a] text-[#D97706] border border-[#D97706]/40'
                ]"
                @click="setStatusFilter('reparacion')"
              >
                <span class="w-2.5 h-2.5 rounded-full bg-[#D97706]"></span>
                <span>En reparación</span>
                <span class="px-2 py-0.5 rounded-full text-xs bg-[#D97706]/15 font-extrabold">
                  {{ books.filter((b) => b.statusId === 3).length }}
                </span>
              </button>

              <button
                :class="[
                  'px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 cursor-pointer',
                  selectedStatus === 'baja' ? 'ring-2 ring-offset-1 ring-[#DC2626] shadow-md' : '',
                  'bg-[#FEE2E2] hover:bg-[#fecaca] text-[#DC2626] border border-[#DC2626]/40'
                ]"
                @click="setStatusFilter('baja')"
              >
                <span class="w-2.5 h-2.5 rounded-full bg-[#DC2626]"></span>
                <span>En proceso de baja</span>
                <span class="px-2 py-0.5 rounded-full text-xs bg-[#DC2626]/15 font-extrabold">
                  {{ books.filter((b) => b.statusId === 4).length }}
                </span>
              </button>

              <button
                :class="[
                  'px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 cursor-pointer',
                  selectedStatus === 'catalogo' ? 'ring-2 ring-offset-1 ring-[#7C3AED] shadow-md' : '',
                  'bg-[#EDE9FE] hover:bg-[#ddd6fe] text-[#7C3AED] border border-[#7C3AED]/40'
                ]"
                @click="setStatusFilter('catalogo')"
              >
                <span class="w-2.5 h-2.5 rounded-full bg-[#7C3AED]"></span>
                <span>En catálogo</span>
                <span class="px-2 py-0.5 rounded-full text-xs bg-[#7C3AED]/15 font-extrabold">
                  {{ books.filter((b) => b.statusId === 5).length }}
                </span>
              </button>
            </div>
          </div>
        </div>
      </section>

      <!-- Métricas con tarjetas más amplias y tipografía más grande -->
      <section class="w-full px-6 lg:px-12 -mt-10 z-20">
        <div class="max-w-[1440px] mx-auto grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
          <div class="bg-white p-5 rounded-2xl shadow-[0_8px_24px_rgba(0,35,81,0.08)] border border-slate-200 flex items-center gap-4">
            <div class="w-13 h-13 rounded-2xl bg-gradient-to-br from-[#002351] to-[#1b396a] text-[#ecd49c] flex items-center justify-center shrink-0 shadow-md">
              <span class="material-symbols-outlined text-2xl">menu_book</span>
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-2xl lg:text-3xl text-[#002351] font-black tracking-tight">{{ metrics.totalBooks.toLocaleString() }}</span>
              <span class="text-xs text-slate-500 font-semibold uppercase tracking-wider">Total Ejemplares</span>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl shadow-[0_8px_24px_rgba(0,35,81,0.08)] border border-blue-200 flex items-center gap-4">
            <div class="w-13 h-13 rounded-2xl bg-[#DBEAFE] text-[#1D4ED8] border border-[#1D4ED8]/30 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-2xl">sync_alt</span>
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-2xl lg:text-3xl text-[#1D4ED8] font-black tracking-tight">{{ metrics.borrowedCount }}</span>
              <span class="text-xs text-slate-500 font-semibold uppercase tracking-wider">En Circulación</span>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl shadow-[0_8px_24px_rgba(0,35,81,0.08)] border border-amber-200 flex items-center gap-4">
            <div class="w-13 h-13 rounded-2xl bg-[#FEF3C7] text-[#D97706] border border-[#D97706]/30 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-2xl">build_circle</span>
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-2xl lg:text-3xl text-[#D97706] font-black tracking-tight">{{ metrics.repairCount }}</span>
              <span class="text-xs text-slate-500 font-semibold uppercase tracking-wider">En Reparación</span>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl shadow-[0_8px_24px_rgba(0,35,81,0.08)] border border-rose-200 flex items-center gap-4">
            <div class="w-13 h-13 rounded-2xl bg-[#FEE2E2] text-[#DC2626] border border-[#DC2626]/30 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-2xl">delete_forever</span>
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-2xl lg:text-3xl text-[#DC2626] font-black tracking-tight">{{ metrics.discardCount }}</span>
              <span class="text-xs text-slate-500 font-semibold uppercase tracking-wider">En Proceso de Baja</span>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl shadow-[0_8px_24px_rgba(0,35,81,0.08)] border border-purple-200 flex items-center gap-4 col-span-2 sm:col-span-1">
            <div class="w-13 h-13 rounded-2xl bg-[#EDE9FE] text-[#7C3AED] border border-[#7C3AED]/30 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-2xl">auto_stories</span>
            </div>
            <div class="flex flex-col min-w-0">
              <span class="text-2xl lg:text-3xl text-[#7C3AED] font-black tracking-tight">{{ metrics.catalogCount }}</span>
              <span class="text-xs text-slate-500 font-semibold uppercase tracking-wider">En Catalogación</span>
            </div>
          </div>
        </div>
      </section>

      <!-- Catálogo y Panel Lateral -->
      <section class="w-full px-6 lg:px-12 py-10">
        <div class="max-w-[1440px] mx-auto flex flex-col gap-6">
          
          <!-- Toolbar -->
          <div class="bg-white p-5 rounded-2xl shadow-[0_2px_12px_rgba(0,35,81,0.04)] border border-slate-200 flex flex-col md:flex-row items-center justify-between gap-4">
            <div class="flex items-center gap-3 w-full md:w-auto">
              <span class="w-3 h-3 rounded-full bg-emerald-500 ring-4 ring-emerald-100"></span>
              <p class="text-base text-slate-700 font-medium">
                Mostrando <span class="font-bold text-[#002351] text-lg">{{ filteredBooks.length }}</span> obras registradas • <strong class="text-[#002351] font-bold">Tec Monclova</strong>
              </p>
            </div>

            <div class="flex items-center flex-wrap gap-3.5 w-full md:w-auto justify-end">
              <button
                class="px-5 py-2.5 bg-[#002351] hover:bg-[#184580] text-white rounded-xl text-sm font-bold flex items-center gap-2 shadow-md transition-colors cursor-pointer"
                @click="openNewBookModal"
              >
                <span class="material-symbols-outlined text-base">add</span>
                <span>Registrar Nuevo Ejemplar</span>
              </button>

              <div class="flex items-center gap-2">
                <label class="text-xs text-slate-500 font-bold uppercase whitespace-nowrap" for="sortSelect">Ordenar:</label>
                <select
                  id="sortSelect"
                  v-model="sortBy"
                  class="h-10 px-3 bg-slate-50 text-slate-800 text-sm font-medium rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#002351] cursor-pointer"
                  @change="fetchBooks"
                >
                  <option value="dewey">Clasificación Dewey Ascendente</option>
                  <option value="status">Estado Administrativo</option>
                  <option value="barcode">Número de Inventario / Folio</option>
                </select>
              </div>

              <!-- Switch Grid / List -->
              <div class="flex items-center bg-slate-100 rounded-xl p-1 border border-slate-200">
                <button
                  :class="['p-1.5 rounded-lg cursor-pointer', layoutMode === 'grid' ? 'bg-white text-[#002351] shadow-sm' : 'text-slate-500 hover:text-slate-800']"
                  title="Vista Cuadrícula"
                  @click="layoutMode = 'grid'"
                >
                  <span class="material-symbols-outlined text-xl leading-none">grid_view</span>
                </button>
                <button
                  :class="['p-1.5 rounded-lg cursor-pointer', layoutMode === 'list' ? 'bg-white text-[#002351] shadow-sm' : 'text-slate-500 hover:text-slate-800']"
                  title="Vista Detallada"
                  @click="layoutMode = 'list'"
                >
                  <span class="material-symbols-outlined text-xl leading-none">view_agenda</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Grid de Libros + Panel Lateral -->
          <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
            
            <!-- Contenedor de Libros -->
            <div :class="['lg:col-span-8 grid gap-6 transition-all', layoutMode === 'grid' ? 'grid-cols-1 md:grid-cols-2' : 'grid-cols-1']">
              <div
                v-for="book in filteredBooks"
                :key="book.id"
                :class="[
                  'book-card group relative bg-white rounded-2xl p-5 shadow-[0_4px_18px_rgba(0,35,81,0.06)] hover:shadow-[0_20px_35px_-8px_rgba(0,35,81,0.22)] border cursor-pointer flex flex-col justify-between overflow-hidden transition-all duration-300',
                  selectedBook?.id === book.id ? 'border-[#C5A059] ring-2 ring-[#C5A059]/50 shadow-xl' : 'border-slate-200 hover:border-[#C5A059]/60'
                ]"
                @click="selectBook(book)"
              >
                <!-- Badge de Estado Superior -->
                <div class="flex items-center justify-between mb-3.5">
                  <span :class="['px-3 py-1 rounded-full text-xs font-bold border flex items-center gap-2 shadow-sm', getStatusBadge(book.statusId).badgeClass]">
                    <span :class="['w-2 h-2 rounded-full', getStatusBadge(book.statusId).dotClass]"></span>
                    {{ getStatusBadge(book.statusId).label }}
                  </span>
                  <span class="text-xs font-bold text-[#002351] bg-slate-100 px-2.5 py-1 rounded-md font-mono border border-slate-200">
                    {{ book.folio }}
                  </span>
                </div>

                <!-- Portada 3D y Datos de la Obra -->
                <div class="flex gap-5 items-start">
                  <!-- Portada 3D -->
                  <div class="book-stage shrink-0">
                    <div
                      :class="[
                        'book-cover-3d relative w-32 h-44 rounded-r-lg rounded-l-[3px] shadow-[6px_8px_18px_rgba(0,25,60,0.35)] flex flex-col justify-between p-3 text-white border-l-4 border-l-[#C5A059] border-y border-r border-white/20 overflow-hidden bg-gradient-to-br',
                        book.coverGradient || 'from-[#0c264d] via-[#001f47] to-[#04142d]'
                      ]"
                    >
                      <div class="book-spine-lighting absolute inset-0 pointer-events-none z-20"></div>
                      <div class="relative z-10 flex justify-between items-start">
                        <span class="text-[9px] font-bold tracking-widest text-[#f5d99b] font-mono">ITSM • {{ book.id }}</span>
                        <span class="material-symbols-outlined text-[15px] text-[#eed394]">menu_book</span>
                      </div>
                      <div class="relative z-10 my-auto text-center">
                        <p class="text-xs leading-tight font-extrabold tracking-wider gold-foil-text drop-shadow uppercase">
                          {{ book.title.split(' ')[0] }} {{ book.title.split(' ')[1] || '' }}
                        </p>
                        <div class="w-10 h-0.5 bg-[#C5A059] mx-auto mt-1 rounded-full"></div>
                      </div>
                      <div class="relative z-10 flex items-center justify-between text-[8.5px] text-white/80 border-t border-white/15 pt-1 font-mono">
                        <span class="truncate max-w-[70px] text-[#eed394] font-medium">{{ book.author || 'ITSM' }}</span>
                        <span class="px-1 py-0.5 bg-white/10 rounded">{{ book.cutter }}</span>
                      </div>
                      <div class="absolute bottom-1.5 left-1.5 z-30 bg-white text-slate-900 px-1.5 py-0.5 rounded-[2px] font-mono text-[7px] font-black shadow">
                        {{ book.dewey }}
                      </div>
                    </div>
                  </div>

                  <!-- Textos con tipografía más grande -->
                  <div class="flex flex-col min-w-0 flex-1">
                    <h3 class="text-lg leading-snug text-[#002351] group-hover:text-[#184580] line-clamp-2 transition-colors font-bold font-['Plus_Jakarta_Sans',sans-serif]">
                      {{ book.title }}
                    </h3>
                    <p class="text-sm text-slate-700 mt-1.5 flex items-center gap-1.5">
                      <span class="font-bold text-[#002351]">Autor:</span> {{ book.author || 'Sin autor especificado' }}
                    </p>
                    <div class="mt-2 flex items-center" v-if="book.note">
                      <span class="text-xs text-slate-700 bg-slate-100 px-2.5 py-1 rounded-md border border-slate-200 font-medium">
                        <strong class="text-[#002351] font-bold">Nota:</strong> {{ book.note }}
                      </span>
                    </div>
                    <div class="mt-3 flex flex-wrap items-center gap-2">
                      <span class="text-xs text-[#002351] font-bold bg-blue-50 px-2.5 py-1 rounded-md border border-blue-200 font-mono">
                        Dewey: {{ book.dewey }}
                      </span>
                      <span class="text-xs text-slate-800 font-bold bg-slate-100 px-2.5 py-1 rounded-md border border-slate-200 font-mono">
                        Cutter: {{ book.cutter }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Footer Card -->
                <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-between text-slate-600">
                  <div class="flex items-center gap-1.5 text-xs">
                    <span class="material-symbols-outlined text-base text-[#C5A059]">shelves</span>
                    <span class="font-semibold text-slate-800 truncate max-w-[190px]">{{ book.shelfName }}</span>
                  </div>
                  <button
                    class="px-3.5 py-1.5 bg-[#002351] hover:bg-[#184580] text-white text-xs font-bold rounded-xl transition-all flex items-center gap-1.5 shadow-sm cursor-pointer"
                    @click.stop="selectBook(book)"
                  >
                    <span>Gestionar</span>
                    <span class="material-symbols-outlined text-sm">tune</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Panel Lateral de Detalle / Ficha Técnica (Limpio y Espacioso) -->
            <aside class="lg:col-span-4 bg-white rounded-2xl p-6 shadow-[0_8px_30px_rgba(0,35,81,0.08)] border border-slate-200 sticky top-36 transition-all">
              <div class="flex items-center justify-between pb-3.5 border-b border-slate-200">
                <div class="flex items-center gap-2.5">
                  <span class="w-3 h-3 rounded-full bg-[#002351]"></span>
                  <span class="text-xs text-[#002351] font-black uppercase tracking-wider">FICHA TÉCNICA / CONTROL</span>
                </div>
                <span class="px-2.5 py-1 rounded text-xs font-bold bg-[#C5A059]/20 text-[#7a5712] border border-[#C5A059]/40">
                  Campus Monclova
                </span>
              </div>

              <div class="mt-5 flex flex-col gap-5" v-if="selectedBook">
                <!-- Portada y Título -->
                <div class="flex items-start gap-4">
                  <div
                    :class="[
                      'w-22 h-32 shrink-0 rounded-r-md rounded-l-[2px] text-white p-2.5 flex flex-col justify-between shadow-lg relative overflow-hidden border-l-2 border-l-[#C5A059] border-y border-r border-white/20 bg-gradient-to-br',
                      selectedBook.coverGradient || 'from-[#0c264d] via-[#001f47] to-[#04142d]'
                    ]"
                  >
                    <span class="text-[8px] font-bold text-[#C5A059] font-mono">{{ selectedBook.dewey }}</span>
                    <p class="text-[10px] leading-tight font-extrabold gold-foil-text text-center uppercase">
                      {{ selectedBook.title.split(' ')[0] }}
                    </p>
                    <span class="text-[7px] text-[#c7d9fb] text-center font-mono">ITSM Monclova</span>
                  </div>

                  <div class="flex flex-col min-w-0 flex-1">
                    <span class="px-2.5 py-1 rounded text-xs font-bold bg-[#002351] text-white font-mono w-fit mb-1.5 shadow-sm">
                      {{ selectedBook.folio }}
                    </span>
                    <h4 class="text-lg text-[#002351] leading-tight font-bold font-['Plus_Jakarta_Sans',sans-serif]">
                      {{ selectedBook.title }}
                    </h4>
                    <div class="mt-2.5 flex items-center">
                      <span :class="['px-3 py-1 rounded-full text-xs font-bold border flex items-center gap-1.5', getStatusBadge(selectedBook.statusId).badgeClass]">
                        <span :class="['w-2 h-2 rounded-full', getStatusBadge(selectedBook.statusId).dotClass]"></span>
                        {{ getStatusBadge(selectedBook.statusId).label }}
                      </span>
                    </div>
                  </div>
                </div>

                <!-- Datos Técnicos -->
                <div class="bg-slate-50 p-4.5 rounded-2xl border border-slate-200 flex flex-col gap-3.5">
                  <div class="text-xs font-bold text-slate-500 uppercase tracking-wide border-b border-slate-200 pb-1.5 flex items-center justify-between">
                    <span>Datos de Catalogación</span>
                    <span class="text-xs font-bold text-[#002351] font-mono">Tec Monclova</span>
                  </div>

                  <div class="bg-white p-3 rounded-xl border border-slate-200 flex flex-col">
                    <span class="text-slate-400 font-semibold text-[11px] uppercase">Autor / Responsabilidad:</span>
                    <span class="font-bold text-[#002351] text-sm mt-0.5">{{ selectedBook.author || 'Sin autor especificado' }}</span>
                  </div>

                  <div class="bg-white p-3 rounded-xl border border-slate-200 flex flex-col" v-if="selectedBook.note">
                    <span class="text-slate-400 font-semibold text-[11px] uppercase">Nota (Edición / Volumen):</span>
                    <span class="font-bold text-slate-800 text-sm mt-0.5">{{ selectedBook.note }}</span>
                  </div>

                  <div class="grid grid-cols-2 gap-3">
                    <div class="bg-white p-3 rounded-xl border border-slate-200 flex flex-col">
                      <span class="text-slate-400 font-semibold text-[11px] uppercase">Código Dewey:</span>
                      <span class="font-bold text-[#002351] text-sm mt-0.5 font-mono">{{ selectedBook.dewey }}</span>
                    </div>
                    <div class="bg-white p-3 rounded-xl border border-slate-200 flex flex-col">
                      <span class="text-slate-400 font-semibold text-[11px] uppercase">Código Cutter:</span>
                      <span class="font-bold text-slate-800 text-sm mt-0.5 font-mono">{{ selectedBook.cutter }}</span>
                    </div>
                  </div>

                  <div class="bg-white p-3 rounded-xl border border-slate-200 flex flex-col">
                    <span class="text-slate-400 font-semibold text-[11px] uppercase">Estante Físico:</span>
                    <span class="font-bold text-[#002351] text-sm mt-0.5 flex items-center gap-1.5">
                      <span class="material-symbols-outlined text-base text-[#C5A059]">shelves</span>
                      {{ selectedBook.shelfName }}
                    </span>
                  </div>

                  <!-- Barra de disponibilidad -->
                  <div class="flex flex-col gap-1.5 mt-1">
                    <div class="flex justify-between text-xs">
                      <span class="text-slate-600 font-semibold">Disponibilidad en Sala:</span>
                      <span class="font-bold text-slate-900">{{ selectedBook.availableText }}</span>
                    </div>
                    <div class="w-full h-2.5 bg-slate-200 rounded-full overflow-hidden">
                      <div class="h-full bg-emerald-600 rounded-full transition-all duration-500" :style="{ width: selectedBook.availabilityPercent + '%' }"></div>
                    </div>
                  </div>
                </div>

                <!-- Botones de Acción Administrativa -->
                <div class="flex flex-col gap-2.5 pt-1">
                  <button
                    class="w-full h-12 bg-[#002351] hover:bg-[#184580] text-white text-sm font-bold rounded-xl shadow-md flex items-center justify-center gap-2 transition-all active:scale-[0.98] border border-white/10 cursor-pointer"
                    @click="openActionModal('cambiar_estado')"
                  >
                    <span class="material-symbols-outlined text-lg text-[#ecd49c]">published_with_changes</span>
                    <span>Cambiar Estado de Ejemplar</span>
                  </button>

                  <div class="grid grid-cols-2 gap-2.5">
                    <button
                      class="h-11 bg-blue-50 hover:bg-blue-100 text-[#1D4ED8] border border-blue-200 text-xs font-bold rounded-xl flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                      @click="openActionModal('prestamo_devolucion')"
                    >
                      <span class="material-symbols-outlined text-base text-[#1D4ED8]">swap_horizontal_circle</span>
                      <span>Préstamo / Devolución</span>
                    </button>
                    <button
                      class="h-11 bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-200 text-xs font-bold rounded-xl flex items-center justify-center gap-1.5 transition-colors cursor-pointer"
                      @click="openActionModal('editar_ficha')"
                    >
                      <span class="material-symbols-outlined text-base text-[#002351]">edit_square</span>
                      <span>Editar Ficha</span>
                    </button>
                  </div>

                  <button
                    class="w-full h-11 bg-[#FEF3C7] hover:bg-[#fde68a] text-[#B45309] border border-[#D97706]/40 text-xs font-bold rounded-xl flex items-center justify-center gap-2 transition-colors cursor-pointer"
                    @click="openActionModal('reportar_reparacion')"
                  >
                    <span class="material-symbols-outlined text-lg text-[#D97706]">handyman</span>
                    <span>Reportar a Reparación / Taller</span>
                  </button>
                </div>
              </div>
            </aside>
          </div>
        </div>
      </section>
    </main>

    <!-- Modal de Acción Administrativa -->
    <div v-if="showActionModal" class="fixed inset-0 z-50 bg-[#001838]/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white max-w-md w-full rounded-2xl p-6 shadow-2xl border border-slate-200 flex flex-col gap-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2 text-[#002351] font-bold">
            <span class="material-symbols-outlined text-2xl text-[#C5A059]">{{ modalIcon }}</span>
            <span class="text-lg font-['Plus_Jakarta_Sans',sans-serif]">{{ modalActionTitle }}</span>
          </div>
          <button class="p-1 text-slate-400 hover:text-slate-700 rounded-full cursor-pointer" @click="showActionModal = false">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>

        <p class="text-sm text-slate-600 leading-relaxed">{{ modalActionMessage }}</p>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-bold text-slate-700 uppercase">Seleccionar Nuevo Estado:</label>
          <select
            v-model="selectedNewStatus"
            class="h-11 px-3 bg-slate-50 text-slate-800 text-sm rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-[#002351] cursor-pointer"
          >
            <option :value="1">1. Disponible (Verde)</option>
            <option :value="2">2. Prestado (Azul)</option>
            <option :value="3">3. En reparación (Ámbar)</option>
            <option :value="4">4. En proceso de baja (Rojo)</option>
            <option :value="5">5. En catálogo (Morado)</option>
          </select>
        </div>

        <div class="bg-slate-50 p-4 rounded-xl border border-slate-200 flex items-center justify-between">
          <div>
            <span class="text-[10px] text-slate-400 font-bold uppercase tracking-wider">Folio de Movimiento:</span>
            <p class="text-xl text-[#002351] font-extrabold tracking-wide font-mono">{{ modalTicketCode }}</p>
            <span class="text-xs text-emerald-700 font-semibold">Registrado por: Mtra. Carmen Valdés</span>
          </div>
          <div class="w-12 h-12 bg-[#001b3d] text-[#C5A059] rounded-xl flex items-center justify-center shadow-inner">
            <span class="material-symbols-outlined text-2xl">verified_user</span>
          </div>
        </div>

        <div class="flex justify-end gap-2.5 pt-2">
          <button
            class="px-4 py-2 text-slate-600 hover:bg-slate-100 text-xs font-semibold rounded-xl cursor-pointer"
            @click="showActionModal = false"
          >
            Cancelar
          </button>
          <button
            class="px-5 py-2.5 bg-[#002351] text-white text-xs font-bold rounded-xl hover:bg-[#184580] transition-colors shadow-md cursor-pointer"
            @click="applyStatusUpdate"
          >
            Confirmar y Aplicar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal para Registrar Nuevo Ejemplar -->
    <div v-if="showNewBookModal" class="fixed inset-0 z-50 bg-[#001838]/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white max-w-lg w-full rounded-2xl p-6 shadow-2xl border border-slate-200 flex flex-col gap-4">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-2 text-[#002351] font-bold">
            <span class="material-symbols-outlined text-2xl text-[#C5A059]">library_add</span>
            <span class="text-lg font-['Plus_Jakarta_Sans',sans-serif]">Registrar Nuevo Ejemplar</span>
          </div>
          <button class="p-1 text-slate-400 hover:text-slate-700 rounded-full cursor-pointer" @click="showNewBookModal = false">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>

        <form class="flex flex-col gap-3.5" @submit.prevent="saveNewBook">
          <div>
            <label class="text-xs font-bold text-slate-700 uppercase">Título de la Obra *</label>
            <input
              v-model="newBook.title"
              required
              class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none"
              placeholder="Ej. Inteligencia Artificial: Un Enfoque Moderno"
            />
          </div>

          <div class="grid grid-cols-2 gap-3.5">
            <div>
              <label class="text-xs font-bold text-slate-700 uppercase">Autor(es)</label>
              <input
                v-model="newBook.author"
                class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none"
                placeholder="Stuart Russell & Peter Norvig"
              />
            </div>
            <div>
              <label class="text-xs font-bold text-slate-700 uppercase">Folio Institucional *</label>
              <input
                v-model="newBook.folio"
                required
                class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none font-mono"
                placeholder="FOL-TECNM-009"
              />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-3.5">
            <div>
              <label class="text-xs font-bold text-slate-700 uppercase">Clasificación Dewey *</label>
              <input
                v-model="newBook.dewey"
                required
                class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none font-mono"
                placeholder="006.3"
              />
            </div>
            <div>
              <label class="text-xs font-bold text-slate-700 uppercase">Código Cutter *</label>
              <input
                v-model="newBook.cutter"
                required
                class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none font-mono"
                placeholder=".R96 2026"
              />
            </div>
          </div>

          <div class="grid grid-cols-2 gap-3.5">
            <div>
              <label class="text-xs font-bold text-slate-700 uppercase">Estante Asignado</label>
              <select
                v-model="newBook.shelfId"
                class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none cursor-pointer"
              >
                <option :value="1">Estante 1 (Software y Computación)</option>
                <option :value="2">Estante 2 (Siderurgia y Metalurgia)</option>
                <option :value="3">Estante 3 (Redes y Telecomunicaciones)</option>
                <option :value="4">Estante 4 (Ciencias Básicas)</option>
                <option :value="5">Estante 5 (Gestión Empresarial)</option>
              </select>
            </div>
            <div>
              <label class="text-xs font-bold text-slate-700 uppercase">Estado Inicial</label>
              <select
                v-model="newBook.statusId"
                class="w-full h-11 px-3.5 bg-slate-50 border border-slate-200 rounded-xl text-sm mt-1 focus:ring-2 focus:ring-[#002351] focus:outline-none cursor-pointer"
              >
                <option :value="1">Disponible</option>
                <option :value="5">En catálogo</option>
                <option :value="3">En reparación</option>
              </select>
            </div>
          </div>

          <div class="flex justify-end gap-2.5 pt-3">
            <button
              type="button"
              class="px-4 py-2 text-slate-600 hover:bg-slate-100 text-xs font-semibold rounded-xl cursor-pointer"
              @click="showNewBookModal = false"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="px-5 py-2.5 bg-[#002351] text-white text-xs font-bold rounded-xl hover:bg-[#184580] transition-colors shadow-md cursor-pointer"
            >
              Guardar Ejemplar en Acervo
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Footer Institucional -->
    <footer class="w-full bg-[#00142e] text-white py-12 border-t border-white/10 mt-16">
      <div class="max-w-[1440px] mx-auto px-6 lg:px-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8 mb-10">
          <div class="flex flex-col gap-3">
            <div class="flex items-center gap-2.5">
              <span class="material-symbols-outlined text-2xl text-[#C5A059]">local_library</span>
              <span class="text-lg text-white font-bold font-['Plus_Jakarta_Sans',sans-serif]">Tec Monclova</span>
            </div>
            <p class="text-xs text-[#b0c8ee] leading-relaxed">
              Instituto Tecnológico Superior de Monclova. Módulo de Administración y Gestión Bibliotecaria. Control sistematizado del acervo físico institucional.
            </p>
          </div>

          <div class="flex flex-col gap-2.5">
            <h4 class="text-xs text-[#C5A059] uppercase tracking-wider font-bold">Módulos Administrativos</h4>
            <ul class="flex flex-col gap-1.5 text-xs text-[#b0c8ee]">
              <li class="hover:text-white transition-colors cursor-pointer">Circulación y Préstamos de Mostrador</li>
              <li class="hover:text-white transition-colors cursor-pointer">Catalogación y Clasificación Dewey</li>
              <li class="hover:text-white transition-colors cursor-pointer">Taller de Restauración y Bajas</li>
              <li class="hover:text-white transition-colors cursor-pointer">Inventario y Auditoría de Estantería</li>
            </ul>
          </div>

          <div class="flex flex-col gap-2.5">
            <h4 class="text-xs text-[#C5A059] uppercase tracking-wider font-bold">Políticas & Catálogos</h4>
            <ul class="flex flex-col gap-1.5 text-xs text-[#b0c8ee]">
              <li class="hover:text-white transition-colors cursor-pointer">Normativa de Préstamos ITSM</li>
              <li class="hover:text-white transition-colors cursor-pointer">Manual de Procesos Técnicos MARC-21</li>
              <li class="hover:text-white transition-colors cursor-pointer">Protocolo de Bajas y Descarte</li>
              <li class="hover:text-white transition-colors cursor-pointer">Acervo Especializado Siderurgia</li>
            </ul>
          </div>

          <div class="flex flex-col gap-2.5">
            <h4 class="text-xs text-[#C5A059] uppercase tracking-wider font-bold">Soporte al Bibliotecario</h4>
            <ul class="flex flex-col gap-1.5 text-xs text-[#b0c8ee]">
              <li>Carretera 57 Km 4.5, Monclova, Coahuila</li>
              <li>soporte.sigb@monclova.tecnm.mx</li>
              <li>Ext. Mostrador: 114 / Catalogación: 116</li>
              <li>Mesa de Ayuda de Sistemas ITSM</li>
            </ul>
          </div>
        </div>

        <div class="pt-6 border-t border-white/10 flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-[#8ca8d4]">
          <p>© 2026 Instituto Tecnológico Superior de Monclova (ITSM) • Módulo de Gestión Bibliotecaria.</p>
          <div class="flex items-center gap-4">
            <span class="hover:text-white transition-colors cursor-pointer">Manual de Usuario SIGB</span>
            <span class="hover:text-white transition-colors cursor-pointer">Bitácora de Auditoría</span>
            <span class="hover:text-white transition-colors cursor-pointer">Portal Institucional ITSM</span>
          </div>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.book-stage {
  perspective: 900px;
}

.book-cover-3d {
  transform-style: preserve-3d;
  transition: transform 0.42s cubic-bezier(0.2, 0.8, 0.2, 1), box-shadow 0.42s cubic-bezier(0.2, 0.8, 0.2, 1);
  transform: rotateY(-6deg) rotateX(2deg);
}

.book-card:hover .book-cover-3d {
  transform: rotateY(-18deg) rotateX(4deg) translateY(-8px) translateZ(14px);
  box-shadow: 18px 24px 34px -8px rgba(0, 35, 81, 0.45), 0 0 24px -2px rgba(197, 160, 89, 0.35);
}

.book-spine-lighting {
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.22) 0%, rgba(255, 255, 255, 0.04) 2.5%, rgba(0, 0, 0, 0.45) 5%, transparent 12%);
}

.gold-foil-text {
  background: linear-gradient(135deg, #FFF3D6 0%, #D8B168 45%, #FBF0D9 70%, #9B752A 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
</style>
