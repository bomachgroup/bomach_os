import { createElement, type AnchorHTMLAttributes, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { beforeEach, describe, expect, it, vi } from 'vitest'

const routerMocks = vi.hoisted(() => ({
  pathname: '/dashboard',
  navigate: vi.fn(async () => undefined),
  subscribe: vi.fn(() => () => undefined),
}))

const notificationMocks = vi.hoisted(() => ({
  list: vi.fn(),
  stats: vi.fn(),
  markRead: vi.fn(),
  markAllRead: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({
      to,
      children,
      ...props
    }: AnchorHTMLAttributes<HTMLAnchorElement> & { to: string; children: ReactNode }) =>
      createElement('a', { ...props, href: to }, children),
    Outlet: () => null,
    useNavigate: () => routerMocks.navigate,
    useRouter: () => ({ subscribe: routerMocks.subscribe }),
    useRouterState: ({
      select,
    }: {
      select: (state: { location: { pathname: string } }) => unknown
    }) => select({ location: { pathname: routerMocks.pathname } }),
  }
})

vi.mock('@/shared/auth/auth.api', () => ({
  authApi: {
    logout: vi.fn(async () => ({ success: true })),
  },
}))

vi.mock('@/shared/notifications/notifications.api', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@/shared/notifications/notifications.api')>()
  return { ...actual, notificationApi: notificationMocks }
})

import { AppShell } from './app-shell'
import { authApi } from '@/shared/auth/auth.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { notificationApi, type NotificationDto } from '@/shared/notifications/notifications.api'
import { ToastProvider } from '@/shared/feedback/toast-provider'

Object.defineProperty(HTMLDialogElement.prototype, 'showModal', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.setAttribute('open', '')
  },
})
Object.defineProperty(HTMLDialogElement.prototype, 'close', {
  configurable: true,
  value(this: HTMLDialogElement) {
    this.removeAttribute('open')
    this.dispatchEvent(new Event('close'))
  },
})

function session(
  permissions: Record<string, string[]> = { employees: ['list'] },
): AuthenticatedSession {
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
    is_read: false,
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

function renderShell(permissions?: Record<string, string[]>) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session(permissions))
  const result = render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(ToastProvider, null, createElement(AppShell)),
    ),
  )
  return { queryClient, ...result }
}

