import { apiClient } from '@/shared/api/api-client'

export interface CompanyOverviewDto {
  total_employees: number | null
  new_employees_30_days: number | null
  total_branches: number | null
  inactive_branches_30_days: number | null
  pending_approvals: number | null
  overdue_approvals: number | null
  asset_inventory: number | null
  new_inventory_30_days: number | null
  departments_count?: number | null
  units_count?: number | null
  asset_count?: number | null
  assets_added_30_days?: number | null
  approval_queue?:
    | {
        id: number
        request_id: string
        title: string
        action_type: string
        requester_name: string | null
        created_at: string
      }[]
    | null
}

export const companyOverviewQueryKey = ['company', 'dashboard', 'overview'] as const

export const companyDashboardApi = {
  overview: (signal?: AbortSignal) =>
    apiClient.get<CompanyOverviewDto>('/company/dashboard/overview', { signal }),
}
