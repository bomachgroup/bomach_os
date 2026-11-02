import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import type { LeaveRequestListParams } from './leaves.api'
import { leaveRequestsApi } from './leaves.api'

export const leaveRequestsQueryKeys = {
  all: ['my-leaves'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...leaveRequestsQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...leaveRequestsQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: LeaveRequestListParams) =>
    [...leaveRequestsQueryKeys.lists(userId, employeeId), params] as const,
  stats: (userId: number, employeeId: string) =>
    [...leaveRequestsQueryKeys.scoped(userId, employeeId), 'stats'] as const,
  details: (userId: number, employeeId: string) =>
    [...leaveRequestsQueryKeys.scoped(userId, employeeId), 'detail'] as const,
  detail: (userId: number, employeeId: string, requestId: number) =>
    [...leaveRequestsQueryKeys.details(userId, employeeId), requestId] as const,
}

export const leaveRequestListQueryOptions = (
  userId: number,
  employeeId: string,
  params: LeaveRequestListParams,
) =>
  queryOptions({
    queryKey: leaveRequestsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => leaveRequestsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const leaveRequestStatsQueryOptions = (
  userId: number,
  employeeId: string,
  employeePk: number,
) =>
  queryOptions({
    queryKey: leaveRequestsQueryKeys.stats(userId, employeeId),
    queryFn: ({ signal }) => leaveRequestsApi.stats(employeePk, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const leaveRequestDetailQueryOptions = (
  userId: number,
  employeeId: string,
  requestId: number,
) =>
  queryOptions({
    queryKey: leaveRequestsQueryKeys.detail(userId, employeeId, requestId),
    queryFn: ({ signal }) => leaveRequestsApi.detail(requestId, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
