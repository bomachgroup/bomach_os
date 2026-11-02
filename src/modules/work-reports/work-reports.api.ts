import { apiClient } from '@/shared/api/api-client'

export type WorkReportStatus = 'draft' | 'submitted' | 'approved' | 'rejected'
export type WorkReportStatusFilter = 'all' | WorkReportStatus

export interface WorkReport {
  id: number
  employeeId: number
  employeeName?: string | null
  day: string
  hoursWorked: number
  operationalBase: string | null
  workActivities: string | null
  taskDetails: string | null
  planNextDay: string | null
  summary: string | null
  status: WorkReportStatus
  feedback: string | null
  rating: number | null
  reviewedBy: string | null
  reviewedAt: string | null
  attachments: string[]
  createdAt: string
  updatedAt: string
}

interface WorkReportDto {
  id: number
  employee_id: number
  employee_name?: string | null
  day: string
  hours_worked: number | string
  operational_base?: string | null
  work_summary?: string | null
  work_activities?: string | null
  task_details?: string | null
  plan_next_day?: string | null
  status: WorkReportStatus
  feedback?: string | null
  rating?: number | null
  reviewed_by?:
    string | { first_name?: string | null; last_name?: string | null; email?: string | null } | null
  reviewed_at?: string | null
  attachments?: ({ file_url: string } | string)[] | null
  created_at: string
  updated_at: string
}

export interface WorkReportPage {
  count: number
  items: WorkReport[]
}

export interface WorkReportListParams {
  employeeId: number
  status: WorkReportStatusFilter
  query: string
  dateFrom: string
  dateTo: string
  limit: number
  offset: number
}

export interface WorkReportInput {
  day: string
  hours_worked: number
  operational_base: string | null
  work_activities: string
  task_details: string
  plan_next_day: string
  status: 'draft' | 'submitted'
  attachments: string[]
}

export interface WorkReportApprovalInput {
  rating?: number | null
  feedback?: string | null
}

export interface WorkLocationOption {
  id: number | null
  name: string
  branchName: string | null
  latitude: number | null
  longitude: number | null
}

interface WorkLocationDto {
  id?: number
  name?: string | null
  workspace_name?: string | null
  branch_name?: string | null
  latitude?: number | string | null
  longitude?: number | string | null
  status?: string | null
  is_active?: boolean
  is_expired?: boolean
  can_be_used?: boolean
}

interface WorkLocationListDto {
  locations?: WorkLocationDto[]
}

function reviewerName(value: WorkReportDto['reviewed_by']): string | null {
  if (!value) return null
  if (typeof value === 'string') return value
  const name = [value.first_name, value.last_name].filter(Boolean).join(' ').trim()
  return name || value.email || null
}

function mapReport(dto: WorkReportDto): WorkReport {
  return {
    id: dto.id,
    employeeId: dto.employee_id,
    employeeName: dto.employee_name ?? null,
    day: dto.day,
    hoursWorked: Number(dto.hours_worked),
    operationalBase: dto.operational_base ?? null,
    workActivities: dto.work_activities ?? null,
    taskDetails: dto.task_details ?? null,
    planNextDay: dto.plan_next_day ?? null,
    summary: dto.work_summary ?? dto.work_activities ?? null,
    status: dto.status,
    feedback: dto.feedback ?? null,
    rating: dto.rating ?? null,
    reviewedBy: reviewerName(dto.reviewed_by),
    reviewedAt: dto.reviewed_at ?? null,
    attachments: (dto.attachments ?? []).map((attachment) =>
      typeof attachment === 'string' ? attachment : attachment.file_url,
    ),
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function queryString(params: WorkReportListParams): string {
  const search = new URLSearchParams()
  if (params.employeeId > 0) search.set('employee_id', String(params.employeeId))
  search.set('limit', String(params.limit))
  search.set('offset', String(params.offset))
  if (params.status !== 'all') search.set('status', params.status)
  if (params.query.trim()) search.set('search', params.query.trim())
  if (params.dateFrom) search.set('date_from', params.dateFrom)
  if (params.dateTo) search.set('date_to', params.dateTo)
  return search.toString()
}

function canUseLocation(location: WorkLocationDto): boolean {
  if (typeof location.can_be_used === 'boolean') return location.can_be_used
  return (
    location.status?.toLowerCase() === 'approved' &&
    location.is_active !== false &&
    location.is_expired !== true
  )
}

function numericOrNull(value: number | string | null | undefined): number | null {
  if (value == null || value === '') return null
  const number = Number(value)
  return Number.isFinite(number) ? number : null
}

export const workReportsApi = {
  list: async (params: WorkReportListParams, signal?: AbortSignal) => {
    const response = await apiClient.get<{ count: number; items: WorkReportDto[] }>(
      `/work-reports/?${queryString(params)}`,
      { signal },
    )
    return { count: response.count, items: response.items.map(mapReport) }
  },

  detail: async (reportId: number, signal?: AbortSignal) =>
    mapReport(await apiClient.get<WorkReportDto>(`/work-reports/${reportId}`, { signal })),

  create: async (input: WorkReportInput) =>
    mapReport(await apiClient.post<WorkReportDto>('/work-reports/', input)),

  update: async (reportId: number, input: WorkReportInput) =>
    mapReport(await apiClient.put<WorkReportDto>(`/work-reports/${reportId}`, input)),

  withdraw: async (reportId: number) =>
    mapReport(await apiClient.put<WorkReportDto>(`/work-reports/${reportId}`, { status: 'draft' })),

  remove: (reportId: number) => apiClient.delete<{ detail: string }>(`/work-reports/${reportId}`),

  approve: async (reportId: number, input: WorkReportApprovalInput) =>
    mapReport(await apiClient.post<WorkReportDto>(`/work-reports/${reportId}/approve`, input)),

  reject: async (reportId: number, feedback: string) =>
    mapReport(
      await apiClient.post<WorkReportDto>(`/work-reports/${reportId}/reject`, { feedback }),
    ),

  upload: async (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return apiClient.post<{ url: string }>('/others/upload-file', formData)
  },

  workspaces: async (signal?: AbortSignal): Promise<WorkLocationOption[]> => {
    const response = await apiClient.get<WorkLocationListDto | WorkLocationDto[]>(
      '/biometric/location/whitelisted',
      { signal },
    )
    const locations = Array.isArray(response) ? response : (response.locations ?? [])
    return locations.filter(canUseLocation).map((location) => ({
      id: location.id ?? null,
      name: location.name?.trim() || location.workspace_name?.trim() || 'Workspace',
      branchName: location.branch_name?.trim() || null,
      latitude: numericOrNull(location.latitude),
      longitude: numericOrNull(location.longitude),
    }))
  },
}
