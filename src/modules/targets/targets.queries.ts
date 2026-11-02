import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import type { TargetListParams, TargetReportListParams } from './targets.api'
import { targetsApi } from './targets.api'

export const targetsQueryKeys = {
  all: ['my-targets'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...targetsQueryKeys.all, userId, employeeId] as const,
  assigned: (userId: number, employeeId: string) =>
    [...targetsQueryKeys.scoped(userId, employeeId), 'assigned'] as const,
  assignedList: (userId: number, employeeId: string, params: TargetListParams) =>
    [...targetsQueryKeys.assigned(userId, employeeId), params] as const,
  reports: (userId: number, employeeId: string) =>
    [...targetsQueryKeys.scoped(userId, employeeId), 'reports'] as const,
  reportList: (userId: number, employeeId: string, params: TargetReportListParams) =>
    [...targetsQueryKeys.reports(userId, employeeId), params] as const,
  reportDetail: (userId: number, employeeId: string, reportId: number) =>
    [...targetsQueryKeys.scoped(userId, employeeId), 'report', reportId] as const,
}

export const assignedTargetsQueryOptions = (
  userId: number,
  employeeId: string,
  params: TargetListParams,
) =>
  queryOptions({
    queryKey: targetsQueryKeys.assignedList(userId, employeeId, params),
    queryFn: ({ signal }) => targetsApi.listAssigned(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const targetReportsQueryOptions = (
  userId: number,
  employeeId: string,
  params: TargetReportListParams,
) =>
  queryOptions({
    queryKey: targetsQueryKeys.reportList(userId, employeeId, params),
    queryFn: ({ signal }) => targetsApi.listReports(params, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const targetReportDetailQueryOptions = (
  userId: number,
  employeeId: string,
  reportId: number,
) =>
  queryOptions({
    queryKey: targetsQueryKeys.reportDetail(userId, employeeId, reportId),
    queryFn: ({ signal }) => targetsApi.reportDetail(reportId, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
