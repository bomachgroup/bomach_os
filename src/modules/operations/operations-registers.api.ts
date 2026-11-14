import { apiClient } from '@/shared/api/api-client'
import type { SiteReport } from '@/modules/work-reports/site-reports.api'

export interface OperationsPage<T> {
  items: T[]
  count: number
  limit: number
  offset: number
}

export interface OperationsProjectOption {
  id: number
  name: string
  short_code: string
  status: string
}

export interface OperationsWorksite {
  id: number
  project_id: number | null
  project_name?: string | null
  project_short_code?: string | null
  project?: OperationsProjectOption | null
  name: string
  location: string
  latitude: string | null
  longitude: string | null
  status: 'setup' | 'active' | 'inactive' | 'completed' | string
  description: string | null
  created_at: string
  updated_at: string
}

export interface OperationsTask {
  id: number
  project_id: number | null
  project: OperationsProjectOption | null
  milestone_id: number | null
  worksite_id: number | null
  worksite: Pick<OperationsWorksite, 'id' | 'name' | 'location' | 'status'> | null
  name: string
  description: string | null
  status: 'pending' | 'in_progress' | 'completed' | 'cancelled'
  priority: 'low' | 'medium' | 'high'
  assigned_to: number[]
  assignees: Array<{ id: number; employee_id: string; name: string; designation: string }>
  created_by: { id: number; name: string } | null
  due_date: string | null
  estimated_hours: string | null
  created_at: string
  updated_at: string
}

export interface WorksiteListParams {
  limit: number
  offset: number
  search: string
  status: string
  project_id: number | null
}

export interface TaskListParams {
  limit: number
  offset: number
  search: string
  status: string
  priority: string
  project_id: number | null
  worksite_id: number | null
}

export interface EngineeringReportListParams {
  limit: number
  offset: number
  status: string
  employee_id: number | null
  worksite_id: number | null
  project_id: number | null
  date_from: string
  date_to: string
}

function query(values: Record<string, string | number | null | undefined>) {
  const params = new URLSearchParams()
  for (const [key, value] of Object.entries(values)) {
    if (value === null || value === undefined || value === '') continue
    params.set(key, String(value))
  }
  return params.toString()
}

export const operationsRegistersApi = {
  worksites: (params: WorksiteListParams, signal?: AbortSignal) =>
    apiClient.get<OperationsPage<OperationsWorksite>>(`/worksites?${query({ ...params })}`, {
      signal,
    }),
  worksite: (id: number, signal?: AbortSignal) =>
    apiClient.get<OperationsWorksite>(`/worksites/${id}`, { signal }),
  createWorksite: (
    input: Pick<OperationsWorksite, 'name' | 'location' | 'status' | 'description'> & {
      project_id: number | null
    },
  ) => apiClient.post<OperationsWorksite>('/worksites', input),
  updateWorksite: (id: number, input: Partial<OperationsWorksite>) =>
    apiClient.put<OperationsWorksite>(`/worksites/${id}`, input),
  removeWorksite: (id: number) => apiClient.delete<{ detail: string }>(`/worksites/${id}`),
  tasks: (params: TaskListParams, signal?: AbortSignal) =>
    apiClient.get<OperationsPage<OperationsTask>>(`/tasks?${query({ ...params })}`, { signal }),
  task: (id: number, signal?: AbortSignal) =>
    apiClient.get<OperationsTask>(`/tasks/${id}`, { signal }),
  createTask: (input: Partial<OperationsTask> & { name: string }) =>
    apiClient.post<OperationsTask>('/tasks', input),
  updateTask: (id: number, input: Partial<OperationsTask>) =>
    apiClient.put<OperationsTask>(`/tasks/${id}`, input),
  removeTask: (id: number) => apiClient.delete<{ detail: string }>(`/tasks/${id}`),
  engineeringReports: (params: EngineeringReportListParams, signal?: AbortSignal) =>
    apiClient.get<OperationsPage<SiteReport>>(`/engineering-site-reports?${query({ ...params })}`, {
      signal,
    }),
  engineeringReport: (id: number, signal?: AbortSignal) =>
    apiClient.get<SiteReport>(`/engineering-site-reports/${id}`, { signal }),
  submitEngineeringReport: (id: number) =>
    apiClient.post<SiteReport>(`/engineering-site-reports/${id}/submit`, {}),
  approveEngineeringReport: (id: number, rating: number | null) =>
    apiClient.post<SiteReport>(`/engineering-site-reports/${id}/approve`, { rating }),
  rejectEngineeringReport: (id: number, feedback: string) =>
    apiClient.post<SiteReport>(`/engineering-site-reports/${id}/reject`, { feedback }),
  removeEngineeringReport: (id: number) =>
    apiClient.delete<{ detail: string }>(`/engineering-site-reports/${id}`),
}
