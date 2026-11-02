import { describe, expect, it } from 'vitest'

import { validateLoansSearch } from './loans.search'

describe('validateLoansSearch', () => {
  it('keeps valid view, status, request, and pagination state', () => {
    expect(
      validateLoansSearch({
        view: 'history',
        status: 'approved',
        request_id: '12',
        page: '3',
        pageSize: '20',
      }),
    ).toEqual({
      view: 'history',
      search: '',
      status: 'approved',
      request_id: 12,
      page: 3,
      pageSize: 20,
    })
  })

  it('normalizes invalid URL values to safe defaults', () => {
    expect(
      validateLoansSearch({ view: 'unknown', status: 'history', page: '-1', pageSize: '15' }),
    ).toEqual({ view: 'all', search: '', status: 'all', page: 1, pageSize: 10 })
  })
})
