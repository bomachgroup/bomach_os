import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { tab: 'workflows', status: 'all', search: '', page: 1 },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return { ...actual, useSearch: () => routeState.search, useNavigate: () => routeState.navigate }
})

import {
  approvalWorkflowsApi,
  approvalWorkflowsQueryKeys,
} from '@/modules/company/approval-workflows.api'
import { approvalRequestsApi } from '@/modules/company/company-dashboard.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { ApprovalWorkflowsPage } from './approval-workflows-page'

const session = (permissions: AuthenticatedSession['permissions']) =>
  ({
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
  }) as AuthenticatedSession

const flow = {
  id: 1,
  name: 'Expense review',
  description: 'Two-stage review for expense claims.',
  action_type: 'expense_claim',
  action_type_display: 'Expense Claim',
  is_active: true,
  steps: [
    {
      id: 11,
      step_order: 1,
      step_name: 'Manager review',
      required_level: 'manager',
      required_level_display: 'Manager',
    },
    {
      id: 12,
      step_order: 2,
      step_name: 'Finance review',
      required_level: 'head_finance',
      required_level_display: 'Head of Finance',
    },
  ],
  created_by_id: 7,
  created_by_name: 'Reviewer',
  created_at: '2026-10-20T09:00:00Z',
  updated_at: '2026-10-24T09:00:00Z',
}

const request = {
  id: 44,
  approval_request_id: 'APR-44',
  flow_id: 1,
  flow_name: 'Expense review',
  action_type: 'expense_claim',
  action_type_display: 'Expense Claim',
  title: 'Travel reimbursement',
  description: 'Reimbursement for the field visit.',
  status: 'pending' as const,
  status_display: 'Pending',
  current_step: 1,
  total_steps: 2,
  pending_step_name: 'Manager review',
  pending_step_required_level: 'manager',
  pending_step_required_level_display: 'Manager',
  decisions: [],
  metadata: null,
  created_by_id: 8,
  created_by_name: 'Amara Staff',
  created_at: '2026-10-25T09:00:00Z',
  updated_at: '2026-10-25T09:00:00Z',
}

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

