import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, describe, expect, it, vi } from 'vitest'

import { branchesApi } from '@/modules/company/branches.api'
import { kpiManagementApi } from '@/modules/company/kpi-management.api'
import { rolesApi, type RoleDto } from '@/modules/company/roles.api'
import { validateRoleDetailSearch } from '@/modules/company/role-detail.search'
import {
  employeesApi,
  type EmployeeDto,
  type EmployeeScorecardDto,
  type PerformanceReviewApiDto,
} from '@/modules/hr/employees.api'
import { trainingProgramsApi } from '@/modules/hr/training-programs.api'
import { ApiError } from '@/shared/api/api-error'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { RoleDetailPage } from './role-detail-page'

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

const role: RoleDto = {
  id: 6,
  name: 'Operations Coordinator',
  branches: [],
  permissions: { employees: ['view'] },
  created_at: '2026-01-01T00:00:00Z',
  updated_at: '2026-01-02T00:00:00Z',
}

function session(permissions: AuthenticatedSession['permissions']): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'admin@example.test',
      username: 'admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions,
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-007',
      username: 'admin',
      email: 'admin@example.test',
    },
    roles: [],
    permissions,
  }
}

function renderRoleDetail(
  permissions: AuthenticatedSession['permissions'] = {
    roles: ['view'],
    role_descriptions: ['view'],
  },
  initialPath = '/company/roles/6',
) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session(permissions))
  const rootRoute = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: Outlet,
  })
  const directoryRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/roles',
    component: () => <div>Role directory</div>,
  })
  const detailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/company/roles/$roleId',
    validateSearch: validateRoleDetailSearch,
    component: RoleDetailPage,
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([protectedRoute.addChildren([directoryRoute, detailRoute])]),
    history: createMemoryHistory({ initialEntries: [initialPath] }),
  })
  const showToast = vi.fn()
  render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
  return { queryClient, router }
}

describe('RoleDetailPage optional role description', () => {
  afterEach(() => vi.restoreAllMocks())

  it('treats a missing optional description as a neutral empty state', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    const description = vi
      .spyOn(rolesApi, 'description')
      .mockRejectedValue(new ApiError('Description not found', { status: 404 }))

    renderRoleDetail()

    expect(await screen.findByText('No role description yet')).toBeInTheDocument()
    expect(screen.queryByText('Record not found')).not.toBeInTheDocument()
    expect(screen.queryByText('Not provided')).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Try again' })).not.toBeInTheDocument()
    expect(description).toHaveBeenCalledOnce()
  })

  it('uses the same single empty state for a successful but blank description', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockResolvedValue({
      purpose: '  ',
      responsibilities: '',
      job_description: '   ',
    })

    renderRoleDetail()

    expect(await screen.findByText('No role description yet')).toBeInTheDocument()
    expect(
      screen.getByText('Purpose and responsibilities have not been added for this role.'),
    ).toBeInTheDocument()
    expect(screen.queryByText('Not provided')).not.toBeInTheDocument()
  })

  it('shows a restrained retry action for a retryable load error and reloads successfully', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    const description = vi
      .spyOn(rolesApi, 'description')
      .mockRejectedValueOnce(new ApiError('Service unavailable', { status: 503 }))
      .mockResolvedValue({ purpose: '', responsibilities: '', job_description: '' })

    renderRoleDetail()

    expect(await screen.findByText('Role definition could not load')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('No role description yet')).toBeInTheDocument()
    expect(description).toHaveBeenCalledTimes(2)
  })

  it('does not offer retry for a permission-denied description', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(new ApiError('Forbidden', { status: 403 }))

    renderRoleDetail()

    expect(await screen.findByText('Role definition is restricted')).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Try again' })).not.toBeInTheDocument()
    expect(screen.queryByText('No role description yet')).not.toBeInTheDocument()
  })
})

