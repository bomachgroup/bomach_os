import { apiClient } from '@/shared/api/api-client'

export type SiteReportType = 'engineering' | 'survey'
export type SiteReportStatus = 'draft' | 'submitted' | 'approved' | 'rejected'
export type SiteReportStatusFilter = 'all' | SiteReportStatus

export interface SiteReportActivity {
  id?: number
  activity_type: string
  description: string
}

export interface SiteReportExpense {
  id?: number
  expense_category: string
  name: string
  amount: string | number
  description: string
}

export interface SiteReportMaterial {
  id?: number
  equipment_id: number | null
  equipment_name: string
  unit: string
  quantity_used: string | number
}

export interface BearingDistancePoint {
  id?: number
  point_number: number
  azimuth_degrees: number
  azimuth_minutes: number
  azimuth_seconds: string | number
  distance: string | number
}

export interface XyzPoint {
  id?: number
  point_number: number
  northing: string | number
  easting: string | number
  elevation: string | number
}

export interface SiteReport {
  id: number
  employee_id: number | null
  employee_name: string | null
  status: SiteReportStatus
  rating: number | null
  reviewed_by_id: number | null
  reviewed_at: string | null
  worksite_id: number
  worksite_name: string
  project_id: number | null
  task_id: number | null
  date: string
  summary: string
  tomorrow_activities?: string
  comments_suggestions?: string
  work_data_type?: 'bearing_distance' | 'site_points_xyz'
  measurement_unit?: string
  coordinate_system?: string
  datum?: string
  coordinate_zone?: string
  gps_latitude?: string | number | null
  gps_longitude?: string | number | null
  submission_version: number
  activities: SiteReportActivity[]
  expenses: SiteReportExpense[]
  materials_used: SiteReportMaterial[]
  attachments: string[]
  bearing_distance_points?: BearingDistancePoint[]
  xyz_points?: XyzPoint[]
  created_at: string
  updated_at: string
}

export interface SiteReportPage {
  count: number
  items: SiteReport[]
}

export interface WorksiteOption {
  id: number
  project_id: number | null
  name: string
  location: string
  status: string
}

export interface WorksitePage {
  count: number
  items: WorksiteOption[]
}

export interface EngineeringSiteReportCreate {
  worksite_id: number
  project_id?: number | null
  task_id?: number | null
  date: string
  tomorrow_activities?: string
  comments_suggestions?: string
  activities: Array<Pick<SiteReportActivity, 'activity_type' | 'description'>>
  expenses?: Array<Pick<SiteReportExpense, 'expense_category' | 'name' | 'amount' | 'description'>>
  materials_used?: Array<{ equipment_id: number; quantity_used: string | number }>
  attachments?: string[]
}

export interface SurveySiteReportCreate {
  worksite_id: number
  project_id?: number | null
  task_id?: number | null
  date: string
  work_data_type: 'bearing_distance' | 'site_points_xyz'
  measurement_unit: string
  coordinate_system?: string
  datum?: string
  coordinate_zone?: string
  gps_latitude?: string | null
  gps_longitude?: string | null
  activities: Array<Pick<SiteReportActivity, 'description'>>
  expenses?: Array<Pick<SiteReportExpense, 'expense_category' | 'name' | 'amount' | 'description'>>
  materials_used?: Array<{ equipment_id: number; quantity_used: string | number }>
  attachments?: string[]
  bearing_distance_points?: Array<Omit<BearingDistancePoint, 'id'>>
  xyz_points?: Array<Omit<XyzPoint, 'id'>>
}

export interface TaskOption {
  id: number
  name?: string
  title?: string
  project_id?: number | null
  project?: { id: number; name?: string } | null
}

export interface SiteEquipmentOption {
  id: number
  worksite_id: number
  name: string
  unit: string
  quantity: string | number
}

export interface SiteReportListParams {
  employeeId: number
  status: SiteReportStatusFilter
  limit: number
  offset: number
}

