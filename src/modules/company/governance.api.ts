import { apiClient } from '@/shared/api/api-client'

export interface GovernancePage<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export interface GovernanceListParams {
  limit: number
  offset: number
  search: string
}

export interface FieldChoice {
  value: string
  label: string
}

export interface BoardMeetingDto {
  id: number
  meeting_id: string
  title: string
  agenda: string
  meeting_date: string
  meeting_time: string
  duration_minutes: number
  duration_display: string
  status: string
  status_display: string
  location_type: string
  location_type_display: string
  location: string | null
  attendees: { user_id: number; full_name: string; email: string }[]
  attendee_count: number
  organizer_id: number | null
  organizer_name: string | null
  file_url: string | null
  notes: string | null
  created_at: string
  updated_at: string
}

export interface BoardResolutionDto {
  id: number
  resolution_id: string
  title: string
  description: string
  resolution_type: string
  resolution_type_display: string
  status: string
  status_display: string
  resolution_date: string
  attachment_url: string | null
  notes: string | null
  created_by_id: number | null
  created_by_name: string | null
  approved_by_id: number | null
  approved_by_name: string | null
  approved_at: string | null
  created_at: string
  updated_at: string
}

export interface ShareholderDto {
  id: number
  shareholder_id: string
  user_id: number
  first_name: string
  last_name: string
  email: string
  phone_number: string | null
  profile_picture: string | null
  title: string
  title_display: string
  share_percentage: number
  share_count: number | null
  is_board_member: boolean
  is_active: boolean
  notes: string | null
  created_at: string
  updated_at: string
}

export interface AssociateDto {
  id: number
  user_id: number
  employee_id: string
  first_name: string
  last_name: string
  email: string
  phone_number: string | null
  designation: string
  employment_type: string
  employment_status: string
  is_active: boolean
  branch_name: string | null
  department_name: string | null
}

export interface AssociateDetailDto extends AssociateDto {
  username: string
  middle_name: string
  gender: string
  marital_status: string
  nationality: string
  other_phone: string | null
  personal_email: string | null
  date_of_birth: string | null
  address: string | null
  city: string
  state: string
  country: string
  profile_picture: string | null
  location: string
  start_date: string | null
  work_schedule: string
  role_name: string | null
  department_units: { id: number; name: string }[]
}

export interface PartnerDto {
  id: number
  code: string | null
  name: string
  email: string
  phone: string
  address: string
  category: string
  category_display: string
  status: string
  status_display: string
  kyc_status: string
  kyc_status_display: string
  commission_rate: number
  notes: string
  agreement_count: number
  created_at: string
  updated_at: string
}

export interface AssociatePageParams extends GovernanceListParams {
  employmentType: string
}

export interface MeetingAttendeeChoice {
  user_id: number
  employee_id: string
  first_name: string
  last_name: string
  email: string
  designation: string
  is_active: boolean
}

function pageParams(params: GovernanceListParams) {
  const search = new URLSearchParams({ limit: String(params.limit), offset: String(params.offset) })
  if (params.search.trim()) search.set('search', params.search.trim())
  return search
}

export const governanceApi = {
  uploadFile: (file: File) => {
    const formData = new FormData()
    formData.append('file', file)
    return apiClient.post<{ url: string }>('/others/upload-file', formData)
  },
  meetings: (params: GovernanceListParams, signal?: AbortSignal) =>
    apiClient.get<GovernancePage<BoardMeetingDto>>(`/meetings/?${pageParams(params)}`, { signal }),
  meeting: (id: number, signal?: AbortSignal) =>
    apiClient.get<BoardMeetingDto>(`/meetings/${id}`, { signal }),
  meetingChoices: (signal?: AbortSignal) =>
    apiClient.get<{ statuses: FieldChoice[]; location_types: FieldChoice[] }>('/meetings/choices', {
      signal,
    }),
  createMeeting: (input: Record<string, unknown>) =>
    apiClient.post<BoardMeetingDto>('/meetings/', input),
  updateMeeting: (id: number, input: Record<string, unknown>) =>
    apiClient.put<BoardMeetingDto>(`/meetings/${id}`, input),
  cancelMeeting: (id: number) => apiClient.delete<{ detail: string }>(`/meetings/${id}`),

  resolutions: (params: GovernanceListParams, signal?: AbortSignal) =>
    apiClient.get<GovernancePage<BoardResolutionDto>>(`/board-resolutions/?${pageParams(params)}`, {
      signal,
    }),
  resolution: (id: number, signal?: AbortSignal) =>
    apiClient.get<BoardResolutionDto>(`/board-resolutions/${id}`, { signal }),
  resolutionChoices: (signal?: AbortSignal) =>
    apiClient.get<{
      types?: FieldChoice[]
      resolution_types?: FieldChoice[]
      statuses: FieldChoice[]
    }>('/board-resolutions/choices', { signal }),
  createResolution: (input: Record<string, unknown>) =>
    apiClient.post<BoardResolutionDto>('/board-resolutions/', input),
  updateResolution: (id: number, input: Record<string, unknown>) =>
    apiClient.put<BoardResolutionDto>(`/board-resolutions/${id}`, input),
  approveResolution: (id: number) =>
    apiClient.post<BoardResolutionDto>(`/board-resolutions/${id}/approve`, {}),
  archiveResolution: (id: number) =>
    apiClient.delete<{ detail: string }>(`/board-resolutions/${id}`),

  shareholders: (params: GovernanceListParams, signal?: AbortSignal) =>
    apiClient.get<GovernancePage<ShareholderDto>>(`/shareholders/?${pageParams(params)}`, {
      signal,
    }),
  shareholder: (id: number, signal?: AbortSignal) =>
    apiClient.get<ShareholderDto>(`/shareholders/${id}`, { signal }),
  createShareholder: (input: Record<string, unknown>) =>
    apiClient.post<ShareholderDto>('/shareholders/', input),
  updateShareholder: (id: number, input: Record<string, unknown>) =>
    apiClient.put<ShareholderDto>(`/shareholders/${id}`, input),

  associates: (params: AssociatePageParams, signal?: AbortSignal) => {
    const search = pageParams(params)
    search.set('employment_type', params.employmentType)
    search.set('is_active', 'true')
    search.set('add_shareholders', 'false')
    return apiClient.get<GovernancePage<AssociateDto>>(`/employees/employees?${search}`, { signal })
  },
  associate: (userId: number, signal?: AbortSignal) =>
    apiClient.get<AssociateDetailDto>(`/employees/employees/${userId}`, { signal }),
  meetingAttendeeChoices: (signal?: AbortSignal) =>
    apiClient.get<GovernancePage<MeetingAttendeeChoice>>(
      '/employees/employees?limit=100&offset=0&is_active=true&add_shareholders=true',
      { signal },
    ),
  partners: (params: GovernanceListParams, signal?: AbortSignal) =>
    apiClient.get<GovernancePage<PartnerDto>>(`/partners/?${pageParams(params)}`, { signal }),
  partner: (id: number, signal?: AbortSignal) =>
    apiClient.get<PartnerDto>(`/partners/${id}`, { signal }),
  partnerChoices: (signal?: AbortSignal) =>
    apiClient.get<{
      category: FieldChoice[]
      status: FieldChoice[]
      kyc_status: FieldChoice[]
    }>('/partners/choices/fields', { signal }),
  createPartner: (input: Record<string, unknown>) =>
    apiClient.post<PartnerDto>('/partners/', input),
  updatePartner: (id: number, input: Record<string, unknown>) =>
    apiClient.put<PartnerDto>(`/partners/${id}`, input),
  deletePartner: (id: number) => apiClient.delete<{ detail: string }>(`/partners/${id}`),
}

