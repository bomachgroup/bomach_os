import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'
import { trainingProgramsApi } from './training-programs.api'

afterEach(() => vi.restoreAllMocks())

describe('trainingProgramsApi', () => {
  it('sends supported search and filter values with offset pagination', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })
    await trainingProgramsApi.list({
      limit: 20,
      offset: 40,
      search: ' Safety ',
      provider: ' Acme ',
      status: 'in_progress',
      audience: 'new_hires',
    })
    expect(get).toHaveBeenCalledWith(
      '/training-programs/?limit=20&offset=40&search=Safety&provider=Acme&status=in_progress&target_audience=new_hires',
      { signal: undefined },
    )
  })

  it('omits empty and all-value filters', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })
    await trainingProgramsApi.list({
      limit: 10,
      offset: 0,
      search: '',
      provider: '',
      status: 'all',
      audience: 'all',
    })
    expect(get).toHaveBeenCalledWith('/training-programs/?limit=10&offset=0', { signal: undefined })
  })

  it('sends one unified search term without a separate provider parameter', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })
    await trainingProgramsApi.list({
      limit: 10,
      offset: 0,
      search: 'Northstar Learning',
      status: 'all',
      audience: 'all',
    })
    expect(get).toHaveBeenCalledWith(
      '/training-programs/?limit=10&offset=0&search=Northstar+Learning',
      { signal: undefined },
    )
  })

  it('uses real create, detail, update and delete routes', async () => {
    const post = vi.spyOn(apiClient, 'post').mockResolvedValue({ id: 6 })
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ id: 6 })
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue({ id: 6 })
    const del = vi.spyOn(apiClient, 'delete').mockResolvedValue(undefined)
    const input = {
      program_name: 'Safety',
      provider: 'Acme',
      description: 'Safety basics',
      start_date: '2026-11-01',
      end_date: '2026-11-02',
      cost: 1200,
      target_audience: 'all_employees' as const,
      status: 'pending' as const,
    }

    await trainingProgramsApi.create(input)
    await trainingProgramsApi.get(6)
    await trainingProgramsApi.update(6, input)
    await trainingProgramsApi.delete(6)

    expect(post).toHaveBeenCalledWith('/training-programs/', input)
    expect(get).toHaveBeenCalledWith('/training-programs/6', { signal: undefined })
    expect(put).toHaveBeenCalledWith('/training-programs/6', input)
    expect(del).toHaveBeenCalledWith('/training-programs/6')
  })
})
