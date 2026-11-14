import { useEffect, useState, type FormEvent } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  ArrowRight,
  CalendarDays,
  ClipboardList,
  Plus,
  Search,
  Trash2,
  UserRound,
  X,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import { myTasksQueryKeys } from '@/modules/tasks/tasks.queries'
import { operationsRegisterKeys, operationsRegisterQueries } from '../operations-registers.queries'
import {
  operationsRegistersApi,
  type OperationsTask,
  type OperationsWorksite,
} from '../operations-registers.api'
import { projectIdForWorksiteSelection } from '../operations-registers.forms'
import { projectQueryKeys, type ProjectListParams, projectsApi } from '../projects.api'
import { projectQueries } from '../projects.queries'
import type { OperationsTasksSearch } from '../operations-registers.search'

const PAGE_SIZE = 10
const statuses = [
  { value: 'active', label: 'Active work' },
  { value: 'all', label: 'All tasks' },
  { value: 'pending', label: 'Pending' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]
const priorities = [
  { value: '', label: 'All priorities' },
  { value: 'high', label: 'High' },
  { value: 'medium', label: 'Medium' },
  { value: 'low', label: 'Low' },
]
const taskStatuses = [
  { value: 'pending', label: 'Pending' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]
const taskPriorities = priorities.filter((item) => item.value)

function dateLabel(value: string | null) {
  if (!value) return 'No due date'
  const [year, month, day] = value.split('-').map(Number)
  return new Intl.DateTimeFormat(undefined, { dateStyle: 'medium' }).format(
    new Date(year, month - 1, day),
  )
}

function tone(status: string): 'neutral' | 'info' | 'success' | 'warning' | 'danger' {
  if (status === 'completed') return 'success'
  if (status === 'in_progress') return 'info'
  if (status === 'cancelled') return 'danger'
  return 'warning'
}

function TaskSearch({ value }: { value: string }) {
  const navigate = useNavigate()
  const [draft, setDraft] = useState(value)
  useEffect(() => {
    const search = draft.trim().slice(0, 120)
    if (search === value) return
    const timer = window.setTimeout(
      () =>
        void navigate({
          to: '/works/tasks',
          search: (previous: OperationsTasksSearch) => ({ ...previous, search, page: 1 }),
          replace: true,
          resetScroll: false,
        }),
      250,
    )
    return () => window.clearTimeout(timer)
  }, [draft, navigate, value])
  return (
    <label
      htmlFor="operations-task-search"
      className="text-control-label text-text-secondary block space-y-1.5 font-bold"
    >
      Search tasks
      <span className="relative block">
        <Search
          className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="operations-task-search"
          type="search"
          value={draft}
          maxLength={120}
          className="pl-9"
          placeholder="Task name or work detail"
          onChange={(event) => setDraft(event.target.value)}
        />
      </span>
    </label>
  )
}

export function OperationsTasksPage() {
  const search = useSearch({ strict: false }) as OperationsTasksSearch
  const navigate = useNavigate()
  const client = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const [formOpen, setFormOpen] = useState(false)
  const [editing, setEditing] = useState<OperationsTask | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<OperationsTask | null>(null)
  const [errorMessage, setErrorMessage] = useState('')
  const params = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
    status: search.status === 'all' ? '' : search.status,
    priority: search.priority,
    project_id: search.projectId,
    worksite_id: search.worksiteId,
  }
  const tasks = useQuery({
    ...operationsRegisterQueries.tasks(userId, employeeId, params),
    enabled: Boolean(session && hasPermission(session.permissions, 'tasks', 'list')),
  })
  const projects = useQuery({
    ...projectQueries.list(userId, employeeId, {
      limit: 100,
      offset: 0,
      search: '',
      status: '',
      priority: '',
      archived: false,
    } satisfies ProjectListParams),
    enabled: Boolean(session && hasPermission(session.permissions, 'projects', 'list')),
  })
  const worksites = useQuery({
    ...operationsRegisterQueries.worksites(userId, employeeId, {
      limit: 100,
      offset: 0,
      search: '',
      status: '',
      project_id: null,
    }),
    enabled: Boolean(session && hasPermission(session.permissions, 'worksites', 'list')),
  })
  const canCreate = Boolean(session && hasPermission(session.permissions, 'tasks', 'create'))
  const canUpdate = Boolean(session && hasPermission(session.permissions, 'tasks', 'update'))
  const canDelete = Boolean(session && hasPermission(session.permissions, 'tasks', 'delete'))
  const canView = Boolean(session && hasPermission(session.permissions, 'tasks', 'view'))

  async function invalidateTaskData() {
    await Promise.all([
      client.invalidateQueries({
        queryKey: operationsRegisterKeys.lists(userId, employeeId, 'tasks'),
      }),
      client.invalidateQueries({
        queryKey: operationsRegisterKeys.details(userId, employeeId, 'task'),
      }),
      client.invalidateQueries({ queryKey: projectQueryKeys.all }),
      client.invalidateQueries({ queryKey: myTasksQueryKeys.all }),
    ])
  }
  const save = useMutation({
    mutationFn: (input: TaskWrite) =>
      editing
        ? operationsRegistersApi.updateTask(editing.id, input)
        : operationsRegistersApi.createTask(input),
    onSuccess: async (task) => {
      await invalidateTaskData()
      setFormOpen(false)
      setEditing(null)
      toast.showToast({
        title: editing ? 'Task updated' : 'Task created',
        description: `${task.name} is saved and assigned work is available in My Tasks.`,
        tone: 'success',
      })
    },
    onError: (error) =>
      setErrorMessage(error instanceof Error ? error.message : 'The task could not be saved.'),
  })
  const remove = useMutation({
    mutationFn: (task: OperationsTask) => operationsRegistersApi.removeTask(task.id),
    onSuccess: async () => {
      await invalidateTaskData()
      setDeleteTarget(null)
      toast.showToast({
        title: 'Task deleted',
        description: 'The task has been removed.',
        tone: 'success',
      })
    },
    onError: (error) => {
      setDeleteTarget(null)
      toast.showToast({
        title: 'Could not delete task',
        description: error instanceof Error ? error.message : 'Try again.',
        tone: 'danger',
      })
    },
  })
  const changeStatus = useMutation({
    mutationFn: ({ task, status }: { task: OperationsTask; status: OperationsTask['status'] }) =>
      operationsRegistersApi.updateTask(task.id, { status }),
    onSuccess: async () => {
      await invalidateTaskData()
      toast.showToast({ title: 'Task status updated', tone: 'success' })
    },
    onError: (error) =>
      toast.showToast({
        title: 'Status was not updated',
        description: error instanceof Error ? error.message : 'Try again.',
        tone: 'danger',
      }),
  })

  function change(patch: Partial<OperationsTasksSearch>) {
    void navigate({
      to: '/works/tasks',
      search: (previous: OperationsTasksSearch) => ({ ...previous, ...patch }),
      resetScroll: false,
    })
  }
  function startCreate() {
    setEditing(null)
    setErrorMessage('')
    setFormOpen(true)
  }

  return (
    <PageLayout
      title="Tasks"
      subtitle="Plan and assign delivery work across projects and field sites."
      actionsInline
      actions={
        canCreate ? (
          <Button size="sm" leadingIcon={<Plus className="size-4" />} onClick={startCreate}>
            <span className="hidden min-[480px]:inline">New task</span>
            <span className="min-[480px]:hidden">Add</span>
          </Button>
        ) : null
      }
    >
      <div className="space-y-5">
        <Card className="space-y-4">
          <div className="flex flex-wrap items-end justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Operations register</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Task board</h2>
              <p className="text-body-sm text-text-secondary mt-1">
                {tasks.data?.count ?? '—'} {search.status === 'active' ? 'active tasks' : 'tasks'}{' '}
                in your access scope
              </p>
            </div>
            <div className="w-full min-[480px]:w-56">
              <DropdownSelect
                label="Task view"
                value={search.status}
                options={statuses}
                onChange={(status) => change({ status, page: 1 })}
              />
            </div>
          </div>
          <div className="tablet:grid-cols-2 grid gap-3">
            <TaskSearch key={search.search} value={search.search} />
            <DropdownSelect
              label="Priority"
              value={search.priority}
              options={priorities}
              onChange={(priority) => change({ priority, page: 1 })}
            />
          </div>
          <div className="tablet:grid-cols-2 grid gap-3">
            <DropdownSelect
              label="Project"
              value={String(search.projectId ?? '')}
              options={[
                { value: '', label: 'All projects' },
                ...(projects.data?.items ?? []).map((project) => ({
                  value: String(project.id),
                  label: `${project.short_code} · ${project.name}`,
                })),
              ]}
              onChange={(value) =>
                change({ projectId: value ? Number(value) : null, worksiteId: null, page: 1 })
              }
            />
            <DropdownSelect
              label="Worksite"
              value={String(search.worksiteId ?? '')}
              options={[
                { value: '', label: 'All worksites' },
                ...(worksites.data?.items ?? [])
                  .filter((site) => !search.projectId || site.project_id === search.projectId)
                  .map((site) => ({ value: String(site.id), label: site.name })),
              ]}
              onChange={(value) => change({ worksiteId: value ? Number(value) : null, page: 1 })}
            />
          </div>
        </Card>
        {tasks.isPending ? (
          <div role="status" aria-label="Loading tasks" className="space-y-3">
            <Skeleton variant="card" className="h-44" />
            <Skeleton variant="card" className="h-44" />
          </div>
        ) : tasks.isError ? (
          <ErrorState
            title="Tasks could not load"
            error={tasks.error}
            action={
              <Button variant="outline" onClick={() => void tasks.refetch()}>
                Try again
              </Button>
            }
          />
        ) : !tasks.data?.items.length ? (
          <Card>
            <EmptyState
              title={
                search.status === 'active'
                  ? 'No active tasks need attention'
                  : 'No tasks match this view'
              }
              description={
                search.status === 'active'
                  ? 'Pending and in-progress work will appear here. Switch to All tasks to review completed history.'
                  : 'Adjust the filters or create a task for the team.'
              }
              action={
                canCreate ? (
                  <Button onClick={startCreate} leadingIcon={<Plus className="size-4" />}>
                    New task
                  </Button>
                ) : null
              }
            />
          </Card>
        ) : (
          <section className="space-y-3" aria-label="Operations task records">
            {tasks.data.items.map((task) => (
              <TaskCard
                key={task.id}
                task={task}
                canView={canView}
                canUpdate={canUpdate}
                canDelete={canDelete}
                busy={changeStatus.isPending && changeStatus.variables?.task.id === task.id}
                onStatus={(status) => changeStatus.mutate({ task, status })}
                onEdit={() => {
                  setEditing(task)
                  setErrorMessage('')
                  setFormOpen(true)
                }}
                onDelete={() => setDeleteTarget(task)}
              />
            ))}
          </section>
        )}
        {tasks.data && tasks.data.count > PAGE_SIZE ? (
          <Pagination
            count={tasks.data.count}
            page={search.page}
            onPage={(page) => change({ page })}
          />
        ) : null}
      </div>
      <TaskForm
        key={`${formOpen}-${editing?.id ?? 'new'}`}
        open={formOpen}
        task={editing}
        projects={projects.data?.items ?? []}
        worksites={worksites.data?.items ?? []}
        error={errorMessage}
        busy={save.isPending}
        onClose={() => setFormOpen(false)}
        onSave={(input) => save.mutate(input)}
      />
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title="Delete task?"
        description={deleteTarget?.name}
        size="sm"
        fitContent
        footer={
          <div className="flex justify-end gap-2">
            <Button variant="outline" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              isLoading={remove.isPending}
              onClick={() => deleteTarget && remove.mutate(deleteTarget)}
            >
              Delete task
            </Button>
          </div>
        }
      >
        <p className="text-body-sm text-text-secondary">
          This removes the task from Operations and from assigned employees’ My Tasks lists.
        </p>
      </Dialog>
    </PageLayout>
  )
}

type TaskWrite = Pick<
  OperationsTask,
  | 'name'
  | 'description'
  | 'project_id'
  | 'milestone_id'
  | 'worksite_id'
  | 'status'
  | 'priority'
  | 'assigned_to'
  | 'due_date'
  | 'estimated_hours'
>

function TaskCard({
  task,
  canView,
  canUpdate,
  canDelete,
  busy,
  onStatus,
  onEdit,
  onDelete,
}: {
  task: OperationsTask
  canView: boolean
  canUpdate: boolean
  canDelete: boolean
  busy: boolean
  onStatus: (status: OperationsTask['status']) => void
  onEdit: () => void
  onDelete: () => void
}) {
  return (
    <Card className="overflow-hidden p-0" elevation="sm">
      <div className="flex flex-wrap items-start justify-between gap-3 p-4">
        <div className="flex min-w-0 items-start gap-3">
          <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
            <ClipboardList className="size-5" aria-hidden="true" />
          </span>
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              <h3 className="text-label text-text-primary font-semibold break-words">
                {task.name}
              </h3>
              <StatusChip dense label={task.status.replaceAll('_', ' ')} tone={tone(task.status)} />
            </div>
            <p className="text-body-sm text-text-secondary mt-1 break-words">
              {task.project?.short_code ? `${task.project.short_code} · ` : ''}
              {task.project?.name ?? 'Project-wide task'}
              {task.worksite ? ` · ${task.worksite.name}` : ''}
            </p>
            {task.description ? (
              <p className="text-body-sm text-text-secondary mt-2 line-clamp-2 break-words">
                {task.description}
              </p>
            ) : null}
          </div>
        </div>
        <StatusChip
          dense
          label={`${task.priority} priority`}
          tone={
            task.priority === 'high' ? 'danger' : task.priority === 'medium' ? 'warning' : 'neutral'
          }
        />
      </div>
      <div className="bg-surface-muted/60 border-border-subtle grid gap-3 border-t px-4 py-3 sm:grid-cols-3">
        <Fact
          icon={<CalendarDays className="size-4" />}
          label="Due"
          value={dateLabel(task.due_date)}
        />
        <Fact
          icon={<UserRound className="size-4" />}
          label="Assigned"
          value={
            task.assignees.length
              ? task.assignees.map((assignee) => assignee.name).join(', ')
              : 'Unassigned'
          }
        />
        <Fact
          label="Estimate"
          value={task.estimated_hours ? `${task.estimated_hours} hours` : 'Not estimated'}
        />
      </div>
      <footer className="border-border-subtle flex flex-wrap items-center justify-between gap-2 border-t px-4 py-3">
        <span className="text-caption text-text-muted">Task #{task.id}</span>
        <div className="flex flex-wrap gap-2">
          {canView ? (
            <Link
              to="/works/tasks/$taskId"
              params={{ taskId: String(task.id) }}
              className="rounded-control border-border-strong bg-surface text-text-primary hover:bg-surface-muted focus-visible:shadow-focus-ring text-caption inline-flex min-h-9 items-center gap-2 border px-3 font-semibold"
            >
              Details <ArrowRight className="size-4" />
            </Link>
          ) : null}
          {canUpdate ? (
            <DropdownSelect
              aria-label={`Change ${task.name} status`}
              value={task.status}
              options={taskStatuses}
              onChange={(value) => onStatus(value as OperationsTask['status'])}
              disabled={busy}
              className="min-w-36"
            />
          ) : null}
          {canUpdate ? (
            <Button size="sm" variant="outline" onClick={onEdit}>
              Edit
            </Button>
          ) : null}
          {canDelete ? (
            <Button size="sm" variant="ghost" onClick={onDelete} aria-label={`Delete ${task.name}`}>
              <Trash2 className="size-4" />
            </Button>
          ) : null}
        </div>
      </footer>
    </Card>
  )
}

function TaskForm({
  open,
  task,
  projects,
  worksites,
  error,
  busy,
  onClose,
  onSave,
}: {
  open: boolean
  task: OperationsTask | null
  projects: Array<{ id: number; name: string; short_code: string }>
  worksites: OperationsWorksite[]
  error: string
  busy: boolean
  onClose: () => void
  onSave: (input: TaskWrite) => void
}) {
  const [name, setName] = useState(task?.name ?? '')
  const [description, setDescription] = useState(task?.description ?? '')
  const [projectId, setProjectId] = useState(task?.project_id ? String(task.project_id) : '')
  const [worksiteId, setWorksiteId] = useState(task?.worksite_id ? String(task.worksite_id) : '')
  const [status, setStatus] = useState<OperationsTask['status']>(task?.status ?? 'pending')
  const [priority, setPriority] = useState<OperationsTask['priority']>(task?.priority ?? 'medium')
  const [dueDate, setDueDate] = useState(task?.due_date ?? '')
  const [estimatedHours, setEstimatedHours] = useState(task?.estimated_hours ?? '')
  const [assigned, setAssigned] = useState<number[]>(task?.assigned_to ?? [])
  const [assigneeOption, setAssigneeOption] = useState('')
  const members = useQuery({
    queryKey: ['operations-task-members', task?.id ?? 'new', projectId],
    queryFn: ({ signal }) => projectsApi.employeeOptions(Number(projectId), '', signal),
    enabled: Boolean(open && projectId),
  })
  const availableSites = worksites.filter(
    (site) => !projectId || site.project_id === Number(projectId),
  )
  const selectedWorksite = worksites.find((site) => String(site.id) === worksiteId)
  const projectOptions = [
    { value: '', label: 'No project selected' },
    ...projects.map((project) => ({
      value: String(project.id),
      label: `${project.short_code} · ${project.name}`,
    })),
    ...(projectId && !projects.some((project) => String(project.id) === projectId)
      ? [
          {
            value: projectId,
            label: `${selectedWorksite?.project_short_code ?? `Project #${projectId}`} · ${selectedWorksite?.project_name ?? selectedWorksite?.project?.name ?? 'Linked worksite project'}`,
          },
        ]
      : []),
  ]
  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    onSave({
      name: name.trim(),
      description: description.trim() || null,
      project_id: projectId ? Number(projectId) : null,
      milestone_id: task?.milestone_id ?? null,
      worksite_id: worksiteId ? Number(worksiteId) : null,
      status,
      priority,
      assigned_to: assigned,
      due_date: dueDate || null,
      estimated_hours: estimatedHours ? String(Number(estimatedHours)) : null,
    })
  }
  const memberOptions = (members.data ?? [])
    .filter((member) => !assigned.includes(member.id))
    .map((member) => ({
      value: String(member.id),
      label: `${member.name} · ${member.employee_id}`,
    }))
  return (
    <Dialog
      open={open}
      onOpenChange={(value) => !value && onClose()}
      title={task ? 'Edit task' : 'Create task'}
      description="Define delivery work, site context, timing, priority, and assigned employees."
      size="lg"
      footer={
        <div className="flex flex-wrap justify-end gap-2">
          <Button variant="outline" disabled={busy} onClick={onClose}>
            Cancel
          </Button>
          <Button type="submit" form="operations-task-form" isLoading={busy}>
            {task ? 'Save task' : 'Create task'}
          </Button>
        </div>
      }
    >
      <form id="operations-task-form" onSubmit={submit} className="space-y-4">
        {error ? (
          <p role="alert" className="text-body-sm text-danger">
            {error}
          </p>
        ) : null}
        <FormControl id="task-name" label="Task name" required>
          <TextInput
            value={name}
            onChange={(event) => setName(event.target.value)}
            maxLength={255}
            required
          />
        </FormControl>
        <FormControl id="task-description" label="Work details">
          <TextArea
            value={description}
            onChange={(event) => setDescription(event.target.value)}
            rows={3}
            maxLength={4000}
            placeholder="Describe the expected outcome and handoff"
          />
        </FormControl>
        <div className="grid gap-3 sm:grid-cols-2">
          <FormControl id="task-project" label="Project">
            <DropdownSelect
              value={projectId}
              options={projectOptions}
              onChange={(value) => {
                setProjectId(value)
                if (
                  value &&
                  worksiteId &&
                  !worksites.some(
                    (site) => String(site.id) === worksiteId && site.project_id === Number(value),
                  )
                )
                  setWorksiteId('')
              }}
              searchable
            />
          </FormControl>
          <FormControl id="task-worksite" label="Worksite">
            <DropdownSelect
              value={worksiteId}
              options={[
                { value: '', label: 'No worksite' },
                ...availableSites.map((site) => ({ value: String(site.id), label: site.name })),
              ]}
              onChange={(value) => {
                setWorksiteId(value)
                setProjectId(projectIdForWorksiteSelection(projectId, value, worksites))
              }}
              searchable
            />
          </FormControl>
        </div>
        <p className="text-caption text-text-secondary -mt-2">
          A project-linked worksite supplies its project automatically. Standalone worksites can
          only be linked to unprojected tasks.
        </p>
        <div className="grid gap-3 sm:grid-cols-2">
          <FormControl id="task-status" label="Status">
            <DropdownSelect
              value={status}
              options={taskStatuses}
              onChange={(value) => setStatus(value as OperationsTask['status'])}
            />
          </FormControl>
          <FormControl id="task-priority" label="Priority">
            <DropdownSelect
              value={priority}
              options={taskPriorities}
              onChange={(value) => setPriority(value as OperationsTask['priority'])}
            />
          </FormControl>
        </div>
        <div className="grid gap-3 sm:grid-cols-2">
          <FormControl id="task-due-date" label="Due date">
            <TextInput
              type="date"
              value={dueDate}
              onChange={(event) => setDueDate(event.target.value)}
            />
          </FormControl>
          <FormControl id="task-estimate" label="Estimate (hours)">
            <TextInput
              type="number"
              min="0"
              step="0.25"
              value={estimatedHours}
              onChange={(event) => setEstimatedHours(event.target.value)}
            />
          </FormControl>
        </div>
        <section className="bg-surface-muted rounded-control space-y-3 p-3">
          <div>
            <h3 className="text-label text-text-primary font-semibold">Assignment</h3>
            <p className="text-caption text-text-secondary mt-1">
              Project employees are validated against the project’s owning branch.
            </p>
          </div>
          {projectId ? (
            members.isError ? (
              <p role="alert" className="text-body-sm text-danger">
                Project members could not load. You can save the task without changing assignment.
              </p>
            ) : (
              <div className="flex flex-wrap items-end gap-2">
                <div className="min-w-0 flex-1">
                  <DropdownSelect
                    label="Add assignee"
                    value={assigneeOption}
                    options={[
                      {
                        value: '',
                        label: memberOptions.length
                          ? 'Choose a project employee'
                          : 'No additional employees',
                      },
                      ...memberOptions,
                    ]}
                    onChange={setAssigneeOption}
                    searchable
                    disabled={members.isPending}
                  />
                </div>
                <Button
                  type="button"
                  variant="outline"
                  disabled={!assigneeOption}
                  onClick={() => {
                    setAssigned((items) => [...items, Number(assigneeOption)])
                    setAssigneeOption('')
                  }}
                >
                  Add
                </Button>
              </div>
            )
          ) : (
            <p className="text-caption text-text-secondary">
              Select a project to choose its approved employee members. Unprojected tasks can remain
              unassigned.
            </p>
          )}
          {assigned.length ? (
            <ul className="flex flex-wrap gap-2">
              {assigned.map((id) => {
                const employee = members.data?.find((item) => item.id === id)
                return (
                  <li
                    key={id}
                    className="bg-surface border-border-subtle text-body-sm inline-flex max-w-full items-center gap-2 rounded-full border px-2.5 py-1"
                  >
                    {employee?.name ??
                      task?.assignees.find((item) => item.id === id)?.name ??
                      `Employee #${id}`}
                    <button
                      type="button"
                      aria-label={`Remove assignee ${id}`}
                      className="text-text-muted hover:text-danger"
                      onClick={() => setAssigned((items) => items.filter((item) => item !== id))}
                    >
                      <X className="size-3.5" />
                    </button>
                  </li>
                )
              })}
            </ul>
          ) : (
            <p className="text-caption text-text-muted">No employees assigned.</p>
          )}
        </section>
      </form>
    </Dialog>
  )
}

