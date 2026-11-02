import { apiClient } from '@/shared/api/api-client'

export interface KpiPageDto<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export interface KpiRoleDto {
  id: number
  name: string
}

export interface KpiMetricDto {
  id: number
  name: string
  description: string
  unit: string
  created_at?: string
  updated_at?: string
}

export interface RoleKpiDto {
  id: number
  role_id: number
  metric_id: number
  metric: KpiMetricDto
  tracking_mode: string
  target_value: string | number | null
  weight: string | number | null
  period: string
  sequence: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface RoleKpiListParams {
  limit: number
  offset: number
  search: string
}

export interface RoleKpiWriteInput {
  metric_id: number
  tracking_mode: string
  target_value: number | null
  weight: number | null
  period: string
  sequence?: number
  is_active: boolean
}

export interface KpiMetricWriteInput {
  name: string
  description: string
  unit: string
}

function pageParams(limit: number, offset: number, search = '') {
  const params = new URLSearchParams({ limit: String(limit), offset: String(offset) })
  if (search.trim()) params.set('search', search.trim())
  return params
}

async function collectPages<T>(
  loadPage: (limit: number, offset: number) => Promise<KpiPageDto<T>>,
  signal?: AbortSignal,
): Promise<T[]> {
  const limit = 100
  const collected: T[] = []
  let offset = 0
  let count: number
  do {
    if (signal?.aborted) throw new DOMException('The request was aborted.', 'AbortError')
    const result = await loadPage(limit, offset)
    collected.push(...result.items)
    count = result.count
    if (!result.items.length) break
    offset += result.items.length
  } while (offset < count)
  return collected
}

export const kpiManagementApi = {
  list: (params: RoleKpiListParams, signal?: AbortSignal) =>
    apiClient.get<KpiPageDto<RoleKpiDto>>(
      `/roles/kpis?${pageParams(params.limit, params.offset, params.search)}`,
      { signal },
    ),
  roleAssignments: (roleId: number, signal?: AbortSignal) =>
    collectPages(
      (limit, offset) =>
        apiClient.get<KpiPageDto<RoleKpiDto>>(
          `/roles/${roleId}/kpis?${pageParams(limit, offset)}`,
          { signal },
        ),
      signal,
    ),
  roles: (signal?: AbortSignal) =>
    collectPages(
      (limit, offset) =>
        apiClient.get<KpiPageDto<KpiRoleDto>>(`/roles/?${pageParams(limit, offset)}`, { signal }),
      signal,
    ),
  metrics: (signal?: AbortSignal) =>
    collectPages(
      (limit, offset) =>
        apiClient.get<KpiPageDto<KpiMetricDto>>(`/kpis/metrics/?${pageParams(limit, offset)}`, {
          signal,
        }),
      signal,
    ),
  create: (roleId: number, input: RoleKpiWriteInput) =>
    apiClient.post<RoleKpiDto>(`/roles/${roleId}/kpis`, input),
  update: (roleId: number, roleKpiId: number, input: RoleKpiWriteInput) =>
    apiClient.patch<RoleKpiDto>(`/roles/${roleId}/kpis/${roleKpiId}`, input),
  remove: (roleId: number, roleKpiId: number) =>
    apiClient.delete<{ detail: string }>(`/roles/${roleId}/kpis/${roleKpiId}`),
  createMetric: (input: KpiMetricWriteInput) =>
    apiClient.post<KpiMetricDto>('/kpis/metrics/', input),
}

export const kpiManagementQueryKeys = {
  all: ['company', 'kpi-management'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...kpiManagementQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...kpiManagementQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: RoleKpiListParams) =>
    [...kpiManagementQueryKeys.lists(userId, employeeId), params] as const,
  roles: (userId: number, employeeId: string) =>
    [...kpiManagementQueryKeys.scoped(userId, employeeId), 'roles'] as const,
  metrics: (userId: number, employeeId: string) =>
    [...kpiManagementQueryKeys.scoped(userId, employeeId), 'metrics'] as const,
  assignments: (userId: number, employeeId: string, roleId: number) =>
    [...kpiManagementQueryKeys.scoped(userId, employeeId), 'role-assignments', roleId] as const,
}