beforeEach(() => {
  localStorage.clear()
  routerMocks.pathname = '/dashboard'
  vi.clearAllMocks()
  Object.defineProperty(window, 'matchMedia', {
    configurable: true,
    value: vi.fn().mockImplementation((query: string) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      addListener: vi.fn(),
      removeListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })
  notificationMocks.list.mockResolvedValue({ items: [], count: 0 })
  notificationMocks.stats.mockResolvedValue({ unread_count: 0 })
  notificationMocks.markRead.mockResolvedValue(notification({ is_read: true }))
  notificationMocks.markAllRead.mockResolvedValue({ detail: 'Marked notifications as read' })
})

describe('authenticated app shell', () => {
  it('filters sidebar destinations by both menu visibility and route permission', () => {
    renderShell({ employees: ['list'] })

    fireEvent.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))

    expect(screen.getByRole('link', { name: /Overview/ })).toHaveAttribute('href', '/dashboard')
    expect(screen.getByRole('link', { name: /Employees/ })).toHaveAttribute('href', '/hr/employees')
    expect(screen.queryByRole('link', { name: /Roles & Permissions/ })).not.toBeInTheDocument()
    expect(screen.queryByRole('link', { name: /Recruitment/ })).not.toBeInTheDocument()
  })

  it('keeps the selected navigation link in sync with router location changes', () => {
    const { queryClient, rerender } = renderShell({ employees: ['list'] })
    const renderApp = () =>
      rerender(createElement(QueryClientProvider, { client: queryClient }, createElement(AppShell)))

    expect(screen.getByRole('link', { name: 'Overview' })).toHaveAttribute('aria-current', 'page')
    routerMocks.pathname = '/hr/employees'
    renderApp()
    expect(screen.getByRole('link', { name: 'Employees' })).toHaveAttribute('aria-current', 'page')
    routerMocks.pathname = '/dashboard'
    renderApp()
    expect(screen.getByRole('link', { name: 'Overview' })).toHaveAttribute('aria-current', 'page')
  })

  it('shows the employee-owned scorecard under My Work', async () => {
    routerMocks.pathname = '/hr/monthly-scorecard'
    renderShell({ monthly_scorecards: ['view_own'] })

    const scorecard = screen.getByRole('link', { name: 'My Scorecard' })
    expect(scorecard).toHaveAttribute('href', '/hr/monthly-scorecard')
    expect(scorecard).toHaveAttribute('aria-current', 'page')
    expect(screen.queryByRole('link', { name: 'Monthly Scorecard' })).not.toBeInTheDocument()
  })

  it('opens inline page search from Ctrl/Cmd+K and navigates to a permitted result', async () => {
    const user = userEvent.setup()
    renderShell({ employees: ['list'] })

    await user.keyboard('{Control>}k{/Control}')
    const search = within(screen.getByRole('dialog', { name: 'Workspace navigation' })).getByRole(
      'combobox',
      { name: 'Search pages' },
    )
    expect(search).toHaveFocus()
    await user.type(search, 'Employees')
    expect(screen.getByRole('listbox', { name: 'Matching workspace pages' })).toBeInTheDocument()
    await user.keyboard('{Enter}')

    expect(routerMocks.navigate).toHaveBeenCalledWith({ to: '/hr/employees' })
    expect(
      screen.queryByRole('listbox', { name: 'Matching workspace pages' }),
    ).not.toBeInTheDocument()
  })

  it('pins destinations and saves the collapsed sidebar preference', async () => {
    const user = userEvent.setup()
    renderShell({ employees: ['list'] })

    await user.click(screen.getByRole('button', { name: 'HR/Admin navigation group' }))

    const employees = screen.getByRole('link', { name: 'Employees' })
    fireEvent.focus(employees)
    await user.click(screen.getByRole('button', { name: 'Pin Employees' }))
    expect(screen.getAllByRole('button', { name: 'Unpin Employees' })).toHaveLength(2)
    expect(screen.getAllByRole('button', { name: 'Unpin Employees' })[0]).toHaveClass(
      'nav-pinned-toggle',
    )
    await waitFor(() =>
      expect(
        JSON.parse(localStorage.getItem('bomach.sidebar.preferences.v2') ?? '{}').pinnedPaths,
      ).toContain('/hr/employees'),
    )

    await user.click(screen.getByRole('button', { name: 'Collapse sidebar' }))
    await waitFor(() =>
      expect(
        JSON.parse(localStorage.getItem('bomach.sidebar.preferences.v2') ?? '{}').collapsed,
      ).toBe(true),
    )
    expect(screen.getByRole('button', { name: 'Expand sidebar' })).toBeInTheDocument()
  })

  it('temporarily expands a collapsed desktop sidebar on hover and closes it on leave', async () => {
    Object.defineProperty(window, 'matchMedia', {
      configurable: true,
      value: vi.fn().mockImplementation((query: string) => ({
        matches: query === '(min-width: 1100px)',
        media: query,
        onchange: null,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        addListener: vi.fn(),
        removeListener: vi.fn(),
        dispatchEvent: vi.fn(),
      })),
    })
    localStorage.setItem(
      'bomach.sidebar.preferences.v2',
      JSON.stringify({
        collapsed: true,
        expandedGroups: ['Dashboard'],
        expandedCategories: [],
        collapsedCategories: [],
      }),
    )
    renderShell({ employees: ['list'] })

    const sidebar = screen.getByRole('complementary')
    expect(screen.getByRole('button', { name: 'Expand sidebar' })).toBeInTheDocument()
    fireEvent.mouseEnter(sidebar)

    expect(screen.getByRole('button', { name: 'Keep sidebar expanded' })).toBeInTheDocument()
    expect(
      screen.getByRole('button', { name: 'My account navigation subgroup' }),
    ).toBeInTheDocument()
    await userEvent
      .setup()
      .click(screen.getByRole('button', { name: 'My account navigation subgroup' }))
    expect(screen.getByRole('link', { name: 'My profile' })).toBeInTheDocument()

    fireEvent.mouseLeave(sidebar)

    expect(screen.getByRole('button', { name: 'Expand sidebar' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'My profile' })).not.toBeInTheDocument()
  })

  it('lets the active navigation group collapse and remembers the choice', async () => {
    const user = userEvent.setup()
    renderShell({ employees: ['list'] })
    const dashboardGroup = screen.getByRole('button', { name: 'My Work navigation group' })

    expect(dashboardGroup).toHaveAttribute('aria-expanded', 'true')
    await user.click(dashboardGroup)

    expect(screen.getByRole('button', { name: 'My Work navigation group' })).toHaveAttribute(
      'aria-expanded',
      'false',
    )
    expect(screen.getByRole('link', { name: 'Overview' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'My profile' })).not.toBeInTheDocument()
    await waitFor(() =>
      expect(
        JSON.parse(localStorage.getItem('bomach.sidebar.preferences.v2') ?? '{}').collapsedGroups,
      ).toContain('Dashboard'),
    )
  })

  it('opens the mobile drawer, traps focus, and closes it with Escape restoring focus', async () => {
    const user = userEvent.setup()
    renderShell({ employees: ['list'] })
    const trigger = screen.getByRole('button', { name: 'Open navigation menu' })

    await user.click(trigger)
    const drawer = screen.getByRole('dialog', { name: 'Workspace navigation' })
    const close = within(drawer).getByRole('button', { name: 'Close navigation menu' })
    await waitFor(() => expect(close).toHaveFocus())
    expect(document.body.style.overflow).toBe('hidden')
    fireEvent.keyDown(close, { key: 'Tab', shiftKey: true })
    expect(
      within(drawer).getByRole('button', { name: 'Open profile for Staff User' }),
    ).toHaveFocus()
    fireEvent.keyDown(drawer, { key: 'Escape' })

    await waitFor(() =>
      expect(
        screen.queryByRole('dialog', { name: 'Workspace navigation' }),
      ).not.toBeInTheDocument(),
    )
    expect(document.body.style.overflow).toBe('')
    expect(trigger).toHaveFocus()

    await user.click(trigger)
    const backdrop = screen.getAllByRole('button', { name: 'Close navigation menu' })[0]!
    await user.click(backdrop)
    await waitFor(() =>
      expect(
        screen.queryByRole('dialog', { name: 'Workspace navigation' }),
      ).not.toBeInTheDocument(),
    )
    expect(trigger).toHaveFocus()
  })

  it('shows a permission-aware notification center and marks items read', async () => {
    const user = userEvent.setup()
    notificationMocks.list.mockResolvedValue({ items: [notification()], count: 1 })
    notificationMocks.stats.mockResolvedValue({ unread_count: 1 })
    renderShell({
      employees: ['list'],
      notifications: ['view', 'list', 'mark_read', 'mark_all_read'],
      leave_requests: ['list'],
    })

    const trigger = await screen.findByRole('button', { name: 'Notifications, 1 unread' })
    await user.click(trigger)
    expect(await screen.findByText('Leave request needs review')).toBeInTheDocument()

    const viewAll = screen.getByRole('button', { name: 'View all notifications' })
    expect(viewAll).toHaveClass('min-h-11', 'w-full')
    await user.click(viewAll)
    expect(routerMocks.navigate).toHaveBeenCalledWith({
      to: '/notifications',
      search: { filter: 'all' },
    })

    await user.click(trigger)
    const unreadFilter = screen.getByRole('button', { name: 'unread' })
    expect(unreadFilter).toHaveClass('min-h-10', 'min-w-10')
    const markRead = screen.getByRole('button', {
      name: 'Mark Leave request needs review as read',
    })
    expect(markRead).toHaveClass('size-10')
    await user.click(markRead)

    await waitFor(() =>
      expect(notificationApi.markRead).toHaveBeenCalledWith(81, expect.anything()),
    )
    expect(notificationApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ limit: 8, offset: 0 }),
    )
  })

  it('opens a notification directly from the bell preview without using View all', async () => {
    const user = userEvent.setup()
    notificationMocks.list.mockResolvedValue({ items: [notification()], count: 1 })
    notificationMocks.stats.mockResolvedValue({ unread_count: 1 })
    renderShell({
      employees: ['list'],
      notifications: ['view', 'list', 'mark_read'],
    })

    await user.click(await screen.findByRole('button', { name: 'Notifications' }))
    await user.click(
      await screen.findByRole('button', {
        name: 'View notification: Leave request needs review',
      }),
    )

    expect(routerMocks.navigate).toHaveBeenCalledWith({
      to: '/notifications/$notificationId',
      params: { notificationId: '81' },
      search: { filter: 'all' },
    })
  })

  it('uses the authorized related destination when detail permission is missing', async () => {
    const user = userEvent.setup()
    notificationMocks.list.mockResolvedValue({ items: [notification()], count: 1 })
    notificationMocks.stats.mockResolvedValue({ unread_count: 1 })
    renderShell({
      employees: ['list'],
      notifications: ['list', 'mark_read'],
      leave_requests: ['view_own'],
    })

    await user.click(await screen.findByRole('button', { name: 'Notifications' }))
    await user.click(
      await screen.findByRole('button', {
        name: 'Open leave request: Leave request needs review',
      }),
    )

    await waitFor(() => expect(routerMocks.navigate).toHaveBeenCalledWith({ to: '/hr/leaves/81' }))
  })

  it('offers the named destination beside notification details in the bell preview', async () => {
    const user = userEvent.setup()
    notificationMocks.list.mockResolvedValue({ items: [notification()], count: 1 })
    notificationMocks.stats.mockResolvedValue({ unread_count: 1 })
    renderShell({
      employees: ['list'],
      notifications: ['view', 'list', 'mark_read'],
      leave_requests: ['view_own'],
    })

    await user.click(await screen.findByRole('button', { name: 'Notifications, 1 unread' }))
    await user.click(
      await screen.findByRole('button', {
        name: 'Open leave request: Leave request needs review',
      }),
    )

    await waitFor(() => expect(routerMocks.navigate).toHaveBeenCalledWith({ to: '/hr/leaves/81' }))
  })

  it('does not report zero unread notifications when the count request fails', async () => {
    const user = userEvent.setup()
    notificationMocks.stats.mockRejectedValue(new Error('Count unavailable'))
    renderShell({
      employees: ['list'],
      notifications: ['view', 'list'],
    })

    await user.click(await screen.findByRole('button', { name: 'Notifications' }))

    expect(await screen.findByText('Unread count unavailable')).toBeInTheDocument()
    expect(screen.queryByText('You are all caught up')).not.toBeInTheDocument()
  })

  it('hides notifications when the account cannot list them', () => {
    renderShell({ employees: ['list'] })
    expect(screen.queryByRole('button', { name: /^Notifications/ })).not.toBeInTheDocument()
  })

  it('opens account details and requires confirmation before signing out', async () => {
    const user = userEvent.setup()
    const { queryClient } = renderShell({ employees: ['list'] })
    queryClient.setQueryData(['private'], { value: 1 })

    await user.click(screen.getByRole('button', { name: 'Open profile for Staff User' }))
    expect(screen.getByRole('dialog', { name: 'Your profile' })).toBeInTheDocument()
    expect(
      within(screen.getByRole('dialog', { name: 'Your profile' })).getByRole('link', {
        name: 'View full profile',
      }),
    ).toHaveAttribute('href', '/dashboard/my-profile')
    expect(
      within(screen.getByRole('dialog', { name: 'Your profile' })).queryByText(
        'Two-factor authentication',
      ),
    ).not.toBeInTheDocument()
    await user.click(
      within(screen.getByRole('dialog', { name: 'Your profile' })).getByRole('button', {
        name: 'Sign out',
      }),
    )
    const confirm = screen.getByRole('dialog', { name: 'Sign out of Bomach OS?' })
    expect(confirm).toBeInTheDocument()
    await user.click(within(confirm).getByRole('button', { name: 'Sign out' }))

    await waitFor(() => expect(authApi.logout).toHaveBeenCalledOnce())
    expect(queryClient.getQueryData(['private'])).toBeUndefined()
    expect(routerMocks.navigate).toHaveBeenCalledWith({ to: '/login' })
  })
})
