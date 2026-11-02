import { describe, expect, it } from 'vitest'

import { auditLogSearchParams } from './audit-log.api'

describe('Audit Log API query parameters', () => {
  it('maps all server-side filters and offset pagination to the backend contract', () => {
    const params = auditLogSearchParams({
      search: '  login  ',
      userId: '42',
      auditType: 'login_failed',
      auditStatus: 'warning',
      startDate: '2026-10-01',
      endDate: '2026-10-23',
      limit: 10,
      offset: 20,
    })

    expect(params.toString()).toBe(
      'limit=10&offset=20&search=login&user_id=42&audit_type=login_failed&audit_status=warning&start_date=2026-10-01&end_date=2026-10-23',
    )
  })

  it('omits empty filters while keeping a valid first-page request', () => {
    const params = auditLogSearchParams({
      search: '',
      userId: '',
      auditType: '',
      auditStatus: '',
      startDate: '',
      endDate: '',
      limit: 10,
      offset: 0,
    })

    expect(params.toString()).toBe('limit=10&offset=0')
  })
})