describe('RoleDetailPage permissions summary', () => {
  afterEach(() => vi.restoreAllMocks())

  it('matches the role review permission cards and opens the editor at Permissions', async () => {
    const user = userEvent.setup()
    const detailedRole: RoleDto = {
      ...role,
      permissions: {
        employees: ['view', 'update_own'],
        attendance: ['list_own'],
      },
    }
    vi.spyOn(rolesApi, 'get').mockResolvedValue(detailedRole)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({
      permissions_map: {
        employees: ['view', 'update_own'],
        attendance: ['list_own'],
      },
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })

    renderRoleDetail({ roles: ['view', 'update'], role_descriptions: ['view'] })

    const summary = await screen.findByRole('region', {
      name: 'Selected permissions by work area',
    })
    expect(within(summary).getByRole('heading', { name: 'People' })).toBeInTheDocument()
    expect(within(summary).getByText('Employees')).toBeInTheDocument()
    expect(within(summary).getByText('Update Own')).toBeInTheDocument()
    expect(
      within(summary).getByRole('heading', { name: 'Attendance & access' }),
    ).toBeInTheDocument()
    expect(summary.querySelectorAll('svg.size-3')).toHaveLength(3)

    await user.click(screen.getByRole('button', { name: 'Edit permissions' }))

    const editor = await screen.findByRole('dialog', { name: 'Edit role' })
    expect(within(editor).getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    expect(
      within(editor).getByRole('button', {
        name: 'Permissions, step 2 of 3, current step',
      }),
    ).toBeInTheDocument()
    expect(within(editor).getByRole('checkbox', { name: 'Employees Update Own' })).toBeChecked()
  })

  it('renders the first permission actions as soon as the responsibilities step advances', async () => {
    const user = userEvent.setup()
    const resourceChoices = Object.fromEntries(
      Array.from({ length: 30 }, (_, index) => [`qa_resource_${index + 1}`, ['view']]),
    )
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockResolvedValue({
      purpose: 'Coordinate operations.',
      responsibilities: 'Keep teams aligned.',
      job_description: '',
    })
    vi.spyOn(rolesApi, 'permissionMap').mockResolvedValue({
      permissions_map: { employees: ['view'], ...resourceChoices },
    })
    vi.spyOn(branchesApi, 'list').mockResolvedValue({ count: 0, items: [] })

    renderRoleDetail({
      roles: ['view', 'update'],
      role_descriptions: ['view', 'update'],
    })

    await user.click(await screen.findByRole('button', { name: 'Edit role' }))
    const editor = await screen.findByRole('dialog', { name: 'Edit role' })
    await user.click(within(editor).getByRole('button', { name: 'Continue' }))
    expect(
      within(editor).getByRole('heading', { name: 'Make this role easy to understand' }),
    ).toBeInTheDocument()

    await user.click(within(editor).getByRole('button', { name: 'Continue' }))

    expect(within(editor).getByRole('heading', { name: 'Permissions' })).toBeInTheDocument()
    const permissionList = editor.querySelector('ul[data-rendered-group-count]')
    expect(Number(permissionList?.getAttribute('data-rendered-group-count'))).toBeGreaterThan(0)
  })
})

describe('RoleDetailPage URL-backed tabs', () => {
  afterEach(() => vi.restoreAllMocks())

  it('opens a directly linked tab and keeps the selected tab in the URL', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 0, items: [] })

    const { router } = renderRoleDetail(
      { roles: ['view'], employees: ['list'] },
      '/company/roles/6?tab=performance-analytics',
    )

    expect(
      await screen.findByRole('tab', { name: 'Performance Analytics', selected: true }),
    ).toBeInTheDocument()
    expect(await screen.findByRole('heading', { name: 'Team performance' })).toBeInTheDocument()
    expect(router.state.location.search).toEqual({ tab: 'performance-analytics' })

    await user.click(screen.getByRole('tab', { name: 'Overview' }))
    expect(router.state.location.search).toEqual({ tab: 'overview' })
    expect(
      within(screen.getByRole('tabpanel')).getByRole('heading', {
        name: 'Operations Coordinator',
      }),
    ).toBeInTheDocument()
  })

  it('falls back to Overview for an unsupported tab value', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )

    renderRoleDetail({ roles: ['view'] }, '/company/roles/6?tab=unsupported-section')

    expect(await screen.findByRole('tab', { name: 'Overview', selected: true })).toBeInTheDocument()
    expect(
      within(screen.getByRole('tabpanel')).getByRole('heading', {
        name: 'Operations Coordinator',
      }),
    ).toBeInTheDocument()
    expect(validateRoleDetailSearch({ tab: 'unsupported-section' }).tab).toBe('overview')
  })
})

