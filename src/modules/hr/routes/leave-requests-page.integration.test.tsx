import { createElement, useState, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { search: '', status: 'all', kind: 'all', page: 1, pageSize: 10 },
  navigate: vi.fn(),
  navigateFrom: '',
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    useSearch: () => routeState.search,
    useNavigate: ({ from }: { from?: string } = {}) => {
      routeState.navigateFrom = from ?? ''
      return routeState.navigate
    },
  }
})

import { hrLeaveRequestsApi, type HRLeaveRequest } from '@/modules/hr/leave-requests.api'
import { validateHRLeaveRequestsSearch } from '@/modules/hr/leave-requests.search'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'

import { LeaveRequestsPage } from './leave-requests-page'

const showToast = vi.fn()
let queryClient: QueryClient

const request: HRLeaveRequest = {
  id: 64,
  employeeId: 23,
  employeeName: 'Amina Ademola',
  employeeCode: 'EMP-023',
  branchName: 'Lagos HQ',
  requestKind: 'leave',
  leaveType: 'annual_leave',
  startDate: '2026-11-02',
  endDate: '2026-11-04',
  reason: 'Family commitment',
  status: 'pending',
  approverId: null,
  approverName: null,
  approvalDate: null,
  rejectionReason: null,
  durationDays: 3,
  createdAt: '2026-10-26T09:00:00Z',
  updatedAt: '2026-10-26T09:00:00Z',
}

const requestFixtures: HRLeaveRequest[] = [
  request,
  {
    ...request,
    id: 65,
    employeeId: 24,
    employeeName: 'Amara Chukwuemeka-Okwu',
    employeeCode: 'QA-20261030-HR-LEAVE-EDGE-001',
    branchName: 'Port Harcourt Regional Operations Office',
    startDate: '2026-11-06',
    endDate: '2026-11-07',
    reason:
      'I am requesting two days away to attend to a family commitment. I have coordinated the handover of my current work and shared the relevant updates with my team.',
    status: 'approved',
    leaveType: 'annual_leave',
    durationDays: 2,
  },
  {
    ...request,
    id: 66,
    employeeId: 25,
    employeeName: 'Nneka Okafor',
    employeeCode: 'QA-20261030-LEAVE-002',
    branchName: 'Abuja',
    requestKind: 'absence',
    leaveType: '',
    startDate: '2026-10-24',
    endDate: '2026-10-24',
    reason:
      'I was unable to attend work due to an urgent personal matter and am submitting this record for review.',
    status: 'pending',
    durationDays: 1,
  },
  {
    ...request,
    id: 67,
    employeeId: 26,
    employeeName: 'Ifeanyi Bello',
    employeeCode: 'QA-20261030-LEAVE-003',
    branchName: 'Enugu',
    requestKind: 'running_late',
    leaveType: '',
    startDate: '2026-10-22',
    endDate: '2026-10-22',
    reason:
      'Unexpected traffic and a delay on my route affected my arrival time. I have submitted this report for review.',
    status: 'rejected',
    durationDays: 0,
    rejectionReason: 'Please include the expected arrival time.',
  },
  {
    ...request,
    id: 68,
    employeeId: 27,
    employeeName: 'Tomi Akinwale',
    employeeCode: 'QA-20261030-LEAVE-004',
    branchName: 'Lagos',
    leaveType: 'maternity_leave',
    startDate: '2026-12-01',
    endDate: '2026-12-12',
    reason:
      'I am requesting annual leave during the planned school break and will hand over open work before my leave starts.',
    status: 'pending',
    durationDays: 12,
  },
  {
    ...request,
    id: 69,
    employeeId: 28,
    employeeName: 'Dara Eze',
    employeeCode: 'QA-20261030-LEAVE-005',
    branchName: null,
    leaveType: 'casual_leave',
    startDate: '2026-10-18',
    endDate: '2026-10-18',
    reason: 'I no longer need this leave because the appointment has been rescheduled.',
    status: 'cancelled',
    durationDays: 1,
  },
  {
    ...request,
    id: 70,
    employeeId: 29,
    employeeName: 'Musa Yakubu',
    employeeCode: 'QA-20261030-LEAVE-006',
    branchName: 'Kano',
    leaveType: 'sick_leave',
    startDate: '2026-10-12',
    endDate: '2026-10-14',
    reason: 'I needed time away to attend a scheduled medical appointment.',
    status: 'approved',
    durationDays: 3,
    approverId: 19,
    approverName: 'Test Admin',
    approvalDate: '2026-10-10',
  },
  {
    ...request,
    id: 71,
    employeeId: 30,
    employeeName: 'Zainab Musa',
    employeeCode: 'QA-20261030-LEAVE-007',
    branchName: 'Lagos',
    leaveType: 'compassionate_leave',
    startDate: '2026-11-16',
    endDate: '2026-11-17',
    reason: 'I am requesting two days of annual leave for a family commitment.',
    status: 'pending',
    durationDays: 2,
  },
  {
    ...request,
    id: 72,
    employeeId: 19,
    employeeName: 'HR Admin',
    employeeCode: 'EMP-009',
    branchName: 'Lagos HQ',
    leaveType: 'unpaid_leave',
    startDate: '2026-12-21',
    endDate: '2026-12-22',
    reason: 'I am requesting two days away to attend to a family commitment.',
    status: 'pending',
    durationDays: 2,
  },
  {
    ...request,
    id: 73,
    employeeId: 31,
    employeeName: 'Kehinde Adebayo',
    employeeCode: 'QA-20261030-LEAVE-009',
    branchName: 'Enugu',
    requestKind: 'absence',
    leaveType: '',
    startDate: '2026-10-06',
    endDate: '2026-10-06',
    reason:
      'I was unable to attend work due to a family emergency and am submitting this record for review.',
    status: 'rejected',
    durationDays: 1,
    rejectionReason: 'Please provide the supporting information required for review.',
  },
]

