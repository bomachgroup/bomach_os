import { apiClient } from '@/shared/api/api-client'

export type AssetStatus = 'in_use' | 'maintenance' | 'available' | 'retired' | 'lost_stolen'
export type AssetType = 'laptop' | 'printer' | 'vehicle' | 'furniture' | 'equipment' | 'other'

export interface AssetDocumentDto {
  name: string
  type: 'Document' | 'Image'
  url: string | null
}

export interface AssetDto {
  id: number
  name: string
  asset_type: AssetType | string
  branch: string
  assigned_to_id: number | null
  department_id: number | null
  purchase_date: string | null
  value: string | number | null
  vendor: string | null
  invoice_number: string | null
  status: AssetStatus | string
  warranty_expiry_date: string | null
  notes: string | null
  serial_number: string | null
  imei: string | null
  manufacturer: string | null
  documents: AssetDocumentDto[]
  created_at: string
  updated_at: string
}

export interface AssetChoiceDto {
  value: string
  label: string
  description?: string | null
}

export interface AssetChoicesDto {
  branches: AssetChoiceDto[]
  employees: AssetChoiceDto[]
  departments: AssetChoiceDto[]
}

export interface AssetPageDto {
  count: number
  items: AssetDto[]
  limit?: number
  offset?: number
}

export interface AssetListParams {
  limit: number
  offset: number
  search: string
}

export interface AssetWriteInput {
  name: string
  asset_type: AssetType
  branch: string
  assigned_to_id: number | null
  department_id: number | null
  purchase_date: string | null
  value: string | null
  vendor: string | null
  invoice_number: string | null
  status: AssetStatus
  warranty_expiry_date: string | null
  notes: string | null
  serial_number: string | null
  imei: string | null
  manufacturer: string | null
  documents: AssetDocumentDto[]
}

function listParams(params: AssetListParams) {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  return search
}

export const assetsApi = {
  list: (params: AssetListParams, signal?: AbortSignal) =>
    apiClient.get<AssetPageDto>(`/assets/?${listParams(params)}`, { signal }),
  choices: (signal?: AbortSignal) => apiClient.get<AssetChoicesDto>('/assets/choices', { signal }),
  create: (input: AssetWriteInput) => apiClient.post<AssetDto>('/assets/', input),
  update: (id: number, input: AssetWriteInput) => apiClient.put<AssetDto>(`/assets/${id}`, input),
  remove: (id: number) => apiClient.delete<{ detail: string }>(`/assets/${id}`),
  upload: async (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return apiClient.post<{ url: string }>('/others/upload-file', formData)
  },
}

export const assetQueryKeys = {
  all: ['company', 'assets'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...assetQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...assetQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: AssetListParams) =>
    [...assetQueryKeys.lists(userId, employeeId), params] as const,
  choices: (userId: number, employeeId: string) =>
    [...assetQueryKeys.scoped(userId, employeeId), 'choices'] as const,
}
