import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor, within } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'

const routerState = vi.hoisted(() => ({
  search: {
    status: 'all',
    priority: 'all',
    sort: 'due_date',
    page: 1,
    task: undefined as number | undefined,
  },
  navigate: vi.fn(),
}))

vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>()
  return {
    ...actual,
    useSearch: () => routerState.search,
    useNavigate: () => routerState.navigate,
  }
})

import { AUTH_SESSION_QUERY_KEY, type AuthenticatedSession } from '@/shared/auth/session'
import { ToastContext } from '@/shared/feedback/toast-context'
import { myTasksApi, type MyTaskDto, type MyTasksSummaryDto } from '../tasks.api'
import { MyTasksPage } from './my-tasks-page'

const session: AuthenticatedSession = {
  user: {
    id: 7,
    email: 'avery@example.com',
    username: 'avery',
    first_name: 'Avery',
    last_name: 'Staff',
    is_verified: true,
    created_at: '2026-01-01T00:00:00Z',
    role: null,
    permissions: {},
  },
  employee: {
    user_id: 7,
    employee_id: 'EMP-007',
    username: 'avery',
    email: 'avery@example.com',
    first_name: 'Avery',
    last_name: 'Staff',
    designation: 'Project Officer',
  },
  roles: [],
  permissions: { tasks: ['list_own', 'view_own', 'update_own'] },
}

const pendingTask: MyTaskDto = {
  id: 14,
  project_id: 3,
  project: {
    id: 3,
    name: 'Workspace rollout',
    short_code: 'WORK-03',
    status: 'in_progress',
    location: null,
    priority: 'medium',
    progress: 20,
    start_date: null,
    deadline: null,
  },
  milestone_id: null,
  milestone: null,
  name: 'Prepare site estimate',
  description: 'Review quantities and prepare an estimate for the site team.',
  status: 'pending',
  priority: 'high',
  due_date: '2026-10-20',
  estimated_hours: '2.50',
  created_at: '2026-10-18T08:00:00Z',
  updated_at: '2026-10-18T08:00:00Z',
}

const summary: MyTasksSummaryDto = {
  total: 1,
  pending: 1,
  in_progress: 0,
  completed: 0,
  cancelled: 0,
}

const showToast = vi.fn()
let queryClient: QueryClient

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

function renderPage() {
  queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, session)
  return render(
    <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
      <QueryClientProvider client={queryClient}>
        <MyTasksPage />
      </QueryClientProvider>
    </ToastContext.Provider>,
  )
}

