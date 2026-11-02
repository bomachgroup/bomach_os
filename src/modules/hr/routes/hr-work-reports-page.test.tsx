import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { workReportsApi, type WorkReport } from '@/modules/work-reports/work-reports.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { validateHRWorkReportsSearch } from '@/modules/hr/work-reports.search'

import { HRWorkReportsPage } from './hr-work-reports-page'

Object.defineProperty(HTMLDialogElement.prototype, 'showModal', {
  configurable: true,
  value: function showModal(this: HTMLDialogElement) {
    this.setAttribute('open', '')
  },
})
Object.defineProperty(HTMLDialogElement.prototype, 'close', {
  configurable: true,
  value: function close(this: HTMLDialogElement) {
    this.removeAttribute('open')
  },
})

const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'hr@example.test',
    username: 'hr',
    first_name: 'HR',
    last_name: 'Reviewer',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    id: 19,
    user_id: 9,
    employee_id: 'EMP-009',
    username: 'hr',
    email: 'hr@example.test',
    first_name: 'HR',
    last_name: 'Reviewer',
  },
  roles: [],
  permissions: { work_reports: ['list', 'view', 'approve', 'reject'] },
}

const report: WorkReport = {
  id: 42,
  employeeId: 23,
  employeeName: 'Amaka Okafor',
  day: '2026-10-19',
  hoursWorked: 7.5,
  operationalBase: 'Lagos office',
  workActivities: 'Completed the scheduled generator inspection.',
  taskDetails: 'Logged inspection findings for maintenance.',
  planNextDay: 'Follow up on the replacement part.',
  summary: 'Inspected the generator and recorded the results.',
  status: 'submitted',
  feedback: null,
  rating: null,
  reviewedBy: null,
  reviewedAt: null,
  attachments: [],
  createdAt: '2026-10-19T12:00:00Z',
  updatedAt: '2026-10-19T12:00:00Z',
}

let queryClient: QueryClient
const showToast = vi.fn()

function renderPage({
  url = '/hr/work-report?search=&status=all&page=1',
  permissions = session.permissions,
}: { url?: string; permissions?: AuthenticatedSession['permissions'] } = {}) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const route = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/hr/work-report',
    validateSearch: validateHRWorkReportsSearch,
    component: HRWorkReportsPage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([route])]),
    history: createMemoryHistory({ initialEntries: [url] }),
  })
  render(
    <QueryClientProvider client={queryClient}>
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <RouterProvider router={router} />
      </ToastContext.Provider>
    </QueryClientProvider>,
  )
  return router
}

