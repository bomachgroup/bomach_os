import { canVisitDestination, destinationForPath } from '@/app/navigation/route-manifest'
import { hasPermission, type PermissionSet } from '@/shared/auth/session'

import type { NotificationDto } from './notifications.api'

export type NotificationTone = 'success' | 'warning' | 'danger' | 'info' | 'neutral'
export type NotificationIconName =
  | 'bell'
  | 'calendar'
  | 'clock'
  | 'report'
  | 'money'
  | 'page'
  | 'people'
  | 'task'
  | 'building'
  | 'approvals'
  | 'warning'
  | 'target'
  | 'org'

export interface NotificationMoneySummary {
  label: string
  formatted: string
  tone: 'success' | 'warning' | 'danger' | 'neutral'
}

export interface NotificationDetailRow {
  label: string
  value?: string
  tone?: NotificationTone
  money?: NotificationMoneySummary
}

export interface NotificationDetailSection {
  title: string
  icon: NotificationIconName
  rows: NotificationDetailRow[]
}

export interface NotificationActionLink {
  label: string
  href: string
}

type RecordValue = Record<string, unknown>

function isRecord(value: unknown): value is RecordValue {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
}

function record(value: unknown): RecordValue {
  return isRecord(value) ? value : {}
}

function text(value: unknown): string | undefined {
  if (typeof value === 'string' && value.trim()) return value.trim()
  if (typeof value === 'number' && Number.isFinite(value)) return String(value)
  if (typeof value === 'boolean') return value ? 'Yes' : 'No'
  return undefined
}

function nested(value: unknown, ...keys: string[]): unknown {
  return keys.reduce<unknown>((current, key) => record(current)[key], value)
}

