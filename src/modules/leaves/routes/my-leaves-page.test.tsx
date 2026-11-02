import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { kind: 'all', status: 'all', page: 1 },
  params: { requestId: '77' },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({ to, children, className }: { to: string; children: ReactNode; className?: string }) =>
      createElement('a', { href: to, className }, children),
    useSearch: () => routeState.search,
    useNavigate: () => routeState.navigate,
    useParams: () => routeState.params,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { leaveRequestsApi, type LeaveRequest } from '../leaves.api'
import { LeaveRequestDetailPage, MyLeavesPage } from './my-leaves-page'

const session: AuthenticatedSession = {
  user: {
    id: 7,
    email: 'staff@example.com',
    username: 'staff',
    first_name: 'Sam',
    last_name: 'Staff',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    id: 23,
    user_id: 7,
    employee_id: 'EMP-007',
    username: 'staff',
    email: 'staff@example.com',
    first_name: 'Sam',
    last_name: 'Staff',
  },
  roles: [],
  permissions: { leave_requests: ['list_own', 'view_own', 'create', 'update_own', 'delete_own'] },
}

const rejectedRequest: LeaveRequest = {
  id: 77,
  employeeId: 23,
  requestKind: 'leave',
  leaveType: 'annual_leave',
  startDate: '2026-11-04',
  endDate: '2026-11-06',
  reason: 'Family travel and rest.',
  status: 'rejected',
  approverName: 'Alex Reviewer',
  approvalDate: '2026-10-20',
  rejectionReason: 'Please select dates within your available balance.',
  durationDays: 3,
  createdAt: '2026-10-19T08:00:00Z',
  updatedAt: '2026-10-20T08:00:00Z',
}

let queryClient: QueryClient
const showToast = vi.fn()

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

