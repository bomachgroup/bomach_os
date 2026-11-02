import { describe, expect, it } from 'vitest'

import { validateTrainingProgramsSearch } from './training-programs.search'

describe('validateTrainingProgramsSearch', () => {
  it('uses one URL search value for program names and providers', () => {
    const search = validateTrainingProgramsSearch({
      search: 'Northstar',
      provider: 'legacy provider filter',
      status: 'all',
      audience: 'all',
      page: '2',
      pageSize: '20',
    })

    expect(search).toEqual({
      search: 'Northstar',
      status: 'all',
      audience: 'all',
      page: 2,
      pageSize: 20,
    })
    expect(search).not.toHaveProperty('provider')
  })

  it('falls back to safe defaults for malformed filters and pagination', () => {
    expect(
      validateTrainingProgramsSearch({ search: 'x'.repeat(201), status: 'active', page: 0 }),
    ).toMatchObject({
      search: '',
      status: 'all',
      audience: 'all',
      page: 1,
      pageSize: 10,
    })
  })
})