function humanize(value: unknown): string | undefined {
  const normalized = text(value)
  if (!normalized) return undefined
  return normalized
    .replace(/[._-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function notificationDetails(notification: NotificationDto): RecordValue {
  return record(notification.metadata?.details)
}

function canonicalKind(value: unknown): string {
  const kind = (text(value) ?? '').toLowerCase()
  if (kind.includes('attendance') && kind.includes('reminder')) return 'attendance_reminder'
  if (kind.includes('payment')) return 'payment'
  if (kind.includes('invoice')) return 'invoice'
  if (kind.includes('quote')) return 'quote'
  if (kind.includes('real_estate') || kind.includes('installment')) return 'real_estate'
  if (kind.includes('service_task')) return 'service_task'
  if (kind.includes('service_request')) return 'service_request'
  if (kind.includes('service_order') || kind.includes('order')) return 'service_order'
  if (kind.includes('deliverable')) return 'deliverable'
  if (kind.includes('leave')) return 'leave_request'
  if (kind.includes('work_report') || kind.includes('report')) return 'work_report'
  if (kind.includes('project_task') || kind === 'task') return 'project_task'
  if (kind.includes('security')) return 'security'
  return kind
}

export function notificationKind(notification: NotificationDto): string {
  const details = notificationDetails(notification)
  const metadata = record(notification.metadata)
  if (text(details.kind)) return canonicalKind(details.kind)
  if (text(notification.event_type)) return canonicalKind(notification.event_type)
  if (metadata.reference && metadata.amount !== undefined) return 'payment'
  if (metadata.invoice_number) return 'invoice'
  if (metadata.quote_number) return 'quote'
  if (metadata.task_number) return 'service_task'
  return canonicalKind(notification.notification_type) || 'update'
}

export function notificationCategory(notification: NotificationDto): string {
  const kind = notificationKind(notification)
  const details = notificationDetails(notification)
  if (kind === 'attendance_reminder') {
    return details.destination === 'work_report' ? 'Work report' : 'Attendance'
  }
  if (kind === 'leave_request') {
    const requestKind = text(details.request_kind)
    if (requestKind === 'running_late') return 'Late arrival'
    if (requestKind === 'absence') return 'Absence request'
    return 'Leave request'
  }
  const labels: Record<string, string> = {
    work_report: 'Work report',
    project_task: 'Project task',
    service_task: 'Service task',
    service_order: 'Service order',
    service_request: 'Service request',
    real_estate: 'Property update',
    security: 'Security',
  }
  return labels[kind] ?? humanize(kind) ?? 'Update'
}

export function notificationIcon(notification: NotificationDto): NotificationIconName {
  const kind = notificationKind(notification)
  const details = notificationDetails(notification)
  if (kind === 'attendance_reminder') {
    return details.destination === 'work_report' ? 'report' : 'clock'
  }
  if (kind === 'payment') return 'money'
  if (kind === 'invoice' || kind === 'quote' || kind === 'deliverable') return 'page'
  if (kind === 'real_estate') return 'building'
  if (kind === 'service_task' || kind === 'project_task') return 'task'
  if (kind === 'service_request' || kind === 'leave_request') return 'approvals'
  if (kind === 'work_report') return 'report'
  if (kind === 'security') return 'warning'
  return 'bell'
}

export function notificationTone(notification: NotificationDto): NotificationTone {
  const priority = notification.priority.toLowerCase()
  if (priority === 'critical' || notification.notification_type === 'error') return 'danger'
  if (priority === 'high' || notification.notification_type === 'warning') return 'warning'
  if (notification.notification_type === 'success') return 'success'
  if (
    notification.notification_type === 'info' ||
    notification.notification_type === 'approval' ||
    notification.notification_type === 'task'
  ) {
    return 'info'
  }
  return 'neutral'
}

export function notificationPriorityLabel(priority: string) {
  const normalized = priority.trim().toLowerCase()
  if (normalized === 'critical') return 'Critical'
  if (normalized === 'high') return 'Important'
  return undefined
}

export function notificationDate(value: string, relative = false) {
  const date = new Date(value)
  if (!Number.isFinite(date.getTime())) return 'Date unavailable'
  if (relative) {
    const elapsedSeconds = Math.round((date.getTime() - Date.now()) / 1000)
    const units: Array<[number, Intl.RelativeTimeFormatUnit]> = [
      [60, 'second'],
      [60, 'minute'],
      [24, 'hour'],
      [7, 'day'],
      [4.35, 'week'],
      [12, 'month'],
      [Number.POSITIVE_INFINITY, 'year'],
    ]
    let elapsed = elapsedSeconds
    for (const [divisor, unit] of units) {
      if (Math.abs(elapsed) < divisor) {
        return new Intl.RelativeTimeFormat(undefined, { numeric: 'auto' }).format(elapsed, unit)
      }
      elapsed = Math.round(elapsed / divisor)
    }
  }
  return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium', timeStyle: 'short' }).format(
    date,
  )
}

function dateValue(value: unknown, includeTime = false): string | undefined {
  const raw = text(value)
  if (!raw) return undefined
  const parsed = new Date(/^\d{4}-\d{2}-\d{2}$/.test(raw) ? `${raw}T12:00:00` : raw)
  if (!Number.isFinite(parsed.getTime())) return raw
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: 'medium',
    ...(includeTime && !/^\d{4}-\d{2}-\d{2}$/.test(raw) ? { timeStyle: 'short' as const } : {}),
    ...(/^\d{4}-\d{2}-\d{2}$/.test(raw) ? { timeZone: 'UTC' } : {}),
  }).format(parsed)
}

function amountNumber(value: unknown): number | undefined {
  const raw = typeof value === 'number' ? value : Number(String(value ?? '').replace(/,/g, ''))
  return Number.isFinite(raw) ? raw : undefined
}

function moneyValue(value: unknown, label = ''): NotificationMoneySummary | undefined {
  const entry = record(value)
  const rawAmount = entry.amount ?? value
  const amount = amountNumber(rawAmount)
  if (amount === undefined) return undefined
  const currency = (text(entry.currency) ?? 'NGN').toUpperCase()
  let formatted: string
  try {
    formatted = new Intl.NumberFormat('en-NG', {
      style: 'currency',
      currency,
      maximumFractionDigits: 2,
    }).format(amount)
  } catch {
    formatted = `${currency} ${new Intl.NumberFormat('en-NG', { maximumFractionDigits: 2 }).format(amount)}`
  }
  const state = `${text(entry.state) ?? ''} ${text(entry.status) ?? ''} ${label}`.toLowerCase()
  const flow = (text(entry.flow) ?? '').toLowerCase()
  const tone =
    /reject|refund|default|expense|debit|failed|declined/.test(state) || flow === 'outflow'
      ? 'danger'
      : /overdue|outstanding|pending|review/.test(state)
        ? 'warning'
        : /received|confirm|paid|settled|complete|approved/.test(state) || flow === 'inflow'
          ? 'success'
          : 'neutral'
  return { label, formatted, tone }
}

