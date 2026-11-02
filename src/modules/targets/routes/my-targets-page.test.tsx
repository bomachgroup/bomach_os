import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: {
    scope: 'active',
    period: 'all',
    status: 'all',
    targetsPage: 1,
    reportsPage: 1,
  },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    useSearch: () => routeState.search,
    useNavigate: () => routeState.navigate,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { targetsApi, type EmployeeTarget, type TargetReport } from '../targets.api'
import { targetsQueryKeys } from '../targets.queries'
import { MyTargetsPage } from './my-targets-page'

function localDateString(date: Date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}

const today = new Date()
const currentMonthStart = localDateString(new Date(today.getFullYear(), today.getMonth(), 1))
const currentMonthEnd = localDateString(new Date(today.getFullYear(), today.getMonth() + 1, 0))

const baseSession: AuthenticatedSession = {
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
    employee_targets: ['list_own'],
    target_reports: ['list_own', 'view_own', 'create'],
  },
}

const target: EmployeeTarget = {
  id: 31,
  title: 'Monthly sales',
  description: 'Close qualified sales for the month.',
  targetValue: 100,
  unit: 'units',
  period: 'monthly',
  periodStart: currentMonthStart,
  periodEnd: currentMonthEnd,
  isActive: true,
  approvedProgressValue: 20,
  remainingValue: 80,
  progressPercentage: 20,
  isCompleted: false,
  hasPendingReport: false,
}

const report: TargetReport = {
  id: 94,
  employeeTargetId: target.id,
  target: {
    id: target.id,
    title: target.title,
    targetValue: target.targetValue,
    unit: target.unit,
    period: target.period,
    periodStart: target.periodStart,
    periodEnd: target.periodEnd,
  },
  summary: 'Completed work on five qualified leads.',
  progressValue: 5,
  status: 'submitted',
  rejectionReason: '',
  createdAt: '2026-10-19T09:00:00Z',
  updatedAt: '2026-10-19T09:00:00Z',
}

let queryClient: QueryClient
const showToast = vi.fn()

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

