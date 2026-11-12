import { createElement, StrictMode, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  reportType: 'engineering',
  reportId: '91',
  search: {
    type: 'site',
    status: 'approved',
    page: 3,
  },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({
      to,
      children,
      className,
      'aria-label': ariaLabel,
    }: {
      to: string
      children: ReactNode
      className?: string
      'aria-label'?: string
    }) => createElement('a', { href: to, className, 'aria-label': ariaLabel }, children),
    useParams: () => ({ reportType: routeState.reportType, reportId: routeState.reportId }),
    useSearch: () => routeState.search,
    useNavigate: () => routeState.navigate,
  }
})

import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { siteReportsApi, type SiteReport, type SiteReportStatus } from '../site-reports.api'
import { SiteReportDetailPage, SiteReportEditPage } from './site-report-pages'

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
  permissions: {
    engineering_site_reports: ['view_own', 'update_own', 'submit_own', 'delete_own'],
    survey_site_reports: ['view_own', 'update_own', 'submit_own', 'delete_own'],
  },
}

const report: SiteReport = {
  id: 91,
  employee_id: 23,
  employee_name: 'Sam Staff',
  status: 'draft',
  rating: null,
  reviewed_by_id: null,
  reviewed_at: null,
  worksite_id: 6,
  worksite_name: 'North worksite',
  project_id: 14,
  task_id: null,
  date: '2026-10-27',
  summary: 'Inspected the foundation.',
  tomorrow_activities: 'Check concrete curing.',
  comments_suggestions: 'Use the north access road.',
  submission_version: 1,
  activities: [{ id: 1, activity_type: 'concrete_work', description: 'Inspected the foundation.' }],
  expenses: [
    {
      id: 2,
      expense_category: 'labour',
      name: 'Site transport',
      amount: '1500',
      description: 'Vehicle fuel.',
    },
  ],
  materials_used: [
    { id: 3, equipment_id: 5, equipment_name: 'Concrete mixer', unit: 'hours', quantity_used: '2' },
  ],
  attachments: ['https://files.example.com/site-photo.jpg'],
  created_at: '2026-10-27T09:00:00Z',
  updated_at: '2026-10-27T09:00:00Z',
}

const showToast = vi.fn()
let queryClient: QueryClient

function reportWithStatus(status: SiteReportStatus): SiteReport {
  return {
    ...report,
    status,
    summary: status === 'rejected' ? 'Please clarify the foundation measurements.' : report.summary,
    rating: status === 'approved' ? 4 : null,
    reviewed_by_id: status === 'draft' ? null : 5,
    reviewed_at: status === 'draft' ? null : '2026-10-28T09:00:00Z',
  }
}

function renderPage(selectedReport = report, permissions = session.permissions) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  vi.spyOn(siteReportsApi, 'detail').mockResolvedValue(selectedReport)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <SiteReportDetailPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

