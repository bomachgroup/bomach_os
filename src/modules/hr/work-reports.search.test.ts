import { describe, expect, it } from 'vitest'

import { validateHRWorkReportsSearch } from './work-reports.search'

describe('validateHRWorkReportsSearch', () => {
  it('defaults the HR register to submitted reports while preserving an explicit all-status link', () => {
    expect(validateHRWorkReportsSearch({}).status).toBe('submitted')
    expect(validateHRWorkReportsSearch({ status: 'all' }).status).toBe('all')
  })

  it('keeps a valid employee-profile report deep link and normalizes invalid filters', () => {
    expect(
      validateHRWorkReportsSearch({ reportId: '42', status: 'submitted', search: '  Lagos  ' }),
    ).toMatchObject({ reportId: 42, status: 'submitted', search: '  Lagos  ', page: 1 })
    expect(
      validateHRWorkReportsSearch({ reportId: 'not-a-number', status: 'unknown', page: 0 }),
    ).toEqual({
      search: '',
      status: 'submitted',
      page: 1,
      reportId: undefined,
    })
    expect(validateHRWorkReportsSearch({ reportId: '-2' }).reportId).toBeUndefined()
  })
})
