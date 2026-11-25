<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

type LoanTab = 'activos' | 'proximos' | 'vencidos' | 'historial'
type LoanState = 'en_tiempo' | 'vence_hoy' | 'vencido' | 'devuelto'

interface LoanRecord {
  id: number
  folio: string
  bookTitle: string
  bookFullTitle: string
  bookSubtitle: string
  studentName: string
  controlNumber: string
  careerKey: string
  careerLabel: string
  loanDate: string
  dueDate: string
  state: LoanState
  statusText: string
  isOverdue: boolean
  isDueToday: boolean
  fineAmount?: number
}

interface TodayReturn {
  id: number
  bookTitle: string
  time: string
  studentInfo: string
  detail: string
  hasFine: boolean
}

const initialLoans: LoanRecord[] = [
  {
    id: 1,
    folio: '#4002',
    bookTitle: 'Ingeniería Económica',
    bookFullTitle: 'Ingeniería Económica (Blank & Tarquin)',
    bookSubtitle: 'L. Blank, A. Tarquin • 7a Ed.',
    studentName: 'Carlos Eduardo Ramos',
    controlNumber: '20051189',
    careerKey: 'gestion',
    careerLabel: 'Ing. Gestión Empresarial',
    loanDate: '02/Ago/24',
    dueDate: '09/Ago/24',
    state: 'en_tiempo',
    statusText: 'En tiempo (2 días)',
    isOverdue: false,
    isDueToday: false,
  },
  {
    id: 2,
    folio: '#4004',
    bookTitle: 'Mecatrónica: Sistemas de Control',
    bookFullTitle: 'Mecatrónica: Sistemas de Control',
    bookSubtitle: 'W. Bolton • 5a Edición',
    studentName: 'Mariana Soto Valdés',
    controlNumber: '21050342',
    careerKey: 'mecatronica',
    careerLabel: 'Ing. Mecatrónica • Morosa',
    loanDate: '28/Jul/24',
    dueDate: '04/Ago/24',
    state: 'vencido',
    statusText: 'Vencido (-4 días)',
    isOverdue: true,
    isDueToday: false,
    fineAmount: 60,
  },
  {
    id: 3,
    folio: '#3890',
    bookTitle: 'Termodinámica Técnica',
    bookFullTitle: 'Termodinámica Técnica',
    bookSubtitle: 'Y. Cengel, M. Boles',
    studentName: 'Luis Fernando Garza',
    controlNumber: '19050882',
    careerKey: 'mecanica',
    careerLabel: 'Ing. Mecánica',
    loanDate: '03/Ago/24',
    dueDate: '10/Ago/24',
    state: 'en_tiempo',
    statusText: 'En tiempo (3 días)',
    isOverdue: false,
    isDueToday: false,
  },
  {
    id: 4,
    folio: '#2215',
    bookTitle: 'Química Ambiental y Energías',
    bookFullTitle: 'Química Ambiental y Energías Renovables',
    bookSubtitle: 'C. Baird, M. Cann',
    studentName: 'Valeria Méndez Gómez',
    controlNumber: '22050114',
    careerKey: 'energias',
    careerLabel: 'Ing. Energías Renovables',
    loanDate: '01/Ago/24',
    dueDate: '08/Ago/24 (Hoy)',
    state: 'vence_hoy',
    statusText: 'Vence Hoy (Hasta 20:00)',
    isOverdue: false,
    isDueToday: true,
  },
  {
    id: 5,
    folio: '#4102',
    bookTitle: 'Manufactura, Ing. y Tecnología',
    bookFullTitle: 'Manufactura, Ingeniería y Tecnología',
    bookSubtitle: 'S. Kalpakjian, S. Schmid',
    studentName: 'Jorge Alberto Castro',
    controlNumber: '21050720',
    careerKey: 'industrial',
    careerLabel: 'Ing. Industrial',
    loanDate: '04/Ago/24',
    dueDate: '11/Ago/24',
    state: 'en_tiempo',
    statusText: 'En tiempo (4 días)',
    isOverdue: false,
    isDueToday: false,
  },
  {
    id: 6,
    folio: '#3510',
    bookTitle: 'Cálculo Vectorial',
    bookFullTitle: 'Cálculo Vectorial (Stewart)',
    bookSubtitle: 'J. Stewart • 8a Ed.',
    studentName: 'Andrea Paz',
    controlNumber: '22050981',
    careerKey: 'sistemas',
    careerLabel: 'Ing. en Sistemas',
    loanDate: '01/Ago/24',
    dueDate: '08/Ago/24',
    state: 'devuelto',
    statusText: 'Devuelto • Sin multa',
    isOverdue: false,
    isDueToday: false,
  },
]

const initialReturns: TodayReturn[] = [
  {
    id: 1,
    bookTitle: 'Cálculo Vectorial (Stewart)',
    time: '11:42 hrs',
    studentInfo: 'Andrea Paz (No. 22050981)',
    detail: 'En buen estado • Sin multa',
    hasFine: false,
  },
  {
    id: 2,
    bookTitle: 'Física Universitaria Vol. 2',
    time: '10:15 hrs',
    studentInfo: 'David Esquivel (No. 21050419)',
    detail: 'Estante: Sala General A',
    hasFine: false,
  },
  {
    id: 3,
    bookTitle: 'Diseño Digital y VHDL',
    time: '09:30 hrs',
    studentInfo: 'Héctor Moncada (No. 20050112)',
    detail: 'Atraso 1 día • Multa: $15 MXN',
    hasFine: true,
  },
]

