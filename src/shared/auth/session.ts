import { queryOptions } from '@tanstack/react-query'

import { ApiError } from '@/shared/api/api-error'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { authApi, type CurrentUserDto, type EmployeeProfileDto, type RoleDto } from './auth.api'

export const AUTH_SESSION_QUERY_KEY = ['auth', 'session'] as const

export type PermissionSet = Record<string, string[]>

export interface AuthenticatedSession {
  user: CurrentUserDto
  employee: EmployeeProfileDto
  roles: RoleDto[]
  permissions: PermissionSet
  permissionsCatalog: Record<string, string[]>
}

export class SessionBootstrapError extends Error {
  constructor(
    readonly stage: 'profile' | 'permissions',
    options?: { cause?: unknown },
  ) {
    super(
      stage === 'profile'
        ? 'We could not load your employee profile.'
        : 'We could not load your roles and permissions.',
      options,
    )
    this.name = 'SessionBootstrapError'
  }
}

export async function loadAuthenticatedSession(
  signal?: AbortSignal,
): Promise<AuthenticatedSession> {
  const user = await authApi.currentUser(signal)
  if (typeof window !== 'undefined') {
    window.sessionStorage.setItem(SESSION_ESTABLISHED_KEY, '1')
  }

  let employee: EmployeeProfileDto
  try {
    employee = await authApi.employeeProfile(user.id, signal)
  } catch (cause) {
    throw new SessionBootstrapError('profile', { cause })
  }

  try {
    const [roleResult, catalogResult] = await Promise.allSettled([
      authApi.employeeRole(user.id, signal),
      authApi.permissionsCatalog(signal),
    ])

    let role: RoleDto | null = null
    if (roleResult.status === 'fulfilled') {
      role = roleResult.value
    } else if (!(roleResult.reason instanceof ApiError && roleResult.reason.status === 404)) {
      throw roleResult.reason
    }

    if (catalogResult.status === 'rejected') throw catalogResult.reason
    const roles = role ? [role] : []
    return {
      user,
      employee,
      roles,
      permissions: role?.permissions ?? {},
      permissionsCatalog: catalogResult.value.permissions_map,
    }
  } catch (cause) {
    throw new SessionBootstrapError('permissions', { cause })
  }
}

export const authSessionQueryOptions = () =>
  queryOptions({
    queryKey: AUTH_SESSION_QUERY_KEY,
    queryFn: ({ signal }) => loadAuthenticatedSession(signal),
    staleTime: 60_000,
    retry: false,
  })

export function hasPermission(
  permissions: PermissionSet,
  resource: string,
  action: string,
): boolean {
  return permissions[resource]?.includes(action) ?? false
}
