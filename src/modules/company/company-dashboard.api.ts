import { apiClient } from '@/shared/api/api-client'

export type ApprovalRequestStatus = 'pending' | 'approved' | 'rejected' | 'cancelled'
export type ApprovalRequestStatusFilter = 'all' | ApprovalRequestStatus

export interface CompanyProfileDto {
  id: number
  company_name: string
  company_email: string
  company_phone: string
  company_addresses: string
  rc_number: string
  industry: string
  is_configured: boolean
  created_at: string
  updated_at: string
}

export interface CompanyBrandingDto {
  id: number
  company_logo: string | null
  company_slogan: string | null
  primary_color_code: string
  secondary_color_code: string
  created_at: string
  updated_at: string
}

export interface CompanyPreferencesDto {
  id: number
  default_currency: string
  language_preference: string
  business_rules: string
  punctuality_cutoff_time: string
  time_zone: string
  extras: Record<string, unknown>
  created_at: string
  updated_at: string
}

export interface CompanySettingsChoice {
  value: string
  label: string
}

export interface CompanySettingsChoicesDto {
  currencies: CompanySettingsChoice[]
  languages: CompanySettingsChoice[]
  time_zones: CompanySettingsChoice[]
}

export interface ApprovalDecisionDto {
  id: number
  step_order: number
  step_name: string
  decision: string
  decision_display: string
  comment: string | null
  approver_id: number | null
  approver_name: string | null
  created_at: string
}

export interface ApprovalRequestDto {
  id: number
  approval_request_id: string
  flow_id: number
  flow_name: string
  action_type: string
  action_type_display: string
  title: string
  description: string
  status: ApprovalRequestStatus
  status_display: string
  current_step: number
  total_steps: number
  pending_step_name: string | null
  pending_step_required_level: string | null
  pending_step_required_level_display: string | null
  decisions: ApprovalDecisionDto[]
  metadata: Record<string, unknown> | null
  created_by_id: number | null
  created_by_name: string | null
  created_at: string
  updated_at: string
}

export interface ApprovalRequestPageDto {
  count: number
  items: ApprovalRequestDto[]
}

export interface ApprovalRequestListParams {
  status: ApprovalRequestStatusFilter
  search: string
  limit: number
  offset: number
}

export interface CompanyOverviewDto {
  total_employees: number | null
  new_employees_30_days: number | null
  total_branches: number | null
  operational_branches?: number | null
  non_operational_branches?: number | null
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

export const companyOverviewQueryKey = (userId: number, employeeId: string) =>
  ['company', 'dashboard', 'overview', userId, employeeId] as const

export const companyIdentityQueryKeys = {
  profile: (userId: number) => ['company', 'identity', 'profile', userId] as const,
  branding: (userId: number) => ['company', 'identity', 'branding', userId] as const,
  preferences: (userId: number) => ['company', 'settings', 'preferences', userId] as const,
  choices: (userId: number) => ['company', 'settings', 'choices', userId] as const,
}

export const companyDashboardApi = {
  overview: (signal?: AbortSignal) =>
    apiClient.get<CompanyOverviewDto>('/company/dashboard/overview', { signal }),
  profile: (signal?: AbortSignal) =>
    apiClient.get<CompanyProfileDto>('/company/company/profile', { signal }),
  updateProfile: (
    input: Partial<Omit<CompanyProfileDto, 'id' | 'created_at' | 'updated_at' | 'is_configured'>>,
  ) => apiClient.put<CompanyProfileDto>('/company/company/profile', input),
  branding: (signal?: AbortSignal) =>
    apiClient.get<CompanyBrandingDto>('/company/company/branding', { signal }),
  updateBranding: (input: Partial<Omit<CompanyBrandingDto, 'id' | 'created_at' | 'updated_at'>>) =>
    apiClient.put<CompanyBrandingDto>('/company/company/branding', input),
  preferences: (signal?: AbortSignal) =>
    apiClient.get<CompanyPreferencesDto>('/company/company/preferences', { signal }),
  updatePreferences: (
    input: Partial<Omit<CompanyPreferencesDto, 'id' | 'created_at' | 'updated_at' | 'extras'>>,
  ) => apiClient.put<CompanyPreferencesDto>('/company/company/preferences', input),
  choices: (signal?: AbortSignal) =>
    apiClient.get<CompanySettingsChoicesDto>('/company/company/choices', { signal }),
  uploadLogo: async (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return apiClient.post<{ url: string }>('/others/upload-file', formData)
  },
}

function approvalRequestSearchParams(params: ApprovalRequestListParams): URLSearchParams {
  const search = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.status !== 'all') search.set('status', params.status)
  if (params.search.trim()) search.set('search', params.search.trim())
  return search
}

export const approvalRequestsApi = {
  list: (params: ApprovalRequestListParams, signal?: AbortSignal) =>
    apiClient.get<ApprovalRequestPageDto>(
      `/approvals/requests?${approvalRequestSearchParams(params)}`,
      {
        signal,
      },
    ),
  approve: (requestId: number) =>
    apiClient.post<ApprovalRequestDto>(`/approvals/requests/${requestId}/approve`, {}),
  reject: (requestId: number, comment: string) =>
    apiClient.post<ApprovalRequestDto>(`/approvals/requests/${requestId}/reject`, { comment }),
}

export const approvalRequestsQueryKeys = {
  all: ['company', 'approval-requests'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...approvalRequestsQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...approvalRequestsQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: ApprovalRequestListParams) =>
    [...approvalRequestsQueryKeys.lists(userId, employeeId), params] as const,
}
