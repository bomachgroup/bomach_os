import { useEffect, useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useSearch } from '@tanstack/react-router'
import {
  Archive,
  ArrowRight,
  BriefcaseBusiness,
  CalendarDays,
  ChevronLeft,
  ChevronRight,
  CircleAlert,
  Flag,
  MapPin,
  Plus,
  RotateCcw,
  Search,
  Trash2,
  Zap,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { useToast } from '@/shared/feedback/use-toast'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'
import { StatusChip } from '@/shared/ui/status-chip'
import {
  projectQueryKeys,
  projectsApi,
  type ProjectDto,
  type ProjectWriteInput,
} from '../projects.api'
import { projectQueries } from '../projects.queries'
import type { ProjectsSearch } from '../projects.search'
import { ProjectFormDialog } from './project-form-dialog'

const PAGE_SIZE = 10
const statusOptions = [
  { value: '', label: 'All statuses' },
  { value: 'planning', label: 'Planning' },
  { value: 'in_progress', label: 'In progress' },
  { value: 'on_hold', label: 'On hold' },
  { value: 'completed', label: 'Completed' },
  { value: 'cancelled', label: 'Cancelled' },
]
const priorityOptions = [
  { value: '', label: 'All priorities' },
  { value: 'critical', label: 'Critical' },
  { value: 'high', label: 'High' },
  { value: 'medium', label: 'Medium' },
  { value: 'low', label: 'Low' },
]

function money(value: string): string {
  const amount = Number(value)
  return Number.isFinite(amount)
    ? new Intl.NumberFormat('en-NG', {
        style: 'currency',
        currency: 'NGN',
        maximumFractionDigits: 0,
      }).format(amount)
    : 'Not available'
}

function projectDate(value: string | null): string {
  if (!value) return 'Not scheduled'
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat('en-NG', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function tone(status: string): 'neutral' | 'info' | 'success' | 'warning' | 'danger' {
  if (status === 'completed') return 'success'
  if (status === 'in_progress') return 'info'
  if (status === 'on_hold') return 'warning'
  if (status === 'cancelled') return 'danger'
  return 'neutral'
}

function priorityTone(priority: string): 'neutral' | 'warning' | 'danger' {
  if (priority === 'critical') return 'danger'
  if (priority === 'high') return 'warning'
  return 'neutral'
}

function ProjectSearchField({ value }: { value: string }) {
  const navigate = useNavigate()
  const [draft, setDraft] = useState(value)

  useEffect(() => {
    const normalized = draft.trim().slice(0, 120)
    if (normalized === value) return
    const timeout = window.setTimeout(() => {
      void navigate({
        to: '/works/projects',
        search: (previous: ProjectsSearch) => ({ ...previous, search: normalized, page: 1 }),
        replace: true,
        resetScroll: false,
      })
    }, 250)
    return () => window.clearTimeout(timeout)
  }, [draft, navigate, value])

  return (
    <label
      className="text-control-label text-text-secondary block space-y-1.5 font-bold"
      htmlFor="project-search"
    >
      Search projects
      <span className="relative block">
        <Search
          className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2"
          aria-hidden="true"
        />
        <TextInput
          id="project-search"
          type="search"
          maxLength={120}
          value={draft}
          onChange={(event) => setDraft(event.target.value)}
          placeholder="Name, code, category, client..."
          className="pl-9"
        />
      </span>
    </label>
  )
}

export function ProjectsPage() {
  const search = useSearch({ from: '/_protected/works/projects' }) as ProjectsSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = String(session?.employee.id ?? '')
  const [editing, setEditing] = useState<ProjectDto | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [archiveTarget, setArchiveTarget] = useState<ProjectDto | null>(null)
  const [deleteTarget, setDeleteTarget] = useState<ProjectDto | null>(null)
  const params = {
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
    search: search.search,
    status: search.status,
    priority: search.priority,
    archived: search.archived,
  }
  const projects = useQuery({
    ...projectQueries.list(userId, employeeId, params),
    enabled: Boolean(session),
  })
  const canCreate = Boolean(session && hasPermission(session.permissions, 'projects', 'create'))
  const canView = Boolean(session && hasPermission(session.permissions, 'projects', 'view'))
  const canUpdate = Boolean(session && hasPermission(session.permissions, 'projects', 'update'))
  const canArchive = Boolean(
    session &&
    hasPermission(session.permissions, 'projects', search.archived ? 'restore' : 'archive'),
  )
  const canDelete = Boolean(session && hasPermission(session.permissions, 'projects', 'delete'))

  function changeSearch(patch: Partial<ProjectsSearch>, replace = false) {
    void navigate({
      to: '/works/projects',
      search: (previous: ProjectsSearch) => ({ ...previous, ...patch }),
      replace,
      resetScroll: false,
    })
  }

  async function refreshProjectViews(projectId?: number) {
    const invalidations = [
      queryClient.invalidateQueries({ queryKey: projectQueryKeys.lists(userId, employeeId) }),
      queryClient.invalidateQueries({ queryKey: projectQueryKeys.overview(userId, employeeId) }),
    ]
    if (projectId) {
      invalidations.push(
        queryClient.invalidateQueries({
          queryKey: projectQueryKeys.detail(userId, employeeId, projectId),
        }),
      )
    }
    await Promise.all(invalidations)
  }

  const saveMutation = useMutation({
    mutationFn: ({ input, project }: { input: ProjectWriteInput; project: ProjectDto | null }) =>
      project ? projectsApi.update(project.id, input) : projectsApi.create(input),
    onSuccess: async (project, variables) => {
      await refreshProjectViews(variables.project?.id)
      setFormOpen(false)
      setEditing(null)
      showToast({
        title: variables.project ? 'Project updated' : 'Project created',
        description: `${project.name} has been saved.`,
        tone: 'success',
      })
    },
  })
  const archiveMutation = useMutation({
    mutationFn: (project: ProjectDto) =>
      search.archived ? projectsApi.restore(project.id) : projectsApi.archive(project.id),
    onSuccess: async (_result, project) => {
      await refreshProjectViews(project.id)
      setArchiveTarget(null)
      showToast({
        title: search.archived ? 'Project restored' : 'Project archived',
        tone: 'success',
      })
    },
    onError: () =>
      showToast({
        title: 'Project status could not be changed',
        description: 'Refresh and try again.',
        tone: 'danger',
      }),
  })
  const deleteMutation = useMutation({
    mutationFn: (project: ProjectDto) => projectsApi.remove(project.id),
    onSuccess: async (_result, project) => {
      await refreshProjectViews(project.id)
      setDeleteTarget(null)
      showToast({ title: 'Project permanently deleted', tone: 'success' })
    },
    onError: () =>
      showToast({
        title: 'Project could not be deleted',
        description: 'The project may have related records or your permission may have changed.',
        tone: 'danger',
      }),
  })

  const totalPages = Math.max(1, Math.ceil((projects.data?.count ?? 0) / PAGE_SIZE))
  const heading = search.archived ? 'Archived projects' : 'Projects'
  const filtersActive = Boolean(search.search || search.status || search.priority)

  useEffect(() => {
    if (!projects.data || projects.isPlaceholderData || search.page <= totalPages) return
    void navigate({
      to: '/works/projects',
      search: (previous: ProjectsSearch) => ({ ...previous, page: totalPages }),
      replace: true,
      resetScroll: false,
    })
  }, [navigate, projects.data, projects.isPlaceholderData, search.page, totalPages])

  return (
    <PageLayout
      title={heading}
      actionsInline
      actions={
        <>
          <Button
            size="sm"
            variant={search.archived ? 'primary' : 'outline'}
            aria-label={search.archived ? 'View active projects' : 'View archived projects'}
            title={search.archived ? 'View active projects' : 'View archived projects'}
            leadingIcon={
              search.archived ? (
                <BriefcaseBusiness className="size-4" aria-hidden="true" />
              ) : (
                <Archive className="size-4" aria-hidden="true" />
              )
            }
            className="max-[360px]:size-11 max-[360px]:px-0"
            onClick={() => changeSearch({ archived: !search.archived, page: 1 })}
          >
            <span className="hidden min-[480px]:inline">
              {search.archived ? 'Active projects' : 'Archived'}
            </span>
            <span className="hidden min-[361px]:max-[479px]:inline">
              {search.archived ? 'Active' : 'Archive'}
            </span>
          </Button>
          {canCreate && !search.archived ? (
            <Button
              size="sm"
              aria-label="Add project"
              title="Add project"
              leadingIcon={<Plus className="size-4" aria-hidden="true" />}
              className="max-[360px]:size-11 max-[360px]:px-0"
              onClick={() => {
                setEditing(null)
                setFormOpen(true)
              }}
            >
              <span className="hidden min-[480px]:inline">Add project</span>
              <span className="hidden min-[361px]:max-[479px]:inline">New</span>
            </Button>
          ) : null}
        </>
      }
    >
      <div className="space-y-5">
        <Card className="space-y-4">
          <div className="flex min-w-0 items-start justify-between gap-3">
            <div className="min-w-0">
              <p className="text-overline text-primary font-semibold">Project directory</p>
              <h2 className="text-h2 text-text-primary mt-1 font-semibold">Find a project</h2>
              <p className="text-body-sm text-text-secondary mt-1 max-w-2xl">
                Search by name or code, then narrow the register by status and priority.
              </p>
            </div>
            {projects.data ? (
              <StatusChip
                dense
                label={`${projects.data.count} ${search.archived ? 'archived' : 'active'}`}
                tone="neutral"
                className="shrink-0"
              />
            ) : null}
          </div>
          <ProjectSearchField key={search.search} value={search.search} />
          <div className="grid min-w-0 grid-cols-1 gap-3 min-[361px]:grid-cols-2">
            <DropdownSelect
              label="Status"
              value={search.status}
              options={statusOptions}
              onChange={(value) => changeSearch({ status: value, page: 1 }, true)}
            />
            <DropdownSelect
              label="Priority"
              value={search.priority}
              options={priorityOptions}
              onChange={(value) => changeSearch({ priority: value, page: 1 }, true)}
            />
          </div>
        </Card>

        <section aria-labelledby="project-register-heading" className="space-y-3">
          <div className="flex flex-wrap items-end justify-between gap-2">
            <div>
              <p className="text-overline text-primary font-semibold">Operations</p>
              <h2
                id="project-register-heading"
                className="text-h2 text-text-primary mt-1 font-semibold"
              >
                Project register
              </h2>
            </div>
            {projects.data ? (
              <p className="text-caption text-text-secondary">
                {projects.data.count} {search.archived ? 'archived' : 'active'} project
                {projects.data.count === 1 ? '' : 's'}
              </p>
            ) : null}
          </div>

          {projects.isPending ? (
            <div className="grid gap-3" aria-label="Loading projects" aria-busy="true">
              {Array.from({ length: 4 }, (_, index) => (
                <Skeleton key={index} className="h-36" />
              ))}
            </div>
          ) : projects.isError ? (
            <ErrorState
              title="Projects could not load"
              description="Check your connection and retry the register."
              error={projects.error}
              action={
                <Button variant="outline" onClick={() => void projects.refetch()}>
                  Try again
                </Button>
              }
            />
          ) : projects.data?.items.length ? (
            <>
              <div className="grid min-w-0 gap-3">
                {projects.data.items.map((project) => (
                  <article key={project.id} aria-label={`${project.name} project`}>
                    <Card className="min-w-0 overflow-hidden p-0">
                      <div className="phone:p-5 desktop:grid-cols-[minmax(0,1fr)_16rem] grid min-w-0 gap-4 p-4">
                        <div className="min-w-0">
                          <div className="flex min-w-0 flex-wrap items-start gap-2">
                            {canView ? (
                              <Link
                                to="/works/projects/$projectId"
                                params={{ projectId: String(project.id) }}
                                className="focus-visible:shadow-focus-ring text-label text-text-primary rounded-control hover:text-primary min-w-0 flex-1 font-semibold break-words outline-none min-[480px]:truncate"
                              >
                                {project.name}
                              </Link>
                            ) : (
                              <h3 className="text-label text-text-primary min-w-0 flex-1 font-semibold break-words min-[480px]:truncate">
                                {project.name}
                              </h3>
                            )}
                            <StatusChip
                              dense
                              label={project.status.replaceAll('_', ' ')}
                              tone={tone(project.status)}
                            />
                            {project.is_archived ? (
                              <StatusChip dense label="Archived" tone="neutral" />
                            ) : null}
                          </div>
                          <div className="text-caption text-text-secondary mt-2 flex min-w-0 flex-wrap items-center gap-2">
                            <span className="bg-surface-muted rounded-pill max-w-full px-2 py-1 font-semibold break-words">
                              {project.short_code}
                            </span>
                            <span className="max-w-full break-words">{project.category}</span>
                            <span className="inline-flex max-w-full min-w-0 items-center gap-1">
                              <MapPin className="size-3.5 shrink-0" aria-hidden="true" />
                              <span className="break-words">
                                {project.location || project.branch_name || 'Location not set'}
                              </span>
                            </span>
                          </div>
                          {project.summary ? (
                            <p className="text-body-sm text-text-secondary mt-3 line-clamp-2 break-words">
                              {project.summary}
                            </p>
                          ) : null}
                          <div className="mt-4 max-w-xl">
                            <div className="text-caption text-text-secondary mb-1.5 flex items-center justify-between gap-3">
                              <span>Delivery progress</span>
                              <span className="text-text-primary font-semibold">
                                {project.progress}%
                              </span>
                            </div>
                            <ProgressBar
                              value={project.progress}
                              label={`${project.name} delivery progress`}
                            />
                          </div>
                        </div>

                        <section
                          aria-label={`${project.name} budget and priority`}
                          className="bg-primary-subtle/40 border-primary/10 rounded-control phone:px-4 phone:py-3 desktop:border-border-subtle desktop:bg-surface-muted/45 desktop:flex-col desktop:items-start desktop:justify-center desktop:gap-4 desktop:p-4 flex min-w-0 items-center justify-between gap-3 border px-3 py-2.5"
                        >
                          <div className="desktop:items-start flex min-w-0 items-center gap-3">
                            <span className="bg-surface text-primary rounded-control desktop:size-10 flex size-9 shrink-0 items-center justify-center">
                              <BriefcaseBusiness
                                className="desktop:size-5 size-4"
                                aria-hidden="true"
                              />
                            </span>
                            <div className="min-w-0">
                              <p className="text-overline text-text-muted whitespace-nowrap">
                                Allocated budget
                              </p>
                              <p className="text-body-sm text-text-primary phone:text-label max-[360px]:text-caption mt-0.5 font-semibold break-words tabular-nums">
                                {money(project.budget)}
                              </p>
                            </div>
                          </div>
                          <StatusChip
                            dense
                            label={`${project.priority.replaceAll('_', ' ')} priority`}
                            tone={priorityTone(project.priority)}
                            className="hidden shrink-0 min-[361px]:inline-flex"
                          />
                          <StatusChip
                            dense
                            aria-label={`${project.priority.replaceAll('_', ' ')} priority`}
                            label={project.priority.replaceAll('_', ' ')}
                            tone={priorityTone(project.priority)}
                            icon={<Zap className="size-3" />}
                            className="inline-flex shrink-0 min-[361px]:hidden"
                          />
                        </section>
                      </div>

                      <footer className="bg-surface-muted/30 border-border-subtle desktop:flex-row desktop:items-center desktop:justify-between desktop:px-4 flex min-w-0 flex-col gap-3 border-t p-3">
                        <div
                          role="group"
                          aria-label={`${project.name} schedule`}
                          className="desktop:flex desktop:flex-wrap desktop:items-center grid min-w-0 grid-cols-2 gap-2"
                        >
                          <div className="bg-surface border-border-subtle rounded-control shadow-elevation-sm phone:gap-2.5 phone:px-3 flex min-w-0 items-center gap-2 border px-2.5 py-2">
                            <span className="bg-primary-subtle text-primary rounded-control flex size-8 shrink-0 items-center justify-center">
                              <CalendarDays className="size-4" aria-hidden="true" />
                            </span>
                            <span className="min-w-0">
                              <span className="text-overline text-text-muted block tracking-wide uppercase">
                                Start
                              </span>
                              <span className="text-caption text-text-primary block font-semibold break-words">
                                {projectDate(project.start_date)}
                              </span>
                            </span>
                          </div>
                          <div className="bg-surface border-border-subtle rounded-control shadow-elevation-sm phone:gap-2.5 phone:px-3 flex min-w-0 items-center gap-2 border px-2.5 py-2">
                            <span className="bg-primary-subtle text-primary rounded-control flex size-8 shrink-0 items-center justify-center">
                              <Flag className="size-4" aria-hidden="true" />
                            </span>
                            <span className="min-w-0">
                              <span className="text-overline text-text-muted block tracking-wide uppercase">
                                Target date
                              </span>
                              <span className="text-caption text-text-primary block font-semibold break-words">
                                {projectDate(project.deadline)}
                              </span>
                            </span>
                          </div>
                        </div>
                        <div className="flex flex-wrap items-center justify-end gap-1.5">
                          {canView ? (
                            <ProjectActionButton
                              label={`Open ${project.name}`}
                              text="Open"
                              icon={<ArrowRight className="size-4" aria-hidden="true" />}
                              onClick={() =>
                                void navigate({
                                  to: '/works/projects/$projectId',
                                  params: { projectId: String(project.id) },
                                })
                              }
                            />
                          ) : null}
                          {canUpdate && !project.is_archived ? (
                            <ProjectActionButton
                              label={`Edit ${project.name}`}
                              text="Edit"
                              icon={<BriefcaseBusiness className="size-4" aria-hidden="true" />}
                              onClick={() => {
                                setEditing(project)
                                setFormOpen(true)
                              }}
                            />
                          ) : null}
                          {canArchive ? (
                            <ProjectActionButton
                              label={`${project.is_archived ? 'Restore' : 'Archive'} ${project.name}`}
                              text={project.is_archived ? 'Restore' : 'Archive'}
                              icon={
                                project.is_archived ? (
                                  <RotateCcw className="size-4" aria-hidden="true" />
                                ) : (
                                  <Archive className="size-4" aria-hidden="true" />
                                )
                              }
                              onClick={() => setArchiveTarget(project)}
                            />
                          ) : null}
                          {canDelete ? (
                            <ProjectActionButton
                              label={`Delete ${project.name}`}
                              text="Delete"
                              icon={<Trash2 className="size-4" aria-hidden="true" />}
                              variant="danger"
                              onClick={() => setDeleteTarget(project)}
                            />
                          ) : null}
                        </div>
                      </footer>
                    </Card>
                  </article>
                ))}
              </div>
              <div className="bg-surface-muted/35 border-border-subtle rounded-control phone:flex-row phone:items-center phone:justify-between phone:px-4 flex flex-col gap-3 border p-3">
                <p className="text-caption text-text-secondary">
                  Showing {(search.page - 1) * PAGE_SIZE + 1}–
                  {Math.min(search.page * PAGE_SIZE, projects.data.count)} of {projects.data.count}
                  <span className="sr-only"> projects</span>
                </p>
                <div className="flex justify-end gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    aria-label="Previous projects page"
                    disabled={search.page <= 1}
                    onClick={() => changeSearch({ page: search.page - 1 })}
                  >
                    <ChevronLeft className="size-4" aria-hidden="true" />
                    <span className="hidden min-[361px]:inline">Previous</span>
                  </Button>
                  <span className="text-caption text-text-secondary inline-flex min-h-9 items-center px-1">
                    {search.page} / {totalPages}
                  </span>
                  <Button
                    variant="outline"
                    size="sm"
                    aria-label="Next projects page"
                    disabled={search.page >= totalPages}
                    onClick={() => changeSearch({ page: search.page + 1 })}
                  >
                    <span className="hidden min-[361px]:inline">Next</span>
                    <ChevronRight className="size-4" aria-hidden="true" />
                  </Button>
                </div>
              </div>
            </>
          ) : (
            <EmptyState
              title={search.archived ? 'No archived projects' : 'No projects match'}
              description={
                filtersActive
                  ? 'Try removing a filter or searching with a different term.'
                  : 'Create a project to begin tracking its budget, team, and delivery work.'
              }
              action={
                filtersActive ? (
                  <Button
                    variant="outline"
                    onClick={() => {
                      changeSearch({ search: '', status: '', priority: '', page: 1 }, true)
                    }}
                  >
                    Clear filters
                  </Button>
                ) : canCreate && !search.archived ? (
                  <Button
                    leadingIcon={<Plus className="size-4" />}
                    onClick={() => setFormOpen(true)}
                  >
                    Add project
                  </Button>
                ) : undefined
              }
            />
          )}
        </section>
      </div>

      {formOpen ? (
        <ProjectFormDialog
          open
          project={editing}
          onOpenChange={(open) => {
            setFormOpen(open)
            if (!open) setEditing(null)
          }}
          onSave={(input) =>
            saveMutation.mutateAsync({ input, project: editing }).then(() => undefined)
          }
          saving={saveMutation.isPending}
        />
      ) : null}
      <Dialog
        open={Boolean(archiveTarget)}
        onOpenChange={(open) => {
          if (!open) setArchiveTarget(null)
        }}
        title={search.archived ? 'Restore project?' : 'Archive project?'}
        description={
          search.archived
            ? 'The project will return to the active register and Operations metrics.'
            : 'Archiving hides the project from the active register and Operations metrics. Its records and status are preserved.'
        }
        compactOnMobile
        fitContent
        bodyClassName="bg-background"
        footer={
          <>
            <Button variant="outline" onClick={() => setArchiveTarget(null)}>
              Cancel
            </Button>
            <Button
              onClick={() => archiveTarget && archiveMutation.mutate(archiveTarget)}
              isLoading={archiveMutation.isPending}
            >
              {search.archived ? 'Restore project' : 'Archive project'}
            </Button>
          </>
        }
      >
        {archiveTarget ? (
          <Card>
            <p className="font-semibold">{archiveTarget.name}</p>
            <p className="text-caption text-text-secondary mt-1">{archiveTarget.short_code}</p>
          </Card>
        ) : null}
      </Dialog>
      <Dialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => {
          if (!open) setDeleteTarget(null)
        }}
        title="Permanently delete project?"
        description="This cannot be undone. Use archive instead if you may need this project or its history later."
        compactOnMobile
        fitContent
        bodyClassName="bg-background"
        footer={
          <>
            <Button variant="outline" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button
              variant="danger"
              onClick={() => deleteTarget && deleteMutation.mutate(deleteTarget)}
              isLoading={deleteMutation.isPending}
            >
              <Trash2 className="size-4" aria-hidden="true" /> Delete permanently
            </Button>
          </>
        }
      >
        <div className="space-y-3">
          <SectionErrorState
            title="Irreversible action"
            description="Project details and linked records may be permanently removed. Confirm only if this is intentional."
          />
          {deleteTarget ? (
            <Card>
              <p className="font-semibold">{deleteTarget.name}</p>
              <p className="text-caption text-text-secondary mt-1">{deleteTarget.short_code}</p>
            </Card>
          ) : null}
          <p className="text-caption text-danger flex items-start gap-2">
            <CircleAlert className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
            Deletion is permission-gated and may be rejected when related records still exist.
          </p>
        </div>
      </Dialog>
    </PageLayout>
  )
}

function ProjectActionButton({
  label,
  text,
  icon,
  variant = 'outline',
  onClick,
}: {
  label: string
  text: string
  icon: ReactNode
  variant?: 'outline' | 'ghost' | 'danger'
  onClick: () => void
}) {
  return (
    <Button
      variant={variant}
      size="sm"
      aria-label={label}
      title={label}
      leadingIcon={icon}
      className="phone:size-auto phone:min-h-9 phone:px-3 max-[479px]:size-11 max-[479px]:px-0"
      onClick={onClick}
    >
      <span className="hidden min-[480px]:inline">{text}</span>
    </Button>
  )
}
