import { apiClient } from '@/shared/api/api-client'

export interface HROverviewDto {
  total_employees: number | null
  new_hires_mtd: number | null
  headcount_by_department: { department: string; count: number }[] | null
  open_roles: number | null
  pending_leaves: number | null
  review_queue?:
    | {
        id: number
        request_kind: string
        request_label: string
        employee_name: string
        start_date: string
        end_date: string
        created_at: string
      }[]
    | null
}

export const hrOverviewQueryKey = ['hr', 'dashboard', 'overview'] as const

export const hrDashboardApi = {
  overview: (signal?: AbortSignal) =>
    apiClient.get<HROverviewDto>('/hr/dashboard/overview', { signal }),
}
