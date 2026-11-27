<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import {
  createCirculationLoan,
  getCirculationSummary,
  renewCirculationLoan,
  returnCirculationLoan,
} from '../api/circulationApi'
import type {
  BlockedStudentAlert,
  LoanRecord,
  LoanState,
  LoanTab,
  TodayReturn,
} from '../types/circulation'

const CAREER_OPTIONS = [
  { key: 'sistemas', label: 'Ing. en Sistemas' },
  { key: 'industrial', label: 'Ing. Industrial' },
  { key: 'mecatronica', label: 'Ing. Mecatrónica' },
  { key: 'mecanica', label: 'Ing. Mecánica' },
  { key: 'gestion', label: 'Ing. en Gestión Empresarial' },
  { key: 'energias', label: 'Ing. en Energías Renovables' },
  { key: 'electronica', label: 'Ing. Electrónica' },
]

function formatShortDate(date: Date): string {
  const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
  const day = String(date.getDate()).padStart(2, '0')
  const month = months[date.getMonth()]
  const year = String(date.getFullYear()).slice(-2)
  return `${day}/${month}/${year}`
}

function addDaysToShortDate(daysToAdd: number, baseDate?: Date): string {
  const target = baseDate ? new Date(baseDate) : new Date()
  target.setDate(target.getDate() + daysToAdd)
  return formatShortDate(target)
}

const initialLoans: LoanRecord[] = [
  {
    id: 1,
    folio: '5002',
    bookTitle: 'Código Limpio: Manual de estilo para el desarrollo ágil',
    bookFullTitle: 'Código Limpio: Manual de estilo para el desarrollo ágil',
    bookSubtitle: 'Robert C. Martin • 1ra Edición',
    studentName: 'Carlos Alberto Mendoza Rivas',
    controlNumber: '21280541',
    careerKey: 'sistemas',
    careerLabel: 'Ing. en Sistemas',
    loanDate: addDaysToShortDate(-1),
    dueDate: addDaysToShortDate(2),
    state: 'en_tiempo',
    statusText: 'En tiempo (2 días • Plazo 3 días)',
    isOverdue: false,
    isDueToday: false,
    hasEnrollmentBlock: false,
    enrollmentBlockReason: null,
    daysOverdue: 0,
  },
  {
    id: 2,
    folio: '5004',
    bookTitle: 'Redes de Computadoras: Un Enfoque Descendente',
    bookFullTitle: 'Redes de Computadoras: Un Enfoque Descendente',
    bookSubtitle: 'James F. Kurose • 7ma Edición',
    studentName: 'Ana Sofía Garza Villalobos',
    controlNumber: '22280312',
    careerKey: 'sistemas',
    careerLabel: 'Ing. en Sistemas • BLOQUEO DE INSCRIPCIÓN',
    loanDate: addDaysToShortDate(-5),
    dueDate: addDaysToShortDate(-2),
    state: 'vencido',
    statusText: 'Vencido (-2 días) • Bloqueo de Inscripción',
    isOverdue: true,
    isDueToday: false,
    hasEnrollmentBlock: true,
    enrollmentBlockReason: 'Bloqueo de inscripción activo por adeudo de ejemplar vencido (Folio 5004).',
    daysOverdue: 2,
  },
  {
    id: 3,
    folio: '5005',
    bookTitle: 'Termodinámica Técnica',
    bookFullTitle: 'Termodinámica Técnica',
    bookSubtitle: 'Y. Çengel, M. Boles',
    studentName: 'Luis Fernando Garza',
    controlNumber: '19050882',
    careerKey: 'mecanica',
    careerLabel: 'Ing. Mecánica',
    loanDate: addDaysToShortDate(0),
    dueDate: addDaysToShortDate(3),
    state: 'en_tiempo',
    statusText: 'En tiempo (3 días)',
    isOverdue: false,
    isDueToday: false,
    hasEnrollmentBlock: false,
    enrollmentBlockReason: null,
    daysOverdue: 0,
  },
  {
    id: 4,
    folio: '5009',
    bookTitle: 'Química General y Orgánica',
    bookFullTitle: 'Química General y Orgánica',
    bookSubtitle: 'Raymond Chang • 11va Edición',
    studentName: 'Valeria Méndez Gómez',
    controlNumber: '22050114',
    careerKey: 'energias',
    careerLabel: 'Ing. en Energías Renovables',
    loanDate: addDaysToShortDate(-3),
    dueDate: `${addDaysToShortDate(0)} (Hoy)`,
    state: 'vence_hoy',
    statusText: 'Vence Hoy (Plazo 3 días)',
    isOverdue: false,
    isDueToday: true,
    hasEnrollmentBlock: false,
    enrollmentBlockReason: null,
    daysOverdue: 0,
  },
  {
    id: 5,
    folio: '5010',
    bookTitle: 'Investigación de Operaciones',
    bookFullTitle: 'Investigación de Operaciones',
    bookSubtitle: 'Hamdy A. Taha • 9na Edición',
    studentName: 'Jorge Alberto Castro',
    controlNumber: '21050720',
    careerKey: 'industrial',
    careerLabel: 'Ing. Industrial • BLOQUEO DE INSCRIPCIÓN',
    loanDate: addDaysToShortDate(-4),
    dueDate: addDaysToShortDate(-1),
    state: 'vencido',
    statusText: 'Vencido (-1 día) • Bloqueo de Inscripción',
    isOverdue: true,
    isDueToday: false,
    hasEnrollmentBlock: true,
    enrollmentBlockReason: 'Bloqueo de inscripción activo por adeudo de ejemplar vencido (Folio 5010).',
    daysOverdue: 1,
  },
  {
    id: 6,
    folio: '5000',
    bookTitle: 'Sistemas Operativos Modernos',
    bookFullTitle: 'Sistemas Operativos Modernos (Tanenbaum)',
    bookSubtitle: 'Andrew S. Tanenbaum • 4ta Ed.',
    studentName: 'Luis Fernando Treviño Peña',
    controlNumber: '20280199',
    careerKey: 'industrial',
    careerLabel: 'Ing. Industrial',
    loanDate: addDaysToShortDate(-6),
    dueDate: addDaysToShortDate(-3),
    state: 'devuelto',
    statusText: 'Devuelto • Sin bloqueo de inscripción',
    isOverdue: false,
    isDueToday: false,
    hasEnrollmentBlock: false,
    enrollmentBlockReason: null,
    daysOverdue: 0,
  },
]