export function OperationsTaskDetailPage() {
  const params = useParams({ strict: false }) as { taskId?: string }
  const taskId = Number(params.taskId)
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const detail = useQuery({
    ...operationsRegisterQueries.task(
      session?.user.id ?? 0,
      session?.employee.employee_id ?? '',
      taskId,
    ),
    enabled: Boolean(
      session &&
      Number.isSafeInteger(taskId) &&
      taskId > 0 &&
      hasPermission(session.permissions, 'tasks', 'view'),
    ),
  })
  const canView = Boolean(session && hasPermission(session.permissions, 'tasks', 'view'))
  return (
    <PageLayout
      title={detail.data?.name ?? 'Task details'}
      subtitle="Assignment, delivery context, and progress."
      backLink={
        <Link
          to="/works/tasks"
          search={{
            search: '',
            status: 'active',
            priority: '',
            projectId: null,
            worksiteId: null,
            page: 1,
          }}
          className={pageBackLinkClassName}
        >
          <PageBackLinkContent>Tasks</PageBackLinkContent>
        </Link>
      }
    >
      {detail.isPending ? (
        <Skeleton variant="card" className="h-64" />
      ) : detail.isError ? (
        <ErrorState
          title="Task details unavailable"
          error={detail.error}
          action={
            <Button variant="outline" onClick={() => void detail.refetch()}>
              Try again
            </Button>
          }
        />
      ) : detail.data ? (
        <Card>
          <div className="flex flex-wrap items-start justify-between gap-3">
            <div>
              <p className="text-overline text-primary font-semibold">Task #{detail.data.id}</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold break-words">
                {detail.data.name}
              </h2>
              <p className="text-body-sm text-text-secondary mt-2">
                {detail.data.project?.name ?? 'Project-wide task'}
                {detail.data.worksite ? ` · ${detail.data.worksite.name}` : ''}
              </p>
            </div>
            <StatusChip
              label={detail.data.status.replaceAll('_', ' ')}
              tone={tone(detail.data.status)}
            />
          </div>
          {detail.data.description ? (
            <p className="text-body text-text-secondary border-border-subtle mt-5 border-t pt-4 whitespace-pre-wrap">
              {detail.data.description}
            </p>
          ) : null}
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <Fact label="Priority" value={detail.data.priority} />
            <Fact label="Due date" value={dateLabel(detail.data.due_date)} />
            <Fact
              label="Estimated effort"
              value={
                detail.data.estimated_hours
                  ? `${detail.data.estimated_hours} hours`
                  : 'Not estimated'
              }
            />
            <Fact label="Created by" value={detail.data.created_by?.name ?? 'Not recorded'} />
            <Fact
              label="Assignees"
              value={detail.data.assignees.map((item) => item.name).join(', ') || 'Unassigned'}
            />
          </div>
          {canView && detail.data.worksite ? (
            <Link
              className="text-body-sm text-primary mt-5 inline-flex items-center gap-2 font-semibold"
              to="/works/worksite/$worksiteId"
              params={{ worksiteId: String(detail.data.worksite.id) }}
            >
              View worksite <ArrowRight className="size-4" />
            </Link>
          ) : null}
        </Card>
      ) : null}
    </PageLayout>
  )
}

function Fact({ label, value, icon }: { label: string; value: string; icon?: React.ReactNode }) {
  return (
    <div className="bg-surface-muted rounded-control min-w-0 p-3">
      <p className="text-caption text-text-secondary flex items-center gap-1.5">
        {icon}
        {label}
      </p>
      <p className="text-body-sm text-text-primary mt-1 break-words">{value}</p>
    </div>
  )
}

function Pagination({
  count,
  page,
  onPage,
}: {
  count: number
  page: number
  onPage: (page: number) => void
}) {
  const total = Math.ceil(count / PAGE_SIZE)
  return (
    <Card className="flex flex-wrap items-center justify-between gap-3 py-3">
      <span className="text-body-sm text-text-secondary">
        {(page - 1) * PAGE_SIZE + 1}–{Math.min(page * PAGE_SIZE, count)} of {count}
      </span>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          Previous
        </Button>
        <span className="text-caption text-text-secondary">
          Page {page} of {total}
        </span>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= total}
          onClick={() => onPage(page + 1)}
        >
          Next
        </Button>
      </div>
    </Card>
  )
}
