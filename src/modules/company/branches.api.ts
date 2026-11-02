import { apiClient } from '@/shared/api/api-client'

export type BranchOperationalStatus =
  'active' | 'inactive' | 'under_maintenance' | 'temporarily_closed' | 'permanently_closed' | string

export interface BranchDto {
  id: number
  branch_name: string
  branch_id: string
  default_currency: string | null
  language_preference: string | null
  country: string
  country_code: string | null
  state: string
  state_code: string | null
  city: string | null
  lga: string | null
  office_address: string
  full_address: string
  operational_status: BranchOperationalStatus
  operational_status_display: string
  branch_role: string
  branch_role_display: string
  contact_email: string
  contact_phone: string
  manager_id: number | null
  manager_name: string | null
  is_active: boolean
  is_operational: boolean
  latitude: number | null
  longitude: number | null
  attendance_radius_meters: number
  notes: string | null
  created_at: string
  updated_at: string
}

export interface BranchPageDto {
  count: number
  items: BranchDto[]
  limit?: number
  offset?: number
}

export interface BranchChoice {
  value: string
  label: string
}

export interface BranchChoicesDto {
  operational_status: BranchChoice[]
  branch_role: BranchChoice[]
  currencies: BranchChoice[]
  languages: BranchChoice[]
}

export interface BranchManagerChoice {
  user_id: number
  employee_id: string
  name: string
  designation: string
  branch_id: number | null
  branch_name: string | null
}

export interface BranchManagerPageDto {
  count: number
  items: BranchManagerChoice[]
  limit?: number
  offset?: number
}

export interface BranchBusinessHoursDto {
  id: number
  day_of_week: number
  day_name: string
  open_time: string | null
  close_time: string | null
  is_open: boolean
}

export interface BranchBusinessHoursInput {
  day_of_week: number
  open_time: string | null
  close_time: string | null
  is_open: boolean
}

export interface BranchWriteInput {
  branch_name: string
  default_currency: string
  language_preference: string
  country: string
  country_code?: string
  state: string
  state_code?: string
  city: string
  lga: string
  office_address: string
  operational_status: string
  branch_role: string
  contact_email: string
  contact_phone: string
  manager_id: number | null
  is_active: boolean
  notes: string
  latitude: number | null
  longitude: number | null
  attendance_radius_meters: number
  business_hours?: BranchBusinessHoursInput[]
}

export type BranchUpdateInput = Partial<BranchWriteInput>

export interface BranchListParams {
  limit: number
  offset: number
  search: string
  operationalStatus: string
  branchRole: string
  recordState: string
}

export interface BranchManagerParams {
  limit: number
  offset: number
  search: string
  branchId?: number
  currentManagerId?: number | null
}

function listSearchParams(params: BranchListParams): URLSearchParams {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if (params.operationalStatus !== 'all') {
    search.set('operational_status', params.operationalStatus)
  }
  if (params.branchRole !== 'all') search.set('branch_role', params.branchRole)
  if (params.recordState !== 'all') {
    search.set('is_active', String(params.recordState === 'active'))
  }
  return search
}

function managerSearchParams(params: BranchManagerParams): URLSearchParams {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if (params.branchId) search.set('branch_id', String(params.branchId))
  if (params.currentManagerId) search.set('current_manager_id', String(params.currentManagerId))
  return search
}

export const branchesApi = {
  list: (params: BranchListParams, signal?: AbortSignal) =>
    apiClient.get<BranchPageDto>(`/branch/branches?${listSearchParams(params)}`, { signal }),
  detail: (branchId: number, signal?: AbortSignal) =>
    apiClient.get<BranchDto>(`/branch/branches/${branchId}`, { signal }),
  create: (input: BranchWriteInput) => apiClient.post<BranchDto>('/branch/branches', input),
  update: (branchId: number, input: BranchUpdateInput) =>
    apiClient.put<BranchDto>(`/branch/branches/${branchId}`, input),
  businessHours: (branchId: number, signal?: AbortSignal) =>
    apiClient.get<BranchBusinessHoursDto[]>(`/branch/branches/${branchId}/business-hours`, {
      signal,
    }),
  updateBusinessHours: (branchId: number, input: BranchBusinessHoursInput[]) =>
    apiClient.put<BranchBusinessHoursDto[]>(`/branch/branches/${branchId}/business-hours`, input),
  choices: (signal?: AbortSignal) =>
    apiClient.get<BranchChoicesDto>('/branch/branches/choices/fields', { signal }),
  managerChoices: (params: BranchManagerParams, signal?: AbortSignal) =>
    apiClient.get<BranchManagerPageDto>(
      `/branch/branches/choices/managers?${managerSearchParams(params)}`,
      { signal },
    ),
}

export const branchQueryKeys = {
  all: ['company', 'branches'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...branchQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...branchQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: BranchListParams) =>
    [...branchQueryKeys.lists(userId, employeeId), params] as const,
  detail: (userId: number, employeeId: string, branchId: number) =>
    [...branchQueryKeys.scoped(userId, employeeId), 'detail', branchId] as const,
  hours: (userId: number, employeeId: string, branchId: number) =>
    [...branchQueryKeys.scoped(userId, employeeId), 'business-hours', branchId] as const,
  choices: (userId: number, employeeId: string) =>
    [...branchQueryKeys.scoped(userId, employeeId), 'choices'] as const,
  managers: (userId: number, employeeId: string, params: BranchManagerParams) =>
    [...branchQueryKeys.scoped(userId, employeeId), 'managers', params] as const,
}
