import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { ApiError } from '@/shared/api/api-error'

const notificationMocks = vi.hoisted(() => ({
  list: vi.fn(),
  stats: vi.fn(),
  get: vi.fn(),
  markRead: vi.fn(),
  markAllRead: vi.fn(),
}))

vi.mock('@/shared/notifications/notifications.api', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/shared/notifications/notifications.api')>()
  return {
    ...actual,
    notificationApi: {
      list: notificationMocks.list,
      stats: notificationMocks.stats,
      get: notificationMocks.get,
      markRead: notificationMocks.markRead,
      markAllRead: notificationMocks.markAllRead,
    },
  }
})

import { NotificationsPage } from './notifications-page'
import { NotificationDetailPage } from './notification-detail-page'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { type NotificationDto } from '@/shared/notifications/notifications.api'
import { validateNotificationsSearch } from '@/shared/notifications/notifications.search'

function session(): AuthenticatedSession {
  const permissions = {
    notifications: ['list', 'view', 'mark_read', 'mark_all_read'],
    attendance: ['list_own'],
  }
  return {
    user: {
      id: 7,
      email: 'staff@example.com',
      username: 'staff',
      first_name: 'Staff',
      last_name: 'User',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions: {},
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-7',
      username: 'staff',
      email: 'staff@example.com',
      first_name: 'Staff',
      last_name: 'User',
      designation: 'Coordinator',
    },
    roles: [{ id: 1, name: 'Staff', permissions }],
    permissions,
  }
}

function notification(overrides: Partial<NotificationDto> = {}): NotificationDto {
  return {
    id: 81,
    title: 'Leave request needs review',
    message: 'A leave request has been submitted for your review.',
    notification_type: 'approval',
    is_read: true,
    link: '/hr/leave-request',
    metadata: {},
    created_at: '2026-10-17T09:00:00Z',
    event_type: 'leave.requested',
    priority: 'normal',
    action: 'Review request',
    entity_type: 'leave_request',
    entity_id: '81',
    ...overrides,
  }
}

function renderNotificationRoute(path: string) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session())

  const rootRoute = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: Outlet,
  })
  const inboxRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/notifications',
    validateSearch: validateNotificationsSearch,
    component: NotificationsPage,
  })
  const detailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/notifications/$notificationId',
    validateSearch: validateNotificationsSearch,
    component: NotificationDetailPage,
  })
  const attendanceRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/hr/attendance',
    component: () => createElement('div', null, 'Attendance page'),
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      protectedRoute.addChildren([inboxRoute, detailRoute, attendanceRoute]),
    ]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })

  const result = render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(RouterProvider, { router }),
    ) as ReactNode,
  )

  return { ...result, queryClient, router }
}

