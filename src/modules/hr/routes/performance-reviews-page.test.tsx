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

import {
  performanceReviewsApi,
  type PerformanceReview,
  type PerformanceReviewInput,
} from '@/modules/hr/performance-reviews.api'
import { performanceReviewsQueryKeys } from '@/modules/hr/performance-reviews.queries'
import { validatePerformanceReviewsSearch } from '@/modules/hr/performance-reviews.search'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'

import { PerformanceReviewsPage } from './performance-reviews-page'

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
  },
})

const permissions = { performance_reviews: ['list', 'view', 'create', 'update', 'delete'] }
const session: AuthenticatedSession = {
  user: {
    id: 9,
    email: 'hr@example.test',
    username: 'hr',
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
    username: 'hr',
    email: 'hr@example.test',
    first_name: 'HR',
    last_name: 'Reviewer',
  },
  roles: [],
  permissions,
}

const review: PerformanceReview = {
  id: 8,
  employeeId: 23,
  employeeName: 'Amaka Okafor',
  reviewerId: 19,
  reviewerName: 'HR Reviewer',
  reviewDate: '2026-10-27',
  reviewPeriod: 'Q4 2026',
  overallRating: 4,
  strengths: 'Clear communication',
  areasForImprovement: 'Delegation',
  feedback: 'Strong work with clients.',
  employeeComment: null,
  createdAt: '2026-10-27T10:00:00Z',
  updatedAt: '2026-10-27T10:00:00Z',
}

let queryClient: QueryClient
const showToast = vi.fn()

function renderPage({
  url = '/hr/performance-review?search=&rating=all&page=1&pageSize=10',
  currentPermissions = permissions,
  seedList = true,
}: {
  url?: string
  currentPermissions?: AuthenticatedSession['permissions']
  seedList?: boolean
} = {}) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions: currentPermissions })
  if (seedList) {
    const routeSearch = validatePerformanceReviewsSearch(
      Object.fromEntries(new URL(url, 'http://localhost').searchParams.entries()),
    )
    queryClient.setQueryData(
      performanceReviewsQueryKeys.list(session.user.id, session.employee.employee_id, {
        search: routeSearch.search,
        rating: routeSearch.rating === 'all' ? 'all' : Number(routeSearch.rating),
        limit: routeSearch.pageSize,
        offset: (routeSearch.page - 1) * routeSearch.pageSize,
      }),
      { count: 1, items: [review] },
    )
  }
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const route = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/hr/performance-review',
    validateSearch: validatePerformanceReviewsSearch,
    component: PerformanceReviewsPage,
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
  return router
}

