import { createElement, type ReactNode } from 'react'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routeState = vi.hoisted(() => ({
  search: { type: 'all', status: 'all', page: 1 },
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
import { myWorkReportsApi, type MyWorkReport } from '../my-work-reports.api'
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
  permissions: {
    work_reports: ['list_own', 'create', 'view_own'],
    engineering_site_reports: ['list_own', 'create', 'view_own'],
    survey_site_reports: ['list_own', 'create', 'view_own'],
    worksites: ['list'],
  },
}

const reports: MyWorkReport[] = [
  {
    id: 30,
    reportId: 30,
    type: 'survey',
    date: '2026-10-27',
    status: 'rejected',
    summary: 'Clarified the site boundary measurements.',
    worksiteName: 'North worksite',
    hoursWorked: null,
    taskId: 91,
    rating: null,
    reviewedAt: '2026-10-28T09:00:00Z',
    attachments: ['https://files.example.com/site-photo.jpg'],
    payload: {},
  },
  {
    id: 29,
    reportId: 12,
    type: 'daily',
    date: '2026-10-26',
    status: 'submitted',
    summary: 'Completed the generator inspection.',
    worksiteName: null,
    hoursWorked: 7.5,
    taskId: null,
    rating: 4,
    reviewedAt: null,
    attachments: [],
    payload: {},
  },
  {
    id: 28,
    reportId: 28,
    type: 'engineering',
    date: '2026-10-25',
    status: 'draft',
    summary: 'Completed the retaining wall inspection.',
    worksiteName: 'West worksite',
    hoursWorked: null,
    taskId: null,
    rating: null,
    reviewedAt: null,
    attachments: [],
    payload: {},
  },
]

let queryClient: QueryClient

function pageContent() {
  return (
    <ToastContext.Provider value={{ showToast: vi.fn(), dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <MyWorkReportsPage />
      </QueryClientProvider>
    </ToastContext.Provider>
  )
}

function renderPage(permissions = session.permissions) {
  queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, { ...session, permissions })
  return render(pageContent())
}

describe('My Work Reports page', () => {
  beforeEach(() => {
    routeState.search = { type: 'all', status: 'all', page: 1 }
    routeState.navigate.mockReset()
    vi.spyOn(myWorkReportsApi, 'list').mockResolvedValue({ count: reports.length, items: reports })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows daily, engineering, and survey reports in the one register', async () => {
    renderPage()

    expect(await screen.findByText('Clarified the site boundary measurements.')).toBeInTheDocument()
    expect(screen.getByText('Completed the generator inspection.')).toBeInTheDocument()
    expect(screen.getByText('Completed the retaining wall inspection.')).toBeInTheDocument()
    expect(screen.getByText('North worksite')).toBeInTheDocument()
    expect(screen.getByText('7.5 hours')).toBeInTheDocument()
    expect(screen.getByText('3 reports')).toBeInTheDocument()
    await waitFor(() =>
      expect(myWorkReportsApi.list).toHaveBeenCalledWith(
        { type: 'all', status: 'all', limit: 10, offset: 0 },
        expect.any(AbortSignal),
      ),
    )
  })

  it('updates type and status filters and resets global pagination', async () => {
    const user = userEvent.setup()
    routeState.search.page = 3
    renderPage()
    await screen.findByText('Clarified the site boundary measurements.')

    await user.click(screen.getByRole('combobox', { name: 'Filter by report type' }))
    await user.click(screen.getByRole('option', { name: 'Engineering reports' }))
    let update = routeState.navigate.mock.calls.at(-1)?.[0]
    expect(update.search(routeState.search)).toMatchObject({ type: 'engineering', page: 1 })

    await user.click(screen.getByRole('combobox', { name: 'Filter by report status' }))
    await user.click(screen.getByRole('option', { name: 'Needs revision' }))
    update = routeState.navigate.mock.calls.at(-1)?.[0]
    expect(update.search(routeState.search)).toMatchObject({ status: 'rejected', page: 1 })
  })

  it('keeps the type and status filters in two columns above narrow-phone width', async () => {
    renderPage()

    await screen.findByRole('combobox', { name: 'Filter by report type' })
    const typeFilter = screen.getByRole('combobox', { name: 'Filter by report type' })

    expect(typeFilter.parentElement?.parentElement).toHaveClass('min-[340px]:grid-cols-2')
  })

  it('shows only permitted type filters and normalizes a hidden type URL', async () => {
    routeState.search = { type: 'survey', status: 'all', page: 1 }
    renderPage({ work_reports: ['list_own'], engineering_site_reports: ['list_own'] })

    await screen.findByText('Clarified the site boundary measurements.')
    const typeSelect = screen.getByRole('combobox', { name: 'Filter by report type' })
    await userEvent.setup().click(typeSelect)
    expect(screen.getByRole('option', { name: 'All report types' })).toBeInTheDocument()
    expect(screen.getByRole('option', { name: 'Daily reports' })).toBeInTheDocument()
    expect(screen.getByRole('option', { name: 'Engineering reports' })).toBeInTheDocument()
    expect(screen.queryByRole('option', { name: 'Survey reports' })).not.toBeInTheDocument()
    await waitFor(() =>
      expect(routeState.navigate).toHaveBeenCalledWith(expect.objectContaining({ replace: true })),
    )
  })

  it('does not call the combined history endpoint without any report list permission', () => {
    renderPage({})
    expect(screen.getByText('You can’t view these reports')).toBeInTheDocument()
    expect(myWorkReportsApi.list).not.toHaveBeenCalled()
  })

  it('offers site report creation only when create and worksite-list permissions are both present', async () => {
    const user = userEvent.setup()
    renderPage({
      engineering_site_reports: ['list_own', 'create'],
      survey_site_reports: ['list_own', 'create'],
      worksites: ['list'],
    })

    const newReport = await screen.findByText('New report')
    await user.click(newReport)
    expect(screen.getByRole('link', { name: 'Engineering site report' })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: 'Survey site report' })).toBeInTheDocument()
    expect(screen.queryByRole('link', { name: 'Daily work report' })).not.toBeInTheDocument()
  })

  it('hides site report creation if worksite list permission is absent', async () => {
    renderPage({ engineering_site_reports: ['list_own', 'create'] })
    expect(await screen.findByText('Report register')).toBeInTheDocument()
    expect(screen.queryByText('New report')).not.toBeInTheDocument()
  })
})
