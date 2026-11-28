export type LoanTab = 'activos' | 'proximos' | 'vencidos' | 'historial'
export type LoanState = 'en_tiempo' | 'vence_hoy' | 'vencido' | 'devuelto'

export interface LoanRecord {
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
  hasEnrollmentBlock: boolean
  enrollmentBlockReason?: string | null
  daysOverdue?: number
}

export interface BlockedStudentAlert {
  loanId: number
  borrowerId?: number
  studentName: string
  controlNumber: string
  careerLabel: string
  folio: string
  bookTitle: string
  dueDate: string
  daysOverdue: number
  blockReason: string
}

export interface TodayReturn {
  id: number
  folio?: string
  bookTitle: string
  time: string
  studentInfo: string
  detail: string
  wasBlocked: boolean
}

export interface CirculationSummaryApiDto {
  activeLoans: number
  scheduledToday: number
  overdueLoans: number
  blockedStudentsCount: number
  webRenewals: number
  receivedToday: number
  historyCount: number
  loans: LoanRecord[]
  blockedStudents: BlockedStudentAlert[]
  todayReturns: TodayReturn[]
}

export interface CreateLoanPayload {
  folio: string
  bookTitle?: string
  studentName: string
  controlNumber: string
  careerKey: string
  borrowerType?: string
}
