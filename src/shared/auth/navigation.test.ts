import { describe, expect, it } from 'vitest'

import {
  canVisitDestination,
  PROTECTED_DESTINATIONS,
  type ProtectedDestination,
} from '@/app/navigation/route-manifest'
import { resolvePostLoginTarget, safeInternalTarget } from './navigation'
import type { AuthenticatedSession } from './session'

const origin = 'https://os.example.com'
const destinations: ProtectedDestination[] = [
  {
    path: '/dashboard',
    title: 'Overview',
    section: 'Workspace',
    group: 'Dashboard',
    requiredPermissions: [],
    visibleResources: ['employees'],
    inSidebar: true,
    icon: 'home',
    order: 0,
  },
  {
    path: '/company/roles/$roleId',
    title: 'Role details',
    section: 'Workspace',
    group: 'Company',
    requiredPermissions: [{ resource: 'roles', action: 'list' }],
    visibleResources: [],
    inSidebar: false,
    icon: 'shield',
    order: 1,
  },
  {
    path: '/hr/employees',
    title: 'Employees',
    section: 'People',
    group: 'HR/Admin',
    requiredPermissions: [{ resource: 'employees', action: 'list' }],
    visibleResources: ['employees'],
    inSidebar: true,
    icon: 'people',
    order: 2,
  },
]

function session(permissions: Record<string, string[]>): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'person@example.com',
      username: 'person',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-7',
      username: 'person',
      email: 'person@example.com',
      first_name: 'A',
      last_name: 'Person',
    },
    roles: [],
    permissions,
    permissionsCatalog: {},
  }
}

describe('auth navigation', () => {
  it('registers 40 sidebar destinations and exposes the Company and HR dashboards first', () => {
    const sidebar = PROTECTED_DESTINATIONS.filter((destination) => destination.inSidebar)
    expect(sidebar).toHaveLength(40)
    expect(sidebar.filter((destination) => destination.group === 'Dashboard')).toHaveLength(8)
    expect(sidebar.filter((destination) => destination.group === 'Company')).toHaveLength(15)
    expect(sidebar.filter((destination) => destination.group === 'HR/Admin')).toHaveLength(17)
    expect(sidebar.find((destination) => destination.path === '/company/overview')?.order).toBe(9)
    expect(sidebar.find((destination) => destination.path === '/hr')?.order).toBe(29)
    expect(
      PROTECTED_DESTINATIONS.some((destination) => destination.path === '/employee/directory'),
    ).toBe(true)
    expect(
      PROTECTED_DESTINATIONS.some((destination) => destination.path === '/company/roles/$roleId'),
    ).toBe(true)
  })

  it('keeps a safe same-origin deep link with its search and hash', () => {
    expect(safeInternalTarget('/hr/employees?status=active#list', origin)).toBe(
      '/hr/employees?status=active#list',
    )
  })

  it.each([
    'https://attacker.example/path',
    '//attacker.example/path',
    '\\\\attacker.example\\path',
    '/login',
    '/splash',
    'javascript:alert(1)',
  ])('rejects unsafe or non-protected return targets: %s', (target) => {
    expect(safeInternalTarget(target, origin)).toBeNull()
  })

  it('returns to a permitted parameterized route and preserves its query', () => {
    const loggedIn = session({ roles: ['list'] })
    expect(
      resolvePostLoginTarget('/company/roles/42?tab=permissions', loggedIn, destinations, origin),
    ).toBe('/company/roles/42?tab=permissions')
  })

  it('uses the first permitted destination when the requested one is forbidden', () => {
    const loggedIn = session({ employees: ['list'] })
    expect(resolvePostLoginTarget('/company/roles/42', loggedIn, destinations, origin)).toBe(
      '/dashboard',
    )
  })

  it('falls back to the first permitted in-scope destination and shows no access when none qualify', () => {
    expect(resolvePostLoginTarget('/hr/employees', session({}), destinations, origin)).toBe(
      '/dashboard',
    )
    expect(
      resolvePostLoginTarget(
        '/hr/employees',
        session({ employees: ['list'] }),
        destinations,
        origin,
      ),
    ).toBe('/hr/employees')
    expect(canVisitDestination(destinations[0]!, session({}).permissions)).toBe(true)
    expect(canVisitDestination(destinations[2]!, session({}).permissions)).toBe(false)
    expect(
      resolvePostLoginTarget('/company/roles/42', session({}), destinations.slice(1), origin),
    ).toBe('/no-access')
  })
})
