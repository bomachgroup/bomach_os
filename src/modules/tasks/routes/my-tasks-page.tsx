import { useMemo, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  ArrowDownUp,
  CalendarDays,
  Check,
  CheckCircle2,
  CircleAlert,
  ChevronLeft,
  ChevronRight,
  ClipboardList,
  CircleHelp,
  CircleX,
  Clock3,
  Eye,
  Flag,
  ListChecks,
  RefreshCw,
  type LucideIcon,
} from 'lucide-react'

import { personalWorkQueryKeys } from '@/modules/dashboard/personal-work.api'
import { presentError } from '@/shared/errors'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Dialog } from '@/shared/ui/dialog'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'

import {
  myTasksApi,
  type MyTaskDto,
  type MyTasksListParams,
  type MyTasksSummaryDto,
  type TaskListStatus,
  type TaskPriorityFilter,
  type TaskSort,
  type TaskStatus,
} from '../tasks.api'
import {
  myTaskDetailQueryOptions,
  myTasksListQueryOptions,
  myTasksQueryKeys,
  myTasksSummaryQueryOptions,
} from '../tasks.queries'
import type { MyTasksSearch } from '../tasks.search'

const PAGE_SIZE = 10
const desktopTaskGridColumns =
  'desktop:grid-cols-[minmax(0,1.65fr)_minmax(7rem,1fr)_minmax(7rem,.9fr)_minmax(7rem,.9fr)_minmax(9.5rem,1.25fr)]'

const taskTabs: {
  id: TaskListStatus
  label: string
  countKey: keyof MyTasksSummaryDto
  icon: LucideIcon
  accent: string
  countAccent: string
}[] = [
  {
    id: 'all',
    label: 'All tasks',
    countKey: 'total',
    icon: ClipboardList,
    accent: 'text-primary',
    countAccent: 'bg-primary-subtle text-primary',
  },
  {
    id: 'pending',
    label: 'Pending',
    countKey: 'pending',
    icon: Clock3,
    accent: 'text-warning-foreground',
    countAccent: 'bg-warning-subtle text-warning-foreground',
  },
  {
    id: 'in_progress',
    label: 'In progress',
    countKey: 'in_progress',
    icon: ListChecks,
    accent: 'text-info-foreground',
    countAccent: 'bg-info-subtle text-info-foreground',
  },
  {
    id: 'completed',
    label: 'Completed',
    countKey: 'completed',
    icon: CheckCircle2,
    accent: 'text-success-foreground',
    countAccent: 'bg-success-subtle text-success-foreground',
  },
]

const priorityFilterOptions = [
  { value: 'all', label: 'All priorities' },
  {
    value: 'high',
    label: 'High priority',
    icon: <Flag className="size-4" />,
    iconClassName: 'text-danger',
  },
  {
    value: 'medium',
    label: 'Medium priority',
    icon: <Flag className="size-4" />,
    iconClassName: 'text-warning-foreground',
  },
  {
    value: 'low',
    label: 'Low priority',
    icon: <Flag className="size-4" />,
    iconClassName: 'text-text-muted',
  },
]

const taskSortOptions = [
  {
    value: 'due_date',
    label: 'Due date',
    icon: <ArrowDownUp className="size-4" />,
    iconClassName: 'text-text-muted',
  },
  {
    value: 'priority',
    label: 'Priority',
    icon: <ArrowDownUp className="size-4" />,
    iconClassName: 'text-text-muted',
  },
]

function statusPresentation(status: string): {
  label: string
  tone: StatusTone
  icon: LucideIcon
} {
  switch (status) {
    case 'pending':
      return { label: 'Pending', tone: 'warning', icon: Clock3 }
    case 'in_progress':
      return { label: 'In progress', tone: 'info', icon: ListChecks }
    case 'completed':
      return { label: 'Completed', tone: 'success', icon: CheckCircle2 }
    case 'cancelled':
      return { label: 'Cancelled', tone: 'neutral', icon: CircleX }
    default:
      return { label: status.replaceAll('_', ' '), tone: 'neutral', icon: CircleHelp }
  }
}

