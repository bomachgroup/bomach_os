import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  reportId: '81',
  search: { status: 'all', page: 1 },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({ to, children, className }: { to: string; children: ReactNode; className?: string }) =>
      createElement('a', { href: to, className }, children),
    useParams: () => ({ reportId: routeState.reportId }),
    useSearch: () => routeState.search,
    useNavigate: () => routeState.navigate,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { workReportsApi, type WorkReport, type WorkReportStatus } from '../work-reports.api'
import { workReportsQueryKeys } from '../work-reports.queries'
import { WorkReportDetailPage } from './work-report-detail-page'

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

const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'jules@example.com',
    username: 'jules',
    first_name: 'Jules',
    last_name: 'Staff',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    id: 31,
    user_id: 9,
    employee_id: 'EMP-031',
    username: 'jules',
    email: 'jules@example.com',
    first_name: 'Jules',
    last_name: 'Staff',
  },
  roles: [],
  permissions: {
    work_reports: ['view_own', 'update_own', 'delete_own'],
  },
}

const report: WorkReport = {
  id: 81,
  employeeId: 31,
  day: '2026-10-19',
  hoursWorked: 7.5,
  operationalBase: 'Lagos office',
  workActivities: 'Inspected the generator controls.',
  taskDetails: 'The pressure gauge needs replacement.',
  planNextDay: 'Check the replacement gauge.',
  summary: 'Inspected the generator controls.',
  status: 'draft',
  feedback: null,
  rating: null,
  reviewedBy: null,
  reviewedAt: null,
  attachments: [],
  createdAt: '2026-10-19T12:00:00Z',
  updatedAt: '2026-10-19T12:00:00Z',
}

const showToast = vi.fn()
let queryClient: QueryClient

function reportWithStatus(status: WorkReportStatus): WorkReport {
  return {
    ...report,
    status,
    feedback: status === 'rejected' ? 'Please add the follow-up result.' : 'Reviewed and recorded.',
    rating: status === 'approved' ? 4 : null,
    reviewedBy: status === 'draft' ? null : 'Mira Okafor',
    reviewedAt: status === 'draft' ? null : '2026-10-19T13:00:00Z',
  }
}

function renderPage(selectedReport = report, permissions = session.permissions) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  vi.spyOn(workReportsApi, 'detail').mockResolvedValue(selectedReport)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <WorkReportDetailPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('Work Report detail actions', () => {
  beforeEach(() => {
    routeState.reportId = '81'
    routeState.navigate.mockReset()
    showToast.mockReset()
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows approved review feedback as read-only', async () => {
    renderPage(reportWithStatus('approved'))

    expect(
      await screen.findByText('This report has been reviewed and approved. It is now read-only.'),
    ).toBeInTheDocument()
    expect(screen.getByText('Reviewed and recorded.')).toBeInTheDocument()
    expect(screen.getByText('4/5')).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Edit report' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Delete report' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Withdraw for editing' })).not.toBeInTheDocument()
  })

  it('keeps the cached report visible when a background refresh fails', async () => {
    queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
    queryClient.setQueryData(
      workReportsQueryKeys.detail(session.user.id, session.employee.employee_id, report.id),
      report,
      { updatedAt: Date.now() - 61_000 },
    )
    vi.spyOn(workReportsApi, 'detail').mockRejectedValue(new Error('offline'))

    render(
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <QueryClientProvider client={queryClient}>
          <WorkReportDetailPage />
        </QueryClientProvider>
      </ToastContext.Provider>,
    )

    expect(await screen.findByText('Inspected the generator controls.')).toBeInTheDocument()
    expect(await screen.findByText('Showing the saved report')).toBeInTheDocument()
    expect(screen.queryByText('Report could not load')).not.toBeInTheDocument()
  })

  it('requires confirmation before deleting a draft and allows cancellation', async () => {
    const user = userEvent.setup()
    const remove = vi.spyOn(workReportsApi, 'remove').mockResolvedValue({ detail: 'Deleted.' })
    renderPage()

    await user.click(await screen.findByRole('button', { name: 'Delete report' }))
    expect(screen.getByRole('dialog', { name: 'Delete this report?' })).toBeInTheDocument()
    expect(remove).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Cancel' }))
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
    expect(remove).not.toHaveBeenCalled()
  })

  it('withdraws a submitted report only after confirmation, then opens its editor', async () => {
    const user = userEvent.setup()
    const updated = { ...reportWithStatus('submitted'), status: 'draft' as const }
    const withdraw = vi.spyOn(workReportsApi, 'withdraw').mockResolvedValue(updated)
    renderPage(reportWithStatus('submitted'))

    await user.click(await screen.findByRole('button', { name: 'Withdraw for editing' }))
    expect(screen.getByRole('dialog', { name: 'Withdraw this report?' })).toBeInTheDocument()
    expect(withdraw).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Withdraw report' }))
    await waitFor(() => expect(withdraw).toHaveBeenCalledOnce())
    expect(routeState.navigate).toHaveBeenCalledWith({
      to: '/dashboard/my-reports/$reportId/edit',
      params: { reportId: '81' },
      search: { status: 'all', page: 1 },
    })
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Report withdrawn', tone: 'success' }),
    )
  })
})
