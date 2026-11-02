import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { parseApiPage, rolesApi, type RoleWriteInput } from './roles.api'
import { ApiError } from '@/shared/api/api-error'

afterEach(() => vi.restoreAllMocks())

describe('rolesApi', () => {
  it('normalizes the supported role-list pagination envelopes', () => {
    expect(parseApiPage({ count: 3, items: [{ id: 1 }] })).toEqual({
      count: 3,
      items: [{ id: 1 }],
    })
    expect(parseApiPage({ count: 2, results: [{ id: 2 }] })).toEqual({
      count: 2,
      items: [{ id: 2 }],
    })
    expect(parseApiPage({ data: { count: 1, items: [{ id: 3 }] } })).toEqual({
      count: 1,
      items: [{ id: 3 }],
    })
    expect(parseApiPage([{ id: 4 }])).toEqual({ count: 1, items: [{ id: 4 }] })
  })

  it('rejects a successful response with no recognizable role list instead of crashing in render', () => {
    expect(() => parseApiPage({ count: 2, roles: [{ id: 1 }] })).toThrow(ApiError)
    expect(() => parseApiPage({ count: 2, roles: [{ id: 1 }] })).toThrow(
      'The server returned role data in an unexpected format.',
    )
  })

  it('validates role records before the directory or detail screen renders them', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 1,
          name: 'Malformed role',
          permissions: {},
          created_at: '2026-01-01T00:00:00Z',
          updated_at: '2026-01-01T00:00:00Z',
        },
      ],
    })

    await expect(rolesApi.list({ limit: 10, offset: 0, search: '' })).rejects.toMatchObject({
      code: 'INVALID_ROLE_RESPONSE',
    })
    expect(get).toHaveBeenCalledOnce()
  })

  it('posts role creation to the slash-terminated backend route', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 1 })
    const input: RoleWriteInput = {
      name: 'QA role',
      branch_ids: [],
      permissions: {},
      description: {
        purpose: 'Verify the role save contract.',
        responsibilities: '',
        job_description: '',
      },
    }

    await rolesApi.create(input)

    expect(post).toHaveBeenCalledWith('/roles/', input)
  })

  it('puts role updates to the selected role route with the full permissions payload', async () => {
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue({ id: 6 })
    const input: RoleWriteInput = {
      name: 'Updated QA role',
      branch_ids: [3],
      permissions: { employees: ['view', 'update'], roles: ['list'] },
      description: {
        purpose: 'Verify role updates.',
        responsibilities: 'Keep permissions accurate.',
        job_description: '',
      },
    }

    await rolesApi.update(6, input)

    expect(put).toHaveBeenCalledWith('/roles/6', input)
  })
})
