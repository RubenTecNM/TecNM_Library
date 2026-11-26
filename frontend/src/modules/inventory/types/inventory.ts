export type BookStatusKey = 'disponible' | 'prestado' | 'reparacion' | 'baja' | 'catalogo'

export type InventorySortKey = 'dewey' | 'status' | 'relevance' | 'barcode'

export interface StatusMeta {
  id: number
  key: BookStatusKey
  label: string
  cardLabel: string
  statusClass: string
  dotClass: string
  pillBgClass: string
  badgeBgClass: string
}

export interface BookApiDto {
  id: number
  title: string
  note?: string | null
  author?: string | null
  folio: string
  dewey: string
  cutter: string
  statusId: number
  statusName: string
  shelfId: number
  shelfName: string
  availableText: string
  availabilityPercent: number
  topics?: string[] | null
}

export interface BookMetricsApiDto {
  totalBooks: number
  availableCount: number
  borrowedCount: number
  repairCount: number
  discardCount: number
  catalogCount: number
}

export interface BookSearchParams {
  search?: string
  field?: 'all' | 'title' | 'author' | 'dewey' | 'cutter' | 'folio' | 'barcode' | 'shelf' | 'topic'
  status?: 'all' | BookStatusKey
  sortBy?: InventorySortKey
}

export interface CreateBookPayload {
  title: string
  author?: string
  note?: string
  folio: string
  dewey: string
  cutter: string
  statusId: number
  shelfId: number
}

export interface UpdateBookStatusPayload {
  statusId: number
  note?: string
}

export interface BookItem {
  id: number
  title: string
  author: string
  note: string
  folio: string
  dewey: string
  cutter: string
  shelf: string
  shelfId: number
  status: BookStatusKey
  available: string
  barWidth: number
  code: string
  shortTitle: string
  coverSubtitle: string
  coverAuthor: string
  coverEdition: string
  coverIcon: string
  coverGradient: string
  coverBorderColor: string
  coverTagColor: string
  coverSubtitleColor: string
  coverBarColor: string
  deweyBadgeClass: string
  recommendation: string
  topics: string[]
}

export interface MetricsSummary {
  totalBooks: number
  borrowedCount: number
  repairCount: number
  discardCount: number
  catalogCount: number
}
