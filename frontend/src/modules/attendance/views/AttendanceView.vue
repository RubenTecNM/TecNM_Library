<script setup lang="ts">
import { computed, onBeforeUnmount, reactive, ref } from 'vue'

type ServiceType = 'Presencial' | 'Virtual' | 'Reunión' | 'Clase' | 'Mantenimiento' | 'Otra'
type ShiftType = 'Matutino' | 'Vespertino'
type FilterPreset = 'hoy' | 'semana' | 'mes' | 'custom'

interface ServiceOption {
  name: ServiceType
  icon: string
  badgeClass: string
  dotClass: string
}

interface SampleVisitor {
  matricula: string
  nombre: string
  shortRol: string
}

interface VisitRecord {
  id: number
  dateIso: string
  timeLabel: string
  shift: ShiftType
  matricula: string
  nombre: string
  carrera: string
  servicio: ServiceType
  nota?: string
  isNew?: boolean
}

const SERVICE_OPTIONS: ServiceOption[] = [
  {
    name: 'Presencial',
    icon: 'menu_book',
    badgeClass: 'bg-blue-100 text-blue-800',
    dotClass: 'bg-blue-600',
  },
  {
    name: 'Virtual',
    icon: 'computer',
    badgeClass: 'bg-emerald-100 text-emerald-800',
    dotClass: 'bg-emerald-600',
  },
  {
    name: 'Reunión',
    icon: 'groups',
    badgeClass: 'bg-purple-100 text-purple-800',
    dotClass: 'bg-purple-600',
  },
  {
    name: 'Clase',
    icon: 'co_present',
    badgeClass: 'bg-amber-100 text-amber-900',
    dotClass: 'bg-amber-600',
  },
  {
    name: 'Mantenimiento',
    icon: 'build',
    badgeClass: 'bg-slate-200 text-slate-800',
    dotClass: 'bg-slate-600',
  },
  {
    name: 'Otra',
    icon: 'more_horiz',
    badgeClass: 'bg-surface-container text-on-surface',
    dotClass: 'bg-primary',
  },
]

const SERVICE_META: Record<ServiceType, ServiceOption> = Object.fromEntries(
  SERVICE_OPTIONS.map((opt) => [opt.name, opt]),
) as Record<ServiceType, ServiceOption>

const SAMPLE_USERS: SampleVisitor[] = [
  {
    matricula: '20570142',
    nombre: 'Carlos Alberto Mendoza Rivas',
    shortRol: 'Ing. Informática',
  },
  {
    matricula: 'DOC-0841',
    nombre: 'Ing. Roberto Hernández D.',
    shortRol: 'Informática / Docente',
  },
  {
    matricula: '21570389',
    nombre: 'Ana Sofía Garza V.',
    shortRol: 'Ing. Informática / Alumna',
  },
  {
    matricula: '22570014',
    nombre: 'Luis Fernando Ramos P.',
    shortRol: 'Ing. Gestión Empresarial / Alumno',
  },
  {
    matricula: '20570912',
    nombre: 'María José Torres G.',
    shortRol: 'Ing. Industrial / Alumna',
  },
  {
    matricula: 'EXT-0019',
    nombre: 'Téc. Jaime Villarreal C.',
    shortRol: 'Ing. Electrónica / Soporte',
  },
]

