import { describe, expect, it } from 'vitest'

import type { PermissionSet } from '@/shared/auth/session'

import {
  notificationActions,
  notificationCategory,
  notificationContextSummary,
  notificationDetailSections,
  notificationIcon,
  notificationMoneySummary,
  notificationTone,
} from './notification-presentation'
import type { NotificationDto } from './notifications.api'

function makeNotification(overrides: Partial<NotificationDto> = {}): NotificationDto {
  return {
    id: 7,
    title: 'Update available',
    message: 'Review the latest update.',
    notification_type: 'info',
    is_read: false,
    link: '',
    metadata: {},
    created_at: '2026-10-20T10:00:00Z',
    event_type: null,
    priority: 'normal',
    action: '',
    entity_type: '',
    entity_id: '',
    ...overrides,
  }
}

describe('notification presentation and authorized destinations', () => {
  it('uses notification type for the base color and lets urgency raise the tone', () => {
    expect(notificationTone(makeNotification())).toBe('info')
    expect(notificationTone(makeNotification({ notification_type: 'success' }))).toBe('success')
    expect(notificationTone(makeNotification({ notification_type: 'warning' }))).toBe('warning')
    expect(
      notificationTone(makeNotification({ notification_type: 'info', priority: 'high' })),
    ).toBe('warning')
    expect(
      notificationTone(makeNotification({ notification_type: 'warning', priority: 'critical' })),
    ).toBe('danger')
  })

  it('uses mobile-style attendance context and details', () => {
    const item = makeNotification({
      title: 'Attendance has not been recorded',
      event_type: 'attendance_status_reminder',
      entity_type: 'attendance',
      entity_id: '17',
      metadata: {
        details: {
          schema_version: 1,
          kind: 'attendance_reminder',
          destination: 'attendance',
          date: '2026-10-20',
          stage: 'status_0830',
          action: 'update_attendance_status',
        },
      },
    })

    expect(notificationCategory(item)).toBe('Attendance')
    expect(notificationIcon(item)).toBe('clock')
    expect(notificationContextSummary(item)).toBe('Oct 20, 2026 · 8:30 a.m.')
    expect(notificationDetailSections(item)).toEqual([
      expect.objectContaining({
        title: 'Attendance',
        icon: 'clock',
        rows: expect.arrayContaining([
          expect.objectContaining({ label: 'Date', value: 'Oct 20, 2026' }),
          expect.objectContaining({ label: 'Reminder', value: '8:30 a.m.' }),
          expect.objectContaining({
            label: 'Next step',
            value: 'Update your attendance status',
          }),
        ]),
      }),
    ])
  })

  it('maps a backend leave deep link to the implemented own-request page only with permission', () => {
    const item = makeNotification({
      title: 'Leave request approved',
      link: '/leave/42',
      entity_type: 'leave_request',
      entity_id: '42',
      metadata: {
        details: {
          schema_version: 1,
          kind: 'leave_request',
          request_kind: 'leave',
          leave_type: 'annual',
          start_date: '2026-10-24',
          end_date: '2026-10-25',
          duration_days: 2,
          status: 'approved',
        },
      },
    })

    expect(notificationCategory(item)).toBe('Leave request')
    expect(notificationContextSummary(item)).toBe('Annual · Oct 24, 2026 – Oct 25, 2026')
    expect(notificationActions(item, { leave_requests: ['view_own'] })).toEqual([
      { label: 'Open leave request', href: '/hr/leaves/42' },
    ])
    expect(notificationActions(item, {})).toEqual([])
  })

  it('uses the real destination name for work reports and permission-checked app routes', () => {
    const report = makeNotification({
      entity_type: 'work_report',
      entity_id: '19',
      link: '/dashboard/my-reports/19',
    })
    expect(notificationActions(report, { work_reports: ['view_own'] })).toEqual([
      { label: 'Open work report', href: '/dashboard/my-reports/19' },
    ])

    const appRoute = makeNotification({
      link: '/hr/leave-request',
      entity_type: '',
      entity_id: '',
    })
    expect(notificationActions(appRoute, { leave_requests: ['list'] })).toEqual([
      { label: 'Open Leave Requests', href: '/hr/leave-request' },
    ])
  })

  it('routes work-report reminders to the report or its supported create/list destination', () => {
    const permissions: PermissionSet = { work_reports: ['view_own', 'create'] }
    const withReport = makeNotification({
      action: 'submit_work_report',
      metadata: {
        details: {
          schema_version: 1,
          kind: 'attendance_reminder',
          destination: 'work_report',
          action: 'submit_work_report',
          report_id: 19,
        },
      },
    })
    const withoutReport = makeNotification({
      metadata: {
        details: {
          schema_version: 1,
          kind: 'attendance_reminder',
          destination: 'work_report',
          action: 'submit_work_report',
        },
      },
    })

    expect(notificationActions(withReport, permissions)).toEqual([
      { label: 'Open today’s work report', href: '/dashboard/my-reports/19' },
    ])
    expect(notificationActions(withoutReport, permissions)).toEqual([
      { label: 'Prepare today’s work report', href: '/dashboard/my-reports/create' },
    ])
  })

  it('formats money notifications with a state-aware amount and typed sections', () => {
    const item = makeNotification({
      title: 'Payment confirmed',
      notification_type: 'success',
      entity_type: 'payment',
      metadata: {
        details: {
          schema_version: 1,
          kind: 'payment',
          money: {
            amount: '12500',
            currency: 'NGN',
            flow: 'inflow',
            state: 'confirmed',
          },
          payment: { reference: 'PAY-7', status: 'confirmed', method: 'bank_transfer' },
          invoice: {
            number: 'INV-7',
            amounts: {
              total: { amount: '25000', currency: 'NGN', state: 'invoiced' },
              paid: { amount: '12500', currency: 'NGN', state: 'received' },
              balance_due: { amount: '12500', currency: 'NGN', state: 'outstanding' },
            },
          },
        },
      },
    })

    expect(notificationMoneySummary(item)).toMatchObject({
      label: 'Payment amount',
      formatted: '₦12,500.00',
      tone: 'success',
    })
    expect(notificationDetailSections(item).map(({ title }) => title)).toEqual([
      'Payment',
      'Invoice',
    ])
    expect(notificationDetailSections(item)[1]?.rows).toContainEqual(
      expect.objectContaining({
        label: 'Balance due',
        money: expect.objectContaining({ tone: 'warning' }),
      }),
    )
  })

  it('does not follow an external backend link or show an unauthorized destination', () => {
    expect(
      notificationActions(makeNotification({ link: 'https://attacker.example/leave/7' }), {
        leave_requests: ['view_own'],
      }),
    ).toEqual([])
    expect(
      notificationActions(
        makeNotification({
          link: '/hr/attendance',
          entity_type: 'attendance',
        }),
        { attendance: ['list_own'] },
      ),
    ).toEqual([{ label: 'Open attendance', href: '/hr/attendance' }])
  })
})
