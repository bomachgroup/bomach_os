import { apiClient } from '@/shared/api/api-client'

export type LeaveRequestKind = 'leave' | 'absence' | 'running_late'
export type LeaveRequestKindFilter = 'all' | 'leave' | 'attendance_exception'
export type LeaveRequestStatus = 'pending' | 'approved' | 'rejected' | 'cancelled'
export type LeaveRequestStatusFilter = 'all' | LeaveRequestStatus

export interface LeaveRequest {
  id: number
  employeeId: number
  requestKind: LeaveRequestKind
  leaveType: string
  startDate: string
  endDate: string
  reason: string
  status: LeaveRequestStatus
  approverName: string | null
  approvalDate: string | null
  rejectionReason: string | null
  durationDays: number
  createdAt: string
  updatedAt: string
}

export interface LeaveRequestPage {
  count: number
  items: LeaveRequest[]
}

export interface LeaveRequestStats {
  employee_id: number
  total: number
  pending: number
  approved: number
  rejected: number
  cancelled: number
  leave: number
  absence: number
  running_late: number
}

export interface LeaveRequestListParams {
  employeeId: number
  kind: LeaveRequestKindFilter
  status: LeaveRequestStatusFilter
  limit: number
  offset: number
}

export interface LeaveRequestInput {
  request_kind: LeaveRequestKind
  leave_type: string | null
  start_date: string | null
  end_date: string | null
  reason: string
}

interface LeaveRequestDto {
  id: number
  employee_id: number
  request_kind: LeaveRequestKind
  leave_type: string
  start_date: string
  end_date: string
  reason: string
  status: LeaveRequestStatus
  approver_name?: string | null
  approval_date?: string | null
  rejection_reason?: string | null
  duration_days: number
  created_at: string
  updated_at: string
}

function mapLeaveRequest(dto: LeaveRequestDto): LeaveRequest {
  return {
    id: dto.id,
    employeeId: dto.employee_id,
    requestKind: dto.request_kind,
    leaveType: dto.leave_type ?? '',
    startDate: dto.start_date,
    endDate: dto.end_date,
    reason: dto.reason,
    status: dto.status,
    approverName: dto.approver_name ?? null,
    approvalDate: dto.approval_date ?? null,
    rejectionReason: dto.rejection_reason ?? null,
    durationDays: dto.duration_days,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function listSearchParams(params: LeaveRequestListParams): URLSearchParams {
  const search = new URLSearchParams({
    employee_id: String(params.employeeId),
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.kind !== 'all') search.set('request_kind', params.kind)
  if (params.status !== 'all') search.set('status', params.status)
  return search
}

export const leaveRequestsApi = {
  list: async (params: LeaveRequestListParams, signal?: AbortSignal): Promise<LeaveRequestPage> => {
    const response = await apiClient.get<{ count: number; items: LeaveRequestDto[] }>(
      `/leave-requests/?${listSearchParams(params)}`,
      { signal },
    )
    return { count: response.count, items: response.items.map(mapLeaveRequest) }
  },

  stats: (employeeId: number, signal?: AbortSignal) =>
    apiClient.get<LeaveRequestStats>(`/leave-requests/stats/by-employee/${employeeId}`, { signal }),

  detail: async (requestId: number, signal?: AbortSignal) =>
    mapLeaveRequest(
      await apiClient.get<LeaveRequestDto>(`/leave-requests/${requestId}`, { signal }),
    ),

  create: async (input: LeaveRequestInput) =>
    mapLeaveRequest(await apiClient.post<LeaveRequestDto>('/leave-requests/', input)),

  update: async (requestId: number, input: Partial<LeaveRequestInput>) =>
    mapLeaveRequest(await apiClient.patch<LeaveRequestDto>(`/leave-requests/${requestId}`, input)),

  cancel: (requestId: number) =>
    apiClient.delete<{ detail: string }>(`/leave-requests/${requestId}`),
}
