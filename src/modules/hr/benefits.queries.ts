import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { benefitsApi, type BenefitsListParams } from './benefits.api'

export const benefitsQueryKeys = {
  all: ['hr', 'benefits'] as const,
  lists: (userId: number, employeeId: string) =>
    [...benefitsQueryKeys.all, userId, employeeId, 'list'] as const,
  list: (userId: number, employeeId: string, params: BenefitsListParams) =>
    [...benefitsQueryKeys.lists(userId, employeeId), params] as const,
}

export const benefitsListOptions = (
  userId: number,
  employeeId: string,
  params: BenefitsListParams,
) =>
  queryOptions({
    queryKey: benefitsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => benefitsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
