import { apiClient } from '@/shared/api/api-client'

export interface AuditLogDto {
  id: number
  activity: string
  audit_type: string
  audit_type_display: string
  audit_status: string
  audit_status_display: string
  ip_address: string | null
  metadata: Record<string, unknown> | null
  user: {
    id: number | null
    email: string | null
    full_name: string | null
  } | null
  created_at: string
  updated_at: string
}

export interface AuditLogPageDto {
  count: number
  items: AuditLogDto[]
}

export interface AuditLogListParams {
  search: string
  userId: string
  auditType: string
  auditStatus: string
  startDate: string
  endDate: string
  limit: number
  offset: number
}

export function auditLogSearchParams(params: AuditLogListParams) {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if (params.userId) search.set('user_id', params.userId)
  if (params.auditType) search.set('audit_type', params.auditType)
  if (params.auditStatus) search.set('audit_status', params.auditStatus)
  if (params.startDate) search.set('start_date', params.startDate)
  if (params.endDate) search.set('end_date', params.endDate)
  return search
}

export const auditLogApi = {
  list: (params: AuditLogListParams, signal?: AbortSignal) =>
    apiClient.get<AuditLogPageDto>(`/audit-logs/?${auditLogSearchParams(params)}`, { signal }),
}

export const auditLogQueryKeys = {
  all: ['company', 'audit-log'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...auditLogQueryKeys.all, userId, employeeId] as const,
  list: (userId: number, employeeId: string, params: AuditLogListParams) =>
    [...auditLogQueryKeys.scoped(userId, employeeId), params] as const,
}
