<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

type ShiftType = 'Matutino' | 'Vespertino' | 'Sin actividad'
type CareerKey =
  | 'industrial'
  | 'mecanica'
  | 'electronica'
  | 'renovables'
  | 'gestion'
  | 'informatica'
  | 'mecatronica'

interface DayAttendanceRow {
  id: string
  week: 1 | 2
  dayNumber: string
  dayLabel: string
  monthShort: string
  men: number
  women: number
  docentes: number
  administrativos: number
  alumnos: number
  careers: Record<CareerKey, number>
  services: Record<string, number>
  shift: ShiftType
}

const CAREER_COLUMNS: { key: CareerKey; shortLabel: string; label: string; badgeClass: string }[] = [
  {
    key: 'industrial',
    shortLabel: 'Indust.',
    label: 'Ing. Industrial',
    badgeClass: 'bg-primary/10 text-primary border border-primary/20',
  },
  {
    key: 'mecanica',
    shortLabel: 'Mecán.',
    label: 'Ing. Mecánica',
    badgeClass: 'bg-surface-tint/10 text-surface-tint border border-surface-tint/20',
  },
  {
    key: 'electronica',
    shortLabel: 'Electr.',
    label: 'Ing. Electrónica',
    badgeClass: 'bg-primary/10 text-primary border border-primary/20',
  },
  {
    key: 'renovables',
    shortLabel: 'Renov.',
    label: 'Ing. Energías Renovables',
    badgeClass: 'bg-emerald-50 text-emerald-700 border border-emerald-200',
  },
  {
    key: 'gestion',
    shortLabel: 'Gestión',
    label: 'Ing. Gestión Empresarial',
    badgeClass: 'bg-secondary-container/50 text-secondary border border-secondary-container',
  },
  {
    key: 'informatica',
    shortLabel: 'Inform.',
    label: 'Ing. Informática',
    badgeClass: 'bg-primary/10 text-primary border border-primary/20',
  },
  {
    key: 'mecatronica',
    shortLabel: 'Mecatr.',
    label: 'Ing. Mecatrónica',
    badgeClass: 'bg-surface-tint/10 text-surface-tint border border-surface-tint/20',
  },
]

const MONTH_OPTIONS = [
  { value: 'AGOSTO', label: 'Agosto', short: 'Ago' },
  { value: 'SEPTIEMBRE', label: 'Septiembre', short: 'Sep' },
  { value: 'OCTUBRE', label: 'Octubre', short: 'Oct' },
  { value: 'NOVIEMBRE', label: 'Noviembre', short: 'Nov' },
  { value: 'DICIEMBRE', label: 'Diciembre', short: 'Dic' },
]

const emptyCareers = (): Record<CareerKey, number> => ({
  industrial: 0,
  mecanica: 0,
  electronica: 0,
  renovables: 0,
  gestion: 0,
  informatica: 0,
  mecatronica: 0,
})

const initialRows: DayAttendanceRow[] = [
  // Semana 1
  {
    id: '2026-08-03',
    week: 1,
    dayNumber: '03',
    dayLabel: 'Lunes 3',
    monthShort: 'Ago 2026',
    men: 2,
    women: 1,
    docentes: 1,
    administrativos: 0,
    alumnos: 1,
    careers: { ...emptyCareers(), industrial: 1 },
    services: { 'Fís': 2, 'Mtto': 1 },
    shift: 'Matutino',
  },
  {
    id: '2026-08-04',
    week: 1,
    dayNumber: '04',
    dayLabel: 'Martes 4',
    monthShort: 'Ago 2026',
    men: 1,
    women: 2,
    docentes: 0,
    administrativos: 2,
    alumnos: 1,
    careers: { ...emptyCareers(), gestion: 1 },
    services: { 'Virtual': 1 },
    shift: 'Vespertino',
  },
  {
    id: '2026-08-05',
    week: 1,
    dayNumber: '05',
    dayLabel: 'Miércoles 5',
    monthShort: 'Ago 2026',
    men: 3,
    women: 0,
    docentes: 0,
    administrativos: 1,
    alumnos: 0,
    careers: { ...emptyCareers(), gestion: 2 },
    services: { 'Reun': 2, 'Mtto': 1 },
    shift: 'Matutino',
  },
  {
    id: '2026-08-06',
    week: 1,
    dayNumber: '06',
    dayLabel: 'Jueves 6',
    monthShort: 'Ago 2026',
    men: 3,
    women: 1,
    docentes: 0,
    administrativos: 0,
    alumnos: 4,
    careers: { ...emptyCareers(), mecanica: 1, gestion: 3 },
    services: { 'Fís': 3, 'Mtto': 1 },
    shift: 'Matutino',
  },
  {
    id: '2026-08-07',
    week: 1,
    dayNumber: '07',
    dayLabel: 'Viernes 7',
    monthShort: 'Ago 2026',
    men: 0,
    women: 0,
    docentes: 0,
    administrativos: 0,
    alumnos: 0,
    careers: emptyCareers(),
    services: {},
    shift: 'Sin actividad',
  },
  // Semana 2
  {
    id: '2026-08-10',
    week: 2,
    dayNumber: '10',
    dayLabel: 'Lunes 10',
    monthShort: 'Ago 2026',
    men: 0,
    women: 4,
    docentes: 0,
    administrativos: 0,
    alumnos: 4,
    careers: { ...emptyCareers(), gestion: 4 },
    services: { 'Reunión': 4 },
    shift: 'Matutino',
  },
  {
    id: '2026-08-13',
    week: 2,
    dayNumber: '13',
    dayLabel: 'Jueves 13',
    monthShort: 'Ago 2026',
    men: 4,
    women: 4,
    docentes: 0,
    administrativos: 0,
    alumnos: 8,
    careers: { ...emptyCareers(), industrial: 5, gestion: 3 },
    services: { 'Reunión': 8 },
    shift: 'Matutino',
  },
  {
    id: '2026-08-14',
    week: 2,
    dayNumber: '14',
    dayLabel: 'Viernes 14',
    monthShort: 'Ago 2026',
    men: 1,
    women: 0,
    docentes: 0,
    administrativos: 1,
    alumnos: 0,
    careers: emptyCareers(),
    services: { 'Física': 1 },
    shift: 'Matutino',
  },
]

const CIRCUMFERENCE = 2 * Math.PI * 38 // ~238.76

const rows = ref<DayAttendanceRow[]>(
  initialRows.map((row) => ({
    ...row,
    careers: { ...row.careers },
    services: { ...row.services },
  })),
)
const selectedYear = ref('2026')
const selectedMonth = ref('AGOSTO')
const rangeMode = ref<'weeks' | 'month'>('weeks')
const searchFilter = ref('')
const showModalRegistro = ref(false)
const isSubmitting = ref(false)
const feedbackMessage = ref('')

const registrationForm = ref({
  date: '2026-08-03',
  shift: 'Matutino' as 'Matutino' | 'Vespertino',
  gender: 'H' as 'H' | 'M',
  area: 'Alumnos' as 'Alumnos' | 'Doc' | 'Adm',
  career: 'gestion' as CareerKey | 'NINGUNA',
  service: 'Reunión',
  controlNumber: '',
})

const selectedMonthMeta = computed(
  () => MONTH_OPTIONS.find((m) => m.value === selectedMonth.value) ?? MONTH_OPTIONS[0],
)

function rowTotal(row: DayAttendanceRow): number {
  return row.men + row.women
}

