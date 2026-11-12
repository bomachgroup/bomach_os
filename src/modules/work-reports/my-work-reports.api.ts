import { apiClient } from '@/shared/api/api-client'
import type { WorkReportStatus, WorkReportStatusFilter } from './work-reports.api'

export type MyWorkReportType = 'daily' | 'engineering' | 'survey'
export type MyWorkReportTypeFilter = 'all' | 'daily' | 'site' | 'engineering' | 'survey'

export interface MyWorkReport {
  id: number
  reportId: number
  type: MyWorkReportType
  date: string
  status: WorkReportStatus
  summary: string
  worksiteName: string | null
  hoursWorked: number | null
  taskId: number | null
  rating: number | null
  reviewedAt: string | null
  attachments: string[]
  payload: Record<string, unknown>
}

export interface MyWorkReportsPage {
  count: number
  items: MyWorkReport[]
}

export interface MyWorkReportsParams {
  type: MyWorkReportTypeFilter
  status: WorkReportStatusFilter
  limit: number
  offset: number
}

interface ReportDto {
  id: number
  report_type: 'daily_work' | 'engineering_site' | 'survey_site'
  status: WorkReportStatus
  rating: number | null
  reviewed_at: string | null
  summary: string | null
  payload: Record<string, unknown> | null
}

interface ReportPageDto {
  count: number
  items: ReportDto[]
}

function stringValue(value: unknown): string | null {
  return typeof value === 'string' && value.trim() ? value.trim() : null
}

function numberValue(value: unknown): number | null {
  if (value == null || value === '') return null
  const number = Number(value)
  return Number.isFinite(number) ? number : null
}

function mapReport(dto: ReportDto): MyWorkReport {
  const payload = dto.payload ?? {}
  const type: MyWorkReportType =
    dto.report_type === 'daily_work'
      ? 'daily'
      : dto.report_type === 'engineering_site'
        ? 'engineering'
        : 'survey'
  const date = stringValue(payload.day) ?? stringValue(payload.date) ?? ''
  const sourceId = numberValue(payload.work_report_id)
  const attachments = Array.isArray(payload.attachments)
    ? payload.attachments.filter((item): item is string => typeof item === 'string')
    : []

  return {
    id: dto.id,
    reportId: type === 'daily' ? (sourceId ?? dto.id) : dto.id,
    type,
    date,
    status: dto.status,
    summary:
      stringValue(dto.summary) ??
      stringValue(payload.work_activities) ??
      'No activity summary provided.',
    worksiteName: stringValue(payload.worksite_name),
    hoursWorked: numberValue(payload.hours_worked),
    taskId: numberValue(payload.task_id),
    rating: numberValue(dto.rating),
    reviewedAt: dto.reviewed_at,
    attachments,
    payload,
  }
}

export const myWorkReportsApi = {
  list: async (params: MyWorkReportsParams, signal?: AbortSignal): Promise<MyWorkReportsPage> => {
    const search = new URLSearchParams({
      report_type: params.type,
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.status !== 'all') search.set('status', params.status)
    const response = await apiClient.get<ReportPageDto>(`/my-work-reports?${search}`, { signal })
    return { count: response.count, items: response.items.map(mapReport) }
  },
}
