import { validateBenefitsSearch } from './benefits.search'
import { validateLoansSearch } from './loans.search'
import type { MyLoansSearch } from './my-loans.search'
import type { MyPaySearch } from './my-pay.search'
import type { PermissionSet } from '@/shared/auth/session'

export type FinanceRouteAudience = 'hr' | 'personal' | 'denied'

export function loansRouteAudience(permissions: PermissionSet): FinanceRouteAudience {
  if (permissions.loans?.includes('list')) return 'hr'
  if (permissions.loans?.includes('list_own')) return 'personal'
  return 'denied'
}

export function payrollRouteAudience(permissions: PermissionSet): FinanceRouteAudience {
  if (permissions.payroll?.includes('list')) return 'hr'
  if (permissions.payroll?.includes('list_own')) return 'personal'
  return 'denied'
}

function searchValues(searchStr: string): Record<string, string> {
  return Object.fromEntries(new URLSearchParams(searchStr))
}

export function myLoansSearchFromLegacy(searchStr: string): MyLoansSearch {
  const legacy = validateLoansSearch(searchValues(searchStr))
  return {
    status: legacy.view === 'pending' ? 'pending' : legacy.status,
    ...(legacy.request_id ? { request_id: legacy.request_id } : {}),
    page: legacy.page,
    pageSize: legacy.pageSize,
  }
}

export function myPaySearchFromLegacy(searchStr: string): MyPaySearch {
  const legacy = validateBenefitsSearch(searchValues(searchStr))
  return {
    status: legacy.status,
    page: legacy.page,
    pageSize: legacy.pageSize,
  }
}
