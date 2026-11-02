import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routerState = vi.hoisted(() => ({
  search: {
    search: '',
    userId: '',
    auditType: '',
    auditStatus: '',
    startDate: '',
    endDate: '',
    page: 1,
  },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({ to, children, ...props }: { to: string; children: React.ReactNode }) => (
      <a href={to} {...props}>
        {children}
      </a>
    ),
    useSearch: () => routerState.search,
    useNavigate: () => routerState.navigate,
  }
})

import { auditLogApi, auditLogQueryKeys, type AuditLogDto } from '@/modules/company/audit-log.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { AuditLogPage } from './audit-log-page'

const logFixture: AuditLogDto = {
  id: 9,
  activity: 'Two-factor verification failed for account.',
  audit_type: 'two_factor_failed',
  audit_type_display: '2FA Code Failed',
  audit_status: 'warning',
  audit_status_display: 'Warning',
  ip_address: '192.0.2.44',
  metadata: null,
  user: { id: 42, email: 'qa.audit@example.test', full_name: 'QA Audit Reviewer' },
  created_at: '2026-10-23T09:15:00Z',
  updated_at: '2026-10-23T09:15:00Z',
}

const makeSession = (permissions: AuthenticatedSession['permissions']): AuthenticatedSession => ({
  user: {
    id: 7,
    email: 'reviewer@example.com',
    username: 'reviewer',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions,
  },
  employee: {
    user_id: 7,
    employee_id: 'EMP-007',
    username: 'reviewer',
    email: 'reviewer@example.com',
  },
  roles: [],
  permissions,
})

let queryClient: QueryClient