function formatServices(services: Record<string, number>): string {
  const entries = Object.entries(services).filter(([, count]) => count > 0)
  if (entries.length === 0) return '—'
  return entries.map(([label, count]) => `${count} ${label}`).join(', ')
}

function matchesSearch(row: DayAttendanceRow): boolean {
  const term = searchFilter.value.trim().toLowerCase()
  if (!term) return true
  const careerMatches = CAREER_COLUMNS.some(
    (col) => row.careers[col.key] > 0 && col.label.toLowerCase().includes(term),
  )
  const haystack = [
    row.dayLabel,
    row.dayNumber,
    row.monthShort,
    row.shift,
    formatServices(row.services),
  ]
    .join(' ')
    .toLowerCase()
  return haystack.includes(term) || careerMatches
}

const week1Rows = computed(() => rows.value.filter((r) => r.week === 1 && matchesSearch(r)))
const week2Rows = computed(() => rows.value.filter((r) => r.week === 2 && matchesSearch(r)))

function computeSubtotal(list: DayAttendanceRow[]) {
  const careers = emptyCareers()
  const services: Record<string, number> = {}
  let men = 0
  let women = 0
  let docentes = 0
  let administrativos = 0
  let alumnos = 0
  let matutino = 0
  let vespertino = 0

  for (const row of list) {
    const total = rowTotal(row)
    men += row.men
    women += row.women
    docentes += row.docentes
    administrativos += row.administrativos
    alumnos += row.alumnos
    if (row.shift === 'Matutino') matutino += total
    if (row.shift === 'Vespertino') vespertino += total
    for (const col of CAREER_COLUMNS) {
      careers[col.key] += row.careers[col.key]
    }
    for (const [key, count] of Object.entries(row.services)) {
      services[key] = (services[key] ?? 0) + count
    }
  }

  return {
    men,
    women,
    total: men + women,
    docentes,
    administrativos,
    alumnos,
    careers,
    servicesSummary: formatServices(services),
    matutino,
    vespertino,
  }
}

const week1Subtotal = computed(() => computeSubtotal(rows.value.filter((r) => r.week === 1)))
const week2Subtotal = computed(() => computeSubtotal(rows.value.filter((r) => r.week === 2)))
const grandTotal = computed(() => week1Subtotal.value.total + week2Subtotal.value.total)

// Donut chart metrics (derived from Semana 1 or all visible rows)
const activeMetricsScope = computed(() =>
  rangeMode.value === 'month' ? computeSubtotal(rows.value) : week1Subtotal.value,
)

const genderStats = computed(() => {
  const { men, women, total } = activeMetricsScope.value
  const menPct = total > 0 ? (men / total) * 100 : 0
  const womenPct = total > 0 ? (women / total) * 100 : 0
  return {
    men,
    women,
    total,
    menPct: menPct.toFixed(1),
    womenPct: womenPct.toFixed(1),
    menOffset: CIRCUMFERENCE * (1 - menPct / 100),
  }
})

const shiftStats = computed(() => {
  const { matutino, vespertino } = activeMetricsScope.value
  const total = matutino + vespertino
  const matPct = total > 0 ? (matutino / total) * 100 : 0
  const vespPct = total > 0 ? (vespertino / total) * 100 : 0
  return {
    matutino,
    vespertino,
    total,
    matPct: matPct.toFixed(1),
    vespPct: vespPct.toFixed(1),
    matOffset: CIRCUMFERENCE * (1 - matPct / 100),
  }
})

const careerStats = computed(() => {
  const { careers, total } = activeMetricsScope.value
  const gestion = careers.gestion
  const industrial = careers.industrial
  const mecanica = careers.mecanica
  const others = Math.max(0, total - gestion - industrial - mecanica)
  const denom = Math.max(1, total)

  const gestionPct = (gestion / denom) * 100
  const industrialPct = (industrial / denom) * 100
  const mecanicaPct = (mecanica / denom) * 100
  const othersPct = Math.max(0, 100 - gestionPct - industrialPct - mecanicaPct)

  const gestionLen = (gestionPct / 100) * CIRCUMFERENCE
  const mecanicaLen = (mecanicaPct / 100) * CIRCUMFERENCE
  const industrialLen = (industrialPct / 100) * CIRCUMFERENCE

  return {
    total,
    gestion,
    industrial,
    mecanica,
    others,
    gestionPct: gestionPct.toFixed(1),
    gestionPctInt: Math.round(gestionPct),
    industrialPctInt: Math.round(industrialPct),
    mecanicaPctInt: Math.round(mecanicaPct),
    othersPctInt: Math.round(othersPct),
    gestionDash: `${gestionLen.toFixed(2)} ${(CIRCUMFERENCE - gestionLen).toFixed(2)}`,
    mecanicaDash: `${mecanicaLen.toFixed(2)} ${(CIRCUMFERENCE - mecanicaLen).toFixed(2)}`,
    mecanicaOffset: (-gestionLen).toFixed(2),
    industrialDash: `${industrialLen.toFixed(2)} ${(CIRCUMFERENCE - industrialLen).toFixed(2)}`,
    industrialOffset: (-(gestionLen + mecanicaLen)).toFixed(2),
  }
})

function openModalRegistro() {
  showModalRegistro.value = true
}

function closeModalRegistro() {
  showModalRegistro.value = false
}

function guardarRegistro() {
  if (isSubmitting.value) return
  isSubmitting.value = true
  try {
    const form = registrationForm.value
    const dayStr = form.date.split('-')[2] ?? '03'
    const dayNum = Number(dayStr)
    const week: 1 | 2 = dayNum <= 7 ? 1 : 2

    let target = rows.value.find((row) => row.id === form.date)
    if (!target) {
      const weekdayNames = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado']
      const parsed = new Date(`${form.date}T12:00:00`)
      const weekday = weekdayNames[parsed.getDay()] ?? 'Día'
      target = {
        id: form.date,
        week,
        dayNumber: dayStr.padStart(2, '0'),
        dayLabel: `${weekday} ${dayNum}`,
        monthShort: `${selectedMonthMeta.value.short} ${selectedYear.value}`,
        men: 0,
        women: 0,
        docentes: 0,
        administrativos: 0,
        alumnos: 0,
        careers: emptyCareers(),
        services: {},
        shift: form.shift,
      }
      rows.value.push(target)
      rows.value.sort((a, b) => a.id.localeCompare(b.id))
    }

    if (form.gender === 'H') target.men += 1
    else target.women += 1

    if (form.area === 'Doc') target.docentes += 1
    else if (form.area === 'Adm') target.administrativos += 1
    else target.alumnos += 1

    if (form.career !== 'NINGUNA') {
      target.careers[form.career] += 1
    }

    target.services[form.service] = (target.services[form.service] ?? 0) + 1
    if (target.shift === 'Sin actividad') {
      target.shift = form.shift
    }

    showModalRegistro.value = false
    feedbackMessage.value = `Asistencia registrada con éxito en ${target.dayLabel} (${selectedMonthMeta.value.label} ${selectedYear.value}).`
    registrationForm.value.controlNumber = ''
  } finally {
    isSubmitting.value = false
  }
}

