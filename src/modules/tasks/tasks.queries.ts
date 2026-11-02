import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import type { MyTasksListParams } from './tasks.api'
import { myTasksApi } from './tasks.api'

export const myTasksQueryKeys = {
  all: ['my-tasks'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...myTasksQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...myTasksQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: MyTasksListParams) =>
    [...myTasksQueryKeys.lists(userId, employeeId), params] as const,
  summary: (userId: number, employeeId: string) =>
    [...myTasksQueryKeys.scoped(userId, employeeId), 'summary'] as const,
  details: (userId: number, employeeId: string) =>
    [...myTasksQueryKeys.scoped(userId, employeeId), 'detail'] as const,
  detail: (userId: number, employeeId: string, taskId: number) =>
    [...myTasksQueryKeys.details(userId, employeeId), taskId] as const,
}

export const myTasksListQueryOptions = (
  userId: number,
  employeeId: string,
  params: MyTasksListParams,
) =>
  queryOptions({
    queryKey: myTasksQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => myTasksApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const myTasksSummaryQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: myTasksQueryKeys.summary(userId, employeeId),
    queryFn: ({ signal }) => myTasksApi.summary(signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const myTaskDetailQueryOptions = (userId: number, employeeId: string, taskId: number) =>
  queryOptions({
    queryKey: myTasksQueryKeys.detail(userId, employeeId, taskId),
    queryFn: ({ signal }) => myTasksApi.detail(taskId, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