export function notificationMoneySummary(
  notification: NotificationDto,
): NotificationMoneySummary | undefined {
  const details = notificationDetails(notification)
  const kind = notificationKind(notification)
  const invoice = record(details.invoice)
  const invoiceAmounts = record(invoice.amounts)
  const amounts = record(details.amounts)
  const installment = record(details.installment)
  const metadata = record(notification.metadata)

  if (kind === 'payment') {
    return moneyValue(details.money ?? metadata.amount, 'Payment amount')
  }
  if (kind === 'invoice') {
    if (String(invoice.status ?? details.status ?? '').toLowerCase() === 'paid') {
      return moneyValue(amounts.paid ?? invoiceAmounts.paid ?? amounts.total, 'Paid in full')
    }
    return moneyValue(
      amounts.balance_due ??
        invoiceAmounts.balance_due ??
        details.balance_due ??
        details.balance ??
        metadata.balance,
      'Balance due',
    )
  }
  if (kind === 'quote') return moneyValue(details.money ?? details.amount, 'Quote value')
  if (kind === 'service_order') return moneyValue(details.money ?? details.amount, 'Order value')
  if (kind === 'real_estate') {
    const sequence = text(installment.sequence)
    return (
      moneyValue(
        installment.amount_due,
        sequence ? `Installment ${sequence}` : 'Installment due',
      ) ??
      moneyValue(details.quoted_amount, 'Quoted amount') ??
      moneyValue(invoiceAmounts.balance_due, 'Balance due') ??
      moneyValue(invoiceAmounts.paid, 'Paid to date')
    )
  }
  if (kind === 'payment' || kind === 'invoice' || kind === 'quote') return undefined

  const legacyKind = canonicalKind(notification.event_type ?? notification.notification_type)
  if (legacyKind === 'payment' || metadata.reference) {
    return moneyValue(metadata.amount, 'Payment amount')
  }
  if (legacyKind === 'invoice' || metadata.invoice_number) {
    return moneyValue(metadata.balance_due ?? metadata.balance ?? metadata.amount, 'Balance due')
  }
  return undefined
}

function reminderStage(value: unknown): string | undefined {
  const labels: Record<string, string> = {
    clock_in_0800: '8:00 a.m.',
    status_0830: '8:30 a.m.',
    status_0900: '9:00 a.m.',
    work_report_1600: '4:00 p.m.',
    work_report_1700: '5:00 p.m. final reminder',
    clock_out_1700: '5:00 p.m.',
  }
  const raw = text(value)
  return raw ? (labels[raw] ?? humanize(raw)) : undefined
}

function reminderAction(value: unknown): string | undefined {
  const labels: Record<string, string> = {
    clock_in: 'Record your attendance',
    clock_out: 'Complete your clock-out',
    update_attendance_status: 'Update your attendance status',
    submit_work_report: 'Submit today’s work report',
  }
  const raw = text(value)
  return raw ? (labels[raw] ?? humanize(raw)) : undefined
}

function statusTone(value: string): NotificationTone {
  const normalized = value.toLowerCase()
  if (/reject|cancel|overdue|default|failed|declined|returned/.test(normalized)) return 'danger'
  if (/pending|review|awaiting|draft|progress|partial|hold|expir|submitted/.test(normalized)) {
    return 'warning'
  }
  if (/approve|confirm|paid|complete|accept|received|active|sent|done/.test(normalized)) {
    return 'success'
  }
  return 'neutral'
}

function row(label: string, value: unknown, formatter?: (value: unknown) => string | undefined) {
  const formatted = formatter ? formatter(value) : text(value)
  return formatted ? { label, value: formatted } : null
}

function statusRow(label: string, value: unknown) {
  const formatted = humanize(value)
  return formatted ? { label, value: formatted, tone: statusTone(formatted) } : null
}

