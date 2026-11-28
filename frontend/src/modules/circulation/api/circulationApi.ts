import { http } from '../../../shared/api/http'
import type {
  CirculationSummaryApiDto,
  CreateLoanPayload,
  LoanRecord,
} from '../types/circulation'

export async function getCirculationSummary(): Promise<CirculationSummaryApiDto> {
  const response = await http.get<CirculationSummaryApiDto>('/circulation/loans')
  return response.data
}

export async function createCirculationLoan(payload: CreateLoanPayload): Promise<LoanRecord> {
  const response = await http.post<LoanRecord>('/circulation/loans', payload)
  return response.data
}

export async function returnCirculationLoan(loanId: number): Promise<LoanRecord> {
  const response = await http.put<LoanRecord>(`/circulation/loans/${loanId}/return`)
  return response.data
}

export async function renewCirculationLoan(loanId: number): Promise<LoanRecord> {
  const response = await http.put<LoanRecord>(`/circulation/loans/${loanId}/renew`)
  return response.data
}
