import { describe, expect, it } from 'vitest'

import { validateMyTargetsSearch } from './targets.search'

describe('My Targets URL search', () => {
  it('keeps valid independent filters and pagination in the route state', () => {
    expect(
      validateMyTargetsSearch({
        scope: 'all',
        period: 'quarterly',
        status: 'rejected',
        targetsPage: '3',
        reportsPage: '8',
      }),
    ).toEqual({
      scope: 'all',
      period: 'quarterly',
      status: 'rejected',
      targetsPage: 3,
      reportsPage: 8,
    })
  })

  it('falls back safely for invalid filters and pages', () => {
    expect(
      validateMyTargetsSearch({
        scope: 'archived',
        period: 'decade',
        status: 'waiting',
        targetsPage: '-4',
        reportsPage: 'many',
      }),
    ).toEqual({
      scope: 'active',
      period: 'all',
      status: 'all',
      targetsPage: 1,
      reportsPage: 1,
    })
  })
})
