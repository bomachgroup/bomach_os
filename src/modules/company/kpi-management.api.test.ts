import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { kpiManagementApi } from './kpi-management.api'

afterEach(() => vi.restoreAllMocks())

describe('kpiManagementApi', () => {
  it('lists role KPI assignments with server search and offset pagination', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await kpiManagementApi.list({ limit: 50, offset: 50, search: '  client follow-ups  ' })

    expect(get).toHaveBeenCalledWith('/roles/kpis?limit=50&offset=50&search=client+follow-ups', {
      signal: undefined,
    })
  })

  it('collects all role records from paginated lookup endpoints', async () => {
    const get = vi
      .spyOn(apiClient, 'get')
      .mockResolvedValueOnce({
        count: 101,
        items: Array.from({ length: 100 }, (_, index) => ({ id: index + 1 })),
      })
      .mockResolvedValueOnce({ count: 101, items: [{ id: 101 }] })

    const roles = await kpiManagementApi.roles()

    expect(roles).toHaveLength(101)
    expect(get).toHaveBeenNthCalledWith(1, '/roles/?limit=100&offset=0', { signal: undefined })
    expect(get).toHaveBeenNthCalledWith(2, '/roles/?limit=100&offset=100', { signal: undefined })
  })

  it('uses the supported create, patch, delete, and shared-metric endpoints', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 6 })
    const patch = vi.spyOn(apiClient, 'patch').mockResolvedValue({ id: 6 })
    const remove = vi.spyOn(apiClient, 'delete').mockResolvedValue({ detail: 'removed' })

    await kpiManagementApi.create(9, {
      metric_id: 3,
      tracking_mode: 'manual',
      target_value: 20,
      weight: null,
      period: 'monthly',
      is_active: true,
    })
    await kpiManagementApi.update(9, 6, {
      metric_id: 3,
      tracking_mode: 'system',
      target_value: 22,
      weight: 10,
      period: 'quarterly',
      sequence: 2,
      is_active: false,
    })
    await kpiManagementApi.remove(9, 6)
    await kpiManagementApi.createMetric({ name: 'Follow-ups', unit: 'count', description: '' })

    expect(post).toHaveBeenNthCalledWith(1, '/roles/9/kpis', {
      metric_id: 3,
      tracking_mode: 'manual',
      target_value: 20,
      weight: null,
      period: 'monthly',
      is_active: true,
    })
    expect(patch).toHaveBeenCalledWith('/roles/9/kpis/6', expect.objectContaining({ sequence: 2 }))
    expect(remove).toHaveBeenCalledWith('/roles/9/kpis/6')
    expect(post).toHaveBeenNthCalledWith(2, '/kpis/metrics/', {
      name: 'Follow-ups',
      unit: 'count',
      description: '',
    })
  })
})
