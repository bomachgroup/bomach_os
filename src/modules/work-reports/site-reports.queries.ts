import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { siteReportsApi, type SiteReportListParams, type SiteReportType } from './site-reports.api'

export const siteReportQueryKeys = {
  all: ['personal-site-reports'] as const,
  scoped: (type: SiteReportType, userId: number, employeeId: string) =>
    [...siteReportQueryKeys.all, type, userId, employeeId] as const,
  lists: (type: SiteReportType, userId: number, employeeId: string) =>
    [...siteReportQueryKeys.scoped(type, userId, employeeId), 'list'] as const,
  list: (type: SiteReportType, userId: number, employeeId: string, params: SiteReportListParams) =>
    [...siteReportQueryKeys.lists(type, userId, employeeId), params] as const,
  details: (type: SiteReportType, userId: number, employeeId: string) =>
    [...siteReportQueryKeys.scoped(type, userId, employeeId), 'detail'] as const,
  detail: (type: SiteReportType, userId: number, employeeId: string, reportId: number) =>
    [...siteReportQueryKeys.details(type, userId, employeeId), reportId] as const,
  equipment: (userId: number, worksiteId: number) =>
    [...siteReportQueryKeys.all, 'equipment', userId, worksiteId] as const,
  worksites: (userId: number) => [...siteReportQueryKeys.all, 'worksites', userId] as const,
  tasks: (userId: number, projectId: number) =>
    [...siteReportQueryKeys.all, 'tasks', userId, projectId] as const,
}

export const siteReportListOptions = (
  type: SiteReportType,
  userId: number,
  employeeId: string,
  params: SiteReportListParams,
) => ({
  queryKey: siteReportQueryKeys.list(type, userId, employeeId, params),
  queryFn: ({ signal }: { signal: AbortSignal }) => siteReportsApi.list(type, params, signal),
  staleTime: DATA_FRESHNESS_MS.history,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
})

export const siteReportDetailOptions = (
  type: SiteReportType,
  userId: number,
  employeeId: string,
  reportId: number,
) => ({
  queryKey: siteReportQueryKeys.detail(type, userId, employeeId, reportId),
  queryFn: ({ signal }: { signal: AbortSignal }) => siteReportsApi.detail(type, reportId, signal),
  staleTime: DATA_FRESHNESS_MS.history,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
})

export const siteEquipmentOptions = (userId: number, worksiteId: number) => ({
  queryKey: siteReportQueryKeys.equipment(userId, worksiteId),
  queryFn: ({ signal }: { signal: AbortSignal }) =>
    siteReportsApi.listEquipment(worksiteId, signal),
  staleTime: DATA_FRESHNESS_MS.reference,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
})

export const siteWorksitesOptions = (userId: number) => ({
  queryKey: siteReportQueryKeys.worksites(userId),
  queryFn: ({ signal }: { signal: AbortSignal }) => siteReportsApi.listWorksites(signal),
  staleTime: DATA_FRESHNESS_MS.reference,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
})

export const siteTasksOptions = (userId: number, projectId: number) => ({
  queryKey: siteReportQueryKeys.tasks(userId, projectId),
  queryFn: ({ signal }: { signal: AbortSignal }) =>
    siteReportsApi.listProjectTasks(projectId, signal),
  staleTime: DATA_FRESHNESS_MS.reference,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
})