export interface EngineeringSiteReportUpdate {
  date?: string
  tomorrow_activities?: string
  comments_suggestions?: string
  activities?: Array<Pick<SiteReportActivity, 'activity_type' | 'description'>>
  expenses?: Array<Pick<SiteReportExpense, 'expense_category' | 'name' | 'amount' | 'description'>>
  materials_used?: Array<{ equipment_id: number; quantity_used: string | number }>
  attachments?: string[]
}

export interface SurveySiteReportUpdate {
  date?: string
  measurement_unit?: string
  coordinate_system?: string
  datum?: string
  coordinate_zone?: string
  gps_latitude?: string | null
  gps_longitude?: string | null
  activities?: Array<Pick<SiteReportActivity, 'description'>>
  expenses?: Array<Pick<SiteReportExpense, 'expense_category' | 'name' | 'amount' | 'description'>>
  materials_used?: Array<{ equipment_id: number; quantity_used: string | number }>
  attachments?: string[]
  bearing_distance_points?: Array<Omit<BearingDistancePoint, 'id'>>
  xyz_points?: Array<Omit<XyzPoint, 'id'>>
}

function endpoint(type: SiteReportType): string {
  return type === 'engineering' ? '/engineering-site-reports' : '/survey-site-reports'
}

function listQuery(params: SiteReportListParams): string {
  const search = new URLSearchParams({
    employee_id: String(params.employeeId),
    limit: String(params.limit),
    offset: String(params.offset),
  })
  if (params.status !== 'all') search.set('status', params.status)
  return search.toString()
}

export const siteReportsApi = {
  list: (type: SiteReportType, params: SiteReportListParams, signal?: AbortSignal) =>
    apiClient.get<SiteReportPage>(`${endpoint(type)}?${listQuery(params)}`, { signal }),
  listEquipment: async (worksiteId: number, signal?: AbortSignal) => {
    const limit = 100
    const items: SiteEquipmentOption[] = []
    while (true) {
      const search = new URLSearchParams({
        worksite_id: String(worksiteId),
        limit: String(limit),
        offset: String(items.length),
      })
      const page = await apiClient.get<{ count: number; items: SiteEquipmentOption[] }>(
        `/site-equipment?${search.toString()}`,
        { signal },
      )
      items.push(...page.items)
      if (!page.items.length) break
      if (items.length >= page.count) break
    }
    return items
  },
  listWorksites: async (signal?: AbortSignal): Promise<WorksiteOption[]> => {
    const limit = 100
    const items: WorksiteOption[] = []
    while (true) {
      const search = new URLSearchParams({ limit: String(limit), offset: String(items.length) })
      const page = await apiClient.get<WorksitePage>(`/worksites?${search}`, { signal })
      items.push(...page.items)
      if (!page.items.length || items.length >= page.count) break
    }
    return items
  },
  listProjectTasks: async (projectId: number, signal?: AbortSignal): Promise<TaskOption[]> => {
    const limit = 100
    const items: TaskOption[] = []
    while (true) {
      const search = new URLSearchParams({
        project_id: String(projectId),
        limit: String(limit),
        offset: String(items.length),
      })
      const page = await apiClient.get<{ count: number; items: TaskOption[] }>(`/tasks?${search}`, {
        signal,
      })
      items.push(...page.items)
      if (!page.items.length || items.length >= page.count) break
    }
    return items
  },
  detail: (type: SiteReportType, reportId: number, signal?: AbortSignal) =>
    apiClient.get<SiteReport>(`${endpoint(type)}/${reportId}`, { signal }),
  update: (
    type: SiteReportType,
    reportId: number,
    input: EngineeringSiteReportUpdate | SurveySiteReportUpdate,
  ) => apiClient.put<SiteReport>(`${endpoint(type)}/${reportId}`, input),
  create: (type: SiteReportType, input: EngineeringSiteReportCreate | SurveySiteReportCreate) =>
    apiClient.post<SiteReport>(endpoint(type), input),
  submit: (type: SiteReportType, reportId: number) =>
    apiClient.post<SiteReport>(`${endpoint(type)}/${reportId}/submit`, {}),
  remove: (type: SiteReportType, reportId: number) =>
    apiClient.delete<{ detail: string }>(`${endpoint(type)}/${reportId}`),
}