function exportSpreadsheet() {
  const headers = [
    'Semana',
    'Fecha',
    'Hombres',
    'Mujeres',
    'Docentes',
    'Administrativos',
    'Alumnos',
    ...CAREER_COLUMNS.map((c) => c.label),
    'Servicios',
    'Total',
    'Turno',
  ]
  const csvRows = [
    headers.join(','),
    ...rows.value.map((row) =>
      [
        `Semana ${row.week}`,
        `"${row.dayLabel} ${row.monthShort}"`,
        row.men,
        row.women,
        row.docentes,
        row.administrativos,
        row.alumnos,
        ...CAREER_COLUMNS.map((c) => row.careers[c.key]),
        `"${formatServices(row.services)}"`,
        rowTotal(row),
        `"${row.shift}"`,
      ].join(','),
    ),
  ]

  const blob = new Blob(['\uFEFF' + csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `Biblioteca_Asistencia_${selectedMonthMeta.value.label}_${selectedYear.value}.csv`
  link.click()
  URL.revokeObjectURL(url)

  feedbackMessage.value = `Archivo exportado: Biblioteca_Asistencia_${selectedMonthMeta.value.label}_${selectedYear.value}.csv`
}

function handleEscape(event: KeyboardEvent) {
  if (event.key === 'Escape' && showModalRegistro.value) {
    closeModalRegistro()
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleEscape)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleEscape)
})
</script>

