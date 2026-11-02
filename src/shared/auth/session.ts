import { queryOptions } from '@tanstack/react-query'

import { ApiError } from '@/shared/api/api-error'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { authApi, type CurrentUserDto, type EmployeeProfileDto, type RoleDto } from './auth.api'

export const AUTH_SESSION_QUERY_KEY = ['auth', 'session'] as const

export type PermissionSet = Record<string, string[]>

function isPermissionSet(value: unknown): value is PermissionSet {
  return (
    typeof value === 'object' &&
    value !== null &&
    !Array.isArray(value) &&
    Object.values(value).every(
      (actions) => Array.isArray(actions) && actions.every((action) => typeof action === 'string'),
    )
  )
}

export interface AuthenticatedSession {
  user: CurrentUserDto
  employee: EmployeeProfileDto
  roles: RoleDto[]
  permissions: PermissionSet
}

export class SessionBootstrapError extends Error {
  constructor(
    readonly stage: 'profile' | 'permissions',
    options?: { cause?: unknown },
  ) {
    super(
      stage === 'profile'
        ? 'We could not load your employee profile.'
        : 'We could not load your access permissions.',
      options,
    )
    this.name = 'SessionBootstrapError'
  }
}

export async function loadAuthenticatedSession(
  signal?: AbortSignal,
): Promise<AuthenticatedSession> {
  let user: CurrentUserDto
  try {
    user = await authApi.currentUser(signal)
  } catch (cause) {
    if (cause instanceof ApiError && cause.status === 401) throw cause
    throw new SessionBootstrapError('permissions', { cause })
  }

  if (!isPermissionSet(user.permissions)) {
    throw new SessionBootstrapError('permissions')
  }

  if (typeof window !== 'undefined') {
    window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
  }

  let employee: EmployeeProfileDto
  try {
    employee = await authApi.employeeProfile(user.id, signal)
  } catch (cause) {
    throw new SessionBootstrapError('profile', { cause })
  }

  const roles = user.role ? [{ ...user.role, permissions: user.permissions }] : []
  return {
    user,
    employee,
    roles,
    permissions: user.permissions,
  }
}

export const authSessionQueryOptions = () =>
  queryOptions({
    queryKey: AUTH_SESSION_QUERY_KEY,
    queryFn: ({ signal }) => loadAuthenticatedSession(signal),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

export function hasPermission(
  permissions: PermissionSet,
  resource: string,
  action: string,
): boolean {
  return permissions[resource]?.includes(action) ?? false
}
