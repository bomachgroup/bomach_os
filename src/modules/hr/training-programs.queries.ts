import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { trainingProgramsApi, type TrainingProgramListParams } from './training-programs.api'

export const trainingProgramsQueryKeys = {
  all: ['hr', 'training-programs'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...trainingProgramsQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...trainingProgramsQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: TrainingProgramListParams) =>
    [...trainingProgramsQueryKeys.lists(userId, employeeId), params] as const,
  detail: (userId: number, employeeId: string, id: number) =>
    [...trainingProgramsQueryKeys.scoped(userId, employeeId), 'detail', id] as const,
}

export const trainingProgramListOptions = (
  userId: number,
  employeeId: string,
  params: TrainingProgramListParams,
) =>
  queryOptions({
    queryKey: trainingProgramsQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => trainingProgramsApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const trainingProgramDetailOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: trainingProgramsQueryKeys.detail(userId, employeeId, id),
    queryFn: ({ signal }) => trainingProgramsApi.get(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
