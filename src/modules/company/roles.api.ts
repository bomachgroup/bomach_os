import { apiClient } from '@/shared/api/api-client'
import { ApiError } from '@/shared/api/api-error'

export interface ApiPage<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export interface RoleDto {
  id: number
  name: string
  branches: Array<{ id: number; branch_name: string }>
  permissions: Record<string, string[]>
  created_at: string
  updated_at: string
}

function invalidRoleResponse(details: unknown): ApiError {
  return new ApiError('The server returned role data in an unexpected format.', {
    status: 502,
    code: 'INVALID_ROLE_RESPONSE',
    details,
  })
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

function readPageItems(payload: unknown): { items: unknown[]; metadata: Record<string, unknown> } {
  if (Array.isArray(payload)) return { items: payload, metadata: {} }
  if (!isRecord(payload)) throw invalidRoleResponse(payload)

  const candidates = [payload, isRecord(payload.data) ? payload.data : undefined].filter(
    (candidate): candidate is Record<string, unknown> => candidate !== undefined,
  )
  for (const candidate of candidates) {
    const items = candidate.items ?? candidate.results ?? candidate.data
    if (Array.isArray(items)) return { items, metadata: candidate }
  }

  throw invalidRoleResponse(payload)
}

export function parseApiPage<T>(payload: unknown): ApiPage<T> {
  const { items, metadata } = readPageItems(payload)
  const root = isRecord(payload) ? payload : {}
  const count = metadata.count ?? root.count
  const limit = metadata.limit ?? root.limit
  const offset = metadata.offset ?? root.offset

  return {
    items: items as T[],
    count: typeof count === 'number' && Number.isFinite(count) ? count : items.length,
    ...(typeof limit === 'number' ? { limit } : {}),
    ...(typeof offset === 'number' ? { offset } : {}),
  }
}

function parseRoleDto(value: unknown): RoleDto {
  if (!isRecord(value)) throw invalidRoleResponse(value)

  const validBranches =
    Array.isArray(value.branches) &&
    value.branches.every(
      (branch) =>
        isRecord(branch) && typeof branch.id === 'number' && typeof branch.branch_name === 'string',
    )
  const validPermissions =
    isRecord(value.permissions) &&
    Object.values(value.permissions).every(
      (actions) => Array.isArray(actions) && actions.every((action) => typeof action === 'string'),
    )

  if (
    typeof value.id !== 'number' ||
    !Number.isFinite(value.id) ||
    typeof value.name !== 'string' ||
    !validBranches ||
    !validPermissions ||
    typeof value.created_at !== 'string' ||
    typeof value.updated_at !== 'string'
  ) {
    throw invalidRoleResponse(value)
  }

  return value as unknown as RoleDto
}

export interface RoleDescriptionDto {
  id?: number
  role_id?: number
  purpose: string
  responsibilities: string
  job_description: string
}

export interface RoleWriteInput {
  name: string
  branch_ids: number[]
  permissions: Record<string, string[]>
  description?: RoleDescriptionDto
}

export interface RoleListParams {
  limit: number
  offset: number
  search: string
}

export interface RoleReportingNodeDto {
  id: number
  role_id: number
  role: { id: number; name: string }
  reports_to_role_id: number
  reports_to_role: { id: number; name: string }
  relationship_type: string
  branch_id: number | null
  department_id: number | null
  unit_id: number | null
  sequence: number
  is_active: boolean
  cycle_detected?: boolean
  children?: RoleReportingNodeDto[]
}

export interface SOPChoiceDto {
  id: number
  title: string
  version: string
  priority: string
  is_up_to_date: boolean
  department: string | null
  unit: string | null
}

const pageParams = (params: RoleListParams) => {
  const query = new URLSearchParams({ limit: String(params.limit), offset: String(params.offset) })
  if (params.search.trim()) query.set('search', params.search.trim())
  return query
}

export const rolesApi = {
  list: async (params: RoleListParams, signal?: AbortSignal) => {
    const payload = await apiClient.get<unknown>(`/roles/?${pageParams(params)}`, { signal })
    const page = parseApiPage<unknown>(payload)
    return { ...page, items: page.items.map(parseRoleDto) }
  },
  get: async (id: number, signal?: AbortSignal) =>
    parseRoleDto(await apiClient.get<unknown>(`/roles/${id}`, { signal })),
  permissionMap: (signal?: AbortSignal) =>
    apiClient.get<{ permissions_map: Record<string, string[]> }>('/roles/permissions-map', {
      signal,
    }),
  description: (id: number, signal?: AbortSignal) =>
    apiClient.get<RoleDescriptionDto>(`/roles/${id}/description`, { signal }),
  reportingChain: (id: number, signal?: AbortSignal) =>
    apiClient.get<{ role: { id: number; name: string }; chain: RoleReportingNodeDto[] }>(
      `/roles/${id}/reporting-chain`,
      { signal },
    ),
  reportingTree: (id: number, signal?: AbortSignal) =>
    apiClient.get<{ role: { id: number; name: string }; direct_reports: RoleReportingNodeDto[] }>(
      `/roles/${id}/reporting-tree`,
      { signal },
    ),
  create: (input: RoleWriteInput) => apiClient.post<RoleDto>('/roles/', input),
  update: (id: number, input: RoleWriteInput) => apiClient.put<RoleDto>(`/roles/${id}`, input),
  remove: (id: number) => apiClient.delete<{ detail: string }>(`/roles/${id}`),
  listSection: async <T>(id: number, section: string, signal?: AbortSignal) =>
    parseApiPage<T>(
      await apiClient.get<unknown>(`/roles/${id}/${section}?limit=100&offset=0`, { signal }),
    ),
  sopChoices: async (signal?: AbortSignal) => {
    const limit = 100
    const items: SOPChoiceDto[] = []
    let offset = 0
    while (true) {
      if (signal?.aborted) throw new DOMException('The request was aborted.', 'AbortError')
      const params = new URLSearchParams({ limit: String(limit), offset: String(offset) })
      const payload = await apiClient.get<unknown>(`/roles/sop-options?${params}`, {
        signal,
      })
      const page = parseApiPage<SOPChoiceDto>(payload)
      items.push(...page.items)
      if (page.items.length < limit) break
      offset += page.items.length
    }
    return items
  },
  createSection: <T>(id: number, section: string, input: Record<string, unknown>) =>
    apiClient.post<T>(`/roles/${id}/${section}`, input),
  updateSection: <T>(id: number, section: string, itemId: number, input: Record<string, unknown>) =>
    apiClient.patch<T>(`/roles/${id}/${section}/${itemId}`, input),
  removeSection: (id: number, section: string, itemId: number) =>
    apiClient.delete<{ detail: string }>(`/roles/${id}/${section}/${itemId}`),
}

const rolesRoot = ['company', 'roles'] as const

export const rolesQueryKeys = {
  all: rolesRoot,
  list: (userId: number, employeeId: string, params: RoleListParams) =>
    [...rolesRoot, userId, employeeId, 'list', params] as const,
  detail: (userId: number, employeeId: string, roleId: number) =>
    [...rolesRoot, userId, employeeId, 'detail', roleId] as const,
  reportingChart: (userId: number, employeeId: string, roleId: number) =>
    [...rolesRoot, userId, employeeId, 'detail', roleId, 'reporting-chart'] as const,
  sopChoices: (userId: number, employeeId: string) =>
    [...rolesRoot, userId, employeeId, 'sop-choices'] as const,
  section: (userId: number, employeeId: string, roleId: number, section: string) =>
    [...rolesRoot, userId, employeeId, 'detail', roleId, section] as const,
  permissions: [...rolesRoot, 'permission-map'] as const,
}

export function unwrapPage<T>(result: ApiPage<T> | T[]): T[] {
  return parseApiPage<T>(result).items
}
