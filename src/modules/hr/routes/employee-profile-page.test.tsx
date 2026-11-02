import { createElement, type ReactNode } from 'react'
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

import { auditLogApi } from '@/modules/company/audit-log.api'
import { employeesApi, type EmployeeDto, type ManagedTaskDto } from '@/modules/hr/employees.api'
import { validateEmployeeProfileSearch } from '@/modules/hr/employees.search'
import { workReportsApi } from '@/modules/work-reports/work-reports.api'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'

import { EmployeeProfilePage } from './employee-profile-page'

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

const employee = {
  id: 23,
  user_id: 52,
  employee_id: 'EMP-052',
  username: 'amaka.okafor',
  email: 'amaka@example.test',
  first_name: 'Amaka',
  middle_name: 'Chidinma',
  last_name: 'Okafor',
  gender: 'female',
  marital_status: 'single',
  nationality: 'Nigerian',
  phone_number: null,
  other_phone: null,
  personal_email: null,
  date_of_birth: null,
  address: null,
  city: '',
  state: '',
  zip_code: '',
  country: '',
  profile_picture: null,
  is_active: true,
  employment_is_active: true,
  account_is_active: true,
  emergency_contact_name: '',
  emergency_contact_relationship: '',
  emergency_contact_phone: '',
  designation: 'Operations Analyst',
  employment_type: 'full-time',
  employment_status: 'active',
  branch_id: 3,
  branch_name: 'Lagos HQ',
  department_id: 8,
  department_name: 'Operations',
  department_units: [],
  role_id: 6,
  role_name: 'Operations Analyst',
  location: 'Lagos',
  reporting_to_id: null,
  start_date: '2024-01-15',
  probation_period: null,
  work_schedule: '',
  gross_salary: null,
  salary_frequency: 'monthly',
  allowances: null,
  bank_name: '',
  account_number: '',
  tax_id: '',
  pension_number: '',
  pfa_provider: '',
  rsa_number: '',
  employer_contribution: null,
  hmo_current_plan: '',
  hmo_id_number: '',
  hmo_dependents_covered: 0,
} satisfies EmployeeDto

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
    permissions: {},
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
  permissions: {
    employees: ['view', 'update', 'exit'],
    employee_documents: ['view', 'upload', 'delete'],
    employee_reviews: ['list', 'create', 'update', 'delete'],
    employee_kpis: ['list'],
    employee_targets: ['list'],
    audit_logs: ['list'],
    monthly_scorecards: ['view'],
    performance_reviews: ['list'],
    tasks: ['list'],
    work_reports: ['list'],
  },
}

let queryClient: QueryClient

function renderProfile(activeSession = session) {
  queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false, gcTime: 0 },
      mutations: { retry: false },
    },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, activeSession)
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const profileRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/hr/employees/$userId',
    validateSearch: validateEmployeeProfileSearch,
    component: EmployeeProfilePage,
  })
  const router = createRouter({
    routeTree: root.addChildren([protectedRoute.addChildren([profileRoute])]),
    history: createMemoryHistory({ initialEntries: ['/hr/employees/52?section=profile'] }),
  })
  return render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(
        ToastContext.Provider,
        { value: { showToast: vi.fn(), dismissToast: vi.fn() } },
        createElement(RouterProvider, { router }),
      ),
    ) as ReactNode,
  )
}

