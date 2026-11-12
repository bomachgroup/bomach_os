import { describe, expect, it } from 'vitest'

import { validateProjectDetailSearch, validateProjectsSearch } from './projects.search'

describe('project route search validation', () => {
  it('normalizes filters and clamps invalid pagination', () => {
    expect(
      validateProjectsSearch({
        search: '  site  ',
        status: 'in_progress',
        priority: 'critical',
        page: '4',
        archived: 'true',
      }),
    ).toEqual({
      search: 'site',
      status: 'in_progress',
      priority: 'critical',
      page: 4,
      archived: true,
    })
    expect(validateProjectsSearch({ page: '-1', status: 'invalid' })).toMatchObject({
      page: 1,
      status: '',
    })
  })

  it('falls back to overview for unknown tabs', () => {
    expect(validateProjectDetailSearch({ tab: 'budget' })).toEqual({ tab: 'overview' })
    expect(validateProjectDetailSearch({ tab: 'meetings' })).toEqual({ tab: 'meetings' })
  })
})
