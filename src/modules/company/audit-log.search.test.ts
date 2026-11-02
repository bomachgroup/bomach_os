import { describe, expect, it } from 'vitest'

import { auditLogDateRangeError, validateAuditLogSearch } from './audit-log.search'

describe('Audit Log URL search', () => {
  it('uses safe defaults for absent or malformed values', () => {
    expect(validateAuditLogSearch({ page: '0', userId: '-4', auditType: 'create' })).toEqual({
      search: '',
      userId: '',
      auditType: '',
      auditStatus: '',
      startDate: '',
      endDate: '',
      page: 1,
    })
  })

  it('retains supported filters and valid dates', () => {
    expect(
      validateAuditLogSearch({
        search: '  sign in  ',
        userId: '42',
        auditType: 'login_failed',
        auditStatus: 'warning',
        startDate: '2026-10-01',
        endDate: '2026-10-23',
        page: '3',
      }),
    ).toEqual({
      search: 'sign in',
      userId: '42',
      auditType: 'login_failed',
      auditStatus: 'warning',
      startDate: '2026-10-01',
      endDate: '2026-10-23',
      page: 3,
    })
  })

  it('clears impossible calendar dates and catches a reversed range', () => {
    expect(validateAuditLogSearch({ startDate: '2026-02-30' }).startDate).toBe('')
    expect(auditLogDateRangeError('2026-10-24', '2026-10-23')).toContain('later')
    expect(auditLogDateRangeError('2026-10-23', '2026-10-23')).toBeNull()
  })
})