describe('notification inbox and detail routing', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    Object.defineProperty(navigator, 'onLine', { configurable: true, value: true })
    notificationMocks.list.mockImplementation(({ isRead }: { isRead?: boolean }) =>
      Promise.resolve(
        isRead === false ? { items: [], count: 0 } : { items: [notification()], count: 1 },
      ),
    )
    notificationMocks.stats.mockResolvedValue({ unread_count: 0 })
    notificationMocks.get.mockResolvedValue(notification())
    notificationMocks.markRead.mockResolvedValue(notification())
    notificationMocks.markAllRead.mockResolvedValue({ detail: 'Marked notifications as read' })
  })

  it('loads the protected inbox and keeps the selected filter in the URL', async () => {
    const user = userEvent.setup()
    const { router } = renderNotificationRoute('/notifications?filter=all')

    expect(
      await screen.findByRole('link', {
        name: 'Open notification: Leave request needs review',
      }),
    ).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: /^Unread$/ }))
    await waitFor(() => expect(router.state.location.search).toMatchObject({ filter: 'unread' }))
    expect(await screen.findByText('You are all caught up')).toBeInTheDocument()
    expect(notificationMocks.list).toHaveBeenCalledWith(expect.objectContaining({ isRead: false }))

    await user.click(screen.getByRole('button', { name: /^All notifications$/ }))
    expect(
      await screen.findByRole('link', {
        name: 'Open notification: Leave request needs review',
      }),
    ).toBeInTheDocument()

    await user.click(screen.getByText('A leave request has been submitted for your review.'))
    await waitFor(() => expect(router.state.location.pathname).toBe('/notifications/81'))
    expect(router.state.location.search).toMatchObject({ filter: 'all' })
  })

  it('puts the newest notification first and opens its named destination', async () => {
    const user = userEvent.setup()
    const newest = notification({
      id: 82,
      title: 'Attendance status reminder',
      message: 'Update your attendance status for today.',
      notification_type: 'info',
      is_read: false,
      link: '/hr/attendance',
      entity_type: 'attendance',
      entity_id: '82',
      created_at: '2026-10-22T11:00:00Z',
      metadata: {
        details: {
          schema_version: 1,
          kind: 'attendance_reminder',
          destination: 'attendance',
          date: '2026-10-22',
          stage: 'status_0830',
          action: 'update_attendance_status',
        },
      },
    })
    const older = notification({ id: 81, created_at: '2026-10-21T09:00:00Z' })
    notificationMocks.list.mockResolvedValue({ items: [older, newest], count: 2 })
    notificationMocks.stats.mockResolvedValue({ unread_count: 1 })
    const { router } = renderNotificationRoute('/notifications?filter=all')

    const notificationLinks = await screen.findAllByRole('link', { name: /Open notification:/ })
    expect(notificationLinks[0]).toHaveAccessibleName(
      'Open notification: Attendance status reminder',
    )
    expect(screen.getAllByRole('article')[0]).toHaveClass('border-info/30')
    expect(
      screen.getByRole('button', { name: 'Open attendance: Attendance status reminder' }),
    ).toBeInTheDocument()

    await user.click(
      screen.getByRole('button', { name: 'Open attendance: Attendance status reminder' }),
    )
    await waitFor(() => expect(router.state.location.pathname).toBe('/hr/attendance'))
    expect(notificationMocks.markRead.mock.calls[0]?.[0]).toBe(82)
  })

  it('loads notification params and preserves the inbox filter on back navigation', async () => {
    const user = userEvent.setup()
    const { router } = renderNotificationRoute('/notifications/81?filter=unread')

    expect(
      await screen.findByRole('heading', { name: 'Leave request needs review' }),
    ).toBeInTheDocument()
    expect(notificationMocks.get).toHaveBeenCalledWith(81, expect.anything())

    await user.click(screen.getByRole('link', { name: 'Back to Notifications' }))
    await waitFor(() => expect(router.state.location.pathname).toBe('/notifications'))
    expect(router.state.location.search).toMatchObject({ filter: 'unread' })
  })

  it('shows a safe empty state for an invalid detail identifier without fetching a record', async () => {
    renderNotificationRoute('/notifications/not-a-number?filter=all')

    expect(
      await screen.findByRole('heading', { name: 'Notification not found' }),
    ).toBeInTheDocument()
    expect(notificationMocks.get).not.toHaveBeenCalled()
  })

  it('explains an offline connection and recovers when the user retries', async () => {
    const user = userEvent.setup()
    Object.defineProperty(navigator, 'onLine', { configurable: true, value: false })
    notificationMocks.list
      .mockRejectedValueOnce(new ApiError('Network request failed', { status: 0 }))
      .mockResolvedValueOnce({ items: [], count: 0 })

    renderNotificationRoute('/notifications?filter=all')

    expect(await screen.findByRole('heading', { name: 'You are offline' })).toBeInTheDocument()
    expect(screen.getByText('Reconnect to the internet, then try again.')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('No notifications yet')).toBeInTheDocument()
  })

  it('explains a server failure and recovers when the service is available again', async () => {
    const user = userEvent.setup()
    notificationMocks.list
      .mockRejectedValueOnce(new ApiError('Internal Server Error', { status: 503 }))
      .mockResolvedValueOnce({ items: [], count: 0 })

    renderNotificationRoute('/notifications?filter=all')

    expect(
      await screen.findByRole('heading', { name: 'Service temporarily unavailable' }),
    ).toBeInTheDocument()
    expect(
      screen.getByText('BOMACH OS could not complete this request. Please try again shortly.'),
    ).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('No notifications yet')).toBeInTheDocument()
  })
})
