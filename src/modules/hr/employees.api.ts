import { apiClient } from '@/shared/api/api-client'

export interface ApiPage<T> {
  count: number
  items: T[]
  limit?: number
  offset?: number
}

export interface EmployeeDto {
  id: number
  user_id: number
  employee_id: string
  username: string
  email: string
  first_name: string
  middle_name: string
  last_name: string
  gender: string
  marital_status: string
  nationality: string
  phone_number: string | null
  other_phone: string | null
  personal_email: string | null
  date_of_birth: string | null
  address: string | null
  city: string
  state: string
  zip_code: string
  country: string
  profile_picture: string | null
  is_active: boolean
  employment_is_active: boolean
  account_is_active: boolean
  emergency_contact_name: string
  emergency_contact_relationship: string
  emergency_contact_phone: string
  designation: string
  employment_type: string
  employment_status: string
  branch_id: number | null
  branch_name: string | null
  department_id: number | null
  department_name: string | null
  department_units: Array<{ id: number; name: string; department_id: number }>
  role_id: number | null
  role_name: string | null
  location: string
  reporting_to_id: number | null
  start_date: string | null
  probation_period: number | null
  work_schedule: string
  gross_salary: string | null
  salary_frequency: string
  allowances: Record<string, unknown> | null
  bank_name: string
  account_number: string
  tax_id: string
  pension_number: string
  pfa_provider: string
  rsa_number: string
  employer_contribution: string | null
  hmo_current_plan: string
  hmo_id_number: string
  hmo_dependents_covered: number
}

export interface EmployeeListParams {
  limit: number
  offset: number
  search: string
  view: 'active' | 'past'
  branchId: string
  departmentId: string
}

export type EmployeeWriteInput = Partial<EmployeeDto> & {
  email?: string
  department_unit_ids?: number[]
}

export interface EmployeeDocumentDto {
  id: number
  employee_id: number
  name: string
  file_url: string
  file_type: string
  uploaded_at: string
}

export interface EmployeeReviewDto {
  id: number
  employee_id: number
  reviewer_id: number | null
  reviewer_name: string | null
  quarter: string
  year: number
  review_period: string
  job_knowledge: number | null
  communication: number | null
  problem_solving: number | null
  teamwork: number | null
  initiative: number | null
  quality_of_work: number | null
  overall_rating: number | null
  key_achievements: string
  areas_for_improvement: string
  development_plan: string
  review_date: string
}

export interface EmployeeScorecardDto {
  id: number
  employee_id: number
  employee_name: string | null
  employee_level: string | null
  month: number
  year: number
  attendance_score: number | string
  task_delivery_score: number | string
  report_accuracy_score: number | string
  brand_contribution_score: number | string
  training_progress_score: number | string
  overall_score: number | string
  target_score: number | string
  target_achievement: number | string
  ranking: number | null
  is_auto_generated: boolean
  notes: string
}

export interface ManagedTaskDto {
  id: number
  name: string
  description: string | null
  status: string
  priority: string
  due_date: string | null
  assigned_to: number[]
  project_name?: string | null
  project?: { id: number; name: string } | null
  created_at: string
}

export interface EmployeeLeavePeriodDto {
  id: number
  employee_id: number
  leave_type: string
  leave_type_label: string
  reason: string
  start_date: string
  expected_return_date: string | null
  review_reminder_date: string | null
  actual_return_date: string | null
  status: 'active' | 'returned' | 'cancelled'
  return_employment_status: string
  created_at: string
  updated_at: string
  created_by_name: string | null
  returned_by_name: string | null
}

export interface EmployeeLeavePeriodCreateInput {
  leave_type: string
  reason: string
  start_date: string
  expected_return_date: string | null
  review_reminder_date: string | null
}

export interface EmployeeLeaveReturnInput {
  actual_return_date: string
  legacy_start_date?: string
  legacy_leave_type?: string
  legacy_reason?: string
  legacy_return_employment_status?: string
}

export interface PerformanceReviewApiDto {
  id: number
  employee_id: number
  review_period: string
  overall_rating: number | string
  review_date: string
  strengths?: string
  areas_for_improvement?: string
  comments?: string
}

export interface PerformancePlanItemDto {
  item_key: string
  kind: 'kpi' | 'target'
  source: string
  source_id: number | null
  is_customized: boolean
  role_defaults?: Record<string, unknown>
  config: {
    name?: string
    title?: string
    description?: string
    unit?: string
    tracking_mode?: string
    target_value?: number | string | null
    weight?: number | string | null
    period?: string
    sequence?: number
    is_active?: boolean
    [key: string]: unknown
  }
}

export interface EmployeePerformancePlanDto {
  employee_id: number
  role_id: number
  period_start: string
  period_end: string
  revision: number | null
  effective_from: string | null
  source: string
  kpis: PerformancePlanItemDto[]
  targets: PerformancePlanItemDto[]
}

function listUrl(params: EmployeeListParams) {
  const query = new URLSearchParams({
    limit: String(params.limit),
    offset: String(params.offset),
    // Flutter's Active / Past tabs are backed by the employment active flag.
    // The API now derives that flag from employment_status, so terminated,
    // suspended and inactive records remain visible in the Past tab even when
    // older rows have no offboard_date.
    is_active: params.view === 'active' ? 'true' : 'false',
  })
  if (params.search.trim()) query.set('search', params.search.trim())
  if (params.branchId !== 'all') query.set('branch_id', params.branchId)
  if (params.departmentId !== 'all') query.set('department_id', params.departmentId)
  return query
}

