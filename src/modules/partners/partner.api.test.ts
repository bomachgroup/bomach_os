import { beforeEach, describe, expect, it, vi } from 'vitest'

vi.mock('@/shared/api/api-client', () => ({
  apiClient: {
    get: vi.fn(),
    post: vi.fn(),
    patch: vi.fn(),
  },
}))

import { apiClient } from '@/shared/api/api-client'
import { partnerAdminApi, partnerPortalApi } from './partner.api'

describe('partner APIs', () => {
  beforeEach(() => vi.clearAllMocks())

  it('uses the permission-scoped invitation route without sending secret setup data', async () => {
    vi.mocked(apiClient.post).mockResolvedValue({ partner: { id: 21 }, invitation: { id: 34 } })

    await partnerAdminApi.invite({
      email: 'partner@example.com',
      partner_role: 'surveyor',
      branch_id: 8,
    })

    expect(apiClient.post).toHaveBeenCalledWith('/partners/invitations', {
      email: 'partner@example.com',
      partner_role: 'surveyor',
      branch_id: 8,
    })
    expect(JSON.stringify(vi.mocked(apiClient.post).mock.calls[0])).not.toMatch(
      /setup_token|password/,
    )
  })

  it('keeps setup, profile completion, and unread counts on partner-only endpoints', async () => {
    vi.mocked(apiClient.post).mockResolvedValue({ success: true })
    vi.mocked(apiClient.patch).mockResolvedValue({ profile_completed: true })
    vi.mocked(apiClient.get).mockResolvedValue({ unread_count: 2 })

    await partnerPortalApi.completeSetup({ setup_token: 'one-time', new_password: 'secret-pass' })
    await partnerPortalApi.updateProfile({ name: 'Ada Partner', phone: '+2348012345678' })
    await partnerPortalApi.unreadNotificationCount()
    await partnerPortalApi.unreadMessageCount()

    expect(apiClient.post).toHaveBeenCalledWith(
      '/auth/partner-setup/complete',
      { setup_token: 'one-time', new_password: 'secret-pass' },
      { skipRefresh: true },
    )
    expect(apiClient.patch).toHaveBeenCalledWith('/partner/profile', {
      name: 'Ada Partner',
      phone: '+2348012345678',
    })
    expect(apiClient.get).toHaveBeenNthCalledWith(1, '/partner/notifications/unread-count', {
      signal: undefined,
    })
    expect(apiClient.get).toHaveBeenNthCalledWith(2, '/partner/messages/unread-count', {
      signal: undefined,
    })
  })
})
