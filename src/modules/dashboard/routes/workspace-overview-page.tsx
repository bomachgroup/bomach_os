import { useQuery } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import {
  Activity,
  ArrowRight,
  Bell,
  BriefcaseBusiness,
  Building2,
  CalendarCheck2,
  CalendarDays,
  CheckCheck,
  CircleX,
  ClipboardCheck,
  Clock3,
  FileText,
  GitBranch,
  MapPinned,
  PackageSearch,
  Users,
} from 'lucide-react'

import {
  DashboardEmptyMessage,
  DashboardListRow,
  DashboardPanel,
  DashboardPanelCard,
  DashboardRingMetricCard,
  DashboardScoreBreakdownCard,
  DashboardLoadingRows,
  type DashboardTone,
} from '@/modules/dashboard/dashboard-components'
import { dashboardApi, personalOverviewQueryKey } from '@/modules/dashboard/dashboard.api'
import {
  personalWorkApi,
  personalWorkQueryKeys,
  type PersonalLeaveRequestDto,
  type PersonalLoanDto,
  type PersonalTaskDto,
  type PersonalWorkReportDto,
} from '@/modules/dashboard/personal-work.api'
import {
  companyDashboardApi,
  companyOverviewQueryKey,
} from '@/modules/company/company-dashboard.api'
import { hrDashboardApi, hrOverviewQueryKey } from '@/modules/hr/hr-dashboard.api'
import {
  operationsDashboardApi,
  operationsOverviewQueryKey,
} from '@/modules/operations/operations-dashboard.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { notificationApi, type NotificationDto } from '@/shared/notifications/notifications.api'
import { Button } from '@/shared/ui/button'
import { SectionErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { cn } from '@/shared/lib/cn'
import { PageLayout } from '@/shared/ui/page-layout'

interface UpdateItem {
  key: string
  category: string
  title: string
  description: string
  date: string
  href?: string
  icon: ReactNode
}

interface AttentionItem {
  key: string
  title: string
  description: string
  href: string
  icon: ReactNode
  status: string
  tone: DashboardTone
  weight: number
}

function hasAny(permissions: Record<string, string[]>, requirements: [string, string][]) {
  return requirements.some(([resource, action]) => hasPermission(permissions, resource, action))
}

function localDateString(date: Date) {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

function formatShortDate(value: string) {
  return new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric' }).format(
    new Date(`${value.slice(0, 10)}T00:00:00`),
  )
}

function relativeTime(value: string) {
  const difference = Date.now() - new Date(value).getTime()
  if (!Number.isFinite(difference)) return ''
  const minutes = Math.max(1, Math.floor(difference / 60_000))
  if (minutes < 60) return `${minutes}m ago`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.floor(hours / 24)
  return days < 7 ? `${days}d ago` : formatShortDate(value)
}

function greeting(now: Date) {
  const hour = now.getHours()
  return hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening'
}

function performanceGridClass(cardCount: number) {
  if (cardCount === 3) {
    return 'desktop:grid-cols-[minmax(10.5rem,0.8fr)_minmax(0,1.6fr)_minmax(0,1.6fr)]'
  }
  return cardCount === 2 ? 'tablet:grid-cols-2' : 'grid-cols-1'
}

function initials(name: string) {
  return name
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('')
}

function canonicalEntity(type: string, id: string | number) {
  const canonicalType = canonicalEntityType(type)
  return `${canonicalType}:${id}`
}

function canonicalEntityType(type: string) {
  const normalized = type.toLowerCase().replaceAll('-', '_')
  const canonicalType = normalized.includes('task')
    ? 'task'
    : normalized.includes('report')
      ? 'work_report'
      : normalized.includes('leave') || normalized.includes('absence')
        ? 'leave_request'
        : normalized.includes('loan')
          ? 'loan'
          : normalized
  return canonicalType
}

function notificationRoute(notification: NotificationDto): string | undefined {
  const entityType =
    `${notification.entity_type} ${String(notification.metadata.entity_type ?? '')}`
      .toLowerCase()
      .replaceAll('-', '_')
  if (entityType.includes('task')) return '/dashboard/my-tasks'
  if (entityType.includes('report')) return '/dashboard/my-reports'
  if (entityType.includes('leave') || entityType.includes('absence')) return '/hr/leaves'
  if (entityType.includes('loan')) return '/hr/loans'
  return undefined
}

function notificationKey(notification: NotificationDto) {
  const type = notification.entity_type || String(notification.metadata.entity_type ?? '')
  const id = notification.entity_id || String(notification.metadata.entity_id ?? '')
  return type && id ? canonicalEntity(type, id) : `notification:${notification.id}`
}

function buildUpdates({
  notifications,
  tasks,
  reports,
  leaveRequests,
  loans,
  excludedKeys,
}: {
  notifications: NotificationDto[]
  tasks: PersonalTaskDto[]
  reports: PersonalWorkReportDto[]
  leaveRequests: PersonalLeaveRequestDto[]
  loans: PersonalLoanDto[]
  excludedKeys: Set<string>
}) {
  const candidates: UpdateItem[] = []

  for (const item of notifications) {
    const key = notificationKey(item)
    if (excludedKeys.has(key)) continue
    candidates.push({
      key,
      category: key.startsWith('notification:')
        ? 'notification'
        : canonicalEntityType(item.entity_type || String(item.metadata.entity_type ?? '')),
      title: item.title,
      description: item.message,
      date: item.created_at,
      href: notificationRoute(item),
      icon: <Bell className="size-4" aria-hidden="true" />,
    })
  }

  for (const task of tasks) {
    if (task.status !== 'completed') continue
    const key = canonicalEntity('task', task.id)
    if (excludedKeys.has(key)) continue
    candidates.push({
      key,
      category: 'task',
      title: 'Task completed',
      description: task.name,
      date: task.updated_at,
      href: '/dashboard/my-tasks',
      icon: <CheckCheck className="size-4" aria-hidden="true" />,
    })
  }

  for (const report of reports) {
    if (report.status === 'draft') continue
    const key = canonicalEntity('work_report', report.id)
    if (excludedKeys.has(key)) continue
    candidates.push({
      key,
      category: 'work_report',
      title:
        report.status === 'approved'
          ? 'Work report approved'
          : report.status === 'rejected'
            ? 'Work report returned for update'
            : 'Work report submitted',
      description: report.work_summary?.trim() || formatShortDate(report.day),
      date: report.updated_at,
      href: '/dashboard/my-reports',
      icon: <FileText className="size-4" aria-hidden="true" />,
    })
  }

  for (const request of leaveRequests) {
    if (request.status === 'pending') continue
    const key = canonicalEntity('leave_request', request.id)
    if (excludedKeys.has(key)) continue
    candidates.push({
      key,
      category: 'leave_request',
      title: `Request ${request.status}`,
      description: `${request.request_kind === 'leave' ? 'Leave' : 'Attendance'} · ${formatShortDate(request.start_date)}`,
      date: request.updated_at,
      href: '/hr/leaves',
      icon: <CalendarCheck2 className="size-4" aria-hidden="true" />,
    })
  }

  for (const loan of loans) {
    if (loan.status.toLowerCase().includes('pending')) continue
    const key = canonicalEntity('loan', loan.id)
    if (excludedKeys.has(key)) continue
    candidates.push({
      key,
      category: 'loan',
      title: `Loan request ${loan.status.toLowerCase()}`,
      description: loan.reason,
      date: loan.updated_at,
      href: '/hr/loans',
      icon: <BriefcaseBusiness className="size-4" aria-hidden="true" />,
    })
  }

  const latestByEntity = new Map<string, UpdateItem>()
  for (const candidate of candidates) {
    const current = latestByEntity.get(candidate.key)
    if (!current || new Date(candidate.date).getTime() > new Date(current.date).getTime()) {
      latestByEntity.set(candidate.key, candidate)
    }
  }

  const sorted = [...latestByEntity.values()].sort(
    (left, right) => new Date(right.date).getTime() - new Date(left.date).getTime(),
  )
  // Prefer a mix of actual event types from the recent window, then backfill
  // from that same window when one source dominates or other sources are empty.
  const recentCandidates = sorted.slice(0, 10)
  const selected: UpdateItem[] = []
  const deferred: UpdateItem[] = []
  const seenCategories = new Set<string>()

  for (const item of recentCandidates) {
    if (selected.length >= 5 || seenCategories.has(item.category)) {
      deferred.push(item)
      continue
    }
    selected.push(item)
    seenCategories.add(item.category)
  }

  for (const item of deferred) {
    if (selected.length >= 5) break
    selected.push(item)
  }

  return selected
    .sort((left, right) => new Date(right.date).getTime() - new Date(left.date).getTime())
    .slice(0, 5)
}

function TodayCell({
  icon,
  label,
  value,
  detail,
  href,
  error,
  loading,
  onRetry,
  tone = 'primary',
  className,
}: {
  icon: ReactNode
  label: string
  value: ReactNode
  detail?: ReactNode
  href?: string
  error?: boolean
  loading?: boolean
  onRetry?: () => void
  tone?: DashboardTone
  className?: string
}) {
  return (
    <div
      className={cn(
        'rounded-control border-border-subtle bg-surface phone:p-4 min-w-0 border p-3',
        className,
      )}
    >
      <p className="text-caption text-text-secondary flex items-center gap-2.5">
        <span
          className={cn(
            'rounded-control flex size-9 shrink-0 items-center justify-center',
            tone === 'success'
              ? 'bg-success-subtle text-success-foreground'
              : tone === 'warning'
                ? 'bg-warning-subtle text-warning-foreground'
                : tone === 'danger'
                  ? 'bg-danger-subtle text-danger-foreground'
                  : tone === 'info'
                    ? 'bg-info-subtle text-info-foreground'
                    : tone === 'neutral'
                      ? 'bg-neutral-100 text-neutral-600'
                      : 'bg-primary-subtle text-primary',
          )}
          aria-hidden="true"
        >
          {icon}
        </span>
        <span className="font-medium">{label}</span>
      </p>
      {loading ? (
        <div className="mt-3 space-y-2" role="status" aria-label={`Loading ${label}`}>
          <Skeleton className="h-5 w-28" />
          <Skeleton className="h-3 w-36" />
        </div>
      ) : error ? (
        <div className="mt-2 flex items-center gap-2">
          <span className="text-caption text-danger">Unavailable</span>
          {onRetry ? (
            <Button variant="ghost" size="sm" onClick={onRetry}>
              Retry
            </Button>
          ) : null}
        </div>
      ) : (
        <>
          {href ? (
            <Link
              to={href as never}
              className="text-body-md text-text-primary focus-visible:shadow-focus-ring rounded-control mt-3 inline-flex min-h-8 max-w-full items-center gap-1 font-semibold focus-visible:outline-none"
            >
              <span className="truncate">{value}</span>
              <ArrowRight className="size-3.5 shrink-0" aria-hidden="true" />
            </Link>
          ) : (
            <p className="text-body-md text-text-primary mt-3 truncate font-semibold">{value}</p>
          )}
          {detail ? <p className="text-caption text-text-muted mt-1 truncate">{detail}</p> : null}
        </>
      )}
    </div>
  )
}

function PulseSection({
  enabled,
  loading,
  error,
  items,
  onRetry,
}: {
  enabled: boolean
  loading: boolean
  error: boolean
  items: { label: string; value: number; detail: string; href: string; icon: ReactNode }[]
  onRetry: () => void
}) {
  if (!enabled) return null
  return (
    <DashboardPanel
      title="Organization pulse"
      description="A few signals from areas you can access."
      icon={<Building2 className="size-5" aria-hidden="true" />}
      action={
        error && items.length ? (
          <Button variant="ghost" size="sm" onClick={onRetry}>
            Retry unavailable data
          </Button>
        ) : null
      }
    >
      <DashboardPanelCard>
        {loading ? (
          <DashboardLoadingRows count={3} />
        ) : error && items.length === 0 ? (
          <SectionErrorState
            description="Organization summaries could not be loaded. Your personal work is still available."
            onRetry={onRetry}
          />
        ) : items.length ? (
          <ul className="divide-border-subtle divide-y">
            {items.slice(0, 3).map((item) => (
              <DashboardListRow
                key={item.label}
                icon={item.icon}
                title={item.label}
                description={item.detail}
                trailing={item.value.toLocaleString()}
                href={item.href}
              />
            ))}
          </ul>
        ) : (
          <DashboardEmptyMessage
            title="No organization signals"
            description="There are no summary values in your current permission and branch scope."
          />
        )}
      </DashboardPanelCard>
    </DashboardPanel>
  )
}

export function WorkspaceOverviewPage() {
  const { data: session } = useQuery(authSessionQueryOptions())
  const permissions = session?.permissions ?? {}
  const now = new Date()
  const today = localDateString(now)
  const monthStart = localDateString(new Date(now.getFullYear(), now.getMonth(), 1))
  const firstName = session?.employee.first_name || session?.user.first_name || 'there'
  const fullName = [session?.employee.first_name, session?.employee.last_name]
    .filter(Boolean)
    .join(' ')
  const roleTitle = session?.employee.designation || session?.roles[0]?.name || 'Your workspace'
  const department = session?.employee.department || ''

  const canViewAttendance = hasAny(permissions, [
    ['attendance', 'list'],
    ['attendance', 'list_own'],
  ])
  const canViewReports = hasAny(permissions, [
    ['work_reports', 'list'],
    ['work_reports', 'list_own'],
  ])
  const canViewTasks = hasAny(permissions, [
    ['tasks', 'list'],
    ['tasks', 'list_own'],
  ])
  const canViewLeaves = hasAny(permissions, [
    ['leave_requests', 'list'],
    ['leave_requests', 'list_own'],
  ])
  const canViewLoans = hasAny(permissions, [
    ['loans', 'list'],
    ['loans', 'list_own'],
  ])
  const canViewNotifications = hasPermission(permissions, 'notifications', 'list')

  const personalEnabled = canViewAttendance || canViewReports
  const companyEnabled = hasAny(permissions, [
    ['branches', 'list'],
    ['approval_requests', 'list'],
    ['departments', 'list'],
    ['department_units', 'list'],
    ['assets', 'list'],
  ])
  const hrEnabled = hasAny(permissions, [
    ['employees', 'list'],
    ['job_postings', 'list'],
    ['leave_requests', 'list'],
  ])
  const operationsEnabled = hasAny(permissions, [
    ['projects', 'list'],
    ['worksites', 'list'],
    ['contracts', 'list'],
    ['timelines', 'list'],
  ])
  const pulseEnabled = companyEnabled || hrEnabled || operationsEnabled

  const personal = useQuery({
    queryKey: personalOverviewQueryKey,
    queryFn: ({ signal }) => dashboardApi.personalOverview(signal),
    enabled: personalEnabled,
    staleTime: 30_000,
  })
  const attendanceToday = useQuery({
    queryKey: personalWorkQueryKeys.attendanceToday,
    queryFn: ({ signal }) => personalWorkApi.attendanceToday(signal),
    enabled: canViewAttendance,
    staleTime: 30_000,
  })
  const tasks = useQuery({
    queryKey: personalWorkQueryKeys.tasks,
    queryFn: ({ signal }) => personalWorkApi.tasks(signal),
    enabled: canViewTasks,
    staleTime: 30_000,
  })
  const completedTasks = useQuery({
    queryKey: personalWorkQueryKeys.completedTasks,
    queryFn: ({ signal }) => personalWorkApi.completedTasks(signal),
    enabled: canViewTasks,
    staleTime: 30_000,
  })
  const reports = useQuery({
    queryKey: [...personalWorkQueryKeys.reports, monthStart, today],
    queryFn: ({ signal }) => personalWorkApi.reports(monthStart, today, signal),
    enabled: canViewReports,
    staleTime: 30_000,
  })
  const leaveRequests = useQuery({
    queryKey: personalWorkQueryKeys.leaveRequests,
    queryFn: ({ signal }) => personalWorkApi.leaveRequests(signal),
    enabled: canViewLeaves,
    staleTime: 30_000,
  })
  const loans = useQuery({
    queryKey: personalWorkQueryKeys.loans,
    queryFn: ({ signal }) => personalWorkApi.loans(signal),
    enabled: canViewLoans,
    staleTime: 30_000,
  })
  const notifications = useQuery({
    queryKey: personalWorkQueryKeys.notifications,
    queryFn: ({ signal }) => notificationApi.list({ limit: 20, offset: 0, signal }),
    enabled: canViewNotifications,
    staleTime: 30_000,
  })
  const company = useQuery({
    queryKey: companyOverviewQueryKey,
    queryFn: ({ signal }) => companyDashboardApi.overview(signal),
    enabled: companyEnabled,
    staleTime: 30_000,
  })
  const hr = useQuery({
    queryKey: hrOverviewQueryKey,
    queryFn: ({ signal }) => hrDashboardApi.overview(signal),
    enabled: hrEnabled,
    staleTime: 30_000,
  })
  const operations = useQuery({
    queryKey: operationsOverviewQueryKey,
    queryFn: ({ signal }) => operationsDashboardApi.overview(signal),
    enabled: operationsEnabled,
    staleTime: 30_000,
  })

  const workReports = reports.data?.items ?? []
  const personalTasks = tasks.data?.items ?? []
  const todayReport = workReports.find((report) => report.day === today)
  const openTasks = personalTasks.filter(
    (task) => task.status !== 'completed' && task.status !== 'cancelled',
  )
  const sortedTasks = [...openTasks].sort((left, right) => {
    const dueCompare = (left.due_date ?? '9999-12-31').localeCompare(right.due_date ?? '9999-12-31')
    if (dueCompare) return dueCompare
    const priority = { high: 0, medium: 1, low: 2 }
    return (
      (priority[left.priority as keyof typeof priority] ?? 3) -
      (priority[right.priority as keyof typeof priority] ?? 3)
    )
  })

  const attentionItems: AttentionItem[] = []
  const attendanceState = attendanceToday.data
  if (attendanceState?.day_policy?.required && attendanceState.state === 'not_clocked_in') {
    attentionItems.push({
      key: 'attendance:today',
      title: 'Record attendance',
      description: 'Check in to start your workday.',
      href: '/hr/attendance',
      icon: <Clock3 className="size-4" aria-hidden="true" />,
      status: 'Today',
      tone: 'warning',
      weight: 0,
    })
  }
  if (todayReport?.status === 'rejected') {
    attentionItems.push({
      key: canonicalEntity('work_report', todayReport.id),
      title: 'Revise today’s work report',
      description: 'Review the feedback and resubmit your report.',
      href: '/dashboard/my-reports',
      icon: <FileText className="size-4" aria-hidden="true" />,
      status: 'Needs update',
      tone: 'danger',
      weight: 1,
    })
  } else if (
    todayReport?.status === 'draft' ||
    (!todayReport && reports.isSuccess && hasPermission(permissions, 'work_reports', 'create'))
  ) {
    attentionItems.push({
      key: todayReport ? canonicalEntity('work_report', todayReport.id) : 'work_report:today',
      title: todayReport ? 'Continue today’s work report' : 'Submit today’s work report',
      description: todayReport
        ? 'Finish the saved draft and submit it.'
        : 'Add a summary of today’s work.',
      href: '/dashboard/my-reports',
      icon: <FileText className="size-4" aria-hidden="true" />,
      status: todayReport ? 'Draft' : 'Due today',
      tone: 'warning',
      weight: 1,
    })
  }
  for (const task of sortedTasks) {
    const dueText = task.due_date
      ? task.due_date < today
        ? `Overdue · ${formatShortDate(task.due_date)}`
        : `Due ${formatShortDate(task.due_date)}`
      : task.project?.name || 'Assigned task'
    attentionItems.push({
      key: canonicalEntity('task', task.id),
      title: task.name,
      description: task.project?.name ? `${dueText} · ${task.project.name}` : dueText,
      href: '/dashboard/my-tasks',
      icon: <ClipboardCheck className="size-4" aria-hidden="true" />,
      status: task.status === 'in_progress' ? 'In progress' : task.priority,
      tone:
        task.due_date && task.due_date < today
          ? 'danger'
          : task.priority === 'high'
            ? 'warning'
            : task.status === 'in_progress'
              ? 'info'
              : 'neutral',
      weight: task.due_date && task.due_date < today ? 2 : task.priority === 'high' ? 3 : 4,
    })
  }
  const sortedAttentionItems = [...attentionItems]
    .sort((left, right) => left.weight - right.weight)
    .slice(0, 5)
  const excludedUpdateKeys = new Set(openTasks.map((task) => canonicalEntity('task', task.id)))
  for (const item of sortedAttentionItems) excludedUpdateKeys.add(item.key)

  const updates = buildUpdates({
    notifications: notifications.data?.items ?? [],
    tasks: [...personalTasks, ...(completedTasks.data?.items ?? [])],
    reports: workReports,
    leaveRequests: leaveRequests.data?.items ?? [],
    loans: loans.data?.items ?? [],
    excludedKeys: excludedUpdateKeys,
  })
  const updateQueries = [
    ...(canViewNotifications ? [notifications] : []),
    ...(canViewTasks ? [tasks] : []),
    ...(canViewTasks ? [completedTasks] : []),
    ...(canViewReports ? [reports] : []),
    ...(canViewLeaves ? [leaveRequests] : []),
    ...(canViewLoans ? [loans] : []),
  ]
  const updatesLoading = updateQueries.some((query) => query.isPending)
  const failedUpdateQueries = updateQueries.filter((query) => query.isError)
  const retryUpdates = () => {
    void Promise.all(failedUpdateQueries.map((query) => query.refetch()))
  }

  const attendanceSummary = canViewAttendance ? personal.data?.attendance : null
  const workReportSummary = canViewReports ? personal.data?.work_reports : null
  const hasPersonalMetrics = Boolean(attendanceSummary || workReportSummary)
  const performanceCardCount = (attendanceSummary ? 2 : 0) + (workReportSummary ? 1 : 0)
  const expectedPerformanceCardCount = (canViewAttendance ? 2 : 0) + (canViewReports ? 1 : 0)

  const companyPulse: {
    label: string
    value: number
    detail: string
    href: string
    icon: ReactNode
  }[] = []
  if (
    hasPermission(permissions, 'approval_requests', 'list') &&
    company.data?.pending_approvals != null
  ) {
    companyPulse.push({
      label: 'Pending approvals',
      value: company.data.pending_approvals,
      detail: 'Company governance queue',
      href: '/company/overview',
      icon: <ClipboardCheck className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'branches', 'list') && company.data?.total_branches != null) {
    companyPulse.push({
      label: 'Branches',
      value: company.data.total_branches,
      detail: 'In your organization scope',
      href: '/company/overview',
      icon: <GitBranch className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'assets', 'list') && company.data?.asset_count != null) {
    companyPulse.push({
      label: 'Tracked assets',
      value: company.data.asset_count,
      detail: 'Company inventory',
      href: '/company/overview',
      icon: <PackageSearch className="size-4" aria-hidden="true" />,
    })
  }
  if (
    hasPermission(permissions, 'departments', 'list') &&
    company.data?.departments_count != null
  ) {
    companyPulse.push({
      label: 'Departments',
      value: company.data.departments_count,
      detail: 'Organization structure',
      href: '/company/overview',
      icon: <Building2 className="size-4" aria-hidden="true" />,
    })
  }

  const hrPulse: typeof companyPulse = []
  if (hasPermission(permissions, 'leave_requests', 'list') && hr.data?.pending_leaves != null) {
    hrPulse.push({
      label: 'Pending leave requests',
      value: hr.data.pending_leaves,
      detail: 'Waiting for HR review',
      href: '/hr',
      icon: <CalendarCheck2 className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'job_postings', 'list') && hr.data?.open_roles != null) {
    hrPulse.push({
      label: 'Open roles',
      value: hr.data.open_roles,
      detail: 'Active recruitment',
      href: '/hr',
      icon: <BriefcaseBusiness className="size-4" aria-hidden="true" />,
    })
  }
  if (hasPermission(permissions, 'employees', 'list') && hr.data?.total_employees != null) {
    hrPulse.push({
      label: 'Active employees',
      value: hr.data.total_employees,
      detail: 'Within HR branch scope',
      href: '/hr',
      icon: <Users className="size-4" aria-hidden="true" />,
    })
  }

  const operationsPulse: typeof companyPulse = []
  if (
    !operations.data?.scope_limited &&
    hasPermission(permissions, 'projects', 'list') &&
    operations.data?.total_projects != null
  ) {
    operationsPulse.push({
      label: 'Projects',
      value: operations.data.total_projects,
      detail: 'Current operations portfolio',
      href: '/dashboard',
      icon: <Activity className="size-4" aria-hidden="true" />,
    })
  }
  if (
    !operations.data?.scope_limited &&
    hasPermission(permissions, 'worksites', 'list') &&
    operations.data?.total_worksites != null
  ) {
    operationsPulse.push({
      label: 'Worksites',
      value: operations.data.total_worksites,
      detail: 'Current operations footprint',
      href: '/dashboard',
      icon: <MapPinned className="size-4" aria-hidden="true" />,
    })
  }
  if (
    !operations.data?.scope_limited &&
    hasPermission(permissions, 'contracts', 'list') &&
    operations.data?.total_contracts != null
  ) {
    operationsPulse.push({
      label: 'Contracts',
      value: operations.data.total_contracts,
      detail: 'Current operations portfolio',
      href: '/dashboard',
      icon: <FileText className="size-4" aria-hidden="true" />,
    })
  }

  const pulseItems = [
    ...companyPulse.filter((item) => item.label === 'Pending approvals'),
    ...hrPulse.filter((item) => item.label === 'Pending leave requests'),
    ...companyPulse.filter((item) => item.label !== 'Pending approvals'),
    ...hrPulse.filter((item) => item.label !== 'Pending leave requests'),
    ...operationsPulse,
  ].slice(0, 3)
  const pulseQueries = [
    ...(companyEnabled ? [company] : []),
    ...(hrEnabled ? [hr] : []),
    ...(operationsEnabled ? [operations] : []),
  ]
  const pulseLoading = pulseQueries.some((query) => query.isPending)
  const pulseError = pulseQueries.some((query) => query.isError)
  const retryPulse = () => {
    void Promise.all(pulseQueries.filter((query) => query.isError).map((query) => query.refetch()))
  }

  const userInitials = initials(fullName || firstName)
  const todayDateLabel = new Intl.DateTimeFormat(undefined, {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  }).format(now)
  const attendanceLabel = !attendanceState
    ? 'Attendance status'
    : attendanceState.state === 'clocked_in'
      ? 'Clocked in'
      : attendanceState.state === 'clocked_out'
        ? 'Shift complete'
        : attendanceState.day_policy?.required
          ? 'Not recorded yet'
          : 'Not scheduled'
  const attendanceTone: DashboardTone = !attendanceState
    ? 'neutral'
    : attendanceState.state === 'clocked_out'
      ? 'success'
      : attendanceState.state === 'clocked_in'
        ? 'info'
        : attendanceState.day_policy?.required
          ? 'warning'
          : 'neutral'
  const taskSummary = tasks.data?.count ?? 0
  const reportStatus = todayReport
    ? todayReport.status === 'approved'
      ? 'Report approved'
      : todayReport.status === 'submitted'
        ? 'Report submitted'
        : todayReport.status === 'rejected'
          ? 'Update requested'
          : 'Draft in progress'
    : canViewReports && reports.isSuccess
      ? 'No report submitted'
      : 'Work report status'
  const reportTone: DashboardTone =
    todayReport?.status === 'approved'
      ? 'success'
      : todayReport?.status === 'submitted'
        ? 'info'
        : todayReport?.status === 'rejected'
          ? 'danger'
          : todayReport?.status === 'draft' || (reports.isSuccess && !todayReport)
            ? 'warning'
            : 'neutral'

  return (
    <PageLayout title="Overview">
      <div className="phone:space-y-7 space-y-6">
        <section className="dashboard-enter dashboard-hero rounded-surface shadow-elevation-md phone:px-6 phone:py-6 tablet:flex tablet:min-h-44 tablet:items-center tablet:justify-between tablet:gap-6 wide:px-8 relative isolate overflow-hidden px-4 py-5 text-white">
          <div
            className="pointer-events-none absolute -top-20 -right-12 -z-10 size-72 rounded-full border-[34px] border-white/10"
            aria-hidden="true"
          />
          <div
            className="pointer-events-none absolute right-36 -bottom-28 -z-10 size-56 rounded-full border border-white/10 bg-white/5"
            aria-hidden="true"
          />
          <div className="phone:gap-4 flex min-w-0 items-center gap-3">
            <span className="text-h3 phone:size-16 flex size-14 shrink-0 items-center justify-center rounded-2xl border border-white/25 bg-white/15 font-semibold shadow-lg shadow-blue-950/10">
              {userInitials || 'B'}
            </span>
            <div className="min-w-0">
              <p className="text-overline mb-1 tracking-wider text-white/75 uppercase">
                Personal workspace
              </p>
              <h1 className="text-h1 phone:text-display-md mt-1 font-semibold break-words text-white">
                {greeting(now)}, {fullName || firstName}
              </h1>
              <p className="text-body-md mt-1 truncate text-white/85">
                {department ? `${roleTitle} · ${department}` : roleTitle}
              </p>
            </div>
          </div>
          <div className="tablet:mt-0 tablet:ml-6 tablet:justify-end mt-5 flex min-w-0">
            <span className="text-body-sm rounded-pill inline-flex min-h-10 items-center gap-2 border border-white/20 bg-white/10 px-4 font-medium text-white">
              <CalendarDays className="size-4 shrink-0" aria-hidden="true" />
              {todayDateLabel}
            </span>
          </div>
        </section>

        <DashboardPanel
          title="Today"
          description="The essentials for your workday."
          icon={<CalendarDays className="size-5" aria-hidden="true" />}
        >
          <div className="phone:grid-cols-2 tablet:grid-cols-3 tablet:gap-4 grid min-w-0 grid-cols-1 gap-3">
            {canViewAttendance ? (
              <TodayCell
                icon={<Clock3 className="size-4" aria-hidden="true" />}
                label="Attendance"
                tone={attendanceTone}
                value={attendanceLabel}
                detail={
                  attendanceState?.clock_in
                    ? `Started ${new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' }).format(new Date(attendanceState.clock_in.timestamp))}`
                    : attendanceState?.day_policy?.label
                }
                href="/hr/attendance"
                loading={attendanceToday.isPending}
                error={attendanceToday.isError}
                onRetry={() => void attendanceToday.refetch()}
              />
            ) : null}
            {canViewTasks ? (
              <TodayCell
                icon={<ClipboardCheck className="size-4" aria-hidden="true" />}
                label="Tasks"
                tone={taskSummary > 0 ? 'primary' : 'neutral'}
                value={
                  tasks.data
                    ? `${taskSummary} active ${taskSummary === 1 ? 'task' : 'tasks'}`
                    : 'Task context'
                }
                detail={
                  sortedTasks[0] ? `Next: ${sortedTasks[0].name}` : 'No active tasks in your list'
                }
                href="/dashboard/my-tasks"
                loading={tasks.isPending}
                error={tasks.isError}
                onRetry={() => void tasks.refetch()}
              />
            ) : null}
            {canViewReports ? (
              <TodayCell
                icon={<FileText className="size-4" aria-hidden="true" />}
                label="Work report"
                tone={reportTone}
                className="phone:col-span-2 tablet:col-span-1"
                value={reportStatus}
                detail={todayReport ? formatShortDate(todayReport.day) : 'Today’s report'}
                href="/dashboard/my-reports"
                loading={reports.isPending}
                error={reports.isError}
                onRetry={() => void reports.refetch()}
              />
            ) : null}
            {!canViewAttendance && !canViewTasks && !canViewReports ? (
              <p className="text-body-sm text-text-secondary col-span-full px-4 py-5">
                Personal work summaries are not available for your current permissions.
              </p>
            ) : null}
          </div>
        </DashboardPanel>

        <div className="space-y-6">
          <DashboardPanel
            title="Needs your attention"
            description="A short list of items that may need your next step."
            icon={<Activity className="size-5" aria-hidden="true" />}
            action={
              canViewTasks ? (
                <Link
                  to="/dashboard/my-tasks"
                  className="text-caption text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-1 px-2 font-semibold focus-visible:outline-none"
                >
                  My tasks <ArrowRight className="size-4" aria-hidden="true" />
                </Link>
              ) : canViewReports ? (
                <Link
                  to="/dashboard/my-reports"
                  className="text-caption text-primary focus-visible:shadow-focus-ring rounded-control inline-flex min-h-10 items-center gap-1 px-2 font-semibold focus-visible:outline-none"
                >
                  My reports <ArrowRight className="size-4" aria-hidden="true" />
                </Link>
              ) : null
            }
          >
            <DashboardPanelCard>
              {(attendanceToday.isPending && canViewAttendance) ||
              (tasks.isPending && canViewTasks) ||
              (reports.isPending && canViewReports) ? (
                <DashboardLoadingRows count={3} />
              ) : attendanceToday.isError || tasks.isError || reports.isError ? (
                <div className="space-y-3">
                  <SectionErrorState
                    description="Some personal action items could not be checked. Retry the unavailable source above."
                    onRetry={() => {
                      if (attendanceToday.isError) void attendanceToday.refetch()
                      if (tasks.isError) void tasks.refetch()
                      if (reports.isError) void reports.refetch()
                    }}
                  />
                  {sortedAttentionItems.length ? (
                    <ul className="divide-border-subtle divide-y">
                      {sortedAttentionItems.map((item) => (
                        <DashboardListRow
                          key={item.key}
                          icon={item.icon}
                          tone={item.tone}
                          title={item.title}
                          description={item.description}
                          trailing={item.status}
                          trailingTone={item.tone}
                          href={item.href}
                        />
                      ))}
                    </ul>
                  ) : null}
                </div>
              ) : sortedAttentionItems.length ? (
                <ul className="divide-border-subtle divide-y">
                  {sortedAttentionItems.map((item, index) => (
                    <DashboardListRow
                      key={item.key}
                      className="dashboard-enter"
                      style={{ animationDelay: `${index * 45}ms` }}
                      icon={item.icon}
                      tone={item.tone}
                      title={item.title}
                      description={item.description}
                      trailing={item.status}
                      trailingTone={item.tone}
                      href={item.href}
                    />
                  ))}
                </ul>
              ) : (
                <DashboardEmptyMessage
                  title="Nothing needs your attention"
                  description="Your personal tasks and daily work are up to date."
                />
              )}
            </DashboardPanelCard>
          </DashboardPanel>

          <DashboardPanel
            title="Performance overview"
            description="Attendance, work reports, and punctuality this month."
            icon={<Activity className="size-5" aria-hidden="true" />}
            action={
              <span className="bg-primary-subtle text-primary rounded-pill text-caption phone:inline-flex hidden px-3 py-1.5 font-medium">
                Month to date
              </span>
            }
          >
            {personal.isPending && personalEnabled ? (
              <DashboardPanelCard>
                <div
                  className={cn(
                    'grid min-w-0 gap-4',
                    performanceGridClass(expectedPerformanceCardCount),
                  )}
                  aria-label="Loading performance overview"
                  role="status"
                >
                  {Array.from({ length: expectedPerformanceCardCount }, (_, index) => (
                    <div
                      key={index}
                      className="rounded-surface border-border-subtle bg-surface-muted/70 space-y-4 border p-4"
                    >
                      <Skeleton className="h-4 w-2/3" />
                      <Skeleton className="h-24 w-full" />
                      <Skeleton className="h-3 w-full" />
                      <Skeleton className="h-3 w-4/5" />
                    </div>
                  ))}
                </div>
              </DashboardPanelCard>
            ) : personal.isError ? (
              <DashboardPanelCard>
                <SectionErrorState
                  description="Monthly progress could not be loaded. Your other dashboard sections remain available."
                  onRetry={() => void personal.refetch()}
                />
              </DashboardPanelCard>
            ) : hasPersonalMetrics ? (
              <DashboardPanelCard className="tablet:p-5">
                <div
                  className={cn('grid min-w-0 gap-4', performanceGridClass(performanceCardCount))}
                >
                  {attendanceSummary ? (
                    <DashboardRingMetricCard
                      title="Attendance"
                      scoreLabel="Attendance rate"
                      score={attendanceSummary.attendance_rate_percent}
                      tone="primary"
                      detail={
                        attendanceSummary.required_workdays
                          ? `${attendanceSummary.attended_workdays} of ${attendanceSummary.required_workdays} required days`
                          : 'No required days yet'
                      }
                    />
                  ) : null}
                  {workReportSummary ? (
                    <DashboardScoreBreakdownCard
                      title="Work reports"
                      icon={<FileText className="size-4" aria-hidden="true" />}
                      tone="info"
                      score={workReportSummary.score_percent}
                      stats={[
                        {
                          label: 'Submitted',
                          value: workReportSummary.reports_submitted,
                          icon: <FileText className="size-4" aria-hidden="true" />,
                          tone: 'info',
                        },
                        {
                          label: 'Approved',
                          value: workReportSummary.approved_reports,
                          icon: <CheckCheck className="size-4" aria-hidden="true" />,
                          tone: 'success',
                        },
                        {
                          label: 'Average rating',
                          value:
                            workReportSummary.average_rating === null
                              ? '—'
                              : `${workReportSummary.average_rating.toFixed(1)} / 5`,
                          icon: <Activity className="size-4" aria-hidden="true" />,
                          tone: 'warning',
                        },
                      ]}
                    />
                  ) : null}
                  {attendanceSummary ? (
                    <DashboardScoreBreakdownCard
                      title="Punctuality"
                      icon={<Clock3 className="size-4" aria-hidden="true" />}
                      tone="success"
                      score={attendanceSummary.punctuality_rate_percent}
                      stats={[
                        {
                          label: 'Required days',
                          value: attendanceSummary.required_workdays,
                          icon: <CalendarDays className="size-4" aria-hidden="true" />,
                          tone: 'info',
                        },
                        {
                          label: 'On time',
                          value: attendanceSummary.on_time_arrivals,
                          icon: <CheckCheck className="size-4" aria-hidden="true" />,
                          tone: 'success',
                        },
                        {
                          label: 'Late',
                          value: attendanceSummary.late_arrivals,
                          icon: <Clock3 className="size-4" aria-hidden="true" />,
                          tone: 'warning',
                        },
                        {
                          label: 'Absent',
                          value: Math.max(
                            0,
                            attendanceSummary.required_workdays -
                              attendanceSummary.attended_workdays,
                          ),
                          icon: <CircleX className="size-4" aria-hidden="true" />,
                          tone: 'danger',
                        },
                      ]}
                    />
                  ) : null}
                </div>
              </DashboardPanelCard>
            ) : (
              <DashboardPanelCard>
                <DashboardEmptyMessage
                  title="No progress summary available"
                  description="Personal attendance and report progress appears here when your role can view it."
                />
              </DashboardPanelCard>
            )}
          </DashboardPanel>
        </div>

        <div className="tablet:grid-cols-2 grid min-w-0 gap-6">
          <DashboardPanel
            title="Recent updates"
            description="Recent events from your notifications and personal work."
            icon={<Bell className="size-5" aria-hidden="true" />}
            action={
              failedUpdateQueries.length ? (
                <Button variant="ghost" size="sm" onClick={retryUpdates}>
                  Retry missing data
                </Button>
              ) : null
            }
          >
            <DashboardPanelCard>
              {updatesLoading && !updates.length ? (
                <DashboardLoadingRows count={4} />
              ) : updates.length ? (
                <>
                  {failedUpdateQueries.length ? (
                    <p className="text-caption text-warning-strong mb-2" role="status">
                      Some update sources could not be loaded.
                    </p>
                  ) : null}
                  <ul className="divide-border-subtle divide-y">
                    {updates.map((item, index) => (
                      <DashboardListRow
                        key={item.key}
                        className="dashboard-enter"
                        style={{ animationDelay: `${index * 40}ms` }}
                        icon={item.icon}
                        title={item.title}
                        description={item.description}
                        trailing={relativeTime(item.date)}
                        href={item.href}
                      />
                    ))}
                  </ul>
                </>
              ) : failedUpdateQueries.length ? (
                <SectionErrorState
                  description="Recent updates could not be loaded. Your other dashboard sections remain available."
                  onRetry={retryUpdates}
                />
              ) : (
                <DashboardEmptyMessage
                  title="No recent updates"
                  description="New activity on your tasks, reports, leave, loans, and notifications will appear here."
                />
              )}
            </DashboardPanelCard>
          </DashboardPanel>

          <PulseSection
            enabled={pulseEnabled}
            loading={pulseLoading}
            error={pulseError}
            items={pulseItems}
            onRetry={retryPulse}
          />
        </div>
      </div>
    </PageLayout>
  )
}