function moneyRow(label: string, value: unknown) {
  const formatted = moneyValue(value, label)
  return formatted ? { label, money: formatted } : null
}

function section(
  title: string,
  icon: NotificationIconName,
  rows: Array<NotificationDetailRow | null>,
): NotificationDetailSection | null {
  const visibleRows = rows.filter((item): item is NotificationDetailRow => item !== null)
  return visibleRows.length ? { title, icon, rows: visibleRows } : null
}

function fallbackDetails(details: RecordValue): NotificationDetailSection[] {
  const hidden = /^(kind|schema_version|id|.*_id|.*token|.*password|.*secret)$/i
  const rows: Array<NotificationDetailRow | null> = []
  for (const [key, value] of Object.entries(details)) {
    if (hidden.test(key) || rows.length >= 8 || value == null) continue
    const label = humanize(key) ?? key
    if (isRecord(value)) {
      for (const [childKey, childValue] of Object.entries(value)) {
        if (hidden.test(childKey) || rows.length >= 8 || childValue == null) continue
        const childLabel = `${label} · ${humanize(childKey) ?? childKey}`
        const childMoney = /amount|balance|total|price|value/i.test(childKey)
          ? moneyValue(childValue, childLabel)
          : undefined
        rows.push(
          childMoney ? { label: childLabel, money: childMoney } : row(childLabel, childValue),
        )
      }
    } else if (Array.isArray(value)) {
      const formatted = value.slice(0, 3).map(text).filter(Boolean).join(' · ')
      if (formatted) rows.push({ label, value: formatted })
    } else if (/amount|balance|total|price|value/i.test(key)) {
      rows.push(moneyRow(label, value))
    } else {
      rows.push(
        row(
          label,
          value,
          /status|state|type|priority|action|stage/i.test(key) ? humanize : undefined,
        ),
      )
    }
  }
  return [section('Additional information', 'page', rows)].filter(
    (item): item is NotificationDetailSection => item !== null,
  )
}

