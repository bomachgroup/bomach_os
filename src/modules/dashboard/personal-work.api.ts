import { apiClient } from '@/shared/api/api-client'

export interface PaginatedDto<TItem> {
  count: number
  items: TItem[]
}

export interface TodayAttendanceDto {
  date: string
  state: 'clocked_in' | 'clocked_out' | 'not_clocked_in' | string
  next_action: 'clock_in' | 'clock_out' | null
  day_policy: {
    required: boolean
    reason: string | null
    label: string
    non_working_day_name: string | null
  } | null
  clock_in: { timestamp: string } | null
  clock_out: { timestamp: string } | null
}

export interface PersonalTaskDto {
  id: number
  name: string
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled' | string
  priority: 'low' | 'medium' | 'high' | string
  due_date: string | null
  updated_at: string
  created_at: string
  project?: { name: string } | null
}

export interface PersonalWorkReportDto {
  id: number
  day: string
  status: 'draft' | 'submitted' | 'approved' | 'rejected' | string
  work_summary: string | null
  created_at: string
  updated_at: string
  rating: number | null
}

export interface PersonalLeaveRequestDto {
  id: number
  request_kind: 'leave' | 'absence' | 'running_late' | string
  leave_type: string
  start_date: string
  end_date: string
  status: 'pending' | 'approved' | 'rejected' | 'cancelled' | string
  created_at: string
  updated_at: string
}

export interface PersonalLoanDto {
  id: number
  loan_amount: string
  repayment_date: string
  reason: string
  status: string
  created_at: string
  updated_at: string
}

const personalWorkScope = (userId: number, employeeId: string) =>
  ['dashboard', 'personal', userId, employeeId] as const

export const personalWorkQueryKeys = {
  scoped: personalWorkScope,
  attendanceToday: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'attendance-today'] as const,
  tasks: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'tasks'] as const,
  completedTasks: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'completed-tasks'] as const,
  reports: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'reports'] as const,
  leaveRequests: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'leave-requests'] as const,
  loans: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'loans'] as const,
  notifications: (userId: number, employeeId: string) =>
    [...personalWorkScope(userId, employeeId), 'notifications'] as const,
}

export const personalWorkApi = {
  attendanceToday: (signal?: AbortSignal) =>
    apiClient.get<TodayAttendanceDto>('/biometric/attendance/today', { signal }),

  tasks: async (signal?: AbortSignal) => {
    const query = (status: string) =>
      apiClient.get<PaginatedDto<PersonalTaskDto>>(
        `/my-tasks?${new URLSearchParams({ status, limit: '10', offset: '0' })}`,
        { signal },
      )
    const [pending, inProgress] = await Promise.all([query('pending'), query('in_progress')])
    return {
      count: pending.count + inProgress.count,
      items: [...pending.items, ...inProgress.items],
    }
  },

  completedTasks: (signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<PersonalTaskDto>>(
      `/my-tasks?${new URLSearchParams({ status: 'completed', limit: '5', offset: '0' })}`,
      { signal },
    ),

  reports: (dateFrom: string, dateTo: string, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<PersonalWorkReportDto>>(
      `/work-reports/?${new URLSearchParams({
        date_from: dateFrom,
        date_to: dateTo,
        limit: '10',
        offset: '0',
      })}`,
      { signal },
    ),

  leaveRequests: (signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<PersonalLeaveRequestDto>>('/leave-requests/?limit=10&offset=0', {
      signal,
    }),

  loans: (signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<PersonalLoanDto>>('/loans?limit=10&offset=0', { signal }),
}