const loans = ref<LoanRecord[]>(initialLoans.map((item) => ({ ...item })))
const todayReturns = ref<TodayReturn[]>(initialReturns.map((item) => ({ ...item })))
const activeTab = ref<LoanTab>('activos')
const tableSearch = ref('')
const globalSearch = ref('')
const selectedCareer = ref('all')
const scannerValue = ref('')
const currentPage = ref(1)
const feedbackMessage = ref('')
const feedbackTone = ref<'info' | 'success' | 'warning'>('info')
const selectedLoanDetail = ref<LoanRecord | null>(null)
const isProcessing = ref(false)
const headerSearchRef = ref<HTMLInputElement | null>(null)

const metricsBase = ref({
  activeLoans: 142,
  scheduledToday: 28,
  overdueLoans: 7,
  webRenewals: 12,
  receivedToday: 19,
  historyCount: 45,
})

const filteredLoans = computed(() => {
  const query = (tableSearch.value.trim() || globalSearch.value.trim()).toLowerCase()

  return loans.value.filter((loan) => {
    if (activeTab.value === 'activos' && loan.state === 'devuelto') return false
    if (activeTab.value === 'proximos' && !loan.isDueToday) return false
    if (activeTab.value === 'vencidos' && !loan.isOverdue) return false
    if (activeTab.value === 'historial' && loan.state !== 'devuelto') return false

    if (selectedCareer.value !== 'all' && loan.careerKey !== selectedCareer.value) {
      return false
    }

    if (!query) return true
    const haystack = [
      loan.folio,
      loan.bookTitle,
      loan.bookFullTitle,
      loan.bookSubtitle,
      loan.studentName,
      loan.controlNumber,
      loan.careerLabel,
      loan.statusText,
    ]
      .join(' ')
      .toLowerCase()

    return haystack.includes(query)
  })
})

function notify(message: string, tone: 'info' | 'success' | 'warning' = 'info') {
  feedbackMessage.value = message
  feedbackTone.value = tone
}

function getCurrentTimeLabel(): string {
  const now = new Date()
  const hh = String(now.getHours()).padStart(2, '0')
  const mm = String(now.getMinutes()).padStart(2, '0')
  return `${hh}:${mm} hrs`
}

function receiveLoan(loan: LoanRecord) {
  if (isProcessing.value || loan.state === 'devuelto') return
  isProcessing.value = true
  try {
    const hadFine = loan.isOverdue && (loan.fineAmount ?? 0) > 0
    if (loan.isOverdue) {
      metricsBase.value.overdueLoans = Math.max(0, metricsBase.value.overdueLoans - 1)
    }
    if (loan.isDueToday) {
      metricsBase.value.scheduledToday = Math.max(0, metricsBase.value.scheduledToday - 1)
    }
    metricsBase.value.activeLoans = Math.max(0, metricsBase.value.activeLoans - 1)
    metricsBase.value.receivedToday += 1
    metricsBase.value.historyCount += 1

    loan.state = 'devuelto'
    loan.isOverdue = false
    loan.isDueToday = false
    loan.statusText = hadFine ? `Devuelto • Multa cobrada ($${loan.fineAmount} MXN)` : 'Devuelto • En buen estado'

    todayReturns.value.unshift({
      id: Date.now(),
      bookTitle: loan.bookTitle,
      time: getCurrentTimeLabel(),
      studentInfo: `${loan.studentName} (No. ${loan.controlNumber})`,
      detail: hadFine ? `Sanción liquidada • Multa: $${loan.fineAmount} MXN` : 'En buen estado • Sin multa',
      hasFine: hadFine,
    })

    notify(
      hadFine
        ? `Devolución registrada para ${loan.folio} (${loan.bookTitle}) con sanción liquidada.`
        : `Devolución registrada correctamente para ${loan.folio} (${loan.bookTitle}).`,
      'success',
    )
  } finally {
    isProcessing.value = false
  }
}

function renewLoan(loan: LoanRecord) {
  if (isProcessing.value || loan.state === 'devuelto') return
  isProcessing.value = true
  try {
    if (loan.isDueToday) {
      metricsBase.value.scheduledToday = Math.max(0, metricsBase.value.scheduledToday - 1)
    }
    loan.isDueToday = false
    loan.isOverdue = false
    loan.state = 'en_tiempo'
    loan.dueDate = '14/Ago/24'
    loan.statusText = 'Renovado (+3 días)'
    notify(`Préstamo ${loan.folio} renovado por 3 días adicionales.`, 'info')
  } finally {
    isProcessing.value = false
  }
}

function sendReminder(loan: LoanRecord) {
  notify(
    `Recordatorio institucional enviado a ${loan.studentName} (Control ${loan.controlNumber}) por el ejemplar ${loan.folio}.`,
    'warning',
  )
}

function processQuickScan(action: 'loan' | 'return') {
  if (isProcessing.value) return
  const code = scannerValue.value.trim()
  if (!code) {
    notify(
      action === 'loan'
        ? 'Escanea o ingresa un folio o número de control para procesar el préstamo.'
        : 'Escanea o ingresa un folio o número de control para registrar la devolución.',
      'warning',
    )
    return
  }

  const normalized = code.toLowerCase()
  const matched = loans.value.find(
    (loan) =>
      loan.state !== 'devuelto' &&
      (loan.folio.toLowerCase().includes(normalized) ||
        loan.controlNumber.toLowerCase().includes(normalized)),
  )

  if (action === 'return') {
    if (matched) {
      receiveLoan(matched)
    } else {
      notify(`No se encontró un préstamo activo con el código "${code}".`, 'warning')
    }
  } else {
    const newId = Math.max(0, ...loans.value.map((item) => item.id)) + 1
    const folioFormatted = code.startsWith('#') ? code : `#${code.toUpperCase()}`
    loans.value.unshift({
      id: newId,
      folio: folioFormatted,
      bookTitle: 'Ejemplar registrado en terminal',
      bookFullTitle: `Ejemplar ${folioFormatted} • Préstamo de mostrador`,
      bookSubtitle: 'Registro rápido • Acervo TecNM Monclova',
      studentName: 'Estudiante TecNM Monclova',
      controlNumber: /^\d{8}$/.test(code) ? code : '21050999',
      careerKey: 'sistemas',
      careerLabel: 'Ing. en Sistemas',
      loanDate: '08/Ago/24',
      dueDate: '15/Ago/24',
      state: 'en_tiempo',
      statusText: 'En tiempo (7 días)',
      isOverdue: false,
      isDueToday: false,
    })
    metricsBase.value.activeLoans += 1
    activeTab.value = 'activos'
    notify(`Préstamo registrado desde terminal para el código ${folioFormatted}.`, 'success')
  }

  scannerValue.value = ''
}

