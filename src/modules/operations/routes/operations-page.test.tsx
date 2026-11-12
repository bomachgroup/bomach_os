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
import { beforeEach, describe, expect, it, vi } from 'vitest'

import { ToastProvider } from '@/shared/feedback/toast-provider'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { projectsApi, type OperationsOverviewDto } from '../projects.api'
import { OperationsPage } from './operations-page'

function session(permissions: Record<string, string[]>): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'staff@example.com',
      username: 'staff',
      first_name: 'Staff',
      last_name: 'User',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions: {},
    },
    employee: {
      user_id: 7,
      employee_id: 'EMP-7',
      username: 'staff',
      email: 'staff@example.com',
      first_name: 'Staff',
      last_name: 'User',
      designation: 'Coordinator',
    },
    roles: [],
    permissions,
  }
}

function overview(overrides: Partial<OperationsOverviewDto> = {}): OperationsOverviewDto {
  return {
    total_projects: 23,
    total_tasks: 22,
    allocated_project_budget: '53625000',
    approved_and_paid_expenses: '26812500',
    budget_utilization_percent: '50',
    total_worksites: 21,
    total_contracts: 11,
    total_timelines: 23,
    scope_limited: false,
    recent_projects: [
      {
        id: 51,
        name: 'Operations demo project 22',
        short_code: 'OPS-DEMO-022',
        status: 'in_progress',
        budget: '3750000',
        progress: 35,
        updated_at: '2026-11-11T10:00:00Z',
      },
    ],
    ...overrides,
  }
}

function renderOperations(
  permissions: Record<string, string[]> = {
    projects: ['create', 'list', 'view'],
  },
  path = '/operations',
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
  const operationsRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/operations',
    component: OperationsPage,
  })
  const projectRegisterRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/works/projects',
    component: () => createElement('h1', null, 'Project register route'),
  })
  const projectDetailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/works/projects/$projectId',
    component: () => createElement('h1', null, 'Project detail route'),
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([
      protectedRoute.addChildren([operationsRoute, projectRegisterRoute, projectDetailRoute]),
    ]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })

  const result = render(
    createElement(
      QueryClientProvider,
      { client: queryClient },
      createElement(ToastProvider, null, createElement(RouterProvider, { router })),
    ) as ReactNode,
  )

  return { ...result, queryClient, router }
}

describe('OperationsPage', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.spyOn(projectsApi, 'overview').mockResolvedValue(overview())
  })

  it('groups portfolio health and supporting counts while retaining project navigation', async () => {
    const user = userEvent.setup()
    const { router } = renderOperations()

    const snapshot = await screen.findByRole('region', { name: 'Portfolio snapshot' })
    expect(within(snapshot).getByText('Projects in scope')).toBeInTheDocument()
    expect(within(snapshot).getByText('23')).toBeInTheDocument()
    expect(within(snapshot).getByText('Allocated project budget')).toBeInTheDocument()
    expect(within(snapshot).getByText('₦53,625,000')).toBeInTheDocument()
    expect(within(snapshot).getByText('Budget utilization')).toBeInTheDocument()
    expect(within(snapshot).getByText('50%')).toBeInTheDocument()

    const coverage = screen.getByRole('region', { name: 'Operational coverage' })
    for (const [label, value] of [
      ['Project tasks', '22'],
      ['Worksites', '21'],
      ['Contracts', '11'],
      ['Timelines', '23'],
    ]) {
      expect(within(coverage).getByText(label)).toBeInTheDocument()
      expect(within(coverage).getByText(value)).toBeInTheDocument()
    }

    expect(screen.getByRole('link', { name: 'Operations demo project 22' })).toHaveAttribute(
      'href',
      '/works/projects/51',
    )
    await user.click(screen.getByRole('button', { name: 'All projects' }))
    await waitFor(() => expect(router.state.location.pathname).toBe('/works/projects'))
  })

  it('hides project actions when the user lacks the matching permissions', async () => {
    renderOperations({ projects: [] })

    expect(await screen.findByRole('region', { name: 'Portfolio snapshot' })).toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Add project' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'All projects' })).not.toBeInTheDocument()
    expect(screen.getByText('Operations demo project 22')).toBeInTheDocument()
    expect(
      screen.queryByRole('link', { name: 'Operations demo project 22' }),
    ).not.toBeInTheDocument()
  })

  it('shows utilization as unavailable when no valid denominator is supplied', async () => {
    vi.mocked(projectsApi.overview).mockResolvedValueOnce(
      overview({
        allocated_project_budget: null,
        budget_utilization_percent: null,
      }),
    )
    renderOperations()

    const snapshot = await screen.findByRole('region', { name: 'Portfolio snapshot' })
    const utilization = within(snapshot).getByText('Budget utilization').closest('article')
    expect(utilization).not.toBeNull()
    expect(within(utilization as HTMLElement).getByText('Not available')).toBeInTheDocument()
    expect(
      within(utilization as HTMLElement).getByRole('progressbar', { name: 'Budget utilization' }),
    ).not.toHaveAttribute('aria-valuenow')
  })

  it('preserves loading, retry, and empty-project states', async () => {
    let finishLoading: ((value: OperationsOverviewDto) => void) | undefined
    vi.mocked(projectsApi.overview).mockImplementationOnce(
      () => new Promise((resolve) => (finishLoading = resolve)),
    )
    const loading = renderOperations()
    expect(
      await screen.findByRole('status', { name: 'Loading operations overview' }),
    ).toBeInTheDocument()
    finishLoading?.(overview({ recent_projects: [] }))
    expect(await screen.findByText('No projects yet')).toBeInTheDocument()
    loading.unmount()

    vi.mocked(projectsApi.overview)
      .mockRejectedValueOnce(new Error('Temporary failure'))
      .mockRejectedValueOnce(new Error('Temporary failure'))
      .mockResolvedValueOnce(overview({ recent_projects: [] }))
    const { unmount } = renderOperations()
    expect(
      await screen.findByRole('button', { name: 'Try again' }, { timeout: 5000 }),
    ).toBeInTheDocument()
    await userEvent.setup().click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByText('No projects yet')).toBeInTheDocument()
    unmount()
  })
})