const initialReturns: TodayReturn[] = [
  {
    id: 1,
    folio: '5000',
    bookTitle: 'Sistemas Operativos Modernos',
    time: '11:42 hrs',
    studentInfo: 'Luis Fernando Treviño Peña (No. 20280199)',
    detail: 'En buen estado • Sin bloqueo de inscripción',
    wasBlocked: false,
  },
  {
    id: 2,
    folio: '5006',
    bookTitle: 'Física Universitaria Moderna',
    time: '10:15 hrs',
    studentInfo: 'David Esquivel (No. 21050419)',
    detail: 'Estante: Sala General A • Sin adeudo',
    wasBlocked: false,
  },
  {
    id: 3,
    folio: '5011',
    bookTitle: 'Sistemas Digitales: Principios y Aplicaciones',
    time: '09:30 hrs',
    studentInfo: 'Héctor Moncada (No. 20050112)',
    detail: 'Entregado tras vencimiento • Bloqueo de inscripción liberado',
    wasBlocked: true,
  },
]

const loans = ref<LoanRecord[]>(initialLoans.map((item) => ({ ...item })))
const todayReturns = ref<TodayReturn[]>(initialReturns.map((item) => ({ ...item })))
const activeTab = ref<LoanTab>('activos')
const tableSearch = ref('')
const globalSearch = ref('')
const selectedCareer = ref('all')
const currentPage = ref(1)
const feedbackMessage = ref('')
const feedbackTone = ref<'info' | 'success' | 'warning'>('info')
const selectedLoanDetail = ref<LoanRecord | null>(null)
const showNewLoanModal = ref(false)
const showReturnModal = ref(false)
const selectedReturnLoanId = ref<number | null>(null)
const isProcessing = ref(false)
const headerSearchRef = ref<HTMLInputElement | null>(null)

const newLoanForm = ref({
  folio: '',
  bookTitle: '',
  studentName: '',
  controlNumber: '',
  careerKey: 'sistemas',
})

const metricsBase = ref({
  activeLoans: 142,
  scheduledToday: 28,
  overdueLoans: 7,
  webRenewals: 12,
  receivedToday: 19,
  historyCount: 45,
})

const activeLoanRecords = computed(() =>
  loans.value.filter((loan) => loan.state !== 'devuelto'),
)

const blockedStudentsAlerts = computed<BlockedStudentAlert[]>(() =>
  loans.value
    .filter((loan) => loan.isOverdue || loan.hasEnrollmentBlock)
    .map((loan) => ({
      loanId: loan.id,
      studentName: loan.studentName,
      controlNumber: loan.controlNumber,
      careerLabel: loan.careerLabel.replace(/\s*•\s*BLOQUEO DE INSCRIPCIÓN/i, ''),
      folio: loan.folio,
      bookTitle: loan.bookTitle,
      dueDate: loan.dueDate,
      daysOverdue: loan.daysOverdue ?? 1,
      blockReason:
        loan.enrollmentBlockReason ??
        `Bloqueo de inscripción escolar por ejemplar vencido (Folio ${loan.folio}).`,
    })),
)

function normalizeSearchText(text: string): string {
  return text
    .trim()
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
}

