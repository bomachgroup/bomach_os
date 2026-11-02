import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { act, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routerState = vi.hoisted(() => ({
  search: { status: 'all', search: '', page: 1 },
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

import {
  approvalRequestsApi,
  approvalRequestsQueryKeys,
  companyOverviewQueryKey,
  type ApprovalRequestDto,
  type ApprovalRequestPageDto,
} from '@/modules/company/company-dashboard.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { ApprovalRequestsPage } from './approval-requests-page'

const pendingRequest: ApprovalRequestDto = {
  id: 42,
  approval_request_id: 'APR-123456ABCDEF',
  flow_id: 7,
  flow_name: 'Purchase review',
  action_type: 'asset_purchase',
  action_type_display: 'Asset Purchase',
  title: 'Replace the field equipment',
  description: 'The field team needs replacement equipment before the next inspection.',
  status: 'pending',
  status_display: 'Pending',
  current_step: 1,
  total_steps: 2,
  pending_step_name: 'Department review',
  pending_step_required_level: 'manager',
  pending_step_required_level_display: 'Manager',
  decisions: [],
  metadata: null,
  created_by_id: 12,
  created_by_name: 'Amara Staff',
  created_at: '2026-10-20T09:00:00Z',
  updated_at: '2026-10-20T09:00:00Z',
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

const showToast = vi.fn()
let queryClient: QueryClient

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

function renderPage(permissions: AuthenticatedSession['permissions']) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, makeSession(permissions))
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <ApprovalRequestsPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

function deferred<T>() {
  let resolve!: (value: T) => void
  const promise = new Promise<T>((resolvePromise) => {
    resolve = resolvePromise
  })
  return { promise, resolve }
}

describe('Approval Requests page', () => {
  beforeEach(() => {
    routerState.search = { status: 'all', search: '', page: 1 }
    routerState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(approvalRequestsApi, 'list').mockResolvedValue({
      count: 1,
      items: [pendingRequest],
    })
    vi.spyOn(approvalRequestsApi, 'approve').mockResolvedValue({
      ...pendingRequest,
      status: 'approved',
      status_display: 'Approved',
    })
    vi.spyOn(approvalRequestsApi, 'reject').mockResolvedValue({
      ...pendingRequest,
      status: 'rejected',
      status_display: 'Rejected',
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows request details and only the action allowed by the reviewer permissions', async () => {
    const user = userEvent.setup()
    renderPage({ approval_requests: ['list', 'approve'] })
    const invalidate = vi.spyOn(queryClient, 'invalidateQueries')

    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()
    await user.click(
      await screen.findByRole('button', { name: 'Review request' }, { timeout: 10_000 }),
    )
    const dialog = await screen.findByRole('dialog')
    expect(within(dialog).getByText(pendingRequest.description)).toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: 'Approve' })).toBeInTheDocument()
    expect(within(dialog).queryByRole('button', { name: 'Reject' })).not.toBeInTheDocument()

    await user.click(within(dialog).getByRole('button', { name: 'Approve' }))
    await waitFor(() => expect(approvalRequestsApi.approve).toHaveBeenCalledWith(42))
    expect(invalidate).toHaveBeenCalledWith({
      queryKey: approvalRequestsQueryKeys.lists(7, 'EMP-007'),
    })
    expect(invalidate).toHaveBeenCalledWith({ queryKey: companyOverviewQueryKey(7, 'EMP-007') })
    expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ title: 'Request approved' }))
  })

  it('shows a loading label instead of a false zero count before the first response', async () => {
    const list = deferred<ApprovalRequestPageDto>()
    vi.spyOn(approvalRequestsApi, 'list').mockReturnValueOnce(list.promise)
    renderPage({ approval_requests: ['list'] })

    expect(screen.getByText('Loading requests…')).toBeInTheDocument()
    expect(screen.queryByText('0 requests in this view')).not.toBeInTheDocument()

    await act(async () => {
      list.resolve({ count: 1, items: [pendingRequest] })
      await list.promise
    })
    expect(await screen.findByText('1 request in this view')).toBeInTheDocument()
  })

  it('reports an intermediate approval step without implying the whole request is approved', async () => {
    const user = userEvent.setup()
    vi.spyOn(approvalRequestsApi, 'approve').mockResolvedValueOnce({
      ...pendingRequest,
      current_step: 2,
      pending_step_name: 'Finance review',
    })
    renderPage({ approval_requests: ['list', 'approve'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    await user.click(
      within(await screen.findByRole('dialog')).getByRole('button', { name: 'Approve' }),
    )

    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith({
        title: 'Approval recorded',
        description: 'The request is now awaiting Finance review.',
        tone: 'success',
      }),
    )
  })

  it('requires and sends a rejection reason as the backend comment', async () => {
    const user = userEvent.setup()
    renderPage({ approval_requests: ['list', 'reject'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    const detailDialog = await screen.findByRole('dialog')
    expect(within(detailDialog).getByRole('button', { name: 'Reject' })).toBeInTheDocument()
    expect(within(detailDialog).queryByRole('button', { name: 'Approve' })).not.toBeInTheDocument()
    await user.click(within(detailDialog).getByRole('button', { name: 'Reject' }))

    const rejectionDialog = await screen.findByRole('dialog')
    const reason = within(rejectionDialog).getByRole('textbox', { name: 'Reason' })
    expect(reason).toHaveFocus()
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject request' }))

    expect(approvalRequestsApi.reject).not.toHaveBeenCalled()
    expect(reason).toHaveAttribute('aria-invalid', 'true')
    expect(reason).toHaveAttribute('aria-describedby', 'approval-rejection-reason-error')
    expect(document.activeElement).toBe(reason)
    expect(
      within(rejectionDialog).getByText(
        'Enter a short reason so the requester understands the decision.',
      ),
    ).toBeInTheDocument()

    await user.type(reason, 'The supplier quote is incomplete.')
    expect(reason).not.toHaveAttribute('aria-invalid', 'true')
    expect(
      within(rejectionDialog).queryByText(
        'Enter a short reason so the requester understands the decision.',
      ),
    ).not.toBeInTheDocument()
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject request' }))

    await waitFor(() =>
      expect(approvalRequestsApi.reject).toHaveBeenCalledWith(
        42,
        'The supplier quote is incomplete.',
      ),
    )
  })

  it('puts submitted search text in validated URL state', async () => {
    const user = userEvent.setup()
    renderPage({ approval_requests: ['list'] })

    await screen.findByText(pendingRequest.title)
    await user.type(screen.getByRole('textbox', { name: 'Search requests' }), 'equipment')
    await user.click(screen.getByRole('button', { name: 'Search' }))
    const searchOptions = routerState.navigate.mock.calls.at(-1)?.[0]
    expect(searchOptions).toEqual(
      expect.objectContaining({ to: '/company/approval-requests', search: expect.any(Function) }),
    )
    expect(searchOptions.search(routerState.search)).toEqual({
      status: 'all',
      search: 'equipment',
      page: 1,
    })
  })

  it('preserves the search while status changes and resets pagination', async () => {
    const user = userEvent.setup()
    routerState.search = { status: 'all', search: 'gear', page: 3 }
    renderPage({ approval_requests: ['list'] })

    await user.click(screen.getByRole('combobox', { name: 'Filter approval requests by status' }))
    await user.click(await screen.findByRole('option', { name: /Pending/ }))
    const filterOptions = routerState.navigate.mock.calls.at(-1)?.[0]
    expect(filterOptions.search(routerState.search)).toEqual({
      status: 'pending',
      search: 'gear',
      page: 1,
    })
  })

  it('shows a failed approval decision without closing the request review', async () => {
    const user = userEvent.setup()
    vi.spyOn(approvalRequestsApi, 'approve').mockRejectedValueOnce(
      new Error('Decision unavailable'),
    )
    renderPage({ approval_requests: ['list', 'approve'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Approve' }))

    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Approval could not be recorded', tone: 'danger' }),
      ),
    )
    expect(screen.getByRole('dialog')).toBeInTheDocument()
    expect(
      within(screen.getByRole('dialog')).getByText(pendingRequest.description),
    ).toBeInTheDocument()
  })

  it('prevents dismissing the review dialog while an approval is being recorded', async () => {
    const user = userEvent.setup()
    const approval = deferred<ApprovalRequestDto>()
    vi.spyOn(approvalRequestsApi, 'approve').mockReturnValueOnce(approval.promise)
    renderPage({ approval_requests: ['list', 'approve', 'reject'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    const dialog = await screen.findByRole('dialog')
    await user.click(within(dialog).getByRole('button', { name: 'Approve' }))

    expect(within(dialog).getByRole('button', { name: 'Close dialog' })).toBeDisabled()
    expect(within(dialog).getByRole('button', { name: 'Reject' })).toBeDisabled()
    await act(async () => {
      dialog.dispatchEvent(new Event('cancel', { cancelable: true }))
    })
    expect(dialog).toHaveAttribute('open')

    await act(async () => {
      approval.resolve({ ...pendingRequest, status: 'approved', status_display: 'Approved' })
      await approval.promise
    })
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('protects the rejection reason from dismissal while the decision is being recorded', async () => {
    const user = userEvent.setup()
    const rejection = deferred<ApprovalRequestDto>()
    vi.spyOn(approvalRequestsApi, 'reject').mockReturnValueOnce(rejection.promise)
    renderPage({ approval_requests: ['list', 'reject'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    await user.click(
      within(await screen.findByRole('dialog')).getByRole('button', { name: 'Reject' }),
    )
    const dialog = await screen.findByRole('dialog')
    const reason = within(dialog).getByRole('textbox', { name: 'Reason' })
    await user.type(reason, 'The requested evidence is incomplete.')
    await user.click(within(dialog).getByRole('button', { name: 'Reject request' }))

    expect(reason).toHaveValue('The requested evidence is incomplete.')
    expect(within(dialog).getByRole('button', { name: 'Close dialog' })).toBeDisabled()
    expect(within(dialog).getByRole('button', { name: 'Cancel' })).toBeDisabled()
    await act(async () => {
      dialog.dispatchEvent(new Event('cancel', { cancelable: true }))
    })
    expect(dialog).toHaveAttribute('open')

    await act(async () => {
      rejection.resolve({ ...pendingRequest, status: 'rejected', status_display: 'Rejected' })
      await rejection.promise
    })
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
  })

  it('retains the rejection reason after a server error and allows retry', async () => {
    const user = userEvent.setup()
    const reject = vi
      .spyOn(approvalRequestsApi, 'reject')
      .mockRejectedValueOnce(new Error('Temporary server error'))
      .mockResolvedValueOnce({ ...pendingRequest, status: 'rejected', status_display: 'Rejected' })
    renderPage({ approval_requests: ['list', 'reject'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    await user.click(
      within(await screen.findByRole('dialog')).getByRole('button', { name: 'Reject' }),
    )
    const rejectionDialog = await screen.findByRole('dialog')
    const reason = within(rejectionDialog).getByRole('textbox', { name: 'Reason' })
    await user.type(reason, 'The supporting documents are incomplete.')
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject request' }))

    expect(await within(rejectionDialog).findByRole('alert')).toBeInTheDocument()
    expect(reason).toHaveValue('The supporting documents are incomplete.')
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject request' }))
    await waitFor(() => expect(reject).toHaveBeenCalledTimes(2))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Request rejected' }),
      ),
    )
  })

  it('recovers a bookmarked page that is beyond the result set', async () => {
    routerState.search = { status: 'all', search: '', page: 3 }
    renderPage({ approval_requests: ['list'] })

    await screen.findByText(pendingRequest.title)
    await waitFor(() => expect(routerState.navigate).toHaveBeenCalled())
    const options = routerState.navigate.mock.calls.at(-1)?.[0]
    expect(options).toEqual(
      expect.objectContaining({ to: '/company/approval-requests', replace: true }),
    )
    expect(options.search(routerState.search)).toMatchObject({ page: 1 })
  })

  it('shows an honest empty state when no requests match', async () => {
    vi.spyOn(approvalRequestsApi, 'list').mockResolvedValueOnce({ count: 0, items: [] })
    renderPage({ approval_requests: ['list'] })
    expect(await screen.findByText('No requests in this view')).toBeInTheDocument()
  })

  it('shows a recoverable error when the first request load fails', async () => {
    const list = vi
      .spyOn(approvalRequestsApi, 'list')
      .mockRejectedValueOnce(new Error('Temporary network failure'))
      .mockResolvedValueOnce({ count: 1, items: [pendingRequest] })
    const user = userEvent.setup()
    renderPage({ approval_requests: ['list'] })

    await user.click(await screen.findByRole('button', { name: 'Try again' }))
    expect(await screen.findByText(pendingRequest.title)).toBeInTheDocument()
    expect(list).toHaveBeenCalledTimes(2)
  })

  it('keeps cached requests visible and offers local retry after revalidation fails', async () => {
    const list = vi
      .spyOn(approvalRequestsApi, 'list')
      .mockResolvedValueOnce({ count: 1, items: [pendingRequest] })
      .mockRejectedValueOnce(new Error('Temporary network failure'))
      .mockResolvedValueOnce({ count: 1, items: [pendingRequest] })
    const user = userEvent.setup()
    renderPage({ approval_requests: ['list'] })
    expect(await screen.findByText(pendingRequest.title)).toBeInTheDocument()

    await act(async () => {
      await queryClient.invalidateQueries({
        queryKey: approvalRequestsQueryKeys.lists(7, 'EMP-007'),
      })
    })
    const retryStatus = await screen.findByRole('status')
    expect(within(retryStatus).getByText(/Showing saved requests/)).toBeInTheDocument()
    expect(screen.getByText(pendingRequest.title)).toBeInTheDocument()

    await user.click(within(retryStatus).getByRole('button', { name: 'Retry' }))
    await waitFor(() => expect(list).toHaveBeenCalledTimes(3))
    await waitFor(() =>
      expect(screen.queryByText(/Showing saved requests/)).not.toBeInTheDocument(),
    )
    expect(screen.getByText(pendingRequest.title)).toBeInTheDocument()
  })

  it('does not request the list when the user lacks list permission', () => {
    const list = vi.spyOn(approvalRequestsApi, 'list')
    renderPage({})
    expect(screen.getByText('You can’t view approval requests')).toBeInTheDocument()
    expect(list).not.toHaveBeenCalled()
  })
})