describe('RoleDetailPage performance analytics', () => {
  afterEach(() => vi.restoreAllMocks())

  const employee = {
    id: 91,
    user_id: 191,
    employee_id: 'QA-RD-001',
    first_name: 'Maya',
    last_name: 'Okafor',
    designation: 'Operations Analyst',
    department_name: 'Operations',
    branch_name: 'Enugu',
    role_id: role.id,
  } as EmployeeDto
  const scorecard = {
    id: 31,
    employee_id: employee.id,
    month: 10,
    year: 2026,
    attendance_score: '90',
    task_delivery_score: '82',
    report_accuracy_score: '88',
    brand_contribution_score: '76',
    training_progress_score: '84',
    overall_score: '84',
    target_score: '75',
    target_achievement: '112',
    ranking: 1,
    is_auto_generated: true,
    notes: '',
  } as EmployeeScorecardDto

  it('presents team metrics, scored progress, review state, and profile navigation', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 1, items: [employee] })
    const scorecardQuery = vi.spyOn(employeesApi, 'scorecard').mockResolvedValue(scorecard)
    vi.spyOn(employeesApi, 'performanceReviews').mockResolvedValue({
      count: 1,
      items: [
        {
          id: 61,
          employee_id: employee.id,
          review_period: 'q3',
          overall_rating: '4',
          review_date: '2026-09-30',
        } as PerformanceReviewApiDto,
      ],
    })

    renderRoleDetail(
      {
        roles: ['view'],
        employees: ['list', 'view'],
        monthly_scorecards: ['view'],
        performance_reviews: ['list'],
      },
      '/company/roles/6?tab=performance-analytics',
    )

    expect(await screen.findAllByText('1 / 1')).toHaveLength(2)
    expect(scorecardQuery.mock.calls[0]?.[4]).toBe(false)
    expect(screen.getAllByText('84%')).toHaveLength(2)
    expect(screen.getByText('Maya Okafor')).toBeInTheDocument()
    expect(screen.getByText('Operations Analyst · QA-RD-001')).toBeInTheDocument()
    expect(screen.getByText('Operations · Enugu')).toBeInTheDocument()
    expect(screen.getByText('Review on file')).toBeInTheDocument()
    expect(screen.getByRole('progressbar', { name: 'Maya Okafor monthly score' })).toHaveAttribute(
      'aria-valuenow',
      '84',
    )
    expect(screen.getByRole('link', { name: 'View profile' })).toHaveAttribute(
      'href',
      '/hr/employees/191',
    )
  })

  it('distinguishes an unavailable scorecard and offers a local retry', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 1, items: [employee] })
    vi.spyOn(employeesApi, 'scorecard')
      .mockRejectedValueOnce(new ApiError('Unavailable', { status: 503 }))
      .mockResolvedValue(scorecard)
    vi.spyOn(employeesApi, 'performanceReviews').mockResolvedValue({ count: 0, items: [] })

    renderRoleDetail(
      {
        roles: ['view'],
        employees: ['list', 'view'],
        monthly_scorecards: ['view'],
        performance_reviews: ['list'],
      },
      '/company/roles/6?tab=performance-analytics',
    )

    expect(await screen.findByText('Some performance details could not load')).toBeInTheDocument()
    expect(screen.getByText('Scorecard could not be loaded')).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('1 / 1')).toBeInTheDocument()
    expect(screen.queryByText('Some performance details could not load')).not.toBeInTheDocument()
  })

  it('treats a missing monthly scorecard as unscored without showing an error', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 1, items: [employee] })
    vi.spyOn(employeesApi, 'scorecard').mockRejectedValue(
      new ApiError('No scorecard found for this employee and period.', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'performanceReviews').mockResolvedValue({ count: 0, items: [] })

    renderRoleDetail(
      {
        roles: ['view'],
        employees: ['list', 'view'],
        monthly_scorecards: ['view'],
        performance_reviews: ['list'],
      },
      '/company/roles/6?tab=performance-analytics',
    )

    expect(await screen.findAllByText('0 / 1')).toHaveLength(2)
    expect(screen.getByText('No scorecard for this month')).toBeInTheDocument()
    expect(screen.queryByText('Some performance details could not load')).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Try again' })).not.toBeInTheDocument()
  })

  it('sorts individual performance alphabetically by employee name', async () => {
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'description').mockRejectedValue(
      new ApiError('Description not found', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'list').mockResolvedValue({
      count: 2,
      items: [
        { ...employee, id: 92, user_id: 192, first_name: 'Zoya', last_name: 'Ibe' },
        { ...employee, id: 93, user_id: 193, first_name: 'Amina', last_name: 'Garba' },
      ],
    })
    vi.spyOn(employeesApi, 'scorecard').mockRejectedValue(
      new ApiError('No scorecard found for this employee and period.', { status: 404 }),
    )
    vi.spyOn(employeesApi, 'performanceReviews').mockResolvedValue({ count: 0, items: [] })

    renderRoleDetail(
      {
        roles: ['view'],
        employees: ['list', 'view'],
        monthly_scorecards: ['view'],
        performance_reviews: ['list'],
      },
      '/company/roles/6?tab=performance-analytics',
    )

    expect(await screen.findByText('Amina Garba')).toBeInTheDocument()
    const names = [...document.querySelectorAll('#role-detail-panel article .text-label')].map(
      (node) => node.textContent,
    )
    expect(names).toEqual(['Amina Garba', 'Zoya Ibe'])
  })
})

