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
import {
  projectsApi,
  type PaginatedDto,
  type ProjectDto,
  type ProjectTimelineDto,
} from '../projects.api'
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

function renderProjects(
  path = '/works/projects?search=&status=&priority=&page=1&archived=false',
  session = adminSession(),
) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false, gcTime: 0 }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)

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
    vi.spyOn(projectsApi, 'updateEmployees').mockResolvedValue(sampleProject())
    vi.spyOn(projectsApi, 'worksites').mockResolvedValue({
      items: [],
      count: 0,
      limit: 100,
      offset: 0,
    })
    vi.spyOn(projectsApi, 'files').mockResolvedValue([])
    vi.spyOn(projectsApi, 'milestones').mockResolvedValue({
      items: [],
      count: 0,
      limit: 100,
      offset: 0,
    })
    vi.spyOn(projectsApi, 'tasks').mockResolvedValue({
      items: [],
      count: 0,
      limit: 100,
      offset: 0,
    })
    vi.spyOn(projectsApi, 'associates').mockResolvedValue([])
    vi.spyOn(projectsApi, 'associateOptions').mockResolvedValue([
      { id: 12, name: 'QA construction partner', code: 'QA-PARTNER', category: 'Contractor' },
    ])
    vi.spyOn(projectsApi, 'meetings').mockResolvedValue({
      items: [],
      count: 0,
      limit: 100,
      offset: 0,
    })
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

  it('uses consistent, count-aware list sections across project tabs', async () => {
    const user = userEvent.setup()
    const timeline: ProjectTimelineDto = {
      id: 1,
      project_id: 101,
      name: 'Groundworks',
      description: 'Prepare the construction footprint.',
      status: 'in_progress',
      start_date: '2026-11-01',
      end_date: '2026-12-01',
    }
    vi.mocked(projectsApi.timelines).mockResolvedValueOnce({
      items: [timeline],
      count: 1,
      limit: 100,
      offset: 0,
    })
    vi.mocked(projectsApi.employeeOptions).mockResolvedValueOnce([
      {
        id: 9,
        employee_id: 'EMP-009',
        name: 'Amaka Nwosu',
        email: 'amaka@example.test',
        position: 'Site engineer',
      },
    ])
    vi.mocked(projectsApi.worksites).mockResolvedValueOnce({
      items: [
        {
          id: 1,
          project_id: 101,
          name: 'North field office',
          location: 'Emene, Enugu',
          latitude: null,
          longitude: null,
          status: 'active',
          description: 'Primary site coordination office.',
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })
    vi.mocked(projectsApi.files).mockResolvedValueOnce([
      {
        id: 1,
        original_filename: 'site-brief.pdf',
        content_type: 'application/pdf',
        size: 2048,
        uploaded_by_name: 'Test Admin',
        created_at: '2026-11-02T09:00:00Z',
        download_url: '/api/project-files/1',
      },
    ])
    vi.mocked(projectsApi.milestones).mockResolvedValue({
      items: [
        {
          id: 1,
          project_id: 101,
          name: 'Foundation works',
          description: 'Complete the foundation phase.',
          priority: 'high',
          status: 'in_progress',
          budget: '250000.00',
          progress: 60,
          start_date: '2026-11-01',
          end_date: '2026-12-01',
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })
    vi.mocked(projectsApi.tasks).mockResolvedValueOnce({
      items: [
        {
          id: 1,
          project_id: 101,
          milestone_id: 1,
          name: 'Inspect excavation',
          description: 'Record the inspection findings.',
          status: 'pending',
          priority: 'critical',
          due_date: '2026-11-21',
          estimated_hours: '4.00',
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })
    vi.mocked(projectsApi.associates).mockResolvedValueOnce([
      {
        id: 1,
        partner_id: 12,
        name: 'QA Construction Partner',
        code: 'QA-PARTNER',
        category: 'Contractor',
        project_role: 'Civil works contractor',
      },
    ])
    vi.mocked(projectsApi.meetings).mockResolvedValueOnce({
      items: [
        {
          id: 1,
          meeting_id: 'MTG-001',
          project_id: 101,
          title: 'Weekly site review',
          agenda: 'Review work completed and resolve blockers.',
          meeting_date: '2026-11-18',
          meeting_time: '09:30:00',
          duration_minutes: 60,
          duration_display: '1 hour',
          status: 'scheduled',
          status_display: 'Scheduled',
          location_type: 'physical',
          location_type_display: 'In person',
          location: 'Site office',
          attendee_count: 4,
          organizer_id: 7,
          organizer_name: 'Test Admin',
          notes: null,
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })

    const session = adminSession()
    session.permissions = {
      ...session.permissions,
      worksites: ['create', 'list', 'update', 'delete'],
      milestones: ['create', 'list', 'update', 'delete'],
      tasks: ['create', 'list', 'update', 'delete'],
      meetings: ['create', 'list', 'update', 'delete'],
    }
    renderProjects('/works/projects/101?tab=overview', session)
    const timelinePanel = await screen.findByRole('region', { name: 'Project timeline' })
    expect(within(timelinePanel).getByText('1 phase')).toBeInTheDocument()
    expect(within(timelinePanel).getByText('Groundworks')).toBeInTheDocument()
    expect(
      within(timelinePanel).getByText('Prepare the construction footprint.'),
    ).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Members' }))
    const membersPanel = await screen.findByRole('region', { name: 'Project members' })
    expect(within(membersPanel).getByText('1 employee')).toBeInTheDocument()
    expect(within(membersPanel).getByText('Amaka Nwosu')).toBeInTheDocument()
    await user.click(within(membersPanel).getByRole('checkbox'))
    expect(within(membersPanel).getByText('1 selected')).toBeInTheDocument()
    await user.click(within(membersPanel).getByRole('button', { name: 'Save team' }))
    await waitFor(() => expect(projectsApi.updateEmployees).toHaveBeenCalledWith(101, [9]))

    await user.click(screen.getByRole('button', { name: 'Work site' }))
    const worksitePanel = await screen.findByRole('region', { name: 'Project worksites' })
    expect(within(worksitePanel).getByText('1 worksite')).toBeInTheDocument()
    expect(within(worksitePanel).getByText('Emene, Enugu')).toBeInTheDocument()
    expect(
      within(worksitePanel).getByRole('button', { name: 'Edit North field office' }),
    ).toHaveTextContent('Edit')
    expect(
      within(worksitePanel).getByRole('button', { name: 'Delete North field office' }),
    ).toHaveTextContent('Delete')
    const addWorksite = within(worksitePanel).getByRole('button', { name: 'Add worksite' })
    expect(addWorksite.querySelector('span:first-of-type')).toHaveClass('max-[479px]:hidden')
    expect(addWorksite.querySelector('span[aria-hidden="true"]')).toHaveClass('max-[360px]:hidden')

    await user.click(screen.getByRole('button', { name: 'Files' }))
    const filesPanel = await screen.findByRole('region', { name: 'Project files' })
    expect(within(filesPanel).getByText('1 file')).toBeInTheDocument()
    expect(within(filesPanel).getByText('site-brief.pdf')).toBeInTheDocument()
    expect(
      within(filesPanel).getByRole('link', { name: 'Download site-brief.pdf' }),
    ).toBeInTheDocument()
    expect(
      within(filesPanel).getByRole('button', { name: 'Delete site-brief.pdf' }),
    ).toHaveTextContent('Delete')

    await user.click(screen.getByRole('button', { name: 'Milestones' }))
    const milestonesPanel = await screen.findByRole('region', { name: 'Milestones' })
    expect(within(milestonesPanel).getByText('1 milestone')).toBeInTheDocument()
    expect(within(milestonesPanel).getByText('60%')).toBeInTheDocument()
    expect(within(milestonesPanel).getByText('High')).toBeInTheDocument()
    expect(
      within(milestonesPanel).getByRole('button', { name: 'Edit milestone' }),
    ).toHaveTextContent('Edit')
    expect(
      within(milestonesPanel).getByRole('button', { name: 'Delete Foundation works' }),
    ).toHaveTextContent('Delete')

    await user.click(screen.getByRole('button', { name: 'Tasks' }))
    const tasksPanel = await screen.findByRole('region', { name: 'Project tasks' })
    expect(within(tasksPanel).getByText('1 task')).toBeInTheDocument()
    expect(within(tasksPanel).getByText('Foundation works')).toBeInTheDocument()
    expect(within(tasksPanel).getByText('Critical')).toBeInTheDocument()
    expect(
      within(tasksPanel).getByRole('button', { name: 'Edit Inspect excavation' }),
    ).toHaveTextContent('Edit')
    expect(
      within(tasksPanel).getByRole('button', { name: 'Delete Inspect excavation' }),
    ).toHaveTextContent('Delete')

    await user.click(screen.getByRole('button', { name: 'Associates' }))
    const associatesPanel = await screen.findByRole('region', { name: 'Project associates' })
    expect(within(associatesPanel).getByText('1 partner')).toBeInTheDocument()
    expect(within(associatesPanel).getByText('Civil works contractor')).toBeInTheDocument()
    expect(
      within(associatesPanel).getByRole('button', {
        name: 'Remove QA Construction Partner from project',
      }),
    ).toHaveTextContent('Remove')

    await user.click(screen.getByRole('button', { name: 'Meetings' }))
    const meetingsPanel = await screen.findByRole('region', { name: 'Project meetings' })
    expect(within(meetingsPanel).getByText('1 meeting')).toBeInTheDocument()
    expect(within(meetingsPanel).getByText('Weekly site review')).toBeInTheDocument()
    expect(within(meetingsPanel).getByText('4 people')).toBeInTheDocument()
    expect(
      within(meetingsPanel).getByRole('button', { name: 'Edit Weekly site review' }),
    ).toHaveTextContent('Edit')
    expect(
      within(meetingsPanel).getByRole('button', { name: 'Cancel Weekly site review' }),
    ).toHaveTextContent('Cancel')
  })

  it('uses shared date and time popovers in project milestone, task, and meeting create/edit dialogs', async () => {
    const user = userEvent.setup()
    vi.mocked(projectsApi.milestones).mockResolvedValue({
      items: [
        {
          id: 1,
          project_id: 101,
          name: 'Foundation works',
          description: 'Complete the foundation phase.',
          priority: 'high',
          status: 'in_progress',
          budget: '250000.00',
          progress: 60,
          start_date: '2026-11-01',
          end_date: '2026-12-01',
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })
    vi.mocked(projectsApi.tasks).mockResolvedValue({
      items: [
        {
          id: 1,
          project_id: 101,
          milestone_id: 1,
          name: 'Inspect excavation',
          description: 'Record the inspection findings.',
          status: 'pending',
          priority: 'high',
          due_date: '2026-11-21',
          estimated_hours: '4.00',
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })
    vi.mocked(projectsApi.meetings).mockResolvedValue({
      items: [
        {
          id: 1,
          meeting_id: 'MTG-001',
          project_id: 101,
          title: 'Weekly site review',
          agenda: 'Review work completed and resolve blockers.',
          meeting_date: '2026-11-18',
          meeting_time: '09:30:00',
          duration_minutes: 60,
          duration_display: '1 hour',
          status: 'scheduled',
          status_display: 'Scheduled',
          location_type: 'physical',
          location_type_display: 'In person',
          location: 'Site office',
          attendee_count: 4,
          organizer_id: 7,
          organizer_name: 'Test Admin',
          notes: null,
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })
    const session = adminSession()
    session.permissions = {
      ...session.permissions,
      milestones: ['create', 'list', 'update', 'delete'],
      tasks: ['create', 'list', 'update', 'delete'],
      meetings: ['create', 'list', 'update', 'delete'],
    }
    const { container } = renderProjects('/works/projects/101?tab=milestones', session)

    async function openDatePicker(dialog: HTMLElement, label: RegExp) {
      const trigger = within(dialog).getByRole('button', { name: label })
      expect(trigger).toHaveAttribute('aria-haspopup', 'dialog')
      expect(dialog.querySelector('input[type="date"]')).not.toBeInTheDocument()
      await user.click(trigger)
      expect(await screen.findByRole('dialog', { name: 'Choose a date' })).toBeInTheDocument()
      await user.click(trigger)
    }

    const milestones = await screen.findByRole('region', { name: 'Milestones' })
    await user.click(within(milestones).getByRole('button', { name: 'Add milestone' }))
    let dialog = await screen.findByRole('dialog', { name: 'Add milestone' })
    await openDatePicker(dialog, /Start date/)
    await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))
    await user.click(within(milestones).getByRole('button', { name: 'Edit milestone' }))
    dialog = await screen.findByRole('dialog', { name: 'Edit milestone' })
    expect(within(dialog).getByRole('button', { name: /Start date/ })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    expect(within(dialog).getByRole('button', { name: /End date/ })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))

    await user.click(screen.getByRole('button', { name: 'Tasks' }))
    const tasks = await screen.findByRole('region', { name: 'Project tasks' })
    await user.click(within(tasks).getByRole('button', { name: 'Add task' }))
    dialog = await screen.findByRole('dialog', { name: 'Add task' })
    await openDatePicker(dialog, /Due date/)
    await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))
    await user.click(within(tasks).getByRole('button', { name: 'Edit Inspect excavation' }))
    dialog = await screen.findByRole('dialog', { name: 'Edit task' })
    expect(within(dialog).getByRole('button', { name: /Due date/ })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))

    await user.click(screen.getByRole('button', { name: 'Meetings' }))
    const meetings = await screen.findByRole('region', { name: 'Project meetings' })
    await user.click(within(meetings).getByRole('button', { name: 'Add meeting' }))
    dialog = await screen.findByRole('dialog', { name: 'Add meeting' })
    await openDatePicker(dialog, /Date/)
    const timeTrigger = within(dialog).getByRole('button', { name: /Time/ })
    expect(dialog.querySelector('input[type="time"]')).not.toBeInTheDocument()
    await user.click(timeTrigger)
    expect(await screen.findByRole('dialog', { name: 'Choose a time' })).toBeInTheDocument()
    await user.click(timeTrigger)
    await user.click(within(dialog).getByRole('button', { name: 'Cancel' }))
    await user.click(within(meetings).getByRole('button', { name: 'Edit Weekly site review' }))
    dialog = await screen.findByRole('dialog', { name: 'Edit meeting' })
    expect(dialog.querySelector('input[type="date"]')).not.toBeInTheDocument()
    expect(dialog.querySelector('input[type="time"]')).not.toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: /Date/ })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    expect(within(dialog).getByRole('button', { name: /Time/ })).toHaveAttribute(
      'aria-haspopup',
      'dialog',
    )
    expect(container.querySelector('input[type="date"], input[type="time"]')).toBeNull()
  })

  it('keeps read-only project lists free of empty action footers', async () => {
    const session = adminSession()
    session.permissions.worksites = ['list']
    vi.mocked(projectsApi.worksites).mockResolvedValueOnce({
      items: [
        {
          id: 3,
          project_id: 101,
          name: 'North field office',
          location: 'Emene, Enugu',
          latitude: null,
          longitude: null,
          status: 'active',
          description: null,
          created_at: '2026-11-01T09:00:00Z',
          updated_at: '2026-11-02T09:00:00Z',
        },
      ],
      count: 1,
      limit: 100,
      offset: 0,
    })

    renderProjects('/works/projects/101?tab=worksite', session)

    const panel = await screen.findByRole('region', { name: 'Project worksites' })
    const card = panel.querySelector('article')
    expect(card).not.toBeNull()
    expect(card?.querySelector('footer')).not.toBeInTheDocument()
    expect(within(panel).queryByRole('button', { name: 'Add worksite' })).not.toBeInTheDocument()
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
