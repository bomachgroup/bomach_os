import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import {
  createMemoryHistory,
  createRootRoute,
  createRoute,
  createRouter,
  Outlet,
  RouterProvider,
} from '@tanstack/react-router'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

import { employeesApi, type EmployeeScorecardDto } from '@/modules/hr/employees.api'
import {
  performanceAnalyticsApi,
  type EmployeeEvaluation,
  type EmployeeEvaluationSummary,
} from '@/modules/hr/performance-analytics.api'
import {
  performanceAnalyticsQueryKeys,
  type PerformanceEmployeeChoice,
} from '@/modules/hr/performance-analytics.queries'
import {
  validateEvaluationSearch,
  validateScorecardSearch,
} from '@/modules/hr/performance-analytics.search'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ApiError } from '@/shared/api/api-error'
import { ToastContext } from '@/shared/feedback/toast-context'

import { EmployeeEvaluationPage } from './employee-evaluation-page'
import { MonthlyScorecardPage } from './monthly-scorecard-page'
import { PerformanceEnginePage } from './performance-engine-page'

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

const employeeId = 42
const scorecard: EmployeeScorecardDto = {
  id: 5,
  employee_id: employeeId,
  employee_name: 'Amaka Okafor',
  employee_level: 'Operations Associate',
  month: 10,
  year: 2026,
  attendance_score: '90.25',
  task_delivery_score: '85',
  report_accuracy_score: '88',
  brand_contribution_score: '80',
  training_progress_score: '95',
  overall_score: '87.65',
  target_score: '80',
  target_achievement: '109.56',
  ranking: 2,
  is_auto_generated: true,
  notes: 'Strong month; continue the documented development plan.',
}
const employeeChoice: PerformanceEmployeeChoice = {
  id: employeeId,
  employeeCode: 'EMP-042',
  fullName: 'Amaka Okafor',
  designation: 'Operations Associate',
  branchName: 'Lagos',
}
const savedEvaluation: EmployeeEvaluation = {
  id: 7,
  employeeId,
  evaluatorId: 19,
  month: 10,
  year: 2026,
  promotionRequired: false,
  trainingRequired: true,
  salaryIncrease: false,
  overallScore: 87.65,
  createdAt: '2026-10-30T10:00:00Z',
  updatedAt: '2026-10-30T10:00:00Z',
  managerComments: 'Strong delivery with a clear training focus.',
  employeeName: 'Amaka Okafor',
  employeeLevel: 'Operations Associate',
  attendanceScore: 90.25,
  taskDeliveryScore: 85,
  reportAccuracyScore: 88,
  trainingProgressScore: 95,
  brandContributionScore: 80,
  targetScore: 80,
  targetAchievement: 109.56,
  ranking: 2,
}
const summary: EmployeeEvaluationSummary = {
  id: savedEvaluation.id,
  employeeId,
  evaluatorId: 19,
  month: 10,
  year: 2026,
  promotionRequired: false,
  trainingRequired: true,
  salaryIncrease: false,
  overallScore: 87.65,
  createdAt: savedEvaluation.createdAt,
  updatedAt: savedEvaluation.updatedAt,
}

const baseSession: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'reviewer@example.test',
    username: 'reviewer',
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
    employee_id: 'EMP-019',
    username: 'reviewer',
    email: 'reviewer@example.test',
    first_name: 'HR',
    last_name: 'Reviewer',
  },
  roles: [],
  permissions: {},
}

type PagePath = '/hr/monthly-scorecard' | '/hr/employee-evaluation' | '/hr/performance-engine'

let queryClient: QueryClient
const showToast = vi.fn()

