import { describe, expect, it } from 'vitest'

import { validateWorkReportsSearch } from './work-reports.search'

describe('validateWorkReportsSearch', () => {
  it('keeps status and pagination for copied links and ignores retired filters', () => {
    expect(
      validateWorkReportsSearch({
        status: 'rejected',
        q: 'pump repair',
        from: '2026-10-01',
        to: '2026-10-15',
        page: '3',
      }),
    ).toEqual({
      status: 'rejected',
      page: 3,
    })
  })

  it('normalizes invalid or unsafe values to defaults', () => {
    expect(
      validateWorkReportsSearch({
        status: 'unknown',
        q: 'x'.repeat(200),
        from: 'yesterday',
        to: null,
        page: '-1',
      }),
    ).toEqual({
      status: 'all',
      page: 1,
    })
  })
})