function priorityPresentation(priority: string): { label: string; tone: StatusTone } {
  switch (priority) {
    case 'high':
      return { label: 'High', tone: 'danger' }
    case 'medium':
      return { label: 'Medium', tone: 'warning' }
    default:
      return { label: priority === 'low' ? 'Low' : 'Unspecified', tone: 'neutral' }
  }
}

function formatDate(value: string | null): string {
  if (!value) return 'No due date'
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function isOverdue(value: string | null, status: string): boolean {
  if (!value || status === 'completed' || status === 'cancelled') return false
  const now = new Date()
  const today = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`
  return value < today
}

function projectName(task: MyTaskDto): string | null {
  return task.project?.name ?? task.milestone?.name ?? null
}

function estimatedHours(task: MyTaskDto): string {
  if (
    task.estimated_hours === null ||
    task.estimated_hours === undefined ||
    task.estimated_hours === ''
  ) {
    return '—'
  }
  const hours = Number(task.estimated_hours)
  return Number.isFinite(hours) ? `${hours}h` : '—'
}

function TaskLabels({ task }: { task: MyTaskDto }) {
  const status = statusPresentation(task.status)
  const priority = priorityPresentation(task.priority)
  const StatusIcon = status.icon
  return (
    <div className="flex flex-wrap items-center gap-2">
      <StatusChip
        label={status.label}
        tone={status.tone}
        dense
        icon={<StatusIcon className="size-3" />}
      />
      <StatusChip
        label={priority.label}
        tone={priority.tone}
        dense
        icon={<Flag className="size-3" />}
      />
    </div>
  )
}

function TaskDescription({ task }: { task: MyTaskDto }) {
  const project = projectName(task)
  return (
    <div className="min-w-0">
      <p className="text-label text-text-primary truncate font-semibold">{task.name}</p>
      <p className="text-caption text-text-secondary mt-1 line-clamp-2">
        {task.description?.trim() || project || `Task #${task.id}`}
      </p>
    </div>
  )
}

function TaskStatusButton({
  task,
  canUpdate,
  onStart,
  onComplete,
}: {
  task: MyTaskDto
  canUpdate: boolean
  onStart: () => void
  onComplete: () => void
}) {
  if (!canUpdate) return null
  if (task.status === 'pending') {
    return (
      <Button
        variant="outline"
        size="sm"
        onClick={onStart}
        leadingIcon={<ListChecks className="size-4" />}
      >
        Start task
      </Button>
    )
  }
  if (task.status === 'in_progress') {
    return (
      <Button
        variant="primary"
        size="sm"
        onClick={onComplete}
        leadingIcon={<CheckCircle2 className="size-4" />}
      >
        Mark complete
      </Button>
    )
  }
  return null
}

function TaskRow({
  task,
  canUpdate,
  canView,
  onStart,
  onComplete,
  onDetails,
}: {
  task: MyTaskDto
  canUpdate: boolean
  canView: boolean
  onStart: () => void
  onComplete: () => void
  onDetails: () => void
}) {
  const overdue = isOverdue(task.due_date, task.status)
  return (
    <article
      className={`border-border-subtle ${desktopTaskGridColumns} desktop:items-center desktop:gap-4 tablet:px-5 grid gap-3 border-b px-4 py-4 last:border-b-0`}
    >
      <div className="flex min-w-0 items-start gap-3">
        <span className="bg-primary-subtle text-primary rounded-control mt-0.5 flex size-9 shrink-0 items-center justify-center">
          <ClipboardList className="size-4" aria-hidden="true" />
        </span>
        <div className="min-w-0 flex-1">
          <TaskDescription task={task} />
          <div className="desktop:hidden mt-2">
            <TaskLabels task={task} />
          </div>
        </div>
      </div>
      <div className="text-body-sm text-text-secondary desktop:block hidden min-w-0 truncate">
        {projectName(task) ?? 'No project'}
      </div>
      <div className="desktop:block hidden">
        <TaskLabels task={task} />
      </div>
      <div className="text-caption desktop:text-body-sm text-text-secondary flex items-center gap-2">
        <CalendarDays className="text-text-muted size-4 shrink-0" aria-hidden="true" />
        <span className={overdue ? 'text-danger font-semibold' : ''}>
          {overdue ? 'Overdue · ' : ''}
          {formatDate(task.due_date)}
        </span>
      </div>
      <div className="flex flex-wrap items-center justify-end gap-2">
        {canView ? (
          <Button
            variant="ghost"
            size="sm"
            onClick={onDetails}
            leadingIcon={<Eye className="size-4" />}
          >
            Details
          </Button>
        ) : null}
        <TaskStatusButton
          task={task}
          canUpdate={canUpdate}
          onStart={onStart}
          onComplete={onComplete}
        />
      </div>
      <div className="text-caption text-text-muted desktop:hidden flex items-center gap-1.5 pl-12">
        <Clock3 className="size-3.5" aria-hidden="true" />
        Estimated time: {estimatedHours(task)}
      </div>
    </article>
  )
}

