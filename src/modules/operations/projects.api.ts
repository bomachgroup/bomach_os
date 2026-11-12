import { apiClient } from '@/shared/api/api-client'

export type ProjectStatus = 'planning' | 'in_progress' | 'on_hold' | 'completed' | 'cancelled'
export type ProjectPriority = 'low' | 'medium' | 'high' | 'critical'

export interface ProjectDto {
  id: number
  name: string
  short_code: string
  category: string
  department_id: number | null
  client_id: number
  branch_id: number | null
  branch_name: string | null
  employee_ids: number[]
  location: string | null
  priority: ProjectPriority
  summary: string | null
  status: ProjectStatus
  budget: string
  progress: number
  start_date: string | null
  deadline: string | null
  is_archived: boolean
  archived_at: string | null
  archived_by_id: number | null
  created_at: string
  updated_at: string
  file_url: string | null
  expense_count: number
  committed_expense_total: string
  spent_expense_total: string
  consumed_expense_total: string
  remaining_budget: string
}

export interface ProjectRecentDto {
  id: number
  name: string
  short_code: string
  status: ProjectStatus
  budget: string
  progress: number
  updated_at: string
}

export interface OperationsOverviewDto {
  total_projects: number | null
  total_tasks: number | null
  allocated_project_budget: string | null
  approved_and_paid_expenses: string | null
  budget_utilization_percent: string | null
  total_worksites: number | null
  total_contracts: number | null
  total_timelines: number | null
  scope_limited: boolean
  recent_projects: ProjectRecentDto[]
}

export interface PaginatedDto<T> {
  items: T[]
  count: number
  limit: number
  offset: number
}

export interface ProjectListParams {
  limit: number
  offset: number
  search: string
  status: string
  priority: string
  archived: boolean
}

export interface ProjectWriteInput {
  name: string
  short_code: string
  category: string
  client_id: number
  branch_id: number
  department_id: number | null
  employee_ids: number[]
  location: string | null
  priority: ProjectPriority
  summary: string | null
  status: ProjectStatus
  budget: string
  progress: number
  start_date: string | null
  deadline: string | null
  file_url: string | null
}

export interface ProjectEmployeeDto {
  id: string
  employee_id: string
  full_name: string
  email: string
  is_active: boolean
  position: string
}

export interface ProjectEmployeePageDto {
  items: ProjectEmployeeDto[]
  count: number
}

export interface ProjectEmployeeOptionDto {
  id: number
  employee_id: string
  name: string
  email: string
  position: string
}

export interface ProjectBranchOptionDto {
  id: number
  name: string
  code: string
}

export interface ProjectClientOptionDto {
  id: number
  name: string
  email: string
}

export interface ProjectWorksiteDto {
  id: number
  project_id: number | null
  name: string
  location: string
  latitude: string | null
  longitude: string | null
  status: string
  description: string | null
  created_at: string
  updated_at: string
}

export interface ProjectMilestoneDto {
  id: number
  project_id: number
  name: string
  description: string | null
  priority: string
  status: string
  budget: string | null
  progress: number
  start_date: string | null
  end_date: string | null
  created_at: string
  updated_at: string
}

export interface ProjectTaskDto {
  id: number
  project_id: number | null
  milestone_id: number | null
  name: string
  description: string | null
  status: string
  priority: string
  due_date: string | null
  estimated_hours: string | null
  created_at: string
  updated_at: string
}

export interface ProjectAssociateDto {
  id: number
  partner_id: number
  name: string
  code: string | null
  category: string
  project_role: string
}

export interface ProjectAssociateOptionDto {
  id: number
  name: string
  code: string | null
  category: string
}

export interface ProjectAttachmentDto {
  id: number
  original_filename: string
  content_type: string
  size: number
  uploaded_by_name: string | null
  created_at: string
  download_url: string
}