function toLocalIsoDate(date: Date): string {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

function addDaysIso(baseIso: string, deltaDays: number): string {
  const [y, m, d] = baseIso.split('-').map(Number)
  const dt = new Date(y, (m || 1) - 1, d || 1)
  dt.setDate(dt.getDate() + deltaDays)
  return toLocalIsoDate(dt)
}

function formatDisplayDate(isoDate: string): string {
  const [y, m, d] = isoDate.split('-')
  if (!y || !m || !d) return isoDate
  return `${d}/${m}/${y}`
}

function formatCurrentTime12h(date: Date): string {
  let hours = date.getHours()
  const minutes = String(date.getMinutes()).padStart(2, '0')
  const ampm = hours >= 12 ? 'PM' : 'AM'
  hours = hours % 12
  hours = hours || 12
  return `${String(hours).padStart(2, '0')}:${minutes} ${ampm}`
}

const todayIso = toLocalIsoDate(new Date())
const defaultShift: ShiftType = new Date().getHours() < 15 ? 'Matutino' : 'Vespertino'

const initialVisits: VisitRecord[] = [
  {
    id: 1,
    dateIso: todayIso,
    timeLabel: '09:01 AM',
    shift: 'Matutino',
    matricula: '20570142',
    nombre: 'Carlos Alberto Mendoza Rivas',
    carrera: 'Ing. Informática',
    servicio: 'Presencial',
  },
  {
    id: 2,
    dateIso: todayIso,
    timeLabel: '09:15 AM',
    shift: 'Matutino',
    matricula: 'DOC-0841',
    nombre: 'Ing. Roberto Hernández D.',
    carrera: 'Informática / Docente',
    servicio: 'Clase',
  },
  {
    id: 3,
    dateIso: todayIso,
    timeLabel: '09:30 AM',
    shift: 'Matutino',
    matricula: '21570389',
    nombre: 'Ana Sofía Garza V.',
    carrera: 'Ing. Informática / Alumna',
    servicio: 'Virtual',
  },
  {
    id: 4,
    dateIso: todayIso,
    timeLabel: '10:05 AM',
    shift: 'Matutino',
    matricula: '22570014',
    nombre: 'Luis Fernando Ramos P.',
    carrera: 'Ing. Gestión Empresarial / Alumno',
    servicio: 'Reunión',
  },
  {
    id: 5,
    dateIso: todayIso,
    timeLabel: '10:45 AM',
    shift: 'Matutino',
    matricula: '20570912',
    nombre: 'María José Torres G.',
    carrera: 'Ing. Industrial / Alumna',
    servicio: 'Presencial',
  },
  {
    id: 6,
    dateIso: todayIso,
    timeLabel: '11:20 AM',
    shift: 'Matutino',
    matricula: 'EXT-0019',
    nombre: 'Téc. Jaime Villarreal C.',
    carrera: 'Ing. Electrónica / Soporte',
    servicio: 'Mantenimiento',
  },
  {
    id: 7,
    dateIso: todayIso,
    timeLabel: '04:15 PM',
    shift: 'Vespertino',
    matricula: '21280615',
    nombre: 'Diego Alejandro Salinas R.',
    carrera: 'Ing. Mecatrónica / Alumno',
    servicio: 'Presencial',
  },
  {
    id: 8,
    dateIso: todayIso,
    timeLabel: '05:10 PM',
    shift: 'Vespertino',
    matricula: '22280402',
    nombre: 'Valeria Guadalupe Castillo M.',
    carrera: 'Ing. Gestión Empresarial / Alumna',
    servicio: 'Virtual',
  },
  {
    id: 9,
    dateIso: addDaysIso(todayIso, -1),
    timeLabel: '09:40 AM',
    shift: 'Matutino',
    matricula: '20280199',
    nombre: 'Luis Fernando Treviño P.',
    carrera: 'Ing. Industrial / Alumno',
    servicio: 'Reunión',
  },
  {
    id: 10,
    dateIso: addDaysIso(todayIso, -2),
    timeLabel: '05:30 PM',
    shift: 'Vespertino',
    matricula: '23280711',
    nombre: 'Sofía Alejandra Morales L.',
    carrera: 'Ing. Informática / Alumna',
    servicio: 'Presencial',
  },
]

const visits = ref<VisitRecord[]>(initialVisits.map((item) => ({ ...item })))
let nextVisitId = visits.value.length + 1

const form = reactive({
  dateIso: todayIso,
  shift: defaultShift as ShiftType,
  visitorInput: '',
  service: 'Presencial' as ServiceType,
  note: '',
  isGroup: false,
  groupCount: 1,
})

// Period filters
const filterFrom = ref(todayIso)
const filterTo = ref(todayIso)
const appliedFrom = ref(todayIso)
const appliedTo = ref(todayIso)
const activePreset = ref<FilterPreset>('hoy')

// Pagination
const pageSize = 6
const currentPage = ref(1)

// Toast notification
const toastVisible = ref(false)
const toastTitle = ref('Visita registrada exitosamente')
const toastDetails = ref('Registro añadido a la bitácora institucional')
let toastTimer: ReturnType<typeof setTimeout> | null = null

function showToast(title: string, details: string) {
  toastTitle.value = title
  toastDetails.value = details
  toastVisible.value = true
  if (toastTimer !== null) {
    clearTimeout(toastTimer)
  }
  toastTimer = setTimeout(() => {
    toastVisible.value = false
    toastTimer = null
  }, 3500)
}

function selectService(serviceName: ServiceType) {
  form.service = serviceName
}

function handleGroupToggle() {
  if (form.isGroup) {
    if (form.groupCount <= 1) {
      form.groupCount = 5
    }
  } else {
    form.groupCount = 1
  }
}

function findMatchingVisitor(query: string): SampleVisitor | undefined {
  const normalized = query.trim().toLowerCase()
  if (!normalized) return undefined
  return SAMPLE_USERS.find(
    (user) =>
      user.matricula.toLowerCase() === normalized ||
      user.nombre.toLowerCase() === normalized ||
      user.nombre.toLowerCase().includes(normalized),
  )
}

function handleRegisterVisit() {
  const rawInput = form.visitorInput.trim()
  if (!rawInput) return

  const matched = findMatchingVisitor(rawInput)
  const visitDateIso = form.dateIso || todayIso

  let matricula = matched?.matricula ?? ''
  let nombre = matched?.nombre ?? rawInput
  const carrera = matched?.shortRol ?? 'Comunidad TecNM'

  if (!matricula) {
    matricula =
      rawInput.length <= 10 && /^[A-Za-z0-9-]+$/.test(rawInput)
        ? rawInput.toUpperCase()
        : `VIS-${Math.floor(1000 + Math.random() * 9000)}`
  }

  const safeGroupCount = Math.min(60, Math.max(1, Number(form.groupCount) || 1))
  if (form.isGroup && safeGroupCount > 1) {
    nombre = `${nombre} (Grupo: +${safeGroupCount} pers.)`
  }

  const now = new Date()
  const newVisit: VisitRecord = {
    id: nextVisitId++,
    dateIso: visitDateIso,
    timeLabel: formatCurrentTime12h(now),
    shift: form.shift,
    matricula,
    nombre,
    carrera,
    servicio: form.service,
    nota: form.note.trim() || undefined,
    isNew: true,
  }

  visits.value.unshift(newVisit)
  setTimeout(() => {
    newVisit.isNew = false
  }, 1200)

  // Ensure the active date range includes the registered visit date
  if (visitDateIso < appliedFrom.value) {
    filterFrom.value = visitDateIso
    appliedFrom.value = visitDateIso
    activePreset.value = 'custom'
  }
  if (visitDateIso > appliedTo.value) {
    filterTo.value = visitDateIso
    appliedTo.value = visitDateIso
    activePreset.value = 'custom'
  }

  currentPage.value = 1

  showToast(
    'Visita registrada exitosamente',
    `Registrado: ${nombre} (${form.service} - Turno ${form.shift})`,
  )

  form.visitorInput = ''
  form.note = ''
  form.isGroup = false
  form.groupCount = 1
}

function handleDeleteVisit(visit: VisitRecord) {
  if (!window.confirm('¿Desea anular esta entrada del registro de asistencias?')) {
    return
  }
  visits.value = visits.value.filter((item) => item.id !== visit.id)
  if (currentPage.value > totalPages.value) {
    currentPage.value = totalPages.value
  }
  showToast('Registro anulado', `Se anuló la visita de ${visit.nombre}.`)
}

function applyDateFilter() {
  if (filterFrom.value && filterTo.value && filterFrom.value > filterTo.value) {
    const temp = filterFrom.value
    filterFrom.value = filterTo.value
    filterTo.value = temp
  }
  appliedFrom.value = filterFrom.value || todayIso
  appliedTo.value = filterTo.value || todayIso
  currentPage.value = 1
  showToast(
    'Filtro aplicado',
    `Mostrando visitas del ${formatDisplayDate(appliedFrom.value)} al ${formatDisplayDate(appliedTo.value)}.`,
  )
}

function setFilterPreset(preset: 'hoy' | 'semana' | 'mes') {
  activePreset.value = preset
  if (preset === 'hoy') {
    filterFrom.value = todayIso
    filterTo.value = todayIso
  } else if (preset === 'semana') {
    filterFrom.value = addDaysIso(todayIso, -6)
    filterTo.value = todayIso
  } else if (preset === 'mes') {
    const [y, m] = todayIso.split('-')
    filterFrom.value = `${y}-${m}-01`
    filterTo.value = todayIso
  }
  appliedFrom.value = filterFrom.value
  appliedTo.value = filterTo.value
  currentPage.value = 1
  showToast(
    'Periodo actualizado',
    `Consulta del ${formatDisplayDate(appliedFrom.value)} al ${formatDisplayDate(appliedTo.value)}.`,
  )
}

function onManualDateInput() {
  activePreset.value = 'custom'
}

const filteredVisits = computed(() => {
  return visits.value.filter((visit) => {
    const afterStart = !appliedFrom.value || visit.dateIso >= appliedFrom.value
    const beforeEnd = !appliedTo.value || visit.dateIso <= appliedTo.value
    return afterStart && beforeEnd
  })
})

const totalCount = computed(() => filteredVisits.value.length)
const matutinoCount = computed(
  () => filteredVisits.value.filter((visit) => visit.shift === 'Matutino').length,
)
const vespertinoCount = computed(
  () => filteredVisits.value.filter((visit) => visit.shift === 'Vespertino').length,
)

const totalPages = computed(() => Math.max(1, Math.ceil(filteredVisits.value.length / pageSize)))

const paginatedVisits = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  return filteredVisits.value.slice(start, start + pageSize)
})

