import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { branchesApi } from './branches.api'

afterEach(() => vi.restoreAllMocks())

describe('branchesApi', () => {
  it('serializes list filters and URL pagination for the directory', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await branchesApi.list({
      limit: 10,
      offset: 20,
      search: 'North Office',
      operationalStatus: 'under_maintenance',
      branchRole: 'state_headquarters',
      recordState: 'inactive',
    })

    expect(get).toHaveBeenCalledWith(
      '/branch/branches?limit=10&offset=20&search=North+Office&operational_status=under_maintenance&branch_role=state_headquarters&is_active=false',
      { signal: undefined },
    )
  })

  it('keeps an unfiltered list request clean', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await branchesApi.list({
      limit: 10,
      offset: 0,
      search: '  ',
      operationalStatus: 'all',
      branchRole: 'all',
      recordState: 'all',
    })

    expect(get).toHaveBeenCalledWith('/branch/branches?limit=10&offset=0', {
      signal: undefined,
    })
  })

  it('requests manager choices within the selected branch and includes its current manager', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await branchesApi.managerChoices({
      limit: 20,
      offset: 0,
      search: 'Amina',
      branchId: 4,
      currentManagerId: 17,
    })

    expect(get).toHaveBeenCalledWith(
      '/branch/branches/choices/managers?limit=20&offset=0&search=Amina&branch_id=4&current_manager_id=17',
      { signal: undefined },
    )
  })

  it('sends weekly-hours replacement to the dedicated endpoint', async () => {
    const put = vi.spyOn(apiClient, 'put').mockResolvedValue([])
    const schedule = [{ day_of_week: 6, open_time: null, close_time: null, is_open: false }]

    await branchesApi.updateBusinessHours(4, schedule)

    expect(put).toHaveBeenCalledWith('/branch/branches/4/business-hours', schedule)
  })
})
