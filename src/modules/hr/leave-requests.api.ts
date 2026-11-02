import { apiClient } from '@/shared/api/api-client'
import type {
  LeaveRequest,
  LeaveRequestInput,
  LeaveRequestKind,
  LeaveRequestStatus,
} from '@/modules/leaves/leaves.api'

export interface HRLeaveRequest extends LeaveRequest {
  employeeName: string
  employeeCode: string | null
  branchName: string | null
  approverId: number | null
}

export interface HRLeaveRequestParams {
  limit: number
  offset: number
  search: string
  status: 'all' | 'pending' | 'history' | LeaveRequestStatus
  kind: 'all' | LeaveRequestKind | 'attendance_exception'
}

export interface HRLeaveRequestPage {
  count: number
  items: HRLeaveRequest[]
}

export interface HRLeaveRequestSummary {
  total: number
  pending: number
  approved: number
  approved_this_month: number
  on_leave: number
  rejected: number
  cancelled: number
  leave: number
  absence: number
  running_late: number
}

interface LeaveRequestDto {
  id: number
  employee_id: number
  employee_name?: string | null
  employee_code?: string | null
  branch_name?: string | null
  request_kind: LeaveRequestKind
  leave_type: string
  start_date: string
  end_date: string
  reason: string
  status: LeaveRequestStatus
  approver_id?: number | null
  approver_name?: string | null
  approval_date?: string | null
  rejection_reason?: string | null
  duration_days: number
  created_at: string
  updated_at: string
}

interface PaginatedDto<T> {
  count: number
  items: T[]
}

function mapRequest(dto: LeaveRequestDto): HRLeaveRequest {
  return {
    id: dto.id,
    employeeId: dto.employee_id,
    employeeName: dto.employee_name ?? 'Employee',
    employeeCode: dto.employee_code ?? null,
    branchName: dto.branch_name ?? null,
    requestKind: dto.request_kind,
    leaveType: dto.leave_type ?? '',
    startDate: dto.start_date,
    endDate: dto.end_date,
    reason: dto.reason,
    status: dto.status,
    approverId: dto.approver_id ?? null,
    approverName: dto.approver_name ?? null,
    approvalDate: dto.approval_date ?? null,
    rejectionReason: dto.rejection_reason ?? null,
    durationDays: dto.duration_days,
    createdAt: dto.created_at,
    updatedAt: dto.updated_at,
  }
}

function requestParams(params: HRLeaveRequestParams) {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if (params.status !== 'all') search.set('status', params.status)
  if (params.kind !== 'all') search.set('request_kind', params.kind)
  return search
}

export const hrLeaveRequestsApi = {
  list: async (params: HRLeaveRequestParams, signal?: AbortSignal): Promise<HRLeaveRequestPage> => {
    const page = await apiClient.get<PaginatedDto<LeaveRequestDto>>(
      `/leave-requests/?${requestParams(params)}`,
      { signal },
    )
    return { count: page.count, items: page.items.map(mapRequest) }
  },
  detail: async (id: number, signal?: AbortSignal) =>
    mapRequest(await apiClient.get<LeaveRequestDto>(`/leave-requests/${id}`, { signal })),
  summary: (signal?: AbortSignal) =>
    apiClient.get<HRLeaveRequestSummary>('/leave-requests/stats/summary', { signal }),
  create: async (input: LeaveRequestInput) =>
    mapRequest(await apiClient.post<LeaveRequestDto>('/leave-requests/', input)),
  update: async (id: number, input: Partial<Omit<LeaveRequestInput, 'request_kind'>>) =>
    mapRequest(await apiClient.patch<LeaveRequestDto>(`/leave-requests/${id}`, input)),
  review: async (id: number, status: 'approved' | 'rejected', rejection_reason?: string) =>
    mapRequest(
      await apiClient.patch<LeaveRequestDto>(`/leave-requests/${id}/status`, {
        status,
        rejection_reason,
      }),
    ),
  cancel: (id: number) => apiClient.delete<{ detail: string }>(`/leave-requests/${id}`),
}
