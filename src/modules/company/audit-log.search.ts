import { z } from 'zod'

const auditTypes = [
  'login',
  'login_failed',
  'logout',
  'forgot_password',
  'reset_password',
  'two_factor_sent',
  'two_factor_verified',
  'two_factor_failed',
  'webauthn_registered',
  'webauthn_approved',
  'webauthn_rejected',
  'webauthn_verified',
  'webauthn_failed',
  'add_employee',
  'update_employee',
  'update_profile',
  'add_client',
  'add_lead',
  'finance_action',
  'non_working_day_change',
  'leave_request_change',
] as const

const auditStatuses = ['success', 'info', 'warning', 'error'] as const

function isValidDateOnly(value: string) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false
  const date = new Date(`${value}T00:00:00.000Z`)
  return Number.isFinite(date.getTime()) && date.toISOString().slice(0, 10) === value
}

const dateOnly = z
  .string()
  .refine((value) => !value || isValidDateOnly(value))
  .catch('')

const auditLogSearchSchema = z.object({
  search: z.string().trim().max(200).catch(''),
  userId: z
    .string()
    .regex(/^\d{0,12}$/)
    .catch(''),
  auditType: z.enum(auditTypes).or(z.literal('')).catch(''),
  auditStatus: z.enum(auditStatuses).or(z.literal('')).catch(''),
  startDate: dateOnly,
  endDate: dateOnly,
  page: z.coerce.number().int().min(1).max(10_000).catch(1),
})

export type AuditLogSearch = z.infer<typeof auditLogSearchSchema>

export function validateAuditLogSearch(search: Record<string, unknown>): AuditLogSearch {
  return auditLogSearchSchema.parse(search)
}

export const AUDIT_LOG_TYPES = auditTypes
export const AUDIT_LOG_STATUSES = auditStatuses

export function auditLogDateRangeError(startDate: string, endDate: string) {
  if (!startDate || !endDate) return null
  return endDate < startDate ? 'End date must be the same as or later than the start date.' : null
}
