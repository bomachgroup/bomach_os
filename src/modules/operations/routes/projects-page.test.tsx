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
import { projectsApi, type PaginatedDto, type ProjectDto } from '../projects.api'
import { validateProjectDetailSearch, validateProjectsSearch } from '../projects.search'
import { ProjectDetailPage } from './project-detail-page'
import { ProjectsPage } from './projects-page'

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

function adminSession(): AuthenticatedSession {
  return {
    user: {
      id: 7,
      email: 'admin@example.test',
      username: 'admin',
      first_name: 'QA',
      last_name: 'Admin',
      is_verified: true,
      created_at: '2026-01-01T00:00:00Z',
      role: null,
      permissions: {},
    },
    employee: {
      id: 7,
      user_id: 7,
      employee_id: 'EMP-QA-ADMIN',
      username: 'admin',
      email: 'admin@example.test',
      first_name: 'QA',
      last_name: 'Admin',
      designation: 'QA Admin',
    },
    roles: [],
    permissions: {
      projects: ['create', 'list', 'view', 'update', 'archive', 'restore', 'delete'],
    },
  }
}

function sampleProject(overrides: Partial<ProjectDto> = {}): ProjectDto {
  return {
    id: 101,
    name: 'QA project redesign sample',
    short_code: 'QA-PROJECT-101',
    category: 'Construction',
    department_id: null,
    client_id: 8,
    branch_id: 4,
    branch_name: 'Enugu',
    employee_ids: [],
    location: 'Enugu central site',
    priority: 'high',
    summary: 'Synthetic project for the Projects register tests.',
    status: 'planning',
    budget: '1250000.00',
    progress: 35,
    start_date: '2026-11-11',
    deadline: '2026-12-01',
    is_archived: false,
    archived_at: null,
    archived_by_id: null,
    created_at: '2026-11-11T09:00:00Z',
    updated_at: '2026-11-11T09:00:00Z',
    file_url: null,
    expense_count: 0,
    committed_expense_total: '0.00',
    spent_expense_total: '0.00',
    consumed_expense_total: '0.00',
    remaining_budget: '1250000.00',
    ...overrides,
  }
}

function page(overrides: Partial<PaginatedDto<ProjectDto>> = {}): PaginatedDto<ProjectDto> {
  return {
    items: [sampleProject()],
    count: 24,
    limit: 10,
    offset: 0,
    ...overrides,
  }
}

function renderProjects(path = '/works/projects?search=&status=&priority=&page=1&archived=false') {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, adminSession())

  const rootRoute = createRootRoute({ component: Outlet })
  const protectedRoute = createRoute({
    getParentRoute: () => rootRoute,
    id: '_protected',
    component: Outlet,
  })
  const projectsRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/works/projects',
    validateSearch: validateProjectsSearch,
    component: ProjectsPage,
  })
  const detailRoute = createRoute({
    getParentRoute: () => protectedRoute,
    path: '/works/projects/$projectId',
    validateSearch: validateProjectDetailSearch,
    component: ProjectDetailPage,
  })
  const router = createRouter({
    routeTree: rootRoute.addChildren([protectedRoute.addChildren([projectsRoute, detailRoute])]),
    history: createMemoryHistory({ initialEntries: [path] }),
  })

  const result = render(
    <QueryClientProvider client={queryClient}>
      <ToastProvider>
        <RouterProvider router={router} />
      </ToastProvider>
    </QueryClientProvider>,
  )
  return { ...result, queryClient, router }
}