function renderPage(
  path: PagePath,
  url: string,
  permissions: AuthenticatedSession['permissions'],
  seed?: (client: QueryClient) => void,
) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...baseSession, permissions })
  seed?.(queryClient)

  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const route =
    path === '/hr/monthly-scorecard'
      ? createRoute({
          getParentRoute: () => protectedRoute,
          path,
          validateSearch: validateScorecardSearch,
          component: MonthlyScorecardPage,
        })
      : path === '/hr/employee-evaluation'
        ? createRoute({
            getParentRoute: () => protectedRoute,
            path,
            validateSearch: validateEvaluationSearch,
            component: EmployeeEvaluationPage,
          })
        : createRoute({
            getParentRoute: () => protectedRoute,
            path,
            component: PerformanceEnginePage,
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
}

function seedEvaluationSelection(client: QueryClient) {
  client.setQueryData(performanceAnalyticsQueryKeys.employeeChoices(9, 'EMP-019'), [employeeChoice])
  client.setQueryData(
    performanceAnalyticsQueryKeys.evaluations(9, 'EMP-019', employeeId, 10, 2026),
    [],
  )
}

beforeEach(() => showToast.mockReset())

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('HR performance analytics pages', () => {
  it('renders a saved monthly scorecard and its measured breakdown', async () => {
    const permissions = { monthly_scorecards: ['view_own'] }
    renderPage(
      '/hr/monthly-scorecard',
      '/hr/monthly-scorecard?month=10&year=2026',
      permissions,
      (client) =>
        client.setQueryData(
          performanceAnalyticsQueryKeys.scorecard(9, 'EMP-019', 19, 10, 2026),
          scorecard,
        ),
    )

    expect(
      await screen.findByText('Strong month; continue the documented development plan.'),
    ).toBeVisible()
    expect(screen.getByText('87.7%')).toBeVisible()
    expect(screen.getByText('Performance breakdown')).toBeVisible()
  })

  it('reports missing scorecard data without requesting generation', async () => {
    vi.spyOn(employeesApi, 'scorecard').mockRejectedValue(
      new ApiError('Not found', { status: 404 }),
    )
    renderPage('/hr/monthly-scorecard', '/hr/monthly-scorecard?month=10&year=2026', {
      monthly_scorecards: ['view_own'],
    })

    expect(await screen.findByText('No scorecard for this period')).toBeVisible()
    expect(employeesApi.scorecard).toHaveBeenCalledWith(
      19,
      10,
      2026,
      expect.any(AbortSignal),
      false,
    )
  })

  it('creates an employee evaluation with the signed-in employee as evaluator', async () => {
    const create = vi.spyOn(performanceAnalyticsApi.evaluations, 'create').mockResolvedValue({
      ...savedEvaluation,
      id: 8,
      managerComments: 'Strong delivery and a clear next step.',
    })
    renderPage(
      '/hr/employee-evaluation',
      '/hr/employee-evaluation?month=10&year=2026&employee_id=42',
      { employees: ['list'], employee_evaluations: ['list', 'create'] },
      (client) => {
        seedEvaluationSelection(client)
        client.setQueryData(
          performanceAnalyticsQueryKeys.evaluations(9, 'EMP-019', employeeId, 10, 2026),
          [],
        )
      },
    )
    const user = userEvent.setup()
    expect(screen.queryByRole('textbox', { name: 'Manager’s comments' })).not.toBeInTheDocument()
    await user.click(await screen.findByRole('button', { name: 'Add assessment' }))
    await user.type(
      await screen.findByRole('textbox', { name: 'Manager’s comments' }),
      'Strong delivery and a clear next step.',
    )
    await user.click(screen.getByRole('button', { name: 'Submit evaluation' }))

    await waitFor(() =>
      expect(create).toHaveBeenCalledWith({
        employee_id: employeeId,
        evaluator_id: 19,
        month: 10,
        year: 2026,
        manager_comments: 'Strong delivery and a clear next step.',
        promotion_required: false,
        training_required: false,
        salary_increase: false,
      }),
    )
    await waitFor(() => expect(screen.queryByRole('dialog')).not.toBeInTheDocument())
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Evaluation submitted' }),
    )
  })

  it('keeps evaluation input and shows a recoverable error when save fails', async () => {
    vi.spyOn(performanceAnalyticsApi.evaluations, 'create').mockRejectedValue(new Error('Offline'))
    renderPage(
      '/hr/employee-evaluation',
      '/hr/employee-evaluation?month=10&year=2026&employee_id=42',
      { employees: ['list'], employee_evaluations: ['list', 'create'] },
      (client) => {
        seedEvaluationSelection(client)
        client.setQueryData(
          performanceAnalyticsQueryKeys.evaluations(9, 'EMP-019', employeeId, 10, 2026),
          [],
        )
      },
    )
    const user = userEvent.setup()
    await user.click(await screen.findByRole('button', { name: 'Add assessment' }))
    let comments = await screen.findByRole('textbox', { name: 'Manager’s comments' })
    await user.type(comments, 'Keep this draft after a connection issue.')
    await user.click(screen.getByRole('button', { name: 'Cancel' }))
    expect(screen.queryByRole('textbox', { name: 'Manager’s comments' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'Add assessment' }))
    comments = await screen.findByRole('textbox', { name: 'Manager’s comments' })
    expect(comments).toHaveValue('Keep this draft after a connection issue.')
    await user.click(screen.getByRole('button', { name: 'Submit evaluation' }))

    expect(await screen.findByText('Evaluation was not saved')).toBeVisible()
    expect(screen.getByRole('dialog', { name: 'Manager assessment' })).toHaveAttribute('open')
    expect(comments).toHaveValue('Keep this draft after a connection issue.')
  })

  it('updates a saved evaluation', async () => {
    const update = vi.spyOn(performanceAnalyticsApi.evaluations, 'update').mockResolvedValue({
      ...savedEvaluation,
      managerComments: 'Updated manager notes for this period.',
    })
    renderPage(
      '/hr/employee-evaluation',
      '/hr/employee-evaluation?month=10&year=2026&employee_id=42',
      { employees: ['list'], employee_evaluations: ['list', 'view', 'update'] },
      (client) => {
        seedEvaluationSelection(client)
        client.setQueryData(
          performanceAnalyticsQueryKeys.evaluations(9, 'EMP-019', employeeId, 10, 2026),
          [summary],
        )
        client.setQueryData(
          performanceAnalyticsQueryKeys.evaluation(9, 'EMP-019', savedEvaluation.id),
          savedEvaluation,
        )
      },
    )
    const user = userEvent.setup()
    await user.click(await screen.findByRole('button', { name: 'Edit assessment' }))
    const comments = await screen.findByRole('textbox', { name: 'Manager’s comments' })
    await user.clear(comments)
    await user.type(comments, 'Updated manager notes for this period.')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    await waitFor(() =>
      expect(update).toHaveBeenCalledWith(savedEvaluation.id, {
        manager_comments: 'Updated manager notes for this period.',
        promotion_required: false,
        training_required: true,
        salary_increase: false,
      }),
    )
  })

  it('clearly labels unavailable engine capabilities as planned', async () => {
    renderPage('/hr/performance-engine', '/hr/performance-engine', {
      performance_reviews: ['list'],
    })
    expect(await screen.findByText('Performance Engine APIs are not available')).toBeVisible()
    expect(screen.getAllByText('Planned')).toHaveLength(10)
    expect(screen.getByText('Not live yet')).toBeVisible()
  })
})