/** Maps versioned mobile/backend details to readable, type-specific sections. */
export function notificationDetailSections(
  notification: NotificationDto,
): NotificationDetailSection[] {
  const details = notificationDetails(notification)
  const kind = notificationKind(notification)
  const request = record(details.request)
  const service = record(details.service)
  const invoice = record(details.invoice)
  const invoiceAmounts = record(invoice.amounts)
  const payment = record(details.payment)
  const quote = record(details.quote)
  const task = record(details.task)
  const order = record(details.order)
  const deliverable = record(details.deliverable)
  const asset = record(details.asset)
  const installment = record(details.installment)
  const project = record(details.project)
  const milestone = record(details.milestone)
  const amounts = record(details.amounts)
  const rows: Array<NotificationDetailSection | null> = []

  if (kind === 'attendance_reminder') {
    const isReport = details.destination === 'work_report'
    rows.push(
      section(isReport ? 'Work report' : 'Attendance', isReport ? 'report' : 'clock', [
        row('Date', details.date, dateValue),
        row('Reminder', details.stage, reminderStage),
        row('Next step', details.action, reminderAction),
        statusRow('Report status', details.report_status),
      ]),
    )
  } else if (kind === 'leave_request') {
    const requestKind = text(details.request_kind)
    const isLate = requestKind === 'running_late'
    const isAbsence = requestKind === 'absence'
    rows.push(
      section(
        isLate ? 'Late-arrival report' : isAbsence ? 'Absence request' : 'Leave request',
        isLate ? 'clock' : 'calendar',
        [
          statusRow('Status', details.status),
          !isLate && !isAbsence ? row('Leave type', details.leave_type, humanize) : null,
          row(isLate ? 'Reported for' : 'Start date', details.start_date, dateValue),
          !isLate ? row('End date', details.end_date, dateValue) : null,
          !isLate
            ? row('Duration', details.duration_days, (value) => {
                const formatted = text(value)
                return formatted ? `${formatted} ${formatted === '1' ? 'day' : 'days'}` : undefined
              })
            : null,
          row('Submitted', details.submitted_at, (value) => dateValue(value, true)),
          row('Decision recorded', details.decided_at, (value) => dateValue(value, true)),
          row('Reviewed by', details.decision_by),
          row('Decision reason', details.decision_reason),
          row('Decision note', details.decision_note_available ? 'Available' : null),
        ],
      ),
    )
  } else if (kind === 'work_report') {
    rows.push(
      section('Work report', 'report', [
        statusRow('Status', details.status),
        row('Report date', details.report_date, dateValue),
        row('Hours worked', details.hours_worked, (value) => {
          const formatted = text(value)
          return formatted ? `${formatted} hours` : undefined
        }),
        row('Rating', details.rating, (value) => {
          const formatted = text(value)
          return formatted ? `${formatted} / 5` : undefined
        }),
        row('Reviewed', details.reviewed_at, (value) => dateValue(value, true)),
        row('Feedback', details.feedback_available ? 'Available' : null),
      ]),
    )
  } else if (kind === 'payment') {
    rows.push(
      section('Payment', 'money', [
        row('Reference', payment.reference ?? record(notification.metadata).reference),
        statusRow('Status', payment.status ?? notification.event_type),
        row('Method', payment.method, humanize),
        row('Submitted', payment.submitted_at, (value) => dateValue(value, true)),
        row('Payment date', payment.payment_date, dateValue),
        row('Reviewed', payment.reviewed_at, (value) => dateValue(value, true)),
        row('Review note', payment.review_note_available ? 'Available' : null),
      ]),
      section('Invoice', 'page', [
        row('Invoice number', invoice.number ?? record(notification.metadata).invoice_number),
        statusRow('Status', invoice.status),
        row('Due date', invoice.due_date, dateValue),
        moneyRow('Invoice total', invoiceAmounts.total),
        moneyRow('Paid to date', invoiceAmounts.paid),
        moneyRow(
          'Balance due',
          invoiceAmounts.balance_due ?? record(notification.metadata).balance,
        ),
      ]),
    )
  } else if (kind === 'invoice') {
    rows.push(
      section('Invoice', 'page', [
        row(
          'Invoice number',
          invoice.number ?? details.invoice_number ?? record(notification.metadata).invoice_number,
        ),
        statusRow('Status', invoice.status ?? details.status ?? notification.event_type),
        row('Issue date', invoice.issue_date ?? details.issue_date, dateValue),
        row('Due date', invoice.due_date ?? details.due_date, dateValue),
        row('Service', service.name),
        moneyRow('Invoice total', amounts.total ?? invoiceAmounts.total ?? details.total),
        moneyRow('Paid to date', amounts.paid ?? invoiceAmounts.paid ?? details.paid),
        moneyRow(
          'Balance due',
          amounts.balance_due ??
            invoiceAmounts.balance_due ??
            details.balance_due ??
            details.balance,
        ),
      ]),
    )
  } else if (kind === 'quote') {
    rows.push(
      section('Quote', 'page', [
        row('Quote number', quote.number),
        statusRow('Status', quote.status),
        row('Version', quote.version),
        row('Valid until', quote.valid_until, dateValue),
        row('Service', service.name),
        row('Request', request.number),
        moneyRow('Quoted amount', details.money),
      ]),
    )
  } else if (kind === 'service_request') {
    rows.push(
      section('Service request', 'approvals', [
        row('Request number', request.number),
        statusRow('Status', request.status),
        row('Priority', request.priority, humanize),
        row('Created', request.created_at, (value) => dateValue(value, true)),
        row('Due date', request.due_date, dateValue),
        row('Next action', request.next_action),
        row('Service', service.name),
        row('Assigned to', nested(details, 'assigned_to', 'name')),
      ]),
    )
  } else if (kind === 'service_task') {
    rows.push(
      section('Task', 'task', [
        row('Task number', task.number),
        row('Task', task.title),
        statusRow('Status', task.status),
        row('Priority', task.priority, humanize),
        row('Due date', task.due_date, dateValue),
        row('Service', service.name),
      ]),
      section('Service order', 'building', [
        row('Order number', order.number),
        statusRow('Status', order.status),
      ]),
    )
  } else if (kind === 'service_order') {
    rows.push(
      section('Service order', 'building', [
        row('Order number', order.number),
        statusRow('Status', order.status),
        statusRow('Payment status', order.payment_status),
        row('Progress', order.progress, (value) => `${text(value) ?? ''}%`),
        row('Due date', order.due_date, dateValue),
        row('Service', service.name),
        moneyRow('Order value', details.money),
      ]),
    )
  } else if (kind === 'deliverable') {
    rows.push(
      section('Deliverable', 'page', [
        row('Deliverable number', deliverable.number),
        row('Type', deliverable.type, humanize),
        row('Version', deliverable.version),
        statusRow('Status', deliverable.status),
      ]),
      section('Service order', 'building', [
        row('Order number', order.number),
        statusRow('Status', order.status),
      ]),
    )
  } else if (kind === 'real_estate') {
    rows.push(
      section('Property', 'building', [
        row('Property', asset.label),
        row('Estate', asset.estate_name),
        statusRow('Status', asset.state),
        row('Settlement', asset.settlement_mode, humanize),
        row('Reservation expires', asset.reservation_expires_at, (value) => dateValue(value, true)),
        row('Request number', request.number),
      ]),
      section('Installment', 'calendar', [
        row('Installment', installment.sequence),
        row('Description', installment.label),
        statusRow('Status', installment.status),
        row('Due date', installment.due_date, dateValue),
        moneyRow('Amount due', installment.amount_due),
      ]),
      section('Quote', 'page', [
        row('Quote number', quote.number),
        statusRow('Status', quote.status),
        row('Valid until', quote.valid_until, dateValue),
        moneyRow('Quoted amount', details.quoted_amount),
      ]),
      section('Invoice', 'page', [
        row('Invoice number', invoice.number),
        statusRow('Status', invoice.status),
        row('Due date', invoice.due_date, dateValue),
        moneyRow('Paid to date', invoiceAmounts.paid),
        moneyRow('Balance due', invoiceAmounts.balance_due),
      ]),
    )
  } else if (kind === 'project_task') {
    const assignees = Array.isArray(details.assignees)
      ? details.assignees
          .map((person) => {
            const assignee = record(person)
            return [text(assignee.name), text(assignee.designation)].filter(Boolean).join(' · ')
          })
          .filter(Boolean)
      : []
    rows.push(
      section('Task', 'task', [
        row('Task', details.title),
        row('Description', details.description),
        statusRow('Status', details.status),
        statusRow('Previous status', details.previous_status),
        row('Changed by', details.changed_by),
        row('Priority', details.priority, humanize),
        row('Due date', details.due_date, dateValue),
        row('Estimated effort', details.estimated_hours, (value) => `${text(value) ?? ''} hours`),
      ]),
      section('Project', 'org', [
        row('Name', project.name),
        row('Project code', project.short_code),
        statusRow('Status', project.status),
        statusRow('Priority', project.priority),
        row('Location', project.location),
        row('Progress', project.progress, (value) => `${text(value) ?? ''}%`),
        row('Start date', project.start_date, dateValue),
        row('Deadline', project.deadline, dateValue),
      ]),
      section('Milestone', 'target', [
        row('Name', milestone.name),
        statusRow('Status', milestone.status),
        statusRow('Priority', milestone.priority),
        row('Progress', milestone.progress, (value) => `${text(value) ?? ''}%`),
        row('Start date', milestone.start_date, dateValue),
        row('End date', milestone.end_date, dateValue),
      ]),
      section('People', 'people', [
        row('Created by', nested(details, 'created_by', 'name')),
        assignees.length ? { label: 'Assigned to', value: assignees.join('\n') } : null,
        row('Assigned by', details.assigned_by),
      ]),
    )
  } else {
    const legacy = record(notification.metadata)
    rows.push(
      section('Notification details', notificationIcon(notification), [
        row('Reference', legacy.reference),
        row('Invoice number', legacy.invoice_number),
        row('Quote number', legacy.quote_number),
        row('Request number', legacy.request_number),
        row('Task number', legacy.task_number),
        statusRow('Status', legacy.status),
        row('Due date', legacy.due_date, dateValue),
        moneyRow('Amount', legacy.amount),
      ]),
    )
  }

  const sections = rows.filter((item): item is NotificationDetailSection => item !== null)
  return sections.length ? sections : Object.keys(details).length ? fallbackDetails(details) : []
}

