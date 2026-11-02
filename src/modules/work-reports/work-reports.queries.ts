import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import type { WorkReportListParams } from './work-reports.api'
import { workReportsApi } from './work-reports.api'

export const workReportsQueryKeys = {
  all: ['work-reports'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...workReportsQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...workReportsQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: WorkReportListParams) =>
    [...workReportsQueryKeys.lists(userId, employeeId), params] as const,
  details: (userId: number, employeeId: string) =>
    [...workReportsQueryKeys.scoped(userId, employeeId), 'detail'] as const,
  detail: (userId: number, employeeId: string, reportId: number) =>
    [...workReportsQueryKeys.details(userId, employeeId), reportId] as const,
  workspaces: (userId: number, employeeId: string) =>
    [...workReportsQueryKeys.scoped(userId, employeeId), 'workspaces'] as const,
}

export const workReportsListQueryOptions = (
  userId: number,
  employeeId: string,
  params: WorkReportListParams,
) =>
  queryOptions({
    queryKey: workReportsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => workReportsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const workReportDetailQueryOptions = (
  userId: number,
  employeeId: string,
  reportId: number,
) =>
  queryOptions({
    queryKey: workReportsQueryKeys.detail(userId, employeeId, reportId),
    queryFn: ({ signal }) => workReportsApi.detail(reportId, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const workspacesQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: workReportsQueryKeys.workspaces(userId, employeeId),
    queryFn: ({ signal }) => workReportsApi.workspaces(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
