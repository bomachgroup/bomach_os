import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import {
  operationsRegistersApi,
  type EngineeringReportListParams,
  type TaskListParams,
  type WorksiteListParams,
} from './operations-registers.api'

const freshness = {
  staleTime: DATA_FRESHNESS_MS.standard,
  refetchOnWindowFocus: true,
  refetchOnReconnect: true,
  retry: 1,
} as const

export const operationsRegisterKeys = {
  all: ['operations-registers'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...operationsRegisterKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string, kind: 'worksites' | 'tasks' | 'reports') =>
    [...operationsRegisterKeys.scoped(userId, employeeId), kind, 'list'] as const,
  list: (
    userId: number,
    employeeId: string,
    kind: 'worksites' | 'tasks' | 'reports',
    params: WorksiteListParams | TaskListParams | EngineeringReportListParams,
  ) => [...operationsRegisterKeys.lists(userId, employeeId, kind), params] as const,
  details: (userId: number, employeeId: string, kind: 'worksite' | 'task' | 'report') =>
    [...operationsRegisterKeys.scoped(userId, employeeId), kind, 'detail'] as const,
  detail: (userId: number, employeeId: string, kind: 'worksite' | 'task' | 'report', id: number) =>
    [...operationsRegisterKeys.details(userId, employeeId, kind), id] as const,
}

export const operationsRegisterQueries = {
  worksites: (userId: number, employeeId: string, params: WorksiteListParams) =>
    queryOptions({
      queryKey: operationsRegisterKeys.list(userId, employeeId, 'worksites', params),
      queryFn: ({ signal }) => operationsRegistersApi.worksites(params, signal),
      ...freshness,
      placeholderData: (previous) => previous,
    }),
  worksite: (userId: number, employeeId: string, id: number) =>
    queryOptions({
      queryKey: operationsRegisterKeys.detail(userId, employeeId, 'worksite', id),
      queryFn: ({ signal }) => operationsRegistersApi.worksite(id, signal),
      ...freshness,
    }),
  tasks: (userId: number, employeeId: string, params: TaskListParams) =>
    queryOptions({
      queryKey: operationsRegisterKeys.list(userId, employeeId, 'tasks', params),
      queryFn: ({ signal }) => operationsRegistersApi.tasks(params, signal),
      ...freshness,
      placeholderData: (previous) => previous,
    }),
  task: (userId: number, employeeId: string, id: number) =>
    queryOptions({
      queryKey: operationsRegisterKeys.detail(userId, employeeId, 'task', id),
      queryFn: ({ signal }) => operationsRegistersApi.task(id, signal),
      ...freshness,
    }),
  reports: (userId: number, employeeId: string, params: EngineeringReportListParams) =>
    queryOptions({
      queryKey: operationsRegisterKeys.list(userId, employeeId, 'reports', params),
      queryFn: ({ signal }) => operationsRegistersApi.engineeringReports(params, signal),
      ...freshness,
      placeholderData: (previous) => previous,
    }),
  report: (userId: number, employeeId: string, id: number) =>
    queryOptions({
      queryKey: operationsRegisterKeys.detail(userId, employeeId, 'report', id),
      queryFn: ({ signal }) => operationsRegistersApi.engineeringReport(id, signal),
      ...freshness,
    }),
}
