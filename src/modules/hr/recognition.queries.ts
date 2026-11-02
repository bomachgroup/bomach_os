import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

import { employeesApi } from './employees.api'
import { recognitionApi, type DisciplinaryListParams } from './recognition.api'

export const recognitionQueryKeys = {
  all: ['hr', 'recognition'] as const,
  awards: ['hr', 'recognition', 'awards'] as const,
  awardsUser: (userId: number, employeeId: string, year: number | null) =>
    [...recognitionQueryKeys.awards, userId, employeeId, year] as const,
  award: (userId: number, employeeId: string, id: number) =>
    [...recognitionQueryKeys.awards, userId, employeeId, 'detail', id] as const,
  leaderboard: (userId: number, employeeId: string, month: number, year: number) =>
    [...recognitionQueryKeys.all, 'leaderboard', userId, employeeId, month, year] as const,
  disciplinary: ['hr', 'recognition', 'disciplinary'] as const,
  disciplinaryList: (userId: number, employeeId: string, params: DisciplinaryListParams) =>
    [...recognitionQueryKeys.disciplinary, userId, employeeId, params] as const,
  disciplinaryDetail: (userId: number, employeeId: string, id: number) =>
    [...recognitionQueryKeys.disciplinary, userId, employeeId, 'detail', id] as const,
  employeeChoices: (userId: number, employeeId: string) =>
    [...recognitionQueryKeys.disciplinary, userId, employeeId, 'employee-choices'] as const,
}

export const awardsListOptions = (userId: number, employeeId: string, year: number | null) =>
  queryOptions({
    queryKey: recognitionQueryKeys.awardsUser(userId, employeeId, year),
    queryFn: ({ signal }) => recognitionApi.awards.listAll(year, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const awardDetailOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: recognitionQueryKeys.award(userId, employeeId, id),
    queryFn: ({ signal }) => recognitionApi.awards.get(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const leaderboardOptions = (
  userId: number,
  employeeId: string,
  month: number,
  year: number,
) =>
  queryOptions({
    queryKey: recognitionQueryKeys.leaderboard(userId, employeeId, month, year),
    queryFn: ({ signal }) => recognitionApi.leaderboard.get(month, year, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const disciplinaryListOptions = (
  userId: number,
  employeeId: string,
  params: DisciplinaryListParams,
) =>
  queryOptions({
    queryKey: recognitionQueryKeys.disciplinaryList(userId, employeeId, params),
    queryFn: ({ signal }) => recognitionApi.disciplinary.listAll(params, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const disciplinaryDetailOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: recognitionQueryKeys.disciplinaryDetail(userId, employeeId, id),
    queryFn: ({ signal }) => recognitionApi.disciplinary.get(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export interface EmployeeChoice {
  id: number
  employeeCode: string
  fullName: string
  designation: string
  branchName: string | null
}

export const employeeChoicesOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: recognitionQueryKeys.employeeChoices(userId, employeeId),
    queryFn: async ({ signal }): Promise<EmployeeChoice[]> => {
      const pageParams = { limit: 500, offset: 0, search: '', branchId: 'all', departmentId: 'all' }
      const [active, past] = await Promise.all([
        employeesApi.list({ ...pageParams, view: 'active' }, signal),
        employeesApi.list({ ...pageParams, view: 'past' }, signal),
      ])
      const unique = new Map<number, EmployeeChoice>()
      for (const employee of [...active.items, ...past.items]) {
        unique.set(employee.id, {
          id: employee.id,
          employeeCode: employee.employee_id,
          fullName: [employee.first_name, employee.middle_name, employee.last_name]
            .filter(Boolean)
            .join(' '),
          designation: employee.designation,
          branchName: employee.branch_name,
        })
      }
      return Array.from(unique.values()).sort((a, b) => a.fullName.localeCompare(b.fullName))
    },
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
