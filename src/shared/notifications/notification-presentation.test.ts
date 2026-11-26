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

  it('presents partner-message context and opens only the permission-scoped conversation', () => {
    const item = makeNotification({
      title: 'New partner message',
      message: 'A partner sent a message in your private conversation.',
      entity_type: 'partner_message',
      entity_id: '91',
      link: '/company/partners/17?tab=messages&conversation=4',
      metadata: {
        partner_id: 17,
        conversation_id: 4,
        message_id: 91,
        amount: 0,
        details: {
          schema_version: 1,
          kind: 'partner_message',
          conversation_kind: 'direct',
          sender_role: 'partner',
          partner_code: 'BOM-REA-017',
        },
      },
    })

    expect(notificationCategory(item)).toBe('Partner message')
    expect(notificationIcon(item)).toBe('message')
    expect(notificationContextSummary(item)).toBe('Private conversation · From partner')
    expect(notificationDetailSections(item)).toEqual([
      expect.objectContaining({
        title: 'Partner conversation',
        rows: expect.arrayContaining([
          expect.objectContaining({ label: 'From', value: 'Partner' }),
          expect.objectContaining({ label: 'Thread', value: 'Private conversation' }),
          expect.objectContaining({ label: 'Partner reference', value: 'BOM-REA-017' }),
        ]),
      }),
    ])
    expect(notificationDetailSections(item).flatMap((section) => section.rows)).not.toContainEqual(
      expect.objectContaining({ label: 'Amount' }),
    )
    expect(notificationActions(item, { partner_messages: ['list'] })).toEqual([
      {
        label: 'Open conversation',
        href: '/company/partners/17?tab=messages&conversation=4',
      },
    ])
    expect(notificationActions(item, {})).toEqual([])
  })

  it('maps legacy partner-message links to the authorized message register', () => {
    const item = makeNotification({
      title: 'New partner message',
      message: 'A partner sent a message.',
      entity_type: 'direct_notification',
      entity_id: '',
      link: '/partners/17/messages',
      metadata: { partner_id: 17 },
    })

    expect(notificationContextSummary(item)).toBe('Partner messaging · From partner')
    expect(notificationDetailSections(item)).toEqual([
      expect.objectContaining({
        title: 'Partner conversation',
        rows: expect.arrayContaining([
          expect.objectContaining({ label: 'From', value: 'Partner' }),
          expect.objectContaining({ label: 'Thread', value: 'Partner messaging' }),
          expect.objectContaining({ label: 'Partner reference', value: 'Partner #17' }),
        ]),
      }),
    ])
    expect(notificationActions(item, { partner_messages: ['list'] })).toEqual([
      {
        label: 'Open partner messages',
        href: '/company/partners/17?tab=messages',
      },
    ])
    expect(notificationActions(item, { partners: ['view'] })).toEqual([])
  })

  it('opens a typed partner conversation even when its notification entity id is absent', () => {
    const item = makeNotification({
      title: 'New partner message',
      entity_type: 'partner_message',
      entity_id: '',
      metadata: { partner_id: 17, conversation_id: 4 },
    })

    expect(notificationActions(item, { partner_messages: ['list'] })).toEqual([
      {
        label: 'Open conversation',
        href: '/company/partners/17?tab=messages&conversation=4',
      },
    ])
  })

  it('recognizes and links legacy partner-message notifications without exposing generic amount metadata', () => {
    const item = makeNotification({
      title: 'New message from Bomach',
      notification_type: 'direct_notification',
      entity_type: '',
      metadata: {
        entity_type: 'partner_message',
        entity_id: '25',
        partner_id: 9,
        conversation_id: 2,
        amount: 0,
      },
      link: '/partners/app?tab=messages&conversation=2',
    })

    expect(notificationCategory(item)).toBe('Partner message')
    expect(notificationDetailSections(item).flatMap((section) => section.rows)).not.toContainEqual(
      expect.objectContaining({ label: 'Amount' }),
    )
    expect(notificationActions(item, { partner_messages: ['list'] })).toEqual([
      { label: 'Open conversation', href: '/company/partners/9?tab=messages&conversation=2' },
    ])
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

  it('opens marketing lead details from entity metadata or legacy links', () => {
    const marketingPermissions: PermissionSet = { leads: ['view', 'list'] }

    expect(
      notificationActions(
        makeNotification({
          title: 'Lead assigned to you',
          entity_type: 'lead',
          entity_id: '7',
          link: '/marketing/leads-detail?id=7',
          metadata: {
            lead_id: 7,
            notification_kind: 'lead_assignment',
          },
        }),
        marketingPermissions,
      ),
    ).toEqual([{ label: 'Open lead details', href: '/marketing/leads-detail?id=7' }])

    expect(
      notificationActions(
        makeNotification({
          title: 'Lead assigned to you',
          link: '/leads-detail?id=42',
          metadata: { lead_id: 42, notification_kind: 'lead_assignment' },
        }),
        marketingPermissions,
      ),
    ).toEqual([{ label: 'Open lead details', href: '/marketing/leads-detail?id=42' }])

    expect(
      notificationActions(
        makeNotification({
          entity_type: 'lead',
          entity_id: '7',
          link: '/marketing/leads-detail?id=7',
        }),
        {},
      ),
    ).toEqual([])
  })
})
