import { apiClient } from '@/shared/api/api-client'

export interface OrganizationPage<TItem> {
  count: number
  items: TItem[]
  limit?: number
  offset?: number
}

export interface DepartmentDto {
  id: number
  name: string
  description: string
}

export interface DepartmentUnitDto {
  id: number
  name: string
  department_id: number
  department_name: string
  description: string
}

export interface DepartmentChoice {
  value: string
  label: string
}

export interface DepartmentChoicesDto {
  items: DepartmentChoice[]
}

export interface DepartmentListParams {
  limit: number
  offset: number
  search: string
}

export interface UnitListParams extends DepartmentListParams {
  departmentId: number | null
}

export interface OrganizationRoleDto {
  id: number
  name: string
}

export type ReportingRelationshipType = 'direct' | 'dotted_line' | 'escalation'

export interface ReportingLineDto {
  id: number
  role_id: number
  role: OrganizationRoleDto
  reports_to_role_id: number
  reports_to_role: OrganizationRoleDto
  relationship_type: ReportingRelationshipType
  branch_id: number | null
  branch: { id: number; branch_name: string } | null
  department_id: number | null
  department: { id: number; name: string } | null
  unit_id: number | null
  unit: { id: number; name: string } | null
  sequence: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface ReportingChartScopeDto {
  key: string
  label: string
  branch_id: number | null
  branch: { id: number; branch_name: string } | null
  department_id: number | null
  department: { id: number; name: string } | null
  unit_id: number | null
  unit: { id: number; name: string } | null
  role_ids: number[]
  reporting_lines: ReportingLineDto[]
}

export interface ReportingChartDto {
  roles: OrganizationRoleDto[]
  scopes: ReportingChartScopeDto[]
}

function listParams(params: DepartmentListParams | UnitListParams) {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.search.trim()) search.set('search', params.search.trim())
  if ('departmentId' in params && params.departmentId !== null) {
    search.set('department_id', String(params.departmentId))
  }
  return search
}

export const companyOrganizationApi = {
  departments: (params: DepartmentListParams, signal?: AbortSignal) =>
    apiClient.get<OrganizationPage<DepartmentDto>>(
      `/organization/department?${listParams(params)}`,
      { signal },
    ),
  departmentChoices: (signal?: AbortSignal) =>
    apiClient.get<DepartmentChoicesDto>('/organization/department/choices', { signal }),
  createDepartment: (input: { name: string; description: string }) =>
    apiClient.post<DepartmentDto>('/organization/department', input),
  updateDepartment: (departmentId: number, input: { name: string; description: string }) =>
    apiClient.put<DepartmentDto>(`/organization/department/${departmentId}`, input),
  units: (params: UnitListParams, signal?: AbortSignal) =>
    apiClient.get<OrganizationPage<DepartmentUnitDto>>(`/organization/unit?${listParams(params)}`, {
      signal,
    }),
  createUnit: (input: { name: string; department_id: number; description: string }) =>
    apiClient.post<DepartmentUnitDto>('/organization/unit', input),
  updateUnit: (
    unitId: number,
    input: { name: string; department_id: number; description: string },
  ) => apiClient.put<DepartmentUnitDto>(`/organization/unit/${unitId}`, input),
  reportingChart: (signal?: AbortSignal) =>
    apiClient.get<ReportingChartDto>('/roles/reporting-chart', { signal }),
}

export const companyOrganizationQueryKeys = {
  all: ['company', 'organization'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...companyOrganizationQueryKeys.all, userId, employeeId] as const,
  departments: (userId: number, employeeId: string, params: DepartmentListParams) =>
    [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'departments', params] as const,
  units: (userId: number, employeeId: string, params: UnitListParams) =>
    [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'units', params] as const,
  departmentChoices: (userId: number, employeeId: string) =>
    [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'department-choices'] as const,
  reportingChart: (userId: number, employeeId: string) =>
    [...companyOrganizationQueryKeys.scoped(userId, employeeId), 'reporting-chart'] as const,
}
