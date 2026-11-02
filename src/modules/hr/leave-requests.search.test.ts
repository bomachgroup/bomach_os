import { describe, expect, it } from 'vitest'

import { validateHRLeaveRequestsSearch } from './leave-requests.search'

describe('validateHRLeaveRequestsSearch', () => {
  it('defaults the HR register to pending requests while preserving an explicit all-status link', () => {
    expect(validateHRLeaveRequestsSearch({}).status).toBe('pending')
    expect(validateHRLeaveRequestsSearch({ status: 'all' }).status).toBe('all')
  })

  it('parses a request deep link and manager filters', () => {
    expect(
      validateHRLeaveRequestsSearch({
        request_id: '41',
        kind: 'running_late',
        status: 'pending',
        page: '3',
        pageSize: '20',
      }),
    ).toEqual({
      search: '',
      request_id: 41,
      kind: 'running_late',
      status: 'pending',
      page: 3,
      pageSize: 20,
    })
  })

  it('rejects unsafe request IDs and normalizes malformed filters', () => {
    expect(
      validateHRLeaveRequestsSearch({
        request_id: '-2',
        kind: 'other',
        status: 'other',
        pageSize: '500',
      }),
    ).toEqual({
      search: '',
      request_id: undefined,
      kind: 'all',
      status: 'pending',
      page: 1,
      pageSize: 10,
    })
  })
})
