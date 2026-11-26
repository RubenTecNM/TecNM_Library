<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'

type PeriodKey = 'Hoy' | 'Semanal' | 'Mensual' | 'Ciclo'

interface WeeklyBarDay {
  label: string
  morning: number
  afternoon: number
  isPeak?: boolean
}

interface CareerUsage {
  name: string
  percent: number
  loans: number
  color: string
}

interface TopBook {
  rank: number
  title: string
  author: string
  loans: number
  dewey: string
}

interface PeriodSnapshot {
  visitsLabel: string
  totalAcervo: number
  visits: number
  activeLoans: number
  returnRate: string
  returnBadge: string
  peakText: string
  menCount: number
  womenCount: number
  weeklyBars: WeeklyBarDay[]
  careers: CareerUsage[]
  topBooks: TopBook[]
}

const PERIOD_OPTIONS: PeriodKey[] = ['Hoy', 'Semanal', 'Mensual', 'Ciclo']
const DONUT_CIRCUMFERENCE = 2 * Math.PI * 45 // ~282.74

const SNAPSHOTS: Record<PeriodKey, PeriodSnapshot> = {
  Hoy: {
    visitsLabel: 'Visitas de Hoy',
    totalAcervo: 5240,
    visits: 164,
    activeLoans: 85,
    returnRate: '99.1%',
    returnBadge: 'Óptimo',
    peakText: 'Hoy 11:30 hrs (54 alumnos)',
    menCount: 90,
    womenCount: 74,
    weeklyBars: [
      { label: 'Lun', morning: 92, afternoon: 28 },
      { label: 'Mar', morning: 112, afternoon: 36 },
      { label: 'Mié (Pico)', morning: 144, afternoon: 43, isPeak: true },
      { label: 'Jue', morning: 108, afternoon: 34 },
      { label: 'Vie', morning: 84, afternoon: 22 },
    ],
    careers: [
      { name: 'Ing. Gestión Empresarial', percent: 34, loans: 9, color: '#1b396a' },
      { name: 'Ing. Industrial', percent: 25, loans: 7, color: '#1b396a' },
      { name: 'Ing. Mecatrónica', percent: 15, loans: 4, color: '#1b396a' },
      { name: 'Ing. Informática / Sistemas', percent: 12, loans: 3, color: '#1b396a' },
      { name: 'Ing. Electrónica', percent: 6, loans: 2, color: '#435e91' },
      { name: 'Ing. Mecánica', percent: 5, loans: 1, color: '#435e91' },
      { name: 'Ing. Energías Renovables', percent: 3, loans: 1, color: '#c5a059' },
    ],
    topBooks: [
      { rank: 1, title: 'Cálculo Diferencial e Integral', author: 'James Stewart', loans: 8, dewey: '515.33' },
      { rank: 2, title: 'Ingeniería de Control Moderna', author: 'Katsuhiko Ogata', loans: 6, dewey: '629.8' },
      { rank: 3, title: 'Administración: Una Perspectiva Global', author: 'H. Koontz', loans: 5, dewey: '658' },
      { rank: 4, title: 'Circuitos Microelectrónicos', author: 'Sedra & Smith', loans: 4, dewey: '621.381' },
      { rank: 5, title: 'Física Universitaria Vol. 1', author: 'Sears & Zemansky', loans: 3, dewey: '530' },
    ],
  },
  Semanal: {
    visitsLabel: 'Visitas de la Semana',
    totalAcervo: 5240,
    visits: 580,
    activeLoans: 85,
    returnRate: '98.8%',
    returnBadge: 'Excelente',
    peakText: 'Miércoles 11:30 hrs (187 alumnos)',
    menCount: 318,
    womenCount: 262,
    weeklyBars: [
      { label: 'Lun', morning: 95, afternoon: 28 },
      { label: 'Mar', morning: 128, afternoon: 44 },
      { label: 'Mié (Pico)', morning: 148, afternoon: 49, isPeak: true },
      { label: 'Jue', morning: 114, afternoon: 36 },
      { label: 'Vie', morning: 86, afternoon: 23 },
    ],
    careers: [
      { name: 'Ing. Gestión Empresarial', percent: 31, loans: 19, color: '#1b396a' },
      { name: 'Ing. Industrial', percent: 27, loans: 16, color: '#1b396a' },
      { name: 'Ing. Mecatrónica', percent: 17, loans: 10, color: '#1b396a' },
      { name: 'Ing. Informática / Sistemas', percent: 11, loans: 7, color: '#1b396a' },
      { name: 'Ing. Electrónica', percent: 6, loans: 4, color: '#435e91' },
      { name: 'Ing. Mecánica', percent: 5, loans: 3, color: '#435e91' },
      { name: 'Ing. Energías Renovables', percent: 3, loans: 2, color: '#c5a059' },
    ],
    topBooks: [
      { rank: 1, title: 'Cálculo Diferencial e Integral', author: 'James Stewart', loans: 18, dewey: '515.33' },
      { rank: 2, title: 'Ingeniería de Control Moderna', author: 'Katsuhiko Ogata', loans: 15, dewey: '629.8' },
      { rank: 3, title: 'Administración: Una Perspectiva Global', author: 'H. Koontz', loans: 12, dewey: '658' },
      { rank: 4, title: 'Circuitos Microelectrónicos', author: 'Sedra & Smith', loans: 10, dewey: '621.381' },
      { rank: 5, title: 'Física Universitaria Vol. 1', author: 'Sears & Zemansky', loans: 9, dewey: '530' },
    ],
  },
  Mensual: {
    visitsLabel: 'Visitas del Mes',
    totalAcervo: 5240,
    visits: 1180,
    activeLoans: 85,
    returnRate: '98.1%',
    returnBadge: 'Excelente',
    peakText: 'Miércoles 11:30 hrs (174 alumnos)',
    menCount: 642,
    womenCount: 538,
    weeklyBars: [
      { label: 'Lun', morning: 90, afternoon: 26 },
      { label: 'Mar', morning: 120, afternoon: 40 },
      { label: 'Mié (Pico)', morning: 145, afternoon: 46, isPeak: true },
      { label: 'Jue', morning: 110, afternoon: 34 },
      { label: 'Vie', morning: 82, afternoon: 21 },
    ],
    careers: [
      { name: 'Ing. Gestión Empresarial', percent: 33, loans: 24, color: '#1b396a' },
      { name: 'Ing. Industrial', percent: 25, loans: 18, color: '#1b396a' },
      { name: 'Ing. Mecatrónica', percent: 16, loans: 12, color: '#1b396a' },
      { name: 'Ing. Informática / Sistemas', percent: 12, loans: 9, color: '#1b396a' },
      { name: 'Ing. Electrónica', percent: 6, loans: 4, color: '#435e91' },
      { name: 'Ing. Mecánica', percent: 5, loans: 4, color: '#435e91' },
      { name: 'Ing. Energías Renovables', percent: 3, loans: 2, color: '#c5a059' },
    ],
    topBooks: [
      { rank: 1, title: 'Cálculo Diferencial e Integral', author: 'James Stewart', loans: 34, dewey: '515.33' },
      { rank: 2, title: 'Ingeniería de Control Moderna', author: 'Katsuhiko Ogata', loans: 28, dewey: '629.8' },
      { rank: 3, title: 'Administración: Una Perspectiva Global', author: 'H. Koontz', loans: 23, dewey: '658' },
      { rank: 4, title: 'Circuitos Microelectrónicos', author: 'Sedra & Smith', loans: 19, dewey: '621.381' },
      { rank: 5, title: 'Física Universitaria Vol. 1', author: 'Sears & Zemansky', loans: 17, dewey: '530' },
    ],
  },
  Ciclo: {
    visitsLabel: 'Visitas del Mes',
    totalAcervo: 5240,
    visits: 1420,
    activeLoans: 85,
    returnRate: '98.4%',
    returnBadge: 'Excelente',
    peakText: 'Miércoles 11:30 hrs (187 alumnos)',
    menCount: 767,
    womenCount: 653,
    weeklyBars: [
      { label: 'Lun', morning: 95, afternoon: 28 },
      { label: 'Mar', morning: 129, afternoon: 44 },
      { label: 'Mié (Pico)', morning: 169, afternoon: 49, isPeak: true },
      { label: 'Jue', morning: 114, afternoon: 36 },
      { label: 'Vie', morning: 86, afternoon: 23 },
    ],
    careers: [
      { name: 'Ing. Gestión Empresarial', percent: 32, loans: 27, color: '#1b396a' },
      { name: 'Ing. Industrial', percent: 26, loans: 22, color: '#1b396a' },
      { name: 'Ing. Mecatrónica', percent: 16, loans: 14, color: '#1b396a' },
      { name: 'Ing. Informática / Sistemas', percent: 12, loans: 10, color: '#1b396a' },
      { name: 'Ing. Electrónica', percent: 6, loans: 5, color: '#435e91' },
      { name: 'Ing. Mecánica', percent: 5, loans: 4, color: '#435e91' },
      { name: 'Ing. Energías Renovables', percent: 3, loans: 3, color: '#c5a059' },
    ],
    topBooks: [
      { rank: 1, title: 'Cálculo Diferencial e Integral', author: 'James Stewart', loans: 42, dewey: '515.33' },
      { rank: 2, title: 'Ingeniería de Control Moderna', author: 'Katsuhiko Ogata', loans: 35, dewey: '629.8' },
      { rank: 3, title: 'Administración: Una Perspectiva Global', author: 'H. Koontz', loans: 29, dewey: '658' },
      { rank: 4, title: 'Circuitos Microelectrónicos', author: 'Sedra & Smith', loans: 24, dewey: '621.381' },
      { rank: 5, title: 'Física Universitaria Vol. 1', author: 'Sears & Zemansky', loans: 21, dewey: '530' },
    ],
  },
}

