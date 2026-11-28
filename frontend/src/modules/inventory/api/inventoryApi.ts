import { http } from '../../../shared/api/http'
import type {
  BookApiDto,
  BookMetricsApiDto,
  BookSearchParams,
  CreateBookPayload,
  NextFolioApiDto,
  UpdateBookPayload,
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

export async function getNextAvailableFolio(): Promise<NextFolioApiDto> {
  const response = await http.get<NextFolioApiDto>('/books/next-folio')
  return response.data
}

export async function createBook(payload: CreateBookPayload): Promise<BookApiDto> {
  const response = await http.post<BookApiDto>('/books', payload)
  return response.data
}

export async function updateBook(bookId: number, payload: UpdateBookPayload): Promise<BookApiDto> {
  const response = await http.put<BookApiDto>(`/books/${bookId}`, payload)
  return response.data
}

export async function updateBookStatus(
  bookId: number,
  payload: UpdateBookStatusPayload,
): Promise<void> {
  await http.put(`/books/${bookId}/status`, payload)
}

export async function createShelf(name: string): Promise<{ id: number; name: string }> {
  const response = await http.post<{ id: number; name: string }>('/books/shelves', { name })
  return response.data
}

export async function getTopics(): Promise<{ id: number; name: string }[]> {
  const response = await http.get<{ id: number; name: string }[]>('/books/topics')
  return Array.isArray(response.data) ? response.data : []
}

export async function createTopic(name: string): Promise<{ id: number; name: string }> {
  const response = await http.post<{ id: number; name: string }>('/books/topics', { name })
  return response.data
}