function renderPage(page: ReactNode, permissions = session.permissions) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>{page}</QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('My Leaves pages', () => {
  beforeEach(() => {
    routeState.search = { kind: 'all', status: 'all', page: 1 }
    routeState.params = { requestId: '77' }
    routeState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(leaveRequestsApi, 'list').mockResolvedValue({ count: 1, items: [rejectedRequest] })
    vi.spyOn(leaveRequestsApi, 'stats').mockResolvedValue({
      employee_id: 23,
      total: 1,
      pending: 0,
      approved: 0,
      rejected: 1,
      cancelled: 0,
      leave: 1,
      absence: 0,
      running_late: 0,
    })
    vi.spyOn(leaveRequestsApi, 'detail').mockResolvedValue(rejectedRequest)
    vi.spyOn(leaveRequestsApi, 'create').mockResolvedValue({
      ...rejectedRequest,
      id: 78,
      status: 'pending',
      rejectionReason: null,
    })
    vi.spyOn(leaveRequestsApi, 'update').mockResolvedValue({
      ...rejectedRequest,
      status: 'pending',
    })
    vi.spyOn(leaveRequestsApi, 'cancel').mockResolvedValue({ detail: 'Cancelled' })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows the personal request register using the signed-in employee id', async () => {
    renderPage(<MyLeavesPage />)

    expect((await screen.findAllByText('Annual leave')).length).toBeGreaterThan(0)
    await waitFor(() =>
      expect(leaveRequestsApi.list).toHaveBeenCalledWith(
        expect.objectContaining({
          employeeId: 23,
          kind: 'all',
          status: 'all',
          limit: 10,
          offset: 0,
        }),
        expect.any(AbortSignal),
      ),
    )
  })

  it('keeps filter changes in URL state and returns pagination to the first page', async () => {
    const user = userEvent.setup()
    routeState.search.page = 3
    renderPage(<MyLeavesPage />)
    await screen.findByRole('heading', { name: 'Request history' })

    await user.click(await screen.findByRole('button', { name: 'Needs attention: 1' }))
    const navigation = routeState.navigate.mock.calls.at(-1)?.[0]
    expect(navigation.to).toBe('/hr/leaves')
    expect(navigation.search(routeState.search)).toMatchObject({ status: 'rejected', page: 1 })
  })

  it('opens a prefilled new request from a rejected record and preserves the rejected entry', async () => {
    const user = userEvent.setup()
    renderPage(<LeaveRequestDetailPage />)
    expect(await screen.findByText(rejectedRequest.rejectionReason!)).toBeInTheDocument()
    expect(screen.getByText('3 calendar days')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Request again' }))
    expect(screen.getByRole('dialog', { name: 'Request again' })).toBeInTheDocument()
    expect(screen.getByRole('combobox', { name: /Leave type/ })).toHaveTextContent('Annual leave')
    expect(screen.getByText('November 4, 2026')).toBeInTheDocument()
    expect(screen.getByText('November 6, 2026')).toBeInTheDocument()
    expect(screen.getByLabelText(/Reason/)).toHaveValue(rejectedRequest.reason)

    await user.click(screen.getByRole('button', { name: 'Submit request' }))
    await waitFor(() =>
      expect(leaveRequestsApi.create).toHaveBeenCalledWith(
        {
          request_kind: 'leave',
          leave_type: 'annual_leave',
          start_date: '2026-11-04',
          end_date: '2026-11-06',
          reason: rejectedRequest.reason,
        },
        expect.anything(),
      ),
    )
    expect(leaveRequestsApi.update).not.toHaveBeenCalled()
    expect(routeState.navigate).toHaveBeenCalledWith(
      expect.objectContaining({ to: '/hr/leaves/$requestId', params: { requestId: '78' } }),
    )
  })

  it('reopens the rejected-request form with a fresh copy of the original request', async () => {
    const user = userEvent.setup()
    renderPage(<LeaveRequestDetailPage />)
    await screen.findByText(rejectedRequest.rejectionReason!)

    await user.click(screen.getByRole('button', { name: 'Request again' }))
    expect(screen.getByRole('dialog', { name: 'Request again' })).toBeInTheDocument()
    const reason = screen.getByRole('textbox', { name: 'Reason' })
    await user.clear(reason)
    await user.type(reason, 'A corrected reason.')
    await user.click(screen.getByRole('button', { name: 'Cancel' }))

    await user.click(screen.getByRole('button', { name: 'Request again' }))
    expect(screen.getByRole('dialog', { name: 'Request again' })).toBeInTheDocument()
    expect(screen.getByRole('textbox', { name: 'Reason' })).toHaveValue(rejectedRequest.reason)
    expect(screen.getByRole('combobox', { name: /Leave type/ })).toHaveTextContent('Annual leave')
  })

  it('edits a same-day late-arrival request without sending replacement dates', async () => {
    const user = userEvent.setup()
    const today = new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Africa/Lagos',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date())
    const lateRequest: LeaveRequest = {
      ...rejectedRequest,
      requestKind: 'running_late',
      leaveType: '',
      startDate: today,
      endDate: today,
      status: 'pending',
      reason: 'Traffic delayed my arrival.',
      rejectionReason: null,
    }
    vi.spyOn(leaveRequestsApi, 'detail').mockResolvedValue(lateRequest)

    renderPage(<LeaveRequestDetailPage />)
    await screen.findByText('Traffic delayed my arrival.')
    await user.click(screen.getByRole('button', { name: 'Edit request' }))
    const reason = screen.getByRole('textbox', { name: 'Reason' })
    await user.clear(reason)
    await user.type(reason, 'The bus had a mechanical issue.')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(leaveRequestsApi.update).toHaveBeenCalledWith(77, {
        reason: 'The bus had a mechanical issue.',
      }),
    )
  })

  it('prevents the request register from loading without its leave permission', () => {
    renderPage(<MyLeavesPage />, {})
    expect(screen.getByText('You can’t view these requests')).toBeInTheDocument()
    expect(leaveRequestsApi.list).not.toHaveBeenCalled()
  })

  it('keeps request history available when summary permission is not granted', async () => {
    renderPage(<MyLeavesPage />, { leave_requests: ['list_own'] })

    expect(await screen.findByRole('heading', { name: 'Request history' })).toBeInTheDocument()
    expect(
      await screen.findByText(
        'Your account can view request history but cannot view request summary counts.',
      ),
    ).toBeInTheDocument()
    expect(leaveRequestsApi.list).toHaveBeenCalled()
    expect(leaveRequestsApi.stats).not.toHaveBeenCalled()
  })
})
