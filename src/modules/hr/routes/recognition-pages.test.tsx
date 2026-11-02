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

import { employeesApi } from '@/modules/hr/employees.api'
import {
  recognitionApi,
  type Award,
  type DisciplinaryCase,
  type LeaderboardResponse,
} from '@/modules/hr/recognition.api'
import { recognitionQueryKeys } from '@/modules/hr/recognition.queries'
import {
  validateLeaderboardSearch,
  validateRecognitionSearch,
} from '@/modules/hr/recognition.search'
import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'

import { AwardsRecognitionPage } from './awards-recognition-page'
import { DisciplinaryProcessPage } from './disciplinary-process-page'
import { PerformanceLeaderboardPage } from './performance-leaderboard-page'

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

const permissions = {
  awards: ['list', 'view', 'create', 'update', 'delete'],
  monthly_scorecards: ['list'],
  disciplinary_cases: ['list', 'view', 'create', 'update', 'delete'],
  employees: ['list'],
}
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

const award: Award = {
  id: 8,
  title: 'Customer service excellence',
  category: 'state_excellence_winner',
  dateAwarded: '2026-10-20',
  rankLevel: 'state',
  description: 'Consistently delivered excellent support.',
  createdAt: '2026-10-20T10:00:00Z',
  updatedAt: '2026-10-20T10:00:00Z',
}
const kase: DisciplinaryCase = {
  id: 12,
  employeeId: 23,
  actionType: 'written_warning',
  violationCategory: 'attendance_issues',
  violationTitle: 'Repeated late arrival',
  violationDescription: 'Three late arrivals were recorded.',
  dateOfViolation: '2026-10-10',
  actionDate: '2026-10-12',
  investigationDetails: 'Attendance records reviewed.',
  severancePaymentDue: false,
  severanceAmount: null,
  daysSinceViolation: 20,
  isSeveranceApplicable: false,
  actionTypeColor: '#F5A623',
  createdAt: '2026-10-12T10:00:00Z',
  updatedAt: '2026-10-12T10:00:00Z',
}
const leaderboard: LeaderboardResponse = {
  month: 10,
  year: 2026,
  entries: [
    {
      rank: 1,
      employeeId: 23,
      employeeName: 'Amaka Okafor',
      branch: 'Lagos',
      score: 92.4,
      award: null,
    },
    { rank: 2, employeeId: 24, employeeName: null, branch: null, score: 84, award: null },
    { rank: 4, employeeId: 25, employeeName: 'Tunde Ayo', branch: 'Abuja', score: 76, award: null },
  ],
  averageScore: 84.13,
  totalParticipants: 3,
}

function localTodayDate() {
  const today = new Date()
  return `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`
}

let queryClient: QueryClient
const showToast = vi.fn()