const filteredLoans = computed(() => {
  const query = normalizeSearchText(tableSearch.value.trim() || globalSearch.value.trim())

  return loans.value.filter((loan) => {
    if (activeTab.value === 'activos' && loan.state === 'devuelto') return false
    if (activeTab.value === 'proximos' && !loan.isDueToday) return false
    if (activeTab.value === 'vencidos' && !loan.isOverdue) return false
    if (activeTab.value === 'historial' && loan.state !== 'devuelto') return false

    if (selectedCareer.value !== 'all' && loan.careerKey !== selectedCareer.value) {
      return false
    }

    if (!query) return true
    const haystack = normalizeSearchText(
      [
        loan.folio,
        loan.bookTitle,
        loan.bookFullTitle,
        loan.bookSubtitle,
        loan.studentName,
        loan.controlNumber,
        loan.careerLabel,
        loan.statusText,
      ].join(' '),
    )

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

async function fetchCirculationFromBackend() {
  try {
    const summary = await getCirculationSummary()
    if (summary && Array.isArray(summary.loans) && summary.loans.length > 0) {
      loans.value = summary.loans.map((item) => ({
        ...item,
        state: (item.state as LoanState) || 'en_tiempo',
      }))
      if (Array.isArray(summary.todayReturns) && summary.todayReturns.length > 0) {
        todayReturns.value = summary.todayReturns
      }
      metricsBase.value.activeLoans = summary.activeLoans
      metricsBase.value.scheduledToday = summary.scheduledToday
      metricsBase.value.overdueLoans = summary.overdueLoans
      metricsBase.value.receivedToday = summary.receivedToday
      metricsBase.value.historyCount = summary.historyCount
    }
  } catch {
    // Mantiene datos locales cuando la API no está disponible
  }
}

async function receiveLoan(loan: LoanRecord) {
  if (isProcessing.value || loan.state === 'devuelto') return
  isProcessing.value = true
  try {
    const hadEnrollmentBlock = loan.isOverdue || loan.hasEnrollmentBlock

    try {
      await returnCirculationLoan(loan.id)
    } catch {
      // Continúa actualizando en cliente si el backend no responde
    }

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
    loan.hasEnrollmentBlock = false
    loan.enrollmentBlockReason = null
    loan.careerLabel = loan.careerLabel.replace(/\s*•\s*BLOQUEO DE INSCRIPCIÓN/i, '')
    loan.statusText = hadEnrollmentBlock
      ? 'Devuelto • Bloqueo de inscripción liberado'
      : 'Devuelto • Sin bloqueo de inscripción'

    todayReturns.value.unshift({
      id: Date.now(),
      folio: loan.folio,
      bookTitle: loan.bookTitle,
      time: getCurrentTimeLabel(),
      studentInfo: `${loan.studentName} (No. ${loan.controlNumber})`,
      detail: hadEnrollmentBlock
        ? 'Entregado tras vencimiento • Bloqueo de inscripción liberado'
        : 'En buen estado • Sin bloqueo de inscripción',
      wasBlocked: hadEnrollmentBlock,
    })

    notify(
      hadEnrollmentBlock
        ? `Devolución registrada para Folio ${loan.folio} (${loan.bookTitle}). Se ha LIBERADO el bloqueo de inscripción del estudiante ${loan.studentName} (${loan.controlNumber}).`
        : `Devolución registrada correctamente para Folio ${loan.folio} (${loan.bookTitle}).`,
      'success',
    )
  } finally {
    isProcessing.value = false
  }
}

async function renewLoan(loan: LoanRecord) {
  if (isProcessing.value || loan.state === 'devuelto') return
  isProcessing.value = true
  try {
    let updatedDueDate = addDaysToShortDate(3)
    try {
      const updated = await renewCirculationLoan(loan.id)
      if (updated?.dueDate) {
        updatedDueDate = updated.dueDate
      }
    } catch {
      // Calcula +3 días localmente
    }

    if (loan.isDueToday) {
      metricsBase.value.scheduledToday = Math.max(0, metricsBase.value.scheduledToday - 1)
    }
    if (loan.isOverdue) {
      metricsBase.value.overdueLoans = Math.max(0, metricsBase.value.overdueLoans - 1)
    }
    loan.isDueToday = false
    loan.isOverdue = false
    loan.hasEnrollmentBlock = false
    loan.enrollmentBlockReason = null
    loan.careerLabel = loan.careerLabel.replace(/\s*•\s*BLOQUEO DE INSCRIPCIÓN/i, '')
    loan.state = 'en_tiempo'
    loan.dueDate = updatedDueDate
    loan.statusText = 'Renovado (+3 días adicionales)'
    notify(`Préstamo de Folio ${loan.folio} renovado por 3 días adicionales (nuevo vencimiento: ${updatedDueDate}).`, 'info')
  } finally {
    isProcessing.value = false
  }
}

function sendReminder(loan: LoanRecord) {
  notify(
    `Alerta de BLOQUEO DE INSCRIPCIÓN enviada a ${loan.studentName} (Control ${loan.controlNumber}) por adeudo del ejemplar Folio ${loan.folio}.`,
    'warning',
  )
}

function openNewLoanModal() {
  newLoanForm.value = {
    folio: '5000',
    bookTitle: '',
    studentName: '',
    controlNumber: '',
    careerKey: 'sistemas',
  }
  showNewLoanModal.value = true
}

async function submitNewLoan() {
  if (isProcessing.value) return
  const folioClean = newLoanForm.value.folio.trim().replace(/^#+/, '')
  const bookTitle = newLoanForm.value.bookTitle.trim()
  const studentName = newLoanForm.value.studentName.trim()
  const controlNumber = newLoanForm.value.controlNumber.trim()
  if (!folioClean || !bookTitle || !studentName || !controlNumber) return

  const numericFolio = Number.parseInt(folioClean, 10)
  if (!Number.isNaN(numericFolio) && numericFolio < 5000) {
    notify('El folio del libro debe ser a partir del número 5000 en adelante.', 'warning')
    return
  }

  // Verificar si el estudiante tiene un bloqueo de inscripción activo antes de prestarle otro libro
  const existingBlocked = blockedStudentsAlerts.value.find(
    (b) => b.controlNumber.toLowerCase() === controlNumber.toLowerCase(),
  )
  if (existingBlocked) {
    notify(
      `ALERTA DE BLOQUEO DE INSCRIPCIÓN: El estudiante ${existingBlocked.studentName} (${controlNumber}) tiene bloqueo activo por el libro "${existingBlocked.bookTitle}" (Folio ${existingBlocked.folio}). Debe devolverlo primero.`,
      'warning',
    )
    return
  }

  isProcessing.value = true
  try {
    const career = CAREER_OPTIONS.find((item) => item.key === newLoanForm.value.careerKey)
    let createdLoan: LoanRecord | null = null

    try {
      createdLoan = await createCirculationLoan({
        folio: folioClean,
        bookTitle,
        studentName,
        controlNumber,
        careerKey: newLoanForm.value.careerKey,
      })
    } catch {
      // Registro local con plazo oficial de 3 días
    }

    const newId = createdLoan?.id ?? Math.max(0, ...loans.value.map((item) => item.id)) + 1
    const startDateLabel = createdLoan?.loanDate ?? formatShortDate(new Date())
    const dueDateLabel = createdLoan?.dueDate ?? addDaysToShortDate(3)

    loans.value.unshift({
      id: newId,
      folio: folioClean,
      bookTitle,
      bookFullTitle: bookTitle,
      bookSubtitle: 'Préstamo de mostrador (Plazo 3 días) • TecNM Monclova',
      studentName,
      controlNumber,
      careerKey: newLoanForm.value.careerKey,
      careerLabel: career?.label ?? 'Ing. en Sistemas',
      loanDate: startDateLabel,
      dueDate: dueDateLabel,
      state: 'en_tiempo',
      statusText: 'En tiempo (Plazo 3 días)',
      isOverdue: false,
      isDueToday: false,
      hasEnrollmentBlock: false,
      enrollmentBlockReason: null,
      daysOverdue: 0,
    })
    metricsBase.value.activeLoans += 1
    activeTab.value = 'activos'
    showNewLoanModal.value = false
    notify(
      `Préstamo de Folio ${folioClean} registrado por 3 días (entrega límite: ${dueDateLabel}) para ${studentName}.`,
      'success',
    )
  } finally {
    isProcessing.value = false
  }
}

function openReturnModal() {
  selectedReturnLoanId.value = activeLoanRecords.value[0]?.id ?? null
  showReturnModal.value = true
}

function confirmModalReturn() {
  if (selectedReturnLoanId.value === null) return
  const target = loans.value.find((loan) => loan.id === selectedReturnLoanId.value)
  if (target) {
    receiveLoan(target)
  }
  showReturnModal.value = false
}

function printExitPass() {
  window.print()
}

function handleKeydown(event: KeyboardEvent) {
  if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') {
    event.preventDefault()
    headerSearchRef.value?.focus()
  } else if (event.key === 'Escape') {
    if (showNewLoanModal.value) showNewLoanModal.value = false
    else if (showReturnModal.value) showReturnModal.value = false
    else if (selectedLoanDetail.value) selectedLoanDetail.value = null
  }
}

onMounted(() => {
  void fetchCirculationFromBackend()
  window.addEventListener('keydown', handleKeydown)
})

onBeforeUnmount(() => {
  window.removeEventListener('keydown', handleKeydown)
})
</script>

<template>
  <div class="circulation-view flex flex-col flex-1 min-h-screen bg-background">
    <!-- Top Sticky Header -->
    <header class="sticky top-0 z-30 w-full h-16 bg-surface-container-lowest/95 backdrop-blur shadow-[0_1px_8px_rgba(27,57,106,0.05)] border-b border-surface-container-high px-4 sm:px-8 flex items-center justify-between gap-4">
      <div class="flex items-center gap-3 min-w-0">
        <div class="flex items-center gap-1.5 text-on-surface-variant font-label-sm text-label-sm truncate">
          <span class="hover:text-primary transition-colors hidden sm:inline">TecNM Monclova</span>
          <span class="material-symbols-outlined text-[14px] hidden sm:inline">chevron_right</span>
          <span class="text-primary font-semibold truncate">Centro de Información y Biblioteca</span>
        </div>
      </div>

      <div class="flex items-center gap-3 shrink-0">
        <div class="hidden md:flex items-center gap-2 bg-surface-container-low px-3 py-1.5 rounded-lg border border-outline-variant/40 w-72">
          <span class="material-symbols-outlined text-outline text-[18px] shrink-0">search</span>
          <input
            ref="headerSearchRef"
            v-model="globalSearch"
            type="text"
            class="circulation-bare-input w-full !min-h-0 !p-0 !border-0 !bg-transparent !shadow-none text-on-surface font-body-sm !text-body-sm placeholder:text-on-surface-variant focus:outline-none"
            placeholder="Buscar por título, folio o matrícula..."
            aria-label="Buscar por título, folio o matrícula"
          />
          <kbd class="bg-surface-container-lowest text-outline font-citation-code text-[10px] px-1.5 py-0.5 rounded border border-outline-variant/60 shadow-xs shrink-0">
            ⌘K
          </kbd>
        </div>

        <div class="flex items-center gap-1.5">
          <button
            type="button"
            class="w-9 h-9 rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-colors"
            title="Notificaciones"
            aria-label="Notificaciones"
            @click="notify(`Tienes ${metricsBase.overdueLoans} préstamos vencidos y ${metricsBase.webRenewals} solicitudes de renovación pendientes.`, 'warning')"
          >
            <span class="material-symbols-outlined text-[20px]">notifications</span>
          </button>
          <button
            type="button"
            class="w-9 h-9 rounded-lg flex items-center justify-center text-on-surface-variant hover:bg-surface-container-high transition-colors"
            title="Manual de Procedimientos e Información"
            aria-label="Manual de Procedimientos e Información"
            @click="notify('Reglamento de circulación TecNM Monclova: plazo de entrega de 3 días, renovación por +3 días adicionales. Los adeudos vencidos generan bloqueo de inscripción (sin multas monetarias).', 'info')"
          >
            <span class="material-symbols-outlined text-[20px]">help_outline</span>
          </button>
          <div class="h-5 w-px bg-surface-container-high mx-1 hidden sm:block"></div>
          <div class="hidden sm:flex items-center gap-1.5 bg-surface-container-low px-3 py-1 rounded-full text-secondary font-label-sm text-label-sm font-semibold">
            <span class="material-symbols-outlined text-[16px]">school</span>
            <span>Campus Monclova</span>
          </div>
        </div>
      </div>
    </header>

    <main class="w-full flex-1 px-4 sm:px-8 py-6 bg-background">
      <div class="max-w-[1520px] mx-auto flex flex-col gap-6">
        <!-- Header Title & Action Toolbar -->
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-surface-container-high/70">
          <div class="flex flex-col gap-1">
            <div class="flex items-center gap-2">
              <span class="w-2 h-2 rounded-full bg-secondary"></span>
              <span class="font-label-sm text-label-sm text-secondary uppercase tracking-widest font-semibold">
                Circulación Activa • Semestre Ago-Dic 2024
              </span>
            </div>
            <h1 class="font-headline-lg !text-[26px] sm:!text-[30px] font-bold text-primary tracking-tight">
              Módulo de Circulación y Préstamos
            </h1>
            <p class="font-body-md text-body-md !text-on-surface-variant !max-w-none">
              Control integral de préstamos (plazo 3 días), renovaciones (+3 días), devoluciones y alertas de bloqueo de inscripción
            </p>
          </div>

          <div class="flex items-center gap-3 flex-wrap">
            <div class="flex items-center gap-2.5 bg-surface-container-lowest px-4 py-2 rounded-xl shadow-sm border border-surface-container-high">
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
              class="flex items-center gap-2 bg-surface-container-lowest hover:bg-surface-container text-primary border border-surface-container-high px-4 py-2.5 rounded-xl transition-all font-label-md text-label-md shadow-sm"
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

        <!-- Counter Quick Operations Bar (without scanner input) -->
        <div class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high/80 px-5 py-4">
          <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div class="flex items-center gap-3.5">
              <div class="w-10 h-10 rounded-xl bg-surface-container-low text-primary flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[22px]">sync_alt</span>
              </div>
              <div class="flex flex-col">
                <span class="font-headline-sm text-[15px] font-bold text-primary">
                  Operaciones de Mostrador
                </span>
                <span class="font-body-sm text-[12px] text-on-surface-variant">
                  Registre una nueva salida de libro o procese la devolución de un ejemplar activo
                </span>
              </div>
            </div>

            <div class="flex items-center gap-2.5 w-full sm:w-auto shrink-0">
              <button
                type="button"
                class="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-primary hover:bg-primary-container text-on-primary font-label-md text-label-md font-semibold px-4 py-2.5 rounded-lg transition-all shadow-sm active:scale-95 disabled:opacity-60"
                :disabled="isProcessing"
                @click="openNewLoanModal"
              >
                <span class="material-symbols-outlined text-[17px]">arrow_forward</span>
                <span class="whitespace-nowrap">Procesar Préstamo</span>
              </button>
              <button
                type="button"
                class="flex-1 sm:flex-none flex items-center justify-center gap-2 bg-surface-container-high hover:bg-surface-container text-primary font-label-md text-label-md font-semibold px-4 py-2.5 rounded-lg transition-all shadow-sm active:scale-95 disabled:opacity-60"
                :disabled="isProcessing"
                @click="openReturnModal"
              >
                <span class="material-symbols-outlined text-[17px]">keyboard_return</span>
                <span class="whitespace-nowrap">Devolución</span>
              </button>
            </div>
          </div>
        </div>

        <!-- 4 Metric Cards (isolated grid class to prevent global.css collision) -->
        <div class="circulation-metrics-grid">
          <!-- Préstamos Activos -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm border border-surface-container-high flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between gap-2">
              <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider font-semibold">
                Préstamos Activos
              </span>
              <div class="w-10 h-10 rounded-xl bg-surface-container-low flex items-center justify-center text-primary shrink-0">
                <span class="material-symbols-outlined text-[22px]">auto_stories</span>
              </div>
            </div>
            <div class="mt-3">
              <div class="flex items-baseline gap-2 flex-wrap">
                <span class="font-headline-lg text-[30px] font-bold text-primary leading-none">
                  {{ metricsBase.activeLoans }}
                </span>
                <span class="font-body-sm text-[12px] text-on-surface-variant font-medium">
                  ejemplares en préstamo
                </span>
              </div>
              <div class="mt-3 pt-2.5 border-t border-surface-container-high/60 flex items-center justify-between text-secondary font-label-sm text-label-sm font-medium">
                <span class="text-on-surface-variant text-[11px]">Catálogo TecNM</span>
              </div>
            </div>
          </div>

          <!-- Entregas Programadas -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm border border-surface-container-high flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between gap-2">
              <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider font-semibold">
                Entregas Programadas
              </span>
              <div class="w-10 h-10 rounded-xl bg-secondary-container/30 flex items-center justify-center text-secondary shrink-0">
                <span class="material-symbols-outlined text-[22px]">pending_actions</span>
              </div>
            </div>
            <div class="mt-3">
              <div class="flex items-baseline gap-2 flex-wrap">
                <span class="font-headline-lg text-[30px] font-bold text-primary leading-none">
                  {{ metricsBase.scheduledToday }}
                </span>
                <span class="font-body-sm text-[12px] text-on-surface-variant font-medium">
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

          <!-- Préstamos Vencidos / Bloqueos de Inscripción -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm border border-error-container/60 flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between gap-2">
              <span class="font-label-sm text-label-sm text-error uppercase tracking-wider font-bold">
                Bloqueos de Inscripción
              </span>
              <div class="w-10 h-10 rounded-xl bg-error-container/40 flex items-center justify-center text-error shrink-0">
                <span class="material-symbols-outlined text-[22px]">block</span>
              </div>
            </div>
            <div class="mt-3">
              <div class="flex items-baseline gap-2 flex-wrap">
                <span class="font-headline-lg text-[30px] font-bold text-error leading-none">
                  {{ blockedStudentsAlerts.length }}
                </span>
                <span class="font-body-sm text-[12px] text-error font-medium">
                  estudiantes con bloqueo
                </span>
              </div>
              <div class="mt-3 pt-2.5 border-t border-error-container/40 flex items-center justify-between text-error font-label-sm text-label-sm font-semibold">
                <button
                  type="button"
                  class="text-error font-semibold text-[11px] hover:underline"
                  @click="activeTab = 'vencidos'"
                >
                  Ver estudiantes bloqueados
                </button>
              </div>
            </div>
          </div>

          <!-- Renovaciones Web -->
          <div class="bg-surface-container-lowest p-5 rounded-xl shadow-sm border border-surface-container-high flex flex-col justify-between hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between gap-2">
              <span class="font-label-sm text-label-sm text-on-surface-variant uppercase tracking-wider font-semibold">
                Renovaciones Web
              </span>
              <div class="w-10 h-10 rounded-xl bg-surface-container-high flex items-center justify-center text-primary shrink-0">
                <span class="material-symbols-outlined text-[22px]">autorenew</span>
              </div>
            </div>
            <div class="mt-3">
              <div class="flex items-baseline gap-2 flex-wrap">
                <span class="font-headline-lg text-[30px] font-bold text-primary leading-none">
                  {{ metricsBase.webRenewals }}
                </span>
                <span class="font-body-sm text-[12px] text-on-surface-variant font-medium">
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

        <!-- Panel de Alertas de Estudiantes con Bloqueo de Inscripción -->
        <div
          v-if="blockedStudentsAlerts.length > 0"
          class="bg-rose-50/90 border border-rose-200 rounded-xl p-4 shadow-sm flex flex-col gap-3"
          role="region"
          aria-label="Alertas de estudiantes con bloqueo de inscripción"
        >
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-rose-200/80">
            <div class="flex items-center gap-2.5">
              <span class="w-8 h-8 rounded-lg bg-rose-600 text-white flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[18px]">gpp_maybe</span>
              </span>
              <div>
                <h2 class="font-headline-sm !text-sm font-bold text-rose-900">
                  Alertas Activas: Estudiantes con Bloqueo de Inscripción ({{ blockedStudentsAlerts.length }})
                </h2>
                <p class="text-[11.5px] !text-rose-700">
                  En el TecNM Campus Monclova no aplican multas monetarias; el retraso en la entrega mayor a 3 días activa el bloqueo de reinscripción escolar hasta devolver el ejemplar.
                </p>
              </div>
            </div>
            <button
              type="button"
              class="px-3 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white font-label-sm text-xs font-semibold shrink-0 transition-colors"
              @click="activeTab = 'vencidos'"
            >
              Filtrar Bloqueados ({{ blockedStudentsAlerts.length }})
            </button>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-2.5">
            <div
              v-for="alert in blockedStudentsAlerts"
              :key="alert.loanId"
              class="bg-white rounded-lg p-3 border border-rose-200 flex items-center justify-between gap-3 shadow-xs"
            >
              <div class="flex flex-col min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                  <span class="px-2 py-0.5 rounded bg-rose-100 text-rose-800 font-citation-code text-[10.5px] font-bold">
                    BLOQUEO ACTIVO • No. {{ alert.controlNumber }}
                  </span>
                  <span class="text-xs font-bold text-slate-900 truncate">{{ alert.studentName }}</span>
                </div>
                <span class="text-[11px] text-slate-600 truncate mt-0.5">
                  {{ alert.careerLabel }} • Adeuda Folio <strong>{{ alert.folio }}</strong> ({{ alert.bookTitle }})
                </span>
                <span class="text-[10.5px] text-rose-700 font-semibold mt-0.5">
                  Venció el {{ alert.dueDate }} ({{ alert.daysOverdue }} {{ alert.daysOverdue === 1 ? 'día' : 'días' }} de retraso)
                </span>
              </div>
              <button
                type="button"
                class="px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-[11px] font-bold shrink-0 transition-colors"
                title="Recibir ejemplar y liberar bloqueo de inscripción"
                @click="
                  () => {
                    const target = loans.find((l) => l.id === alert.loanId)
                    if (target) receiveLoan(target)
                  }
                "
              >
                Recibir y Liberar
              </button>
            </div>
          </div>
        </div>

        <!-- Main Workspace: Spacious table + vertical Devoluciones de Hoy panel -->
        <div class="flex flex-col 2xl:flex-row items-start gap-6 w-full">
          <!-- Left / Primary Table Column -->
          <div class="flex flex-col gap-4 w-full flex-1 min-w-0">
            <!-- Operational Tabs & Filters -->
            <div class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high p-3 flex flex-col xl:flex-row items-stretch xl:items-center justify-between gap-3">
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

              <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
                <div class="relative flex-1 sm:w-52">
                  <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-outline text-[16px] pointer-events-none">
                    search
                  </span>
                  <input
                    v-model="tableSearch"
                    class="circulation-input w-full !h-9 !min-h-0 !pl-8 !pr-3 !py-0 bg-surface-container-low text-on-surface font-body-sm !text-[12px] !rounded-lg border border-outline-variant/40 focus:outline-none focus:ring-1 focus:ring-primary"
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
                    class="circulation-select w-full sm:!w-auto !h-9 !min-h-0 bg-surface-container-low text-on-surface font-label-sm !text-label-sm !pl-7 !pr-7 !py-0 !rounded-lg border border-outline-variant/40 appearance-none cursor-pointer focus:outline-none focus:ring-1 focus:ring-primary"
                    aria-label="Filtrar por carrera"
                  >
                    <option value="all">Todas las Carreras</option>
                    <option v-for="career in CAREER_OPTIONS" :key="career.key" :value="career.key">
                      {{ career.label }}
                    </option>
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
                      <th class="!py-3.5 !px-4 font-semibold !bg-transparent">Folio &amp; Ejemplar</th>
                      <th class="!py-3.5 !px-4 font-semibold !bg-transparent">Estudiante Solicitante</th>
                      <th class="!py-3.5 !px-4 font-semibold whitespace-nowrap !bg-transparent">Préstamo</th>
                      <th class="!py-3.5 !px-4 font-semibold whitespace-nowrap !bg-transparent">Vencimiento</th>
                      <th class="!py-3.5 !px-4 font-semibold !bg-transparent">Estatus</th>
                      <th class="!py-3.5 !px-4 font-semibold text-right !bg-transparent">Acciones</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-surface-container-high font-body-sm text-body-sm">
                    <tr v-if="filteredLoans.length === 0">
                      <td colspan="6" class="!py-10 !px-4 text-center text-on-surface-variant">
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
                      <td class="!py-3.5 !px-4 align-middle">
                        <div class="flex items-center gap-3">
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
                          <div class="flex flex-col min-w-0 max-w-[230px]">
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

                      <td class="!py-3.5 !px-4 align-middle">
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

                      <td class="!py-3.5 !px-4 align-middle whitespace-nowrap text-on-surface-variant font-citation-code text-[12px]">
                        {{ loan.loanDate }}
                      </td>

                      <td
                        :class="[
                          '!py-3.5 !px-4 align-middle whitespace-nowrap font-citation-code text-[12px]',
                          loan.isOverdue
                            ? 'font-bold text-error'
                            : loan.isDueToday
                              ? 'font-bold text-secondary'
                              : 'font-medium text-on-surface',
                        ]"
                      >
                        {{ loan.dueDate }}
                      </td>

                      <td class="!py-3.5 !px-4 align-middle whitespace-nowrap">
                        <span
                          v-if="loan.isOverdue"
                          class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-error-container text-error"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-error animate-ping"></span>
                          {{ loan.statusText }}
                        </span>
                        <span
                          v-else-if="loan.isDueToday"
                          class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold bg-secondary-container text-on-secondary-container"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-secondary"></span>
                          {{ loan.statusText }}
                        </span>
                        <span
                          v-else-if="loan.state === 'devuelto'"
                          class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-surface-container text-primary"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
                          {{ loan.statusText }}
                        </span>
                        <span
                          v-else
                          class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700"
                        >
                          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                          {{ loan.statusText }}
                        </span>
                      </td>

                      <td class="!py-3.5 !px-4 align-middle text-right whitespace-nowrap">
                        <div class="flex items-center justify-end gap-1.5">
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
                              :title="loan.isOverdue ? 'Recibir libro y liberar bloqueo de inscripción' : 'Recibir libro'"
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

              <div class="px-5 py-3.5 bg-surface-container-low/40 border-t border-surface-container-high/60 flex flex-col sm:flex-row items-center justify-between gap-3">
                <div class="font-body-sm text-[12px] text-on-surface-variant flex items-center gap-2">
                  <span>
                    Mostrando <strong>{{ filteredLoans.length }}</strong> de
                    <strong>{{ activeTab === 'historial' ? metricsBase.historyCount : metricsBase.activeLoans }}</strong>
                    registros {{ activeTab === 'historial' ? 'en historial' : 'activos' }}
                  </span>
                  <span class="w-1 h-1 rounded-full bg-outline-variant"></span>
                  <span>Página {{ currentPage }} de 29</span>
                </div>
                <div class="flex items-center gap-2">
                  <button
                    type="button"
                    class="px-3.5 py-1.5 rounded-lg bg-surface-container hover:bg-surface-container-high text-primary font-label-sm text-label-sm font-semibold transition-colors disabled:opacity-50"
                    :disabled="currentPage <= 1"
                    @click="currentPage = Math.max(1, currentPage - 1)"
                  >
                    Anterior
                  </button>
                  <button
                    type="button"
                    class="px-3.5 py-1.5 rounded-lg bg-primary hover:bg-primary-container text-on-primary font-label-sm text-label-sm font-semibold transition-colors shadow-xs disabled:opacity-50"
                    :disabled="currentPage >= 29"
                    @click="currentPage = Math.min(29, currentPage + 1)"
                  >
                    Siguiente
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Right / Bottom Panel: Devoluciones de Hoy (strictly stacked one below another) -->
          <aside class="bg-surface-container-lowest rounded-xl shadow-sm border border-surface-container-high p-5 flex flex-col gap-4 w-full 2xl:w-[340px] shrink-0">
            <div class="flex items-center justify-between gap-2 pb-3 border-b border-surface-container-high/70">
              <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-secondary text-[22px]">assignment_turned_in</span>
                <h2 class="font-headline-sm !text-[16px] font-bold text-primary">Devoluciones de Hoy</h2>
              </div>
              <span class="font-citation-code text-xs text-secondary font-semibold bg-secondary-container/25 px-2.5 py-0.5 rounded-full shrink-0">
                {{ metricsBase.receivedToday }} recibidos
              </span>
            </div>

            <div class="flex flex-col gap-3 w-full">
              <div
                v-for="item in todayReturns"
                :key="item.id"
                :class="[
                  'w-full p-3.5 rounded-xl border flex items-start gap-3 transition-colors',
                  item.wasBlocked
                    ? 'bg-secondary-container/15 border-secondary/30'
                    : 'bg-surface-container-low border-surface-container-high/70',
                ]"
              >
                <div
                  :class="[
                    'w-2.5 h-2.5 rounded-full mt-1.5 shrink-0 ring-4 ring-surface-container-lowest',
                    item.wasBlocked ? 'bg-secondary' : 'bg-emerald-500',
                  ]"
                ></div>
                <div class="flex flex-col flex-1 min-w-0 gap-0.5">
                  <div class="flex items-center justify-between gap-2">
                    <span class="font-label-sm text-[13px] font-bold text-primary truncate">
                      {{ item.bookTitle }}
                    </span>
                    <span class="font-citation-code text-[11px] text-on-surface-variant shrink-0">
                      {{ item.time }}
                    </span>
                  </div>
                  <span class="font-body-sm text-[12px] text-on-surface-variant truncate">
                    {{ item.studentInfo }}
                  </span>
                  <span
                    :class="[
                      'font-semibold text-[11.5px] mt-0.5',
                      item.wasBlocked ? 'text-secondary' : 'text-emerald-700',
                    ]"
                  >
                    {{ item.detail }}
                  </span>
                </div>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </main>

    <!-- Modal: Procesar Préstamo -->
    <div
      v-if="showNewLoanModal"
      class="fixed inset-0 z-50 bg-[#001838]/70 backdrop-blur-sm flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="newLoanModalTitle"
      @click.self="showNewLoanModal = false"
    >
      <div class="bg-white max-w-lg w-full rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
        <div class="bg-primary text-on-primary px-6 py-4 flex items-center justify-between border-b border-tecnm-gold/40">
          <div class="flex items-center gap-2.5">
            <span class="material-symbols-outlined text-tecnm-gold">auto_stories</span>
            <h3 id="newLoanModalTitle" class="font-headline-sm !text-sm font-bold text-white">
              Registrar Nuevo Préstamo
            </h3>
          </div>
          <button
            type="button"
            class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center"
            aria-label="Cerrar"
            @click="showNewLoanModal = false"
          >
            <span class="material-symbols-outlined text-lg">close</span>
          </button>
        </div>

        <form class="p-6 flex flex-col gap-4 text-xs" @submit.prevent="submitNewLoan">
          <div class="circulation-form-grid">
            <div>
              <label class="block font-bold text-slate-700 mb-1" for="loanFolio">Folio del Ejemplar (5000+) *</label>
              <input
                id="loanFolio"
                v-model="newLoanForm.folio"
                type="text"
                required
                placeholder="Ej. 5000"
                class="circulation-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-semibold !text-xs"
              />
            </div>
            <div>
              <label class="block font-bold text-slate-700 mb-1" for="loanControl">Número de Control *</label>
              <input
                id="loanControl"
                v-model="newLoanForm.controlNumber"
                type="text"
                required
                placeholder="Ej. 21280541"
                class="circulation-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 font-citation-code font-semibold !text-xs"
              />
            </div>
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1" for="loanBookTitle">Título del Ejemplar *</label>
            <input
              id="loanBookTitle"
              v-model="newLoanForm.bookTitle"
              type="text"
              required
              placeholder="Ej. Sistemas Operativos Modernos"
              class="circulation-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 !text-xs"
            />
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1" for="loanStudentName">Nombre del Estudiante *</label>
            <input
              id="loanStudentName"
              v-model="newLoanForm.studentName"
              type="text"
              required
              placeholder="Ej. Carlos Alberto Mendoza Rivas"
              class="circulation-input w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 !text-xs"
            />
          </div>

          <div>
            <label class="block font-bold text-slate-700 mb-1" for="loanCareer">Carrera</label>
            <select
              id="loanCareer"
              v-model="newLoanForm.careerKey"
              class="circulation-select w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 !text-xs"
            >
              <option v-for="career in CAREER_OPTIONS" :key="career.key" :value="career.key">
                {{ career.label }}
              </option>
            </select>
          </div>

          <div class="pt-3 border-t border-surface-container-high flex justify-end gap-2">
            <button
              type="button"
              class="px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold"
              @click="showNewLoanModal = false"
            >
              Cancelar
            </button>
            <button
              type="submit"
              class="px-5 py-2 rounded-lg bg-primary text-on-primary font-semibold hover:bg-primary-container transition-colors"
            >
              Registrar Préstamo
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal: Registrar Devolución -->
    <div
      v-if="showReturnModal"
      class="fixed inset-0 z-50 bg-[#001838]/70 backdrop-blur-sm flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="returnModalTitle"
      @click.self="showReturnModal = false"
    >
      <div class="bg-white max-w-md w-full rounded-2xl shadow-2xl border border-slate-200 overflow-hidden">
        <div class="bg-primary text-on-primary px-6 py-4 flex items-center justify-between border-b border-tecnm-gold/40">
          <div class="flex items-center gap-2.5">
            <span class="material-symbols-outlined text-tecnm-gold">keyboard_return</span>
            <h3 id="returnModalTitle" class="font-headline-sm !text-sm font-bold text-white">
              Registrar Devolución
            </h3>
          </div>
          <button
            type="button"
            class="w-8 h-8 rounded-full bg-white/10 hover:bg-white/20 text-white flex items-center justify-center"
            aria-label="Cerrar"
            @click="showReturnModal = false"
          >
            <span class="material-symbols-outlined text-lg">close</span>
          </button>
        </div>

        <div class="p-6 flex flex-col gap-4 text-xs">
          <p v-if="activeLoanRecords.length === 0" class="!text-on-surface-variant">
            No hay préstamos activos pendientes de devolución.
          </p>
          <template v-else>
            <div>
              <label class="block font-bold text-slate-700 mb-1.5" for="returnLoanSelect">
                Selecciona el préstamo a recibir:
              </label>
              <select
                id="returnLoanSelect"
                v-model="selectedReturnLoanId"
                class="circulation-select w-full !h-10 !min-h-0 !px-3 !py-0 bg-white text-slate-800 !rounded-lg border border-slate-300 !text-xs"
              >
                <option v-for="loan in activeLoanRecords" :key="loan.id" :value="loan.id">
                  {{ loan.folio }} — {{ loan.bookTitle }} ({{ loan.studentName }})
                </option>
              </select>
            </div>
          </template>

          <div class="pt-3 border-t border-surface-container-high flex justify-end gap-2">
            <button
              type="button"
              class="px-4 py-2 rounded-lg border border-slate-300 text-slate-700 hover:bg-slate-100 font-semibold"
              @click="showReturnModal = false"
            >
              Cancelar
            </button>
            <button
              v-if="activeLoanRecords.length > 0"
              type="button"
              class="px-5 py-2 rounded-lg bg-primary text-on-primary font-semibold hover:bg-primary-container transition-colors"
              @click="confirmModalReturn"
            >
              Confirmar Devolución
            </button>
          </div>
        </div>
      </div>
    </div>

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

        <div class="p-6 flex flex-col gap-4 text-xs">
          <div>
            <span class="text-on-surface-variant block">Ejemplar</span>
            <strong class="text-primary text-sm">{{ selectedLoanDetail.bookFullTitle }}</strong>
            <p class="!text-on-surface-variant text-xs mt-0.5">{{ selectedLoanDetail.bookSubtitle }}</p>
          </div>
          <div class="circulation-detail-grid pt-3 border-t border-surface-container-high">
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
          <div class="pt-3 border-t border-surface-container-high flex items-center justify-between">
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

<style scoped>
.circulation-metrics-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 1rem;
}

@media (min-width: 640px) {
  .circulation-metrics-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (min-width: 1280px) {
  .circulation-metrics-grid {
    grid-template-columns: repeat(4, minmax(0, 1fr));
  }
}

.circulation-form-grid,
.circulation-detail-grid {
  display: grid;
  grid-template-columns: repeat(1, minmax(0, 1fr));
  gap: 0.75rem;
}

@media (min-width: 640px) {
  .circulation-form-grid,
  .circulation-detail-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
