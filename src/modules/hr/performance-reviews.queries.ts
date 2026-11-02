import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { performanceReviewsApi, type PerformanceReviewListParams } from './performance-reviews.api'

export const performanceReviewsQueryKeys = {
  all: ['hr', 'performance-reviews'] as const,
  lists: (userId: number, employeeId: string) =>
    [...performanceReviewsQueryKeys.all, userId, employeeId, 'list'] as const,
  list: (userId: number, employeeId: string, params: PerformanceReviewListParams) =>
    [...performanceReviewsQueryKeys.lists(userId, employeeId), params] as const,
}

export const performanceReviewsListOptions = (
  userId: number,
  employeeId: string,
  params: PerformanceReviewListParams,
) =>
  queryOptions({
    queryKey: performanceReviewsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => performanceReviewsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