function renderRoute({
  path,
  url,
  permissions: routePermissions = permissions,
  seed = true,
}: {
  path: '/hr/awards-recognition' | '/hr/performance-leaderboard' | '/hr/disciplinary-process'
  url: string
  permissions?: AuthenticatedSession['permissions']
  seed?: boolean
}) {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions: routePermissions })
  if (seed && path === '/hr/awards-recognition') {
    const state = validateRecognitionSearch(
      Object.fromEntries(new URL(url, 'http://local').searchParams.entries()),
    )
    queryClient.setQueryData(
      recognitionQueryKeys.awardsUser(
        9,
        'EMP-019',
        state.year === 'all' ? null : Number(state.year),
      ),
      { count: 1, items: [award] },
    )
  }
  if (seed && path === '/hr/performance-leaderboard') {
    const state = validateLeaderboardSearch(
      Object.fromEntries(new URL(url, 'http://local').searchParams.entries()),
    )
    queryClient.setQueryData(
      recognitionQueryKeys.leaderboard(9, 'EMP-019', state.month, state.year),
      leaderboard,
    )
  }
  if (seed && path === '/hr/disciplinary-process') {
    const state = validateRecognitionSearch(
      Object.fromEntries(new URL(url, 'http://local').searchParams.entries()),
    )
    queryClient.setQueryData(
      recognitionQueryKeys.disciplinaryList(9, 'EMP-019', {
        actionType: state.action,
        violationCategory: state.category,
      }),
      { count: 1, items: [kase] },
    )
  }
  const root = createRootRoute()
  const protectedRoute = createRoute({
    getParentRoute: () => root,
    id: '_protected',
    component: Outlet,
  })
  const pageComponent =
    path === '/hr/awards-recognition'
      ? AwardsRecognitionPage
      : path === '/hr/performance-leaderboard'
        ? PerformanceLeaderboardPage
        : DisciplinaryProcessPage
  const validator =
    path === '/hr/performance-leaderboard' ? validateLeaderboardSearch : validateRecognitionSearch
  const route = createRoute({
    getParentRoute: () => protectedRoute,
    path,
    validateSearch: validator,
    component: pageComponent,
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
  vi.spyOn(recognitionApi.awards, 'listAll').mockResolvedValue({ count: 1, items: [award] })
  vi.spyOn(recognitionApi.awards, 'get').mockResolvedValue(award)
  vi.spyOn(recognitionApi.awards, 'create').mockResolvedValue({ ...award, id: 9 })
  vi.spyOn(recognitionApi.awards, 'update').mockResolvedValue({ ...award, title: 'Updated award' })
  vi.spyOn(recognitionApi.awards, 'remove').mockResolvedValue({ detail: 'Deleted' })
  vi.spyOn(recognitionApi.leaderboard, 'get').mockResolvedValue(leaderboard)
  vi.spyOn(recognitionApi.disciplinary, 'listAll').mockResolvedValue({ count: 1, items: [kase] })
  vi.spyOn(recognitionApi.disciplinary, 'get').mockResolvedValue(kase)
  vi.spyOn(recognitionApi.disciplinary, 'create').mockResolvedValue({ ...kase, id: 13 })
  vi.spyOn(recognitionApi.disciplinary, 'update').mockResolvedValue({
    ...kase,
    violationTitle: 'Updated case',
  })
  vi.spyOn(recognitionApi.disciplinary, 'remove').mockResolvedValue({ detail: 'Deleted' })
  vi.spyOn(employeesApi, 'list').mockResolvedValue({ count: 0, items: [] })
})

afterEach(() => {
  queryClient?.clear()
  vi.restoreAllMocks()
})