const router = useRouter()
const selectedPeriod = ref<PeriodKey>('Ciclo')
const feedbackMessage = ref('')

const snapshot = computed(() => SNAPSHOTS[selectedPeriod.value])

const barGeometry = computed(() => {
  const maxVal = 170
  const maxBarHeight = 135
  const baseline = 140
  return snapshot.value.weeklyBars.map((day, idx) => {
    const morningH = Math.max(8, Math.round((day.morning / maxVal) * maxBarHeight))
    const afternoonH = Math.max(8, Math.round((day.afternoon / maxVal) * maxBarHeight))
    return {
      ...day,
      x: 55 + idx * 90,
      morningH,
      morningY: baseline - morningH,
      afternoonH,
      afternoonY: baseline - afternoonH,
    }
  })
})

const genderDistribution = computed(() => {
  const men = snapshot.value.menCount
  const women = snapshot.value.womenCount
  const total = Math.max(1, men + women)
  const menRatio = men / total
  const womenRatio = women / total
  const menPct = Math.round(menRatio * 100)
  const womenPct = 100 - menPct
  const menOffset = Number((DONUT_CIRCUMFERENCE * (1 - menRatio)).toFixed(1))
  const womenOffset = Number((DONUT_CIRCUMFERENCE * (1 - womenRatio)).toFixed(1))
  const womenAngle = Number((menRatio * 360).toFixed(1))

  return {
    total: men + women,
    men,
    women,
    menPct,
    womenPct,
    menOffset,
    womenOffset,
    womenTransform: `rotate(${womenAngle} 60 60)`,
  }
})

