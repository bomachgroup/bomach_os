import { beforeEach, describe, expect, it, vi } from 'vitest'

import { ApiError } from '@/shared/api/api-error'
import { SESSION_ESTABLISHED_KEY } from '@/shared/api/api-client'
import { authApi } from './auth.api'
import { loadAuthenticatedSession, SessionBootstrapError } from './session'

describe('authenticated session bootstrap', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.spyOn(authApi, 'currentUser').mockResolvedValue({
      id: 7,
      email: 'person@example.com',
      username: 'person',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
    })
    vi.spyOn(authApi, 'employeeProfile').mockResolvedValue({
      user_id: 7,
      employee_id: 'EMP-7',
      username: 'person',
      email: 'person@example.com',
      first_name: 'A',
      last_name: 'Person',
    })
    vi.spyOn(authApi, 'employeeRole').mockResolvedValue({
      id: 2,
      name: 'Staff',
      permissions: { employees: ['list'] },
    })
    vi.spyOn(authApi, 'permissionsCatalog').mockResolvedValue({
      permissions_map: { employees: ['list', 'view'] },
    })
  })

  it('loads profile, role and permission catalog before access is granted', async () => {
    const session = await loadAuthenticatedSession()
    expect(session.employee.employee_id).toBe('EMP-7')
    expect(session.permissions).toEqual({ employees: ['list'] })
    expect(session.permissionsCatalog).toEqual({ employees: ['list', 'view'] })
    expect(window.sessionStorage.getItem(SESSION_ESTABLISHED_KEY)).toBe('1')
  })

  it('treats no assigned role as an empty permission set', async () => {
    vi.spyOn(authApi, 'employeeRole').mockRejectedValue(
      new ApiError('No assigned role', { status: 404 }),
    )

    const session = await loadAuthenticatedSession()
    expect(session.roles).toEqual([])
    expect(session.permissions).toEqual({})
  })

  it('blocks access and identifies a permissions load failure', async () => {
    vi.spyOn(authApi, 'permissionsCatalog').mockRejectedValue(
      new ApiError('Unavailable', { status: 503 }),
    )

    await expect(loadAuthenticatedSession()).rejects.toMatchObject<Partial<SessionBootstrapError>>({
      stage: 'permissions',
    })
  })

  it('blocks access when the employee profile cannot be loaded', async () => {
    vi.spyOn(authApi, 'employeeProfile').mockRejectedValue(
      new ApiError('Unavailable', { status: 503 }),
    )

    await expect(loadAuthenticatedSession()).rejects.toMatchObject<Partial<SessionBootstrapError>>({
      stage: 'profile',
    })
  })
})