function renderPage(permissions: AuthenticatedSession['permissions']) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession(permissions))
  return render(
    <ToastContext.Provider value={{ showToast: vi.fn(), dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <AuditLogPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

async function selectAuditDate(
  user: ReturnType<typeof userEvent.setup>,
  label: string,
  value: string,
) {
  const [year, month, day] = value.split('-').map(Number)
  const date = new Date(year, month - 1, day)
  const monthLabel = new Intl.DateTimeFormat(undefined, { month: 'long' }).format(date)
  const dateLabel = new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  }).format(date)

  await user.click(screen.getByRole('button', { name: label }))
  const calendar = screen.getByRole('dialog', { name: 'Choose a date' })
  await user.click(within(calendar).getByRole('combobox', { name: 'Month' }))
  await user.click(await screen.findByRole('option', { name: monthLabel }))
  await user.click(within(calendar).getByRole('combobox', { name: 'Year' }))
  await user.click(await screen.findByRole('option', { name: String(year) }))
  await user.click(within(calendar).getByRole('button', { name: dateLabel }))
}

describe('Audit Log page', () => {
  beforeEach(() => {
    routerState.search = {
      search: '',
      userId: '',
      auditType: '',
      auditStatus: '',
      startDate: '',
      endDate: '',
      page: 1,
    }
    routerState.navigate.mockReset()
    vi.spyOn(auditLogApi, 'list').mockResolvedValue({ count: 1, items: [logFixture] })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows recorded actor, activity, type, status, IP address, and timestamp', async () => {
    renderPage({ audit_logs: ['list'] })

    expect(await screen.findAllByText(logFixture.activity)).not.toHaveLength(0)
    expect(screen.getAllByText('QA Audit Reviewer').length).toBeGreaterThan(0)
    expect(screen.getAllByText('192.0.2.44').length).toBeGreaterThan(0)
    const table = document.querySelector('table')
    expect(table).not.toBeNull()
    expect(within(table!).getByText('192.0.2.44').closest('td')).toHaveClass('whitespace-nowrap')
    expect(screen.getAllByText('2FA Code Failed').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Warning').length).toBeGreaterThan(0)
  })

  it('separates the register, filters, and event history into a clear hierarchy', async () => {
    renderPage({ audit_logs: ['list'] })

    expect(await screen.findByRole('heading', { name: 'Activity register' })).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Filter activity' })).toBeInTheDocument()
    await screen.findByRole('article')
    expect(screen.getByRole('heading', { name: 'Recorded activity' })).toBeInTheDocument()

    const event = screen.getByRole('article')
    expect(event).toHaveClass('group')
    expect(event).not.toHaveClass('shadow-elevation-sm')
    expect(within(event).getByRole('heading', { name: logFixture.activity })).toBeInTheDocument()
    expect(within(event).getByText('2FA Code Failed')).toBeInTheDocument()
    expect(within(event).getByText('Warning')).toBeInTheDocument()
    expect(within(event).getByText('QA Audit Reviewer')).toBeInTheDocument()
    expect(within(event).getByText('192.0.2.44')).toBeInTheDocument()
  })

  it('uses the shared date picker and omits the page-header refresh action', async () => {
    renderPage({ audit_logs: ['list'] })
    await screen.findAllByText(logFixture.activity)

    expect(screen.getByRole('button', { name: 'From date' })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    expect(screen.getByRole('button', { name: 'To date' })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()
  })

  it('keeps the compact card layout until the audit table has enough room', async () => {
    renderPage({ audit_logs: ['list'] })
    await screen.findAllByText(logFixture.activity)

    const table = document.querySelector('table')
    expect(table?.parentElement).toHaveClass('min-[1200px]:block')
    expect(screen.getAllByRole('article')[0]?.parentElement).toHaveClass('min-[1200px]:hidden')
  })

  it('submits server-supported filters to shareable URL state and resets to page one', async () => {
    const user = userEvent.setup()
    routerState.search.page = 4
    renderPage({ audit_logs: ['list'] })
    await screen.findAllByText(logFixture.activity)

    await user.type(screen.getByRole('textbox', { name: 'Search activity' }), 'device')
    await user.type(screen.getByRole('spinbutton', { name: 'User ID' }), '42')
    await user.click(screen.getByRole('combobox', { name: 'Filter by audit status' }))
    await user.click(await screen.findByRole('option', { name: 'Warning' }))
    await selectAuditDate(user, 'From date', '2026-10-23')
    await selectAuditDate(user, 'To date', '2026-10-23')
    await user.click(screen.getByRole('button', { name: 'Apply filters' }))

    const options = routerState.navigate.mock.calls.at(-1)?.[0]
    expect(options).toEqual(
      expect.objectContaining({ to: '/company/audit-log', search: expect.any(Function) }),
    )
    expect(options.search(routerState.search)).toEqual(
      expect.objectContaining({
        search: 'device',
        userId: '42',
        auditStatus: 'warning',
        startDate: '2026-10-23',
        endDate: '2026-10-23',
        page: 1,
      }),
    )
  })

  it('prevents applying a reversed date range and explains how to fix it', async () => {
    routerState.search.startDate = '2026-10-24'
    routerState.search.endDate = '2026-10-23'
    renderPage({ audit_logs: ['list'] })
    await screen.findAllByText(logFixture.activity)
    expect(screen.getByText(/End date must be the same as or later/)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Apply filters' })).toBeDisabled()
  })

  it('shows a recoverable error when the first request fails', async () => {
    vi.spyOn(auditLogApi, 'list').mockRejectedValueOnce(new Error('backend unavailable'))
    renderPage({ audit_logs: ['list'] })

    expect(await screen.findByRole('button', { name: 'Try again' })).toBeInTheDocument()
  })

  it('keeps cached rows visible and offers retry after refresh failure', async () => {
    const list = vi
      .spyOn(auditLogApi, 'list')
      .mockResolvedValueOnce({ count: 1, items: [logFixture] })
      .mockRejectedValueOnce(new Error('offline'))
    renderPage({ audit_logs: ['list'] })
    await screen.findAllByText(logFixture.activity)
    await queryClient.invalidateQueries({
      queryKey: auditLogQueryKeys.scoped(7, 'EMP-007'),
    })

    expect(await screen.findByText('Showing saved audit events')).toBeInTheDocument()
    expect(screen.getAllByText(logFixture.activity)).not.toHaveLength(0)
    expect(
      within(screen.getByRole('status')).getByRole('button', { name: 'Retry' }),
    ).toBeInTheDocument()
    expect(list).toHaveBeenCalledTimes(2)
  })

  it('distinguishes a true empty result from an unavailable endpoint', async () => {
    vi.spyOn(auditLogApi, 'list').mockResolvedValueOnce({ count: 0, items: [] })
    renderPage({ audit_logs: ['list'] })
    expect(await screen.findByText('No audit events recorded')).toBeInTheDocument()
  })

  it('does not request log data without list permission', () => {
    const list = vi.spyOn(auditLogApi, 'list')
    renderPage({})
    expect(screen.getByText('You can’t view the Audit Log')).toBeInTheDocument()
    expect(list).not.toHaveBeenCalled()
  })
})
