import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { attendanceApi } from './attendance.api'

export const attendanceQueryKeys = {
  all: ['attendance'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...attendanceQueryKeys.all, userId, employeeId] as const,
  today: (userId: number, employeeId: string) =>
    [...attendanceQueryKeys.scoped(userId, employeeId), 'today'] as const,
  summary: (userId: number, employeeId: string) =>
    [...attendanceQueryKeys.scoped(userId, employeeId), 'summary'] as const,
  status: (userId: number, employeeId: string) =>
    [...attendanceQueryKeys.scoped(userId, employeeId), 'biometric-status'] as const,
  locations: (userId: number, employeeId: string) =>
    [...attendanceQueryKeys.scoped(userId, employeeId), 'locations'] as const,
  branches: (userId: number) => [...attendanceQueryKeys.all, 'branches', userId] as const,
  history: (
    userId: number,
    employeeId: string,
    params: { limit: number; offset: number; dateFrom: string; dateTo: string },
  ) => [...attendanceQueryKeys.scoped(userId, employeeId), 'history', params] as const,
  histories: (userId: number, employeeId: string) =>
    [...attendanceQueryKeys.scoped(userId, employeeId), 'history'] as const,
}

export const attendanceTodayQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: attendanceQueryKeys.today(userId, employeeId),
    queryFn: ({ signal }) => attendanceApi.today(signal),
    staleTime: DATA_FRESHNESS_MS.live,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const attendanceSummaryQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: attendanceQueryKeys.summary(userId, employeeId),
    queryFn: ({ signal }) => attendanceApi.summary(signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const biometricStatusQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: attendanceQueryKeys.status(userId, employeeId),
    queryFn: ({ signal }) => attendanceApi.biometricStatus(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const workLocationsQueryOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: attendanceQueryKeys.locations(userId, employeeId),
    queryFn: ({ signal }) => attendanceApi.locations(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const workLocationBranchesQueryOptions = (userId: number) =>
  queryOptions({
    queryKey: attendanceQueryKeys.branches(userId),
    queryFn: ({ signal }) => attendanceApi.branches(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const attendanceHistoryQueryOptions = (
  userId: number,
  employeeId: string,
  params: { limit: number; offset: number; dateFrom: string; dateTo: string },
) =>
  queryOptions({
    queryKey: attendanceQueryKeys.history(userId, employeeId, params),
    queryFn: ({ signal }) => attendanceApi.history(params, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