function renderPage(permissions = baseSession.permissions) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, {
    ...baseSession,
    permissions,
  })
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <MyTargetsPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('My Targets page', () => {
  beforeEach(() => {
    routeState.search = {
      scope: 'active',
      period: 'all',
      status: 'all',
      targetsPage: 1,
      reportsPage: 1,
    }
    routeState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(targetsApi, 'listAssigned').mockResolvedValue({ count: 1, items: [target] })
    vi.spyOn(targetsApi, 'listReports').mockResolvedValue({ count: 1, items: [report] })
    vi.spyOn(targetsApi, 'reportDetail').mockResolvedValue(report)
    vi.spyOn(targetsApi, 'createReport').mockResolvedValue({ ...report, status: 'submitted' })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('loads assigned targets and report history independently with approved and submitted amounts distinct', async () => {
    const { container } = renderPage()

    expect((await screen.findAllByText('Monthly sales')).length).toBeGreaterThan(0)
    expect(await screen.findByText(/5 units submitted/)).toBeInTheDocument()
    expect(screen.getAllByText(/20 units/).length).toBeGreaterThan(0)
    expect(screen.getAllByText(/80 units remaining/).length).toBeGreaterThan(0)
    expect(targetsApi.listAssigned).toHaveBeenCalledWith(
      expect.objectContaining({ scope: 'active', period: 'all', limit: 10, offset: 0 }),
      expect.any(AbortSignal),
    )
    expect(targetsApi.listReports).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'all', limit: 10, offset: 0 }),
      expect.any(AbortSignal),
    )
    expect(container.querySelector('.target-list-container')).toBeInTheDocument()
    expect(container.querySelector('.target-table-header')).toBeInTheDocument()
    expect(container.querySelector('.target-table-row')).toBeInTheDocument()
    expect(container.querySelector('.target-card-row')).toBeInTheDocument()
  })

  it('gates target and history sections independently', async () => {
    renderPage({ employee_targets: ['list_own'] })

    expect((await screen.findAllByText('Monthly sales')).length).toBeGreaterThan(0)
    expect(screen.queryByRole('heading', { name: 'Progress history' })).not.toBeInTheDocument()
    expect(targetsApi.listAssigned).toHaveBeenCalledOnce()
    expect(targetsApi.listReports).not.toHaveBeenCalled()
  })

  it('keeps the target section available when report history fails', async () => {
    vi.mocked(targetsApi.listReports).mockRejectedValueOnce(new Error('History unavailable'))
    renderPage()

    expect((await screen.findAllByText('Monthly sales')).length).toBeGreaterThan(0)
    expect(
      await screen.findByText('An unexpected problem occurred. Please try again.'),
    ).toBeInTheDocument()
  })

  it('disables duplicate progress submission while a report is in review', async () => {
    vi.mocked(targetsApi.listAssigned).mockResolvedValueOnce({
      count: 1,
      items: [{ ...target, hasPendingReport: true }],
    })
    renderPage()

    const buttons = await screen.findAllByRole('button', { name: 'Review pending' })
    expect(buttons.length).toBeGreaterThan(0)
    buttons.forEach((button) => expect(button).toBeDisabled())
  })

  it('does not offer progress submission outside the target period', async () => {
    vi.mocked(targetsApi.listAssigned).mockResolvedValueOnce({
      count: 2,
      items: [
        {
          ...target,
          id: 41,
          title: 'Expired target',
          periodStart: '2020-01-01',
          periodEnd: '2020-01-31',
        },
        {
          ...target,
          id: 42,
          title: 'Upcoming target',
          periodStart: '2999-01-01',
          periodEnd: '2999-01-31',
        },
      ],
    })
    renderPage()

    expect(await screen.findAllByText('Period ended')).not.toHaveLength(0)
    expect(await screen.findAllByText('Upcoming')).not.toHaveLength(0)
    expect(screen.queryByRole('button', { name: 'Report progress' })).not.toBeInTheDocument()
  })

  it('formats a single reported unit in the singular', async () => {
    const checkTarget = { ...target, unit: 'checks' }
    vi.mocked(targetsApi.listAssigned).mockResolvedValueOnce({ count: 1, items: [checkTarget] })
    vi.mocked(targetsApi.listReports).mockResolvedValueOnce({
      count: 1,
      items: [
        {
          ...report,
          progressValue: 1,
          target: { ...report.target, unit: 'checks' },
        },
      ],
    })
    renderPage()

    expect(await screen.findAllByText('1 check submitted')).not.toHaveLength(0)
  })

  it('keeps the entered progress when submission fails', async () => {
    const user = userEvent.setup()
    vi.mocked(targetsApi.createReport).mockRejectedValueOnce(
      new Error('A submitted report already exists.'),
    )
    renderPage()

    await user.click((await screen.findAllByRole('button', { name: 'Report progress' }))[0])
    await user.type(screen.getByLabelText(/Progress achieved/), '5')
    await user.type(screen.getByLabelText(/Progress summary/), 'Completed five leads.')
    await user.click(screen.getByRole('button', { name: 'Submit for review' }))

    expect(
      await screen.findByText('An unexpected problem occurred. Please try again.'),
    ).toBeInTheDocument()
    expect(screen.getByLabelText(/Progress achieved/)).toHaveValue(5)
    expect(screen.getByLabelText(/Progress summary/)).toHaveValue('Completed five leads.')
  })

  it('invalidates only target assignments and report history after a confirmed submission', async () => {
    const user = userEvent.setup()
    renderPage()
    const invalidateSpy = vi.spyOn(queryClient, 'invalidateQueries')

    await user.click((await screen.findAllByRole('button', { name: 'Report progress' }))[0])
    await user.type(screen.getByLabelText(/Progress achieved/), '5')
    await user.type(screen.getByLabelText(/Progress summary/), 'Completed five leads.')
    await user.click(screen.getByRole('button', { name: 'Submit for review' }))

    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Progress submitted' }),
      ),
    )
    expect(targetsApi.createReport).toHaveBeenCalledWith(
      {
        employee_target_id: target.id,
        progress_value: 5,
        summary: 'Completed five leads.',
      },
      expect.objectContaining({ client: queryClient }),
    )
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: targetsQueryKeys.assigned(baseSession.user.id, baseSession.employee.employee_id),
    })
    expect(invalidateSpy).toHaveBeenCalledWith({
      queryKey: targetsQueryKeys.reports(baseSession.user.id, baseSession.employee.employee_id),
    })
    expect(invalidateSpy).toHaveBeenCalledTimes(2)
  })

  it('resets only the report page when a report status filter changes', async () => {
    const user = userEvent.setup()
    routeState.search.reportsPage = 4
    renderPage()

    const needsRevisionFilter = await screen.findByRole('button', { name: 'Needs revision' })
    expect(needsRevisionFilter.querySelector('svg')).toHaveClass('text-danger-foreground')
    await user.click(needsRevisionFilter)
    const navigateCall = routeState.navigate.mock.calls.at(-1)?.[0] as {
      to: string
      search: (previous: typeof routeState.search) => typeof routeState.search
    }
    expect(navigateCall.to).toBe('/dashboard/my-target-reports')
    expect(navigateCall.search(routeState.search)).toEqual({
      ...routeState.search,
      status: 'rejected',
      reportsPage: 1,
    })
  })
})
