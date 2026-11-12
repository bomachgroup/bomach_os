import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  reportType: 'engineering',
  search: { type: 'all', status: 'all', page: 1 },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    Link: ({ to, children, className }: { to: string; children: ReactNode; className?: string }) =>
      createElement('a', { href: to, className }, children),
    useNavigate: () => routeState.navigate,
    useParams: () => ({ reportType: routeState.reportType }),
    useSearch: () => routeState.search,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { ToastContext } from '@/shared/feedback/toast-context'
import { siteReportsApi, type SiteReport } from '../site-reports.api'
import { workReportsApi } from '../work-reports.api'
import { SiteReportCreatePage } from './site-report-create-page'

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
    engineering_site_reports: ['create'],
    survey_site_reports: ['create'],
    worksites: ['list'],
  },
}

const worksite = {
  id: 6,
  project_id: 4,
  name: 'North worksite',
  location: 'Lagos',
  status: 'active',
}

let queryClient: QueryClient
const showToast = vi.fn()
const dismissToast = vi.fn()

function renderPage(permissions = session.permissions) {
  queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast }}>
      <QueryClientProvider client={queryClient}>
        <SiteReportCreatePage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

async function chooseWorksite(user: ReturnType<typeof userEvent.setup>) {
  await user.click(await screen.findByRole('combobox', { name: 'Worksite' }))
  await user.click(await screen.findByRole('option', { name: 'North worksite' }))
}

async function continueStep(user: ReturnType<typeof userEvent.setup>) {
  await user.click(screen.getByRole('button', { name: 'Continue' }))
}

async function waitForReviewReady() {
  await screen.findByRole('heading', { name: 'Review your report' })
  expect(screen.getByRole('group', { name: 'Report summary' })).toBeInTheDocument()
  expect(screen.getByText(/Open the saved report to submit it for review/)).toBeInTheDocument()
  expect(screen.getByText('Create')).toHaveClass('tablet:hidden')
  expect(screen.getByText('Create report')).toHaveClass('hidden', 'tablet:inline')
  await waitFor(() => expect(screen.getByRole('button', { name: 'Create report' })).toBeEnabled())
}

async function moveEngineeringToReview(user: ReturnType<typeof userEvent.setup>) {
  await chooseWorksite(user)
  await continueStep(user)
  await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Poured the footing.')
  await continueStep(user)
  await continueStep(user)
  await continueStep(user)
  await waitForReviewReady()
}

