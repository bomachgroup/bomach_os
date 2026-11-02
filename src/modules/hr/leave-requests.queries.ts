import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { hrLeaveRequestsApi, type HRLeaveRequestParams } from './leave-requests.api'

export const hrLeaveRequestQueryKeys = {
  all: ['hr', 'leave-requests'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...hrLeaveRequestQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...hrLeaveRequestQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: HRLeaveRequestParams) =>
    [...hrLeaveRequestQueryKeys.lists(userId, employeeId), params] as const,
  detail: (userId: number, employeeId: string, id: number) =>
    [...hrLeaveRequestQueryKeys.scoped(userId, employeeId), 'detail', id] as const,
  summary: (userId: number, employeeId: string) =>
    [...hrLeaveRequestQueryKeys.scoped(userId, employeeId), 'summary'] as const,
}

export const hrLeaveRequestListOptions = (
  userId: number,
  employeeId: string,
  params: HRLeaveRequestParams,
) =>
  queryOptions({
    queryKey: hrLeaveRequestQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => hrLeaveRequestsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const hrLeaveRequestSummaryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: hrLeaveRequestQueryKeys.summary(userId, employeeId),
    queryFn: ({ signal }) => hrLeaveRequestsApi.summary(signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const hrLeaveRequestDetailOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: hrLeaveRequestQueryKeys.detail(userId, employeeId, id),
    queryFn: ({ signal }) => hrLeaveRequestsApi.detail(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