function attendanceReminderActions(
  notification: NotificationDto,
  permissions: PermissionSet,
): NotificationActionLink[] {
  const details = notificationDetails(notification)
  const action = text(details.action) ?? notification.action.toLowerCase()
  const destination = text(details.destination)
  if (
    destination === 'attendance' &&
    ['clock_in', 'clock_out', 'update_attendance_status'].includes(action)
  ) {
    return canOpenPath('/hr/attendance', permissions)
      ? [{ label: 'Open attendance', href: '/hr/attendance' }]
      : []
  }
  if (destination === 'work_report' && action === 'submit_work_report') {
    const reportId = text(details.report_id)
    const reportPath = reportId && /^\d+$/.test(reportId) ? `/dashboard/my-reports/${reportId}` : ''
    if (reportPath && canOpenPath(reportPath, permissions)) {
      return [{ label: 'Open today’s work report', href: reportPath }]
    }
    if (canOpenPath('/dashboard/my-reports/create', permissions)) {
      return [{ label: 'Prepare today’s work report', href: '/dashboard/my-reports/create' }]
    }
    return canOpenPath('/dashboard/my-reports', permissions)
      ? [{ label: 'Open work reports', href: '/dashboard/my-reports' }]
      : []
  }
  return []
}

function canOpenPath(path: string, permissions: PermissionSet): boolean {
  const pathname = path.split(/[?#]/, 1)[0] ?? path
  const destination = destinationForPath(pathname)
  if (destination) return canVisitDestination(destination, permissions)
  if (/^\/hr\/leaves\/\d+\/?$/.test(pathname)) {
    return (
      hasPermission(permissions, 'leave_requests', 'view_own') ||
      hasPermission(permissions, 'leave_requests', 'view')
    )
  }
  if (/^\/dashboard\/my-reports\/\d+\/?$/.test(pathname)) {
    return (
      hasPermission(permissions, 'work_reports', 'view_own') ||
      hasPermission(permissions, 'work_reports', 'view')
    )
  }
  if (pathname === '/dashboard/my-reports/create') {
    return hasPermission(permissions, 'work_reports', 'create')
  }
  return false
}

function safeNotificationLink(link: string, permissions: PermissionSet): string | undefined {
  if (!link || typeof window === 'undefined') return undefined
  try {
    const url = new URL(link, window.location.origin)
    if (url.origin !== window.location.origin || !canOpenPath(url.pathname, permissions)) {
      return undefined
    }
    return `${url.pathname}${url.search}${url.hash}`
  } catch {
    return undefined
  }
}

function notificationActionLabel(path: string): string | undefined {
  const pathname = path.split(/[?#]/, 1)[0] ?? path
  if (/^\/hr\/leaves\/\d+\/?$/.test(pathname)) return 'Open leave request'
  if (/^\/dashboard\/my-reports\/\d+\/?$/.test(pathname)) return 'Open work report'
  if (/^\/dashboard\/my-reports\/create\/?$/.test(pathname)) return 'Prepare work report'
  if (pathname === '/dashboard/my-reports') return 'Open work reports'
  if (pathname === '/hr/attendance') return 'Open attendance'
  if (pathname === '/dashboard/my-tasks') return 'Open tasks'
  if (pathname === '/notifications') return 'Open notifications'
  const destination = destinationForPath(pathname)
  return destination ? `Open ${destination.title}` : undefined
}

function notificationEntityPath(notification: NotificationDto, permissions: PermissionSet) {
  const metadata = record(notification.metadata)
  const type = (notification.entity_type || text(metadata.entity_type) || '').toLowerCase()
  const id = notification.entity_id || text(metadata.entity_id) || ''
  if (!/^\d+$/.test(id) || Number(id) < 1) return undefined
  if (type === 'leave_request') {
    const path = `/hr/leaves/${id}`
    return canOpenPath(path, permissions) ? path : undefined
  }
  if (type === 'work_report') {
    const path = `/dashboard/my-reports/${id}`
    return canOpenPath(path, permissions) ? path : undefined
  }
  if (type === 'attendance') {
    return canOpenPath('/hr/attendance', permissions) ? '/hr/attendance' : undefined
  }
  if (type === 'task' || type === 'project_task') {
    return canOpenPath('/dashboard/my-tasks', permissions) ? '/dashboard/my-tasks' : undefined
  }
  return undefined
}

/** Returns only routes implemented in this port and allowed by the user's permissions. */
export function notificationActions(
  notification: NotificationDto,
  permissions: PermissionSet,
): NotificationActionLink[] {
  const details = notificationDetails(notification)
  const kind = notificationKind(notification)
  if (kind === 'attendance_reminder') return attendanceReminderActions(notification, permissions)
  if (details.kind === 'attendance_end_of_day') {
    return [
      ...(canOpenPath('/hr/attendance', permissions)
        ? [{ label: 'Open attendance', href: '/hr/attendance' }]
        : []),
      ...(canOpenPath('/dashboard/my-reports', permissions)
        ? [{ label: 'Open work reports', href: '/dashboard/my-reports' }]
        : []),
    ]
  }
  const entityPath = notificationEntityPath(notification, permissions)
  if (entityPath) {
    const label = notificationActionLabel(entityPath)
    return label ? [{ label, href: entityPath }] : []
  }
  const link = safeNotificationLink(notification.link, permissions)
  if (!link) return []
  const label = notificationActionLabel(link)
  return label ? [{ label, href: link }] : []
}

/** Resolve an optional backend link only when it is same-origin, implemented, and authorized. */
export function notificationTarget(link: string, permissions: PermissionSet) {
  return safeNotificationLink(link, permissions)
}

export function notificationContextSummary(notification: NotificationDto): string | undefined {
  const details = notificationDetails(notification)
  const kind = notificationKind(notification)
  const dateRange = (start: unknown, end: unknown) => {
    const first = dateValue(start)
    const last = dateValue(end)
    if (!first) return undefined
    return last && first !== last ? `${first} – ${last}` : first
  }
  if (kind === 'attendance_reminder') {
    return [dateValue(details.date), reminderStage(details.stage)].filter(Boolean).join(' · ')
  }
  if (kind === 'leave_request') {
    const kindLabel =
      text(details.request_kind) === 'absence'
        ? 'Absence request'
        : text(details.request_kind) === 'running_late'
          ? 'Late-arrival report'
          : humanize(details.leave_type)
    return [kindLabel, dateRange(details.start_date, details.end_date)].filter(Boolean).join(' · ')
  }
  if (kind === 'work_report') {
    const hours = text(details.hours_worked)
    return [dateValue(details.report_date), hours ? `${hours} hours` : undefined]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'project_task') {
    return [
      text(record(details.project).name),
      details.due_date ? `Due ${dateValue(details.due_date)}` : undefined,
    ]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'service_task') {
    return [
      text(record(details.task).number),
      details.due_date ? `Due ${dateValue(details.due_date)}` : undefined,
    ]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'payment') {
    return [
      text(record(details.payment).reference),
      text(record(details.invoice).number)
        ? `Invoice ${text(record(details.invoice).number)}`
        : undefined,
    ]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'invoice') {
    const number = text(
      record(details.invoice).number ??
        details.invoice_number ??
        record(notification.metadata).invoice_number,
    )
    return number ? `Invoice ${number}` : undefined
  }
  if (kind === 'quote') {
    const number = text(record(details.quote).number)
    return number ? `Quote ${number}` : text(record(details.service).name)
  }
  if (kind === 'service_request') {
    return [text(record(details.request).number), text(record(details.service).name)]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'service_order') {
    return [
      text(record(details.order).number)
        ? `Order ${text(record(details.order).number)}`
        : undefined,
      text(record(details.service).name),
    ]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'deliverable') {
    return [text(record(details.deliverable).number), humanize(record(details.deliverable).type)]
      .filter(Boolean)
      .join(' · ')
  }
  if (kind === 'real_estate') {
    return [text(record(details.asset).label), text(record(details.asset).estate_name)]
      .filter(Boolean)
      .join(' · ')
  }
  const metadata = record(notification.metadata)
  if (metadata.reference) return text(metadata.reference)
  if (metadata.invoice_number) return `Invoice ${text(metadata.invoice_number)}`
  if (metadata.quote_number) return `Quote ${text(metadata.quote_number)}`
  return undefined
}
