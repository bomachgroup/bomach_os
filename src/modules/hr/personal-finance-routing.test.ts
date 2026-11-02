import { describe, expect, it } from 'vitest'

import { validateMyLoansSearch } from './my-loans.search'
import { validateMyPaySearch } from './my-pay.search'
import {
  loansRouteAudience,
  myLoansSearchFromLegacy,
  myPaySearchFromLegacy,
  payrollRouteAudience,
} from './personal-finance-routing'

describe('legacy finance route redirects', () => {
  it('chooses personal, HR, and denied audiences from the correct permission precedence', () => {
    expect(loansRouteAudience({ loans: ['list_own'] })).toBe('personal')
    expect(loansRouteAudience({ loans: ['list', 'list_own'] })).toBe('hr')
    expect(loansRouteAudience({})).toBe('denied')
    expect(payrollRouteAudience({ payroll: ['list_own'] })).toBe('personal')
    expect(payrollRouteAudience({ payroll: ['list', 'list_own'] })).toBe('hr')
    expect(payrollRouteAudience({})).toBe('denied')
  })

  it('keeps personal loan status, pagination, and detail while dropping HR employee search', () => {
    expect(
      myLoansSearchFromLegacy(
        '?search=another%20employee&view=pending&status=all&request_id=41&page=3&pageSize=20',
      ),
    ).toEqual({ status: 'pending', request_id: 41, page: 3, pageSize: 20 })
  })

  it('preserves a compatible loan status when redirecting from decision history', () => {
    expect(
      myLoansSearchFromLegacy('?view=history&status=rejected&request_id=9&page=2&pageSize=50'),
    ).toEqual({ status: 'rejected', request_id: 9, page: 2, pageSize: 50 })
  })

  it('keeps payroll status and pagination but drops cross-employee search', () => {
    expect(myPaySearchFromLegacy('?search=employee-name&status=paid&page=4&pageSize=20')).toEqual({
      status: 'paid',
      page: 4,
      pageSize: 20,
    })
  })

  it('validates the personal routes without accepting HR-only filters', () => {
    expect(validateMyLoansSearch({ search: 'ignored', view: 'pending', page: '0' })).toEqual({
      status: 'all',
      page: 1,
      pageSize: 10,
    })
    expect(validateMyPaySearch({ search: 'ignored', employee_id: 17, status: 'paid' })).toEqual({
      status: 'paid',
      page: 1,
      pageSize: 10,
    })
  })
})