function renderEditPage(
  selectedReport = report,
  permissions = session.permissions,
  strictMode = false,
) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  vi.spyOn(siteReportsApi, 'detail').mockResolvedValue(selectedReport)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        {strictMode ? (
          <StrictMode>
            <SiteReportEditPage />
          </StrictMode>
        ) : (
          <SiteReportEditPage />
        )}
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('Personal site report details and actions', () => {
  beforeEach(() => {
    routeState.reportType = 'engineering'
    routeState.reportId = '91'
    routeState.navigate.mockReset()
    showToast.mockReset()
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows report content, attachments, and draft actions for owner permissions', async () => {
    renderPage()

    expect(await screen.findByText('North worksite')).toBeInTheDocument()
    expect(screen.getAllByText('Inspected the foundation.')).toHaveLength(2)
    expect(screen.getByText('Vehicle fuel.')).toBeInTheDocument()
    expect(screen.getByText('Concrete mixer: 2 hours')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Edit report' })).toHaveAttribute(
      'href',
      '/dashboard/my-reports/site/$reportType/$reportId/edit',
    )
    expect(screen.getByRole('button', { name: 'Submit for review' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Delete report' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Submit for review' }).parentElement).toHaveClass(
      'grid',
      'grid-cols-2',
      'tablet:flex',
    )
    expect(screen.getByText('Submit')).toHaveClass('tablet:hidden')
    expect(screen.getByText('Delete')).toHaveClass('tablet:hidden')
    expect(
      screen.getByRole('button', { name: 'Submit for review' }).querySelector('span.hidden'),
    ).toHaveClass('tablet:inline')
    expect(
      screen.getByRole('button', { name: 'Delete report' }).querySelector('span.hidden'),
    ).toHaveClass('tablet:inline')
  })

  it('only allows deleting and editing a rejected report, not submitting it', async () => {
    renderPage(reportWithStatus('rejected'))

    expect(
      (await screen.findAllByText('Please clarify the foundation measurements.')).length,
    ).toBeGreaterThan(0)
    expect(screen.getByRole('link', { name: 'Edit report' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Submit for review' })).not.toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Delete report' })).toBeInTheDocument()
  })

  it.each(['submitted', 'approved'] as const)(
    'keeps a %s report read-only in My Work',
    async (status) => {
      renderPage(reportWithStatus(status))

      await screen.findAllByText('Inspected the foundation.')
      expect(screen.queryByRole('link', { name: 'Edit report' })).not.toBeInTheDocument()
      expect(screen.queryByRole('button', { name: 'Submit for review' })).not.toBeInTheDocument()
      expect(screen.queryByRole('button', { name: 'Delete report' })).not.toBeInTheDocument()
    },
  )

  it('confirms before submitting and shows success only after the server responds', async () => {
    const user = userEvent.setup()
    const submit = vi
      .spyOn(siteReportsApi, 'submit')
      .mockResolvedValue(reportWithStatus('submitted'))
    renderPage()

    await user.click(await screen.findByRole('button', { name: 'Submit for review' }))
    expect(screen.getByRole('dialog', { name: 'Submit site report?' })).toBeInTheDocument()
    expect(screen.getByRole('dialog', { name: 'Submit site report?' })).toHaveClass(
      'max-w-[30rem]',
      'max-h-[calc(100dvh-2rem)]',
      '-translate-y-1/2',
    )
    expect(submit).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Submit report' }))
    await waitFor(() => expect(submit).toHaveBeenCalledWith('engineering', 91))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Report submitted', tone: 'success' }),
    )
  })

  it('keeps the confirmation open and presents server validation errors', async () => {
    const user = userEvent.setup()
    vi.spyOn(siteReportsApi, 'submit').mockRejectedValue(
      new ApiError('Only draft reports can be submitted.', { status: 400 }),
    )
    renderPage()

    await user.click(await screen.findByRole('button', { name: 'Submit for review' }))
    await user.click(screen.getByRole('button', { name: 'Submit report' }))

    expect(await screen.findByText('Only draft reports can be submitted.')).toBeInTheDocument()
    expect(screen.getByRole('dialog', { name: 'Submit site report?' })).toBeInTheDocument()
    expect(showToast).not.toHaveBeenCalled()
  })

  it('confirms deletion before deleting and returns to the site tab after success', async () => {
    const user = userEvent.setup()
    const remove = vi.spyOn(siteReportsApi, 'remove').mockResolvedValue({ detail: 'Deleted.' })
    renderPage()

    await user.click(await screen.findByRole('button', { name: 'Delete report' }))
    expect(screen.getByRole('dialog', { name: 'Delete site report?' })).toBeInTheDocument()
    expect(remove).not.toHaveBeenCalled()

    await user.click(screen.getAllByRole('button', { name: /^Delete report$/ }).at(-1)!)
    await waitFor(() => expect(remove).toHaveBeenCalledWith('engineering', 91))
    await waitFor(() =>
      expect(routeState.navigate).toHaveBeenCalledWith(
        expect.objectContaining({
          to: '/dashboard/my-reports',
          search: expect.objectContaining({
            type: 'site',
            status: 'approved',
            page: 3,
          }),
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Report deleted', tone: 'success' }),
    )
  })

  it('shows distinct expired-session and permission errors for failed mutations', async () => {
    const user = userEvent.setup()
    vi.spyOn(siteReportsApi, 'submit').mockRejectedValue(
      new ApiError('Unauthorized', { status: 401 }),
    )
    const firstView = renderPage()

    await user.click(await screen.findByRole('button', { name: 'Submit for review' }))
    await user.click(screen.getByRole('button', { name: 'Submit report' }))
    expect(await screen.findByText('Sign in again to continue.')).toBeInTheDocument()

    firstView.unmount()
    queryClient.clear()
    vi.restoreAllMocks()
    showToast.mockReset()
    vi.spyOn(siteReportsApi, 'detail').mockResolvedValue(report)
    vi.spyOn(siteReportsApi, 'submit').mockRejectedValue(new ApiError('Forbidden', { status: 403 }))
    queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, {
      ...session,
      permissions: session.permissions,
    })
    render(
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <QueryClientProvider client={queryClient}>
          <SiteReportDetailPage />
        </QueryClientProvider>
      </ToastContext.Provider>,
    )
    await user.click(await screen.findByRole('button', { name: 'Submit for review' }))
    await user.click(screen.getByRole('button', { name: 'Submit report' }))
    expect(
      await screen.findByText('You do not have permission to complete this action.'),
    ).toBeInTheDocument()
  })

  it('edits a rejected engineering report and returns it to details after the server saves it', async () => {
    const user = userEvent.setup()
    routeState.search = {
      ...routeState.search,
      status: 'approved',
      page: 3,
      type: 'daily',
    }
    const updated = {
      ...reportWithStatus('draft'),
      summary: 'Rechecked the north foundation.',
      activities: [
        { id: 1, activity_type: 'concrete_work', description: 'Rechecked the north foundation.' },
      ],
    }
    const update = vi.spyOn(siteReportsApi, 'update').mockResolvedValue(updated)
    renderEditPage(reportWithStatus('rejected'))

    const activity = await screen.findByRole('textbox', { name: /Activity 1/ })
    expect(activity).toHaveValue('Inspected the foundation.')
    expect(screen.getByLabelText(/Report date/)).toHaveValue('2026-10-27')
    expect(screen.getByLabelText(/Expense name/)).toHaveValue('Site transport')
    expect(screen.getByLabelText(/Amount \(NGN\)/)).toHaveValue('1500')
    expect(screen.getByLabelText(/Quantity \(hours\)/)).toHaveValue('2')
    expect(screen.getByText(/Saving your changes returns this report to Draft/)).toBeInTheDocument()
    await user.clear(activity)
    await user.type(activity, 'Rechecked the north foundation.')
    await user.clear(screen.getByLabelText(/Amount \(NGN\)/))
    await user.type(screen.getByLabelText(/Amount \(NGN\)/), '1750')
    await user.clear(screen.getByLabelText(/Quantity \(hours\)/))
    await user.type(screen.getByLabelText(/Quantity \(hours\)/), '3')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(
        'engineering',
        91,
        expect.objectContaining({
          date: '2026-10-27',
          activities: [
            { activity_type: 'concrete_work', description: 'Rechecked the north foundation.' },
          ],
          expenses: [
            {
              expense_category: 'labour',
              name: 'Site transport',
              amount: '1750',
              description: 'Vehicle fuel.',
            },
          ],
          materials_used: [{ equipment_id: 5, quantity_used: '3' }],
        }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Report saved', tone: 'success' }),
    )
    expect(routeState.navigate).toHaveBeenCalledWith(
      expect.objectContaining({
        to: '/dashboard/my-reports/site/$reportType/$reportId',
        search: expect.objectContaining({ type: 'site', status: 'approved', page: 3 }),
      }),
    )
  })

  it('hydrates saved report fields when mounted under React StrictMode', async () => {
    renderEditPage(report, session.permissions, true)

    expect(await screen.findByRole('textbox', { name: /Activity 1/ })).toHaveValue(
      'Inspected the foundation.',
    )
    expect(screen.getByLabelText(/Report date/)).toHaveValue('2026-10-27')
    expect(screen.getByLabelText(/Expense name/)).toHaveValue('Site transport')
    expect(screen.getByLabelText(/Amount \(NGN\)/)).toHaveValue('1500')
    expect(screen.getByLabelText(/Quantity \(hours\)/)).toHaveValue('2')
    expect(screen.getByLabelText(/Attachment links/)).toHaveValue(
      'https://files.example.com/site-photo.jpg',
    )
  })

  it('edits survey bearing points and retains expenses and materials in the update payload', async () => {
    const user = userEvent.setup()
    routeState.reportType = 'survey'
    const surveyReport: SiteReport = {
      ...report,
      work_data_type: 'bearing_distance',
      measurement_unit: 'metres',
      coordinate_system: 'UTM',
      datum: 'WGS84',
      coordinate_zone: '32N',
      bearing_distance_points: [
        {
          id: 9,
          point_number: 1,
          azimuth_degrees: 30,
          azimuth_minutes: 10,
          azimuth_seconds: '5.25',
          distance: '12.4',
        },
      ],
      xyz_points: [],
    }
    const update = vi.spyOn(siteReportsApi, 'update').mockResolvedValue(surveyReport)
    renderEditPage(surveyReport)

    expect(await screen.findByLabelText(/Degrees/)).toHaveValue('30')
    expect(screen.getByLabelText(/Minutes/)).toHaveValue('10')
    expect(screen.getByLabelText(/Seconds/)).toHaveValue('5.25')
    expect(screen.getByLabelText(/Distance \(metres\)/)).toHaveValue('12.4')
    await user.clear(screen.getByLabelText(/Distance \(metres\)/))
    await user.type(screen.getByLabelText(/Distance \(metres\)/), '15.5')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(
        'survey',
        91,
        expect.objectContaining({
          expenses: [
            {
              expense_category: 'labour',
              name: 'Site transport',
              amount: '1500',
              description: 'Vehicle fuel.',
            },
          ],
          materials_used: [{ equipment_id: 5, quantity_used: '2' }],
          bearing_distance_points: [
            {
              point_number: 1,
              azimuth_degrees: 30,
              azimuth_minutes: 10,
              azimuth_seconds: '5.25',
              distance: '15.5',
            },
          ],
        }),
      ),
    )
  })

  it('blocks invalid expense and measurement values before sending an update', async () => {
    const user = userEvent.setup()
    routeState.reportType = 'survey'
    const surveyReport: SiteReport = {
      ...report,
      work_data_type: 'bearing_distance',
      bearing_distance_points: [
        {
          id: 9,
          point_number: 1,
          azimuth_degrees: 30,
          azimuth_minutes: 10,
          azimuth_seconds: '5',
          distance: '12',
        },
      ],
    }
    const update = vi.spyOn(siteReportsApi, 'update')
    renderEditPage(surveyReport)

    await user.clear(await screen.findByLabelText(/Amount \(NGN\)/))
    await user.type(screen.getByLabelText(/Amount \(NGN\)/), '-1')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    expect(
      await screen.findByText('Complete each expense and enter an amount greater than zero.'),
    ).toBeInTheDocument()
    expect(update).not.toHaveBeenCalled()
  })
})