function TaskCard({
  task,
  canUpdate,
  canView,
  onStart,
  onComplete,
  onDetails,
}: {
  task: MyTaskDto
  canUpdate: boolean
  canView: boolean
  onStart: () => void
  onComplete: () => void
  onDetails: () => void
}) {
  const overdue = isOverdue(task.due_date, task.status)
  return (
    <article className="border-border-subtle rounded-surface bg-surface shadow-elevation-sm tablet:p-5 hover:border-border-strong border p-4 motion-safe:transition-colors motion-safe:duration-150">
      <div className="flex items-start justify-between gap-3">
        <div className="flex min-w-0 flex-1 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control mt-0.5 flex size-9 shrink-0 items-center justify-center">
            <ClipboardList className="size-4" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <TaskDescription task={task} />
          </div>
        </div>
        <span className="bg-surface-muted text-caption text-text-secondary rounded-pill shrink-0 px-2.5 py-1 font-medium">
          Task #{task.id}
        </span>
      </div>
      <div className="mt-3">
        <TaskLabels task={task} />
      </div>
      <dl className="border-border-subtle tablet:grid-cols-4 mt-4 grid grid-cols-2 gap-x-5 gap-y-3 border-t pt-4">
        <div className="min-w-0">
          <dt className="text-caption text-text-muted">Project</dt>
          <dd className="text-body-sm text-text-primary mt-1 truncate font-medium">
            {projectName(task) ?? 'No project'}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-caption text-text-muted">Due date</dt>
          <dd
            className={`text-body-sm mt-1 font-medium ${overdue ? 'text-danger' : 'text-text-primary'}`}
          >
            {overdue ? 'Overdue · ' : ''}
            {formatDate(task.due_date)}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-caption text-text-muted">Estimated time</dt>
          <dd className="text-body-sm text-text-primary mt-1 font-medium">
            {estimatedHours(task)}
          </dd>
        </div>
        <div className="min-w-0">
          <dt className="text-caption text-text-muted">Milestone</dt>
          <dd className="text-body-sm text-text-primary mt-1 truncate font-medium">
            {task.milestone?.name ?? '—'}
          </dd>
        </div>
      </dl>
      {canView || canUpdate ? (
        <div className="border-border-subtle mt-4 flex flex-wrap justify-end gap-2 border-t pt-3">
          {canView ? (
            <Button
              variant="ghost"
              size="sm"
              onClick={onDetails}
              leadingIcon={<Eye className="size-4" />}
            >
              Details
            </Button>
          ) : null}
          <TaskStatusButton
            task={task}
            canUpdate={canUpdate}
            onStart={onStart}
            onComplete={onComplete}
          />
        </div>
      ) : null}
    </article>
  )
}

function TaskDetails({ task }: { task: MyTaskDto }) {
  const status = statusPresentation(task.status)
  const priority = priorityPresentation(task.priority)
  const StatusIcon = status.icon
  const values = [
    { label: 'Task', value: task.name },
    { label: 'Project', value: task.project?.name ?? 'Not linked to a project' },
    { label: 'Milestone', value: task.milestone?.name ?? 'Not linked to a milestone' },
    { label: 'Due date', value: formatDate(task.due_date) },
    { label: 'Estimated time', value: estimatedHours(task) },
  ]
  return (
    <div className="space-y-5">
      <div className="flex flex-wrap gap-2">
        <StatusChip
          label={status.label}
          tone={status.tone}
          icon={<StatusIcon className="size-3.5" />}
        />
        <StatusChip
          label={`${priority.label} priority`}
          tone={priority.tone}
          icon={<Flag className="size-3.5" />}
        />
      </div>
      <dl className="divide-border-subtle rounded-control border-border-subtle divide-y border px-4">
        {values.map(({ label, value }) => (
          <div key={label} className="flex flex-wrap justify-between gap-x-6 gap-y-1 py-3">
            <dt className="text-body-sm text-text-secondary">{label}</dt>
            <dd className="text-body-sm text-text-primary max-w-full text-right font-medium">
              {value}
            </dd>
          </div>
        ))}
      </dl>
      <section>
        <h3 className="text-label text-text-primary font-semibold">Description</h3>
        <p className="text-body-sm text-text-secondary mt-2 whitespace-pre-wrap">
          {task.description?.trim() || 'No description was provided for this task.'}
        </p>
      </section>
      <p className="text-caption text-text-muted">
        Task #{task.id} · Updated{' '}
        {new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(
          new Date(task.updated_at),
        )}
      </p>
    </div>
  )
}

