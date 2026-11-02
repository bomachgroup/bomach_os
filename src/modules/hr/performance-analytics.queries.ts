import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { employeesApi, employeesQueryKeys, type EmployeeDto } from './employees.api'
import { performanceAnalyticsApi } from './performance-analytics.api'

export const performanceAnalyticsQueryKeys = {
  all: ['hr', 'performance-analytics'] as const,
  scorecard: employeesQueryKeys.scorecard,
  employeeChoices: (userId: number, employeeId: string) =>
    [...performanceAnalyticsQueryKeys.all, userId, employeeId, 'employee-choices'] as const,
  evaluations: (
    userId: number,
    employeeId: string,
    targetId: number,
    month: number,
    year: number,
  ) => [...performanceAnalyticsQueryKeys.all, userId, employeeId, targetId, month, year] as const,
  evaluation: (userId: number, employeeId: string, id: number) =>
    [...performanceAnalyticsQueryKeys.all, userId, employeeId, 'detail', id] as const,
}

export interface PerformanceEmployeeChoice {
  id: number
  employeeCode: string
  fullName: string
  designation: string
  branchName: string | null
}

function mapEmployee(employee: EmployeeDto): PerformanceEmployeeChoice {
  return {
    id: employee.id,
    employeeCode: employee.employee_id,
    fullName: [employee.first_name, employee.middle_name, employee.last_name]
      .filter(Boolean)
      .join(' '),
    designation: employee.designation,
    branchName: employee.branch_name,
  }
}

export const performanceScorecardOptions = (
  userId: number,
  employeeKey: string,
  employeeRecordId: number,
  month: number,
  year: number,
) =>
  queryOptions({
    queryKey: performanceAnalyticsQueryKeys.scorecard(
      userId,
      employeeKey,
      employeeRecordId,
      month,
      year,
    ),
    queryFn: ({ signal }) =>
      performanceAnalyticsApi.scorecard(employeeRecordId, month, year, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const performanceEmployeeChoicesOptions = (userId: number, employeeKey: string) =>
  queryOptions({
    queryKey: performanceAnalyticsQueryKeys.employeeChoices(userId, employeeKey),
    queryFn: async ({ signal }): Promise<PerformanceEmployeeChoice[]> => {
      const params = {
        limit: 500,
        offset: 0,
        search: '',
        branchId: 'all',
        departmentId: 'all',
      }
      const [active, past] = await Promise.all([
        employeesApi.list({ ...params, view: 'active' }, signal),
        employeesApi.list({ ...params, view: 'past' }, signal),
      ])
      const unique = new Map<number, PerformanceEmployeeChoice>()
      for (const employee of [...active.items, ...past.items]) {
        unique.set(employee.id, mapEmployee(employee))
      }
      return Array.from(unique.values()).sort((a, b) => a.fullName.localeCompare(b.fullName))
    },
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const employeeEvaluationListOptions = (
  userId: number,
  employeeKey: string,
  targetEmployeeId: number,
  month: number,
  year: number,
) =>
  queryOptions({
    queryKey: performanceAnalyticsQueryKeys.evaluations(
      userId,
      employeeKey,
      targetEmployeeId,
      month,
      year,
    ),
    queryFn: ({ signal }) =>
      performanceAnalyticsApi.evaluations.list(targetEmployeeId, month, year, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const employeeEvaluationDetailOptions = (userId: number, employeeKey: string, id: number) =>
  queryOptions({
    queryKey: performanceAnalyticsQueryKeys.evaluation(userId, employeeKey, id),
    queryFn: ({ signal }) => performanceAnalyticsApi.evaluations.get(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
