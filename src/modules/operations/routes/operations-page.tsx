import { useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate } from '@tanstack/react-router'
import {
  ArrowRight,
  BriefcaseBusiness,
  Building2,
  CalendarClock,
  ClipboardList,
  CircleDollarSign,
  FileCheck2,
  Plus,
} from 'lucide-react'

import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { ProgressBar } from '@/shared/ui/progress-bar'
import { StatusChip } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'
import {
  projectsApi,
  projectQueryKeys,
  type ProjectDto,
  type ProjectWriteInput,
} from '../projects.api'
import { projectQueries } from '../projects.queries'
import { ProjectFormDialog } from './project-form-dialog'

function money(value: string | number | null | undefined): string {
  if (value === null || value === undefined || value === '') return 'Not available'
  const amount = Number(value)
  if (!Number.isFinite(amount)) return 'Not available'
  return new Intl.NumberFormat('en-NG', {
    style: 'currency',
    currency: 'NGN',
    maximumFractionDigits: 0,
  }).format(amount)
}

function statusTone(status: string): 'neutral' | 'info' | 'success' | 'warning' | 'danger' {
  if (status === 'completed') return 'success'
  if (status === 'in_progress') return 'info'
  if (status === 'on_hold') return 'warning'
  if (status === 'cancelled') return 'danger'
  return 'neutral'
}