describe('ProjectsPage', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
    vi.spyOn(projectsApi, 'list').mockResolvedValue(page())
    vi.spyOn(projectsApi, 'branchOptions').mockResolvedValue([
      { id: 4, name: 'Enugu', code: 'ENU' },
    ])
    vi.spyOn(projectsApi, 'clientOptions').mockResolvedValue([
      { id: 8, name: 'Fortress Developments', email: 'client@example.test' },
    ])
    vi.spyOn(projectsApi, 'create').mockResolvedValue(sampleProject())
    vi.spyOn(projectsApi, 'update').mockResolvedValue(sampleProject())
    vi.spyOn(projectsApi, 'remove').mockResolvedValue({ detail: 'Project deleted' })
    vi.spyOn(projectsApi, 'detail').mockResolvedValue(sampleProject())
    vi.spyOn(projectsApi, 'timelines').mockResolvedValue({
      items: [],
      count: 0,
      limit: 100,
      offset: 0,
    })
    vi.spyOn(projectsApi, 'employees').mockResolvedValue({ items: [], count: 0 })
    vi.spyOn(projectsApi, 'employeeOptions').mockResolvedValue([])
    vi.spyOn(projectsApi, 'associates').mockResolvedValue([])
    vi.spyOn(projectsApi, 'associateOptions').mockResolvedValue([
      { id: 12, name: 'QA construction partner', code: 'QA-PARTNER', category: 'Contractor' },
    ])
  })

  it('renders the refined register without a Search or manual Refresh action', async () => {
    renderProjects()

    await screen.findByRole('link', { name: 'QA project redesign sample' })
    expect(screen.getByRole('heading', { name: 'Project register' })).toBeInTheDocument()
    expect(
      screen.getByRole('article', { name: 'QA project redesign sample project' }),
    ).toBeInTheDocument()
    expect(screen.getByText('Allocated budget')).toBeInTheDocument()
    expect(
      screen.getByRole('progressbar', { name: 'QA project redesign sample delivery progress' }),
    ).toHaveAttribute('aria-valuenow', '35')
    expect(screen.queryByRole('button', { name: /^Search$/ })).not.toBeInTheDocument()
    expect(screen.queryByRole('button', { name: 'Refresh' })).not.toBeInTheDocument()

    const filterGrid = screen.getByRole('combobox', { name: /Status/ }).closest('.grid')
    expect(filterGrid).toHaveClass('min-[361px]:grid-cols-2')
  })

  it('keeps budget and priority compact through tablet widths', async () => {
    renderProjects()

    const allocation = await screen.findByRole('region', {
      name: 'QA project redesign sample budget and priority',
    })

    expect(allocation).toHaveClass('desktop:flex-col')
    expect(allocation).toHaveClass('desktop:items-start')
    expect(allocation).not.toHaveClass('tablet:flex-col')
    expect(within(allocation).getByText('Allocated budget')).toBeInTheDocument()
    expect(within(allocation).getByText('high priority').parentElement).toHaveClass(
      'border-warning/20',
    )

    const article = screen.getByRole('article', { name: 'QA project redesign sample project' })
    const footer = article.querySelector('footer')
    expect(footer).toHaveClass('flex-col', 'desktop:flex-row')
    expect(footer?.firstElementChild).toHaveClass('grid-cols-2')
    expect(footer?.lastElementChild).toHaveClass('justify-end')
    const schedule = within(footer as HTMLElement).getByRole('group', {
      name: 'QA project redesign sample schedule',
    })
    expect(within(schedule).getByText('Start')).toBeInTheDocument()
    expect(within(schedule).getByText('Target date')).toBeInTheDocument()
    expect(within(schedule).getByText('1 Dec 2026')).toHaveClass('font-semibold')
  })

  it('allows long project names to wrap on narrow screens', async () => {
    const longName = 'Fortress City Estate Development and Infrastructure Programme'
    vi.mocked(projectsApi.list).mockResolvedValueOnce(
      page({ items: [sampleProject({ name: longName })], count: 1 }),
    )
    renderProjects()

    expect(await screen.findByRole('link', { name: longName })).toHaveClass('break-words')
    expect(screen.getByRole('article', { name: `${longName} project` })).toBeInTheDocument()
  })

  it('applies search while typing, replaces route state, and resets pagination', async () => {
    const user = userEvent.setup()
    const { router } = renderProjects(
      '/works/projects?search=&status=&priority=&page=3&archived=false',
    )

    await screen.findByRole('link', { name: 'QA project redesign sample' })
    await user.type(screen.getByRole('searchbox', { name: /Search projects/ }), 'site-qa')

    await waitFor(() => {
      expect(router.state.location.search).toMatchObject({ search: 'site-qa', page: 1 })
    })
    await waitFor(() => {
      expect(projectsApi.list).toHaveBeenLastCalledWith(
        expect.objectContaining({ search: 'site-qa', offset: 0 }),
        expect.anything(),
      )
    })
  })

  it('updates the status filter in the URL and retains accessible project navigation', async () => {
    const user = userEvent.setup()
    const { router } = renderProjects()

    await screen.findByRole('link', { name: 'QA project redesign sample' })
    await user.click(screen.getByRole('combobox', { name: /Status/ }))
    await user.click(await screen.findByRole('option', { name: 'Planning' }))
    await waitFor(() => expect(router.state.location.search.status).toBe('planning'))

    await user.click(screen.getByRole('button', { name: 'Open QA project redesign sample' }))
    expect(
      await screen.findByRole('heading', { name: 'QA project redesign sample' }),
    ).toBeInTheDocument()
    expect(router.state.location.pathname).toBe('/works/projects/101')

    await user.click(screen.getByRole('button', { name: /^Members$/ }))
    await screen.findByRole('heading', { name: 'Project members' })
    expect(router.state.location.search.tab).toBe('members')
    expect(router.state.location.pathname).toBe('/works/projects/101')
  })

  it('uses the employee profile layout and content-sized project dialogs', async () => {
    const user = userEvent.setup()
    renderProjects('/works/projects/101?tab=associates')

    const title = await screen.findByRole('heading', { name: 'QA project redesign sample' })
    const titleRow = title.parentElement?.parentElement
    expect(titleRow).toHaveClass('justify-between')
    expect(
      within(titleRow as HTMLElement).getByRole('button', {
        name: 'Edit QA project redesign sample',
      }),
    ).toBeInTheDocument()

    const projectSections = screen.getByRole('navigation', { name: 'Project sections' })
    expect(projectSections).toHaveClass('grid-cols-2', 'tablet:grid-cols-3', 'desktop:grid-cols-4')
    expect(screen.getByRole('button', { name: 'Associates' })).toHaveAttribute(
      'aria-current',
      'page',
    )

    await user.click(screen.getByRole('button', { name: 'Add associate' }))
    const associateDialog = await screen.findByRole('dialog', { name: 'Add associate' })
    expect(associateDialog).toHaveClass('max-h-[calc(100dvh-2rem)]')
    const associateForm = associateDialog.querySelector('form')
    expect(associateForm?.parentElement).toHaveClass('bg-background', 'flex-auto')
    expect(
      within(associateForm as HTMLFormElement).getByRole('region', {
        name: 'Add associate details',
      }),
    ).toHaveClass('tablet:grid-cols-2')

    await user.click(within(associateDialog).getByRole('button', { name: 'Close dialog' }))
    await user.click(screen.getByRole('button', { name: 'Delete QA project redesign sample' }))
    const deleteDialog = await screen.findByRole('dialog', {
      name: 'Permanently delete project?',
    })
    expect(deleteDialog).toHaveClass('max-h-[calc(100dvh-2rem)]')
    expect(deleteDialog.querySelector('form')).toBeNull()
    expect(within(deleteDialog).getByText('QA project redesign sample')).toBeInTheDocument()
    expect(projectsApi.remove).not.toHaveBeenCalled()
  })

  it('opens create and edit without writing until the final form action', async () => {
    const user = userEvent.setup()
    renderProjects()

    await screen.findByRole('link', { name: 'QA project redesign sample' })
    await user.click(screen.getByRole('button', { name: 'Add project' }))
    expect(await screen.findByRole('heading', { name: 'Create project' })).toBeInTheDocument()
    expect(projectsApi.create).not.toHaveBeenCalled()
    await user.click(screen.getByRole('button', { name: 'Close dialog' }))

    await user.click(screen.getByRole('button', { name: 'Edit QA project redesign sample' }))
    expect(await screen.findByRole('heading', { name: 'Edit project' })).toBeInTheDocument()
    expect(screen.getByRole('textbox', { name: /Project name/ })).toHaveValue(
      'QA project redesign sample',
    )
    expect(projectsApi.update).not.toHaveBeenCalled()
  })
})