function printExitPass() {
  window.print()
}

function handleKeydown(event: KeyboardEvent) {
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
    event.preventDefault()
    headerSearchRef.value?.focus()
  } else if (event.key === 'Escape' && selectedLoanDetail.value) {
    selectedLoanDetail.value = null
  }
}

onMounted(() => {
  window.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <div class="circulation-view flex flex-col flex-1 min-h-screen bg-background">
    <!-- Top Sticky Header -->
    <header class="sticky top-0 z-30 w-full h-16 bg-surface-container-lowest/95 backdrop-blur shadow-[0_1px_8px_rgba(27,57,106,0.05)] border-b border-surface-container-high px-4 sm:px-space-xl flex items-center justify-between gap-3">
      <div class="flex items-center gap-space-md min-w-0">
        <div class="flex items-center gap-space-xs text-on-surface-variant font-label-sm text-label-sm truncate">
          <span class="hover:text-primary transition-colors hidden sm:inline">TecNM Monclova</span>
          <span class="material-symbols-outlined text-[14px] hidden sm:inline">chevron_right</span>
          <span class="text-primary font-semibold truncate">Centro de Información y Biblioteca</span>
        </div>
      </div>

      <div class="flex items-center gap-space-md shrink-0">
        <div class="hidden md:flex items-center gap-space-xs bg-surface-container-low px-space-md py-1.5 rounded-lg border border-outline-variant/40 w-72">
          <span class="material-symbols-outlined text-outline text-[18px] shrink-0">search</span>
          <input
            ref="headerSearchRef"
            v-model="globalSearch"
            type="text"
            class="circulation-bare-input w-full !min-h-0 !p-0 !border-0 !bg-transparent !shadow-none text-on-surface font-body-sm !text-body-sm placeholder:text-on-surface-variant focus:outline-none"
            placeholder="Buscar por título, Dewey o matrícula..."
            aria-label="Buscar por título, Dewey o matrícula"
          />
          <kbd class="bg-surface-container-lowest text-outline font-citation-code text-[10px] px-1.5 py-0.5 rounded border border-outline-variant/60 shadow-xs shrink-0">
            ⌘K
          </kbd>
        </div>

        <div class="flex items-center gap-space-xs">
          <button
            type="button"
            class="w-9 h-9 rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-colors"
            title="Notificaciones"
            aria-label="Notificaciones"
            @click="notify('Tienes 7 préstamos vencidos y 12 solicitudes de renovación pendientes.', 'warning')"
          >
            <span class="material-symbols-outlined text-[20px]">notifications</span>
          </button>
          <button
            type="button"
            class="w-9 h-9 rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-colors"
            title="Manual de Procedimientos e Información"
            aria-label="Manual de Procedimientos e Información"
            @click="notify('Reglamento de circulación TecNM Monclova: préstamo regular de 7 días y renovación de 3 días.', 'info')"
          >
            <span class="material-symbols-outlined text-[20px]">help_outline</span>
          </button>
          <div class="h-5 w-px bg-surface-container-high ml-1 mr-1 hidden sm:block"></div>
          <div class="hidden sm:flex items-center gap-space-xs bg-surface-container-low px-space-sm py-1 rounded-full text-secondary font-label-sm text-label-sm font-semibold">
            <span class="material-symbols-outlined text-[16px]">school</span>
            <span>Campus Monclova</span>
          </div>
        </div>
      </div>
    </header>

    <main class="w-full flex-1 px-4 sm:px-space-xl py-space-lg bg-background">
      <div class="flex flex-col w-full gap-space-lg">
        <!-- Header Title & Action Toolbar -->
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-space-md pb-space-xs border-b border-surface-container-high/60">
          <div class="flex flex-col gap-1">
            <div class="flex items-center gap-2">
              <span class="w-2 h-2 rounded-full bg-secondary"></span>
              <span class="font-label-sm text-label-sm text-secondary uppercase tracking-widest font-semibold">
                Circulación Activa • Semestre Ago-Dic 2024
              </span>
            </div>
            <h1 class="font-headline-lg !text-headline-lg font-bold text-primary tracking-tight">
              Módulo de Circulación y Préstamos
            </h1>
            <p class="font-body-md text-body-md !text-on-surface-variant !max-w-none">
              Control integral de acervo bibliográfico, salidas físicas, devoluciones y sanciones
            </p>
          </div>

          <div class="flex items-center gap-space-sm flex-wrap">
            <div class="flex items-center gap-space-xs bg-surface-container-lowest px-space-md py-2 rounded-xl shadow-sm border border-surface-container-high">
              <span class="material-symbols-outlined text-secondary text-[20px]">calendar_today</span>
              <div class="flex flex-col">
                <span class="text-[11px] text-on-surface-variant font-medium leading-none">Fecha Actual</span>
                <span class="font-label-md text-label-md font-bold text-primary leading-tight mt-0.5">
                  Jueves, 08 de Agosto
                </span>
              </div>
            </div>
            <button
              type="button"
              class="flex items-center gap-space-xs bg-surface-container-lowest hover:bg-surface-container text-primary border border-surface-container-high px-space-md py-2.5 rounded-xl transition-all font-label-md text-label-md shadow-sm"
              @click="printExitPass"
            >
              <span class="material-symbols-outlined text-[18px]">print</span>
              <span>Pase de Salida</span>
            </button>
          </div>
        </div>

        <!-- Feedback Alert Banner -->
        <div
          v-if="feedbackMessage"
          :class="[
            'px-4 py-3 rounded-xl border text-xs font-medium flex items-center justify-between gap-3',
            feedbackTone === 'success'
              ? 'bg-emerald-50 border-emerald-200 text-emerald-800'
              : feedbackTone === 'warning'
                ? 'bg-amber-50 border-amber-200 text-amber-900'
                : 'bg-surface-container-low border-surface-container-high text-primary',
          ]"
          role="status"
        >
          <span class="flex items-center gap-2">
            <span class="material-symbols-outlined text-[18px]">
              {{ feedbackTone === 'success' ? 'check_circle' : feedbackTone === 'warning' ? 'warning' : 'info' }}
            </span>
            <span>{{ feedbackMessage }}</span>
          </span>
          <button
            type="button"
            class="p-1 rounded hover:bg-black/5"
            aria-label="Cerrar aviso"
            @click="feedbackMessage = ''"
          >
            <span class="material-symbols-outlined text-[16px]">close</span>
          </button>
        </div>

        <!-- Streamlined Quick Scanning Terminal -->
        <div class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high/80 p-space-md">
          <div class="flex flex-col lg:flex-row items-center justify-between gap-space-md">
            <div class="flex items-center gap-space-md w-full lg:w-auto shrink-0">
              <div class="flex flex-col">
                <span class="font-headline-sm text-[16px] font-bold text-primary">
                  Terminal de Escaneo Rápido
                </span>
                <span class="font-body-sm text-[12px] text-on-surface-variant">
                  Pase el lector óptico sobre el código de la credencial o el lomo del libro
                </span>
              </div>
            </div>

            <div class="flex-1 flex flex-col sm:flex-row items-center gap-space-sm w-full">
              <div class="relative flex-1 w-full">
                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-outline text-[18px] pointer-events-none">
                  qr_code_scanner
                </span>
                <input
                  id="quick-scanner-input"
                  v-model="scannerValue"
                  type="text"
                  class="circulation-input w-full !h-9 !min-h-0 !pl-9 !pr-3 !py-0 bg-surface-container-low text-on-surface font-body-sm !text-[12px] !rounded-lg border border-outline-variant/40 focus:outline-none focus:ring-1 focus:ring-primary"
                  placeholder="Escanear folio (#4002) o matrícula (20051189) y presionar Enter..."
                  aria-label="Folio o matrícula para escaneo rápido"
                  @keydown.enter.prevent="processQuickScan('loan')"
                />
              </div>

              <div class="flex items-center gap-space-xs w-full sm:w-auto shrink-0">
                <button
                  type="button"
                  class="flex-1 sm:flex-none flex items-center justify-center gap-1.5 bg-primary hover:bg-primary-container text-on-primary font-label-md text-label-md px-space-md py-2 rounded-lg transition-all shadow-sm active:scale-95 disabled:opacity-60"
                  :disabled="isProcessing"
                  @click="processQuickScan('loan')"
                >
                  <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                  <span class="whitespace-nowrap">Procesar Préstamo</span>
                </button>
                <button
                  type="button"
                  class="flex-1 sm:flex-none flex items-center justify-center gap-1.5 bg-surface-container-high hover:bg-surface-container text-primary font-label-md text-label-md px-space-md py-2 rounded-lg transition-all shadow-sm active:scale-95 disabled:opacity-60"
                  :disabled="isProcessing"
                  @click="processQuickScan('return')"
                >
                  <span class="material-symbols-outlined text-[16px]">keyboard_return</span>
                  <span class="whitespace-nowrap">Devolución</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 4 Metric Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-space-md">
          <!-- Préstamos Activos -->
          <div class="bg-surface-container-lowest p-space-md rounded-xl shadow-sm border border-surface-container-high flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
              <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider font-semibold">
                Préstamos Activos
              </span>
              <div class="w-10 h-10 rounded-xl bg-surface-container-low flex items-center justify-center text-primary">
                <span class="material-symbols-outlined text-[22px]">auto_stories</span>
              </div>
            </div>
            <div class="mt-2">
              <div class="flex items-baseline gap-2">
                <span class="font-headline-lg text-[32px] font-bold text-primary leading-none">
                  {{ metricsBase.activeLoans }}
                </span>
                <span class="font-body-sm text-[13px] text-on-surface-variant font-medium">
                  ejemplares en préstamo
                </span>
              </div>
              <div class="mt-3 pt-2.5 border-t border-surface-container-high/60 flex items-center justify-between text-secondary font-label-sm text-label-sm font-medium">
                <span class="text-on-surface-variant text-[11px]">Catálogo TecNM</span>
              </div>
            </div>
          </div>

          <!-- Entregas Programadas -->
          <div class="bg-surface-container-lowest p-space-md rounded-xl shadow-sm border border-surface-container-high flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
              <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider font-semibold">
                Entregas Programadas
              </span>
              <div class="w-10 h-10 rounded-xl bg-secondary-container/30 flex items-center justify-center text-secondary">
                <span class="material-symbols-outlined text-[22px]">pending_actions</span>
              </div>
            </div>
            <div class="mt-2">
              <div class="flex items-baseline gap-2">
                <span class="font-headline-lg text-[32px] font-bold text-primary leading-none">
                  {{ metricsBase.scheduledToday }}
                </span>
                <span class="font-body-sm text-[13px] text-on-surface-variant font-medium">
                  para hoy 08/Ago
                </span>
              </div>
              <div class="mt-3 pt-2.5 border-t border-surface-container-high/60 flex items-center justify-between text-on-surface-variant font-label-sm text-label-sm font-medium">
                <button
                  type="button"
                  class="text-secondary font-semibold text-[11px] hover:underline"
                  @click="activeTab = 'proximos'"
                >
                  Ver entregas de hoy
                </button>
              </div>
            </div>
          </div>

          <!-- Préstamos Vencidos -->
          <div class="bg-surface-container-lowest p-space-md rounded-xl shadow-sm border border-error-container/60 flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
              <span class="font-label-sm text-label-sm text-error uppercase tracking-wider font-bold">
                Préstamos Vencidos
              </span>
              <div class="w-10 h-10 rounded-xl bg-error-container/40 flex items-center justify-center text-error">
                <span class="material-symbols-outlined text-[22px]">warning</span>
              </div>
            </div>
            <div class="mt-2">
              <div class="flex items-baseline gap-2">
                <span class="font-headline-lg text-[32px] font-bold text-error leading-none">
                  {{ metricsBase.overdueLoans }}
                </span>
                <span class="font-body-sm text-[13px] text-error font-medium">
                  alertas con demora
                </span>
              </div>
              <div class="mt-3 pt-2.5 border-t border-error-container/40 flex items-center justify-between text-error font-label-sm text-label-sm font-semibold">
                <button
                  type="button"
                  class="text-error font-semibold text-[11px] hover:underline"
                  @click="activeTab = 'vencidos'"
                >
                  Atender morosos
                </button>
              </div>
            </div>
          </div>

          <!-- Renovaciones Web -->
          <div class="bg-surface-container-lowest p-space-md rounded-xl shadow-sm border border-surface-container-high flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
              <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider font-semibold">
                Renovaciones Web
              </span>
              <div class="w-10 h-10 rounded-xl bg-surface-container-high flex items-center justify-center text-primary">
                <span class="material-symbols-outlined text-[22px]">autorenew</span>
              </div>
            </div>
            <div class="mt-2">
              <div class="flex items-baseline gap-2">
                <span class="font-headline-lg text-[32px] font-bold text-primary leading-none">
                  {{ metricsBase.webRenewals }}
                </span>
                <span class="font-body-sm text-[13px] text-on-surface-variant font-medium">
                  solicitudes pendientes
                </span>
              </div>
              <div class="mt-3 pt-2.5 border-t border-surface-container-high/60 flex items-center justify-between text-secondary font-label-sm text-label-sm font-medium">
                <button
                  type="button"
                  class="text-primary font-semibold text-[11px] cursor-pointer hover:underline"
                  @click="notify('Mostrando solicitudes de renovación pendientes en el módulo.', 'info')"
                >
                  Revisar
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Main Workspace: Balanced 8/4 Grid Layout -->
        <div class="flex flex-col gap-space-lg w-full lg:flex-row items-start">
          <div class="flex flex-col gap-space-md w-full flex-1 min-w-0">
            <!-- Operational Tabs & Filters -->
            <div class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high p-space-sm flex flex-col lg:flex-row items-stretch lg:items-center justify-between gap-space-sm">
              <div class="flex items-center gap-1 bg-surface-container-low p-1 rounded-lg overflow-x-auto" role="tablist">
                <button
                  type="button"
                  role="tab"
                  :aria-selected="activeTab === 'activos'"
                  :class="[
                    'px-3 py-1.5 rounded-md font-label-md text-label-md transition-all flex items-center gap-1.5 whitespace-nowrap',
                    activeTab === 'activos'
                      ? 'font-semibold bg-primary text-on-primary shadow-xs'
                      : 'text-on-surface-variant hover:text-primary',
                  ]"
                  @click="activeTab = 'activos'"
                >
                  <span>Activos</span>
                  <span
                    :class="[
                      'px-1.5 py-0.5 rounded-full text-[11px]',
                      activeTab === 'activos'
                        ? 'bg-on-primary/20 text-on-primary'
                        : 'bg-surface-container-high text-primary',
                    ]"
                  >
                    {{ metricsBase.activeLoans }}
                  </span>
                </button>

                <button
                  type="button"
                  role="tab"
                  :aria-selected="activeTab === 'proximos'"
                  :class="[
                    'px-3 py-1.5 rounded-md font-label-md text-label-md transition-all flex items-center gap-1.5 whitespace-nowrap',
                    activeTab === 'proximos'
                      ? 'font-semibold bg-primary text-on-primary shadow-xs'
                      : 'text-on-surface-variant hover:text-primary',
                  ]"
                  @click="activeTab = 'proximos'"
                >
                  <span>Próximos a Vencer</span>
                  <span
                    :class="[
                      'px-1.5 py-0.5 rounded-full text-[11px]',
                      activeTab === 'proximos'
                        ? 'bg-on-primary/20 text-on-primary'
                        : 'bg-surface-container-high text-primary',
                    ]"
                  >
                    {{ metricsBase.scheduledToday }}
                  </span>
                </button>

                <button
                  type="button"
                  role="tab"
                  :aria-selected="activeTab === 'vencidos'"
                  :class="[
                    'px-3 py-1.5 rounded-md font-label-md text-label-md transition-all flex items-center gap-1.5 whitespace-nowrap',
                    activeTab === 'vencidos'
                      ? 'font-semibold bg-primary text-on-primary shadow-xs'
                      : 'text-on-surface-variant hover:text-error',
                  ]"
                  @click="activeTab = 'vencidos'"
                >
                  <span>Vencidos</span>
                  <span
                    :class="[
                      'px-1.5 py-0.5 rounded-full text-[11px] font-bold',
                      activeTab === 'vencidos'
                        ? 'bg-on-primary/20 text-on-primary'
                        : 'bg-error-container text-error',
                    ]"
                  >
                    {{ metricsBase.overdueLoans }}
                  </span>
                </button>

                <button
                  type="button"
                  role="tab"
                  :aria-selected="activeTab === 'historial'"
                  :class="[
                    'px-3 py-1.5 rounded-md font-label-md text-label-md transition-all flex items-center gap-1.5 whitespace-nowrap',
                    activeTab === 'historial'
                      ? 'font-semibold bg-primary text-on-primary shadow-xs'
                      : 'text-on-surface-variant hover:text-primary',
                  ]"
                  @click="activeTab = 'historial'"
                >
                  <span>Historial</span>
                  <span
                    :class="[
                      'px-1.5 py-0.5 rounded-full text-[11px]',
                      activeTab === 'historial'
                        ? 'bg-on-primary/20 text-on-primary'
                        : 'bg-surface-container-high text-on-surface-variant',
                    ]"
                  >
                    {{ metricsBase.historyCount }}
                  </span>
                </button>
              </div>

              <div class="flex items-center gap-space-xs">
                <div class="relative flex-1 sm:w-48">
                  <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-outline text-[16px] pointer-events-none">
                    search
                  </span>
                  <input
                    v-model="tableSearch"
                    class="circulation-input w-full !h-8 !min-h-0 !pl-8 !pr-3 !py-0 bg-surface-container-low text-on-surface font-body-sm !text-[12px] !rounded-lg border border-outline-variant/40 focus:outline-none focus:ring-1 focus:ring-primary"
                    placeholder="Filtrar tabla..."
                    type="text"
                    aria-label="Filtrar tabla de préstamos"
                  />
                </div>
                <div class="relative shrink-0">
                  <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-outline text-[16px] pointer-events-none">
                    filter_list
                  </span>
                  <select
                    v-model="selectedCareer"
                    class="circulation-select !w-auto !h-8 !min-h-0 bg-surface-container-low text-on-surface font-label-sm !text-label-sm !pl-7 !pr-6 !py-0 !rounded-lg border border-outline-variant/40 appearance-none cursor-pointer focus:outline-none focus:ring-1 focus:ring-primary"
                    aria-label="Filtrar por carrera"
                  >
                    <option value="all">Todas las Carreras</option>
                    <option value="sistemas">Ing. en Sistemas</option>
                    <option value="industrial">Ing. Industrial</option>
                    <option value="mecatronica">Ing. Mecatrónica</option>
                    <option value="mecanica">Ing. Mecánica</option>
                    <option value="gestion">Ing. en Gestión Empresarial</option>
                    <option value="energias">Ing. en Energías Renovables</option>
                    <option value="electronica">Ing. Electrónica</option>
                  </select>
                </div>
              </div>
            </div>

            <!-- Loans Table -->
            <div class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high overflow-hidden">
              <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                  <thead>
                    <tr class="bg-surface-container-low/80 text-on-surface-variant font-label-sm text-label-sm uppercase tracking-wider border-b border-surface-container-high">
                      <th class="!py-3 !px-space-md font-semibold !bg-transparent">Folio &amp; Ejemplar</th>
                      <th class="!py-3 !px-space-md font-semibold !bg-transparent">Estudiante Solicitante</th>
                      <th class="!py-3 !px-space-md font-semibold whitespace-nowrap !bg-transparent">Préstamo</th>
                      <th class="!py-3 !px-space-md font-semibold whitespace-nowrap !bg-transparent">Vencimiento</th>
                      <th class="!py-3 !px-space-md font-semibold !bg-transparent">Estatus</th>
                      <th class="!py-3 !px-space-md font-semibold text-right !bg-transparent">Acciones</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-surface-container-high font-body-sm text-body-sm">
                    <tr v-if="filteredLoans.length === 0">
                      <td colspan="6" class="!py-10 !px-space-md text-center text-on-surface-variant">
                        No hay registros que coincidan con el filtro seleccionado.
                      </td>
                    </tr>

                    <tr
                      v-for="loan in filteredLoans"
                      :key="loan.id"
                      :class="[
                        'transition-colors',
                        loan.isOverdue
                          ? 'bg-error-container/20 hover:bg-error-container/30 border-l-4 border-error'
                          : loan.isDueToday
                            ? 'bg-secondary-container/15 hover:bg-secondary-container/25 border-l-4 border-secondary'
                            : 'hover:bg-surface-container-low/50',
                      ]"
                    >
                      <td class="!py-3.5 !px-space-md align-middle">
                        <div class="flex items-center gap-space-sm">
                          <div
                            :class="[
                              'px-2 py-1 border rounded-md font-citation-code text-xs font-bold shrink-0',
                              loan.isOverdue
                                ? 'bg-error/10 border-error/20 text-error'
                                : loan.isDueToday
                                  ? 'bg-secondary/15 border-secondary/30 text-secondary'
                                  : 'bg-primary-container/10 border-primary-container/20 text-primary',
                            ]"
                          >
                            {{ loan.folio }}
                          </div>
                          <div class="flex flex-col min-w-0 max-w-[200px]">
                            <span
                              :class="[
                                'font-headline-sm text-sm truncate cursor-pointer',
                                loan.isOverdue
                                  ? 'font-bold text-error hover:underline'
                                  : 'font-semibold text-primary hover:text-secondary',
                              ]"
                              :title="loan.bookFullTitle"
                              @click="selectedLoanDetail = loan"
                            >
                              {{ loan.bookTitle }}
                            </span>
                            <span class="text-on-surface-variant text-[11px] truncate">
                              {{ loan.bookSubtitle }}
                            </span>
                          </div>
                        </div>
                      </td>

                      <td class="!py-3.5 !px-space-md align-middle">
                        <div class="flex flex-col min-w-0">
                          <span
                            :class="[
                              'font-label-md text-label-sm text-on-surface',
                              loan.isOverdue ? 'font-bold' : 'font-semibold',
                            ]"
                          >
                            {{ loan.studentName }}
                          </span>
                          <span class="font-citation-code text-[11px] text-on-surface-variant">
                            Control: {{ loan.controlNumber }}
                          </span>
                          <span
                            :class="[
                              'text-[11px]',
                              loan.isOverdue ? 'text-error font-semibold' : 'text-secondary font-medium',
                            ]"
                          >
                            {{ loan.careerLabel }}
                          </span>
                        </div>
                      </td>

                      <td class="!py-3.5 !px-space-md align-middle whitespace-nowrap text-on-surface-variant font-citation-code text-[12px]">
                        {{ loan.loanDate }}
                      </td>

                      <td
                        :class="[
                          '!py-3.5 !px-space-md align-middle whitespace-nowrap font-citation-code text-[12px]',
                          loan.isOverdue
                            ? 'font-bold text-error'
                            : loan.isDueToday
                              ? 'font-bold text-secondary'
                              : 'font-medium text-on-surface',
                        ]"
                      >
                        {{ loan.dueDate }}
                      </td>

                      <td class="!py-3.5 !px-space-md align-middle whitespace-nowrap">
                        <span
                          v-if="loan.isOverdue"
                          class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-error-container text-error"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-error animate-ping"></span>
                          {{ loan.statusText }}
                        </span>
                        <span
                          v-else-if="loan.isDueToday"
                          class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-secondary-container text-on-secondary-container"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-secondary"></span>
                          {{ loan.statusText }}
                        </span>
                        <span
                          v-else-if="loan.state === 'devuelto'"
                          class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-surface-container text-primary"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
                          {{ loan.statusText }}
                        </span>
                        <span
                          v-else
                          class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                          {{ loan.statusText }}
                        </span>
                      </td>

                      <td class="!py-3.5 !px-space-md align-middle text-right whitespace-nowrap">
                        <div class="flex items-center justify-end gap-1">
                          <template v-if="loan.state !== 'devuelto'">
                            <button
                              type="button"
                              :class="[
                                'w-8 h-8 rounded-lg flex items-center justify-center transition-colors',
                                loan.isOverdue
                                  ? 'bg-error hover:bg-error/90 text-on-error'
                                  : loan.isDueToday
                                    ? 'bg-secondary hover:bg-secondary/90 text-on-secondary'
                                    : 'bg-surface-container hover:bg-primary hover:text-on-primary text-primary',
                              ]"
                              :title="loan.isOverdue ? 'Cobrar sanción y recibir' : 'Recibir libro'"
                              @click="receiveLoan(loan)"
                            >
                              <span class="material-symbols-outlined text-[17px]">
                                {{ loan.isOverdue ? 'assignment_late' : 'assignment_turned_in' }}
                              </span>
                            </button>

                            <button
                              v-if="loan.isOverdue"
                              type="button"
                              class="w-8 h-8 rounded-lg flex items-center justify-center bg-surface-container hover:bg-surface-container-high text-error transition-colors"
                              title="Enviar recordatorio"
                              @click="sendReminder(loan)"
                            >
                              <span class="material-symbols-outlined text-[17px]">mail</span>
                            </button>
                            <button
                              v-else
                              type="button"
                              class="w-8 h-8 rounded-lg flex items-center justify-center bg-surface-container hover:bg-secondary hover:text-on-secondary text-secondary transition-colors"
                              title="Renovar (+3 Días)"
                              @click="renewLoan(loan)"
                            >
                              <span class="material-symbols-outlined text-[17px]">add_circle</span>
                            </button>

                            <button
                              v-if="loan.isDueToday"
                              type="button"
                              class="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-surface-container text-on-surface-variant transition-colors"
                              title="Aviso de vencimiento"
                              @click="sendReminder(loan)"
                            >
                              <span class="material-symbols-outlined text-[17px]">notifications_active</span>
                            </button>
                            <button
                              v-else
                              type="button"
                              class="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-surface-container text-on-surface-variant transition-colors"
                              title="Ver Ficha"
                              @click="selectedLoanDetail = loan"
                            >
                              <span class="material-symbols-outlined text-[17px]">badge</span>
                            </button>
                          </template>

                          <button
                            v-else
                            type="button"
                            class="w-8 h-8 rounded-lg flex items-center justify-center hover:bg-surface-container text-on-surface-variant transition-colors"
                            title="Ver Ficha"
                            @click="selectedLoanDetail = loan"
                          >
                            <span class="material-symbols-outlined text-[17px]">badge</span>
                          </button>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <div class="p-space-md bg-surface-container-low/40 border-t border-surface-container-high/60 flex flex-col sm:flex-row items-center justify-between gap-space-sm">
                <div class="font-body-sm text-[12px] text-on-surface-variant flex items-center gap-2">
                  <span>
                    Mostrando <strong>{{ filteredLoans.length }}</strong> de
                    <strong>{{ activeTab === 'historial' ? metricsBase.historyCount : metricsBase.activeLoans }}</strong>
                    registros {{ activeTab === 'historial' ? 'en historial' : 'activos' }}
                  </span>
                  <span class="w-1 h-1 rounded-full bg-outline-variant"></span>
                  <span>Página {{ currentPage }} de 29</span>
                </div>
                <div class="flex items-center gap-space-xs">
                  <button
                    type="button"
                    class="px-space-md py-1.5 rounded-lg bg-surface-container hover:bg-surface-container-high text-primary font-label-sm text-label-sm font-semibold transition-colors disabled:opacity-50"
                    :disabled="currentPage <= 1"
                    @click="currentPage = Math.max(1, currentPage - 1)"
                  >
                    Anterior
                  </button>
                  <button
                    type="button"
                    class="px-space-md py-1.5 rounded-lg bg-primary hover:bg-primary-container text-on-primary font-label-sm text-label-sm font-semibold transition-colors shadow-xs disabled:opacity-50"
                    :disabled="currentPage >= 29"
                    @click="currentPage = Math.min(29, currentPage + 1)"
                  >
                    Siguiente
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Right Panel: Devoluciones de Hoy -->
          <div class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high p-space-md flex flex-col gap-space-md w-full lg:w-80 shrink-0">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-secondary text-[22px]">assignment_turned_in</span>
                <h2 class="font-headline-sm !text-[16px] font-bold text-primary">Devoluciones de Hoy</h2>
              </div>
              <span class="font-citation-code text-xs text-secondary font-semibold bg-secondary-container/20 px-2.5 py-0.5 rounded-full">
                {{ metricsBase.receivedToday }} recibidos
              </span>
            </div>

            <div class="grid grid-cols-1 gap-space-md">
              <div
                v-for="item in todayReturns"
                :key="item.id"
                :class="[
                  'p-space-sm rounded-lg border flex items-start gap-space-sm',
                  item.hasFine
                    ? 'bg-secondary-container/15 border-secondary/30'
                    : 'bg-surface-container-low border-surface-container-high/60',
                ]"
              >
                <div
                  :class="[
                    'w-2.5 h-2.5 rounded-full mt-1 shrink-0 ring-4 ring-surface-container-lowest',
                    item.hasFine ? 'bg-secondary' : 'bg-emerald-500',
                  ]"
                ></div>
                <div class="flex flex-col flex-1 min-w-0">
                  <div class="flex items-center justify-between gap-1">
                    <span class="font-label-sm text-label-sm font-bold text-primary truncate">
                      {{ item.bookTitle }}
                    </span>
                    <span class="font-citation-code text-[10px] text-on-surface-variant shrink-0">
                      {{ item.time }}
                    </span>
                  </div>
                  <span class="font-body-sm text-[11px] text-on-surface-variant truncate">
                    {{ item.studentInfo }}
                  </span>
                  <span
                    :class="[
                      'font-medium text-[11px] mt-0.5',
                      item.hasFine ? 'text-secondary' : 'text-emerald-700',
                    ]"
                  >
                    {{ item.detail }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal Detalle de Préstamo -->
    <div
      v-if="selectedLoanDetail"
      class="fixed inset-0 z-50 bg-[#001838]/70 backdrop-blur-sm flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="loanDetailTitle"
      @click.self="selectedLoanDetail = null"
    >
      <div class="bg-white max-w-lg w-full rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
        <div class="bg-primary text-on-primary px-6 py-4 flex items-center justify-between border-b border-tecnm-gold/40">
          <div class="flex items-center gap-2.5">
            <span class="material-symbols-outlined text-tecnm-gold">badge</span>
            <h3 id="loanDetailTitle" class="font-headline-sm !text-sm font-bold text-white">
              Ficha de Circulación • {{ selectedLoanDetail.folio }}
            </h3>
          </div>
          <button
            type="button"
            class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center"
            aria-label="Cerrar ficha"
            @click="selectedLoanDetail = null"
          >
            <span class="material-symbols-outlined text-lg">close</span>
          </button>
        </div>

        <div class="p-6 flex flex-col gap-3 text-xs">
          <div>
            <span class="text-on-surface-variant block">Ejemplar</span>
            <strong class="text-primary text-sm">{{ selectedLoanDetail.bookFullTitle }}</strong>
            <p class="!text-on-surface-variant text-xs mt-0.5">{{ selectedLoanDetail.bookSubtitle }}</p>
          </div>
          <div class="grid grid-cols-2 gap-3 pt-2 border-t border-surface-container-high">
            <div>
              <span class="text-on-surface-variant block">Solicitante</span>
              <strong class="text-on-surface">{{ selectedLoanDetail.studentName }}</strong>
            </div>
            <div>
              <span class="text-on-surface-variant block">Número de Control</span>
              <strong class="font-citation-code text-primary">{{ selectedLoanDetail.controlNumber }}</strong>
            </div>
            <div>
              <span class="text-on-surface-variant block">Fecha de Préstamo</span>
              <strong class="font-citation-code">{{ selectedLoanDetail.loanDate }}</strong>
            </div>
            <div>
              <span class="text-on-surface-variant block">Fecha de Vencimiento</span>
              <strong class="font-citation-code">{{ selectedLoanDetail.dueDate }}</strong>
            </div>
          </div>
          <div class="pt-2 border-t border-surface-container-high flex items-center justify-between">
            <span class="text-on-surface-variant">Estatus actual:</span>
            <strong class="text-primary">{{ selectedLoanDetail.statusText }}</strong>
          </div>
        </div>

        <div class="bg-surface-container-low px-6 py-3 border-t border-surface-container-high flex justify-end gap-2">
          <button
            type="button"
            class="px-4 py-2 rounded-lg bg-primary text-on-primary text-xs font-semibold hover:bg-primary-container transition-colors"
            @click="selectedLoanDetail = null"
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
