import { complianceRecordTypes, type ComplianceRecordDto } from '@/modules/company/governance.api'
import type { StatusTone } from '@/shared/ui/status-chip'

export function formatComplianceDate(value: string | null | undefined) {
  if (!value) return 'Not provided'
  const date = new Date(`${value.slice(0, 10)}T12:00:00`)
  return Number.isNaN(date.getTime())
    ? value
    : new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      }).format(date)
}

export function complianceTypeLabel(value: string) {
  return (
    complianceRecordTypes.find((item) => item.value === value)?.label ?? value.replaceAll('_', ' ')
  )
}

export function safeComplianceDocumentUrl(value: string) {
  try {
    const url = new URL(value)
    return url.protocol === 'https:' || url.protocol === 'http:' ? url.href : null
  } catch {
    return null
  }
}

function dayCount(value: number) {
  return `${value} day${value === 1 ? '' : 's'}`
}

export function complianceState(record: ComplianceRecordDto): {
  label: string
  tone: StatusTone
  hint: string
} {
  if (record.status === 'archived') return { label: 'Archived', tone: 'neutral', hint: '' }
  if (record.is_expired || record.status === 'expired')
    return { label: 'Expired', tone: 'danger', hint: '' }
  if (record.status === 'pending') return { label: 'Pending', tone: 'warning', hint: '' }
  if (record.days_until_expiry === 0)
    return { label: 'Active', tone: 'success', hint: 'Expires today' }
  if (record.days_until_expiry > 0 && record.days_until_expiry <= 30) {
    return {
      label: 'Active',
      tone: 'warning',
      hint: `Expires in ${dayCount(record.days_until_expiry)}`,
    }
  }
  return { label: 'Active', tone: 'success', hint: '' }
}
