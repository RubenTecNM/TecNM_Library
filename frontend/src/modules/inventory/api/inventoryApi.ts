import { http } from '../../../shared/api/http'
import type {
  BookApiDto,
  BookMetricsApiDto,
  BookSearchParams,
  CreateBookPayload,
  UpdateBookStatusPayload,
} from '../types/inventory'

export async function searchBooks(
  params: BookSearchParams,
  signal?: AbortSignal,
): Promise<BookApiDto[]> {
  const queryParams: Record<string, string> = {}

  const trimmedSearch = params.search?.trim()
  if (trimmedSearch) {
    queryParams.search = trimmedSearch
  }

  if (params.field && params.field !== 'all') {
    queryParams.field = params.field
  }

  if (params.status && params.status !== 'all') {
    queryParams.status = params.status
  }

  if (params.sortBy) {
    queryParams.sortBy = params.sortBy
  }

  const response = await http.get<BookApiDto[]>('/books', {
    params: queryParams,
    signal,
  })

  return Array.isArray(response.data) ? response.data : []
}

export async function getInventoryMetrics(signal?: AbortSignal): Promise<BookMetricsApiDto> {
  const response = await http.get<BookMetricsApiDto>('/books/metrics', { signal })
  return response.data
}

export async function createBook(payload: CreateBookPayload): Promise<BookApiDto> {
  const response = await http.post<BookApiDto>('/books', payload)
  return response.data
}

export async function updateBookStatus(
  bookId: number,
  payload: UpdateBookStatusPayload,
): Promise<void> {
  await http.put(`/books/${bookId}/status`, payload)
}