beforeEach(() => {
  vi.spyOn(employeesApi, 'get').mockResolvedValue(employee)
  vi.spyOn(employeesApi, 'documents').mockResolvedValue([])
  vi.spyOn(employeesApi, 'leavePeriods').mockResolvedValue([])
  vi.spyOn(employeesApi, 'reviews').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(employeesApi, 'performancePlan').mockResolvedValue({
    employee_id: 52,
    role_id: 6,
    period_start: '2026-01-01',
    period_end: '2026-12-31',
    revision: null,
    effective_from: null,
    source: 'role_default',
    kpis: [],
    targets: [],
  })
  vi.spyOn(employeesApi, 'scorecard').mockResolvedValue({
    id: 1,
    employee_id: 23,
    employee_name: 'Amaka Okafor',
    employee_level: null,
    is_auto_generated: false,
    month: 10,
    year: 2026,
    attendance_score: 100,
    task_delivery_score: 100,
    report_accuracy_score: 100,
    brand_contribution_score: 100,
    training_progress_score: 100,
    overall_score: 100,
    target_score: 100,
    target_achievement: 100,
    ranking: null,
    notes: '',
  })
  vi.spyOn(employeesApi, 'performanceReviews').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(employeesApi, 'tasks').mockResolvedValue({
    count: 1,
    items: [
      {
        id: 14,
        name: 'Prepare weekly operations report',
        description: null,
        status: 'in_progress',
        priority: 'normal',
        due_date: '2026-11-02',
        assigned_to: [23],
        created_at: '2026-10-01T00:00:00Z',
      } satisfies ManagedTaskDto,
    ],
  })
  vi.spyOn(auditLogApi, 'list').mockResolvedValue({ count: 0, items: [] })
  vi.spyOn(workReportsApi, 'list').mockResolvedValue({ count: 0, items: [] })
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('EmployeeProfilePage', () => {
  it('keeps all permitted profile sections reachable and loads each section', async () => {
    const user = userEvent.setup()
    renderProfile()

    await waitFor(() => expect(employeesApi.get).toHaveBeenCalledWith(52, expect.any(AbortSignal)))
    expect(await screen.findByRole('heading', { name: 'Amaka Chidinma Okafor' })).toBeVisible()
    expect(await screen.findByRole('heading', { name: 'Personal information' })).toBeVisible()
    expect(screen.getByRole('link', { name: 'Back to employees' })).toHaveClass(
      'size-10',
      'border',
      'bg-surface',
    )
    const tablist = screen.getByRole('tablist', { name: 'Employee profile sections' })
    expect(within(tablist).getAllByRole('tab')).toHaveLength(9)
    expect(tablist).toHaveClass('grid-cols-2')

    const tabAndHeading: Array<[string, string]> = [
      ['Documents', 'Employee documents'],
      ['Reviews', 'Performance reviews'],
      ['Benefits', 'Compensation'],
      ['Performance plan', 'Performance plan'],
      ['Activity', 'Employee activity'],
      ['Tasks', 'Assigned tasks'],
      ['Work reports', 'Work reports'],
      ['Leave', 'Leave history'],
    ]
    for (const [tabName, heading] of tabAndHeading) {
      const tab = within(tablist).getByRole('tab', { name: tabName })
      await user.click(tab)
      expect(await screen.findByRole('heading', { name: heading })).toBeVisible()
      expect(tab).toHaveAttribute('aria-selected', 'true')
      expect(screen.getByRole('tabpanel')).toHaveAttribute('aria-labelledby', tab.id)
    }

    expect(employeesApi.documents).toHaveBeenCalledWith(52, expect.any(AbortSignal))
    expect(employeesApi.reviews).toHaveBeenCalledWith(52, expect.any(AbortSignal))
    expect(employeesApi.performancePlan).toHaveBeenCalledWith(
      52,
      expect.stringMatching(/^\d{4}-01-01$/),
      expect.stringMatching(/^\d{4}-12-31$/),
      expect.any(AbortSignal),
    )
    expect(employeesApi.tasks).toHaveBeenCalledWith(52, expect.any(AbortSignal))
    expect(employeesApi.leavePeriods).toHaveBeenCalledWith(52, expect.any(AbortSignal))
    expect(workReportsApi.list).toHaveBeenCalledWith(
      expect.objectContaining({ employeeId: 23 }),
      expect.any(AbortSignal),
    )
  }, 20000)

  it('hides restricted profile sections rather than rendering inaccessible tabs', async () => {
    const limited = {
      ...session,
      permissions: { employees: ['view'] },
    } satisfies AuthenticatedSession
    queryClient = new QueryClient({ defaultOptions: { queries: { retry: false, gcTime: 0 } } })
    queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, limited)
    vi.mocked(employeesApi.get).mockResolvedValue(employee)

    const root = createRootRoute()
    const protectedRoute = createRoute({
      getParentRoute: () => root,
      id: '_protected',
      component: Outlet,
    })
    const profileRoute = createRoute({
      getParentRoute: () => protectedRoute,
      path: '/hr/employees/$userId',
      validateSearch: validateEmployeeProfileSearch,
      component: EmployeeProfilePage,
    })
    const router = createRouter({
      routeTree: root.addChildren([protectedRoute.addChildren([profileRoute])]),
      history: createMemoryHistory({ initialEntries: ['/hr/employees/52?section=documents'] }),
    })
    render(
      <QueryClientProvider client={queryClient}>
        <ToastContext.Provider value={{ showToast: vi.fn(), dismissToast: vi.fn() }}>
          <RouterProvider router={router} />
        </ToastContext.Provider>
      </QueryClientProvider>,
    )

    expect(await screen.findByRole('tab', { name: 'Profile' })).toHaveAttribute(
      'aria-selected',
      'true',
    )
    const tablist = screen.getByRole('tablist', { name: 'Employee profile sections' })
    expect(within(tablist).getAllByRole('tab')).toHaveLength(2)
    expect(within(tablist).queryByRole('tab', { name: 'Documents' })).not.toBeInTheDocument()
    expect(within(tablist).queryByRole('tab', { name: 'Tasks' })).not.toBeInTheDocument()
  })

  it('renders performance-plan items as readable KPI and target cards instead of raw API data', async () => {
    const user = userEvent.setup()
    vi.mocked(employeesApi.performancePlan).mockResolvedValue({
      employee_id: 52,
      role_id: 6,
      period_start: '2026-01-01',
      period_end: '2026-12-31',
      revision: null,
      effective_from: null,
      source: 'role_default',
      kpis: [
        {
          item_key: 'role-kpi:6',
          kind: 'kpi',
          source: 'role',
          source_id: 6,
          is_customized: false,
          config: {
            name: 'Requests resolved on time',
            description: 'Resolve assigned requests within the agreed timeline.',
            unit: 'percentage',
            tracking_mode: 'manual',
            target_value: '95.00',
            weight: '40.00',
            period: 'monthly',
            is_active: true,
          },
        },
      ],
      targets: [
        {
          item_key: 'role-target:3',
          kind: 'target',
          source: 'role',
          source_id: 3,
          is_customized: false,
          config: {
            title: 'Quarterly milestones',
            description: 'Deliver approved milestones by quarter close.',
            unit: '%',
            target_value: '90.00',
            period: 'quarterly',
            is_active: true,
          },
        },
      ],
    })
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Performance plan' }))

    expect(await screen.findByRole('heading', { name: 'Requests resolved on time' })).toBeVisible()
    expect(screen.getByRole('heading', { name: 'Quarterly milestones' })).toBeVisible()
    expect(screen.getByText('95%')).toBeVisible()
    expect(screen.getByText('40')).toBeVisible()
    expect(screen.queryByText(/"item_key"/)).not.toBeInTheDocument()
    expect(screen.getByText('Role defaults')).toBeVisible()
  })

  it('formats compensation in Nigerian naira and breaks allowances into readable values', async () => {
    const user = userEvent.setup()
    vi.mocked(employeesApi.get).mockResolvedValue({
      ...employee,
      gross_salary: '1250000.00',
      allowances: { housing: 150_000, transport: 50_000, meal: 25_000 },
      employer_contribution: '10',
    })
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Benefits' }))

    expect(await screen.findByText('₦1,250,000.00')).toBeVisible()
    expect(screen.getByText(/^per month$/i)).toBeVisible()
    expect(screen.getByText('Housing')).toBeVisible()
    expect(screen.getByText('₦150,000.00')).toBeVisible()
    expect(screen.getByText('₦50,000.00')).toBeVisible()
    expect(screen.getByText('₦25,000.00')).toBeVisible()
    expect(screen.getByText('10%')).toBeVisible()
    const housingTile = screen.getByText('Housing').parentElement?.parentElement
    expect(housingTile).toHaveClass('flex-col')
    expect(housingTile).toContainElement(screen.getByText('₦150,000.00'))
  })

  it('keeps profile actions compact and opens a dated leave flow instead of changing status directly', async () => {
    const user = userEvent.setup()
    const update = vi.spyOn(employeesApi, 'update').mockResolvedValue(employee)
    renderProfile()

    expect(await screen.findByRole('button', { name: 'Place on leave' })).toBeVisible()
    expect(screen.getByRole('button', { name: 'Suspend access' })).toBeVisible()
    const moreActions = screen.getByRole('button', { name: 'More employee actions' })
    expect(moreActions.closest('.relative.z-10')).not.toBeNull()
    expect(moreActions.closest('.overflow-hidden')).toBeNull()
    await user.click(screen.getByRole('button', { name: 'Place on leave' }))

    expect(await screen.findByRole('dialog', { name: 'Place employee on leave' })).toBeVisible()
    expect(screen.getByLabelText(/^Leave start date/)).toBeVisible()
    expect(screen.getByLabelText(/^Leave type/)).toBeVisible()
    expect(screen.getByLabelText(/^Expected return date/)).toBeVisible()
    expect(screen.queryByLabelText(/^Actual return date/)).not.toBeInTheDocument()
    expect(update).not.toHaveBeenCalled()
    await user.click(screen.getByRole('button', { name: 'Cancel' }))

    await user.click(moreActions)
    expect(screen.getByRole('button', { name: 'Deactivate' })).toBeVisible()
    expect(screen.getByRole('button', { name: 'Exit employee' })).toBeVisible()
  })

  it('places review edit and delete actions in the card footer', async () => {
    const user = userEvent.setup()
    vi.mocked(employeesApi.reviews).mockResolvedValue({
      count: 1,
      items: [
        {
          id: 7,
          employee_id: 52,
          reviewer_id: 9,
          reviewer_name: 'HR Admin',
          quarter: 'Q4',
          year: 2026,
          review_period: 'Q4 2026',
          job_knowledge: 4,
          communication: 5,
          problem_solving: 4,
          teamwork: 5,
          initiative: 4,
          quality_of_work: 5,
          overall_rating: 4.5,
          key_achievements: 'Closed the quarter service goals.',
          areas_for_improvement: 'Continue mentoring new hires.',
          development_plan: 'Complete the leadership module.',
          review_date: '2026-10-28',
        },
      ],
    })
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Reviews' }))

    const article = await screen.findByRole('article')
    expect(within(article).getByText('Closed the quarter service goals.')).toBeVisible()
    expect(within(article).getByText('Continue mentoring new hires.')).toBeVisible()
    const edit = within(article).getByRole('button', { name: 'Edit review' })
    const remove = within(article).getByRole('button', { name: 'Delete' })
    expect(edit.compareDocumentPosition(remove) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy()
    expect(edit.parentElement).toHaveClass('border-t', 'justify-end')
  })

  it('presents multiple documents as compact responsive file cards', async () => {
    const user = userEvent.setup()
    vi.mocked(employeesApi.documents).mockResolvedValue([
      {
        id: 1,
        employee_id: 52,
        name: 'Employment agreement.pdf',
        file_url: 'https://files.example.test/agreement.pdf',
        file_type: 'pdf',
        uploaded_at: '2026-10-28T10:00:00Z',
      },
      {
        id: 2,
        employee_id: 52,
        name: 'Identity verification.docx',
        file_url: 'https://files.example.test/identity.docx',
        file_type: 'docx',
        uploaded_at: '2026-10-27T10:00:00Z',
      },
      {
        id: 3,
        employee_id: 52,
        name: 'Profile photograph.jpg',
        file_url: 'https://files.example.test/photo.jpg',
        file_type: 'jpg',
        uploaded_at: '2026-10-26T10:00:00Z',
      },
    ])
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Documents' }))

    expect(await screen.findByText('3 files')).toBeVisible()
    expect(screen.getByText('Employment agreement.pdf')).toBeVisible()
    expect(screen.getByText('Identity verification.docx')).toBeVisible()
    expect(screen.getByText('Profile photograph.jpg')).toBeVisible()
    expect(screen.getAllByRole('link', { name: /Open file/ })).toHaveLength(3)
  })

  it('links each employee work report to its exact HR review record', async () => {
    const user = userEvent.setup()
    vi.mocked(workReportsApi.list).mockResolvedValue({
      count: 1,
      items: [
        {
          id: 83,
          employeeId: 23,
          employeeName: 'Amaka Okafor',
          day: '2026-10-27',
          hoursWorked: 7.5,
          operationalBase: 'Lagos HQ',
          workActivities: 'Closed the daily service summary.',
          taskDetails: null,
          planNextDay: null,
          summary: 'Closed the daily service summary.',
          status: 'submitted',
          feedback: null,
          rating: null,
          reviewedBy: null,
          reviewedAt: null,
          attachments: [],
          createdAt: '2026-10-27T12:00:00Z',
          updatedAt: '2026-10-27T12:00:00Z',
        },
      ],
    })
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Work reports' }))

    const reviewLink = await screen.findByRole('link', {
      name: 'Open work report from 2026-10-27 for HR review',
    })
    expect(reviewLink.getAttribute('href')).toContain('reportId=83')
    expect(screen.getByRole('link', { name: /Open HR review/ })).toHaveAttribute(
      'href',
      expect.stringContaining('/hr/work-report'),
    )
  })

  it('does not route a manager to the signed-in user’s personal task queue for another employee task', async () => {
    const user = userEvent.setup()
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Tasks' }))

    expect(await screen.findByText('Prepare weekly operations report')).toBeVisible()
    expect(screen.getByText('In progress')).toBeVisible()
    expect(screen.getByText('Project')).toBeVisible()
    expect(screen.getByText('No project')).toBeVisible()
    expect(screen.getByText('Due date')).toBeVisible()
    expect(screen.getByText('Priority')).toBeVisible()
    expect(screen.getByText('Normal')).toBeVisible()
    expect(screen.queryByText('In_progress')).not.toBeInTheDocument()
    expect(screen.queryByRole('link', { name: /Open task/ })).not.toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Open My Tasks' })).not.toBeInTheDocument()
  })

  it('keeps long task details readable and handles missing dates and unfamiliar statuses', async () => {
    const user = userEvent.setup()
    vi.mocked(employeesApi.tasks).mockResolvedValue({
      count: 1,
      items: [
        {
          id: 91,
          name: 'QA-20261028 A very long employee task title with an unusually long unbroken identifier EMPLOYEEPROFILEEDGECASE',
          description:
            'A longer task description that should wrap within the card instead of pushing its metadata outside the viewport.',
          status: 'awaiting_manager_review',
          priority: 'high',
          due_date: null,
          assigned_to: [23],
          project_name: 'Quarterly operations and employee experience review',
          created_at: '2026-10-01T00:00:00Z',
        },
      ],
    })
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Tasks' }))

    expect(await screen.findByText(/unusually long unbroken identifier/)).toBeVisible()
    expect(screen.getByText(/should wrap within the card/)).toBeVisible()
    expect(screen.getByText('Awaiting Manager Review')).toBeVisible()
    expect(screen.getByText('No due date')).toBeVisible()
    expect(screen.getByText('Quarterly operations and employee experience review')).toBeVisible()
    expect(screen.getByText('High')).toBeVisible()
  })

  it('links an employee to their own task in the correctly scoped personal task queue', async () => {
    const user = userEvent.setup()
    const ownSession = {
      ...session,
      user: { ...session.user, id: employee.user_id },
      employee: { ...session.employee, id: employee.id, user_id: employee.user_id },
    } satisfies AuthenticatedSession
    renderProfile(ownSession)
    await user.click(await screen.findByRole('tab', { name: 'Tasks' }))

    expect(await screen.findByRole('link', { name: 'Open My Tasks' })).toHaveAttribute(
      'href',
      expect.stringContaining('/dashboard/my-tasks'),
    )
    expect(
      screen.getByRole('link', { name: 'Open task Prepare weekly operations report' }),
    ).toHaveAttribute('href', expect.stringContaining('task=14'))
  })

  it('formats a zero gross salary instead of treating it as missing', async () => {
    const user = userEvent.setup()
    vi.mocked(employeesApi.get).mockResolvedValue({ ...employee, gross_salary: '0.00' })
    renderProfile()
    await user.click(await screen.findByRole('tab', { name: 'Benefits' }))

    expect(await screen.findByText('₦0.00')).toBeVisible()
  })
})
