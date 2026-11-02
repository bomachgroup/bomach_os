import { apiClient } from '@/shared/api/api-client'

export interface OperationsOverviewDto {
  total_projects: number | null
  allocated_project_budget: string | null
  total_worksites: number | null
  total_contracts: number | null
  total_timelines: number | null
  scope_limited: boolean
}

export const operationsOverviewQueryKey = (userId: number, employeeId: string) =>
  ['operations', 'dashboard', 'overview', userId, employeeId] as const

export const operationsDashboardApi = {
  overview: (signal?: AbortSignal) =>
    apiClient.get<OperationsOverviewDto>('/operations/dashboard/overview', { signal }),
}