describe('RoleDetailPage role standards', () => {
  afterEach(() => vi.restoreAllMocks())

  it('renders related records by name and formats enum values for people', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'listSection').mockImplementation(async (_roleId, section) => {
      if (section === 'kpis') {
        return {
          count: 1,
          items: [
            {
              id: 20,
              metric_id: 20,
              metric: {
                id: 20,
                name: 'Access requests resolved within service level',
                unit: 'percentage',
              },
              tracking_mode: 'semi_automatic',
              target_value: 98,
              weight: 20,
              period: 'monthly',
              sequence: 1,
              is_active: true,
            },
          ],
        } as never
      }
      return { count: 0, items: [] } as never
    })

    renderRoleDetail({ roles: ['view'], role_kpis: ['list'] })

    await user.click(await screen.findByRole('tab', { name: 'KPIs' }))
    expect(
      await screen.findByRole('heading', {
        name: 'Access requests resolved within service level',
      }),
    ).toBeInTheDocument()
    expect(screen.getByText('KPI metric')).toBeInTheDocument()
    expect(screen.getByText('Semi Automatic')).toBeInTheDocument()
    expect(screen.getByText('Monthly')).toBeInTheDocument()
    expect(screen.queryByText('Metric ID')).not.toBeInTheDocument()
    expect(screen.queryByText('semi_automatic')).not.toBeInTheDocument()
  })

  it('uses catalog choices for KPI creation, retries a catalog error, and saves numeric values', async () => {
    const user = userEvent.setup()
    const metric = {
      id: 20,
      name: 'Access requests resolved within service level',
      description: 'Resolved within the agreed service window.',
      unit: 'percentage',
    }
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'listSection').mockResolvedValue({ count: 0, items: [] })
    const metrics = vi
      .spyOn(kpiManagementApi, 'metrics')
      .mockRejectedValueOnce(new ApiError('Service unavailable', { status: 503 }))
      .mockResolvedValue([metric])
    const createSection = vi.spyOn(rolesApi, 'createSection').mockResolvedValue({ id: 55 } as never)

    renderRoleDetail({ roles: ['view'], role_kpis: ['list', 'create'], kpis: ['list'] })

    await user.click(await screen.findByRole('tab', { name: 'KPIs' }))
    await user.click(await screen.findByRole('button', { name: 'Add KPI' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add KPI' })
    await user.click(await within(dialog).findByRole('button', { name: 'Retry KPI metrics' }))
    const metricSelect = await within(dialog).findByRole('combobox', { name: 'Metric' })
    expect(document.querySelectorAll('select')).toHaveLength(0)
    expect(metricSelect).toHaveClass('text-control-value')
    await user.click(metricSelect)
    await user.click(
      await screen.findByRole('option', {
        name: /Access requests resolved within service level/,
      }),
    )

    const trackingMethod = within(dialog).getByRole('combobox', { name: 'Tracking method' })
    await user.click(trackingMethod)
    await user.click(await screen.findByRole('option', { name: 'Manual' }))
    const reviewPeriod = within(dialog).getByRole('combobox', { name: 'Review period' })
    await user.click(reviewPeriod)
    await user.click(await screen.findByRole('option', { name: 'Monthly' }))
    await user.type(within(dialog).getByRole('spinbutton', { name: 'Target value' }), '98')
    const weight = within(dialog).getByRole('spinbutton', { name: 'Weight' })
    await user.type(weight, '101')
    await user.click(within(dialog).getByRole('button', { name: 'Add KPI' }))
    expect(await within(dialog).findByText('Weight must be no more than 100.')).toBeInTheDocument()
    expect(createSection).not.toHaveBeenCalled()
    await user.clear(weight)
    await user.type(weight, '20')
    await user.click(within(dialog).getByRole('button', { name: 'Add KPI' }))

    expect(metrics).toHaveBeenCalledTimes(2)
    expect(createSection).toHaveBeenCalledWith(6, 'kpis', {
      metric_id: 20,
      tracking_mode: 'manual',
      target_value: 98,
      weight: 20,
      period: 'monthly',
      sequence: null,
      is_active: true,
    })
  })

  it('formats routine times without seconds and keeps the time editor normalized', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'listSection').mockImplementation(async (_roleId, section) => {
      if (section === 'daily-routine') {
        return {
          count: 1,
          items: [
            {
              id: 31,
              title: 'Morning review',
              description: 'Review priorities for the day.',
              time_of_day: '08:30:00',
              estimated_minutes: 15,
              sequence: 1,
              is_active: true,
            },
          ],
        } as never
      }
      return { count: 0, items: [] } as never
    })

    renderRoleDetail({ roles: ['view'], role_daily_routines: ['list', 'update'] })

    await user.click(await screen.findByRole('tab', { name: 'Daily Work Routine' }))
    const card = await screen.findByRole('article')
    expect(within(card).getByText('08:30', { exact: true })).toBeInTheDocument()
    expect(within(card).queryByText('08:30:00', { exact: true })).not.toBeInTheDocument()
    await user.click(within(card).getByRole('button', { name: 'Edit' }))
    const dialog = await screen.findByRole('dialog', { name: 'Edit routine item' })
    expect(within(dialog).getByLabelText('Time of day')).toHaveValue('08:30')
    expect(within(dialog).getByLabelText('Time of day')).toHaveAttribute('type', 'time')
  })

  it('uses shared training catalog choices and saves the program identifier', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'listSection').mockResolvedValue({ count: 0, items: [] })
    const trainingChoices = vi.spyOn(trainingProgramsApi, 'choices').mockResolvedValue([
      {
        id: 3,
        program_name: 'Access control fundamentals',
        provider: 'Bomach Learning',
      },
    ])
    const createSection = vi.spyOn(rolesApi, 'createSection').mockResolvedValue({ id: 58 } as never)

    renderRoleDetail({
      roles: ['view'],
      role_training_requirements: ['list', 'create'],
      training_programs: ['list'],
    })

    await user.click(await screen.findByRole('tab', { name: 'Training' }))
    await user.click(await screen.findByRole('button', { name: 'Add training requirement' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add training requirement' })
    const program = await within(dialog).findByRole('combobox', { name: 'Training program' })
    expect(program).toHaveClass('text-control-value')
    await user.click(program)
    await user.click(await screen.findByRole('option', { name: /Access control fundamentals/ }))
    const requirement = within(dialog).getByRole('combobox', { name: 'Requirement' })
    await user.click(requirement)
    await user.click(await screen.findByRole('option', { name: 'Mandatory' }))
    await user.click(within(dialog).getByRole('button', { name: 'Add training requirement' }))

    expect(trainingChoices).toHaveBeenCalledOnce()
    expect(createSection).toHaveBeenCalledWith(6, 'training-requirements', {
      training_program_id: 3,
      requirement_type: 'mandatory',
      sequence: null,
      is_active: true,
    })
  })

  it('uses searchable SOP catalog choices, retries lookup failures, and saves the SOP identifier', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'listSection').mockResolvedValue({ count: 0, items: [] })
    const sopChoices = vi
      .spyOn(rolesApi, 'sopChoices')
      .mockRejectedValueOnce(new ApiError('Service unavailable', { status: 503 }))
      .mockResolvedValue([
        {
          id: 27,
          title: 'Access review procedure',
          version: 'v2.0',
          priority: 'High',
          is_up_to_date: true,
          department: 'Human Resources',
          unit: null,
        },
      ])
    const createSection = vi.spyOn(rolesApi, 'createSection').mockResolvedValue({ id: 59 } as never)

    renderRoleDetail({ roles: ['view'], role_sops: ['list', 'create'] })

    await user.click(await screen.findByRole('tab', { name: 'SOPs' }))
    await user.click(await screen.findByRole('button', { name: 'Assign SOP' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add SOP assignment' })
    await user.click(await within(dialog).findByRole('button', { name: 'Retry procedures' }))
    const procedure = await within(dialog).findByRole('combobox', {
      name: 'Standard operating procedure',
    })
    expect(procedure).toHaveClass('text-control-value')
    expect(document.querySelectorAll('select')).toHaveLength(0)
    await user.click(procedure)
    await user.click(await screen.findByRole('option', { name: /Access review procedure/ }))
    await user.click(within(dialog).getByRole('button', { name: 'Assign SOP' }))

    expect(sopChoices).toHaveBeenCalledTimes(2)
    expect(createSection).toHaveBeenCalledWith(6, 'sops', {
      sop_id: 27,
      is_active: true,
    })
  })

  it('validates required resource details and preserves a draft after a save error', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'listSection').mockResolvedValue({ count: 0, items: [] })
    const createSection = vi
      .spyOn(rolesApi, 'createSection')
      .mockRejectedValue(new ApiError('Service unavailable', { status: 503 }))

    renderRoleDetail({ roles: ['view'], role_resources: ['list', 'create'] })

    await user.click(await screen.findByRole('tab', { name: 'Resources' }))
    await user.click(await screen.findByRole('button', { name: 'Add resource' }))
    const dialog = await screen.findByRole('dialog', { name: 'Add role resource' })
    const name = within(dialog).getByRole('textbox', { name: 'Resource name' })
    await user.click(within(dialog).getByRole('button', { name: 'Add resource' }))
    expect(await within(dialog).findByText('Resource name is required.')).toBeInTheDocument()
    expect(createSection).not.toHaveBeenCalled()

    await user.type(name, 'Role access checklist')
    const resourceType = within(dialog).getByRole('combobox', { name: 'Resource type' })
    await user.click(resourceType)
    await user.click(await screen.findByRole('option', { name: 'Document' }))
    await user.click(within(dialog).getByRole('button', { name: 'Add resource' }))

    expect(await within(dialog).findByText('Changes could not be saved')).toBeInTheDocument()
    expect(within(dialog).getByRole('textbox', { name: 'Resource name' })).toHaveValue(
      'Role access checklist',
    )
    expect(createSection).toHaveBeenCalledWith(6, 'resources', {
      name: 'Role access checklist',
      description: '',
      kind: 'document',
      sequence: null,
      is_active: true,
    })
  })

  it('shows a section retry on a list failure and renders the recovered records', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    const listSection = vi
      .spyOn(rolesApi, 'listSection')
      .mockRejectedValueOnce(new ApiError('Service unavailable', { status: 503 }))
      .mockResolvedValue({
        count: 1,
        items: [
          {
            id: 27,
            name: 'Access review checklist',
            description: 'Review access on schedule.',
            kind: 'document',
            sequence: 1,
            is_active: true,
          },
        ],
      } as never)

    renderRoleDetail({ roles: ['view'], role_resources: ['list'] })

    await user.click(await screen.findByRole('tab', { name: 'Resources' }))
    expect(await screen.findByRole('button', { name: 'Try again' })).toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Try again' }))

    expect(
      await screen.findByRole('heading', { name: 'Access review checklist' }),
    ).toBeInTheDocument()
    expect(listSection).toHaveBeenCalledTimes(2)
  })

  it('omits the duplicate Authority Limits tab and uses shared dropdowns for org chart edits', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    vi.spyOn(rolesApi, 'list').mockResolvedValue({
      count: 1,
      items: [{ ...role, id: 8, name: 'Team Lead' }],
    })
    vi.spyOn(rolesApi, 'listSection').mockResolvedValue({ count: 0, items: [] })
    const reportingChain = vi
      .spyOn(rolesApi, 'reportingChain')
      .mockResolvedValueOnce({ role: { id: 6, name: role.name }, chain: [] })
      .mockResolvedValue({
        role: { id: 6, name: role.name },
        chain: [
          {
            id: 55,
            role_id: 6,
            role: { id: 6, name: role.name },
            reports_to_role_id: 8,
            reports_to_role: { id: 8, name: 'Team Lead' },
            relationship_type: 'dotted_line',
            branch_id: null,
            department_id: null,
            unit_id: null,
            sequence: 1,
            is_active: true,
            cycle_detected: false,
            children: [],
          },
        ],
      })
    vi.spyOn(rolesApi, 'reportingTree').mockResolvedValue({
      role: { id: 6, name: role.name },
      direct_reports: [],
    })
    const createSection = vi.spyOn(rolesApi, 'createSection').mockResolvedValue({ id: 55 } as never)

    renderRoleDetail({ roles: ['view', 'list'], role_reporting_lines: ['list', 'create'] })

    expect(screen.queryByRole('tab', { name: 'Authority Limits' })).not.toBeInTheDocument()
    await user.click(await screen.findByRole('tab', { name: 'Org Chart' }))
    await user.click(await screen.findByRole('button', { name: 'Add reporting relationship' }))

    const dialog = await screen.findByRole('dialog', { name: 'Add reporting relationship' })
    const roleSelect = within(dialog).getByRole('combobox', { name: 'Reports to role' })
    const relationshipSelect = within(dialog).getByRole('combobox', { name: 'Relationship' })
    expect(document.querySelectorAll('select')).toHaveLength(0)
    expect(roleSelect).toHaveClass('text-control-value')

    await user.click(within(dialog).getByRole('button', { name: 'Add reporting relationship' }))
    expect(await within(dialog).findByText('Select reports to role.')).toBeInTheDocument()
    expect(await within(dialog).findByText('Select relationship.')).toBeInTheDocument()

    await user.click(roleSelect)
    await user.click(await screen.findByRole('option', { name: 'Team Lead' }))
    await user.click(relationshipSelect)
    await user.click(await screen.findByRole('option', { name: 'Dotted Line' }))
    await user.click(within(dialog).getByRole('button', { name: 'Add reporting relationship' }))

    expect(createSection).toHaveBeenCalledWith(6, 'reporting-lines', {
      reports_to_role_id: 8,
      relationship_type: 'dotted_line',
      branch_id: null,
      department_id: null,
      unit_id: null,
      sequence: null,
      is_active: true,
    })
    expect(await screen.findByRole('heading', { name: 'Reports to' })).toBeInTheDocument()
    expect(await screen.findByText('Team Lead')).toBeInTheDocument()
    expect(reportingChain).toHaveBeenCalledTimes(2)
    expect(
      screen.getByRole('heading', { name: 'No reporting relationships yet' }),
    ).toBeInTheDocument()
  })

  it('keeps role-choice failures visible and allows an in-place retry', async () => {
    const user = userEvent.setup()
    vi.spyOn(rolesApi, 'get').mockResolvedValue(role)
    const listRoles = vi
      .spyOn(rolesApi, 'list')
      .mockRejectedValueOnce(new ApiError('Service unavailable', { status: 503 }))
      .mockResolvedValue({ count: 1, items: [{ ...role, id: 8, name: 'Team Lead' }] })
    vi.spyOn(rolesApi, 'listSection').mockResolvedValue({ count: 0, items: [] })
    vi.spyOn(rolesApi, 'reportingChain').mockResolvedValue({
      role: { id: 6, name: role.name },
      chain: [],
    })
    vi.spyOn(rolesApi, 'reportingTree').mockResolvedValue({
      role: { id: 6, name: role.name },
      direct_reports: [],
    })

    renderRoleDetail({ roles: ['view', 'list'], role_reporting_lines: ['list', 'create'] })
    await user.click(await screen.findByRole('tab', { name: 'Org Chart' }))
    await user.click(await screen.findByRole('button', { name: 'Add reporting relationship' }))

    const dialog = await screen.findByRole('dialog', { name: 'Add reporting relationship' })
    expect(await within(dialog).findByText('Role choices could not be loaded.')).toBeInTheDocument()
    const save = within(dialog).getByRole('button', { name: 'Add reporting relationship' })
    expect(save).toBeDisabled()
    await user.click(within(dialog).getByRole('button', { name: 'Retry roles' }))
    expect(await within(dialog).findByRole('combobox', { name: 'Reports to role' })).toBeEnabled()
    expect(listRoles).toHaveBeenCalledTimes(2)
  })
})