describe('My Tasks page', () => {
  beforeEach(() => {
    routerState.search = {
      status: 'all',
      priority: 'all',
      sort: 'due_date',
      page: 1,
      task: undefined,
    }
    routerState.navigate.mockReset()
    showToast.mockReset()
    vi.spyOn(myTasksApi, 'list').mockResolvedValue({ count: 1, items: [pendingTask] })
    vi.spyOn(myTasksApi, 'summary').mockResolvedValue(summary)
    vi.spyOn(myTasksApi, 'detail').mockResolvedValue(pendingTask)
    vi.spyOn(myTasksApi, 'updateStatus').mockResolvedValue({
      ...pendingTask,
      status: 'in_progress',
    })
  })

  afterEach(() => {
    queryClient?.clear()
    vi.restoreAllMocks()
  })

  it('shows accurate status counts and task details without a summary-card gallery', async () => {
    renderPage()

    expect(await screen.findAllByText('Prepare site estimate')).toHaveLength(2)
    expect(screen.getByRole('button', { name: 'All tasks, 1 task' })).toBeInTheDocument()
    expect(screen.getAllByText('Workspace rollout')).toHaveLength(2)
    expect(screen.getAllByText('High').length).toBeGreaterThan(0)
    expect(screen.getByText(/Showing 1–1 of 1 tasks/)).toBeInTheDocument()
  })

  it('keeps filters in the URL and shows centered task details in a shared dialog', async () => {
    const user = userEvent.setup()
    routerState.search = { ...routerState.search, task: 14 }
    renderPage()

    const dialog = await screen.findByRole('dialog', { name: 'Task details' })
    expect(dialog).toHaveClass('tablet:top-1/2', 'tablet:max-h-[90dvh]', 'tablet:-translate-y-1/2')
    expect(dialog).toHaveClass('tablet:max-w-[50rem]', 'flex-col')
    expect(dialog).not.toHaveClass('desktop:inset-y-0', 'desktop:h-dvh')
    expect(
      within(dialog).getByRole('heading', { name: 'Prepare site estimate' }),
    ).toBeInTheDocument()
    expect(within(dialog).getByRole('heading', { name: 'Task overview' })).toBeInTheDocument()
    expect(within(dialog).getByText('Workspace rollout')).toBeInTheDocument()
    expect(
      within(dialog).getByText('Review quantities and prepare an estimate for the site team.'),
    ).toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: 'Close' })).toBeInTheDocument()
    expect(within(dialog).getByRole('button', { name: 'Start task' })).toBeInTheDocument()
    expect(myTasksApi.detail).toHaveBeenCalledWith(14, expect.any(AbortSignal))

    await user.click(screen.getByRole('button', { name: 'Close dialog' }))
    expect(routerState.navigate).toHaveBeenCalled()
    const closeNavigation = routerState.navigate.mock.calls.at(-1)?.[0]
    expect(closeNavigation.search(routerState.search)).toMatchObject({
      task: undefined,
    })
  })

  it('changes task status filters on the visible route path', async () => {
    const user = userEvent.setup()
    renderPage()
    await screen.findByText(/Showing 1–1 of 1 tasks/)

    const inProgressFilter = screen.getByRole('button', { name: 'In progress, 0 tasks' })
    expect(inProgressFilter.querySelector('svg')).toHaveClass('text-info-foreground')
    await user.click(inProgressFilter)

    const statusNavigation = routerState.navigate.mock.calls.at(-1)?.[0]
    expect(statusNavigation.to).toBe('/dashboard/my-tasks')
    expect(statusNavigation.search(routerState.search)).toMatchObject({
      status: 'in_progress',
      page: 1,
    })
  })

  it('requires confirmation before completing a shared task and updates scoped caches after success', async () => {
    const user = userEvent.setup()
    const activeTask = { ...pendingTask, status: 'in_progress' as const }
    vi.mocked(myTasksApi.list).mockResolvedValue({ count: 1, items: [activeTask] })
    vi.mocked(myTasksApi.updateStatus).mockResolvedValue({ ...activeTask, status: 'completed' })
    renderPage()

    expect(await screen.findAllByText('Prepare site estimate')).toHaveLength(2)
    await waitFor(() =>
      expect(screen.getAllByRole('button', { name: 'Mark complete' })).toHaveLength(2),
    )
    await user.click(screen.getAllByRole('button', { name: 'Mark complete' })[0])
    const confirmation = await screen.findByRole('dialog', { name: 'Mark this task complete?' })
    expect(within(confirmation).getByText(/shared with everyone assigned/i)).toBeInTheDocument()
    expect(myTasksApi.updateStatus).not.toHaveBeenCalled()

    await user.click(within(confirmation).getByRole('button', { name: 'Mark complete' }))

    await waitFor(() => expect(myTasksApi.updateStatus).toHaveBeenLastCalledWith(14, 'completed'))
    await waitFor(() =>
      expect(showToast).toHaveBeenCalledWith(expect.objectContaining({ tone: 'success' })),
    )
    await waitFor(() => expect(myTasksApi.list).toHaveBeenCalledTimes(2))
    await waitFor(() => expect(myTasksApi.summary).toHaveBeenCalledTimes(2))
  })

  it('does not request data when the user lacks task-list permission', async () => {
    const deniedSession = { ...session, permissions: {} }
    queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    queryClient.setQueryData(AUTH_SESSION_QUERY_KEY, deniedSession)

    render(
      <ToastContext.Provider value={{ showToast, dismissToast: vi.fn() }}>
        <QueryClientProvider client={queryClient}>
          <MyTasksPage />
        </QueryClientProvider>
      </ToastContext.Provider>,
    )

    expect(await screen.findByText('You can’t view these tasks')).toBeInTheDocument()
    expect(myTasksApi.list).not.toHaveBeenCalled()
    expect(myTasksApi.summary).not.toHaveBeenCalled()
  })
})
