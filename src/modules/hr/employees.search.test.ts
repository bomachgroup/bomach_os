import { describe, expect, it } from 'vitest'

import { validateEmployeesSearch } from './employees.search'

describe('validateEmployeesSearch', () => {
  it('parses the page-size allowlist and preserves shareable directory filters', () => {
    expect(
      validateEmployeesSearch({
        search: '  finance  ',
        page: '2',
        pageSize: '20',
        view: 'past',
        branchId: '4',
        departmentId: '8',
      }),
    ).toEqual({
      search: '  finance  ',
      page: 2,
      pageSize: 20,
      view: 'past',
      branchId: '4',
      departmentId: '8',
    })
  })

  it('falls back safely for malformed pagination and non-numeric scope IDs', () => {
    expect(
      validateEmployeesSearch({
        page: '0',
        pageSize: '7',
        branchId: 'all departments',
        departmentId: '-3',
      }),
    ).toEqual({
      search: '',
      page: 1,
      pageSize: 10,
      view: 'active',
      branchId: 'all',
      departmentId: 'all',
    })
  })

  it('bounds the free-text search value', () => {
    expect(validateEmployeesSearch({ search: 'x'.repeat(201) }).search).toBe('')
  })
})