function renderPage(
  permissions: AuthenticatedSession['permissions'],
  client = new QueryClient({ defaultOptions: { queries: { retry: false } } }),
) {
  queryClient = client
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session(permissions))
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <ApprovalWorkflowsPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('ApprovalWorkflowsPage', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    routeState.navigate.mockReset()
    showToast.mockReset()
    routeState.search = { tab: 'workflows', status: 'all', search: '', page: 1 }
    vi.spyOn(approvalWorkflowsApi, 'list').mockResolvedValue({ count: 1, items: [flow] })
    vi.spyOn(approvalWorkflowsApi, 'choices').mockResolvedValue({
      action_types: [{ value: 'expense_claim', label: 'Expense Claim' }],
      required_levels: [
        { value: 'manager', label: 'Manager' },
        { value: 'head_finance', label: 'Head of Finance' },
      ],
    })
    vi.spyOn(approvalRequestsApi, 'list').mockResolvedValue({ count: 1, items: [request] })
  })

  afterEach(() => queryClient?.clear())

  it('shows ordered workflow steps and only tabs the account can read', async () => {
    renderPage({ approval_flows: ['list'] })
    expect(await screen.findByText('Expense review')).toBeInTheDocument()
    expect(screen.getByText(/Manager review/)).toBeInTheDocument()
    expect(screen.getByText(/Head of Finance/)).toBeInTheDocument()
    expect(screen.queryByRole('tab', { name: 'Approval requests' })).not.toBeInTheDocument()
  })

  it('opens a compact, structured workflow detail dialog with the configured sequence', async () => {
    const user = userEvent.setup()
    renderPage({ approval_flows: ['list'] })

    await user.click(await screen.findByRole('button', { name: 'Details' }))
    const dialog = await screen.findByRole('dialog', { name: flow.name })
    expect(dialog).toHaveClass('tablet:top-1/2')
    expect(dialog.querySelector(':scope > div.min-h-0.overflow-y-auto')).toHaveClass('flex-auto')
    expect(within(dialog).getByText('Purpose and scope')).toBeInTheDocument()
    expect(within(dialog).getByText(flow.description)).toBeInTheDocument()
    expect(within(dialog).getByText('01')).toBeInTheDocument()
    expect(within(dialog).getAllByText('02')).toHaveLength(2)
    expect(within(dialog).getByText('Manager review')).toBeInTheDocument()
    expect(within(dialog).getByText('Finance review')).toBeInTheDocument()
    expect(within(dialog).queryByText('Level enforcement')).not.toBeInTheDocument()
  })

  it('creates a workflow with the edited step order and shows success feedback', async () => {
    const user = userEvent.setup()
    const create = vi.spyOn(approvalWorkflowsApi, 'create').mockResolvedValue(flow)
    renderPage({ approval_flows: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New workflow' }))
    const dialog = await screen.findByRole('dialog', { name: 'Create approval workflow' })
    expect(within(dialog).getByText('Workflow details')).toBeInTheDocument()
    expect(within(dialog).getByText('Approval sequence')).toBeInTheDocument()
    expect(within(dialog).queryByText('How approval levels work')).not.toBeInTheDocument()
    await user.type(within(dialog).getByRole('textbox', { name: 'Workflow name' }), 'Finance route')
    await user.type(within(dialog).getByRole('textbox', { name: 'Step name' }), 'Manager review')
    await user.click(within(dialog).getByRole('button', { name: 'Add step' }))
    const stepNames = within(dialog).getAllByRole('textbox', { name: 'Step name' })
    await user.type(stepNames[1], 'Finance review')
    await user.click(within(dialog).getByRole('button', { name: 'Move step 2 up' }))
    const reorderedSteps = within(dialog).getAllByRole('textbox', { name: 'Step name' })
    expect(reorderedSteps[0]).toHaveValue('Finance review')
    expect(reorderedSteps[1]).toHaveValue('Manager review')
    await user.click(within(dialog).getByRole('button', { name: 'Create workflow' }))

    await waitFor(() =>
      expect(create).toHaveBeenCalledWith({
        name: 'Finance route',
        description: '',
        action_type: 'expense_claim',
        steps: [
          { step_order: 1, step_name: 'Finance review', required_level: 'manager' },
          { step_order: 2, step_name: 'Manager review', required_level: 'manager' },
        ],
      }),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'Workflow created',
          tone: 'success',
        }),
      ),
    )
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('focuses the first incomplete approval step and blocks an invalid workflow', async () => {
    const user = userEvent.setup()
    const create = vi.spyOn(approvalWorkflowsApi, 'create')
    renderPage({ approval_flows: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New workflow' }))
    const dialog = await screen.findByRole('dialog', { name: 'Create approval workflow' })
    fireEvent.submit(
      within(dialog).getByRole('button', { name: 'Create workflow' }).closest('form')!,
    )

    expect(await within(dialog).findByRole('alert')).toBeInTheDocument()
    expect(within(dialog).getByRole('textbox', { name: 'Step name' })).toHaveFocus()
    expect(create).not.toHaveBeenCalled()
  })

  it('keeps a failed workflow save open and reports the server error', async () => {
    const user = userEvent.setup()
    vi.spyOn(approvalWorkflowsApi, 'create').mockRejectedValueOnce(new Error('Save unavailable'))
    renderPage({ approval_flows: ['list', 'create'] })

    await user.click(await screen.findByRole('button', { name: 'New workflow' }))
    const dialog = await screen.findByRole('dialog', { name: 'Create approval workflow' })
    await user.type(within(dialog).getByRole('textbox', { name: 'Workflow name' }), 'Finance route')
    await user.type(within(dialog).getByRole('textbox', { name: 'Step name' }), 'Manager review')
    await user.click(within(dialog).getByRole('button', { name: 'Create workflow' }))

    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'Workflow could not be saved',
          tone: 'danger',
        }),
      ),
    )
    expect(screen.getByRole('dialog', { name: 'Create approval workflow' })).toBeInTheDocument()
  })

  it('confirms deactivation, invalidates the register and reports success', async () => {
    const user = userEvent.setup()
    const deactivate = vi
      .spyOn(approvalWorkflowsApi, 'deactivate')
      .mockResolvedValue({ detail: 'Workflow deactivated' })
    renderPage({ approval_flows: ['list', 'delete'] })
    const invalidate = vi.spyOn(queryClient, 'invalidateQueries')

    await user.click(await screen.findByRole('button', { name: 'Deactivate' }))
    const dialog = await screen.findByRole('dialog', { name: 'Deactivate workflow' })
    expect(within(dialog).getByText(flow.name)).toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Deactivate' }))

    await waitFor(() => expect(deactivate).toHaveBeenCalledWith(flow.id))
    expect(invalidate).toHaveBeenCalledWith({
      queryKey: expect.arrayContaining(['company', 'approval-workflows', 7, 'EMP-007', 'list']),
    })
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'Workflow deactivated',
          tone: 'success',
        }),
      ),
    )
  })

  it('keeps existing records visible with a retry action after a revalidation error', async () => {
    const list = vi.spyOn(approvalWorkflowsApi, 'list').mockResolvedValue({
      count: 1,
      items: [flow],
    })
    const user = userEvent.setup()
    const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    renderPage({ approval_flows: ['list'] }, client)

    expect(await screen.findByText(flow.name)).toBeInTheDocument()
    list.mockRejectedValueOnce(new Error('Temporary network failure'))
    await act(async () => {
      await queryClient.invalidateQueries({
        queryKey: approvalWorkflowsQueryKeys.lists(7, 'EMP-007'),
      })
    })
    const retry = await screen.findByRole('status')
    expect(within(retry).getByText(/Showing the last loaded workflows/)).toBeInTheDocument()
    expect(screen.getByText(flow.name)).toBeInTheDocument()

    await user.click(within(retry).getByRole('button', { name: 'Try again' }))
    await waitFor(() => expect(list).toHaveBeenCalledTimes(3))
    await waitFor(() =>
      expect(screen.queryByText(/Showing the last loaded workflows/)).not.toBeInTheDocument(),
    )
  })

  it('uses the shared responsive create labels while keeping its accessible name', async () => {
    renderPage({ approval_flows: ['list', 'create'] })
    const button = await screen.findByRole('button', { name: 'New workflow' })
    expect(within(button).getByText('New')).toHaveClass('max-[361px]:hidden', 'phone:hidden')
    expect(within(button).getByText('New workflow')).toHaveClass('hidden', 'phone:inline')
    expect(
      screen.getByRole('heading', { name: 'Approval workflows' }).parentElement?.parentElement,
    ).toHaveClass('items-center', 'justify-between')
  })

  it('shows the review queue without demo-like reviewer eligibility callouts', async () => {
    routeState.search = { tab: 'requests', status: 'pending', search: '', page: 1 }
    renderPage({ approval_requests: ['list'] })
    expect(await screen.findByText('Travel reimbursement')).toBeInTheDocument()
    expect(screen.queryByText('Reviewer eligibility')).not.toBeInTheDocument()
    expect(screen.queryByRole('tab', { name: 'Workflows' })).not.toBeInTheDocument()
  })

  it('records an approval, invalidates review data, and closes the request details', async () => {
    const user = userEvent.setup()
    routeState.search = { tab: 'requests', status: 'pending', search: '', page: 1 }
    const approve = vi
      .spyOn(approvalRequestsApi, 'approve')
      .mockResolvedValue({ ...request, status: 'approved', status_display: 'Approved' })
    renderPage({ approval_requests: ['list', 'view', 'approve'] })
    const invalidate = vi.spyOn(queryClient, 'invalidateQueries')

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    const dialog = await screen.findByRole('dialog', { name: request.title })
    expect(within(dialog).queryByText('Reviewer eligibility')).not.toBeInTheDocument()
    await user.click(within(dialog).getByRole('button', { name: 'Approve' }))

    await waitFor(() => expect(approve).toHaveBeenCalledWith(request.id))
    await waitFor(() => expect(screen.queryByRole('dialog', { name: request.title })).toBeNull())
    expect(invalidate).toHaveBeenCalledWith({
      queryKey: expect.arrayContaining(['company', 'approval-requests', 7, 'EMP-007', 'list']),
    })
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Request approved', tone: 'success' }),
    )
  })

  it('keeps request details open and reports an approval failure', async () => {
    const user = userEvent.setup()
    routeState.search = { tab: 'requests', status: 'pending', search: '', page: 1 }
    const approve = vi
      .spyOn(approvalRequestsApi, 'approve')
      .mockRejectedValueOnce(new Error('Approvals are temporarily unavailable'))
    renderPage({ approval_requests: ['list', 'view', 'approve'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    const dialog = await screen.findByRole('dialog', { name: request.title })
    await user.click(within(dialog).getByRole('button', { name: 'Approve' }))

    await waitFor(() => expect(approve).toHaveBeenCalledWith(request.id))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({
          title: 'Approval could not be recorded',
          tone: 'danger',
        }),
      ),
    )
    expect(screen.getByRole('dialog', { name: request.title })).toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: 'Approve' })).toBeEnabled()
  })

  it('validates a rejection reason, retains it after failure, then records the rejection', async () => {
    const user = userEvent.setup()
    routeState.search = { tab: 'requests', status: 'pending', search: '', page: 1 }
    const reject = vi
      .spyOn(approvalRequestsApi, 'reject')
      .mockRejectedValueOnce(new ApiError('Storage failed', { status: 500 }))
      .mockResolvedValueOnce({ ...request, status: 'rejected', status_display: 'Rejected' })
    renderPage({ approval_requests: ['list', 'view', 'reject'] })

    await user.click(await screen.findByRole('button', { name: 'Review request' }))
    const details = await screen.findByRole('dialog', { name: request.title })
    await user.click(within(details).getByRole('button', { name: 'Reject' }))
    const rejection = await screen.findByRole('dialog', { name: 'Reject request' })
    const reason = within(rejection).getByRole('textbox', { name: 'Reason' })

    await user.click(within(rejection).getByRole('button', { name: 'Reject request' }))
    expect(await within(rejection).findByRole('status')).toHaveTextContent(
      'Provide a reason for rejecting this request.',
    )
    expect(reason).toHaveFocus()
    expect(reject).not.toHaveBeenCalled()

    await user.type(reason, 'Supporting details need review.')
    await user.click(within(rejection).getByRole('button', { name: 'Reject request' }))
    await waitFor(() =>
      expect(reject).toHaveBeenCalledWith(request.id, 'Supporting details need review.'),
    )
    expect(await within(rejection).findByRole('status')).toHaveTextContent(
      'BOMACH OS could not complete this request. Please try again shortly.',
    )
    expect(reason).toHaveValue('Supporting details need review.')
    expect(reason).toHaveFocus()

    await user.click(within(rejection).getByRole('button', { name: 'Reject request' }))
    await waitFor(() => expect(reject).toHaveBeenCalledTimes(2))
    await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull())
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Request rejected', tone: 'success' }),
    )
  })
})
