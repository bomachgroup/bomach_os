import { apiClient } from '@/shared/api/api-client'

export type TargetPeriod = 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'yearly' | 'custom'
export type TargetReportStatus = 'submitted' | 'approved' | 'rejected'
export type TargetReportStatusFilter = 'all' | TargetReportStatus
export type TargetScope = 'active' | 'all'
export type TargetPeriodFilter = 'all' | TargetPeriod

export interface EmployeeTarget {
  id: number
  title: string
  description: string
  targetValue: number
  unit: string
  period: TargetPeriod
  periodStart: string
  periodEnd: string
  isActive: boolean
  approvedProgressValue: number
  remainingValue: number
  progressPercentage: number
  isCompleted: boolean
  hasPendingReport: boolean
}

export interface TargetReport {
  id: number
  employeeTargetId: number
  target: Pick<
    EmployeeTarget,
    'id' | 'title' | 'targetValue' | 'unit' | 'period' | 'periodStart' | 'periodEnd'
  >
  summary: string
  progressValue: number
  status: TargetReportStatus
  rejectionReason: string
  createdAt: string
  updatedAt: string
}

export interface TargetPage<T> {
  count: number
  items: T[]
}

export interface TargetListParams {
  scope: TargetScope
  period: TargetPeriodFilter
  limit: number
  offset: number
}

export interface TargetReportListParams {
  status: TargetReportStatusFilter
  limit: number
  offset: number
}

interface EmployeeTargetDto {
  id: number
  title: string
  description?: string | null
  target_value: number | string
  unit?: string | null
  period: TargetPeriod
  period_start: string
  period_end: string
  is_active: boolean
  approved_progress_value: number | string
  remaining_value: number | string
  progress_percentage: number | string
  is_completed: boolean
  has_pending_report: boolean
}

interface TargetReportDto {
  id: number
  employee_target_id: number
  employee_target: {
    id: number
    title: string
    target_value: number | string
    unit?: string | null
    period: TargetPeriod
    period_start: string
    period_end: string
  }
  summary: string
  progress_value: number | string
  status: TargetReportStatus
  rejection_reason?: string | null
  created_at: string
  updated_at: string
}

function numeric(value: number | string | null | undefined): number {
  const parsed = Number(value ?? 0)
  return Number.isFinite(parsed) ? parsed : 0
}

function mapTarget(dto: EmployeeTargetDto): EmployeeTarget {
  return {
    id: dto.id,
    title: dto.title,
    description: dto.description ?? '',
    targetValue: numeric(dto.target_value),
    unit: dto.unit?.trim() ?? '',
    period: dto.period,
    periodStart: dto.period_start,
    periodEnd: dto.period_end,
    isActive: dto.is_active,
    approvedProgressValue: numeric(dto.approved_progress_value),
    remainingValue: numeric(dto.remaining_value),
    progressPercentage: numeric(dto.progress_percentage),
    isCompleted: dto.is_completed,
    hasPendingReport: dto.has_pending_report,
  }
}

function mapReport(dto: TargetReportDto): TargetReport {
  return {
    id: dto.id,
    employeeTargetId: dto.employee_target_id,
    target: {
      id: dto.employee_target.id,
      title: dto.employee_target.title,
      targetValue: numeric(dto.employee_target.target_value),
      unit: dto.employee_target.unit?.trim() ?? '',
      period: dto.employee_target.period,
      periodStart: dto.employee_target.period_start,
      periodEnd: dto.employee_target.period_end,
    },
    summary: dto.summary,
    progressValue: numeric(dto.progress_value),
    status: dto.status,
    rejectionReason: dto.rejection_reason ?? '',
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

export const targetsApi = {
  listAssigned: async (params: TargetListParams, signal?: AbortSignal) => {
    const query = new URLSearchParams({
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.scope === 'active') query.set('is_active', 'true')
    if (params.period !== 'all') query.set('period', params.period)
    const response = await apiClient.get<TargetPage<EmployeeTargetDto>>(
      `/employees/me/targets?${query}`,
      { signal },
    )
    return { count: response.count, items: response.items.map(mapTarget) }
  },

  listReports: async (params: TargetReportListParams, signal?: AbortSignal) => {
    const query = new URLSearchParams({
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.status !== 'all') query.set('status', params.status)
    const response = await apiClient.get<TargetPage<TargetReportDto>>(
      `/target-reports/me?${query}`,
      { signal },
    )
    return { count: response.count, items: response.items.map(mapReport) }
  },

  reportDetail: async (reportId: number, signal?: AbortSignal) =>
    mapReport(await apiClient.get<TargetReportDto>(`/target-reports/${reportId}`, { signal })),

  createReport: async (input: {
    employee_target_id: number
    progress_value: number
    summary: string
  }) => mapReport(await apiClient.post<TargetReportDto>('/target-reports/', input)),
}