export const governanceQueryKeys = {
  all: ['company', 'governance'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...governanceQueryKeys.all, userId, employeeId] as const,
  list: (userId: number, employeeId: string, section: string, params: unknown) =>
    [...governanceQueryKeys.scoped(userId, employeeId), section, params] as const,
  lists: (userId: number, employeeId: string, section: string) =>
    [...governanceQueryKeys.scoped(userId, employeeId), section] as const,
  detail: (userId: number, employeeId: string, section: string, id: number) =>
    [...governanceQueryKeys.scoped(userId, employeeId), section, 'detail', id] as const,
  choices: (userId: number, employeeId: string, section: string) =>
    [...governanceQueryKeys.scoped(userId, employeeId), section, 'choices'] as const,
}

export const complianceRecordTypes: FieldChoice[] = [
  { value: 'real_estate_license', label: 'Real Estate License' },
  { value: 'broker_license', label: 'Broker License' },
  { value: 'property_manager_license', label: 'Property Manager License' },
  { value: 'fair_housing_certification', label: 'Fair Housing Certification' },
  { value: 'continuing_education', label: 'Continuing Education Certificate' },
]

export const complianceStatuses: FieldChoice[] = [
  { value: 'active', label: 'Active' },
  { value: 'expired', label: 'Expired' },
  { value: 'pending', label: 'Pending' },
  { value: 'archived', label: 'Archived' },
]

export const compliancePriorities: FieldChoice[] = [
  { value: 'low', label: 'Low' },
  { value: 'medium', label: 'Medium' },
  { value: 'high', label: 'High' },
  { value: 'critical', label: 'Critical' },
]

export interface ComplianceRecordDto {
  id: number
  full_name: string
  email_address: string
  phone_number: string
  department_id: number
  compliance_type: string
  reference_number: string | null
  date_of_issue: string
  expiry_date: string
  issuing_authority: string
  status: string
  description: string | null
  contact_person: string | null
  contact_email: string | null
  cost: number | null
  priority_level: string | null
  is_expired: boolean
  days_until_expiry: number
  created_at: string
  updated_at: string
  documents: string[]
}

export interface ComplianceListParams extends GovernanceListParams {
  complianceType: string
}

export const complianceApi = {
  list: (params: ComplianceListParams, signal?: AbortSignal) => {
    const search = pageParams(params)
    if (params.complianceType) search.set('compliance_type', params.complianceType)
    return apiClient.get<GovernancePage<ComplianceRecordDto>>(
      `/compliance/compliance-records?${search}`,
      { signal },
    )
  },
  detail: (id: number, signal?: AbortSignal) =>
    apiClient.get<ComplianceRecordDto>(`/compliance/compliance-records/${id}`, { signal }),
  create: (input: Record<string, unknown>) =>
    apiClient.post<ComplianceRecordDto>('/compliance/compliance-records', input),
  update: (id: number, input: Record<string, unknown>) =>
    apiClient.put<ComplianceRecordDto>(`/compliance/compliance-records/${id}`, input),
  delete: (id: number) =>
    apiClient.delete<{ detail: string }>(`/compliance/compliance-records/${id}`),
}

export const complianceQueryKeys = {
  all: ['company', 'compliance'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...complianceQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...complianceQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: ComplianceListParams) =>
    [...complianceQueryKeys.lists(userId, employeeId), params] as const,
  detail: (userId: number, employeeId: string, id: number) =>
    [...complianceQueryKeys.scoped(userId, employeeId), 'detail', id] as const,
  departments: (userId: number, employeeId: string) =>
    [...complianceQueryKeys.scoped(userId, employeeId), 'department-choices'] as const,
}