export function OperationsPage() {
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const queryClient = useQueryClient()
  const navigate = useNavigate()
  const { showToast } = useToast()
  const [createOpen, setCreateOpen] = useState(false)
  const canCreate = Boolean(session && hasPermission(session.permissions, 'projects', 'create'))
  const canListProjects = Boolean(session && hasPermission(session.permissions, 'projects', 'list'))
  const canViewProject = Boolean(session && hasPermission(session.permissions, 'projects', 'view'))
  const overview = useQuery({
    ...projectQueries.overview(session?.user.id ?? 0, session?.employee.employee_id ?? ''),
    enabled: Boolean(session),
  })
  const createProject = useMutation({
    mutationFn: (input: ProjectWriteInput) => projectsApi.create(input),
    onSuccess: async (project: ProjectDto) => {
      await queryClient.invalidateQueries({ queryKey: projectQueryKeys.all })
      setCreateOpen(false)
      showToast({
        title: 'Project created',
        description: `${project.name} is now in the project register.`,
        tone: 'success',
      })
      if (canViewProject) {
        void navigate({
          to: '/works/projects/$projectId',
          params: { projectId: String(project.id) },
        })
      }
    },
  })

  const data = overview.data
  const recentProjects = Array.isArray(data?.recent_projects) ? data.recent_projects : null
  const utilizationValue =
    data?.budget_utilization_percent == null ? null : Number(data.budget_utilization_percent)
  const utilization =
    utilizationValue !== null && Number.isFinite(utilizationValue) ? utilizationValue : null

  return (
    <PageLayout
      title="Operations"
      subtitle="A live view of project delivery, budgets, and field activity."
      actionsInline
      actions={
        canCreate ? (
          <Button
            size="sm"
            leadingIcon={<Plus className="size-4" />}
            onClick={() => setCreateOpen(true)}
            aria-label="Add project"
          >
            <span className="phone:inline hidden">Add project</span>
            <span className="phone:hidden">Add</span>
          </Button>
        ) : null
      }
    >
      {overview.isPending ? (
        <div role="status" aria-label="Loading operations overview" className="min-w-0 space-y-5">
          <div className="space-y-3">
            <Skeleton className="h-6 w-48" />
            <div className="tablet:grid-cols-3 grid grid-cols-2 gap-2">
              {Array.from({ length: 3 }, (_, index) => (
                <Skeleton className="h-32" key={index} />
              ))}
            </div>
          </div>
          <div className="space-y-3">
            <Skeleton className="h-6 w-44" />
            <div className="desktop:grid-cols-4 grid grid-cols-2 gap-2">
              {Array.from({ length: 4 }, (_, index) => (
                <Skeleton className="h-20" key={index} />
              ))}
            </div>
          </div>
          <Skeleton className="h-64" />
        </div>
      ) : overview.isError ? (
        <ErrorState
          title="Operations overview is unavailable"
          description="We could not load current project and delivery metrics."
          error={overview.error}
          action={
            <Button variant="outline" onClick={() => void overview.refetch()}>
              Try again
            </Button>
          }
        />
      ) : data ? (
        <>
          <section aria-labelledby="portfolio-snapshot-heading" className="min-w-0">
            <SectionHeading
              id="portfolio-snapshot-heading"
              title="Portfolio snapshot"
              detail="Project scope and budget health"
            />
            <div className="shadow-elevation-sm tablet:grid-cols-3 rounded-surface border-border-subtle bg-border-subtle mt-3 grid min-w-0 grid-cols-2 gap-px overflow-hidden border">
              <PortfolioMetric
                label="Projects in scope"
                value={String(data.total_projects ?? '—')}
                detail="Projects included in this overview"
                icon={<BriefcaseBusiness className="size-5" />}
                tone="primary"
              />
              <PortfolioMetric
                label="Allocated project budget"
                value={money(data.allocated_project_budget)}
                detail="Summed budgets in this overview"
                icon={<CircleDollarSign className="size-5" />}
                tone="success"
              />
              <PortfolioMetric
                className="tablet:col-span-1 col-span-2"
                label="Budget utilization"
                value={
                  utilization === null
                    ? 'Not available'
                    : `${new Intl.NumberFormat(undefined, { maximumFractionDigits: 2 }).format(utilization)}%`
                }
                detail={`Approved + paid: ${money(data.approved_and_paid_expenses)}`}
                icon={<CircleDollarSign className="size-5" />}
                tone={utilization !== null && utilization > 100 ? 'warning' : 'primary'}
                progress={utilization}
                progressLabel="Budget utilization"
                warning={utilization !== null && utilization > 100 ? 'Above budget' : undefined}
              />
            </div>
          </section>

          <section aria-labelledby="operational-coverage-heading" className="mt-5 min-w-0">
            <SectionHeading
              id="operational-coverage-heading"
              title="Operational coverage"
              detail="Supporting delivery activity"
            />
            <div className="desktop:grid-cols-4 phone:gap-3 tablet:gap-4 mt-3 grid min-w-0 grid-cols-2 gap-2">
              <SupportingMetric
                label="Project tasks"
                value={String(data.total_tasks ?? '—')}
                detail="Across projects in scope"
                icon={<ClipboardList className="size-5" />}
                tone="info"
              />
              <SupportingMetric
                label="Worksites"
                value={String(data.total_worksites ?? '—')}
                detail="Project-linked sites"
                icon={<Building2 className="size-5" />}
                tone="primary"
              />
              <SupportingMetric
                label="Contracts"
                value={String(data.total_contracts ?? '—')}
                detail="Visible in your scope"
                icon={<FileCheck2 className="size-5" />}
                tone="success"
              />
              <SupportingMetric
                label="Timelines"
                value={String(data.total_timelines ?? '—')}
                detail="Project delivery plans"
                icon={<CalendarClock className="size-5" />}
                tone="neutral"
              />
            </div>
          </section>

          {canListProjects ? (
            <section aria-labelledby="recent-projects-heading" className="mt-5 min-w-0">
              <Card className="min-w-0 p-0" elevation="sm">
                <div className="border-border-subtle phone:p-5 flex min-w-0 items-start justify-between gap-3 border-b p-4">
                  <div className="min-w-0">
                    <h2 id="recent-projects-heading" className="text-h3 font-semibold">
                      Recently updated projects
                    </h2>
                    <p className="text-caption text-text-secondary mt-1">
                      Latest activity across projects you can access.
                    </p>
                  </div>
                  <Button
                    variant="outline"
                    size="sm"
                    className="phone:min-w-0 phone:px-3 min-w-9 shrink-0 px-2"
                    aria-label="All projects"
                    title="All projects"
                    onClick={() => void navigate({ to: '/works/projects' })}
                  >
                    <span className="phone:inline hidden">All projects</span>
                    <ArrowRight className="size-4" />
                  </Button>
                </div>
                {recentProjects === null ? (
                  <EmptyState
                    title="Project highlights are unavailable"
                    description={
                      data.scope_limited
                        ? 'The overview cannot summarize projects in your current scope. Use All projects to review records available to you.'
                        : 'The overview response did not include recent project details. Use All projects to review records available to you.'
                    }
                  />
                ) : recentProjects.length ? (
                  <div className="divide-border-subtle divide-y">
                    {recentProjects.map((project) => (
                      <ProjectSummary
                        key={project.id}
                        project={project}
                        canView={canViewProject}
                        money={money}
                        statusTone={statusTone}
                      />
                    ))}
                  </div>
                ) : (
                  <EmptyState
                    title="No active projects yet"
                    description="Active projects will appear here when they are available."
                    action={
                      canCreate ? (
                        <Button onClick={() => setCreateOpen(true)}>Add project</Button>
                      ) : undefined
                    }
                  />
                )}
              </Card>
            </section>
          ) : null}
        </>
      ) : null}
      {createOpen ? (
        <ProjectFormDialog
          open
          project={null}
          onOpenChange={setCreateOpen}
          onSave={(input) => createProject.mutateAsync(input).then(() => undefined)}
          saving={createProject.isPending}
        />
      ) : null}
    </PageLayout>
  )
}

function SectionHeading({ id, title, detail }: { id: string; title: string; detail: string }) {
  return (
    <div className="flex min-w-0 items-baseline justify-between gap-3">
      <h2 id={id} className="text-h3 text-text-primary font-semibold">
        {title}
      </h2>
      <p className="text-caption text-text-secondary phone:block hidden shrink-0">{detail}</p>
    </div>
  )
}

