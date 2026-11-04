import type { AuthenticatedSession } from './session'
import { canAccessServicesApp } from '@/app/shell/app-catalog'
import {
  canVisitDestination,
  matchDestinationPath,
  PROTECTED_DESTINATIONS,
  type ProtectedDestination,
} from '@/app/navigation/route-manifest'

export type { ProtectedDestination } from '@/app/navigation/route-manifest'
export { PROTECTED_DESTINATIONS }

export const NO_ACCESS_PATH = '/no-access'

const PUBLIC_PATHS = new Set([
  '/splash',
  '/login',
  '/forgot-password',
  '/reset-password',
  '/biometric',
  '/two-factor-verify',
  NO_ACCESS_PATH,
])

export function safeInternalTarget(
  target: unknown,
  origin = typeof window === 'undefined' ? 'http://localhost' : window.location.origin,
): string | null {
  if (typeof target !== 'string' || !target || target.length > 2048) return null
  if (
    target.startsWith('//') ||
    target.startsWith('\\') ||
    target.includes('\\') ||
    [...target].some((character) => character.charCodeAt(0) < 32 || character.charCodeAt(0) === 127)
  ) {
    return null
  }

  try {
    const parsed = new URL(target, origin)
    if (parsed.origin !== origin || !parsed.pathname.startsWith('/')) return null
    if (PUBLIC_PATHS.has(parsed.pathname)) return null
    return `${parsed.pathname}${parsed.search}${parsed.hash}`
  } catch {
    return null
  }
}

export function canVisitProtectedDestination(
  destination: ProtectedDestination,
  session: AuthenticatedSession,
): boolean {
  return canVisitDestination(destination, session.permissions)
}

export function resolvePostLoginTarget(
  returnTo: unknown,
  session: AuthenticatedSession,
  destinations: readonly ProtectedDestination[] = PROTECTED_DESTINATIONS,
  origin?: string,
): string {
  const effectiveOrigin =
    origin ?? (typeof window === 'undefined' ? 'http://localhost' : window.location.origin)
  const safeTarget = safeInternalTarget(returnTo, effectiveOrigin)
  if (safeTarget) {
    const requestedPath = new URL(safeTarget, effectiveOrigin).pathname
    if (
      (requestedPath === '/services' || requestedPath.startsWith('/services/')) &&
      canAccessServicesApp(session.permissions)
    ) {
      return safeTarget
    }

    const requestedDestination = destinations.find((item) =>
      matchDestinationPath(item.path, requestedPath),
    )
    if (requestedDestination && canVisitDestination(requestedDestination, session.permissions)) {
      return safeTarget
    }
  }

  return (
    destinations.find((destination) => canVisitDestination(destination, session.permissions))
      ?.path ?? NO_ACCESS_PATH
  )
}