function countLabel(summary: MyTasksSummaryDto | undefined, key: keyof MyTasksSummaryDto): string {
  return summary ? String(summary[key]) : '—'
}

function paramsFromSearch(search: MyTasksSearch): MyTasksListParams {
  return {
    status: search.status,
    priority: search.priority,
    sort: search.sort,
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
  }
}

export function MyTasksPage() {
  const search = useSearch({ from: '/_protected/dashboard/my-tasks' }) as MyTasksSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canRead =
    hasPermission(permissions, 'tasks', 'list') || hasPermission(permissions, 'tasks', 'list_own')
  const canViewDetails =
    hasPermission(permissions, 'tasks', 'view') || hasPermission(permissions, 'tasks', 'view_own')
  const canUpdate =
    hasPermission(permissions, 'tasks', 'update') ||
    hasPermission(permissions, 'tasks', 'update_own')
  const [taskToComplete, setTaskToComplete] = useState<MyTaskDto | null>(null)
  const [actionError, setActionError] = useState<string | null>(null)
  const params = useMemo(() => paramsFromSearch(search), [search])

  const listQuery = useQuery({
    ...myTasksListQueryOptions(userId, employeeId, params),
    enabled: Boolean(session && canRead),
  })
  const summaryQuery = useQuery({
    ...myTasksSummaryQueryOptions(userId, employeeId),
    enabled: Boolean(session && canRead),
  })
  const detailQuery = useQuery({
    ...myTaskDetailQueryOptions(userId, employeeId, search.task ?? 0),
    enabled: Boolean(session && canViewDetails && search.task),
  })

  const updateSearch = (updates: Partial<MyTasksSearch>, replace = false) => {
    void navigate({
      to: '/dashboard/my-tasks',
      search: (previous: MyTasksSearch) => ({ ...previous, ...updates }),
      replace,
      resetScroll: false,
    })
  }

  const updateStatusMutation = useMutation({
    mutationFn: ({
      taskId,
      status,
    }: {
      taskId: number
      status: Extract<TaskStatus, 'in_progress' | 'completed'>
    }) => myTasksApi.updateStatus(taskId, status),
    onSuccess: async (updatedTask) => {
      queryClient.setQueryData(
        myTasksQueryKeys.detail(userId, employeeId, updatedTask.id),
        updatedTask,
      )
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: myTasksQueryKeys.lists(userId, employeeId) }),
        queryClient.invalidateQueries({ queryKey: myTasksQueryKeys.summary(userId, employeeId) }),
        queryClient.invalidateQueries({
          queryKey: personalWorkQueryKeys.tasks(userId, employeeId),
        }),
        queryClient.invalidateQueries({
          queryKey: personalWorkQueryKeys.completedTasks(userId, employeeId),
        }),
      ])
      setActionError(null)
      toast.showToast({
        title: 'Task updated',
        description: `Task marked ${updatedTask.status === 'completed' ? 'complete' : 'in progress'}.`,
        tone: 'success',
      })
    },
    onError: (error, variables) => {
      if (variables.status === 'in_progress') {
        setActionError(presentError(error, 'form-submit').message)
      }
    },
  })

  const openDetails = (task: MyTaskDto) => updateSearch({ task: task.id })
  const closeDetails = () => updateSearch({ task: undefined })
  const startTask = (task: MyTaskDto) => {
    setActionError(null)
    updateStatusMutation.mutate({ taskId: task.id, status: 'in_progress' })
  }
  const completeTask = async () => {
    if (!taskToComplete) return
    setActionError(null)
    try {
      await updateStatusMutation.mutateAsync({ taskId: taskToComplete.id, status: 'completed' })
      setTaskToComplete(null)
    } catch {
      // The mutation message is shown in this confirmation so the user can retry.
    }
  }

  const tasks = listQuery.data?.items ?? []
  const resultCount = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(resultCount / PAGE_SIZE))
  const selectedTask = detailQuery.data
  const hasCachedTaskList = Boolean(listQuery.data)
  const hasTaskListRefreshError = listQuery.isError && hasCachedTaskList
  const currentTaskForCompletion = taskToComplete
  const taskActionProps = (task: MyTaskDto) => ({
    task,
    canUpdate,
    canView: canViewDetails,
    onStart: () => startTask(task),
    onComplete: () => setTaskToComplete(task),
    onDetails: () => openDetails(task),
  })

  if (session && !canRead) {
    return (
      <PageLayout title="My Tasks" subtitle="Tasks assigned to you">
        <ErrorState
          title="You can’t view these tasks"
          description="Your account does not have access to the personal task list."
        />
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="My Tasks"
      subtitle="Manage and track the work assigned to you."
      leading={<ListChecks className="size-[18px]" aria-hidden="true" />}
    >
      <div className="space-y-5">
        {actionError ? (
          <Alert tone="danger" role="alert" title="Task update not saved">
            {actionError}
          </Alert>
        ) : null}

        <section
          aria-label="Task list controls"
          className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm phone:p-4 tablet:p-5 space-y-4 border p-3"
        >
          <div className="phone:flex-row phone:items-center phone:justify-between flex flex-col gap-3">
            <div>
              <h2 id="task-list-heading" className="text-h3 text-text-primary font-semibold">
                Assigned tasks
              </h2>
              <p className="text-caption text-text-secondary mt-1" aria-live="polite">
                {listQuery.isPending && !listQuery.data
                  ? 'Loading your task list…'
                  : `${resultCount} ${resultCount === 1 ? 'task' : 'tasks'} in this view`}
              </p>
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between gap-3">
              <p className="text-caption text-text-secondary font-semibold">Filter by status</p>
              <span className="text-caption text-text-muted">Counts cover all assigned tasks</span>
            </div>
            <div
              role="group"
              aria-label="Filter tasks by status"
              className="horizontal-scrollbar bg-surface-muted rounded-control overflow-x-auto p-1"
            >
              <div className="tablet:w-full flex w-[34rem] gap-1">
                {taskTabs.map((tab) => {
                  const active = search.status === tab.id
                  const count = countLabel(summaryQuery.data, tab.countKey)
                  const Icon = tab.icon
                  return (
                    <button
                      key={tab.id}
                      type="button"
                      aria-pressed={active}
                      aria-label={`${tab.label}, ${count} ${count === '1' ? 'task' : 'tasks'}`}
                      onClick={() => updateSearch({ status: tab.id, page: 1 })}
                      className={`focus-visible:shadow-focus-ring text-caption rounded-control inline-flex min-h-10 min-w-0 flex-1 items-center justify-center gap-1.5 px-2 py-2 font-medium whitespace-nowrap focus-visible:outline-none motion-safe:transition-colors motion-safe:duration-150 ${
                        active
                          ? 'bg-surface text-text-primary shadow-elevation-sm ring-border-subtle ring-1'
                          : 'text-text-secondary hover:bg-surface/75 hover:text-text-primary'
                      }`}
                    >
                      <Icon className={`size-4 shrink-0 ${tab.accent}`} aria-hidden="true" />
                      {tab.label}
                      <span
                        className={`rounded-pill text-overline min-w-5 px-1.5 py-0.5 text-center ${tab.countAccent}`}
                      >
                        {count}
                      </span>
                    </button>
                  )
                })}
              </div>
            </div>
          </div>

          <div className="phone:grid-cols-2 grid grid-cols-1 gap-3">
            <DropdownSelect
              id="task-priority"
              label="Priority"
              value={search.priority}
              options={priorityFilterOptions}
              onChange={(priority) =>
                updateSearch({ priority: priority as TaskPriorityFilter, page: 1 })
              }
            />
            <DropdownSelect
              id="task-sort"
              label="Sort by"
              value={search.sort}
              options={taskSortOptions}
              onChange={(sort) => updateSearch({ sort: sort as TaskSort, page: 1 })}
            />
          </div>
        </section>

        {hasTaskListRefreshError ? (
          <Alert
            tone="warning"
            role="status"
            className="flex flex-wrap items-center justify-between gap-x-4 gap-y-2 py-2.5"
          >
            <p className="text-body-sm text-text-secondary flex min-w-0 flex-1 items-center gap-2">
              <CircleAlert className="text-warning-foreground size-4 shrink-0" aria-hidden="true" />
              <span>Could not refresh the task list. Showing the last loaded results.</span>
            </p>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => void listQuery.refetch()}
              isLoading={listQuery.isFetching}
              leadingIcon={<RefreshCw className="size-4" />}
            >
              Retry task list
            </Button>
          </Alert>
        ) : null}

        {listQuery.isFetching && listQuery.data ? (
          <p className="text-caption text-text-secondary flex items-center gap-2" role="status">
            <RefreshCw className="size-3.5 motion-safe:animate-spin" aria-hidden="true" />
            Updating your tasks…
          </p>
        ) : null}

        {listQuery.isPending ? (
          <section
            aria-label="Loading tasks"
            className="border-border-subtle bg-surface rounded-surface tablet:p-5 space-y-4 border p-4"
          >
            <Skeleton variant="row" className="h-16" />
            <Skeleton variant="row" className="h-16" />
            <Skeleton variant="row" className="h-16" />
          </section>
        ) : listQuery.isError && !listQuery.data ? (
          <section className="border-border-subtle bg-surface rounded-surface border">
            <ErrorState
              title="Your tasks could not load"
              description="Check your connection and try again."
              error={listQuery.error}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Try again
                </Button>
              }
            />
          </section>
        ) : tasks.length === 0 ? (
          <section className="border-border-subtle bg-surface rounded-surface border">
            <EmptyState
              title={
                search.priority !== 'all' || search.status !== 'all'
                  ? 'No tasks match these filters'
                  : 'No tasks assigned yet'
              }
              description={
                search.priority !== 'all' || search.status !== 'all'
                  ? 'Adjust your filters or clear them to see more tasks.'
                  : 'Tasks assigned to you will appear here.'
              }
              icon={<ClipboardList className="size-5" />}
              action={
                search.priority !== 'all' || search.status !== 'all' ? (
                  <Button
                    variant="outline"
                    onClick={() => {
                      updateSearch({
                        status: 'all',
                        priority: 'all',
                        sort: 'due_date',
                        page: 1,
                      })
                    }}
                  >
                    Clear filters
                  </Button>
                ) : undefined
              }
            />
          </section>
        ) : (
          <section
            aria-label="Assigned tasks"
            className="border-border-subtle bg-surface rounded-surface shadow-elevation-sm overflow-hidden border"
          >
            <div
              className={`border-border-subtle bg-surface-muted ${desktopTaskGridColumns} desktop:grid hidden gap-4 border-b px-5 py-3`}
            >
              {['Task', 'Project or milestone', 'Status and priority', 'Due date', 'Actions'].map(
                (label) => (
                  <span key={label} className="text-overline text-text-secondary font-semibold">
                    {label}
                  </span>
                ),
              )}
            </div>
            <div className="desktop:hidden bg-background space-y-3 p-3">
              {tasks.map((task) => (
                <TaskCard key={task.id} {...taskActionProps(task)} />
              ))}
            </div>
            <div className="desktop:block hidden">
              {tasks.map((task) => (
                <TaskRow key={task.id} {...taskActionProps(task)} />
              ))}
            </div>
            <footer className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
              <p className="text-caption text-text-secondary" aria-live="polite">
                {resultCount === 0
                  ? 'No results'
                  : `Showing ${(search.page - 1) * PAGE_SIZE + 1}–${Math.min(search.page * PAGE_SIZE, resultCount)} of ${resultCount} tasks`}
              </p>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page <= 1 || listQuery.isFetching}
                  onClick={() => updateSearch({ page: Math.max(1, search.page - 1) }, true)}
                  leadingIcon={<ChevronLeft className="size-4" />}
                >
                  Previous
                </Button>
                <span className="text-caption text-text-secondary min-w-16 text-center">
                  Page {search.page} of {pageCount}
                </span>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={search.page >= pageCount || listQuery.isFetching}
                  onClick={() => updateSearch({ page: Math.min(pageCount, search.page + 1) }, true)}
                  leadingIcon={<ChevronRight className="size-4" />}
                >
                  Next
                </Button>
              </div>
            </footer>
          </section>
        )}

        {detailQuery.isFetching && detailQuery.data ? (
          <p className="sr-only" role="status">
            Refreshing task details.
          </p>
        ) : null}
      </div>

      <Dialog
        open={Boolean(search.task)}
        onOpenChange={(open) => {
          if (!open) closeDetails()
        }}
        title="Task details"
        description="Information for the task assigned to you."
        size="md"
        className="desktop:inset-y-0 desktop:right-0 desktop:left-auto desktop:m-0 desktop:h-dvh desktop:min-h-dvh desktop:max-h-none desktop:w-[min(48rem,calc(100vw-6rem))] desktop:max-w-none desktop:translate-y-0 desktop:rounded-none desktop:border-y-0 desktop:border-r-0 desktop:border-l"
        footer={
          selectedTask ? (
            <div className="flex w-full flex-wrap items-center justify-between gap-2">
              <span className="text-caption text-text-secondary">Task #{selectedTask.id}</span>
              <div className="flex flex-wrap justify-end gap-2">
                {selectedTask.status === 'pending' && canUpdate ? (
                  <Button
                    variant="outline"
                    onClick={() => startTask(selectedTask)}
                    isLoading={updateStatusMutation.isPending}
                  >
                    Start task
                  </Button>
                ) : null}
                {selectedTask.status === 'in_progress' && canUpdate ? (
                  <Button
                    variant="primary"
                    onClick={() => setTaskToComplete(selectedTask)}
                    isLoading={updateStatusMutation.isPending}
                  >
                    Mark complete
                  </Button>
                ) : null}
              </div>
            </div>
          ) : undefined
        }
      >
        {detailQuery.isPending ? (
          <div className="space-y-4">
            <Skeleton variant="row" />
            <Skeleton variant="card" className="h-40" />
          </div>
        ) : detailQuery.isError ? (
          <ErrorState
            title="Task details could not load"
            description="This task may have changed or you may no longer have access to it."
            error={detailQuery.error}
            action={
              <Button variant="outline" onClick={() => void detailQuery.refetch()}>
                Try again
              </Button>
            }
          />
        ) : selectedTask ? (
          <TaskDetails task={selectedTask} />
        ) : (
          <EmptyState
            title="Task details are unavailable"
            description="Your account can see the task list but does not have permission to view task records."
          />
        )}
      </Dialog>

      <Dialog
        open={Boolean(currentTaskForCompletion)}
        onOpenChange={(open) => {
          if (!open && !updateStatusMutation.isPending) setTaskToComplete(null)
        }}
        title="Mark this task complete?"
        description={
          currentTaskForCompletion
            ? `“${currentTaskForCompletion.name}” is shared with everyone assigned to it. Completing it will update the task status for the team.`
            : undefined
        }
        size="sm"
        fitContent
        compactOnMobile
        footer={
          currentTaskForCompletion ? (
            <>
              <Button
                variant="outline"
                onClick={() => setTaskToComplete(null)}
                disabled={updateStatusMutation.isPending}
              >
                Cancel
              </Button>
              <Button
                variant="primary"
                onClick={() => void completeTask()}
                isLoading={updateStatusMutation.isPending}
                leadingIcon={<Check className="size-4" />}
              >
                Mark complete
              </Button>
            </>
          ) : undefined
        }
      >
        <div className="space-y-4">
          <Alert tone="info" title="Shared task status">
            <span>Other people assigned to this task will see it as completed.</span>
          </Alert>
          {updateStatusMutation.isError ? (
            <Alert tone="danger" role="alert" title="The task was not changed">
              The update did not reach the server. You can retry or cancel.
            </Alert>
          ) : null}
        </div>
      </Dialog>
    </PageLayout>
  )
}
