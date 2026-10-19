import { redirect } from '@tanstack/react-router'
import type { QueryClient } from '@tanstack/react-query'

import { ApiError } from '@/shared/api/api-error'
import { SESSION_EXPIRED_NOTICE_KEY } from '@/shared/api/api-client'
import { authSessionQueryOptions, hasPermission } from './session'
import { safeInternalTarget } from './navigation'
import { canVisitDestination, type ProtectedDestination } from '@/app/navigation/route-manifest'

export interface AuthRouteContext {
  queryClient: QueryClient
}

export interface AuthRouteLocation {
  pathname: string
  searchStr: string
  hash: string
}

function locationTarget(location: AuthRouteLocation): string {
  return `${location.pathname}${location.searchStr}${location.hash}`
}

export async function requireAuthenticatedSession(
  context: AuthRouteContext,
  location: AuthRouteLocation,
) {
  try {
    return await context.queryClient.ensureQueryData(authSessionQueryOptions())
  } catch (error) {
    if (error instanceof ApiError && error.status === 401) {
      const returnTo = safeInternalTarget(locationTarget(location))
      const expired =
        typeof window !== 'undefined' &&
        window.sessionStorage.getItem(SESSION_EXPIRED_NOTICE_KEY) === '1'
      throw redirect({
        to: '/login',
        search: { ...(returnTo ? { returnTo } : {}), ...(expired ? { expired: true } : {}) },
      })
    }
    throw error
  }
}

export async function requirePermission(
  context: AuthRouteContext,
  location: AuthRouteLocation,
  resource: string,
  action: string,
): Promise<void> {
  const session = await requireAuthenticatedSession(context, location)
  if (!hasPermission(session.permissions, resource, action)) {
    throw redirect({ to: '/no-access' })
  }
}

export async function requireProtectedDestination(
  context: AuthRouteContext,
  location: AuthRouteLocation,
  destination: ProtectedDestination,
): Promise<void> {
  const session = await requireAuthenticatedSession(context, location)
  if (!canVisitDestination(destination, session.permissions)) {
    throw redirect({ to: '/no-access' })
  }
}