function exportReport() {
  const s = snapshot.value
  const lines = [
    `Informe Ejecutivo Biblioteca TecNM Campus Monclova,Periodo: ${selectedPeriod.value}`,
    '',
    'Indicador,Valor',
    `Total Acervo,${s.totalAcervo}`,
    `${s.visitsLabel},${s.visits}`,
    `Préstamos Activos,${s.activeLoans}`,
    `Tasa de Devolución,${s.returnRate}`,
    '',
    'Carrera,Porcentaje,Préstamos',
    ...s.careers.map((c) => `"${c.name}",${c.percent}%,${c.loans}`),
    '',
    'Top Libros,Autor,Préstamos,Dewey',
    ...s.topBooks.map((b) => `"${b.title}","${b.author}",${b.loans},"${b.dewey}"`),
  ]

  const blob = new Blob(['\uFEFF' + lines.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `Informe_Dashboard_${selectedPeriod.value}_TecNM_Monclova.csv`
  link.click()
  URL.revokeObjectURL(url)

  feedbackMessage.value = `Informe exportado correctamente (${selectedPeriod.value}).`
}

function goToDemographicDetail() {
  router.push('/attendance')
}
</script>

<template>
  <div class="dashboard-view flex flex-col flex-1 min-h-screen bg-background">
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
      <div class="max-w-[1520px] mx-auto flex flex-col gap-6 pb-8">
        <!-- Encabezado de Contexto Ejecutivo -->
        <section class="flex flex-col lg:flex-row lg:items-end justify-between gap-4 bg-surface-container-lowest p-6 rounded-2xl shadow-sm border border-surface-container-high/60">
          <div class="flex flex-col gap-1">
            <div class="flex items-center gap-1.5">
              <span class="inline-block w-2 h-2 rounded-full bg-secondary"></span>
              <span class="font-label-sm text-label-sm text-secondary uppercase tracking-widest font-semibold">
                Indicadores Clave • TecNM Campus Monclova
              </span>
            </div>
            <h2 class="font-headline-lg !text-[24px] sm:!text-[28px] font-bold text-primary tracking-tight">
              Dashboard General
            </h2>
            <p class="font-body-md text-body-md !text-on-surface-variant !max-w-none">
              Resumen ejecutivo de acervo, circulación y afluencia semestral (Ago - Dic 2026).
            </p>
          </div>

          <!-- Controles de Periodo y Acción -->
          <div class="flex flex-wrap items-center gap-2.5">
            <div class="flex items-center bg-surface-container-low p-1 rounded-xl shadow-inner" role="tablist" aria-label="Periodo del dashboard">
              <button
                v-for="period in PERIOD_OPTIONS"
                :key="period"
                type="button"
                role="tab"
                :aria-selected="selectedPeriod === period"
                :class="[
                  'px-3.5 py-1.5 rounded-lg font-label-md text-label-md transition-all',
                  selectedPeriod === period
                    ? 'bg-surface-container-lowest text-primary font-semibold shadow-sm'
                    : 'text-on-surface-variant hover:text-primary',
                ]"
                @click="selectedPeriod = period"
              >
                {{ period }}
              </button>
            </div>
            <button
              type="button"
              class="flex items-center gap-1.5 bg-primary text-on-primary hover:bg-primary-container transition-all px-4 py-2 rounded-xl font-label-md text-label-md font-semibold shadow-sm"
              @click="exportReport"
            >
              <span class="material-symbols-outlined text-[18px]">sim_card_download</span>
              <span>Exportar Informe</span>
            </button>
          </div>
        </section>

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

        <!-- Fila Superior: 4 KPIs Ejecutivos -->
        <section class="dashboard-kpi-grid">
          <!-- KPI 1: Acervo -->
          <div class="flex flex-col justify-between p-5 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60 hover:shadow-md transition-shadow">
            <div class="flex flex-col gap-1 w-full">
              <div class="flex items-center justify-between w-full">
                <span class="font-label-md text-label-md text-on-surface-variant font-medium">Total Acervo</span>
                <div class="p-1.5 rounded-xl bg-surface-container-low text-primary">
                  <span class="material-symbols-outlined text-[24px]">menu_book</span>
                </div>
              </div>
              <div class="text-center py-3">
                <span class="font-display-hero text-[36px] xl:text-[40px] font-bold text-primary tracking-tight leading-none">
                  {{ snapshot.totalAcervo.toLocaleString('es-MX') }}
                </span>
              </div>
            </div>
          </div>

          <!-- KPI 2: Afluencia -->
          <div class="flex flex-col justify-between p-5 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60 hover:shadow-md transition-shadow">
            <div class="flex flex-col gap-1 w-full">
              <div class="flex items-center justify-between w-full">
                <span class="font-label-md text-label-md text-on-surface-variant font-medium">
                  {{ snapshot.visitsLabel }}
                </span>
                <div class="p-1.5 rounded-xl bg-surface-container-low text-secondary">
                  <span class="material-symbols-outlined text-[24px]">group</span>
                </div>
              </div>
              <div class="text-center py-3">
                <span class="font-display-hero text-[36px] xl:text-[40px] font-bold text-primary tracking-tight leading-none">
                  {{ snapshot.visits.toLocaleString('es-MX') }}
                </span>
              </div>
            </div>
          </div>

          <!-- KPI 3: Préstamos Activos -->
          <div class="flex flex-col justify-between p-5 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60 hover:shadow-md transition-shadow">
            <div class="flex flex-col gap-1 w-full">
              <div class="flex items-center justify-between w-full">
                <span class="font-label-md text-label-md text-on-surface-variant font-medium">Préstamos Activos</span>
                <div class="p-1.5 rounded-xl bg-surface-container-low text-primary-container">
                  <span class="material-symbols-outlined text-[24px]">assignment_turned_in</span>
                </div>
              </div>
              <div class="text-center py-3">
                <span class="font-display-hero text-[36px] xl:text-[40px] font-bold text-primary tracking-tight leading-none">
                  {{ snapshot.activeLoans }}
                </span>
              </div>
            </div>
          </div>

          <!-- KPI 4: Tasa de Retorno -->
          <div class="flex flex-col justify-between p-5 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60 hover:shadow-md transition-shadow">
            <div class="flex flex-col gap-1 w-full">
              <div class="flex items-center justify-between w-full">
                <span class="font-label-md text-label-md text-on-surface-variant font-medium">Tasa de Devolución</span>
                <div class="p-1.5 rounded-xl bg-surface-container-low text-secondary">
                  <span class="material-symbols-outlined text-[24px]">verified</span>
                </div>
              </div>
              <div class="text-center py-2">
                <span class="font-display-hero text-[36px] xl:text-[40px] font-bold text-primary tracking-tight leading-none">
                  {{ snapshot.returnRate }}
                </span>
              </div>
            </div>
            <div class="pt-2 flex items-center justify-end">
              <span class="font-label-sm text-label-sm font-semibold text-secondary bg-surface-container-low px-2.5 py-0.5 rounded-md">
                {{ snapshot.returnBadge }}
              </span>
            </div>
          </div>
        </section>

        <!-- Sección Central de Analítica Visual (2 Columnas Equilibradas) -->
        <section class="dashboard-two-col">
          <!-- Gráfica 1: Afluencia Semanal por Turno -->
          <div class="flex flex-col p-6 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60">
            <div class="flex flex-col gap-4 w-full h-full justify-between">
              <div class="flex items-center justify-between flex-wrap gap-2">
                <div class="flex flex-col gap-0.5">
                  <span class="font-label-lg text-label-lg font-bold text-primary">
                    Afluencia Semanal por Turno
                  </span>
                  <span class="font-label-sm text-label-sm text-on-surface-variant">
                    Distribución de ingresos a sala general
                  </span>
                </div>
                <div class="flex items-center gap-3">
                  <div class="flex items-center gap-1.5">
                    <span class="w-3 h-3 rounded-full bg-[#1b396a]"></span>
                    <span class="font-label-sm text-label-sm text-on-surface-variant font-medium">Matutino</span>
                  </div>
                  <div class="flex items-center gap-1.5">
                    <span class="w-3 h-3 rounded-full bg-[#c5a059]"></span>
                    <span class="font-label-sm text-label-sm text-on-surface-variant font-medium">Vespertino</span>
                  </div>
                </div>
              </div>

              <div class="w-full flex flex-col justify-end pt-4 pb-2">
                <svg class="w-full h-44 overflow-visible" viewBox="0 0 500 160" role="img" aria-label="Gráfica de barras de afluencia semanal por turno">
                  <line stroke="#eff4ff" stroke-dasharray="3 3" stroke-width="1" x1="40" x2="490" y1="20" y2="20" />
                  <text fill="#747780" font-size="11" text-anchor="end" x="32" y="24">150</text>
                  <line stroke="#eff4ff" stroke-dasharray="3 3" stroke-width="1" x1="40" x2="490" y1="60" y2="60" />
                  <text fill="#747780" font-size="11" text-anchor="end" x="32" y="64">100</text>
                  <line stroke="#eff4ff" stroke-dasharray="3 3" stroke-width="1" x1="40" x2="490" y1="100" y2="100" />
                  <text fill="#747780" font-size="11" text-anchor="end" x="32" y="104">50</text>
                  <line stroke="#c4c6d0" stroke-width="1" x1="40" x2="490" y1="140" y2="140" />
                  <text fill="#747780" font-size="11" text-anchor="end" x="32" y="143">0</text>

                  <g v-for="day in barGeometry" :key="day.label" :transform="`translate(${day.x}, 0)`">
                    <rect
                      v-if="day.isPeak"
                      fill="#dce9ff"
                      height="135"
                      opacity="0.5"
                      rx="6"
                      width="58"
                      x="7"
                      y="5"
                    />
                    <rect
                      fill="#1b396a"
                      :height="day.morningH"
                      rx="4"
                      width="24"
                      x="10"
                      :y="day.morningY"
                    >
                      <title>{{ day.label }} • Matutino: {{ day.morning }}</title>
                    </rect>
                    <rect
                      fill="#c5a059"
                      :height="day.afternoonH"
                      rx="4"
                      width="24"
                      x="38"
                      :y="day.afternoonY"
                    >
                      <title>{{ day.label }} • Vespertino: {{ day.afternoon }}</title>
                    </rect>
                    <text
                      :fill="day.isPeak ? '#1b396a' : '#44474f'"
                      font-size="11"
                      :font-weight="day.isPeak ? '700' : '600'"
                      text-anchor="middle"
                      x="36"
                      y="156"
                    >
                      {{ day.label }}
                    </text>
                  </g>
                </svg>
              </div>

              <div class="flex items-center gap-1.5 pt-3 border-t border-surface-container-low text-on-surface-variant font-body-sm text-body-sm">
                <span class="material-symbols-outlined text-[16px] text-secondary">event_available</span>
                <span>Pico de concurrencia: <strong class="text-primary">{{ snapshot.peakText }}</strong></span>
              </div>
            </div>
          </div>

          <!-- Gráfica 2: Préstamos y Consulta por Carrera -->
          <div class="flex flex-col p-6 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60">
            <div class="flex flex-col gap-3 w-full">
              <div class="flex items-center justify-between pb-1 gap-2">
                <div class="flex flex-col gap-0.5">
                  <span class="font-label-lg text-label-lg font-bold text-primary">
                    Préstamos y Consulta por Carrera
                  </span>
                  <span class="font-label-sm text-label-sm text-on-surface-variant">
                    Demanda porcentual de material por especialidad
                  </span>
                </div>
                <span class="font-label-sm text-label-sm font-semibold text-primary bg-surface-container-low px-2.5 py-0.5 rounded-md shrink-0">
                  7 Ingenierías
                </span>
              </div>

              <div class="flex flex-col gap-2.5 pt-1">
                <div v-for="career in snapshot.careers" :key="career.name" class="flex flex-col gap-1">
                  <div class="flex justify-between gap-2 font-label-sm text-label-sm">
                    <span class="text-primary font-medium truncate">{{ career.name }}</span>
                    <span class="text-on-surface-variant shrink-0">
                      {{ career.percent }}%
                      <span class="text-outline text-[10px]">({{ career.loans }} préstamos)</span>
                    </span>
                  </div>
                  <div class="w-full h-2 rounded-full bg-surface-container-low overflow-hidden">
                    <div
                      class="h-full rounded-full transition-all duration-300"
                      :style="{ width: `${career.percent}%`, backgroundColor: career.color }"
                    ></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- Fila Inferior: 2 Paneles de Detalle Operativo -->
        <section class="dashboard-two-col">
          <!-- Panel Izquierdo: Top 5 Libros Más Solicitados -->
          <div class="flex flex-col p-6 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60">
            <div class="flex flex-col gap-4 w-full">
              <div class="flex items-center justify-between gap-2">
                <div class="flex flex-col gap-0.5">
                  <span class="font-label-lg text-label-lg font-bold text-primary">
                    Top 5 Libros Más Solicitados
                  </span>
                  <span class="font-label-sm text-label-sm text-on-surface-variant">
                    Títulos con mayor circulación del semestre
                  </span>
                </div>
                <span class="font-label-sm text-label-sm font-semibold text-secondary bg-surface-container-low px-2.5 py-0.5 rounded-md shrink-0">
                  {{ selectedPeriod === 'Ciclo' ? 'Ciclo Activo' : selectedPeriod }}
                </span>
              </div>

              <div class="flex flex-col divide-y divide-surface-container-low">
                <div
                  v-for="book in snapshot.topBooks"
                  :key="book.rank"
                  class="flex items-center justify-between gap-3 py-2.5"
                >
                  <div class="flex items-center gap-3 min-w-0">
                    <div
                      :class="[
                        'w-7 h-7 rounded-lg flex items-center justify-center font-bold text-label-sm shrink-0',
                        book.rank <= 3
                          ? 'bg-[#1b396a] text-white'
                          : 'text-primary bg-surface-container-high',
                      ]"
                    >
                      {{ book.rank }}
                    </div>
                    <div class="flex flex-col min-w-0">
                      <span class="font-label-md text-label-md font-semibold text-primary truncate">
                        {{ book.title }}
                      </span>
                      <span class="font-label-sm text-label-sm text-on-surface-variant truncate">
                        {{ book.author }}
                      </span>
                    </div>
                  </div>
                  <div class="flex flex-col items-end shrink-0">
                    <span class="font-label-md text-label-md font-bold text-primary">
                      {{ book.loans }}
                      <span class="text-on-surface-variant font-normal text-label-sm">préstamos</span>
                    </span>
                    <span class="font-label-sm text-label-sm text-outline">Dewey {{ book.dewey }}</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Panel Derecho: Distribución de Usuarios por Género -->
          <div class="flex flex-col justify-between p-6 rounded-2xl bg-surface-container-lowest shadow-sm border border-surface-container-high/60">
            <div class="flex flex-col justify-between h-full w-full gap-4">
              <div class="flex flex-col gap-3">
                <div class="flex items-center justify-between gap-2">
                  <div class="flex flex-col gap-0.5">
                    <span class="font-label-lg text-label-lg font-bold text-primary">
                      Distribución de Usuarios por Género
                    </span>
                    <span class="font-label-sm text-label-sm text-on-surface-variant">
                      Proporción de estudiantes registrados en sala
                    </span>
                  </div>
                  <span class="font-label-sm text-label-sm font-semibold text-secondary bg-surface-container-low px-2.5 py-0.5 rounded-md shrink-0">
                    {{ genderDistribution.total.toLocaleString('es-MX') }} Visitas
                  </span>
                </div>

                <div class="flex flex-col sm:flex-row items-center justify-around gap-4 py-3">
                  <div class="relative flex items-center justify-center">
                    <svg class="w-36 h-36 -rotate-90" viewBox="0 0 120 120" role="img" aria-label="Distribución de usuarios por género">
                      <circle cx="60" cy="60" fill="transparent" r="45" stroke="#eff4ff" stroke-width="16" />
                      <circle
                        cx="60"
                        cy="60"
                        fill="transparent"
                        r="45"
                        stroke="#1b396a"
                        :stroke-dasharray="DONUT_CIRCUMFERENCE"
                        :stroke-dashoffset="genderDistribution.menOffset"
                        stroke-width="16"
                      />
                      <circle
                        cx="60"
                        cy="60"
                        fill="transparent"
                        r="45"
                        stroke="#c5a059"
                        :stroke-dasharray="DONUT_CIRCUMFERENCE"
                        :stroke-dashoffset="genderDistribution.womenOffset"
                        stroke-linecap="round"
                        stroke-width="16"
                        :transform="genderDistribution.womenTransform"
                      />
                    </svg>
                    <div class="absolute flex flex-col items-center justify-center">
                      <span class="font-headline-sm text-headline-sm font-bold text-primary leading-none">
                        {{ genderDistribution.total.toLocaleString('es-MX') }}
                      </span>
                      <span class="font-label-sm text-[10px] text-on-surface-variant uppercase tracking-wider mt-0.5">
                        Total
                      </span>
                    </div>
                  </div>

                  <div class="flex flex-col gap-2.5">
                    <div class="flex items-center gap-2.5 rounded-xl bg-surface-container-low px-3.5 py-2.5">
                      <span class="w-3 h-3 rounded-full shrink-0 bg-[#1b396a]"></span>
                      <div class="flex flex-col">
                        <span class="font-label-md text-label-md font-semibold text-primary">
                          Hombres: {{ genderDistribution.menPct }}%
                        </span>
                        <span class="font-label-sm text-label-sm text-on-surface-variant">
                          {{ genderDistribution.men.toLocaleString('es-MX') }} visitas
                        </span>
                      </div>
                    </div>
                    <div class="flex items-center gap-2.5 rounded-xl bg-surface-container-low px-3.5 py-2.5">
                      <span class="w-3 h-3 rounded-full shrink-0 bg-[#c5a059]"></span>
                      <div class="flex flex-col">
                        <span class="font-label-md text-label-md font-semibold text-secondary">
                          Mujeres: {{ genderDistribution.womenPct }}%
                        </span>
                        <span class="font-label-sm text-label-sm text-on-surface-variant">
                          {{ genderDistribution.women.toLocaleString('es-MX') }} visitas
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="pt-3 flex items-center justify-between gap-2 border-t border-surface-container-low">
                <div class="flex items-center gap-1.5 text-on-surface-variant font-body-sm text-body-sm">
                  <span class="material-symbols-outlined text-[16px] text-secondary">insights</span>
                  <span>Relación equilibrada de comunidad estudiantil</span>
                </div>
                <button
                  type="button"
                  class="text-primary hover:text-primary-container font-label-md text-label-md font-semibold flex items-center gap-0.5 shrink-0"
                  @click="goToDemographicDetail"
                >
                  <span>Detalle Demográfico</span>
                  <span class="material-symbols-outlined text-[16px]">chevron_right</span>
                </button>
              </div>
            </div>
          </div>
        </section>
      </div>
    </main>
  </div>
</template>

<style scoped>
.dashboard-kpi-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1.25rem;
}

@media (min-width: 640px) {
  .dashboard-kpi-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1280px) {
  .dashboard-kpi-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

.dashboard-two-col {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1.5rem;
}

@media (min-width: 1024px) {
  .dashboard-two-col {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