export const employeesApi = {
  list: (params: EmployeeListParams, signal?: AbortSignal) =>
    apiClient.get<ApiPage<EmployeeDto>>(`/employees/employees?${listUrl(params)}`, { signal }),
  get: (userId: number, signal?: AbortSignal) =>
    apiClient.get<EmployeeDto>(`/employees/employees/${userId}`, { signal }),
  create: (input: EmployeeWriteInput) => apiClient.post<EmployeeDto>('/employees/employees', input),
  update: (userId: number, input: EmployeeWriteInput) =>
    apiClient.put<EmployeeDto>(`/employees/employees/${userId}`, input),
  uploadProfilePicture: (file: File) => {
    const form = new FormData()
    form.set('file', file)
    return apiClient.post<{ url: string }>('/others/upload-file', form)
  },
  exit: (userId: number, input: { exit_date: string; reason: string }) =>
    apiClient.post<{ detail: string }>(`/employees/exit/${userId}`, input),
  leavePeriods: (userId: number, signal?: AbortSignal) =>
    apiClient.get<EmployeeLeavePeriodDto[]>(`/employees/employees/${userId}/leave-periods`, {
      signal,
    }),
  createLeavePeriod: (userId: number, input: EmployeeLeavePeriodCreateInput) =>
    apiClient.post<EmployeeLeavePeriodDto>(`/employees/employees/${userId}/leave-periods`, input),
  returnFromLeave: (userId: number, input: EmployeeLeaveReturnInput) =>
    apiClient.post<EmployeeLeavePeriodDto>(
      `/employees/employees/${userId}/leave-periods/return`,
      input,
    ),
  documents: (userId: number, signal?: AbortSignal) =>
    apiClient.get<EmployeeDocumentDto[]>(`/employees/${userId}/documents`, { signal }),
  uploadDocument: (userId: number, file: File) => {
    const form = new FormData()
    form.set('file', file)
    form.set('name', file.name)
    return apiClient.post<EmployeeDocumentDto>(`/employees/${userId}/documents`, form)
  },
  deleteDocument: (userId: number, documentId: number) =>
    apiClient.delete<{ detail: string }>(`/employees/${userId}/documents/${documentId}`),
  reviews: (userId: number, signal?: AbortSignal) =>
    apiClient.get<ApiPage<EmployeeReviewDto>>(`/employees/${userId}/reviews?limit=100&offset=0`, {
      signal,
    }),
  createReview: (userId: number, input: Record<string, unknown>) =>
    apiClient.post<EmployeeReviewDto>(`/employees/${userId}/reviews`, input),
  updateReview: (reviewId: number, input: Record<string, unknown>) =>
    apiClient.put<EmployeeReviewDto>(`/employees/reviews/${reviewId}`, input),
  deleteReview: (reviewId: number) =>
    apiClient.delete<{ detail: string }>(`/employees/reviews/${reviewId}`),
  performancePlan: (userId: number, periodStart: string, periodEnd: string, signal?: AbortSignal) =>
    apiClient.get<EmployeePerformancePlanDto>(
      `/employees/${userId}/performance-plan?period_start=${periodStart}&period_end=${periodEnd}`,
      { signal },
    ),
  scorecard: (
    employeeRecordId: number,
    month: number,
    year: number,
    signal?: AbortSignal,
    generateIfMissing = true,
  ) =>
    apiClient.get<EmployeeScorecardDto>(
      `/monthly-scorecards/employee/${employeeRecordId}?month=${month}&year=${year}&generate_if_missing=${generateIfMissing}`,
      { signal },
    ),
  performanceReviews: (employeeRecordId: number, signal?: AbortSignal) =>
    apiClient.get<ApiPage<PerformanceReviewApiDto>>(
      `/performance-reviews/?employee_id=${employeeRecordId}&limit=100&offset=0`,
      { signal },
    ),
  tasks: (userId: number, signal?: AbortSignal) =>
    apiClient.get<ApiPage<ManagedTaskDto>>(
      `/employees/employees/${userId}/tasks?limit=100&offset=0`,
      { signal },
    ),
}

export const employeesQueryKeys = {
  all: ['hr', 'employees'] as const,
  list: (userId: number, employeeId: string, params: EmployeeListParams) =>
    [...employeesQueryKeys.all, userId, employeeId, 'list', params] as const,
  detail: (userId: number, employeeId: string, targetUserId: number) =>
    [...employeesQueryKeys.all, userId, employeeId, 'detail', targetUserId] as const,
  documents: (userId: number, employeeId: string, targetUserId: number) =>
    [...employeesQueryKeys.detail(userId, employeeId, targetUserId), 'documents'] as const,
  reviews: (userId: number, employeeId: string, targetUserId: number) =>
    [...employeesQueryKeys.detail(userId, employeeId, targetUserId), 'reviews'] as const,
  plan: (userId: number, employeeId: string, targetUserId: number, start: string, end: string) =>
    [
      ...employeesQueryKeys.detail(userId, employeeId, targetUserId),
      'performance-plan',
      start,
      end,
    ] as const,
  scorecard: (userId: number, employeeId: string, recordId: number, month: number, year: number) =>
    [...employeesQueryKeys.detail(userId, employeeId, recordId), 'scorecard', month, year] as const,
  legacyReviews: (userId: number, employeeId: string, recordId: number) =>
    [...employeesQueryKeys.detail(userId, employeeId, recordId), 'performance-reviews'] as const,
  tasks: (userId: number, employeeId: string, targetUserId: number) =>
    [...employeesQueryKeys.all, userId, employeeId, 'assigned-tasks', targetUserId] as const,
  leavePeriods: (userId: number, employeeId: string, targetUserId: number) =>
    [...employeesQueryKeys.detail(userId, employeeId, targetUserId), 'leave-periods'] as const,
}
