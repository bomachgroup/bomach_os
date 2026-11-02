import { queryOptions } from '@tanstack/react-query'

import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { employeesApi } from '@/modules/hr/employees.api'

import { loansApi, type LoanListParams } from './loans.api'

export const loansQueryKeys = {
  all: ['hr', 'loans'] as const,
  scoped: (userId: number, employeeId: string) =>
    [...loansQueryKeys.all, userId, employeeId] as const,
  lists: (userId: number, employeeId: string) =>
    [...loansQueryKeys.scoped(userId, employeeId), 'list'] as const,
  list: (userId: number, employeeId: string, params: LoanListParams) =>
    [...loansQueryKeys.lists(userId, employeeId), params] as const,
  detail: (userId: number, employeeId: string, id: number) =>
    [...loansQueryKeys.scoped(userId, employeeId), 'detail', id] as const,
  employeeChoices: (userId: number, employeeId: string) =>
    [...loansQueryKeys.scoped(userId, employeeId), 'employee-choices'] as const,
}

export const loansListOptions = (userId: number, employeeId: string, params: LoanListParams) =>
  queryOptions({
    queryKey: loansQueryKeys.list(userId, employeeId, params),
    queryFn: ({ signal }) => loansApi.list(params, signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const loanDetailOptions = (userId: number, employeeId: string, id: number) =>
  queryOptions({
    queryKey: loansQueryKeys.detail(userId, employeeId, id),
    queryFn: ({ signal }) => loansApi.get(id, signal),
    staleTime: DATA_FRESHNESS_MS.history,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export const loanEmployeeChoicesOptions = (userId: number, employeeId: string) =>
  queryOptions({
    queryKey: loansQueryKeys.employeeChoices(userId, employeeId),
    queryFn: ({ signal }) =>
      employeesApi.list(
        {
          limit: 500,
          offset: 0,
          search: '',
          view: 'active',
          branchId: 'all',
          departmentId: 'all',
        },
        signal,
      ),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