<template>
  <div class="attendance-view flex flex-col flex-1 min-h-screen bg-background">
    <!-- Top Institutional Header -->
    <header class="w-full px-4 sm:px-8 pt-6 pb-4 flex flex-col gap-1 bg-surface-container-lowest shadow-[0_1px_8px_rgba(0,0,0,0.04)] border-b border-surface-container-high/60">
      <div class="max-w-[1520px] w-full mx-auto flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div class="flex flex-col">
          <span class="font-label-sm text-label-sm text-secondary uppercase font-semibold tracking-wider">
            Tecnológico Nacional de México • Campus Monclova
          </span>
          <h1 class="font-headline-lg !text-[26px] sm:!text-[30px] text-primary font-bold tracking-tight">
            Biblioteca Tec Monclova
          </h1>
        </div>
        <div class="flex items-center gap-2">
          <div class="flex items-center gap-2 bg-surface-container-low px-3.5 py-1.5 rounded-full border border-surface-container-high/60">
            <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
            <span class="font-label-sm text-label-sm text-on-surface-variant font-medium">
              Servicio Activo • Sala General
            </span>
          </div>
        </div>
      </div>
    </header>

    <main class="w-full flex-1 px-4 sm:px-8 py-6 bg-background">
      <div class="max-w-[1520px] mx-auto flex flex-col gap-6">
        <!-- Top Controls & Filters -->
        <div class="flex flex-col xl:flex-row xl:items-center justify-between gap-4 bg-surface-container-lowest p-4 rounded-xl shadow-sm border border-surface-container-high/60">
          <div class="flex items-center gap-3 flex-wrap">
            <div class="flex items-center gap-2.5 bg-surface-container-low px-3.5 py-2 rounded-lg">
              <span class="material-symbols-outlined text-secondary text-[20px]">calendar_today</span>
              <div class="flex flex-col">
                <span class="font-label-sm text-[10.5px] text-on-surface-variant uppercase tracking-wider">
                  Período Académico
                </span>
                <span class="font-headline-sm text-sm text-primary font-bold">
                  Agosto – Diciembre {{ selectedYear }}
                </span>
              </div>
            </div>

            <div class="flex items-center gap-2 flex-wrap">
              <div class="relative">
                <select
                  id="select-year"
                  v-model="selectedYear"
                  class="attendance-select appearance-none !w-auto !h-9 !min-h-0 bg-surface-container !pl-3.5 !pr-8 !py-0 !rounded-lg font-label-lg !text-xs text-primary font-semibold focus:outline-none focus:ring-2 focus:ring-secondary cursor-pointer border-0"
                  aria-label="Seleccionar año"
                >
                  <option value="2026">2026</option>
                  <option value="2025">2025</option>
                </select>
                <span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-[18px] text-on-surface-variant pointer-events-none">
                  expand_more
                </span>
              </div>

              <div class="relative">
                <select
                  id="select-month"
                  v-model="selectedMonth"
                  class="attendance-select appearance-none !w-auto !h-9 !min-h-0 bg-surface-container !pl-3.5 !pr-8 !py-0 !rounded-lg font-label-lg !text-xs text-primary font-semibold focus:outline-none focus:ring-2 focus:ring-secondary cursor-pointer border-0"
                  aria-label="Seleccionar mes"
                >
                  <option v-for="month in MONTH_OPTIONS" :key="month.value" :value="month.value">
                    {{ month.label }}
                  </option>
                </select>
                <span class="material-symbols-outlined absolute right-2 top-1/2 -translate-y-1/2 text-[18px] text-on-surface-variant pointer-events-none">
                  expand_more
                </span>
              </div>

              <div class="inline-flex rounded-lg p-1 bg-surface-container-low">
                <button
                  type="button"
                  :class="[
                    'px-3 py-1 rounded-md font-label-md text-label-md font-semibold flex items-center gap-1.5 transition-colors',
                    rangeMode === 'weeks'
                      ? 'bg-surface-container-lowest text-primary shadow-sm'
                      : 'text-on-surface-variant hover:text-primary',
                  ]"
                  @click="rangeMode = 'weeks'"
                >
                  <span class="material-symbols-outlined text-[16px]">bar_chart</span>
                  <span>Semana 1</span>
                </button>
                <button
                  type="button"
                  :class="[
                    'px-3 py-1 rounded-md font-label-md text-label-md font-semibold flex items-center gap-1.5 transition-colors',
                    rangeMode === 'month'
                      ? 'bg-surface-container-lowest text-primary shadow-sm'
                      : 'text-on-surface-variant hover:text-primary',
                  ]"
                  @click="rangeMode = 'month'"
                >
                  <span class="material-symbols-outlined text-[16px]">calendar_view_month</span>
                  <span>Acumulado</span>
                </button>
              </div>
            </div>
          </div>

          <!-- Quick Actions -->
          <div class="flex items-center gap-2.5 flex-wrap">
            <button
              type="button"
              class="px-4 py-2 rounded-lg bg-surface-container-low text-primary hover:bg-surface-container font-label-lg text-xs font-semibold flex items-center gap-1.5 transition-colors"
              @click="exportSpreadsheet"
            >
              <span class="material-symbols-outlined text-[18px]">download</span>
              <span>Exportar XLS</span>
            </button>
            <button
              type="button"
              class="px-5 py-2 rounded-lg bg-primary hover:bg-primary-container text-on-primary font-label-lg text-xs font-semibold flex items-center gap-1.5 shadow-sm transition-all"
              @click="openModalRegistro"
            >
              <span class="material-symbols-outlined text-[19px] text-secondary-fixed">person_add</span>
              <span>+ Añadir registro</span>
            </button>
          </div>
        </div>

        <!-- Feedback Notice -->
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

        <!-- 3 Bento Donut-Chart Metric Cards (isolated grid class to prevent global.css collision) -->
        <div class="attendance-metrics-grid">
          <!-- Card 1: Afluencia por Género -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm flex flex-col justify-between border border-surface-container-high/60">
            <div class="flex items-center justify-between">
              <div class="flex flex-col">
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wide">
                  Afluencia por Género
                </span>
                <span class="font-label-sm text-[11px] text-secondary font-semibold">
                  {{ rangeMode === 'month' ? 'Acumulado del Mes' : 'Semana 1 (Del 3-7 Ago)' }}
                </span>
              </div>
              <span class="w-8 h-8 rounded-lg bg-surface-container flex items-center justify-center text-primary">
                <span class="material-symbols-outlined text-[20px]">wc</span>
              </span>
            </div>

            <div class="mt-3 flex items-center justify-between gap-3">
              <div class="relative flex items-center justify-center w-24 h-24 shrink-0">
                <svg class="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="38" fill="none" stroke="#eff4ff" stroke-width="12" />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#fed488"
                    stroke-width="12"
                    :stroke-dasharray="CIRCUMFERENCE"
                    stroke-dashoffset="0"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#1b396a"
                    stroke-width="12"
                    :stroke-dasharray="CIRCUMFERENCE"
                    :stroke-dashoffset="genderStats.menOffset"
                    stroke-linecap="round"
                  />
                </svg>
                <div class="absolute flex flex-col items-center justify-center text-center">
                  <span class="font-headline-sm text-[18px] text-primary font-bold leading-none">
                    {{ genderStats.total }}
                  </span>
                  <span class="font-label-sm text-[10px] text-on-surface-variant leading-tight mt-0.5 font-medium">
                    Visitas
                  </span>
                </div>
              </div>

              <div class="flex flex-col gap-1.5 flex-1 font-label-sm text-[11px]">
                <div class="flex items-center justify-between p-1.5 bg-surface-container-low/50 rounded">
                  <span class="flex items-center gap-1.5 text-primary font-semibold truncate">
                    <span class="w-2.5 h-2.5 rounded-full bg-primary-container inline-block shrink-0"></span>
                    Hombres
                  </span>
                  <span class="font-bold text-primary shrink-0">
                    {{ genderStats.men }}
                    <span class="text-on-surface-variant font-normal">({{ genderStats.menPct }}%)</span>
                  </span>
                </div>
                <div class="flex items-center justify-between p-1.5 bg-surface-container-low/50 rounded">
                  <span class="flex items-center gap-1.5 text-secondary font-semibold truncate">
                    <span class="w-2.5 h-2.5 rounded-full bg-secondary-fixed-dim inline-block shrink-0"></span>
                    Mujeres
                  </span>
                  <span class="font-bold text-secondary shrink-0">
                    {{ genderStats.women }}
                    <span class="text-on-surface-variant font-normal">({{ genderStats.womenPct }}%)</span>
                  </span>
                </div>
              </div>
            </div>

            <div class="mt-3 pt-2.5 border-t border-surface-container flex items-center justify-between font-label-sm text-label-sm text-on-surface-variant">
              <span class="text-primary font-medium flex items-center gap-1 text-[11px]">
                <span class="material-symbols-outlined text-[15px] text-primary">groups</span>
                {{ genderStats.total }} usuarios registrados
              </span>
              <span class="text-secondary font-semibold text-[11px]">
                {{ rangeMode === 'month' ? 'Mes' : 'Semana 1' }}
              </span>
            </div>
          </div>

          <!-- Card 2: Distribución por Turno -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm flex flex-col justify-between border border-surface-container-high/60">
            <div class="flex items-center justify-between">
              <div class="flex flex-col">
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wide">
                  Distribución por Turno
                </span>
                <span class="font-label-sm text-[11px] text-secondary font-semibold">
                  Horario de atención
                </span>
              </div>
              <span class="w-8 h-8 rounded-lg bg-surface-container flex items-center justify-center text-primary">
                <span class="material-symbols-outlined text-[20px]">schedule</span>
              </span>
            </div>

            <div class="mt-3 flex items-center justify-between gap-3">
              <div class="relative flex items-center justify-center w-24 h-24 shrink-0">
                <svg class="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="38" fill="none" stroke="#eff4ff" stroke-width="12" />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#fed488"
                    stroke-width="12"
                    :stroke-dasharray="CIRCUMFERENCE"
                    stroke-dashoffset="0"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#1b396a"
                    stroke-width="12"
                    :stroke-dasharray="CIRCUMFERENCE"
                    :stroke-dashoffset="shiftStats.matOffset"
                    stroke-linecap="round"
                  />
                </svg>
                <div class="absolute flex flex-col items-center justify-center text-center">
                  <span class="font-headline-sm text-[16px] text-primary font-bold leading-none">
                    {{ shiftStats.matPct }}%
                  </span>
                  <span class="font-label-sm text-[10px] text-on-surface-variant leading-tight mt-0.5">
                    Matutino
                  </span>
                </div>
              </div>

              <div class="flex flex-col gap-1.5 flex-1 font-label-sm text-[11px]">
                <div class="flex items-center justify-between p-1.5 bg-surface-container-low/50 rounded">
                  <span class="flex items-center gap-1.5 text-primary font-semibold truncate">
                    <span class="w-2.5 h-2.5 rounded-full bg-primary-container inline-block shrink-0"></span>
                    Matutino
                  </span>
                  <span class="font-bold text-primary shrink-0">
                    {{ shiftStats.matutino }}
                    <span class="text-on-surface-variant font-normal">({{ shiftStats.matPct }}%)</span>
                  </span>
                </div>
                <div class="flex items-center justify-between p-1.5 bg-surface-container-low/50 rounded">
                  <span class="flex items-center gap-1.5 text-secondary font-semibold truncate">
                    <span class="w-2.5 h-2.5 rounded-full bg-secondary-fixed-dim inline-block shrink-0"></span>
                    Vespertino
                  </span>
                  <span class="font-bold text-secondary shrink-0">
                    {{ shiftStats.vespertino }}
                    <span class="text-on-surface-variant font-normal">({{ shiftStats.vespPct }}%)</span>
                  </span>
                </div>
              </div>
            </div>

            <div class="mt-3 pt-2.5 border-t border-surface-container flex items-center justify-between font-label-sm text-label-sm text-on-surface-variant">
              <span class="text-on-surface-variant text-[11px]">Sala General TecNM</span>
              <span class="text-secondary font-semibold text-[11px]">{{ shiftStats.total }} totales</span>
            </div>
          </div>

          <!-- Card 3: Afluencia por Carrera -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm flex flex-col justify-between border border-surface-container-high/60">
            <div class="flex items-center justify-between">
              <div class="flex flex-col">
                <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wide">
                  Afluencia por Carrera
                </span>
                <span class="font-label-sm text-[11px] text-secondary font-semibold">
                  Participación por Programa
                </span>
              </div>
              <span class="w-8 h-8 rounded-lg bg-secondary-container/50 flex items-center justify-center text-secondary">
                <span class="material-symbols-outlined text-[20px]">school</span>
              </span>
            </div>

            <div class="mt-3 flex items-center justify-between gap-3">
              <div class="relative flex items-center justify-center w-24 h-24 shrink-0">
                <svg class="w-24 h-24 transform -rotate-90" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="38" fill="none" stroke="#eff4ff" stroke-width="12" />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#747780"
                    stroke-width="12"
                    :stroke-dasharray="CIRCUMFERENCE"
                    stroke-dashoffset="0"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#fed488"
                    stroke-width="12"
                    :stroke-dasharray="careerStats.industrialDash"
                    :stroke-dashoffset="careerStats.industrialOffset"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#435e91"
                    stroke-width="12"
                    :stroke-dasharray="careerStats.mecanicaDash"
                    :stroke-dashoffset="careerStats.mecanicaOffset"
                  />
                  <circle
                    cx="50"
                    cy="50"
                    r="38"
                    fill="none"
                    stroke="#1b396a"
                    stroke-width="12"
                    :stroke-dasharray="careerStats.gestionDash"
                    stroke-dashoffset="0"
                  />
                </svg>
                <div class="absolute flex flex-col items-center justify-center text-center">
                  <span class="font-headline-sm text-[16px] text-primary font-bold leading-none">
                    {{ careerStats.gestionPct }}%
                  </span>
                  <span class="font-label-sm text-[10px] text-secondary font-semibold leading-tight mt-0.5">
                    Gestión
                  </span>
                </div>
              </div>

              <div class="flex flex-col gap-1 flex-1 font-label-sm text-[10.5px]">
                <div class="flex items-center justify-between">
                  <span class="flex items-center gap-1.5 text-primary font-semibold truncate">
                    <span class="w-2 h-2 rounded bg-primary-container inline-block shrink-0"></span>
                    Gestión Emp.
                  </span>
                  <span class="font-bold text-primary shrink-0">
                    {{ careerStats.gestion }}
                    <span class="text-on-surface-variant font-normal">({{ careerStats.gestionPctInt }}%)</span>
                  </span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="flex items-center gap-1.5 text-secondary font-semibold truncate">
                    <span class="w-2 h-2 rounded bg-secondary-container inline-block shrink-0"></span>
                    Industrial
                  </span>
                  <span class="font-bold text-secondary shrink-0">
                    {{ careerStats.industrial }}
                    <span class="text-on-surface-variant font-normal">({{ careerStats.industrialPctInt }}%)</span>
                  </span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="flex items-center gap-1.5 text-on-surface font-semibold truncate">
                    <span class="w-2 h-2 rounded bg-surface-tint inline-block shrink-0"></span>
                    Mecánica
                  </span>
                  <span class="font-bold text-on-surface shrink-0">
                    {{ careerStats.mecanica }}
                    <span class="text-on-surface-variant font-normal">({{ careerStats.mecanicaPctInt }}%)</span>
                  </span>
                </div>
                <div class="flex items-center justify-between">
                  <span class="flex items-center gap-1.5 text-outline font-semibold truncate">
                    <span class="w-2 h-2 rounded bg-outline inline-block shrink-0"></span>
                    Otras
                  </span>
                  <span class="font-bold text-on-surface-variant shrink-0">
                    {{ careerStats.others }}
                    <span class="text-on-surface-variant font-normal">({{ careerStats.othersPctInt }}%)</span>
                  </span>
                </div>
              </div>
            </div>

            <div class="mt-3 pt-2.5 border-t border-surface-container flex items-center justify-between font-label-sm text-label-sm text-secondary">
              <span class="flex items-center gap-1 font-semibold text-[11px]">
                <span class="material-symbols-outlined text-[15px]">trending_up</span>
                Líder: Ing. Gestión
              </span>
              <span class="text-on-surface-variant text-[11px]">{{ careerStats.total }} totales</span>
            </div>
          </div>
        </div>

        <!-- Spreadsheet Matrix Table Container -->
        <div class="bg-surface-container-lowest rounded-xl shadow-sm overflow-hidden flex flex-col border border-surface-container-high/70">
          <div class="px-5 py-4 bg-primary-container text-on-primary flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div class="flex items-center gap-3.5">
              <div class="w-10 h-10 rounded-lg bg-surface-container-lowest/10 flex items-center justify-center text-secondary-fixed shrink-0">
                <span class="material-symbols-outlined text-[24px]">event_available</span>
              </div>
              <div>
                <div class="flex items-center gap-2 flex-wrap">
                  <h2 class="font-headline-sm !text-base font-bold text-on-primary">Registro Mensual</h2>
                  <span class="px-2 py-0.5 rounded-full text-[11px] font-semibold bg-surface-container-lowest/20 text-on-primary">
                    {{ selectedMonthMeta.label }} {{ selectedYear }}
                  </span>
                </div>
                <span class="font-label-sm text-[12px] text-primary-fixed-dim">
                  Seguimiento de afluencia por semana, carrera y turno
                </span>
              </div>
            </div>

            <div class="flex items-center gap-2.5 flex-wrap">
              <div class="relative">
                <input
                  id="filter-search"
                  v-model="searchFilter"
                  class="attendance-search-input !h-9 !min-h-0 bg-primary/50 !text-on-primary placeholder:text-primary-fixed-dim !text-xs font-body-sm !rounded-lg !pl-8 !pr-3 !py-0 border border-white/15 focus:outline-none focus:bg-primary/80 transition-colors w-48 sm:w-60"
                  placeholder="Buscar día o carrera..."
                  type="text"
                  aria-label="Buscar día o carrera"
                />
                <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-[16px] text-primary-fixed-dim pointer-events-none">
                  search
                </span>
              </div>
              <div class="inline-flex rounded-lg p-0.5 bg-primary/40">
                <button
                  type="button"
                  :class="[
                    'px-2.5 py-1 rounded-md text-[12px] transition-colors',
                    rangeMode === 'weeks'
                      ? 'font-semibold bg-secondary text-on-secondary shadow-sm'
                      : 'font-medium text-primary-fixed-dim hover:text-on-primary',
                  ]"
                  @click="rangeMode = 'weeks'"
                >
                  Semana 1 &amp; 2
                </button>
                <button
                  type="button"
                  :class="[
                    'px-2.5 py-1 rounded-md text-[12px] transition-colors',
                    rangeMode === 'month'
                      ? 'font-semibold bg-secondary text-on-secondary shadow-sm'
                      : 'font-medium text-primary-fixed-dim hover:text-on-primary',
                  ]"
                  @click="rangeMode = 'month'"
                >
                  Mes Completo
                </button>
              </div>
            </div>
          </div>

          <!-- Sub-toolbar & Legend -->
          <div class="px-5 py-2 bg-surface-container-low/60 border-b border-surface-container flex flex-wrap items-center justify-between gap-3">
            <div class="flex items-center gap-3">
              <span class="px-3 py-1.5 border-b-2 border-primary text-primary font-semibold text-label-md flex items-center gap-1.5">
                <span class="material-symbols-outlined text-[16px]">view_list</span>
                <span>Desglose Diario</span>
              </span>
            </div>
            <div class="flex items-center flex-wrap gap-3 text-label-sm text-[11px] text-on-surface-variant">
              <span class="flex items-center gap-1.5">
                <span class="w-2.5 h-2.5 rounded-full bg-primary-container inline-block"></span>
                Hombres
              </span>
              <span class="flex items-center gap-1.5">
                <span class="w-2.5 h-2.5 rounded-full bg-secondary-fixed-dim inline-block"></span>
                Mujeres
              </span>
              <span class="flex items-center gap-1.5">
                <span class="w-2 h-2 rounded bg-emerald-600 inline-block"></span>
                Matutino
              </span>
              <span class="flex items-center gap-1.5">
                <span class="w-2 h-2 rounded bg-purple-700 inline-block"></span>
                Vespertino
              </span>
            </div>
          </div>

          <!-- Matrix Table -->
          <div class="overflow-x-auto w-full border-t border-surface-container">
            <table id="matrixTable" class="w-full text-left border-collapse text-[12px] font-body-sm">
              <thead class="bg-surface-container-low text-on-surface-variant font-label-sm border-b border-surface-container select-none">
                <tr>
                  <th rowspan="2" class="!py-2.5 !px-3 font-bold text-primary border-r border-surface-container text-left min-w-[140px] !bg-surface-container-low">
                    Día / Fecha
                  </th>
                  <th colspan="2" class="!py-1.5 !px-2 text-center font-bold text-primary border-r border-surface-container !bg-surface-container/60">
                    Género
                  </th>
                  <th colspan="3" class="!py-1.5 !px-2 text-center font-bold text-secondary border-r border-surface-container !bg-secondary-container/20">
                    Tipo de Usuario
                  </th>
                  <th colspan="7" class="!py-1.5 !px-2 text-center font-bold text-primary-container border-r border-surface-container !bg-primary-fixed/30">
                    Carreras
                  </th>
                  <th rowspan="2" class="!py-2.5 !px-2.5 text-center font-bold text-primary border-r border-surface-container min-w-[110px] !bg-surface-container-low">
                    Servicios
                  </th>
                  <th rowspan="2" class="!py-2.5 !px-3 text-center font-bold text-primary border-r border-surface-container w-16 !bg-surface-container/50">
                    Total
                  </th>
                  <th rowspan="2" class="!py-2.5 !px-3 text-center font-bold text-primary min-w-[110px] !bg-surface-container-low">
                    Turno
                  </th>
                </tr>
                <tr class="text-[11px] font-semibold text-on-surface-variant border-t border-surface-container/60">
                  <th class="!py-1 !px-2 text-center border-r border-surface-container !bg-surface-container/40 text-primary w-10">H</th>
                  <th class="!py-1 !px-2 text-center border-r border-surface-container !bg-surface-container/40 text-secondary w-10">M</th>
                  <th class="!py-1 !px-2 text-center border-r border-surface-container !bg-secondary-container/10 text-on-surface-variant w-11">Doc</th>
                  <th class="!py-1 !px-2 text-center border-r border-surface-container !bg-secondary-container/10 text-on-surface-variant w-11">Adm</th>
                  <th class="!py-1 !px-2 text-center border-r border-surface-container !bg-secondary-container/10 text-secondary w-11">Alum</th>
                  <th
                    v-for="col in CAREER_COLUMNS"
                    :key="col.key"
                    class="!py-1 !px-1.5 text-center border-r border-surface-container !bg-primary-fixed/20 text-primary w-12"
                  >
                    {{ col.shortLabel }}
                  </th>
                </tr>
              </thead>

              <tbody class="divide-y divide-surface-container-low text-on-surface bg-surface-container-lowest">
                <!-- Semana 1 Header -->
                <tr class="bg-surface-container-high/60 border-y border-surface-container">
                  <td colspan="16" class="!py-2 !px-3 font-headline-sm text-[12px] font-bold text-primary">
                    <div class="flex items-center gap-2">
                      <span class="material-symbols-outlined text-[17px] text-secondary">calendar_month</span>
                      <span>Semana 1 • Del 3 al 7 de {{ selectedMonthMeta.label }} {{ selectedYear }}</span>
                      <span class="ml-2 px-2 py-0.5 rounded text-[10px] font-semibold bg-primary text-on-primary">
                        {{ week1Subtotal.total }} registros
                      </span>
                    </div>
                  </td>
                </tr>

                <!-- Semana 1 Rows -->
                <tr
                  v-for="row in week1Rows"
                  :key="row.id"
                  :class="[
                    'hover:bg-surface-container-low/40 transition-colors',
                    rowTotal(row) === 0 ? 'opacity-75' : '',
                  ]"
                >
                  <td class="!py-2 !px-3 border-r border-surface-container">
                    <div class="flex items-center gap-2">
                      <span
                        :class="[
                          'w-7 h-7 rounded bg-surface-container flex items-center justify-center font-bold text-[12px] shrink-0',
                          rowTotal(row) === 0 ? 'text-outline' : 'text-primary',
                        ]"
                      >
                        {{ row.dayNumber }}
                      </span>
                      <div class="flex flex-col leading-tight">
                        <span
                          :class="[
                            'font-semibold text-[12px]',
                            rowTotal(row) === 0 ? 'text-on-surface-variant' : 'text-primary',
                          ]"
                        >
                          {{ row.dayLabel }}
                        </span>
                        <span class="text-[10px] text-on-surface-variant">{{ row.monthShort }}</span>
                      </div>
                    </div>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container font-bold text-primary bg-primary/5">
                    <span v-if="row.men > 0" class="inline-block px-1.5 py-0.5 rounded bg-primary text-on-primary font-bold text-[11px]">
                      {{ row.men }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container font-bold text-secondary bg-secondary/5">
                    <span v-if="row.women > 0" class="inline-block px-1.5 py-0.5 rounded bg-secondary-container text-on-secondary-container font-bold text-[11px]">
                      {{ row.women }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span v-if="row.docentes > 0" class="inline-block px-1.5 py-0.5 rounded bg-surface-container font-semibold text-[11px] text-primary">
                      {{ row.docentes }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span v-if="row.administrativos > 0" class="inline-block px-1.5 py-0.5 rounded bg-surface-container font-semibold text-[11px] text-on-surface-variant">
                      {{ row.administrativos }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span v-if="row.alumnos > 0" class="inline-block px-1.5 py-0.5 rounded bg-secondary-fixed text-on-secondary-fixed font-bold text-[11px]">
                      {{ row.alumnos }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td
                    v-for="col in CAREER_COLUMNS"
                    :key="col.key"
                    class="!py-2 !px-1.5 text-center border-r border-surface-container"
                  >
                    <span
                      v-if="row.careers[col.key] > 0"
                      :class="['inline-block px-1.5 py-0.5 rounded font-bold text-[11px]', col.badgeClass]"
                    >
                      {{ row.careers[col.key] }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span
                      v-if="formatServices(row.services) !== '—'"
                      class="px-1.5 py-0.5 rounded text-[11px] font-medium bg-surface-container text-on-surface-variant"
                    >
                      {{ formatServices(row.services) }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td
                    :class="[
                      '!py-2 !px-3 text-center border-r border-surface-container',
                      rowTotal(row) > 0 ? 'bg-primary-fixed/20' : 'bg-surface-container/30 text-on-surface-variant',
                    ]"
                  >
                    <span
                      :class="[
                        'inline-flex items-center justify-center px-2 py-0.5 rounded-full',
                        rowTotal(row) > 0 ? 'font-bold text-primary text-[12px]' : 'font-medium text-[11px]',
                      ]"
                    >
                      {{ rowTotal(row) }}
                    </span>
                  </td>

                  <td class="!py-2 !px-3 text-center">
                    <span
                      v-if="row.shift === 'Matutino'"
                      class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-50 text-emerald-800 border border-emerald-300"
                    >
                      <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span>
                      Matutino
                    </span>
                    <span
                      v-else-if="row.shift === 'Vespertino'"
                      class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-purple-50 text-purple-800 border border-purple-300"
                    >
                      <span class="w-1.5 h-1.5 rounded-full bg-purple-700"></span>
                      Vespertino
                    </span>
                    <span v-else class="text-[10px] text-on-surface-variant/60">Sin actividad</span>
                  </td>
                </tr>

                <!-- Subtotal Semana 1 -->
                <tr class="bg-surface-container-high font-bold border-y-2 border-primary/20 text-primary">
                  <td class="!py-2.5 !px-3 border-r border-surface-container">
                    <div class="flex items-center gap-1.5">
                      <span class="w-6 h-6 rounded bg-primary text-on-primary flex items-center justify-center text-[10px] shrink-0">
                        <span class="material-symbols-outlined text-[15px]">functions</span>
                      </span>
                      <span class="font-headline-sm text-[12px] font-bold">Σ Subtotal Sem 1</span>
                    </div>
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container bg-primary/10 text-primary font-extrabold text-[12px]">
                    {{ week1Subtotal.men }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container bg-secondary/10 text-secondary font-extrabold text-[12px]">
                    {{ week1Subtotal.women }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[11px] font-bold text-primary">
                    {{ week1Subtotal.docentes || '—' }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[11px] font-bold text-primary">
                    {{ week1Subtotal.administrativos || '—' }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[11px] font-bold text-secondary">
                    {{ week1Subtotal.alumnos || '—' }}
                  </td>
                  <td
                    v-for="col in CAREER_COLUMNS"
                    :key="`s1-${col.key}`"
                    class="!py-2.5 !px-1.5 text-center border-r border-surface-container text-[11px] font-bold"
                  >
                    <span v-if="week1Subtotal.careers[col.key] > 0">
                      {{ week1Subtotal.careers[col.key] }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[10px] font-semibold text-on-surface-variant">
                    {{ week1Subtotal.servicesSummary }}
                  </td>
                  <td class="!py-2.5 !px-3 text-center border-r border-surface-container bg-primary text-on-primary font-extrabold text-[12px]">
                    {{ week1Subtotal.total }}
                  </td>
                  <td class="!py-2.5 !px-3 text-center">
                    <span class="text-[10px] font-bold text-emerald-900 bg-emerald-100 px-2 py-0.5 rounded">
                      {{ week1Subtotal.matutino }} Mat / {{ week1Subtotal.vespertino }} Vesp
                    </span>
                  </td>
                </tr>

                <!-- Semana 2 Header -->
                <tr class="bg-surface-container-high/60 border-y border-surface-container">
                  <td colspan="16" class="!py-2 !px-3 font-headline-sm text-[12px] font-bold text-primary">
                    <div class="flex items-center gap-2">
                      <span class="material-symbols-outlined text-[17px] text-secondary">calendar_month</span>
                      <span>Semana 2 • Del 10 al 14 de {{ selectedMonthMeta.label }} {{ selectedYear }}</span>
                      <span class="ml-2 px-2 py-0.5 rounded text-[10px] font-semibold bg-primary text-on-primary">
                        {{ week2Subtotal.total }} registros
                      </span>
                    </div>
                  </td>
                </tr>

                <!-- Semana 2 Rows -->
                <tr
                  v-for="row in week2Rows"
                  :key="row.id"
                  class="hover:bg-surface-container-low/40 transition-colors"
                >
                  <td class="!py-2 !px-3 border-r border-surface-container">
                    <div class="flex items-center gap-2">
                      <span class="w-7 h-7 rounded bg-surface-container flex items-center justify-center font-bold text-primary text-[12px] shrink-0">
                        {{ row.dayNumber }}
                      </span>
                      <div class="flex flex-col leading-tight">
                        <span class="font-semibold text-primary text-[12px]">{{ row.dayLabel }}</span>
                        <span class="text-[10px] text-on-surface-variant">{{ row.monthShort }}</span>
                      </div>
                    </div>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container font-bold text-primary bg-primary/5">
                    <span v-if="row.men > 0" class="inline-block px-1.5 py-0.5 rounded bg-primary text-on-primary font-bold text-[11px]">
                      {{ row.men }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container font-bold text-secondary bg-secondary/5">
                    <span v-if="row.women > 0" class="inline-block px-1.5 py-0.5 rounded bg-secondary-container text-on-secondary-container font-bold text-[11px]">
                      {{ row.women }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span v-if="row.docentes > 0" class="inline-block px-1.5 py-0.5 rounded bg-surface-container font-semibold text-[11px] text-primary">
                      {{ row.docentes }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span v-if="row.administrativos > 0" class="inline-block px-1.5 py-0.5 rounded bg-surface-container font-semibold text-[11px] text-on-surface-variant">
                      {{ row.administrativos }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span v-if="row.alumnos > 0" class="inline-block px-1.5 py-0.5 rounded bg-secondary-fixed text-on-secondary-fixed font-bold text-[11px]">
                      {{ row.alumnos }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td
                    v-for="col in CAREER_COLUMNS"
                    :key="col.key"
                    class="!py-2 !px-1.5 text-center border-r border-surface-container"
                  >
                    <span
                      v-if="row.careers[col.key] > 0"
                      :class="['inline-block px-1.5 py-0.5 rounded font-bold text-[11px]', col.badgeClass]"
                    >
                      {{ row.careers[col.key] }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>

                  <td class="!py-2 !px-2 text-center border-r border-surface-container">
                    <span class="px-1.5 py-0.5 rounded text-[11px] font-medium bg-surface-container text-on-surface-variant">
                      {{ formatServices(row.services) }}
                    </span>
                  </td>

                  <td class="!py-2 !px-3 text-center border-r border-surface-container bg-primary-fixed/20">
                    <span class="inline-flex items-center justify-center px-2 py-0.5 rounded-full font-bold text-primary text-[12px]">
                      {{ rowTotal(row) }}
                    </span>
                  </td>

                  <td class="!py-2 !px-3 text-center">
                    <span
                      v-if="row.shift === 'Matutino'"
                      class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-50 text-emerald-800 border border-emerald-300"
                    >
                      <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span>
                      Matutino
                    </span>
                    <span
                      v-else
                      class="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-purple-50 text-purple-800 border border-purple-300"
                    >
                      <span class="w-1.5 h-1.5 rounded-full bg-purple-700"></span>
                      Vespertino
                    </span>
                  </td>
                </tr>

                <!-- Subtotal Semana 2 -->
                <tr class="bg-surface-container-high font-bold border-y-2 border-primary/20 text-primary">
                  <td class="!py-2.5 !px-3 border-r border-surface-container">
                    <div class="flex items-center gap-1.5">
                      <span class="w-6 h-6 rounded bg-primary text-on-primary flex items-center justify-center text-[10px] shrink-0">
                        <span class="material-symbols-outlined text-[15px]">functions</span>
                      </span>
                      <span class="font-headline-sm text-[12px] font-bold">Σ Subtotal Sem 2</span>
                    </div>
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container bg-primary/10 text-primary font-extrabold text-[12px]">
                    {{ week2Subtotal.men }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container bg-secondary/10 text-secondary font-extrabold text-[12px]">
                    {{ week2Subtotal.women }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[11px] font-bold text-primary">
                    {{ week2Subtotal.docentes || '—' }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[11px] font-bold text-primary">
                    {{ week2Subtotal.administrativos || '—' }}
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[11px] font-bold text-secondary">
                    {{ week2Subtotal.alumnos || '—' }}
                  </td>
                  <td
                    v-for="col in CAREER_COLUMNS"
                    :key="`s2-${col.key}`"
                    class="!py-2.5 !px-1.5 text-center border-r border-surface-container text-[11px] font-bold"
                  >
                    <span v-if="week2Subtotal.careers[col.key] > 0">
                      {{ week2Subtotal.careers[col.key] }}
                    </span>
                    <span v-else class="text-on-surface-variant/40">—</span>
                  </td>
                  <td class="!py-2.5 !px-2 text-center border-r border-surface-container text-[10px] font-semibold text-on-surface-variant">
                    {{ week2Subtotal.servicesSummary }}
                  </td>
                  <td class="!py-2.5 !px-3 text-center border-r border-surface-container bg-primary text-on-primary font-extrabold text-[12px]">
                    {{ week2Subtotal.total }}
                  </td>
                  <td class="!py-2.5 !px-3 text-center">
                    <span class="text-[10px] font-bold text-emerald-900 bg-emerald-100 px-2 py-0.5 rounded">
                      {{ week2Subtotal.vespertino > 0 ? `${week2Subtotal.matutino} Mat / ${week2Subtotal.vespertino} Vesp` : `${week2Subtotal.matutino} Matutino` }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Table Footer -->
          <div class="px-5 py-3 bg-surface-container-low flex flex-col sm:flex-row items-center justify-between text-on-surface-variant font-label-sm text-label-sm gap-3">
            <div class="flex items-center gap-2">
              <span class="material-symbols-outlined text-[18px] text-secondary">verified</span>
              <span>Datos validados con el Departamento de Servicios Escolares e Informática</span>
            </div>
            <div class="flex items-center gap-3">
              <span class="text-primary font-bold">
                {{ grandTotal }} Asistencias acumuladas en el período
              </span>
              <button
                type="button"
                class="px-3 py-1 rounded bg-surface-container text-primary hover:bg-surface-container-high transition-colors text-label-sm font-semibold flex items-center gap-1"
                title="Exportar hoja de cálculo"
                aria-label="Exportar hoja de cálculo"
                @click="exportSpreadsheet"
              >
                <span class="material-symbols-outlined text-[16px]">table_view</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal: Registrar Nueva Asistencia -->
    <div
      v-if="showModalRegistro"
      class="fixed inset-0 z-50 bg-primary/50 backdrop-blur-sm flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="modalRegistroTitle"
      @click.self="closeModalRegistro"
    >
      <div class="bg-surface-container-lowest rounded-xl max-w-xl w-full shadow-2xl overflow-hidden flex flex-col border border-surface-container-high">
        <div class="px-6 py-4 bg-primary text-on-primary flex items-center justify-between">
          <div class="flex items-center gap-2.5">
            <span class="material-symbols-outlined text-secondary-fixed">assignment_add</span>
            <h3 id="modalRegistroTitle" class="font-headline-sm !text-base font-bold text-on-primary">
              Registrar Nueva Asistencia
            </h3>
          </div>
          <button
            type="button"
            class="text-on-primary/70 hover:text-on-primary"
            aria-label="Cerrar"
            @click="closeModalRegistro"
          >
            <span class="material-symbols-outlined text-[24px]">close</span>
          </button>
        </div>

        <form class="p-6 flex flex-col gap-4" @submit.prevent="guardarRegistro">
          <div class="attendance-form-grid">
            <div class="flex flex-col gap-1">
              <label class="font-label-sm text-label-sm text-on-surface-variant font-semibold" for="regDate">
                Fecha del Servicio
              </label>
              <input
                id="regDate"
                v-model="registrationForm.date"
                class="attendance-input !h-10 !min-h-0 bg-surface-container-low !px-3 !py-0 !rounded-lg text-body-md font-body-md text-primary border border-outline-variant/40 focus:outline-none focus:ring-2 focus:ring-secondary"
                required
                type="date"
              />
            </div>

            <div class="flex flex-col gap-1">
              <label class="font-label-sm text-label-sm text-on-surface-variant font-semibold" for="regShift">
                Turno
              </label>
              <select
                id="regShift"
                v-model="registrationForm.shift"
                class="attendance-select !h-10 !min-h-0 bg-surface-container-low !px-3 !py-0 !rounded-lg text-body-md font-body-md text-primary border border-outline-variant/40 focus:outline-none focus:ring-2 focus:ring-secondary"
              >
                <option value="Matutino">Matutino</option>
                <option value="Vespertino">Vespertino</option>
              </select>
            </div>
          </div>

          <div class="attendance-form-grid">
            <div class="flex flex-col gap-1">
              <span class="font-label-sm text-label-sm text-on-surface-variant font-semibold">Género</span>
              <div class="flex gap-4 mt-1.5">
                <label class="flex items-center gap-2 text-body-md font-body-md cursor-pointer">
                  <input v-model="registrationForm.gender" class="text-primary focus:ring-secondary" name="genero" type="radio" value="H" />
                  Hombre
                </label>
                <label class="flex items-center gap-2 text-body-md font-body-md cursor-pointer">
                  <input v-model="registrationForm.gender" class="text-primary focus:ring-secondary" name="genero" type="radio" value="M" />
                  Mujer
                </label>
              </div>
            </div>

            <div class="flex flex-col gap-1">
              <label class="font-label-sm text-label-sm text-on-surface-variant font-semibold" for="regArea">
                Área
              </label>
              <select
                id="regArea"
                v-model="registrationForm.area"
                class="attendance-select !h-10 !min-h-0 bg-surface-container-low !px-3 !py-0 !rounded-lg text-body-md font-body-md text-primary border border-outline-variant/40 focus:outline-none focus:ring-2 focus:ring-secondary"
              >
                <option value="Alumnos">Alumno</option>
                <option value="Doc">Docente</option>
                <option value="Adm">Administrativo</option>
              </select>
            </div>
          </div>

          <div class="attendance-form-grid">
            <div class="flex flex-col gap-1">
              <label class="font-label-sm text-label-sm text-on-surface-variant font-semibold" for="regCareer">
                Carrera (si aplica)
              </label>
              <select
                id="regCareer"
                v-model="registrationForm.career"
                class="attendance-select !h-10 !min-h-0 bg-surface-container-low !px-3 !py-0 !rounded-lg text-body-md font-body-md text-primary border border-outline-variant/40 focus:outline-none focus:ring-2 focus:ring-secondary"
              >
                <option value="gestion">Ing. Gestión Empresarial</option>
                <option value="industrial">Ing. Industrial</option>
                <option value="mecanica">Ing. Mecánica</option>
                <option value="electronica">Ing. Electrónica</option>
                <option value="renovables">Ing. Energías Renovables</option>
                <option value="informatica">Ing. Informática</option>
                <option value="mecatronica">Ing. Mecatrónica</option>
                <option value="NINGUNA">Ninguna / Administrativo</option>
              </select>
            </div>

            <div class="flex flex-col gap-1">
              <label class="font-label-sm text-label-sm text-on-surface-variant font-semibold" for="regService">
                Servicio Prestado
              </label>
              <select
                id="regService"
                v-model="registrationForm.service"
                class="attendance-select !h-10 !min-h-0 bg-surface-container-low !px-3 !py-0 !rounded-lg text-body-md font-body-md text-primary border border-outline-variant/40 focus:outline-none focus:ring-2 focus:ring-secondary"
              >
                <option value="Física">Consulta Física</option>
                <option value="Virtual">Servicio Virtual</option>
                <option value="Reunión">Sala de Reunión</option>
                <option value="Clase">Clase / Asesoría</option>
                <option value="Mtto">Mantenimiento de Equipo</option>
                <option value="Otra">Otra</option>
              </select>
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="font-label-sm text-label-sm text-on-surface-variant font-semibold" for="regControl">
              No. de Control o Credencial ITSM
            </label>
            <input
              id="regControl"
              v-model="registrationForm.controlNumber"
              class="attendance-input !h-10 !min-h-0 bg-surface-container-low !px-3 !py-0 !rounded-lg text-body-md font-body-md text-primary border border-outline-variant/40 focus:outline-none focus:ring-2 focus:ring-secondary"
              placeholder="Ej. 21050234"
              type="text"
            />
          </div>

          <div class="flex items-center justify-end gap-2.5 mt-2 pt-3 border-t border-surface-container">
            <button
              type="button"
              class="px-4 py-2 rounded-lg bg-surface-container text-primary font-label-md text-label-md font-semibold hover:bg-surface-container-high transition-colors"
              :disabled="isSubmitting"
              @click="closeModalRegistro"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="px-5 py-2 rounded-lg bg-primary text-on-primary hover:bg-primary-container font-label-md text-label-md font-semibold shadow-sm transition-colors disabled:opacity-60"
              :disabled="isSubmitting"
            >
              Guardar Asistencia
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.attendance-metrics-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1rem;
}

@media (min-width: 768px) {
  .attendance-metrics-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1280px) {
  .attendance-metrics-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

.attendance-form-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1rem;
}

@media (min-width: 640px) {
  .attendance-form-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
