import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { myWorkReportsApi, type MyWorkReportsParams } from './my-work-reports.api'

export const myWorkReportsQueryKeys = {
  all: ['my-work-reports'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...myWorkReportsQueryKeys.all, userId, employeeId] as const,
  list: (userId: number, employeeId: string, params: MyWorkReportsParams) =>
    [...myWorkReportsQueryKeys.scoped(userId, employeeId), params] as const,
}

export const myWorkReportsListOptions = (
  userId: number,
  employeeId: string,
  params: MyWorkReportsParams,
) =>
  queryOptions({
    queryKey: myWorkReportsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => myWorkReportsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