describe('Recognition pages', () => {
  it('uses the compact page header and pairs award date filters above the narrowest phones', async () => {
    renderRoute({
      path: '/hr/awards-recognition',
      url: '/hr/awards-recognition?search=&year=all&month=all&action=all&category=all&page=1&pageSize=10',
    })

    const pageTitle = await screen.findByRole('heading', {
      name: 'Awards & recognition',
      level: 1,
    })
    expect(pageTitle).toHaveClass('text-[clamp(1.125rem,3vw,2rem)]')
    expect(screen.getByRole('button', { name: 'New award' })).toBeVisible()

    const searchForm = screen.getByRole('button', { name: 'Search' }).closest('form')
    expect(searchForm?.children[0]).toHaveClass('min-[400px]:grid-cols-[minmax(0,1fr)_auto]')
    expect(searchForm?.children[1]).toHaveClass('min-[360px]:grid-cols-2')
  })

  it('creates, views, edits, and deletes an award with confirmation and success feedback', async () => {
    const user = userEvent.setup()
    renderRoute({
      path: '/hr/awards-recognition',
      url: '/hr/awards-recognition?search=&year=all&month=all&action=all&category=all&page=1&pageSize=10',
    })

    expect(await screen.findByRole('heading', { name: award.title })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'View details' }))
    expect(await screen.findByRole('heading', { name: 'Recognition note' })).toBeVisible()
    await user.click(await screen.findByRole('button', { name: 'Edit award' }))
    const title = await screen.findByRole('textbox', { name: 'Award title' })
    await user.clear(title)
    await user.type(title, 'Updated award')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(recognitionApi.awards.update).toHaveBeenCalledWith(
        8,
        expect.objectContaining({ title: 'Updated award' }),
      ),
    )
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Award updated', tone: 'success' }),
    )

    await user.click(screen.getByRole('button', { name: 'New award' }))
    await user.type(screen.getByRole('textbox', { name: 'Award title' }), 'Team achievement')
    await user.click(screen.getByRole('combobox', { name: 'Award category' }))
    await user.click(await screen.findByRole('option', { name: 'Dependable team member' }))
    await user.click(screen.getByRole('combobox', { name: 'Award level' }))
    await user.click(await screen.findByRole('option', { name: 'Branch' }))
    await user.click(screen.getByRole('button', { name: 'Date awarded' }))
    await user.click(await screen.findByRole('button', { name: 'Today' }))
    await user.click(screen.getByRole('button', { name: 'Create award' }))
    await waitFor(() =>
      expect(recognitionApi.awards.create).toHaveBeenCalledWith(
        expect.objectContaining({ title: 'Team achievement', date_awarded: localTodayDate() }),
      ),
    )

    const article = screen.getByRole('heading', { name: award.title }).closest('article')!
    await user.click(within(article).getByRole('button', { name: 'Delete' }))
    expect(await screen.findByRole('heading', { name: 'Delete award?' })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Delete award' }))
    await waitFor(() => expect(recognitionApi.awards.remove).toHaveBeenCalledWith(8))
    expect(showToast).toHaveBeenCalledWith(
      expect.objectContaining({ title: 'Award deleted', tone: 'success' }),
    )
  })

  it('keeps leaderboard period in the URL and gracefully labels unavailable employee details', async () => {
    const user = userEvent.setup()
    const router = renderRoute({
      path: '/hr/performance-leaderboard',
      url: '/hr/performance-leaderboard?month=10&year=2026',
    })
    expect(await screen.findByRole('heading', { name: 'Top performers' })).toBeVisible()
    expect(screen.getByText('Amaka Okafor')).toBeVisible()
    expect(
      screen.getByRole('combobox', { name: 'Select leaderboard month' }).closest('.grid'),
    ).toHaveClass('min-[400px]:grid-cols-2')
    expect(screen.getByText('Employee #24')).toBeVisible()
    expect(screen.getByText('Branch details unavailable')).toBeVisible()
    expect(screen.getByText('Other ranked scorecards')).toBeVisible()
    await user.click(screen.getByRole('combobox', { name: 'Select leaderboard month' }))
    await user.click(await screen.findByRole('option', { name: 'September' }))
    await waitFor(() => expect(router.state.location.search.month).toBe(9))
    await waitFor(() =>
      expect(recognitionApi.leaderboard.get).toHaveBeenCalledWith(9, 2026, expect.any(AbortSignal)),
    )
  })

  it('shows a retryable leaderboard error and recovers on retry', async () => {
    const user = userEvent.setup()
    vi.spyOn(recognitionApi.leaderboard, 'get')
      .mockRejectedValueOnce(new Error('Temporary leaderboard failure'))
      .mockResolvedValue(leaderboard)
    renderRoute({
      path: '/hr/performance-leaderboard',
      url: '/hr/performance-leaderboard?month=10&year=2026',
      seed: false,
    })

    expect(await screen.findByText('Leaderboard could not be loaded')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByRole('heading', { name: 'Top performers' })).toBeVisible()
  })

  it('shows a retryable case-register error and recovers on retry', async () => {
    const user = userEvent.setup()
    vi.spyOn(recognitionApi.disciplinary, 'listAll')
      .mockRejectedValueOnce(new Error('Temporary case register failure'))
      .mockResolvedValue({ count: 1, items: [kase] })
    renderRoute({
      path: '/hr/disciplinary-process',
      url: '/hr/disciplinary-process?search=&year=all&month=all&action=all&category=all&page=1&pageSize=10',
      seed: false,
    })

    expect(await screen.findByText('Disciplinary cases could not be loaded')).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Try again' }))
    expect(await screen.findByRole('heading', { name: kase.violationTitle })).toBeVisible()
  })

  it('creates a disciplinary case with date validation, then views, edits, and confirms deletion', async () => {
    const user = userEvent.setup()
    renderRoute({
      path: '/hr/disciplinary-process',
      url: '/hr/disciplinary-process?search=&year=all&month=all&action=all&category=all&page=1&pageSize=10',
    })
    expect(await screen.findByRole('heading', { name: kase.violationTitle })).toBeVisible()

    const searchForm = screen.getByRole('button', { name: 'Search' }).closest('form')
    expect(searchForm).toHaveClass('min-[400px]:grid-cols-4')
    expect(searchForm?.children[0]).toHaveClass('min-[400px]:col-span-3')
    expect(searchForm?.children[1]).toHaveClass('min-[400px]:col-start-1 min-[400px]:row-start-2')
    expect(searchForm?.children[2]).toHaveClass('min-[400px]:col-start-3 min-[400px]:row-start-2')
    expect(searchForm?.children[3]).toHaveClass('min-[400px]:col-start-4 min-[400px]:row-start-1')
    const newCaseButton = screen.getByRole('button', { name: 'New case' })
    expect(newCaseButton).toHaveClass('max-[360px]:size-9')
    expect(newCaseButton.querySelector('span')).toHaveClass('hidden min-[480px]:inline')
    expect(screen.getByRole('heading', { name: kase.violationTitle })).toHaveClass(
      'max-[479px]:basis-full',
    )

    await user.click(screen.getByRole('button', { name: 'New case' }))
    await user.click(screen.getByRole('button', { name: 'Create case' }))
    expect(await screen.findByText('Enter or choose a valid employee record.')).toBeVisible()
    await user.type(screen.getByRole('textbox', { name: 'Employee record ID' }), '23')
    await user.click(screen.getByRole('combobox', { name: 'Disciplinary action type' }))
    await user.click(await screen.findByRole('option', { name: 'Written warning' }))
    await user.click(screen.getByRole('combobox', { name: 'Violation category' }))
    await user.click(await screen.findByRole('option', { name: 'Attendance issues' }))
    await user.click(screen.getByRole('button', { name: 'Violation date' }))
    await user.click(await screen.findByRole('button', { name: 'Today' }))
    await user.type(screen.getByRole('textbox', { name: 'Case title' }), 'Late reporting')
    await user.type(
      screen.getByRole('textbox', { name: 'Incident description' }),
      'Repeated tardiness was reviewed.',
    )
    await user.click(screen.getByRole('button', { name: 'Create case' }))
    await waitFor(() =>
      expect(recognitionApi.disciplinary.create).toHaveBeenCalledWith(
        expect.objectContaining({
          employee_id: 23,
          date_of_violation: localTodayDate(),
          action_type: 'written_warning',
        }),
      ),
    )

    await user.click(screen.getByRole('button', { name: 'View details' }))
    expect(await screen.findByText('Violation description')).toBeVisible()
    await user.click(await screen.findByRole('button', { name: 'Edit case' }))
    const caseTitle = await screen.findByRole('textbox', { name: 'Case title' })
    await user.clear(caseTitle)
    await user.type(caseTitle, 'Updated case')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))
    await waitFor(() =>
      expect(recognitionApi.disciplinary.update).toHaveBeenCalledWith(
        12,
        expect.objectContaining({ violation_title: 'Updated case' }),
      ),
    )

    const card = screen.getByRole('heading', { name: kase.violationTitle }).closest('article')!
    await user.click(within(card).getByRole('button', { name: 'Delete' }))
    expect(await screen.findByRole('heading', { name: 'Delete disciplinary case?' })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Delete case' }))
    await waitFor(() => expect(recognitionApi.disciplinary.remove).toHaveBeenCalledWith(12))
  })

  it('keeps the edit draft and reports a useful error when a case update fails', async () => {
    const user = userEvent.setup()
    vi.spyOn(recognitionApi.disciplinary, 'update').mockRejectedValueOnce(
      new Error('Temporary case update failure'),
    )
    renderRoute({
      path: '/hr/disciplinary-process',
      url: '/hr/disciplinary-process?search=&year=all&month=all&action=all&category=all&page=1&pageSize=10',
    })

    expect(await screen.findByRole('heading', { name: kase.violationTitle })).toBeVisible()
    await user.click(screen.getByRole('button', { name: 'Edit' }))
    const caseTitle = await screen.findByRole('textbox', { name: 'Case title' })
    await user.clear(caseTitle)
    await user.type(caseTitle, 'Retained draft after network error')
    await user.click(screen.getByRole('button', { name: 'Save changes' }))

    expect(await screen.findByText('Case not saved')).toBeVisible()
    expect(caseTitle).toHaveValue('Retained draft after network error')
    await user.click(screen.getByRole('button', { name: 'Cancel' }))
  })

  it('shows permission denial without calling the awards endpoint', async () => {
    renderRoute({
      path: '/hr/awards-recognition',
      url: '/hr/awards-recognition?search=&year=all&month=all&action=all&category=all&page=1&pageSize=10',
      permissions: {},
      seed: false,
    })
    expect(await screen.findByText('You can’t view awards')).toBeVisible()
    expect(recognitionApi.awards.listAll).not.toHaveBeenCalled()
  })
})
