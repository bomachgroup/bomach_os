import type { EmployeeDto } from '@/modules/hr/employees.api'

export type EmployeeDraft = Record<string, string>

export const STANDARD_ALLOWANCE_FIELDS = [
  { key: 'housing', label: 'Housing', draftKey: 'allowance_housing' },
  { key: 'transport', label: 'Transport', draftKey: 'allowance_transport' },
  { key: 'meal', label: 'Meal', draftKey: 'allowance_meal' },
] as const

export function validateAllowanceDraft(draft: EmployeeDraft): Record<string, string> {
  return Object.fromEntries(
    STANDARD_ALLOWANCE_FIELDS.flatMap(({ label, draftKey }) => {
      const value = draft[draftKey]?.trim() ?? ''
      if (!value) return []
      const amount = Number(value)
      return Number.isFinite(amount) && amount >= 0
        ? []
        : [[draftKey, `${label} allowance must be a number greater than or equal to 0.`]]
    }),
  )
}

export function buildAllowances(
  draft: EmployeeDraft,
  existing: Record<string, unknown> | null | undefined,
): Record<string, unknown> {
  const standardKeys = new Set<string>(STANDARD_ALLOWANCE_FIELDS.map(({ key }) => key))
  const allowances = Object.fromEntries(
    Object.entries(existing ?? {}).filter(([key]) => !standardKeys.has(key)),
  )

  for (const { key, draftKey } of STANDARD_ALLOWANCE_FIELDS) {
    const rawValue = draft[draftKey]?.trim() ?? ''
    if (!rawValue) continue
    const amount = Number(rawValue)
    if (Number.isFinite(amount) && amount >= 0) allowances[key] = amount
  }

  return allowances
}

export function asDraft(employee: EmployeeDto | null): EmployeeDraft {
  const draft = Object.fromEntries(
    Object.entries(employee ?? {})
      .filter(([key]) => key !== 'allowances')
      .map(([key, value]) => [key, value == null ? '' : String(value)]),
  )

  for (const { key, draftKey } of STANDARD_ALLOWANCE_FIELDS) {
    const value = employee?.allowances?.[key]
    draft[draftKey] = value === null || value === undefined ? '' : String(value)
  }

  return draft
}
