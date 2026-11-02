import { queryOptions } from '@tanstack/react-query'

import { myRoleApi } from './role.api'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'

export const myRoleQueryKeys = {
  root: (userId: number) => ['my-role', userId] as const,
  assigned: (userId: number) => [...myRoleQueryKeys.root(userId), 'assigned'] as const,
  section: (userId: number, name: string, page?: number) =>
    [...myRoleQueryKeys.root(userId), name, ...(page === undefined ? [] : [page])] as const,
}

export const assignedRoleQueryOptions = (userId: number) =>
  queryOptions({
    queryKey: myRoleQueryKeys.assigned(userId),
    queryFn: ({ signal }) => myRoleApi.assignedRole(userId, signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
