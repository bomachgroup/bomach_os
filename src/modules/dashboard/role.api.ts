import { apiClient } from '@/shared/api/api-client'

export interface RoleBranchDto {
  id: number
  branch_name: string
}

export interface AssignedRoleDto {
  id: number
  name: string
  branches: RoleBranchDto[]
  permissions: Record<string, string[]>
  created_at: string
  updated_at: string
}

export interface RolePageDto<T> {
  items: T[]
  count: number
}

export interface RoleDescriptionDto {
  id: number
  role_id: number
  purpose: string
  responsibilities: string
  job_description: string
  created_at: string
  updated_at: string
}

export interface RoleKpiDto {
  id: number
  role_id: number
  metric_id: number
  metric: { id: number; name: string; description: string; unit: string }
  tracking_mode: string
  target_value: string | number | null
  weight: string | number | null
  period: string
  sequence: number
  is_active: boolean
}

export interface RoleSopDto {
  id: number
  role_id: number
  sop_id: number
  sop: {
    id: number
    title: string
    description: string
    version: string
    priority: string
    is_up_to_date: boolean
    department_id: number | null
    unit_id: number | null
  }
  is_active: boolean
}

export interface RoleReportingLineDto {
  id: number
  role_id: number
  role: { id: number; name: string }
  reports_to_role_id: number
  reports_to_role: { id: number; name: string }
  relationship_type: string
  branch_id: number | null
  branch: RoleBranchDto | null
  department_id: number | null
  department: { id: number; name: string } | null
  unit_id: number | null
  unit: { id: number; name: string } | null
  sequence: number
  is_active: boolean
  cycle_detected?: boolean
}

export interface RoleReportingChainDto {
  role: { id: number; name: string }
  chain: RoleReportingLineDto[]
}

export interface RoleReportingTreeNodeDto {
  id: number
  role_id: number
  role: { id: number; name: string }
  reports_to_role_id: number
  reports_to_role: { id: number; name: string }
  relationship_type: string
  branch_id: number | null
  department_id: number | null
  unit_id: number | null
  is_active: boolean
  cycle_detected?: boolean
  children: RoleReportingTreeNodeDto[]
}

export interface RoleReportingTreeDto {
  role: { id: number; name: string }
  direct_reports: RoleReportingTreeNodeDto[]
}

export interface RoleCareerPathNodeDto {
  id: number
  from_role_id: number
  to_role_id: number
  to_role: { id: number; name: string }
  description: string
  requirements: string
  estimated_duration_months: number | null
  sequence: number
  is_active: boolean
  cycle_detected?: boolean
  children: RoleCareerPathNodeDto[]
}

export interface RoleCareerPathTreeDto {
  role: { id: number; name: string }
  paths: RoleCareerPathNodeDto[]
}

export interface RoleTrainingRequirementDto {
  id: number
  role_id: number
  training_program_id: number
  training_program: {
    id: number
    program_name: string
    provider: string
    status: string
    start_date: string
    end_date: string
  }
  requirement_type: string
  sequence: number
  is_active: boolean
}

export interface RoleTrainingGroupedDto {
  mandatory: RoleTrainingRequirementDto[]
  continuous: RoleTrainingRequirementDto[]
}

export interface RolePlaybookItemDto {
  id: number
  role_id: number
  title: string
  description: string
  kind: string
  sequence: number
  is_active: boolean
}

export interface RolePlaybookGroupedDto {
  best_practice: RolePlaybookItemDto[]
  common_mistake: RolePlaybookItemDto[]
  winning_strategy: RolePlaybookItemDto[]
  lesson_learned: RolePlaybookItemDto[]
}

export interface RoleResourceDto {
  id: number
  role_id: number
  name: string
  description: string
  kind: string
  sequence: number
  is_active: boolean
}

export interface RoleResourcesGroupedDto {
  physical: RoleResourceDto[]
  software: RoleResourceDto[]
  document: RoleResourceDto[]
  skill: RoleResourceDto[]
}

export interface RoleTaskTemplateDto {
  id: number
  role_id: number
  title: string
  description: string
  sequence: number
  default_priority: string
  estimated_minutes: number | null
  is_active: boolean
}

export interface RoleDailyRoutineDto {
  id: number
  role_id: number
  title: string
  description: string
  sequence: number
  time_of_day: string | null
  estimated_minutes: number | null
  is_active: boolean
}

const listQuery = (offset: number, limit = 10) =>
  new URLSearchParams({ offset: String(offset), limit: String(limit) }).toString()

export const myRoleApi = {
  assignedRole: (userId: number, signal?: AbortSignal) =>
    apiClient.get<AssignedRoleDto>(`/roles/employees/${userId}`, { signal }),

  description: (signal?: AbortSignal) =>
    apiClient.get<RoleDescriptionDto>('/roles/me/description', { signal }),

  kpis: (offset: number, signal?: AbortSignal) =>
    apiClient.get<RolePageDto<RoleKpiDto>>(`/roles/me/kpis?${listQuery(offset)}`, { signal }),

  sops: (offset: number, signal?: AbortSignal) =>
    apiClient.get<RolePageDto<RoleSopDto>>(`/roles/me/sops?${listQuery(offset)}`, { signal }),

  reportingLines: (offset: number, signal?: AbortSignal) =>
    apiClient.get<RolePageDto<RoleReportingLineDto>>(
      `/roles/me/reporting-lines?${listQuery(offset)}`,
      { signal },
    ),

  reportingChain: (signal?: AbortSignal) =>
    apiClient.get<RoleReportingChainDto>('/roles/me/reporting-chain', { signal }),

  reportingTree: (signal?: AbortSignal) =>
    apiClient.get<RoleReportingTreeDto>('/roles/me/reporting-tree', { signal }),

  careerPath: (signal?: AbortSignal) =>
    apiClient.get<RoleCareerPathTreeDto>('/roles/me/career-path/tree', { signal }),

  training: (signal?: AbortSignal) =>
    apiClient.get<RoleTrainingGroupedDto>('/roles/me/training-requirements/grouped', { signal }),

  playbook: (signal?: AbortSignal) =>
    apiClient.get<RolePlaybookGroupedDto>('/roles/me/success-playbook/grouped', { signal }),

  resources: (signal?: AbortSignal) =>
    apiClient.get<RoleResourcesGroupedDto>('/roles/me/resources/grouped', { signal }),

  taskTemplates: (offset: number, signal?: AbortSignal) =>
    apiClient.get<RolePageDto<RoleTaskTemplateDto>>(
      `/roles/me/task-templates?${listQuery(offset)}`,
      { signal },
    ),

  dailyRoutine: (offset: number, signal?: AbortSignal) =>
    apiClient.get<RolePageDto<RoleDailyRoutineDto>>(
      `/roles/me/daily-routine?${listQuery(offset)}`,
      { signal },
    ),
}