describe('SiteReportCreatePage', () => {
  beforeEach(() => {
    routeState.reportType = 'engineering'
    routeState.search = { type: 'all', status: 'all', page: 1 }
    routeState.navigate.mockReset()
    showToast.mockReset()
    dismissToast.mockReset()
    vi.spyOn(siteReportsApi, 'listWorksites').mockResolvedValue([worksite])
    vi.spyOn(siteReportsApi, 'listProjectTasks').mockResolvedValue([
      { id: 9, project_id: 4, title: 'Foundation inspection' },
    ])
    vi.spyOn(siteReportsApi, 'listEquipment').mockResolvedValue([
      { id: 11, worksite_id: 6, name: 'Concrete mixer', unit: 'hours', quantity: '12' },
    ])
    vi.spyOn(siteReportsApi, 'create').mockResolvedValue({ id: 88 } as SiteReport)
    vi.spyOn(workReportsApi, 'upload').mockResolvedValue({
      url: 'https://files.example.test/site-photo.jpg',
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('explains that a worksite is required and provides a return path when none are assigned', async () => {
    const user = userEvent.setup()
    vi.spyOn(siteReportsApi, 'listWorksites').mockResolvedValue([])
    renderPage()

    expect(
      await screen.findByRole('heading', { name: 'No worksite is assigned to you' }),
    ).toBeVisible()
    expect(
      screen.getByText(/Ask an administrator to add or assign one to your access scope/),
    ).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Create report' })).not.toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Back to My Work Reports' }))
    expect(routeState.navigate).toHaveBeenCalledWith(
      expect.objectContaining({
        to: '/dashboard/my-reports',
        search: expect.objectContaining({ type: 'engineering' }),
      }),
    )
  })

  it('uses the shared calendar dropdown and preserves a selected date while advancing', async () => {
    const user = userEvent.setup()
    renderPage()
    const dateTrigger = await screen.findByRole('button', { name: 'Report date' })

    await user.click(dateTrigger)
    expect(screen.getByRole('dialog', { name: 'Choose a date' })).toBeVisible()
    const nextDay = new Date()
    nextDay.setDate(nextDay.getDate() + 1)
    const accessibleDate = new Intl.DateTimeFormat(undefined, {
      weekday: 'long',
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    }).format(nextDay)
    await user.click(await screen.findByRole('button', { name: accessibleDate }))

    expect(dateTrigger).toHaveTextContent(
      new Intl.DateTimeFormat(undefined, {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(nextDay),
    )
    await waitFor(() => expect(dateTrigger).toHaveFocus())
    await chooseWorksite(user)
    await continueStep(user)
    expect(await screen.findAllByRole('heading', { name: 'Activities' })).toHaveLength(2)
  })

  it('validates the report context before allowing the user to advance', async () => {
    const user = userEvent.setup()
    renderPage()
    await screen.findByRole('button', { name: 'Report date' })

    await continueStep(user)

    const worksiteField = screen.getByRole('combobox', { name: 'Worksite' })
    expect(await screen.findByRole('status')).toHaveTextContent(
      'Choose a worksite for this report.',
    )
    expect(worksiteField).toHaveAttribute('aria-invalid', 'true')
    expect(worksiteField).toHaveAttribute('aria-describedby', 'site-create-worksite-error')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    expect(screen.queryByRole('heading', { name: 'Activities' })).not.toBeInTheDocument()
    expect(siteReportsApi.create).not.toHaveBeenCalled()
  })

  it('does not create a report when the form receives a submit outside the review stage', async () => {
    renderPage()
    await screen.findByRole('button', { name: 'Report date' })
    const form = screen.getByRole('button', { name: 'Continue' }).closest('form')
    expect(form).not.toBeNull()

    fireEvent.submit(form!)

    const worksiteField = screen.getByRole('combobox', { name: 'Worksite' })
    expect(await screen.findByRole('status')).toHaveTextContent(
      'Choose a worksite for this report.',
    )
    expect(worksiteField).toHaveAttribute('aria-invalid', 'true')
    expect(worksiteField).toHaveAttribute('aria-describedby', 'site-create-worksite-error')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    expect(siteReportsApi.create).not.toHaveBeenCalled()
  })

  it('does not load or show task and equipment controls without their list permissions', async () => {
    const user = userEvent.setup()
    renderPage({
      engineering_site_reports: ['create'],
      worksites: ['list'],
    })

    await chooseWorksite(user)
    expect(screen.queryByRole('combobox', { name: 'Task (optional)' })).not.toBeInTheDocument()
    await continueStep(user)
    expect(screen.queryByRole('button', { name: 'Add material' })).not.toBeInTheDocument()
    expect(siteReportsApi.listProjectTasks).not.toHaveBeenCalled()
    expect(siteReportsApi.listEquipment).not.toHaveBeenCalled()
  })

  it('blocks the create route when the matching report permission is missing', async () => {
    renderPage({ worksites: ['list'] })

    expect(
      await screen.findByRole('heading', { name: 'You can’t create this report' }),
    ).toBeVisible()
    expect(screen.queryByRole('button', { name: 'Continue' })).not.toBeInTheDocument()
    expect(siteReportsApi.listWorksites).not.toHaveBeenCalled()
  })

  it('creates an Engineering report from the final review stage', async () => {
    const user = userEvent.setup()
    renderPage({
      engineering_site_reports: ['create'],
      worksites: ['list'],
    })
    await moveEngineeringToReview(user)
    expect(screen.getByText('Poured the footing.')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Create report' }))

    await waitFor(() =>
      expect(siteReportsApi.create).toHaveBeenCalledWith('engineering', {
        worksite_id: 6,
        project_id: 4,
        date: expect.any(String),
        expenses: [],
        attachments: [],
        tomorrow_activities: '',
        comments_suggestions: '',
        activities: [{ activity_type: 'concrete_work', description: 'Poured the footing.' }],
      }),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Report created', tone: 'success' }),
    )
    expect(routeState.navigate).toHaveBeenCalledWith(
      expect.objectContaining({
        to: '/dashboard/my-reports/site/$reportType/$reportId',
        params: { reportType: 'engineering', reportId: '88' },
      }),
    )
  })

  it('creates a Survey report with task, bearing, and inventory fields', async () => {
    const user = userEvent.setup()
    routeState.reportType = 'survey'
    renderPage({
      survey_site_reports: ['create'],
      worksites: ['list'],
      tasks: ['list'],
      site_equipment: ['list'],
    })
    await chooseWorksite(user)
    await user.click(await screen.findByRole('combobox', { name: 'Task (optional)' }))
    await user.click(await screen.findByRole('option', { name: 'Foundation inspection' }))
    await continueStep(user)
    await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Checked the boundary.')
    await user.type(screen.getByRole('textbox', { name: 'Degrees' }), '40')
    await user.type(screen.getByRole('textbox', { name: 'Minutes' }), '12')
    await user.type(screen.getByRole('textbox', { name: 'Seconds' }), '4')
    await user.type(screen.getByRole('textbox', { name: 'Distance (metres)' }), '15.5')
    await continueStep(user)
    await user.click(screen.getByRole('button', { name: 'Add material' }))
    await user.click(screen.getByRole('combobox', { name: 'Material 1 inventory item' }))
    await user.click(await screen.findByRole('option', { name: 'Concrete mixer · 12 hours' }))
    await user.type(screen.getByRole('textbox', { name: 'Quantity used' }), '2')
    await continueStep(user)
    await continueStep(user)
    await waitForReviewReady()
    await user.click(screen.getByRole('button', { name: 'Create report' }))

    await waitFor(() =>
      expect(siteReportsApi.create).toHaveBeenCalledWith(
        'survey',
        expect.objectContaining({
          worksite_id: 6,
          project_id: 4,
          task_id: 9,
          work_data_type: 'bearing_distance',
          measurement_unit: 'metres',
          activities: [{ description: 'Checked the boundary.' }],
          bearing_distance_points: [
            {
              point_number: 1,
              azimuth_degrees: 40,
              azimuth_minutes: 12,
              azimuth_seconds: '4',
              distance: '15.5',
            },
          ],
          materials_used: [{ equipment_id: 11, quantity_used: '2' }],
        }),
      ),
    )
  })

  it('creates a Survey report with XYZ points when that measurement format is selected', async () => {
    const user = userEvent.setup()
    routeState.reportType = 'survey'
    renderPage({ survey_site_reports: ['create'], worksites: ['list'] })
    await chooseWorksite(user)
    await continueStep(user)
    await user.click(screen.getByRole('combobox', { name: 'Measurement format' }))
    await user.click(await screen.findByRole('option', { name: 'Site points (XYZ)' }))
    await user.type(screen.getByRole('textbox', { name: 'Northing' }), '681234.5')
    await user.type(screen.getByRole('textbox', { name: 'Easting' }), '51234.25')
    await user.type(screen.getByRole('textbox', { name: 'Elevation' }), '-2.75')
    await user.type(
      screen.getByRole('textbox', { name: 'Activity 1' }),
      'Mapped the eastern boundary.',
    )
    await continueStep(user)
    await continueStep(user)
    await continueStep(user)
    await waitForReviewReady()
    await user.click(screen.getByRole('button', { name: 'Create report' }))

    await waitFor(() =>
      expect(siteReportsApi.create).toHaveBeenCalledWith(
        'survey',
        expect.objectContaining({
          work_data_type: 'site_points_xyz',
          xyz_points: [
            {
              point_number: 1,
              northing: '681234.5',
              easting: '51234.25',
              elevation: '-2.75',
            },
          ],
          activities: [{ description: 'Mapped the eastern boundary.' }],
        }),
      ),
    )
  })

  it('blocks incomplete survey measurements and enforces coordinate boundaries', async () => {
    const user = userEvent.setup()
    routeState.reportType = 'survey'
    renderPage({ survey_site_reports: ['create'], worksites: ['list'] })
    await chooseWorksite(user)
    await continueStep(user)
    await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Recorded the boundary.')

    await continueStep(user)
    const degreesField = screen.getByRole('textbox', { name: 'Degrees' })
    expect(await screen.findByRole('status')).toHaveTextContent('Add a complete bearing point')
    expect(degreesField).toHaveAttribute('aria-invalid', 'true')
    expect(degreesField).toHaveAttribute('aria-describedby', 'site-create-bearing-degrees-0-error')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    expect(siteReportsApi.create).not.toHaveBeenCalled()

    await user.type(screen.getByRole('textbox', { name: 'Degrees' }), '359')
    await user.type(screen.getByRole('textbox', { name: 'Minutes' }), '59')
    await user.type(screen.getByRole('textbox', { name: 'Seconds' }), '59.9')
    await user.type(screen.getByRole('textbox', { name: 'Distance (metres)' }), '0.1')
    await user.type(screen.getByRole('textbox', { name: 'GPS latitude' }), '90.1')
    await user.type(screen.getByRole('textbox', { name: 'GPS longitude' }), '180')

    await continueStep(user)
    const latitudeField = screen.getByRole('textbox', { name: 'GPS latitude' })
    expect(await screen.findByRole('status')).toHaveTextContent('Enter both GPS coordinates')
    expect(latitudeField).toHaveAttribute('aria-invalid', 'true')
    expect(latitudeField).toHaveAttribute('aria-describedby', 'site-create-gps-latitude-error')
    await user.clear(screen.getByRole('textbox', { name: 'GPS latitude' }))
    await user.type(screen.getByRole('textbox', { name: 'GPS latitude' }), '-90')
    await continueStep(user)
    expect(await screen.findAllByRole('heading', { name: 'Expenses and materials' })).toHaveLength(
      2,
    )
  })

  it('validates expense amounts and rejects unsafe or oversized evidence files', async () => {
    const user = userEvent.setup()
    renderPage({ engineering_site_reports: ['create'], worksites: ['list'] })
    await chooseWorksite(user)
    await continueStep(user)
    await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Completed inspection.')
    await continueStep(user)
    await user.click(screen.getByRole('button', { name: 'Add expense' }))
    await user.type(screen.getByRole('textbox', { name: 'Expense name' }), 'Fuel')
    await user.type(screen.getByRole('textbox', { name: 'Amount (NGN)' }), '0')
    await user.type(screen.getByRole('textbox', { name: 'Description' }), 'Generator fuel')
    await continueStep(user)

    const amountField = screen.getByRole('textbox', { name: 'Amount (NGN)' })
    expect(await screen.findByRole('status')).toHaveTextContent('enter an amount greater than zero')
    expect(amountField).toHaveAttribute('aria-invalid', 'true')
    expect(amountField).toHaveAttribute('aria-describedby', 'site-create-expense-amount-0-error')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
    await user.clear(screen.getByRole('textbox', { name: 'Amount (NGN)' }))
    await user.type(screen.getByRole('textbox', { name: 'Amount (NGN)' }), '2500')
    await continueStep(user)
    const executable = new File(['not executable'], 'payload.exe', {
      type: 'application/octet-stream',
    })
    await user.upload(screen.getByLabelText('Supporting evidence files'), executable)
    expect(await screen.findByRole('alert')).toHaveTextContent('executable files are not allowed')

    const oversized = new File(['large'], 'oversized.pdf', { type: 'application/pdf' })
    Object.defineProperty(oversized, 'size', { value: 15 * 1024 * 1024 + 1 })
    await user.upload(screen.getByLabelText('Supporting evidence files'), oversized)
    expect(await screen.findByRole('alert')).toHaveTextContent('under 15 MB')

    const validFile = new File(['photo'], 'site-photo.jpg', { type: 'image/jpeg' })
    await user.upload(screen.getByLabelText('Supporting evidence files'), validFile)
    expect(screen.getByText('site-photo.jpg')).toBeInTheDocument()
    await continueStep(user)
    await waitForReviewReady()
  })

  it('uploads selected evidence before creating and includes the returned file URL', async () => {
    const user = userEvent.setup()
    renderPage({ engineering_site_reports: ['create'], worksites: ['list'] })
    await chooseWorksite(user)
    await continueStep(user)
    await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Completed inspection.')
    await continueStep(user)
    await continueStep(user)

    const file = new File(['site photo'], 'site-photo.jpg', { type: 'image/jpeg' })
    await user.upload(screen.getByLabelText('Supporting evidence files'), file)
    await continueStep(user)
    await waitForReviewReady()
    expect(screen.getByRole('heading', { name: 'Attachments' })).toBeInTheDocument()
    expect(workReportsApi.upload).not.toHaveBeenCalled()

    await user.click(screen.getByRole('button', { name: 'Create report' }))

    await waitFor(() => expect(workReportsApi.upload).toHaveBeenCalledWith(file))
    await waitFor(() =>
      expect(siteReportsApi.create).toHaveBeenCalledWith(
        'engineering',
        expect.objectContaining({ attachments: ['https://files.example.test/site-photo.jpg'] }),
      ),
    )
  })

  it('keeps selected files and report details when file upload fails', async () => {
    const user = userEvent.setup()
    vi.spyOn(workReportsApi, 'upload').mockRejectedValue(new Error('Storage is unavailable.'))
    renderPage({ engineering_site_reports: ['create'], worksites: ['list'] })
    await chooseWorksite(user)
    await continueStep(user)
    await user.type(screen.getByRole('textbox', { name: 'Activity 1' }), 'Checked the slab.')
    await continueStep(user)
    await continueStep(user)
    const file = new File(['site photo'], 'site-photo.jpg', { type: 'image/jpeg' })
    await user.upload(screen.getByLabelText('Supporting evidence files'), file)
    await continueStep(user)
    await waitForReviewReady()
    await user.click(screen.getByRole('button', { name: 'Create report' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('could not be uploaded')
    expect(siteReportsApi.create).not.toHaveBeenCalled()
    expect(screen.getByText('site-photo.jpg')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    expect(screen.getByRole('textbox', { name: 'Activity 1' })).toHaveValue('Checked the slab.')
  })

  it('keeps entered values when the server rejects creation and allows returning to edit them', async () => {
    const user = userEvent.setup()
    vi.spyOn(siteReportsApi, 'create').mockRejectedValue(
      new Error('The worksite is no longer available.'),
    )
    renderPage({ engineering_site_reports: ['create'], worksites: ['list'] })
    await moveEngineeringToReview(user)
    await user.click(screen.getByRole('button', { name: 'Create report' }))

    expect(await screen.findByRole('alert')).toHaveTextContent('Your entries are still here.')
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    await user.click(screen.getByRole('button', { name: 'Previous' }))
    expect(screen.getByRole('textbox', { name: 'Activity 1' })).toHaveValue('Poured the footing.')
    expect(showToast).not.toHaveBeenCalled()
    expect(routeState.navigate).not.toHaveBeenCalled()
  })

  it('shows server validation errors beside their field and returns to that step', async () => {
    const user = userEvent.setup()
    vi.spyOn(siteReportsApi, 'create').mockRejectedValue(
      new ApiError('The report has invalid fields.', {
        status: 400,
        fieldErrors: { 'activities.0.description': 'Add a more detailed activity.' },
      }),
    )
    renderPage({ engineering_site_reports: ['create'], worksites: ['list'] })
    await moveEngineeringToReview(user)
    await user.click(screen.getByRole('button', { name: 'Create report' }))

    const activityField = await screen.findByRole('textbox', { name: 'Activity 1' })
    expect(await screen.findByRole('status')).toHaveTextContent('Add a more detailed activity.')
    expect(activityField).toHaveAttribute('aria-invalid', 'true')
    expect(activityField).toHaveAttribute('aria-describedby', 'site-create-activity-0-error')
    expect(screen.queryByRole('alert')).not.toBeInTheDocument()
  })
})
