import { useState, type ReactNode } from 'react'
import { useQuery } from '@tanstack/react-query'
import {
  ArrowUpRight,
  BookOpenCheck,
  BriefcaseBusiness,
  CalendarClock,
  ChevronDown,
  CircleCheck,
  CircleHelp,
  FileText,
  GraduationCap,
  ListChecks,
  Network,
  PackageOpen,
  ShieldCheck,
  Sparkles,
  Target,
} from 'lucide-react'

import { ApiError } from '@/shared/api/api-error'
import {
  authSessionQueryOptions,
  hasPermission,
  SessionBootstrapError,
} from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { DATA_FRESHNESS_MS } from '@/shared/query/freshness'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import {
  EmptyState,
  ErrorState,
  PageSkeleton,
  SectionErrorState,
  Skeleton,
} from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip } from '@/shared/ui/status-chip'
import {
  myRoleApi,
  type AssignedRoleDto,
  type RoleCareerPathNodeDto,
  type RoleDailyRoutineDto,
  type RoleKpiDto,
  type RolePageDto,
  type RoleReportingChainDto,
  type RoleReportingLineDto,
  type RoleReportingTreeNodeDto,
  type RoleResourceDto,
  type RoleSopDto,
  type RoleTaskTemplateDto,
  type RoleTrainingRequirementDto,
} from '@/modules/dashboard/role.api'
import { assignedRoleQueryOptions, myRoleQueryKeys } from '@/modules/dashboard/role.queries'
import { PermissionActionGroups } from '@/shared/permissions/permission-action-groups'

const roleSectionPermissions = {
  description: ['role_descriptions'],
  kpis: ['role_kpis'],
  sops: ['role_sops'],
  authority: ['roles'],
  reporting: ['role_reporting_lines'],
  career: ['role_career_paths'],
  training: ['role_training_requirements'],
  playbook: ['role_success_playbook'],
  resources: ['role_resources'],
  taskTemplates: ['role_task_templates'],
  dailyRoutine: ['role_daily_routines'],
} as const

function canViewSection(permissions: Record<string, string[]>, resources: readonly string[]) {
  return resources.some((resource) =>
    ['view_own', 'view', 'list_own', 'list'].some((action) =>
      hasPermission(permissions, resource, action),
    ),
  )
}

function humanize(value: string) {
  return value.replaceAll('_', ' ').replace(/\b\w/g, (letter) => letter.toUpperCase())
}