beforeEach(() => {
  showToast.mockReset()
  vi.spyOn(workReportsApi, 'list').mockResolvedValue({ count: 1, items: [report] })
  vi.spyOn(workReportsApi, 'detail').mockResolvedValue(report)
  vi.spyOn(workReportsApi, 'approve').mockResolvedValue({ ...report, status: 'approved' })
  vi.spyOn(workReportsApi, 'reject').mockResolvedValue({ ...report, status: 'rejected' })
  vi.spyOn(workReportsApi, 'update').mockResolvedValue({ ...report, status: 'draft' })
  vi.spyOn(workReportsApi, 'remove').mockResolvedValue({ detail: 'Deleted' })
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('HRWorkReportsPage', () => {
  it('opens the actionable review queue when no status filter is specified', async () => {
    renderPage({ url: '/hr/work-report' })

    expect(
      await screen.findByRole('combobox', { name: 'Filter work reports by status' }),
    ).toHaveTextContent('Needs HR review')
    await screen.findByRole('heading', { name: 'Amaka Okafor' })
    expect(workReportsApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'submitted' }),
      expect.any(AbortSignal),
    )
  })

  it('clears work-report filters back to the actionable review queue', async () => {
    const user = userEvent.setup()
    const router = renderPage({
      url: '/hr/work-report?search=Amaka&status=approved&page=2',
    })

    await screen.findByRole('heading', { name: 'Amaka Okafor' })
    await user.click(screen.getByRole('button', { name: 'Clear' }))

    await waitFor(() => {
      expect(router.state.location.search).toMatchObject({
        search: '',
        status: 'submitted',
        page: 1,
      })
    })
  })

  it('opens a report as a detail page without exposing the protected layout id in the URL', async () => {
    const user = userEvent.setup()
    const router = renderPage()

    await user.click((await screen.findAllByRole('button', { name: 'Details' }))[0])

    await waitFor(() => expect(router.state.location.pathname).toBe('/hr/work-report'))
    expect(router.state.location.search.reportId).toBe(42)
    expect(await screen.findByRole('heading', { name: 'Report details' })).toBeVisible()
    expect(screen.getByRole('heading', { name: 'Amaka Okafor' })).toBeVisible()
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
  })

  it('opens the exact report from the durable profile deep link and confirms approval', async () => {
    const user = userEvent.setup()
    const router = renderPage({ url: '/hr/work-report?reportId=42&status=submitted&page=3' })

    expect(await screen.findByRole('heading', { name: 'Amaka Okafor' })).toBeVisible()
    expect(await screen.findByRole('heading', { name: 'Report details' })).toBeVisible()
    expect(
      (await screen.findAllByText('Completed the scheduled generator inspection.')).length,
    ).toBeGreaterThan(0)
    expect(workReportsApi.detail).toHaveBeenCalledWith(42, expect.any(AbortSignal))
    expect(workReportsApi.list).not.toHaveBeenCalled()
    expect(router.state.location.search).toMatchObject({
      reportId: 42,
      status: 'submitted',
      page: 3,
    })

    await user.click(screen.getByRole('button', { name: 'Approve report' }))
    const approvalDialog = await screen.findByRole('dialog', { name: 'Approve work report?' })
    expect(workReportsApi.approve).not.toHaveBeenCalled()
    await user.click(within(approvalDialog).getByRole('button', { name: 'Approve report' }))
    await waitFor(() =>
      expect(workReportsApi.approve).toHaveBeenCalledWith(42, { rating: null, feedback: null }),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Work report approved', tone: 'success' }),
      ),
    )
  })

  it('requires a reason before rejecting from the detail page and then saves the decision', async () => {
    const user = userEvent.setup()
    renderPage({ url: '/hr/work-report?reportId=42' })
    await screen.findByRole('heading', { name: 'Amaka Okafor' })

    await user.click(screen.getByRole('button', { name: 'Reject report' }))
    const rejectionDialog = await screen.findByRole('dialog', { name: 'Reject work report?' })
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject report' }))
    expect(
      await within(rejectionDialog).findByText('Add a reason before rejecting this report.'),
    ).toBeVisible()
    expect(workReportsApi.reject).not.toHaveBeenCalled()

    await user.type(
      within(rejectionDialog).getByRole('textbox', { name: 'Reason for rejection' }),
      'Please add the follow-up result.',
    )
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject report' }))
    await waitFor(() =>
      expect(workReportsApi.reject).toHaveBeenCalledWith(42, 'Please add the follow-up result.'),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Work report rejected', tone: 'success' }),
      ),
    )
  })

  it('offers approve and reject from the register card and requires confirmation before writing', async () => {
    const user = userEvent.setup()
    renderPage()

    const card = (await screen.findAllByRole('article'))[0]
    await user.click(within(card).getByRole('button', { name: 'Approve' }))
    const approvalDialog = await screen.findByRole('dialog', { name: 'Approve work report?' })
    expect(within(approvalDialog).getByRole('heading', { name: 'Report summary' })).toBeVisible()
    expect(within(approvalDialog).getByRole('heading', { name: 'Approval details' })).toBeVisible()
    expect(workReportsApi.approve).not.toHaveBeenCalled()
    await user.click(within(approvalDialog).getByRole('button', { name: 'Cancel' }))

    await user.click(within(card).getByRole('button', { name: 'Reject' }))
    const rejectionDialog = await screen.findByRole('dialog', { name: 'Reject work report?' })
    expect(within(rejectionDialog).getByRole('heading', { name: 'Report summary' })).toBeVisible()
    expect(
      within(rejectionDialog).getByRole('heading', { name: 'Request a revision' }),
    ).toBeVisible()
    await user.type(
      within(rejectionDialog).getByRole('textbox', { name: 'Reason for rejection' }),
      'Please clarify the completed work.',
    )
    await user.click(within(rejectionDialog).getByRole('button', { name: 'Reject report' }))

    await waitFor(() =>
      expect(workReportsApi.reject).toHaveBeenCalledWith(42, 'Please clarify the completed work.'),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Work report rejected', tone: 'success' }),
    )
  })

  it('shows permission-limited report detail without review actions', async () => {
    renderPage({
      url: '/hr/work-report?reportId=42',
      permissions: { work_reports: ['list', 'view'] },
    })

    expect(await screen.findByText('View-only access')).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Approve report' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Reject report' })).not.toBeInTheDocument()
  })

  it('fails closed for a decision when the API rejects that permission', async () => {
    const user = userEvent.setup()
    vi.mocked(workReportsApi.approve).mockRejectedValueOnce(
      new ApiError('You do not have permission to perform this action.', { status: 403 }),
    )
    renderPage({ url: '/hr/work-report?reportId=42' })

    await user.click(await screen.findByRole('button', { name: 'Approve report' }))
    const dialog = await screen.findByRole('dialog', { name: 'Approve work report?' })
    await user.click(within(dialog).getByRole('button', { name: 'Approve report' }))

    expect(await screen.findByText('Decision not saved')).toBeVisible()
    expect(within(dialog).getByRole('button', { name: 'Approve report' })).toBeDisabled()
    expect(screen.queryByRole('button', { name: 'Reject report' })).toBeVisible()
  })

  it('offers a scoped retry when the queue request fails', async () => {
    const user = userEvent.setup()
    vi.mocked(workReportsApi.list).mockRejectedValueOnce(new Error('Temporary queue failure'))
    renderPage()

    await screen.findByText('Work reports could not be loaded')
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(
      (await screen.findAllByRole('heading', { name: 'Amaka Okafor' })).length,
    ).toBeGreaterThan(0)
  })

  it('does not expose self-service creation or management actions for the signed-in employee’s report', async () => {
    const ownDraft = { ...report, employeeId: session.employee.id ?? 19, status: 'draft' as const }
    vi.mocked(workReportsApi.list).mockResolvedValueOnce({ count: 1, items: [ownDraft] })
    renderPage({
      permissions: {
        work_reports: ['list', 'view', 'create', 'update', 'update_own', 'delete', 'delete_own'],
      },
    })

    const card = (await screen.findAllByRole('article'))[0]
    expect(screen.queryByRole('link', { name: /New report/i })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'New report' })).not.toBeInTheDocument()
    expect(within(card).getByText('Your record')).toBeVisible()
    expect(within(card).getByRole('button', { name: 'View report' })).toBeVisible()
    expect(within(card).queryByRole('button', { name: 'Edit' })).not.toBeInTheDocument()
    expect(within(card).queryByRole('button', { name: 'Delete' })).not.toBeInTheDocument()
  })

  it('edits another employee’s returned report through the HR editor and preserves attachments', async () => {
    const user = userEvent.setup()
    const returnedReport = {
      ...report,
      status: 'rejected' as const,
      feedback: 'Please include the follow-up result.',
      attachments: ['https://files.example.test/report.pdf'],
    }
    vi.mocked(workReportsApi.list).mockResolvedValueOnce({ count: 1, items: [returnedReport] })
    vi.mocked(workReportsApi.detail).mockResolvedValueOnce(returnedReport)
    vi.mocked(workReportsApi.update).mockResolvedValueOnce({
      ...returnedReport,
      status: 'draft',
      feedback: null,
      rating: null,
      reviewedBy: null,
      reviewedAt: null,
    })
    renderPage({
      permissions: { work_reports: ['list', 'view', 'update'] },
    })

    const card = (await screen.findAllByRole('article'))[0]
    await user.click(within(card).getByRole('button', { name: 'Edit' }))

    expect(await screen.findByRole('dialog', { name: 'Edit employee report' })).toBeVisible()
    expect(await screen.findByText(/This report will return to Draft/)).toBeVisible()
    expect(screen.getByRole('link', { name: 'Attachment 1' })).toHaveAttribute(
      'href',
      'https://files.example.test/report.pdf',
    )
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(workReportsApi.update).toHaveBeenCalledWith(
        42,
        expect.objectContaining({
          day: '2026-10-19',
          hours_worked: 7.5,
          status: 'draft',
          attachments: ['https://files.example.test/report.pdf'],
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({
        title: 'Work report updated',
        description: expect.stringContaining('now a draft'),
      }),
    )
  })

  it('allows an authorized manager to delete another employee’s draft report', async () => {
    const user = userEvent.setup()
    const draft = { ...report, status: 'draft' as const }
    vi.mocked(workReportsApi.list).mockResolvedValueOnce({ count: 1, items: [draft] })
    renderPage({ permissions: { work_reports: ['list', 'view', 'delete'] } })

    const card = (await screen.findAllByRole('article'))[0]
    await user.click(within(card).getByRole('button', { name: 'Delete' }))
    expect(await screen.findByRole('heading', { name: 'Delete work report' })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Delete report' }))
    await waitFor(() => expect(workReportsApi.remove).toHaveBeenCalledWith(42))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Work report deleted', tone: 'success' }),
    )
  })

  it('does not offer self-review actions for a submitted report owned by the signed-in employee', async () => {
    const user = userEvent.setup()
    const ownSubmitted = {
      ...report,
      employeeId: session.employee.id ?? 19,
      employeeName: 'HR Reviewer',
    }
    vi.mocked(workReportsApi.list).mockResolvedValueOnce({ count: 1, items: [ownSubmitted] })
    vi.mocked(workReportsApi.detail).mockResolvedValueOnce(ownSubmitted)
    renderPage({
      permissions: { work_reports: ['list', 'view', 'approve', 'reject'] },
    })

    const card = (await screen.findAllByRole('article'))[0]
    await user.click(within(card).getByRole('button', { name: 'View report' }))
    expect(await screen.findByText('Self-review is not allowed')).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Approve report' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Return for revision' })).not.toBeInTheDocument()
  })

  it('hides detail actions without view permission and clears an unauthorized deep link', async () => {
    renderPage({
      url: '/hr/work-report?reportId=42&search=&status=all&page=1',
      permissions: { work_reports: ['list'] },
    })

    expect(await screen.findByText('You can’t view this work report')).toBeVisible()
    expect(workReportsApi.detail).not.toHaveBeenCalled()
    expect(workReportsApi.list).not.toHaveBeenCalled()
  })
})
