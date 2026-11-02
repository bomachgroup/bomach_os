import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { approvalRequestsApi } from './company-dashboard.api'

afterEach(() => vi.restoreAllMocks())

describe('approvalRequestsApi', () => {
  it('defaults the request endpoint to an unfiltered All requests page', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await approvalRequestsApi.list({ status: 'all', search: '', limit: 10, offset: 0 })

    expect(get).toHaveBeenCalledWith('/approvals/requests?limit=10&offset=0', {
      signal: undefined,
    })
  })

  it('sends a rejection explanation in the backend comment field', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({})

    await approvalRequestsApi.reject(42, 'Supporting document is missing.')

    expect(post).toHaveBeenCalledWith('/approvals/requests/42/reject', {
      comment: 'Supporting document is missing.',
    })
  })
})