function formatRoleDate(value: string) {
  const parsed = new Date(`${value}T00:00:00`)
  if (Number.isNaN(parsed.getTime())) return value
  return new Intl.DateTimeFormat('en-NG', {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(parsed)
}

function formatTrainingDates(start: string, end: string) {
  const formattedStart = formatRoleDate(start)
  const formattedEnd = formatRoleDate(end)
  return formattedStart && formattedEnd
    ? `${formattedStart} – ${formattedEnd}`
    : formattedStart || formattedEnd
}

function formatRoutineTime(value: string | null) {
  const match = value?.match(/^(\d{1,2}):(\d{2})/)
  if (!match) return value ?? ''
  const date = new Date(Date.UTC(2020, 0, 1, Number(match[1]), Number(match[2])))
  return new Intl.DateTimeFormat('en-NG', {
    hour: 'numeric',
    minute: '2-digit',
    timeZone: 'UTC',
  }).format(date)
}

function formatKpiTarget(value: string | number, unit: string) {
  const numericValue = Number(value)
  const formatted = Number.isFinite(numericValue)
    ? new Intl.NumberFormat('en-NG', { maximumFractionDigits: 1 }).format(numericValue)
    : String(value)
  if (unit === 'percentage') return `${formatted}%`
  if (unit === 'count') {
    if (numericValue === 0) return '0 outstanding'
    return `${formatted} ${numericValue === 1 ? 'item' : 'items'}`
  }
  return `${formatted}${unit ? ` ${humanize(unit)}` : ''}`
}

function trainingStatusTone(status: string) {
  if (status === 'completed') return 'success' as const
  if (status === 'in_progress') return 'info' as const
  if (status === 'overdue' || status === 'cancelled') return 'warning' as const
  return 'neutral' as const
}

function priorityTone(priority: string) {
  if (priority === 'high') return 'danger' as const
  if (priority === 'medium') return 'warning' as const
  return 'neutral' as const
}

function RoleEmptyState({ title, description }: { title: string; description: string }) {
  return (
    <div role="status" className="bg-surface-muted rounded-control px-4 py-4">
      <p className="text-body-sm text-text-primary font-semibold">{title}</p>
      <p className="text-caption text-text-secondary mt-1">{description}</p>
    </div>
  )
}

function RoleAccordion({
  id,
  title,
  description,
  icon,
  children,
  defaultOpen = false,
  className = '',
}: {
  id: string
  title: string
  description: string
  icon: ReactNode
  children: ReactNode
  defaultOpen?: boolean
  className?: string
}) {
  const [open, setOpen] = useState(defaultOpen)
  const panelId = `${id}-panel`
  return (
    <Card className={`rounded-surface min-w-0 overflow-hidden p-0 ${className}`}>
      <h2>
        <button
          type="button"
          id={`${id}-trigger`}
          aria-expanded={open}
          aria-controls={panelId}
          onClick={() => setOpen((current) => !current)}
          className="hover:bg-primary-subtle/25 focus-visible:shadow-focus-ring phone:min-h-[72px] phone:gap-3 phone:px-4 flex min-h-14 w-full min-w-0 items-center gap-2.5 px-3 py-2.5 text-left transition-colors focus-visible:outline-none"
        >
          <span className="bg-primary-subtle text-primary phone:size-10 flex size-9 shrink-0 items-center justify-center rounded-[14px]">
            {icon}
          </span>
          <span className="min-w-0 flex-1">
            <span className="text-body-md text-text-primary block leading-snug font-semibold">
              {title}
            </span>
            <span className="text-caption text-text-secondary tablet:block mt-1 hidden leading-snug">
              {description}
            </span>
          </span>
          <ChevronDown
            aria-hidden="true"
            className={`text-text-secondary size-5 shrink-0 transition-transform motion-reduce:transition-none ${open ? 'rotate-180' : ''}`}
          />
        </button>
      </h2>
      <div
        id={panelId}
        aria-labelledby={`${id}-trigger`}
        hidden={!open}
        className="border-border-subtle bg-surface phone:px-4 phone:py-5 tablet:px-5 border-t px-3 py-4"
      >
        {open ? children : null}
      </div>
    </Card>
  )
}

function RoleDataPanel<T>({
  userId,
  section,
  load,
  render,
  emptyTitle = 'No information added yet',
  emptyDescription = 'There is no information available in this section.',
}: {
  userId: number
  section: string
  load: (signal: AbortSignal) => Promise<T>
  render: (data: T) => ReactNode
  emptyTitle?: string
  emptyDescription?: string
}) {
  const query = useQuery({
    queryKey: myRoleQueryKeys.section(userId, section),
    queryFn: ({ signal }) => load(signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  if (query.isPending) {
    return (
      <div aria-label={`Loading ${section}`} className="space-y-3">
        <Skeleton variant="row" />
        <Skeleton variant="row" />
      </div>
    )
  }
  if (!query.data) {
    if (query.error instanceof ApiError && query.error.status === 404) {
      return <RoleEmptyState title={emptyTitle} description={emptyDescription} />
    }
    return (
      <SectionErrorState
        title="This section could not load"
        error={query.error}
        onRetry={() => void query.refetch()}
      />
    )
  }

  return (
    <div className="space-y-3">
      {query.isError ? (
        <Alert tone="warning" title="Showing saved information">
          <span className="inline-flex flex-wrap items-center gap-2">
            This section could not be refreshed. Retry when your connection is available.
            <Button variant="ghost" size="sm" onClick={() => void query.refetch()}>
              Retry
            </Button>
          </span>
        </Alert>
      ) : null}
      {render(query.data)}
    </div>
  )
}

function RolePagedPanel<T>({
  userId,
  section,
  load,
  renderItem,
  emptyTitle,
  emptyDescription,
}: {
  userId: number
  section: string
  load: (offset: number, signal: AbortSignal) => Promise<RolePageDto<T>>
  renderItem: (item: T) => ReactNode
  emptyTitle: string
  emptyDescription: string
}) {
  const [page, setPage] = useState(0)
  const query = useQuery({
    queryKey: myRoleQueryKeys.section(userId, section, page),
    queryFn: ({ signal }) => load(page * 10, signal),
    staleTime: DATA_FRESHNESS_MS.reference,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })

  if (query.isPending) {
    return (
      <div aria-label={`Loading ${section}`} className="space-y-3">
        <Skeleton variant="row" />
        <Skeleton variant="row" />
      </div>
    )
  }
  if (!query.data) {
    if (query.error instanceof ApiError && query.error.status === 404) {
      return <RoleEmptyState title={emptyTitle} description={emptyDescription} />
    }
    return (
      <SectionErrorState
        title="This section could not load"
        error={query.error}
        onRetry={() => void query.refetch()}
      />
    )
  }

  const pageCount = Math.max(1, Math.ceil(query.data.count / 10))
  return (
    <div className="space-y-3">
      {query.isError ? (
        <Alert tone="warning" title="Showing saved information">
          <span className="inline-flex flex-wrap items-center gap-2">
            This section could not be refreshed.
            <Button variant="ghost" size="sm" onClick={() => void query.refetch()}>
              Retry
            </Button>
          </span>
        </Alert>
      ) : null}
      {query.data.items.length ? (
        <ul className="tablet:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
          {query.data.items.map((item, index) => (
            <li
              key={index}
              className="border-border-subtle bg-surface-muted/45 rounded-control phone:p-4 min-w-0 border p-3"
            >
              {renderItem(item)}
            </li>
          ))}
        </ul>
      ) : (
        <RoleEmptyState title={emptyTitle} description={emptyDescription} />
      )}
      {query.data.count > 10 ? (
        <div className="border-border-subtle flex flex-wrap items-center justify-between gap-3 border-t pt-3">
          <p className="text-caption text-text-secondary">
            Page {page + 1} of {pageCount} · {query.data.count} total
          </p>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={page === 0}
              onClick={() => setPage((value) => value - 1)}
            >
              Previous
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={page + 1 >= pageCount}
              onClick={() => setPage((value) => value + 1)}
            >
              Next
            </Button>
          </div>
        </div>
      ) : null}
    </div>
  )
}

function DataItem({
  title,
  description,
  meta,
}: {
  title: string
  description?: string
  meta?: ReactNode
}) {
  return (
    <div className="min-w-0">
      <h3 className="text-body-md text-text-primary min-w-0 leading-snug font-semibold">{title}</h3>
      {meta ? <div className="mt-2 flex max-w-full flex-wrap gap-1.5">{meta}</div> : null}
      {description ? (
        <p className="text-body-sm text-text-secondary mt-2 leading-relaxed whitespace-pre-line">
          {description}
        </p>
      ) : null}
    </div>
  )
}

function GroupedItems({ groups }: { groups: Array<[string, ReactNode[]]> }) {
  const nonEmpty = groups.filter(([, items]) => items.length > 0)
  if (!nonEmpty.length) {
    return (
      <RoleEmptyState
        title="Nothing listed yet"
        description="There are no items assigned to this role."
      />
    )
  }
  return (
    <div className="tablet:grid-cols-2 grid min-w-0 grid-cols-1 gap-3">
      {nonEmpty.map(([title, items]) => (
        <section
          key={title}
          aria-label={title}
          className="border-border-subtle bg-surface-muted/35 rounded-control phone:p-4 min-w-0 border p-3"
        >
          <header className="mb-2 flex items-center justify-between gap-2">
            <h3 className="text-label text-text-primary font-semibold">{title}</h3>
            <StatusChip
              dense
              tone="neutral"
              label={`${items.length} ${items.length === 1 ? 'item' : 'items'}`}
            />
          </header>
          <ul className="divide-border-subtle divide-y">
            {items.map((item, index) => (
              <li key={`${title}-${index}`} className="min-w-0 py-3 first:pt-2 last:pb-0">
                {item}
              </li>
            ))}
          </ul>
        </section>
      ))}
    </div>
  )
}

function ReportingTree({
  nodes,
  depth = 0,
}: {
  nodes: RoleReportingTreeNodeDto[]
  depth?: number
}) {
  return (
    <ul className={depth ? 'border-border-subtle ml-3 space-y-2 border-l pl-3' : 'space-y-2'}>
      {nodes.map((node) => (
        <li key={node.id} className="min-w-0">
          <div className="border-border-subtle bg-surface rounded-control border px-3 py-3">
            <p className="text-body-md leading-snug font-semibold">{node.role.name}</p>
            <div className="mt-2 flex flex-wrap items-center gap-1.5">
              <StatusChip dense tone="neutral" label={humanize(node.relationship_type)} />
              {node.cycle_detected ? (
                <StatusChip dense tone="warning" label="Review reporting link" />
              ) : null}
            </div>
            <p className="text-caption text-text-secondary mt-2">
              Reports to{' '}
              <span className="text-text-primary font-medium">{node.reports_to_role.name}</span>
            </p>
          </div>
          {node.children.length ? <ReportingTree nodes={node.children} depth={depth + 1} /> : null}
        </li>
      ))}
    </ul>
  )
}

function CareerTree({ nodes, depth = 0 }: { nodes: RoleCareerPathNodeDto[]; depth?: number }) {
  return (
    <ul className={depth ? 'border-border-subtle ml-3 space-y-2 border-l pl-3' : 'space-y-2'}>
      {nodes.map((node) => (
        <li key={node.id} className="min-w-0">
          <div className="border-border-subtle bg-surface rounded-control relative border px-3 py-3">
            <div className="flex flex-wrap items-center justify-between gap-2">
              <p className="text-body-md leading-snug font-semibold">{node.to_role.name}</p>
              <div className="flex flex-wrap gap-1.5">
                <StatusChip
                  dense
                  tone={depth === 0 ? 'info' : 'neutral'}
                  label={depth === 0 ? 'Next step' : 'Further progression'}
                />
                {node.estimated_duration_months ? (
                  <StatusChip
                    dense
                    tone="neutral"
                    label={`~${node.estimated_duration_months} months`}
                  />
                ) : null}
              </div>
            </div>
            {node.description ? (
              <p className="text-body-sm text-text-secondary mt-2 leading-relaxed">
                {node.description}
              </p>
            ) : null}
            {node.requirements ? (
              <p className="text-body-sm text-text-secondary border-border-subtle mt-2 border-t pt-2 leading-relaxed">
                <span className="text-text-primary font-medium">Readiness:</span>{' '}
                {node.requirements}
              </p>
            ) : null}
          </div>
          {node.children.length ? <CareerTree nodes={node.children} depth={depth + 1} /> : null}
        </li>
      ))}
    </ul>
  )
}

function RolePermissionsPanel({ permissions }: { permissions: Record<string, string[]> }) {
  return <PermissionActionGroups permissions={permissions} />
}

function RoleInformation({
  role,
  userId,
  permissions,
}: {
  role: AssignedRoleDto
  userId: number
  permissions: Record<string, string[]>
}) {
  const branches = role.branches ?? []
  const assignedPermissions = Object.entries(role.permissions ?? {}).filter(
    ([, actions]) => actions.length > 0,
  )
  const sectionAllowed = (section: keyof typeof roleSectionPermissions) =>
    canViewSection(permissions, roleSectionPermissions[section])

  return (
    <div className="space-y-5">
      <Card className="overflow-hidden p-0">
        <div className="from-primary/10 via-surface to-surface tablet:flex-row tablet:items-center phone:px-6 flex flex-col gap-4 bg-gradient-to-br px-4 py-5">
          <span className="bg-primary-subtle text-primary rounded-surface flex size-12 shrink-0 items-center justify-center">
            <ShieldCheck className="size-6" aria-hidden="true" />
          </span>
          <div className="min-w-0 flex-1">
            <p className="text-overline text-primary">Your assigned role</p>
            <h2 className="text-h2 text-text-primary mt-1 font-semibold tracking-tight">
              {role.name}
            </h2>
            <p className="text-caption text-text-secondary mt-1">
              Responsibilities, access, and self-service guidance for this assignment.
            </p>
          </div>
          <StatusChip label="Read only" tone="neutral" dense />
        </div>
        <div className="bg-surface-muted/45 border-border-subtle tablet:grid-cols-2 grid grid-cols-1 border-t">
          <div className="border-border-subtle tablet:border-r tablet:border-b-0 flex items-center gap-3 border-b px-5 py-3">
            <BriefcaseBusiness className="text-primary size-4 shrink-0" aria-hidden="true" />
            <span className="text-body-sm">Role ID · {role.id}</span>
          </div>
          <div className="flex min-w-0 flex-wrap items-center gap-2 px-5 py-3">
            <Network className="text-primary size-4 shrink-0" aria-hidden="true" />
            <span className="text-body-sm text-text-secondary">Branch scope</span>
            {branches.length ? (
              branches
                .slice(0, 3)
                .map((branch) => (
                  <StatusChip key={branch.id} dense tone="info" label={branch.branch_name} />
                ))
            ) : (
              <StatusChip dense tone="neutral" label="Company-wide where allowed" />
            )}
            {branches.length > 3 ? (
              <span className="text-caption text-text-secondary">+{branches.length - 3} more</span>
            ) : null}
          </div>
        </div>
      </Card>

      {sectionAllowed('authority') ? (
        <RoleAccordion
          id="role-permissions"
          title="Permissions & authority"
          description="A clear view of the access assigned to your role."
          icon={<ShieldCheck className="size-5" aria-hidden="true" />}
          defaultOpen
        >
          <RolePermissionsPanel permissions={role.permissions ?? {}} />
        </RoleAccordion>
      ) : null}

      <div className="desktop:grid-cols-2 desktop:items-start phone:gap-5 grid min-w-0 grid-cols-1 gap-4">
        {sectionAllowed('description') ? (
          <RoleAccordion
            id="role-description"
            title="Description & responsibilities"
            description="Purpose and expectations of this role."
            icon={<FileText className="size-5" aria-hidden="true" />}
            className="desktop:col-span-2"
          >
            <RoleDataPanel
              userId={userId}
              section="description"
              load={(signal) => myRoleApi.description(signal)}
              render={(data) => {
                const responsibilities = data.responsibilities
                  .split(/\n+/)
                  .map((item) => item.replace(/^[-•*]\s*/, '').trim())
                  .filter(Boolean)
                return data.purpose || data.job_description || responsibilities.length ? (
                  <div className="space-y-4">
                    {data.purpose ? (
                      <section className="from-primary-subtle/70 to-surface rounded-control border-border-subtle phone:p-5 border bg-gradient-to-br p-4">
                        <p className="text-overline text-primary">Role purpose</p>
                        <p className="text-body-md text-text-primary mt-2 max-w-4xl leading-relaxed">
                          {data.purpose}
                        </p>
                      </section>
                    ) : null}
                    {data.job_description ? (
                      <section className="rounded-control bg-surface-muted/45 phone:p-5 p-4">
                        <h3 className="text-label text-text-primary font-semibold">
                          What this role delivers
                        </h3>
                        <p className="text-body-sm text-text-secondary mt-2 max-w-4xl leading-relaxed">
                          {data.job_description}
                        </p>
                      </section>
                    ) : null}
                    {responsibilities.length ? (
                      <section>
                        <div className="mb-3 flex items-end justify-between gap-3">
                          <div>
                            <h3 className="text-label text-text-primary font-semibold">
                              Key responsibilities
                            </h3>
                            <p className="text-caption text-text-secondary mt-1">
                              The work you are accountable for.
                            </p>
                          </div>
                          <StatusChip
                            dense
                            tone="neutral"
                            label={`${responsibilities.length} areas`}
                          />
                        </div>
                        <ul className="tablet:grid-cols-2 grid min-w-0 grid-cols-1 gap-2.5">
                          {responsibilities.map((responsibility, index) => (
                            <li
                              key={`${index}-${responsibility}`}
                              className="border-border-subtle bg-surface rounded-control flex min-w-0 items-start gap-2.5 border p-3"
                            >
                              <CircleCheck
                                className="text-success-foreground mt-0.5 size-4 shrink-0"
                                aria-hidden="true"
                              />
                              <span className="text-body-sm text-text-secondary leading-relaxed">
                                {responsibility}
                              </span>
                            </li>
                          ))}
                        </ul>
                      </section>
                    ) : null}
                  </div>
                ) : (
                  <RoleEmptyState
                    title="Description not added"
                    description="A description has not been added to this role yet."
                  />
                )
              }}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('kpis') ? (
          <RoleAccordion
            id="role-kpis"
            title="Key performance indicators"
            description="Measures used to track role outcomes."
            icon={<Target className="size-5" aria-hidden="true" />}
          >
            <RolePagedPanel
              userId={userId}
              section="kpis"
              load={(offset, signal) => myRoleApi.kpis(offset, signal)}
              emptyTitle="No KPIs assigned"
              emptyDescription="There are no key performance indicators linked to this role."
              renderItem={(item: RoleKpiDto) => (
                <DataItem
                  title={item.metric.name}
                  description={item.metric.description}
                  meta={
                    <>
                      {item.target_value != null ? (
                        <StatusChip
                          dense
                          tone="info"
                          label={`Target ${formatKpiTarget(item.target_value, item.metric.unit)}`}
                        />
                      ) : null}
                      {item.period ? (
                        <StatusChip dense tone="neutral" label={humanize(item.period)} />
                      ) : null}
                    </>
                  }
                />
              )}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('sops') ? (
          <RoleAccordion
            id="role-sops"
            title="Standard operating procedures"
            description="Current procedures connected to this role."
            icon={<BookOpenCheck className="size-5" aria-hidden="true" />}
          >
            <RolePagedPanel
              userId={userId}
              section="sops"
              load={(offset, signal) => myRoleApi.sops(offset, signal)}
              emptyTitle="No procedures assigned"
              emptyDescription="There are no standard operating procedures linked to this role."
              renderItem={(item: RoleSopDto) => (
                <DataItem
                  title={item.sop.title}
                  description={item.sop.description}
                  meta={[
                    item.sop.version ? (
                      <StatusChip key="version" dense tone="neutral" label={item.sop.version} />
                    ) : null,
                    item.sop.priority ? (
                      <StatusChip
                        key="priority"
                        dense
                        tone={priorityTone(item.sop.priority.toLowerCase())}
                        label={`${humanize(item.sop.priority)} priority`}
                      />
                    ) : null,
                    <StatusChip
                      key="review-state"
                      dense
                      tone={item.sop.is_up_to_date ? 'success' : 'warning'}
                      label={item.sop.is_up_to_date ? 'Current' : 'Review needed'}
                    />,
                  ]}
                />
              )}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('reporting') ? (
          <RoleAccordion
            id="role-reporting"
            title="Reporting structure"
            description="Your manager chain and roles that report through this role."
            icon={<Network className="size-5" aria-hidden="true" />}
            className="desktop:col-span-2"
          >
            <div className="space-y-5">
              <div className="tablet:grid-cols-2 tablet:items-start grid min-w-0 grid-cols-1 gap-4">
                <section className="min-w-0">
                  <div className="mb-2">
                    <h3 className="text-label text-text-primary font-semibold">Manager chain</h3>
                    <p className="text-caption text-text-secondary mt-1">
                      Roles this position reports through.
                    </p>
                  </div>
                  <RoleDataPanel
                    userId={userId}
                    section="reporting-chain"
                    load={(signal) => myRoleApi.reportingChain(signal)}
                    emptyTitle="Reporting chain not set"
                    emptyDescription="No manager reporting line has been configured for this role."
                    render={(data: RoleReportingChainDto) =>
                      data.chain.length ? (
                        <ol className="space-y-2">
                          {data.chain.map((line, index) => (
                            <li
                              key={line.id}
                              className="border-border-subtle bg-surface rounded-control flex min-w-0 items-center gap-3 border p-3"
                            >
                              <span className="bg-primary-subtle text-primary text-caption rounded-control flex size-8 shrink-0 items-center justify-center font-semibold">
                                {index + 1}
                              </span>
                              <div className="min-w-0 flex-1">
                                <p className="text-body-sm leading-snug font-semibold">
                                  {line.reports_to_role.name}
                                </p>
                                <p className="text-caption text-text-secondary mt-1">
                                  {humanize(line.relationship_type)} reporting line
                                </p>
                              </div>
                              {line.cycle_detected ? (
                                <StatusChip dense tone="warning" label="Review link" />
                              ) : null}
                            </li>
                          ))}
                        </ol>
                      ) : (
                        <RoleEmptyState
                          title="Reporting chain not set"
                          description="No manager reporting line has been configured."
                        />
                      )
                    }
                  />
                </section>
                <section className="min-w-0">
                  <div className="mb-2">
                    <h3 className="text-label text-text-primary font-semibold">Direct reports</h3>
                    <p className="text-caption text-text-secondary mt-1">
                      Roles that report through this position.
                    </p>
                  </div>
                  <RoleDataPanel
                    userId={userId}
                    section="reporting-tree"
                    load={(signal) => myRoleApi.reportingTree(signal)}
                    emptyTitle="No reporting tree available"
                    emptyDescription="There are no reporting relationships configured below this role."
                    render={(data) =>
                      data.direct_reports.length ? (
                        <ReportingTree nodes={data.direct_reports} />
                      ) : (
                        <RoleEmptyState
                          title="No direct reports"
                          description="No roles currently report through this role."
                        />
                      )
                    }
                  />
                </section>
              </div>
              <section className="border-border-subtle border-t pt-4">
                <div className="mb-2">
                  <h3 className="text-label text-text-primary font-semibold">
                    Reporting relationships
                  </h3>
                  <p className="text-caption text-text-secondary mt-1">
                    Assigned reporting lines and their organizational scope.
                  </p>
                </div>
                <RolePagedPanel
                  userId={userId}
                  section="reporting-lines"
                  load={(offset, signal) => myRoleApi.reportingLines(offset, signal)}
                  emptyTitle="No reporting lines"
                  emptyDescription="There are no reporting lines linked to this role."
                  renderItem={(line: RoleReportingLineDto) => (
                    <DataItem
                      title={`${line.role.name} → ${line.reports_to_role.name}`}
                      description={
                        [line.department?.name, line.branch?.branch_name, line.unit?.name]
                          .filter(Boolean)
                          .join(' · ') || 'Organization-wide relationship'
                      }
                      meta={
                        <StatusChip dense tone="info" label={humanize(line.relationship_type)} />
                      }
                    />
                  )}
                />
              </section>
            </div>
          </RoleAccordion>
        ) : null}

        {sectionAllowed('career') ? (
          <RoleAccordion
            id="role-career"
            title="Career path"
            description="Possible next roles and progression guidance."
            icon={<ArrowUpRight className="size-5" aria-hidden="true" />}
          >
            <RoleDataPanel
              userId={userId}
              section="career-path"
              load={(signal) => myRoleApi.careerPath(signal)}
              emptyTitle="No career path defined"
              emptyDescription="Career progression has not been mapped for this role."
              render={(data) =>
                data.paths.length ? (
                  <CareerTree nodes={data.paths} />
                ) : (
                  <RoleEmptyState
                    title="No next role listed"
                    description="No career progression steps have been defined."
                  />
                )
              }
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('training') ? (
          <RoleAccordion
            id="role-training"
            title="Training requirements"
            description="Required and continuing learning for this role."
            icon={<GraduationCap className="size-5" aria-hidden="true" />}
          >
            <RoleDataPanel
              userId={userId}
              section="training-requirements"
              load={(signal) => myRoleApi.training(signal)}
              render={(data) => (
                <GroupedItems
                  groups={[
                    [
                      'Mandatory',
                      data.mandatory.map((item: RoleTrainingRequirementDto) => (
                        <DataItem
                          key={item.id}
                          title={item.training_program.program_name}
                          description={item.training_program.provider}
                          meta={
                            <>
                              <StatusChip
                                dense
                                tone={trainingStatusTone(item.training_program.status)}
                                label={humanize(item.training_program.status)}
                              />
                              {item.training_program.start_date ||
                              item.training_program.end_date ? (
                                <StatusChip
                                  dense
                                  tone="neutral"
                                  label={formatTrainingDates(
                                    item.training_program.start_date,
                                    item.training_program.end_date,
                                  )}
                                />
                              ) : null}
                            </>
                          }
                        />
                      )),
                    ],
                    [
                      'Continuous learning',
                      data.continuous.map((item: RoleTrainingRequirementDto) => (
                        <DataItem
                          key={item.id}
                          title={item.training_program.program_name}
                          description={item.training_program.provider}
                          meta={
                            <>
                              <StatusChip
                                dense
                                tone={trainingStatusTone(item.training_program.status)}
                                label={humanize(item.training_program.status)}
                              />
                              {item.training_program.start_date ||
                              item.training_program.end_date ? (
                                <StatusChip
                                  dense
                                  tone="neutral"
                                  label={formatTrainingDates(
                                    item.training_program.start_date,
                                    item.training_program.end_date,
                                  )}
                                />
                              ) : null}
                            </>
                          }
                        />
                      )),
                    ],
                  ]}
                />
              )}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('playbook') ? (
          <RoleAccordion
            id="role-playbook"
            title="Success playbook"
            description="Practices, strategies, and lessons for this role."
            icon={<Sparkles className="size-5" aria-hidden="true" />}
          >
            <RoleDataPanel
              userId={userId}
              section="success-playbook"
              load={(signal) => myRoleApi.playbook(signal)}
              render={(data) => (
                <GroupedItems
                  groups={[
                    [
                      'Best practices',
                      data.best_practice.map((item) => (
                        <DataItem key={item.id} title={item.title} description={item.description} />
                      )),
                    ],
                    [
                      'Winning strategies',
                      data.winning_strategy.map((item) => (
                        <DataItem key={item.id} title={item.title} description={item.description} />
                      )),
                    ],
                    [
                      'Lessons learned',
                      data.lesson_learned.map((item) => (
                        <DataItem key={item.id} title={item.title} description={item.description} />
                      )),
                    ],
                    [
                      'Common mistakes',
                      data.common_mistake.map((item) => (
                        <DataItem key={item.id} title={item.title} description={item.description} />
                      )),
                    ],
                  ]}
                />
              )}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('resources') ? (
          <RoleAccordion
            id="role-resources"
            title="Resources"
            description="Tools, documents, skills, and materials for your work."
            icon={<PackageOpen className="size-5" aria-hidden="true" />}
          >
            <RoleDataPanel
              userId={userId}
              section="resources"
              load={(signal) => myRoleApi.resources(signal)}
              render={(data) => (
                <GroupedItems
                  groups={[
                    [
                      'Software',
                      data.software.map((item: RoleResourceDto) => (
                        <DataItem key={item.id} title={item.name} description={item.description} />
                      )),
                    ],
                    [
                      'Documents',
                      data.document.map((item: RoleResourceDto) => (
                        <DataItem key={item.id} title={item.name} description={item.description} />
                      )),
                    ],
                    [
                      'Physical resources',
                      data.physical.map((item: RoleResourceDto) => (
                        <DataItem key={item.id} title={item.name} description={item.description} />
                      )),
                    ],
                    [
                      'Skills',
                      data.skill.map((item: RoleResourceDto) => (
                        <DataItem key={item.id} title={item.name} description={item.description} />
                      )),
                    ],
                  ]}
                />
              )}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('taskTemplates') ? (
          <RoleAccordion
            id="role-task-templates"
            title="Task templates"
            description="Recurring work and default expectations."
            icon={<ListChecks className="size-5" aria-hidden="true" />}
          >
            <RolePagedPanel
              userId={userId}
              section="task-templates"
              load={(offset, signal) => myRoleApi.taskTemplates(offset, signal)}
              emptyTitle="No task templates"
              emptyDescription="There are no role-specific task templates."
              renderItem={(item: RoleTaskTemplateDto) => (
                <DataItem
                  title={item.title}
                  description={item.description}
                  meta={
                    <>
                      <StatusChip
                        dense
                        tone={priorityTone(item.default_priority)}
                        label={`${humanize(item.default_priority)} priority`}
                      />
                      {item.estimated_minutes != null ? (
                        <StatusChip dense tone="neutral" label={`${item.estimated_minutes} min`} />
                      ) : null}
                    </>
                  }
                />
              )}
            />
          </RoleAccordion>
        ) : null}

        {sectionAllowed('dailyRoutine') ? (
          <RoleAccordion
            id="role-daily-routine"
            title="Daily routine"
            description="Suggested rhythm and routine responsibilities."
            icon={<CalendarClock className="size-5" aria-hidden="true" />}
          >
            <RolePagedPanel
              userId={userId}
              section="daily-routine"
              load={(offset, signal) => myRoleApi.dailyRoutine(offset, signal)}
              emptyTitle="No routine defined"
              emptyDescription="A daily routine has not been configured for this role."
              renderItem={(item: RoleDailyRoutineDto) => (
                <DataItem
                  title={item.title}
                  description={item.description}
                  meta={
                    <>
                      {item.time_of_day ? (
                        <StatusChip dense tone="info" label={formatRoutineTime(item.time_of_day)} />
                      ) : null}
                      {item.estimated_minutes != null ? (
                        <StatusChip dense tone="neutral" label={`${item.estimated_minutes} min`} />
                      ) : null}
                    </>
                  }
                />
              )}
            />
          </RoleAccordion>
        ) : null}
      </div>
      {assignedPermissions.length === 0 && !sectionAllowed('authority') ? (
        <Card>
          <div className="flex items-start gap-3">
            <CircleHelp className="text-text-secondary mt-0.5 size-5 shrink-0" aria-hidden="true" />
            <p className="text-body-sm text-text-secondary">
              Role information is available to your account according to its permissions.
            </p>
          </div>
        </Card>
      ) : null}
    </div>
  )
}

export function MyRolePage() {
  const sessionQuery = useQuery({
    ...authSessionQueryOptions(),
    staleTime: DATA_FRESHNESS_MS.standard,
    refetchOnWindowFocus: true,
    refetchOnReconnect: true,
  })
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const roleQuery = useQuery({
    ...assignedRoleQueryOptions(userId),
    enabled: userId > 0,
  })
  const sessionBootstrapError =
    sessionQuery.error instanceof SessionBootstrapError ? sessionQuery.error : null
  const loadError = sessionBootstrapError?.cause ?? sessionQuery.error
  const sessionErrorTitle =
    sessionBootstrapError?.stage === 'permissions'
      ? 'Access permissions could not be verified'
      : 'Your employee profile could not be loaded'
  const sessionErrorDescription =
    sessionBootstrapError?.stage === 'permissions'
      ? 'BOMACH OS could not verify your current access. Check your connection, then retry.'
      : 'Your signed-in employee information is required to load role details. Check your connection, then retry.'

  return (
    <PageLayout
      title="My role"
      subtitle="Understand your responsibilities, permissions, reporting lines, and development path."
      leading={<ShieldCheck className="size-[18px]" aria-hidden="true" />}
    >
      {sessionQuery.isPending ? (
        <PageSkeleton className="space-y-5">
          <Skeleton variant="card" className="h-36" />
          <div className="desktop:grid-cols-2 grid grid-cols-1 gap-4">
            <Skeleton variant="card" />
            <Skeleton variant="card" />
            <Skeleton variant="card" />
            <Skeleton variant="card" />
          </div>
        </PageSkeleton>
      ) : sessionQuery.isError && !session ? (
        <Card>
          <ErrorState
            title={sessionErrorTitle}
            description={sessionErrorDescription}
            error={loadError ?? undefined}
            action={<Button onClick={() => void sessionQuery.refetch()}>Try again</Button>}
          />
        </Card>
      ) : roleQuery.isPending ? (
        <PageSkeleton className="space-y-5">
          <Skeleton variant="card" className="h-36" />
          <div className="desktop:grid-cols-2 grid grid-cols-1 gap-4">
            <Skeleton variant="card" />
            <Skeleton variant="card" />
            <Skeleton variant="card" />
            <Skeleton variant="card" />
          </div>
        </PageSkeleton>
      ) : roleQuery.data ? (
        <div className="space-y-5">
          {roleQuery.isError ? (
            <Alert tone="warning" title={presentError(roleQuery.error, 'background-action').title}>
              <span className="inline-flex flex-wrap items-center gap-2">
                Showing the saved role information. Retry to check for updates.
                <Button variant="ghost" size="sm" onClick={() => void roleQuery.refetch()}>
                  Retry
                </Button>
              </span>
            </Alert>
          ) : null}
          {session ? (
            <RoleInformation
              role={roleQuery.data}
              userId={userId}
              permissions={session.permissions}
            />
          ) : null}
        </div>
      ) : roleQuery.error instanceof ApiError && roleQuery.error.status === 404 ? (
        <Card>
          <EmptyState
            title="No role assigned yet"
            description="A role has not been assigned to your employee account. Contact your manager or People team if you think this is incorrect."
            icon={<ShieldCheck className="size-6" aria-hidden="true" />}
          />
        </Card>
      ) : (
        <Card>
          <ErrorState
            title="Your role could not be loaded"
            description="Check your connection or access, then retry."
            error={roleQuery.error}
            action={<Button onClick={() => void roleQuery.refetch()}>Try again</Button>}
          />
        </Card>
      )}
    </PageLayout>
  )
}