const rangeStart = computed(() => {
  if (filteredVisits.value.length === 0) return 0
  return (currentPage.value - 1) * pageSize + 1
})

const rangeEnd = computed(() =>
  Math.min(currentPage.value * pageSize, filteredVisits.value.length),
)

const pageNumbers = computed(() => Array.from({ length: totalPages.value }, (_, idx) => idx + 1))

function exportToCSV() {
  const headers = ['Fecha', 'Hora', 'Turno', 'Matrícula', 'Nombre', 'Carrera', 'Servicio', 'Nota']
  const rows = filteredVisits.value.map((visit) => [
    formatDisplayDate(visit.dateIso),
    visit.timeLabel,
    visit.shift,
    visit.matricula,
    visit.nombre,
    visit.carrera,
    visit.servicio,
    visit.nota ?? '',
  ])

  const escapeCsv = (val: string) => `"${val.replace(/"/g, '""')}"`
  const csvContent =
    '\uFEFF' +
    [headers, ...rows].map((row) => row.map((cell) => escapeCsv(String(cell))).join(',')).join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.setAttribute('download', `registro_asistencias_${appliedFrom.value}_a_${appliedTo.value}.csv`)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)

  showToast('Reporte CSV generado', `Se exportaron ${filteredVisits.value.length} visitas del periodo.`)
}