export interface ProjectMeetingDto {
  id: number
  meeting_id: string
  project_id: number | null
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
  attendee_count: number
  organizer_id: number | null
  organizer_name: string | null
  notes: string | null
  created_at: string
  updated_at: string
}

export interface ProjectTimelineDto {
  id: number
  project_id: number
  name: string
  description: string | null
  status: string
  start_date: string
  end_date: string
}

function queryString(values: Record<string, string | number | boolean | null | undefined>) {
  const query = new URLSearchParams()
  for (const [key, value] of Object.entries(values)) {
    if (value === null || value === undefined || value === '' || value === false) continue
    query.set(key, String(value))
  }
  return query.toString()
}

const projectRoot = '/projects'

export const projectsApi = {
  overview: (signal?: AbortSignal) =>
    apiClient.get<OperationsOverviewDto>('/operations/dashboard/overview', { signal }),
  list: (params: ProjectListParams, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<ProjectDto>>(
      `${projectRoot}?${queryString({
        limit: params.limit,
        offset: params.offset,
        search: params.search,
        status: params.status,
        priority: params.priority,
        archived: params.archived,
      })}`,
      { signal },
    ),
  detail: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<ProjectDto>(`${projectRoot}/${projectId}`, { signal }),
  create: (input: ProjectWriteInput) => apiClient.post<ProjectDto>(projectRoot, input),
  update: (projectId: number, input: ProjectWriteInput) =>
    apiClient.put<ProjectDto>(`${projectRoot}/${projectId}`, input),
  archive: (projectId: number) => apiClient.post<ProjectDto>(`${projectRoot}/${projectId}/archive`),
  restore: (projectId: number) => apiClient.post<ProjectDto>(`${projectRoot}/${projectId}/restore`),
  remove: (projectId: number) =>
    apiClient.delete<{ detail: string }>(`${projectRoot}/${projectId}`),
  branchOptions: (signal?: AbortSignal) =>
    apiClient.get<ProjectBranchOptionDto[]>(`${projectRoot}/branch-options`, { signal }),
  clientOptions: (search = '', signal?: AbortSignal) =>
    apiClient.get<ProjectClientOptionDto[]>(
      `${projectRoot}/client-options?${queryString({ search })}`,
      { signal },
    ),
  employees: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<ProjectEmployeePageDto>(
      `${projectRoot}/${projectId}/employees?limit=100&offset=0`,
      { signal },
    ),
  employeeOptions: (projectId: number, search = '', signal?: AbortSignal) =>
    apiClient.get<ProjectEmployeeOptionDto[]>(
      `${projectRoot}/${projectId}/employee-options?${queryString({ search })}`,
      { signal },
    ),
  updateEmployees: (projectId: number, employeeIds: number[]) =>
    apiClient.put<ProjectDto>(`${projectRoot}/${projectId}/employees`, {
      employee_ids: employeeIds,
    }),
  worksites: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<ProjectWorksiteDto>>(
      `/worksites?project_id=${projectId}&limit=100&offset=0`,
      { signal },
    ),
  createWorksite: (input: {
    project_id: number
    name: string
    location: string
    status: string
    description: string | null
  }) => apiClient.post<ProjectWorksiteDto>('/worksites', input),
  updateWorksite: (id: number, input: Partial<ProjectWorksiteDto>) =>
    apiClient.put<ProjectWorksiteDto>(`/worksites/${id}`, input),
  removeWorksite: (id: number) => apiClient.delete<{ detail: string }>(`/worksites/${id}`),
  milestones: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<ProjectMilestoneDto>>(
      `/milestones?project_id=${projectId}&limit=100&offset=0`,
      { signal },
    ),
  createMilestone: (input: {
    project_id: number
    name: string
    description: string | null
    status: string
    priority: string
    progress: number
    budget: string | null
    start_date: string | null
    end_date: string | null
  }) => apiClient.post<ProjectMilestoneDto>('/milestones', input),
  updateMilestone: (id: number, input: Partial<ProjectMilestoneDto>) =>
    apiClient.put<ProjectMilestoneDto>(`/milestones/${id}`, input),
  removeMilestone: (id: number) => apiClient.delete<{ detail: string }>(`/milestones/${id}`),
  tasks: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<ProjectTaskDto>>(
      `/tasks?project_id=${projectId}&limit=100&offset=0`,
      { signal },
    ),
  createTask: (input: {
    project_id: number
    milestone_id: number | null
    name: string
    description: string | null
    status: string
    priority: string
    due_date: string | null
    estimated_hours: string | null
  }) => apiClient.post<ProjectTaskDto>('/tasks', input),
  updateTask: (id: number, input: Partial<ProjectTaskDto>) =>
    apiClient.put<ProjectTaskDto>(`/tasks/${id}`, input),
  removeTask: (id: number) => apiClient.delete<{ detail: string }>(`/tasks/${id}`),
  associates: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<ProjectAssociateDto[]>(`${projectRoot}/${projectId}/associates`, { signal }),
  associateOptions: (projectId: number, search = '', signal?: AbortSignal) =>
    apiClient.get<ProjectAssociateOptionDto[]>(
      `${projectRoot}/${projectId}/associate-options?${queryString({ search })}`,
      { signal },
    ),
  addAssociate: (projectId: number, partnerId: number, projectRole: string) =>
    apiClient.post<ProjectAssociateDto>(`${projectRoot}/${projectId}/associates`, {
      partner_id: partnerId,
      project_role: projectRole,
    }),
  removeAssociate: (projectId: number, partnerId: number) =>
    apiClient.delete<{ detail: string }>(`${projectRoot}/${projectId}/associates/${partnerId}`),
  files: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<ProjectAttachmentDto[]>(`${projectRoot}/${projectId}/files`, { signal }),
  uploadFile: (projectId: number, file: File) => {
    const data = new FormData()
    data.append('file', file)
    return apiClient.post<ProjectAttachmentDto>(`${projectRoot}/${projectId}/files`, data)
  },
  removeFile: (projectId: number, fileId: number) =>
    apiClient.delete<{ detail: string }>(`${projectRoot}/${projectId}/files/${fileId}`),
  meetings: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<ProjectMeetingDto>>(
      `/meetings/?project_id=${projectId}&limit=100&offset=0`,
      { signal },
    ),
  createMeeting: (input: {
    project_id: number
    title: string
    agenda: string
    meeting_date: string
    meeting_time: string
    duration_minutes: number
    status: string
    location_type: string
    location: string
    notes: string
  }) => apiClient.post<ProjectMeetingDto>('/meetings/', input),
  updateMeeting: (
    id: number,
    input: {
      project_id: number
      title: string
      agenda: string
      meeting_date: string
      meeting_time: string
      duration_minutes: number
      status: string
      location_type: string
      location: string
      notes: string
    },
  ) => apiClient.put<ProjectMeetingDto>(`/meetings/${id}`, input),
  cancelMeeting: (id: number) => apiClient.delete<{ detail: string }>(`/meetings/${id}`),
  timelines: (projectId: number, signal?: AbortSignal) =>
    apiClient.get<PaginatedDto<ProjectTimelineDto>>(
      `/timelines?project_id=${projectId}&limit=100&offset=0`,
      { signal },
    ),
}

export const projectQueryKeys = {
  all: ['operations'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...projectQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...projectQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: ProjectListParams) =>
    [...projectQueryKeys.lists(userId, employeeId), params] as const,
  detail: (userId: number, employeeId: string, projectId: number) =>
    [...projectQueryKeys.scoped(userId, employeeId), 'detail', projectId] as const,
  tab: (userId: number, employeeId: string, projectId: number, tab: string) =>
    [...projectQueryKeys.scoped(userId, employeeId), projectId, tab] as const,
  overview: (userId: number, employeeId: string) =>
    ['operations', 'dashboard', 'overview', userId, employeeId] as const,
}
