import { apiClient } from '@/shared/api/api-client'

export type PayrollStatus = 'pending' | 'approved' | 'cancelled' | 'paid' | (string & {})

export interface PayrollAllowanceRecord {
  id: number
  employeeId: number
  employeeCode: string
  employeeName: string
  designation: string
  period: string
  baseSalary: number | null
  allowanceTotal: number
  allowanceBreakdown: Record<string, number | string>
  deductionBreakdown: Record<string, number | string>
  deductions: number
  netPay: number
  status: PayrollStatus
  disbursementDate: string | null
}

interface PayrollAllowanceDto {
  id: number
  employee: {
    id: number
    employee_id: string
    full_name: string
    designation: string
  }
  period_display: string
  net_pay: number | string
  base_salary: number | string | null
  commission_bonus: number | string
  allowance_breakdown?: Record<string, number | string> | null
  deduction_breakdown?: Record<string, number | string> | null
  tax_deductions: number | string
  status: PayrollStatus
  disbursement_date: string | null
}

interface ApiPage<T> {
  count: number
  items: T[]
}

export interface BenefitsListParams {
  search: string
  status: 'all' | PayrollStatus
  employeeId?: number
  limit: number
  offset: number
}

export interface BenefitsPage {
  count: number
  items: PayrollAllowanceRecord[]
}

function numberValue(value: number | string | null | undefined): number | null {
  if (value == null || value === '') return null
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : null
}

function mapPayroll(dto: PayrollAllowanceDto): PayrollAllowanceRecord {
  return {
    id: dto.id,
    employeeId: dto.employee.id,
    employeeCode: dto.employee.employee_id,
    employeeName: dto.employee.full_name?.trim() || `Employee #${dto.employee.id}`,
    designation: dto.employee.designation?.trim() || 'Role not provided',
    period: dto.period_display,
    baseSalary: numberValue(dto.base_salary),
    allowanceTotal: numberValue(dto.commission_bonus) ?? 0,
    allowanceBreakdown: dto.allowance_breakdown ?? {},
    deductionBreakdown: dto.deduction_breakdown ?? {},
    deductions: numberValue(dto.tax_deductions) ?? 0,
    netPay: numberValue(dto.net_pay) ?? 0,
    status: dto.status,
    disbursementDate: dto.disbursement_date,
  }
}

export const benefitsApi = {
  list: async (params: BenefitsListParams, signal?: AbortSignal): Promise<BenefitsPage> => {
    const query = new URLSearchParams({
      limit: String(params.limit),
      offset: String(params.offset),
    })
    if (params.search.trim()) query.set('search', params.search.trim())
    if (params.status !== 'all') query.set('status', params.status)
    if (params.employeeId) query.set('employee_id', String(params.employeeId))
    const response = await apiClient.get<ApiPage<PayrollAllowanceDto>>(`/payroll/?${query}`, {
      signal,
    })
    return { count: response.count, items: response.items.map(mapPayroll) }
  },
}
