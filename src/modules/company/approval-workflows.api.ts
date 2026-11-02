import { apiClient } from '@/shared/api/api-client'

export interface WorkflowChoice {
  value: string
  label: string
}

export interface ApprovalWorkflowStepDto {
  id: number
  step_order: number
  step_name: string
  required_level: string
  required_level_display: string
}

export interface ApprovalWorkflowDto {
  id: number
  name: string
  description: string | null
  action_type: string
  action_type_display: string
  is_active: boolean
  steps: ApprovalWorkflowStepDto[]
  created_by_id: number | null
  created_by_name: string | null
  created_at: string
  updated_at: string
}

export interface ApprovalWorkflowInput {
  name: string
  description: string
  action_type: string
  steps: { step_order: number; step_name: string; required_level: string }[]
}

export interface ApprovalWorkflowChoicesDto {
  action_types: WorkflowChoice[]
  required_levels: WorkflowChoice[]
}

export interface ApprovalWorkflowListParams {
  limit: number
  offset: number
  search: string
}

export interface ApprovalWorkflowPageDto {
  count: number
  items: ApprovalWorkflowDto[]
  limit?: number
  offset?: number
}

function listParams(params: ApprovalWorkflowListParams) {
  const query = new URLSearchParams({ limit: String(params.limit), offset: String(params.offset) })
  if (params.search.trim()) query.set('search', params.search.trim())
  return query
}

export const approvalWorkflowsApi = {
  choices: (signal?: AbortSignal) =>
    apiClient.get<ApprovalWorkflowChoicesDto>('/approvals/flows/choices', { signal }),
  list: (params: ApprovalWorkflowListParams, signal?: AbortSignal) =>
    apiClient.get<ApprovalWorkflowPageDto>(`/approvals/flows?${listParams(params)}`, { signal }),
  detail: (id: number, signal?: AbortSignal) =>
    apiClient.get<ApprovalWorkflowDto>(`/approvals/flows/${id}`, { signal }),
  create: (input: ApprovalWorkflowInput) =>
    apiClient.post<ApprovalWorkflowDto>('/approvals/flows', input),
  update: (id: number, input: Partial<ApprovalWorkflowInput> & { is_active?: boolean }) =>
    apiClient.put<ApprovalWorkflowDto>(`/approvals/flows/${id}`, input),
  deactivate: (id: number) => apiClient.delete<{ detail: string }>(`/approvals/flows/${id}`),
}

export const approvalWorkflowsQueryKeys = {
  all: ['company', 'approval-workflows'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...approvalWorkflowsQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...approvalWorkflowsQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: ApprovalWorkflowListParams) =>
    [...approvalWorkflowsQueryKeys.lists(userId, employeeId), params] as const,
  choices: (userId: number, employeeId: string) =>
    [...approvalWorkflowsQueryKeys.scoped(userId, employeeId), 'choices'] as const,
}
