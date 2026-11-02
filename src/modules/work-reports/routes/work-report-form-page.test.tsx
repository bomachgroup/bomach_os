import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  pathname: '/dashboard/my-reports/create',
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
    useNavigate: () => routeState.navigate,
    useRouterState: () => routeState.pathname,
    useSearch: () => routeState.search,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { workReportsApi, type WorkReport } from '../work-reports.api'
import { workReportsQueryKeys } from '../work-reports.queries'
import { WorkReportFormPage } from './work-report-form-page'

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
  permissions: { work_reports: ['create', 'list_own', 'view_own'] },
}

const savedReport: WorkReport = {
  id: 81,
  employeeId: 31,
  day: '2026-10-19',
  hoursWorked: 0,
  operationalBase: null,
  workActivities: null,
  taskDetails: null,
  planNextDay: null,
  summary: null,
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

function renderPage() {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <WorkReportFormPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

async function goToReview(user: ReturnType<typeof userEvent.setup>) {
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.type(
    screen.getByRole('textbox', { name: 'Activity 1' }),
    'Inspected the pump and recorded the result.',
  )
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.click(screen.getByRole('button', { name: 'Continue' }))
  await user.click(screen.getByRole('button', { name: 'Continue' }))
}

describe('Work Report guided form', () => {
  beforeEach(() => {
    routeState.pathname = '/dashboard/my-reports/create'
    routeState.reportId = '81'
    routeState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(workReportsApi, 'create').mockResolvedValue(savedReport)
    vi.spyOn(workReportsApi, 'upload').mockResolvedValue({
      url: 'https://files.example.test/work-report.pdf',
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('keeps the five guided steps and blocks new submission without a valid time range', async () => {
    const user = userEvent.setup()
    renderPage()

    expect(screen.getByText('Step 1 of 5')).toBeInTheDocument()
    await goToReview(user)
    expect(screen.getByRole('heading', { name: 'Review report' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Submit for review' }))

    expect(
      await screen.findByText('Choose a valid start and end time before submitting a new report.'),
    ).toBeInTheDocument()
    expect(screen.getByText('Step 1 of 5')).toBeInTheDocument()
    expect(workReportsApi.create).not.toHaveBeenCalled()
    expect(screen.getByLabelText('Start time').getAttribute('aria-describedby')).toContain(
      'report-time-error',
    )
    expect(screen.getByLabelText('End time').getAttribute('aria-describedby')).toContain(
      'report-time-error',
    )
    await user.click(screen.getByLabelText('Start time'))
    let picker = screen.getByRole('dialog', { name: 'Choose a time' })
    await user.click(within(picker).getByRole('combobox', { name: 'Hour' }))
    await user.click(screen.getByRole('option', { name: '08' }))
    await user.click(within(picker).getByRole('button', { name: 'Set time' }))
    expect(
      screen.getByText('Choose a valid start and end time before submitting a new report.'),
    ).toBeInTheDocument()
    await user.click(screen.getByLabelText('End time'))
    picker = screen.getByRole('dialog', { name: 'Choose a time' })
    await user.click(within(picker).getByRole('combobox', { name: 'Hour' }))
    await user.click(screen.getByRole('option', { name: '04' }))
    await user.click(within(picker).getByRole('combobox', { name: 'AM or PM' }))
    await user.click(screen.getByRole('option', { name: 'PM' }))
    await user.click(within(picker).getByRole('button', { name: 'Set time' }))
    expect(
      screen.queryByText('Choose a valid start and end time before submitting a new report.'),
    ).not.toBeInTheDocument()
  })

  it('uses sequential steps and requires work completed before continuing', async () => {
    const user = userEvent.setup()
    renderPage()

    const reviewStepButtons = screen.getAllByRole('button', { name: /Review report/ })
    expect(reviewStepButtons.length).toBeGreaterThan(0)
    expect(reviewStepButtons.every((button) => button.hasAttribute('disabled'))).toBe(true)
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByText('Step 2 of 5')).toBeInTheDocument()
    expect(screen.getByText('Describe at least one completed activity.')).toBeInTheDocument()

    await user.type(
      screen.getByRole('textbox', { name: 'Activity 1' }),
      'Replaced the site pump seal.',
    )
    expect(screen.queryByText('Describe at least one completed activity.')).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    expect(screen.getByText('Step 3 of 5')).toBeInTheDocument()
  })

  it('adds, removes, and saves work report items as separate entries', async () => {
    const user = userEvent.setup()
    renderPage()

    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Inspect the pump')
    await user.click(screen.getByRole('button', { name: 'Add activity' }))
    await user.type(screen.getByRole('textbox', { name: 'Activity 2' }), 'Update the log')
    await user.click(screen.getByRole('button', { name: 'Continue' }))

    expect(screen.queryByText('No challenges to report? Leave this section blank.')).toBeNull()
    await user.click(screen.getByRole('button', { name: 'Add challenge' }))
    await user.click(screen.getByRole('button', { name: 'Add challenge' }))
    await user.type(screen.getByRole('textbox', { name: 'Challenge 2' }), 'Waiting for a part')
    await user.click(screen.getByRole('button', { name: 'Remove challenge 1' }))
    expect(screen.getByRole('textbox', { name: 'Challenge 1' })).toHaveValue('Waiting for a part')
    await user.click(screen.getByRole('button', { name: 'Add next step' }))
    await user.type(screen.getByRole('textbox', { name: 'Next step 1' }), 'Replace the valve')
    await user.click(screen.getByRole('button', { name: 'Save draft' }))

    await waitFor(() =>
      expect(vi.mocked(workReportsApi.create).mock.calls[0]?.[0]).toMatchObject({
        work_activities: 'Inspect the pump\nUpdate the log',
        task_details: 'Waiting for a part',
        plan_next_day: 'Replace the valve',
        status: 'draft',
      }),
    )
  })

  it('keeps entered draft content after the server rejects a save', async () => {
    const user = userEvent.setup()
    vi.mocked(workReportsApi.create).mockRejectedValueOnce(new Error('network failure'))
    renderPage()

    await user.click(screen.getByRole('button', { name: 'Continue' }))
    const workDescription = 'Completed the pump inspection and updated the log.'
    const workField = screen.getByRole('textbox', { name: 'Activity 1' })
    await user.type(workField, workDescription)
    await user.click(screen.getByRole('button', { name: 'Save draft' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Your entries are still here')
    expect(workField).toHaveValue(workDescription)
    expect(vi.mocked(workReportsApi.create).mock.calls[0]?.[0]).toMatchObject({
      work_activities: workDescription,
      status: 'draft',
    })
  })

  it('keeps uploaded evidence attached locally when the report save fails', async () => {
    const user = userEvent.setup()
    vi.mocked(workReportsApi.create).mockRejectedValueOnce(new Error('save failure'))
    renderPage()

    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.type(
      screen.getByRole('textbox', { name: 'Activity 1' }),
      'Completed the pump inspection.',
    )
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    await user.click(screen.getByRole('button', { name: 'Continue' }))
    const file = new File(['work evidence'], 'work-report.pdf', { type: 'application/pdf' })
    await user.upload(screen.getByLabelText('Supporting evidence files'), file)
    await user.click(screen.getByRole('button', { name: 'Save draft' }))

    expect(await screen.findByRole('link', { name: 'work-report.pdf' })).toHaveAttribute(
      'href',
      'https://files.example.test/work-report.pdf',
    )
    expect(screen.getByRole('alert')).toHaveTextContent('Your entries are still here')
    expect(workReportsApi.upload).toHaveBeenCalledOnce()
    await waitFor(() =>
      expect(vi.mocked(workReportsApi.create).mock.calls[0]?.[0]).toMatchObject({
        attachments: ['https://files.example.test/work-report.pdf'],
      }),
    )
  })

  it('keeps a cached edit usable when refreshing the report fails', async () => {
    routeState.pathname = '/dashboard/my-reports/81/edit'
    queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    const editSession = {
      ...session,
      permissions: { work_reports: ['update_own', 'view_own'] },
    }
    queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, editSession)
    queryClient.setQueryData(
      workReportsQueryKeys.detail(session.user.id, session.employee.employee_id, savedReport.id),
      savedReport,
      { updatedAt: Date.now() - 61_000 },
    )
    vi.spyOn(workReportsApi, 'detail').mockRejectedValue(new Error('offline'))

    render(
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <QueryClientProvider client={queryClient}>
          <WorkReportFormPage />
        </QueryClientProvider>
      </ToastContext.Provider>,
    )

    expect(await screen.findByText('Showing the saved report')).toBeInTheDocument()
    expect(screen.getByRole('heading', { name: 'Edit work report' })).toBeInTheDocument()
    expect(screen.queryByText('Report could not load')).not.toBeInTheDocument()
  })
})