beforeEach(() => {
  showToast.mockReset()
  vi.spyOn(performanceReviewsApi, 'list').mockResolvedValue({ count: 1, items: [review] })
  vi.spyOn(performanceReviewsApi, 'create').mockImplementation(
    async (input: PerformanceReviewInput) => ({
      ...review,
      employeeId: input.employee_id,
      reviewerId: input.reviewer_id,
      reviewDate: input.review_date,
      reviewPeriod: input.review_period,
      overallRating: input.overall_rating,
      strengths: input.strengths,
      areasForImprovement: input.areas_for_improvement,
      feedback: input.feedback,
      employeeComment: input.employee_comment,
    }),
  )
  vi.spyOn(performanceReviewsApi, 'update').mockResolvedValue({
    ...review,
    strengths: 'Updated strengths',
  })
  vi.spyOn(performanceReviewsApi, 'remove').mockResolvedValue(undefined)
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('PerformanceReviewsPage', () => {
  it('keeps the public Performance path when applying search filters', async () => {
    const user = userEvent.setup()
    const router = renderPage()

    expect(await screen.findByRole('heading', { name: 'Performance reviews' })).toBeVisible()
    expect(screen.getByRole('button', { name: 'New review' })).toBeVisible()
    expect(screen.getByRole('combobox', { name: 'Filter reviews by rating' })).toBeVisible()
    await user.type(screen.getByRole('searchbox', { name: 'Search reviews' }), 'Amaka')
    await user.click(screen.getByRole('button', { name: 'Search' }))

    await waitFor(() => expect(router.state.location.pathname).toBe('/hr/performance-review'))
    expect(router.state.location.search.search).toBe('Amaka')
  })

  it('creates with validation, views, updates, and deletes a review', async () => {
    const user = userEvent.setup()
    renderPage({ url: '/hr/performance-review?search=Amaka&rating=all&page=1&pageSize=10' })

    expect(
      await screen.findByRole('heading', { name: 'Amaka Okafor' }, { timeout: 5000 }),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'New review' }))

    await user.type(screen.getByRole('spinbutton', { name: 'Employee record ID' }), '19')
    await user.click(screen.getByRole('button', { name: 'Create review' }))
    expect(await screen.findByText('Choose a reviewer different from the employee.')).toBeVisible()
    expect(performanceReviewsApi.create).not.toHaveBeenCalled()

    const employeeField = screen.getByRole('spinbutton', { name: 'Employee record ID' })
    await user.clear(employeeField)
    await user.type(employeeField, '23')
    await user.click(screen.getByRole('combobox', { name: 'Overall rating' }))
    await user.click(await screen.findByRole('option', { name: '5 of 5 stars' }))
    await user.click(screen.getByRole('button', { name: 'Create review' }))

    await waitFor(() =>
      expect(performanceReviewsApi.create).toHaveBeenCalledWith(
        expect.objectContaining({
          employee_id: 23,
          reviewer_id: 19,
          overall_rating: 5,
          strengths: '',
        }),
      ),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Performance review created', tone: 'success' }),
      ),
    )

    await user.click(screen.getByRole('button', { name: 'View review' }))
    expect(await screen.findByText('Record #23')).toBeVisible()
    expect(screen.getByText('Overall rating')).toBeVisible()
    await user.click(await screen.findByRole('button', { name: 'Edit review' }))
    const strengths = screen.getByRole('textbox', { name: 'Strengths' })
    await user.clear(strengths)
    await user.type(strengths, 'Updated strengths')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(performanceReviewsApi.update).toHaveBeenCalledWith(
        8,
        expect.objectContaining({ strengths: 'Updated strengths' }),
      ),
    )
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Performance review updated', tone: 'success' }),
      ),
    )

    await user.click(screen.getByRole('button', { name: 'View review' }))
    await user.click(await screen.findByRole('button', { name: 'Delete' }))
    await user.click(await screen.findByRole('button', { name: 'Delete review' }))
    await waitFor(() => expect(performanceReviewsApi.remove).toHaveBeenCalledWith(8))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Performance review deleted', tone: 'success' }),
      ),
    )
  })

  it('keeps the register read-only when create, update, and delete are not granted', async () => {
    const user = userEvent.setup()
    renderPage({ currentPermissions: { performance_reviews: ['list', 'view'] } })

    expect(
      await screen.findByRole('heading', { name: 'Amaka Okafor' }, { timeout: 5000 }),
    ).toBeVisible()
    expect(screen.queryByRole('button', { name: 'New review' })).not.toBeInTheDocument()
    await user.click(screen.getByRole('button', { name: 'View review' }))
    expect(screen.queryByRole('button', { name: 'Edit review' })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Delete' })).not.toBeInTheDocument()
  })

  it('shows a failed list request with a retry action', async () => {
    const user = userEvent.setup()
    vi.mocked(performanceReviewsApi.list).mockRejectedValueOnce(
      new Error('Review service unavailable'),
    )
    renderPage({ seedList: false })

    expect(
      await screen.findByText('Performance reviews could not be loaded', {}, { timeout: 5000 }),
    ).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(
      await screen.findByRole('heading', { name: 'Amaka Okafor' }, { timeout: 5000 }),
    ).toBeVisible()
  })
})