onBeforeUnmount(() => {
  if (toastTimer !== null) {
    clearTimeout(toastTimer)
  }
})
</script>

<template>
  <div class="attendance-page flex flex-col min-h-screen bg-background">
    <!-- Top Institutional Header -->
    <header
      class="w-full px-4 sm:px-space-xl pt-space-lg pb-space-md flex flex-col gap-space-xs bg-surface-container-lowest shadow-[0_1px_8px_rgba(0,0,0,0.04)]"
    >
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div class="flex flex-col">
          <h1 class="font-headline-lg !text-[24px] sm:!text-[30px] text-primary font-bold tracking-tight !leading-tight">
            Biblioteca Tec Monclova
          </h1>
        </div>
        <div class="flex items-center gap-space-sm">
          <div class="flex items-center gap-space-xs bg-surface-container-low px-space-md py-space-xs rounded-full">
            <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
            <span class="font-label-sm text-label-sm text-on-surface-variant font-medium">
              Servicio Activo • Sala General
            </span>
          </div>
        </div>
      </div>
    </header>

    <main class="w-full flex-1 px-4 sm:px-space-xl py-space-lg bg-background">
      <div class="flex flex-col w-full gap-space-lg">
        <!-- Dynamic Notification Toast -->
        <div
          :class="[
            'fixed top-6 right-4 sm:right-8 z-50 transition-all duration-300 ease-out flex items-center gap-space-md bg-primary text-on-primary px-space-lg py-space-md rounded-xl shadow-xl border-l-4 border-secondary-fixed max-w-md',
            toastVisible
              ? 'translate-y-0 opacity-100 pointer-events-auto'
              : '-translate-y-24 opacity-0 pointer-events-none',
          ]"
          role="status"
          aria-live="polite"
        >
          <span class="material-symbols-outlined text-secondary-fixed text-[26px] shrink-0">check_circle</span>
          <div class="flex flex-col min-w-0">
            <span class="font-headline-sm text-headline-sm text-on-primary">{{ toastTitle }}</span>
            <span class="font-body-sm text-body-sm text-primary-fixed truncate">{{ toastDetails }}</span>
          </div>
        </div>

        <!-- Header Banner Section -->
        <section
          class="flex flex-col md:flex-row md:items-center justify-between gap-space-md bg-surface-container-lowest p-space-lg rounded-xl shadow-sm"
        >
          <div class="flex items-center gap-space-md">
            <div class="flex flex-col">
              <div class="flex items-center gap-space-sm flex-wrap">
                <span class="font-label-sm text-label-sm uppercase tracking-wider text-secondary font-bold">
                  TecNM • Campus Monclova
                </span>
              </div>
              <h2 class="font-headline-md !text-[22px] text-primary mt-0.5 font-semibold">
                Registro de Asistencias y Visitas Diarias
              </h2>
              <p class="font-body-sm text-body-sm !text-on-surface-variant !max-w-none mt-0.5">
                Control de afluencia, consulta en sala de lectura, módulos virtuales y aulas magnas.
              </p>
            </div>
          </div>

          <div class="flex items-center gap-space-sm shrink-0 self-start md:self-auto">
            <div class="flex items-center gap-space-xs bg-surface-container-low px-space-md py-space-sm rounded-lg">
              <span class="material-symbols-outlined text-primary text-[20px]">calendar_today</span>
              <div class="flex flex-col text-right">
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase">Periodo Vigente</span>
                <span class="font-label-lg text-label-lg text-primary font-bold">Ago - Dic 2026</span>
              </div>
            </div>
          </div>
        </section>

        <!-- Top Section: 'Nueva Visita' Registration Form Card -->
        <section class="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden">
          <div class="bg-primary-container px-space-lg py-space-md flex items-center justify-between text-on-primary">
            <div class="flex items-center gap-space-sm">
              <span class="material-symbols-outlined text-[22px]">how_to_reg</span>
              <h3 class="font-headline-sm !text-[18px] text-on-primary tracking-wide font-semibold">
                Nueva Visita
              </h3>
            </div>
          </div>

          <form class="p-space-lg flex flex-col gap-space-lg" @submit.prevent="handleRegisterVisit">
            <!-- Row 1: Fecha & Turno -->
            <div class="attendance-date-shift-grid">
              <div class="attendance-col-fecha flex flex-col gap-space-xs">
                <label
                  class="font-label-lg text-label-lg text-on-surface font-semibold flex items-center gap-1.5"
                  for="fechaInput"
                >
                  <span class="material-symbols-outlined text-primary text-[18px]">event</span>
                  Fecha:
                </label>
                <div class="relative">
                  <input
                    id="fechaInput"
                    v-model="form.dateIso"
                    class="w-full !h-11 !min-h-0 !px-space-md !py-0 !rounded-lg bg-surface-container-low text-on-surface font-body-md !text-[14px] focus:outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary shadow-inner border border-transparent"
                    required
                    type="date"
                  />
                </div>
              </div>

              <div class="attendance-col-turno flex flex-col gap-space-xs">
                <label
                  class="font-label-lg text-label-lg text-on-surface font-semibold flex items-center gap-1.5"
                  for="turnoSelect"
                >
                  <span class="material-symbols-outlined text-primary text-[18px]">schedule</span>
                  Turno:
                </label>
                <div class="relative">
                  <select
                    id="turnoSelect"
                    v-model="form.shift"
                    class="w-full !h-11 !min-h-0 !pl-space-md !pr-10 !py-0 !rounded-lg bg-surface-container-low text-on-surface font-body-md !text-[14px] focus:outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary appearance-none cursor-pointer border border-transparent"
                  >
                    <option value="Matutino">Matutino</option>
                    <option value="Vespertino">Vespertino</option>
                  </select>
                  <span
                    class="material-symbols-outlined absolute right-3 top-3 text-on-surface-variant text-[20px] pointer-events-none"
                  >
                    expand_more
                  </span>
                </div>
              </div>
            </div>

            <!-- Row 2: Nombre del Visitante -->
            <div class="flex flex-col gap-space-xs">
              <label
                class="font-label-lg text-label-lg text-on-surface font-semibold flex items-center gap-1.5"
                for="usuarioSearchInput"
              >
                <span class="material-symbols-outlined text-primary text-[18px]">person</span>
                Nombre del Visitante:
              </label>
              <div class="relative">
                <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <span class="material-symbols-outlined text-primary text-[20px]">badge</span>
                </div>
                <input
                  id="usuarioSearchInput"
                  v-model="form.visitorInput"
                  autocomplete="off"
                  class="w-full !h-11 !min-h-0 !pl-11 !pr-space-md !py-0 !rounded-lg bg-surface-container-low text-on-surface font-body-md !text-[14px] focus:outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary shadow-inner border border-transparent"
                  placeholder="Ej. Juan Carlos Pérez Morales o matrícula (20570142, DOC-0841)"
                  required
                  type="text"
                />
              </div>
            </div>

            <!-- Row 3: Servicio / Motivo -->
            <div class="flex flex-col gap-space-xs">
              <span class="font-label-lg text-label-lg text-on-surface font-semibold flex items-center gap-1.5">
                <span class="material-symbols-outlined text-primary text-[18px]">category</span>
                Servicio / Motivo:
              </span>
              <div class="flex flex-wrap gap-2.5 pt-1">
                <button
                  v-for="option in SERVICE_OPTIONS"
                  :key="option.name"
                  type="button"
                  :class="[
                    'px-5 py-2.5 rounded-lg font-label-lg text-label-lg font-medium transition-all flex items-center gap-2',
                    form.service === option.name
                      ? 'shadow-md bg-primary text-on-primary'
                      : 'shadow-sm bg-surface-container text-on-surface hover:bg-surface-container-high',
                  ]"
                  @click="selectService(option.name)"
                >
                  <span class="material-symbols-outlined text-[18px]">{{ option.icon }}</span>
                  <span>{{ option.name }}</span>
                </button>
              </div>
            </div>

            <!-- Row 4: Nota / Observaciones -->
            <div class="flex flex-col gap-space-xs">
              <label
                class="font-label-lg text-label-lg text-on-surface font-semibold flex items-center gap-1.5"
                for="notaObservacionInput"
              >
                <span class="material-symbols-outlined text-primary text-[18px]">notes</span>
                Nota / Observaciones:
              </label>
              <div class="relative">
                <input
                  id="notaObservacionInput"
                  v-model="form.note"
                  autocomplete="off"
                  class="w-full !h-11 !min-h-0 !px-space-md !py-0 !rounded-lg bg-surface-container-low text-on-surface font-body-md !text-[14px] focus:outline-none focus:bg-surface-container-lowest focus:ring-2 focus:ring-primary shadow-inner border border-transparent"
                  placeholder="Ej. Préstamo de equipo, consulta específica de tesis, etc. (Opcional)"
                  type="text"
                />
              </div>
            </div>

            <!-- Row 5: Registrar grupo & Cantidad -->
            <div class="flex flex-wrap items-center gap-space-md pt-1 pb-1">
              <label class="flex items-center gap-space-sm cursor-pointer select-none">
                <input
                  id="registrarGrupoCheck"
                  v-model="form.isGroup"
                  class="!w-5 !h-5 !min-h-0 !p-0 rounded text-primary focus:ring-primary focus:ring-offset-0 bg-surface-container cursor-pointer accent-[#002351]"
                  type="checkbox"
                  @change="handleGroupToggle"
                />
                <span class="font-label-lg text-label-lg text-on-surface font-medium">Registrar grupo</span>
              </label>

              <div class="flex items-center gap-space-xs">
                <label class="font-body-md text-body-md text-on-surface-variant" for="cantidadGrupoInput">
                  Cantidad:
                </label>
                <input
                  id="cantidadGrupoInput"
                  v-model.number="form.groupCount"
                  class="!w-20 !h-10 !min-h-0 !px-space-sm !py-0 text-center !rounded-lg bg-surface-container-low text-on-surface font-label-lg !text-[14px] focus:outline-none focus:ring-2 focus:ring-primary shadow-inner border border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                  :disabled="!form.isGroup"
                  max="60"
                  min="1"
                  type="number"
                />
              </div>
            </div>

            <!-- Main Action Submit Button -->
            <div>
              <button
                class="w-full h-12 rounded-lg bg-primary hover:bg-primary-container text-on-primary font-headline-sm text-headline-sm font-semibold shadow-md flex items-center justify-center gap-space-sm transition-all duration-150 transform active:scale-[0.99]"
                type="submit"
              >
                <span class="material-symbols-outlined text-[22px]">how_to_reg</span>
                <span>Registrar Visita</span>
              </button>
            </div>
          </form>
        </section>

        <!-- Bottom Section: 'Historial de Visitas Registradas' -->
        <section class="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex flex-col gap-space-md p-space-lg">
          <!-- Table Header & Metric Chips Row -->
          <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-space-md">
            <div>
              <div class="flex items-center gap-space-sm">
                <span class="material-symbols-outlined text-primary text-[24px]">history</span>
                <h3 class="font-headline-md !text-[22px] text-primary font-semibold">
                  Historial de Visitas Registradas
                </h3>
              </div>
              <p class="font-body-sm text-body-sm !text-on-surface-variant !max-w-none mt-0.5">
                Auditoría en tiempo real para acreditaciones y reportes del Tecnológico de Monclova.
              </p>
            </div>

            <!-- Metric Pills -->
            <div class="flex items-center gap-space-sm flex-wrap">
              <div class="bg-surface-container-low px-space-md py-2 rounded-lg flex items-center gap-2 shadow-inner">
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase font-semibold">
                  Total periodo:
                </span>
                <span class="font-headline-sm text-headline-sm text-primary font-bold">{{ totalCount }}</span>
              </div>
              <div class="bg-surface-container-low px-space-md py-2 rounded-lg flex items-center gap-2 shadow-inner">
                <span class="w-2.5 h-2.5 rounded-full bg-amber-500"></span>
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase font-semibold">
                  Matutino:
                </span>
                <span class="font-headline-sm text-headline-sm text-on-surface font-bold">{{ matutinoCount }}</span>
              </div>
              <div class="bg-surface-container-low px-space-md py-2 rounded-lg flex items-center gap-2 shadow-inner">
                <span class="w-2.5 h-2.5 rounded-full bg-indigo-500"></span>
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase font-semibold">
                  Vespertino:
                </span>
                <span class="font-headline-sm text-headline-sm text-on-surface font-bold">{{ vespertinoCount }}</span>
              </div>
            </div>
          </div>

          <!-- Time Period Filter Bar -->
          <div class="bg-surface-container-low p-space-md rounded-xl flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            <div class="flex flex-wrap items-center gap-4">
              <div class="flex flex-wrap items-center gap-2">
                <span class="font-label-lg text-label-lg text-primary font-bold flex items-center gap-1.5 shrink-0">
                  <span class="material-symbols-outlined text-[18px]">date_range</span>
                  Periodo de consulta:
                </span>
                <div class="flex flex-wrap items-center gap-2">
                  <input
                    id="filtroDesde"
                    v-model="filterFrom"
                    class="!w-auto !h-10 !min-h-0 !px-3 !py-0 !rounded-lg bg-surface-container-lowest text-on-surface font-body-sm !text-[12px] focus:outline-none focus:ring-2 focus:ring-primary shadow-sm border border-transparent"
                    aria-label="Fecha inicial"
                    type="date"
                    @input="onManualDateInput"
                  />
                  <span class="font-body-sm text-body-sm text-on-surface-variant">al</span>
                  <input
                    id="filtroHasta"
                    v-model="filterTo"
                    class="!w-auto !h-10 !min-h-0 !px-3 !py-0 !rounded-lg bg-surface-container-lowest text-on-surface font-body-sm !text-[12px] focus:outline-none focus:ring-2 focus:ring-primary shadow-sm border border-transparent"
                    aria-label="Fecha final"
                    type="date"
                    @input="onManualDateInput"
                  />
                </div>
                <button
                  class="h-10 px-4 rounded-lg bg-primary text-on-primary font-label-lg text-label-lg hover:bg-primary-container transition-colors shadow-sm flex items-center gap-1.5 shrink-0"
                  type="button"
                  @click="applyDateFilter"
                >
                  <span class="material-symbols-outlined text-[18px]">filter_alt</span>
                  <span>Filtrar</span>
                </button>
              </div>

              <div class="flex items-center gap-1 bg-surface-container-lowest p-1 rounded-lg shadow-sm">
                <button
                  type="button"
                  :class="[
                    'px-3 py-1 rounded text-[12px] font-semibold transition-colors',
                    activePreset === 'hoy'
                      ? 'bg-primary text-on-primary'
                      : 'text-on-surface-variant hover:bg-surface-container',
                  ]"
                  @click="setFilterPreset('hoy')"
                >
                  Hoy
                </button>
                <button
                  type="button"
                  :class="[
                    'px-3 py-1 rounded text-[12px] font-semibold transition-colors',
                    activePreset === 'semana'
                      ? 'bg-primary text-on-primary'
                      : 'text-on-surface-variant hover:bg-surface-container',
                  ]"
                  @click="setFilterPreset('semana')"
                >
                  Semana
                </button>
                <button
                  type="button"
                  :class="[
                    'px-3 py-1 rounded text-[12px] font-semibold transition-colors',
                    activePreset === 'mes'
                      ? 'bg-primary text-on-primary'
                      : 'text-on-surface-variant hover:bg-surface-container',
                  ]"
                  @click="setFilterPreset('mes')"
                >
                  Mes
                </button>
              </div>
            </div>

            <div class="flex items-center gap-2 shrink-0 self-end lg:self-center">
              <button
                class="h-10 px-4 rounded-lg bg-surface-container-lowest hover:bg-surface-container text-primary font-label-lg text-label-lg shadow-sm transition-all flex items-center gap-1.5"
                title="Exportar asistencias a hoja de cálculo"
                type="button"
                @click="exportToCSV"
              >
                <span class="material-symbols-outlined text-emerald-700 text-[18px]">download</span>
                <span>Exportar CSV</span>
              </button>
            </div>
          </div>

          <!-- Attendance Table Container -->
          <div class="overflow-x-auto rounded-lg">
            <table id="visitasTable" class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-surface-container-low text-on-surface-variant font-label-md text-label-md uppercase tracking-wider">
                  <th class="!py-space-md !px-space-md">Fecha</th>
                  <th class="!py-space-md !px-space-md">Hora</th>
                  <th class="!py-space-md !px-space-md">Matrícula</th>
                  <th class="!py-space-md !px-space-md">Nombre</th>
                  <th class="!py-space-md !px-space-md">Carrera</th>
                  <th class="!py-space-md !px-space-md">Servicio</th>
                  <th class="!py-space-md !px-space-md text-center">Acción</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-surface-container-low font-body-md text-body-md text-on-surface">
                <tr v-if="paginatedVisits.length === 0">
                  <td colspan="7" class="!py-10 !px-space-md text-center text-on-surface-variant text-sm">
                    No hay visitas registradas en el periodo seleccionado.
                  </td>
                </tr>
                <tr
                  v-for="visit in paginatedVisits"
                  :key="visit.id"
                  :class="[
                    'hover:bg-surface-container-low/60 transition-colors',
                    visit.isNew ? 'bg-surface-container-low/80' : '',
                  ]"
                >
                  <td class="!py-3 !px-space-md font-body-sm text-body-sm text-on-surface-variant whitespace-nowrap">
                    {{ formatDisplayDate(visit.dateIso) }}
                  </td>
                  <td class="!py-3 !px-space-md font-label-md text-label-md text-primary font-semibold whitespace-nowrap">
                    {{ visit.timeLabel }}
                  </td>
                  <td class="!py-3 !px-space-md font-citation-code text-citation-code font-medium text-on-surface whitespace-nowrap">
                    {{ visit.matricula }}
                  </td>
                  <td class="!py-3 !px-space-md">
                    <div class="font-label-lg text-label-lg text-on-surface font-semibold">{{ visit.nombre }}</div>
                    <div v-if="visit.nota" class="font-body-sm text-[11px] text-on-surface-variant mt-0.5">
                      {{ visit.nota }}
                    </div>
                  </td>
                  <td class="!py-3 !px-space-md text-on-surface-variant">
                    <span class="inline-block bg-surface-container px-2 py-0.5 rounded text-[12px]">
                      {{ visit.carrera }}
                    </span>
                  </td>
                  <td class="!py-3 !px-space-md whitespace-nowrap">
                    <span
                      :class="[
                        'inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[12px] font-semibold',
                        SERVICE_META[visit.servicio].badgeClass,
                      ]"
                    >
                      <span :class="['w-1.5 h-1.5 rounded-full', SERVICE_META[visit.servicio].dotClass]"></span>
                      <span>{{ visit.servicio }}</span>
                    </span>
                  </td>
                  <td class="!py-3 !px-space-md text-center">
                    <button
                      class="w-8 h-8 rounded-full hover:bg-error-container text-on-surface-variant hover:text-error inline-flex items-center justify-center transition-colors"
                      title="Anular o cancelar registro"
                      aria-label="Anular registro de visita"
                      type="button"
                      @click="handleDeleteVisit(visit)"
                    >
                      <span class="material-symbols-outlined text-[18px]">cancel</span>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Table Footer: Pagination & Records Summary -->
          <div class="flex flex-col sm:flex-row items-center justify-between gap-space-md pt-space-sm">
            <div class="font-body-sm text-body-sm text-on-surface-variant">
              Mostrando
              <span class="font-semibold text-on-surface">{{ rangeStart }} - {{ rangeEnd }}</span>
              de
              <span class="font-semibold text-on-surface">{{ totalCount }}</span>
              visitas registradas
            </div>

            <div class="flex items-center gap-1 bg-surface-container-low p-1 rounded-lg">
              <button
                class="w-8 h-8 rounded flex items-center justify-center text-on-surface-variant hover:bg-surface-container-lowest transition-colors disabled:opacity-40"
                :disabled="currentPage <= 1"
                title="Página anterior"
                aria-label="Página anterior"
                type="button"
                @click="currentPage = Math.max(1, currentPage - 1)"
              >
                <span class="material-symbols-outlined text-[18px]">chevron_left</span>
              </button>
              <button
                v-for="page in pageNumbers"
                :key="page"
                type="button"
                :class="[
                  'w-8 h-8 rounded flex items-center justify-center font-label-md text-label-md font-semibold transition-colors',
                  currentPage === page
                    ? 'bg-primary text-on-primary shadow-sm'
                    : 'text-on-surface hover:bg-surface-container-lowest',
                ]"
                @click="currentPage = page"
              >
                {{ page }}
              </button>
              <button
                class="w-8 h-8 rounded flex items-center justify-center text-on-surface-variant hover:bg-surface-container-lowest transition-colors disabled:opacity-40"
                :disabled="currentPage >= totalPages"
                title="Página siguiente"
                aria-label="Página siguiente"
                type="button"
                @click="currentPage = Math.min(totalPages, currentPage + 1)"
              >
                <span class="material-symbols-outlined text-[18px]">chevron_right</span>
              </button>
            </div>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<style scoped>
/* Isolated grid to avoid collision with global.css .grid */
.attendance-date-shift-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1rem;
}

@media (min-width: 768px) {
  .attendance-date-shift-grid {
    grid-template-columns: repeat(12, minmax(0, 1fr));
  }

  .attendance-col-fecha {
    grid-column: span 7 / span 7;
  }

  .attendance-col-turno {
    grid-column: span 5 / span 5;
  }
}
</style>