function PortfolioMetric({
  label,
  value,
  detail,
  icon,
  tone,
  progress,
  progressLabel,
  warning,
  className = '',
}: {
  label: string
  value: string
  detail: string
  icon: ReactNode
  tone: 'primary' | 'success' | 'warning'
  progress?: number | null
  progressLabel?: string
  warning?: string
  className?: string
}) {
  const iconTone = {
    primary: 'bg-primary-subtle text-primary',
    success: 'bg-success-subtle text-success-foreground',
    warning: 'bg-warning-subtle text-warning-foreground',
  }[tone]

  return (
    <article className={`bg-surface phone:p-5 flex min-w-0 flex-col p-4 ${className}`}>
      <div className="flex min-w-0 items-center justify-between gap-2">
        <h3 className="text-caption text-text-secondary min-w-0 font-medium">{label}</h3>
        <span
          className={`rounded-control flex size-9 shrink-0 items-center justify-center ${iconTone}`}
        >
          {icon}
        </span>
      </div>
      <p
        className="text-text-primary mt-3 text-[clamp(1rem,4vw,1.75rem)] leading-tight font-semibold break-words tabular-nums"
        title={value}
      >
        {value}
      </p>
      {progressLabel ? (
        <ProgressBar
          className="mt-2"
          value={progress == null ? null : Math.max(0, progress)}
          label={progressLabel}
          valueText={progress == null ? 'Not available' : `${progress}%`}
        />
      ) : null}
      <p className="text-caption text-text-secondary mt-2 line-clamp-2">{detail}</p>
      {warning ? <p className="text-caption text-warning-foreground mt-1">{warning}</p> : null}
    </article>
  )
}

function SupportingMetric({
  label,
  value,
  detail,
  icon,
  tone,
}: {
  label: string
  value: string
  detail: string
  icon: ReactNode
  tone: 'primary' | 'info' | 'success' | 'neutral'
}) {
  const iconTone = {
    primary: 'bg-primary-subtle text-primary',
    info: 'bg-info-subtle text-info-foreground',
    success: 'bg-success-subtle text-success-foreground',
    neutral: 'bg-surface-muted text-text-secondary',
  }[tone]

  return (
    <article className="rounded-control shadow-elevation-sm border-border-subtle bg-surface phone:p-4 min-w-0 border p-3">
      <div className="min-w-0 flex-1">
        <div className="flex min-w-0 items-center justify-between gap-2">
          <p className="text-overline text-text-secondary line-clamp-2 min-h-7 min-w-0">{label}</p>
          <span
            className={`rounded-control flex size-8 shrink-0 items-center justify-center ${iconTone}`}
            aria-hidden="true"
          >
            {icon}
          </span>
        </div>
        <p className="text-text-primary mt-2 text-xl leading-tight font-semibold tabular-nums">
          {value}
        </p>
        <p className="text-overline text-text-muted phone:block mt-1 hidden truncate">{detail}</p>
      </div>
    </article>
  )
}

function ProjectSummary({
  project,
  canView,
  money,
  statusTone,
}: {
  project: Pick<ProjectDto, 'id' | 'name' | 'short_code' | 'updated_at' | 'status' | 'budget'>
  canView: boolean
  money: (value: string | number | null | undefined) => string
  statusTone: (status: string) => 'neutral' | 'info' | 'success' | 'warning' | 'danger'
}) {
  return (
    <div className="hover:bg-surface-muted/70 phone:px-5 grid min-w-0 grid-cols-[minmax(0,1fr)_auto] items-center gap-x-3 gap-y-1 px-4 py-4">
      {canView ? (
        <Link
          to="/works/projects/$projectId"
          params={{ projectId: String(project.id) }}
          className="focus-visible:shadow-focus-ring text-label text-text-primary rounded-control min-w-0 truncate font-semibold outline-none"
          title={project.name}
        >
          {project.name}
        </Link>
      ) : (
        <span
          className="text-label text-text-primary min-w-0 truncate font-semibold"
          title={project.name}
        >
          {project.name}
        </span>
      )}
      <StatusChip
        className="max-w-28 justify-self-end"
        label={project.status.replaceAll('_', ' ')}
        tone={statusTone(project.status)}
        dense
      />
      <span
        className="text-caption text-text-secondary min-w-0 truncate"
        title={`${project.short_code} · Updated ${new Date(project.updated_at).toLocaleDateString()}`}
      >
        {project.short_code} · Updated {new Date(project.updated_at).toLocaleDateString()}
      </span>
      <span
        className="text-caption text-text-primary max-w-32 justify-self-end truncate text-right font-semibold tabular-nums"
        title={money(project.budget)}
      >
        {money(project.budget)}
      </span>
    </div>
  )
}
