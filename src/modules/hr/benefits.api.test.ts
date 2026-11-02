import { afterEach, describe, expect, it, vi } from 'vitest'

import { apiClient } from '@/shared/api/api-client'

import { benefitsApi } from './benefits.api'

afterEach(() => vi.restoreAllMocks())

describe('benefitsApi', () => {
  it('maps payroll allowance data and supports employee, status, search, and pagination filters', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 4,
          employee: {
            id: 19,
            employee_id: 'EMP-019',
            full_name: 'Amina Garba',
            designation: 'People Manager',
          },
          period_display: 'October 2026',
          net_pay: '380000.50',
          base_salary: '300000',
          commission_bonus: '95000',
          allowance_breakdown: { housing: '70000', transport: 25000 },
          deduction_breakdown: { tax: '8000', pension: 7000 },
          tax_deductions: '15000',
          status: 'paid',
          disbursement_date: '2026-10-28',
        },
      ],
    })

    const result = await benefitsApi.list({
      search: ' Amina Garba ',
      status: 'paid',
      employeeId: 19,
      limit: 20,
      offset: 20,
    })

    expect(get).toHaveBeenCalledWith(
      '/payroll/?limit=20&offset=20&search=Amina+Garba&status=paid&employee_id=19',
      { signal: undefined },
    )
    expect(result.items[0]).toMatchObject({
      id: 4,
      employeeId: 19,
      employeeCode: 'EMP-019',
      employeeName: 'Amina Garba',
      allowanceTotal: 95000,
      allowanceBreakdown: { housing: '70000', transport: 25000 },
      deductionBreakdown: { tax: '8000', pension: 7000 },
      netPay: 380000.5,
      status: 'paid',
    })
  })

  it('omits optional filters when they are empty or set to all', async () => {
    const get = vi.spyOn(apiClient, 'get').mockResolvedValue({ count: 0, items: [] })

    await benefitsApi.list({ search: '', status: 'all', limit: 10, offset: 0 })

    expect(get).toHaveBeenCalledWith('/payroll/?limit=10&offset=0', { signal: undefined })
  })
})
