import { beforeEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'
import { broadcastApi, broadcastQueryKeys } from './broadcast.api'

describe('broadcastApi', () => {
  beforeEach(() => vi.restoreAllMocks())

  it('requests the paginated announcements endpoint with supported filters', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })
    const controller = new AbortController()

    await broadcastApi.announcements(
      { limit: 10, offset: 20, search: '  policy update  ', isActive: false },
      controller.signal,
    )

    expect(get).toHaveBeenCalledWith(
      '/announcements/?limit=10&offset=20&search=policy+update&is_active=false',
      { signal: controller.signal },
    )
  })

  it('uses event routes and sends event payloads without unsupported fields', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 5 })
    const payload = {
      title: 'Planning session',
      event_type: 'STRATEGIC_PLANNING',
      event_time_from: '2026-11-01T10:00:00Z',
      event_time_to: '2026-11-01T11:00:00Z',
      meeting_location: 'Main office',
      target_all_branches: true,
      target_all_departments: false,
      target_associates: true,
      target_investors: false,
      target_partners: false,
      reminder_offset: 60,
      recurrence: null,
    }

    await broadcastApi.createEvent(payload)

    expect(post).toHaveBeenCalledWith('/events/', payload)
    expect(payload).not.toHaveProperty('destination')
    expect(payload).not.toHaveProperty('event_date')
  })

  it('scopes query keys by user and employee and keeps list parameters distinct', () => {
    expect(
      broadcastQueryKeys.announcementList(3, 'EMP-3', { limit: 10, offset: 0, search: '' }),
    ).not.toEqual(
      broadcastQueryKeys.announcementList(4, 'EMP-4', { limit: 10, offset: 0, search: '' }),
    )
  })
})
