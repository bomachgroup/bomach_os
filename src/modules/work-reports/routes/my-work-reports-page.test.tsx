import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { status: 'all', page: 1 },
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
    useSearch: () => routeState.search,
    useNavigate: () => routeState.navigate,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { workReportsApi, type WorkReport } from '../work-reports.api'
import { MyWorkReportsPage } from './my-work-reports-page'

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
  permissions: { work_reports: ['list_own', 'create', 'view_own'] },
}

const report: WorkReport = {
  id: 48,
  employeeId: 23,
  day: '2026-10-19',
  hoursWorked: 7.5,
  operationalBase: 'Lagos office',
  workActivities: 'Completed the generator inspection and documented results.',
  taskDetails: 'Logged the inspection findings for the maintenance team.',
  planNextDay: null,
  summary: 'Completed the generator inspection and documented results.',
  status: 'submitted',
  feedback: null,
  rating: 4.5,
  reviewedBy: null,
  reviewedAt: null,
  attachments: ['https://files.example.com/inspection.pdf'],
  createdAt: '2026-10-19T11:00:00Z',
  updatedAt: '2026-10-19T11:00:00Z',
}

let queryClient: QueryClient

function renderPage(permissions = session.permissions) {
  queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  return render(
    <ToastContext.Provider value={{ showToast: vi.fn(), dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <MyWorkReportsPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('My Work Reports page', () => {
  beforeEach(() => {
    routeState.search = { status: 'all', page: 1 }
    routeState.navigate.mockReset()
    vi.spyOn(workReportsApi, 'list').mockImplementation(async (params) => ({
      count: 1,
      items: params.dateFrom ? [report] : [report],
    }))
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows today status and a bounded history using the current employee scope', async () => {
    const { container } = renderPage()

    expect(
      (await screen.findAllByText('Completed the generator inspection and documented results.'))
        .length,
    ).toBeGreaterThan(0)
    expect(screen.getByText('Today’s report')).toBeInTheDocument()
    expect(screen.getByText('7.5 hours recorded')).toBeInTheDocument()
    expect(screen.getAllByText('Lagos office').length).toBeGreaterThan(0)
    expect(
      screen.getByText('Logged the inspection findings for the maintenance team.'),
    ).toBeInTheDocument()
    expect(screen.getAllByText('1 file').length).toBeGreaterThan(0)
    expect(screen.getAllByText('4.5/5').length).toBeGreaterThan(0)
    await waitFor(() =>
      expect(workReportsApi.list).toHaveBeenCalledWith(
        expect.objectContaining({ employeeId: 23, limit: 10, offset: 0 }),
        expect.any(AbortSignal),
      ),
    )
    expect(container.querySelector('.reports-responsive-list')).toBeInTheDocument()
    expect(container.querySelector('.reports-compact-list')).toBeInTheDocument()
    expect(container.querySelector('.reports-table-list')).toBeInTheDocument()
    expect(container.querySelector('.reports-table-list')).toHaveTextContent('View report')
  })

  it('filters by status, resets pagination, and removes the search/date controls', async () => {
    const user = userEvent.setup()
    routeState.search.page = 3
    renderPage()
    await screen.findByText('Today’s report')
    await screen.findAllByText(report.summary!)

    expect(screen.queryByLabelText('Search reports')).not.toBeInTheDocument()
    expect(screen.queryByLabelText('From date')).not.toBeInTheDocument()
    expect(screen.queryByLabelText('To date')).not.toBeInTheDocument()
    expect(screen.getAllByRole('link', { name: /view report for/i }).length).toBeGreaterThan(0)
    expect(screen.getByRole('button', { name: 'All reports' })).toHaveAttribute(
      'aria-pressed',
      'true',
    )

    await user.click(screen.getByRole('button', { name: 'Needs revision' }))
    const statusUpdate = routeState.navigate.mock.calls.at(-1)?.[0]
    expect(statusUpdate.to).toBe('/dashboard/my-reports')
    expect(statusUpdate.search(routeState.search)).toMatchObject({ status: 'rejected', page: 1 })
  })

  it('blocks report history when the session has no list permission', () => {
    renderPage({})
    expect(screen.getByText('You can’t view these reports')).toBeInTheDocument()
    expect(workReportsApi.list).not.toHaveBeenCalled()
  })
})