const summary = {
  total: 1,
  pending: 1,
  approved: 0,
  approved_this_month: 0,
  on_leave: 0,
  rejected: 0,
  cancelled: 0,
  leave: 1,
  absence: 0,
  running_late: 0,
}

const permissions = {
  leave_requests: ['list', 'view', 'create', 'update', 'approve', 'reject'],
}

const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'hr-admin@example.test',
    username: 'hr-admin',
    first_name: 'HR',
    last_name: 'Admin',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions,
  },
  employee: {
    id: 19,
    user_id: 9,
    employee_id: 'EMP-009',
    username: 'hr-admin',
    email: 'hr-admin@example.test',
    first_name: 'HR',
    last_name: 'Admin',
  },
  roles: [],
  permissions,
}

function renderLeaveRequests(
  path = '/hr/leave-request?search=&status=all&kind=all&page=1&pageSize=10',
) {
  queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
  const query = new URLSearchParams(path.split('?')[1])
  routeState.search = validateHRLeaveRequestsSearch(Object.fromEntries(query.entries()))

  function PageHarness() {
    const [search, setSearch] = useState(routeState.search)
    routeState.search = search
    routeState.navigate = vi.fn(
      ({ search: update }: { search: (previous: typeof search) => typeof search }) => {
        setSearch((previous) => update(previous))
      },
    )
    return <LeaveRequestsPage />
  }

  return render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(
        ToastContext.Provider,
        { value: { showToast, dismissToast: vi.fn() } },
        createElement(PageHarness),
      ),
    ) as ReactNode,
  )
}

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

beforeEach(() => {
  routeState.navigateFrom = ''
  vi.spyOn(hrLeaveRequestsApi, 'list').mockResolvedValue({
    count: requestFixtures.length + 3,
    items: requestFixtures,
  })
  vi.spyOn(hrLeaveRequestsApi, 'summary').mockResolvedValue(summary)
  vi.spyOn(hrLeaveRequestsApi, 'detail').mockResolvedValue(request)
  vi.spyOn(hrLeaveRequestsApi, 'update').mockResolvedValue({
    ...request,
    reason: 'Updated family commitment',
  })
  vi.spyOn(hrLeaveRequestsApi, 'review').mockResolvedValue({
    ...request,
    status: 'rejected',
    rejectionReason: 'Resourcing conflict',
  })
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
  showToast.mockReset()
})

describe('Leave Requests page', () => {
  it('opens the pending review queue when no status filter is specified', async () => {
    renderLeaveRequests('/hr/leave-request')

    expect(routeState.search.status).toBe('pending')
    expect(await screen.findByRole('combobox', { name: 'Status' })).toHaveTextContent(
      'Pending review',
    )
    await screen.findAllByRole('article')
    expect(hrLeaveRequestsApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'pending' }),
      expect.any(AbortSignal),
    )
  })

  it('clears leave-request filters back to the pending review queue', async () => {
    const user = userEvent.setup()
    renderLeaveRequests('/hr/leave-request?search=Amina&status=all&kind=leave&page=2')

    await screen.findAllByRole('article')
    await user.click(screen.getByRole('button', { name: 'Clear' }))

    await waitFor(() => {
      expect(routeState.search).toMatchObject({
        search: '',
        kind: 'all',
        status: 'pending',
        page: 1,
      })
    })
  })

  it('does not expose employee self-service submission in the HR register', async () => {
    renderLeaveRequests()

    await screen.findAllByRole('article')
    expect(screen.queryByRole('button', { name: /Submit my request/i })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: /New request/i })).not.toBeInTheDocument()
  })

  it('keeps request details on the public route and records its query deep link', async () => {
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    await user.click(within(card).getByRole('button', { name: 'Details' }))

    await waitFor(() => expect(routeState.search).toHaveProperty('request_id', request.id))
    expect(routeState.navigateFrom).toBe('/hr/leave-request')
  })

  it('moves secondary card actions into a compact menu below the tablet breakpoint', async () => {
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    expect(within(card).getByRole('button', { name: 'Details' })).toBeVisible()
    expect(within(card).getByRole('button', { name: 'Approve' }).parentElement).toHaveClass(
      'hidden',
      'tablet:flex',
    )

    const moreActions = within(card).getByRole('button', {
      name: 'More actions for request #64',
    })
    expect(moreActions.parentElement).toHaveClass('tablet:hidden')
    await user.click(moreActions)

    const menu = await screen.findByRole('menu', { name: 'Actions for request #64' })
    expect(within(menu).getByRole('menuitem', { name: 'Approve' })).toBeVisible()
    expect(within(menu).getByRole('menuitem', { name: 'Reject' })).toBeVisible()
    expect(within(menu).getByRole('menuitem', { name: 'Edit' })).toBeVisible()
    await user.click(within(menu).getByRole('menuitem', { name: 'Approve' }))

    expect(await screen.findByRole('dialog', { name: 'Approve request?' })).toBeVisible()
    expect(hrLeaveRequestsApi.review).not.toHaveBeenCalled()
  })

  it('renders mixed synthetic request data and wraps long employee details safely', async () => {
    renderLeaveRequests()

    expect((await screen.findAllByText('Annual leave')).length).toBeGreaterThan(1)
    expect(screen.getByText('Amina Ademola')).toBeVisible()
    expect(screen.getByText('EMP-023')).toBeVisible()
    expect(screen.getAllByText('Lagos HQ').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Requested dates').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Employee reason').length).toBeGreaterThan(0)
    expect(screen.queryByText(/synthetic fixture/i)).not.toBeInTheDocument()
    expect(screen.getByText('Port Harcourt Regional Operations Office')).toBeVisible()
    expect(screen.getByText('1–10 of 13')).toBeVisible()
    expect(screen.getByRole('button', { name: 'Next' })).toBeEnabled()
  })

  it('submits the employee search from the inline accessible search action', async () => {
    const user = userEvent.setup()
    renderLeaveRequests()

    await screen.findAllByRole('article')
    await user.type(screen.getByRole('searchbox', { name: 'Find employee' }), 'Amina')
    await user.click(screen.getByRole('button', { name: 'Search' }))

    await waitFor(() => expect(routeState.search.search).toBe('Amina'))
    expect(routeState.search.page).toBe(1)
  })

  it('prevents self-review and makes the restriction clear in request details', async () => {
    const ownRequest = { ...request, employeeId: 19, employeeName: 'HR Admin' }
    vi.mocked(hrLeaveRequestsApi.list).mockResolvedValue({ count: 1, items: [ownRequest] })
    vi.mocked(hrLeaveRequestsApi.detail).mockResolvedValue(ownRequest)
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    expect(within(card).queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument()
    expect(within(card).queryByRole('button', { name: 'Reject' })).not.toBeInTheDocument()
    await user.click(within(card).getByRole('button', { name: 'Details' }))

    expect(await screen.findByText('Self-review is not allowed')).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Reject' })).not.toBeInTheDocument()
  })

  it('lets an authorized manager edit another employee’s pending leave in the HR form', async () => {
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    await user.click(within(card).getByRole('button', { name: 'Edit' }))

    expect(await screen.findByRole('dialog', { name: 'Edit employee request' })).toBeVisible()
    expect(screen.getByText(/Update Amina Ademola’s pending annual leave request/)).toBeVisible()
    await user.clear(screen.getByRole('textbox', { name: 'Reason' }))
    await user.type(screen.getByRole('textbox', { name: 'Reason' }), 'Updated family commitment')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(hrLeaveRequestsApi.update).toHaveBeenCalledWith(64, {
        leave_type: 'annual_leave',
        start_date: '2026-11-02',
        end_date: '2026-11-04',
        reason: 'Updated family commitment',
      }),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Request updated', tone: 'success' }),
    )
  })

  it('shows only absence fields when editing an employee absence request', async () => {
    const user = userEvent.setup()
    renderLeaveRequests()

    const cards = await screen.findAllByRole('article')
    const absenceCard = cards.find((card) => card.textContent?.includes('Nneka Okafor'))
    expect(absenceCard).toBeDefined()
    await user.click(within(absenceCard!).getByRole('button', { name: 'Edit' }))

    const dialog = await screen.findByRole('dialog', { name: 'Edit employee request' })
    expect(dialog).toBeVisible()
    expect(within(dialog).getByRole('combobox', { name: 'Request type' })).toHaveTextContent(
      'Absence',
    )
    expect(within(dialog).queryByRole('combobox', { name: 'Leave type' })).not.toBeInTheDocument()
    expect(within(dialog).getByRole('textbox', { name: 'Reason' })).toHaveValue(
      requestFixtures[2].reason,
    )
  })

  it('keeps own, running-late, and decided requests out of the HR edit flow', async () => {
    const ownPending = { ...request, id: 72, employeeId: 19, employeeName: 'HR Admin' }
    const pendingLate = {
      ...request,
      id: 73,
      employeeId: 26,
      requestKind: 'running_late' as const,
      leaveType: '',
    }
    vi.mocked(hrLeaveRequestsApi.list).mockResolvedValueOnce({
      count: 3,
      items: [ownPending, pendingLate, { ...request, id: 74, status: 'approved' }],
    })
    renderLeaveRequests()

    const cards = await screen.findAllByRole('article')
    expect(within(cards[0]).queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
    expect(within(cards[1]).queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
    expect(within(cards[2]).queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
  })

  it('preserves the HR edit form and reports an update failure', async () => {
    vi.mocked(hrLeaveRequestsApi.update).mockRejectedValueOnce(
      new ApiError('The request changed.', { status: 409 }),
    )
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    await user.click(within(card).getByRole('button', { name: 'Edit' }))
    const reason = await screen.findByRole('textbox', { name: 'Reason' })
    await user.clear(reason)
    await user.type(reason, 'Updated family commitment')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Refresh the latest information')
    expect(reason).toHaveValue('Updated family commitment')
  })

  it('requires a rejection reason, preserves it after API failure, and succeeds on retry', async () => {
    vi.mocked(hrLeaveRequestsApi.review)
      .mockRejectedValueOnce(new ApiError('The request changed.', { status: 409 }))
      .mockResolvedValueOnce({
        ...request,
        status: 'rejected',
        rejectionReason: 'Resourcing conflict',
      })
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    await user.click(within(card).getByRole('button', { name: 'Reject' }))
    const rejectionDialog = screen.getByRole('dialog')
    expect(rejectionDialog.children[1]).toHaveClass('flex-auto')
    expect(rejectionDialog).toHaveClass('max-h-[calc(100dvh-2rem)]')
    await user.click(screen.getByRole('button', { name: 'Confirm rejection' }))
    expect(
      await screen.findByText('Enter a rejection reason of at least 3 characters.'),
    ).toBeVisible()
    expect(hrLeaveRequestsApi.review).not.toHaveBeenCalled()

    await user.type(screen.getByLabelText(/Reason for rejection/), 'Resourcing conflict')
    await user.click(screen.getByRole('button', { name: 'Confirm rejection' }))
    expect(
      await screen.findByText('Refresh the latest information before trying again.'),
    ).toBeVisible()
    expect(hrLeaveRequestsApi.review).toHaveBeenCalledWith(64, 'rejected', 'Resourcing conflict')

    await user.click(screen.getByRole('button', { name: 'Confirm rejection' }))
    await waitFor(() => expect(hrLeaveRequestsApi.review).toHaveBeenCalledTimes(2))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Request rejected', tone: 'success' }),
    )
  })

  it('records a successful approval and shows confirmation feedback', async () => {
    vi.mocked(hrLeaveRequestsApi.review).mockResolvedValue({ ...request, status: 'approved' })
    const user = userEvent.setup()
    renderLeaveRequests()

    const [card] = await screen.findAllByRole('article')
    await user.click(within(card).getByRole('button', { name: 'Approve' }))
    await user.click(screen.getByRole('button', { name: 'Confirm approval' }))

    await waitFor(() =>
      expect(hrLeaveRequestsApi.review).toHaveBeenCalledWith(64, 'approved', undefined),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Request approved', tone: 'success' }),
    )
  })
})
