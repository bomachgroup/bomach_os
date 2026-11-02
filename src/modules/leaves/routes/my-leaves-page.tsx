import { useState, type ReactNode } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { Link, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import {
  CalendarDays,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  CircleHelp,
  CircleX,
  Clock3,
  FileClock,
  FilePlus2,
  RotateCcw,
  ShieldAlert,
  Trash2,
  type LucideIcon,
} from 'lucide-react'

import { hrOverviewQueryKey } from '@/modules/hr/hr-dashboard.api'
import { personalOverviewQueryKey } from '@/modules/dashboard/dashboard.api'
import { presentError } from '@/shared/errors'
import { personalWorkQueryKeys } from '@/modules/dashboard/personal-work.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton, SummaryUnavailable } from '@/shared/ui/feedback-states'
import { PageLayout } from '@/shared/ui/page-layout'
import { PageBackLinkContent, pageBackLinkClassName } from '@/shared/ui/page-back-link'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'
import { useToast } from '@/shared/feedback/use-toast'

import { LeaveRequestFormDialog } from '../components/leave-request-form-dialog'
import {
  leaveRequestsApi,
  type LeaveRequest,
  type LeaveRequestInput,
  type LeaveRequestKindFilter,
  type LeaveRequestStatus,
  type LeaveRequestStatusFilter,
} from '../leaves.api'
import {
  leaveRequestDetailQueryOptions,
  leaveRequestListQueryOptions,
  leaveRequestStatsQueryOptions,
  leaveRequestsQueryKeys,
} from '../leaves.queries'
import type { MyLeavesSearch } from '../leaves.search'

const PAGE_SIZE = 10
const desktopGrid =
  'desktop:grid-cols-[minmax(9rem,1fr)_minmax(9rem,1.15fr)_minmax(10rem,1.4fr)_minmax(7rem,.75fr)_minmax(7.5rem,.85fr)]'

function formatDate(value: string): string {
  const [year, month, day] = value.split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function dateRange(request: LeaveRequest): string {
  if (request.requestKind === 'running_late') return formatDate(request.startDate)
  if (request.startDate === request.endDate) return formatDate(request.startDate)
  return `${formatDate(request.startDate)} – ${formatDate(request.endDate)}`
}

function requestType(request: Pick<LeaveRequest, 'requestKind' | 'leaveType'>): string {
  if (request.requestKind === 'running_late') return 'Late arrival'
  if (request.requestKind === 'absence') return 'Absence'
  const labels: Record<string, string> = {
    annual_leave: 'Annual leave',
    sick_leave: 'Sick leave',
    casual_leave: 'Casual leave',
    maternity_leave: 'Maternity leave',
    paternity_leave: 'Paternity leave',
    unpaid_leave: 'Unpaid leave',
    compassionate_leave: 'Compassionate leave',
  }
  return labels[request.leaveType] ?? 'Leave'
}

function statusPresentation(status: string): {
  label: string
  tone: StatusTone
  icon: LucideIcon
  detail: string
} {
  switch (status) {
    case 'pending':
      return {
        label: 'In review',
        tone: 'info',
        icon: Clock3,
        detail: 'Your request is waiting for a decision.',
      }
    case 'approved':
      return {
        label: 'Approved',
        tone: 'success',
        icon: CheckCircle2,
        detail: 'This request has been approved.',
      }
    case 'rejected':
      return {
        label: 'Needs attention',
        tone: 'danger',
        icon: ShieldAlert,
        detail: 'Review the feedback. You can submit a corrected request as a new record.',
      }
    case 'cancelled':
      return {
        label: 'Cancelled',
        tone: 'neutral',
        icon: CircleX,
        detail: 'This request was cancelled.',
      }
    default:
      return {
        label: status.replaceAll('_', ' '),
        tone: 'neutral',
        icon: CircleHelp,
        detail: 'Request status.',
      }
  }
}

const requestKindTabs: { value: LeaveRequestKindFilter; label: string }[] = [
  { value: 'all', label: 'All requests' },
  { value: 'leave', label: 'Leave' },
  { value: 'attendance_exception', label: 'Attendance' },
]

const statusTabs: {
  value: LeaveRequestStatusFilter
  label: string
  icon: LucideIcon
  accent: string
  countKey: 'pending' | 'approved' | 'rejected' | 'cancelled' | null
}[] = [
  { value: 'all', label: 'All statuses', icon: FileClock, accent: 'text-primary', countKey: null },
  {
    value: 'pending',
    label: 'In review',
    icon: Clock3,
    accent: 'text-info-foreground',
    countKey: 'pending',
  },
  {
    value: 'approved',
    label: 'Approved',
    icon: CheckCircle2,
    accent: 'text-success-foreground',
    countKey: 'approved',
  },
  {
    value: 'rejected',
    label: 'Rejected',
    icon: ShieldAlert,
    accent: 'text-danger-foreground',
    countKey: 'rejected',
  },
  {
    value: 'cancelled',
    label: 'Cancelled',
    icon: CircleX,
    accent: 'text-text-muted',
    countKey: 'cancelled',
  },
]

function SummaryMetric({
  label,
  value,
  icon: Icon,
  tone,
  onClick,
}: {
  label: string
  value: number
  icon: LucideIcon
  tone: string
  onClick?: () => void
}) {
  const content = (
    <>
      <span
        className={`bg-surface-muted rounded-control tablet:size-10 flex size-9 shrink-0 items-center justify-center ${tone}`}
      >
        <Icon className="tablet:size-5 size-4.5" aria-hidden="true" />
      </span>
      <div className="min-w-0">
        <p className="text-h3 text-text-primary leading-none font-semibold tabular-nums">{value}</p>
        <p className="text-caption text-text-secondary truncate">{label}</p>
      </div>
    </>
  )
  const className =
    'border-border-subtle bg-surface rounded-control tablet:gap-3 tablet:p-3.5 flex min-w-0 items-center gap-2.5 border p-3 text-left'

  return onClick ? (
    <button
      type="button"
      onClick={onClick}
      aria-label={`${label}: ${value}`}
      className={`${className} hover:border-primary/40 hover:bg-primary-subtle/20 focus-visible:shadow-focus-ring focus-visible:outline-none`}
    >
      {content}
    </button>
  ) : (
    <div className={className}>{content}</div>
  )
}

function RequestStatus({ status }: { status: LeaveRequestStatus }) {
  const presentation = statusPresentation(status)
  const Icon = presentation.icon
  return (
    <StatusChip
      label={presentation.label}
      tone={presentation.tone}
      dense
      icon={<Icon className="size-3" />}
    />
  )
}

function RequestRowContent({ request, canView }: { request: LeaveRequest; canView: boolean }) {
  const TypeIcon = request.requestKind === 'running_late' ? Clock3 : CalendarDays

  return (
    <>
      <div className="desktop:block flex min-w-0 items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-body-sm text-text-primary font-medium">{dateRange(request)}</p>
          <p className="text-caption text-text-muted mt-1">
            Submitted {formatDate(request.createdAt.slice(0, 10))}
          </p>
        </div>
        <span className="desktop:hidden">
          <RequestStatus status={request.status} />
        </span>
      </div>
      <div className="flex min-w-0 items-start gap-2.5">
        <span className="bg-primary-subtle text-primary rounded-control desktop:hidden flex size-8 shrink-0 items-center justify-center">
          <TypeIcon className="size-4" aria-hidden="true" />
        </span>
        <div className="min-w-0">
          <p className="text-label text-text-primary font-semibold">{requestType(request)}</p>
          <p className="desktop:hidden text-body-sm text-text-secondary mt-1 line-clamp-2">
            {request.reason}
          </p>
        </div>
      </div>
      <p className="text-body-sm text-text-secondary desktop:block hidden truncate">
        {request.reason}
      </p>
      <p className="text-body-sm text-text-secondary desktop:block hidden">
        {request.requestKind === 'running_late'
          ? 'Today'
          : `${request.durationDays} calendar ${request.durationDays === 1 ? 'day' : 'days'}`}
      </p>
      <div className="desktop:block hidden">
        <RequestStatus status={request.status} />
      </div>
      <div className="desktop:hidden border-border-subtle flex items-center justify-between gap-3 border-t pt-3">
        <p className="text-caption text-text-secondary">
          {request.requestKind === 'running_late'
            ? 'Today'
            : `${request.durationDays} calendar ${request.durationDays === 1 ? 'day' : 'days'}`}
        </p>
        <span
          className={`text-caption font-semibold ${canView ? 'text-primary' : 'text-text-muted'}`}
        >
          {canView ? 'View details' : 'Details unavailable'}
          {canView ? <ChevronRight className="ml-1 inline size-4" aria-hidden="true" /> : null}
        </span>
      </div>
    </>
  )
}

function MyLeavesList() {
  const search = useSearch({ from: '/_protected/hr/leaves' }) as MyLeavesSearch
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const employeePk = session?.employee.id
  const permissions = session?.permissions ?? {}
  const canRead =
    hasPermission(permissions, 'leave_requests', 'list_own') ||
    hasPermission(permissions, 'leave_requests', 'list')
  const canViewRequest =
    hasPermission(permissions, 'leave_requests', 'view_own') ||
    hasPermission(permissions, 'leave_requests', 'view')
  const canReadStats = canViewRequest
  const canCreate = hasPermission(permissions, 'leave_requests', 'create')
  const listParams = {
    employeeId: employeePk ?? 0,
    kind: search.kind,
    status: search.status,
    limit: PAGE_SIZE,
    offset: (search.page - 1) * PAGE_SIZE,
  } as const
  const listQuery = useQuery({
    ...leaveRequestListQueryOptions(userId, employeeId, listParams),
    enabled: Boolean(session && canRead && employeePk),
  })
  const statsQuery = useQuery({
    ...leaveRequestStatsQueryOptions(userId, employeeId, employeePk ?? 0),
    enabled: Boolean(session && canRead && canReadStats && employeePk),
  })
  const createMutation = useMutation({ mutationFn: leaveRequestsApi.create })
  const [formOpen, setFormOpen] = useState(false)

  function updateSearch(updates: Partial<MyLeavesSearch>) {
    void navigate({
      to: '/hr/leaves',
      search: (previous: MyLeavesSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  }

  async function invalidateAfterChange() {
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: leaveRequestsQueryKeys.scoped(userId, employeeId),
      }),
      queryClient.invalidateQueries({
        queryKey: personalWorkQueryKeys.leaveRequests(userId, employeeId),
      }),
      queryClient.invalidateQueries({ queryKey: personalOverviewQueryKey(userId, employeeId) }),
      queryClient.invalidateQueries({ queryKey: hrOverviewQueryKey(userId, employeeId) }),
    ])
  }

  async function saveNewRequest(input: LeaveRequestInput) {
    const created = await createMutation.mutateAsync(input)
    queryClient.setQueryData(leaveRequestsQueryKeys.detail(userId, employeeId, created.id), created)
    await invalidateAfterChange()
    toast.showToast({
      title: 'Request submitted',
      description: 'Your request has been sent for review.',
      tone: 'success',
    })
    setFormOpen(false)
    await navigate({
      to: '/hr/leaves/$requestId',
      params: { requestId: String(created.id) },
      search,
    })
  }

  const total = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(total / PAGE_SIZE))
  const stats = statsQuery.data
  const requests = listQuery.data?.items ?? []
  const statusFilterOptions = statusTabs.map((tab) => {
    const Icon = tab.icon
    const count = tab.countKey ? stats?.[tab.countKey] : stats?.total
    return {
      value: tab.value,
      label: count === undefined ? tab.label : `${tab.label} · ${count}`,
      icon: <Icon className="size-4" aria-hidden="true" />,
      iconClassName: tab.accent,
    }
  })

  if (sessionQuery.isPending) {
    return (
      <PageLayout title="My Leaves" subtitle="Manage your leave and attendance requests.">
        <Card className="space-y-4" aria-label="Loading leave requests" aria-busy="true">
          <Skeleton variant="title" />
          {Array.from({ length: 4 }, (_, index) => (
            <Skeleton key={index} variant="row" />
          ))}
        </Card>
      </PageLayout>
    )
  }

  if (sessionQuery.isError || !session) {
    return (
      <PageLayout title="My Leaves" subtitle="Manage your leave and attendance requests.">
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )
  }

  if (!canRead) {
    return (
      <PageLayout title="My Leaves" subtitle="Manage your leave and attendance requests.">
        <Card>
          <ErrorState
            title="You can’t view these requests"
            description="Your account does not have access to your personal leave requests."
          />
        </Card>
      </PageLayout>
    )
  }

  if (!employeePk) {
    return (
      <PageLayout title="My Leaves" subtitle="Manage your leave and attendance requests.">
        <Card>
          <ErrorState
            title="Employee profile needs attention"
            description="Your employee record is missing its internal identifier, so requests cannot be safely scoped to you."
          />
        </Card>
      </PageLayout>
    )
  }

  return (
    <PageLayout
      title="My Leaves"
      subtitle="Manage your leave and attendance requests."
      leading={<CalendarDays className="size-[18px]" aria-hidden="true" />}
      actionsInline
      actions={
        canCreate ? (
          <Button
            aria-label="New leave request"
            size="sm"
            className="text-caption tablet:min-h-11 tablet:px-4 tablet:py-2 tablet:text-label min-h-10 max-w-full px-3 max-[479px]:min-h-9 max-[479px]:px-3"
            onClick={() => setFormOpen(true)}
            leadingIcon={<FilePlus2 className="size-4" />}
          >
            <span className="max-[479px]:hidden">New request</span>
            <span className="hidden max-[479px]:inline max-[361px]:hidden">New</span>
          </Button>
        ) : undefined
      }
      contentClassName="space-y-5"
    >
      <section aria-labelledby="leave-summary-heading" className="space-y-3">
        <div className="flex flex-wrap items-end justify-between gap-3">
          <div>
            <h2 id="leave-summary-heading" className="text-h3 text-text-primary font-semibold">
              Request overview
            </h2>
            <p className="text-body-sm text-text-secondary mt-1">
              Your submitted requests and current review status.
            </p>
          </div>
        </div>
        {!canReadStats ? (
          <Card>
            <p className="text-body-sm text-text-secondary">
              Your account can view request history but cannot view request summary counts.
            </p>
          </Card>
        ) : null}
        {canReadStats && statsQuery.isPending ? (
          <div
            className="tablet:gap-3 desktop:grid-cols-4 grid grid-cols-2 gap-2.5"
            aria-label="Loading request summary"
            aria-busy="true"
          >
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} className="h-20" />
            ))}
          </div>
        ) : canReadStats && statsQuery.isError && !stats ? (
          <SummaryUnavailable onRetry={() => void statsQuery.refetch()} />
        ) : canReadStats && stats ? (
          <div className="tablet:gap-3 desktop:grid-cols-4 grid grid-cols-2 gap-2.5">
            <SummaryMetric
              label="Total requests"
              value={stats.total}
              icon={FileClock}
              tone="text-primary"
            />
            <SummaryMetric
              label="In review"
              value={stats.pending}
              icon={Clock3}
              tone="text-info-foreground"
            />
            <SummaryMetric
              label="Approved"
              value={stats.approved}
              icon={CheckCircle2}
              tone="text-success-foreground"
            />
            <SummaryMetric
              label="Needs attention"
              value={stats.rejected}
              icon={ShieldAlert}
              tone="text-danger-foreground"
              onClick={() => updateSearch({ status: 'rejected', page: 1 })}
            />
          </div>
        ) : null}
      </section>

      <section aria-labelledby="my-leaves-history-heading" className="space-y-3">
        <div className="tablet:flex-row tablet:items-end tablet:justify-between flex flex-col gap-2">
          <div>
            <h2 id="my-leaves-history-heading" className="text-h3 text-text-primary font-semibold">
              Request history
            </h2>
            <p className="text-body-sm text-text-secondary mt-1">
              {canViewRequest
                ? 'Open a request to review its details and available actions.'
                : 'Your account can view request history, but it cannot open request details.'}
            </p>
          </div>
          <p className="text-caption text-text-secondary shrink-0" aria-live="polite">
            {listQuery.isPending && !listQuery.data
              ? 'Loading requests'
              : `${total} ${total === 1 ? 'request' : 'requests'}`}
          </p>
        </div>
        <div className="rounded-control border-border-subtle bg-surface shadow-elevation-sm tablet:p-4 border p-3">
          <div className="desktop:grid desktop:grid-cols-[minmax(0,1fr)_17rem] desktop:items-end flex flex-col gap-3.5">
            <div className="min-w-0 space-y-2">
              <p className="text-caption text-text-secondary font-semibold">Request type</p>
              <div
                role="group"
                aria-label="Filter requests by type"
                className="bg-surface-muted rounded-control p-1"
              >
                <div className="grid grid-cols-3 gap-1">
                  {requestKindTabs.map((tab) => (
                    <button
                      key={tab.value}
                      type="button"
                      aria-pressed={search.kind === tab.value}
                      onClick={() => updateSearch({ kind: tab.value, page: 1 })}
                      className={`focus-visible:shadow-focus-ring text-caption rounded-control min-h-10 min-w-0 px-2 py-2 font-medium whitespace-nowrap focus-visible:outline-none motion-safe:transition-colors motion-safe:duration-150 ${search.kind === tab.value ? 'bg-surface text-text-primary shadow-elevation-sm ring-border-subtle ring-1' : 'text-text-secondary hover:bg-surface/75 hover:text-text-primary'}`}
                    >
                      {tab.value === 'all' ? (
                        <>
                          <span className="tablet:hidden">All</span>
                          <span className="tablet:inline hidden">All requests</span>
                        </>
                      ) : (
                        tab.label
                      )}
                    </button>
                  ))}
                </div>
              </div>
            </div>
            <DropdownSelect
              id="leave-status-filter"
              label="Filter by status"
              value={search.status}
              options={statusFilterOptions}
              onChange={(status) =>
                updateSearch({ status: status as LeaveRequestStatusFilter, page: 1 })
              }
            />
          </div>
        </div>

        {listQuery.isError && listQuery.data ? (
          <Alert tone="warning" title="Showing saved requests">
            <div className="flex flex-wrap items-center justify-between gap-3">
              <span>
                The latest refresh failed. You can continue with the requests already loaded.
              </span>
              <Button variant="outline" size="sm" onClick={() => void listQuery.refetch()}>
                Retry refresh
              </Button>
            </div>
          </Alert>
        ) : null}

        {listQuery.isPending ? (
          <Card className="space-y-3" aria-label="Loading requests" aria-busy="true">
            {Array.from({ length: 4 }, (_, index) => (
              <Skeleton key={index} variant="row" />
            ))}
          </Card>
        ) : listQuery.isError && !listQuery.data ? (
          <Card>
            <ErrorState
              title="Requests could not load"
              description="Your request history is available to retry."
              error={listQuery.error}
              action={
                <Button variant="outline" onClick={() => void listQuery.refetch()}>
                  Try again
                </Button>
              }
            />
          </Card>
        ) : requests.length === 0 ? (
          <Card>
            <EmptyState
              title={
                search.status === 'all' && search.kind === 'all'
                  ? 'No requests yet'
                  : 'No requests match these filters'
              }
              description={
                search.status === 'all' && search.kind === 'all'
                  ? 'Your leave and attendance requests will appear here.'
                  : 'Change the selected filters to see more requests.'
              }
              icon={<CalendarDays className="size-6" />}
              action={
                search.status !== 'all' || search.kind !== 'all' ? (
                  <Button
                    variant="outline"
                    onClick={() => updateSearch({ kind: 'all', status: 'all', page: 1 })}
                  >
                    Clear filters
                  </Button>
                ) : canCreate ? (
                  <Button
                    onClick={() => setFormOpen(true)}
                    leadingIcon={<FilePlus2 className="size-4" />}
                  >
                    New request
                  </Button>
                ) : undefined
              }
            />
          </Card>
        ) : (
          <Card className="desktop:p-0 overflow-hidden p-2">
            <div
              className={`bg-surface-muted text-caption text-text-secondary border-border-subtle desktop:grid desktop:px-5 hidden gap-3 border-b px-4 py-3 font-semibold ${desktopGrid}`}
            >
              <span>Date</span>
              <span>Request</span>
              <span>Reason</span>
              <span>Duration</span>
              <span>Status</span>
            </div>
            <div className="desktop:divide-border-subtle desktop:space-y-0 desktop:divide-y space-y-2">
              {requests.map((request) => {
                const className = `border-border-subtle bg-surface focus-visible:shadow-focus-ring text-text-primary hover:bg-surface-muted/70 rounded-control grid gap-3 border px-3.5 py-3.5 focus-visible:outline-none desktop:items-center desktop:gap-3 desktop:rounded-none desktop:border-0 desktop:bg-transparent desktop:px-5 desktop:py-4 ${desktopGrid}`
                return canViewRequest ? (
                  <Link
                    key={request.id}
                    to="/hr/leaves/$requestId"
                    params={{ requestId: String(request.id) }}
                    search={search}
                    className={className}
                  >
                    <RequestRowContent request={request} canView />
                  </Link>
                ) : (
                  <div key={request.id} className={className}>
                    <RequestRowContent request={request} canView={false} />
                  </div>
                )
              })}
            </div>
            <Pagination
              page={search.page}
              pageCount={pageCount}
              total={total}
              onPage={(page) => updateSearch({ page })}
            />
          </Card>
        )}
      </section>

      <LeaveRequestFormDialog
        open={formOpen}
        onOpenChange={setFormOpen}
        title="New leave or attendance request"
        onSave={saveNewRequest}
        saving={createMutation.isPending}
      />
    </PageLayout>
  )
}

function Pagination({
  page,
  pageCount,
  total,
  onPage,
}: {
  page: number
  pageCount: number
  total: number
  onPage: (page: number) => void
}) {
  return (
    <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
      <p className="text-caption text-text-secondary" aria-live="polite">
        Page {page} of {pageCount} · {total} total
      </p>
      <div className="flex items-center gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => onPage(page - 1)}>
          <ChevronLeft className="size-4" />
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          disabled={page >= pageCount}
          onClick={() => onPage(page + 1)}
        >
          Next
          <ChevronRight className="size-4" />
        </Button>
      </div>
    </div>
  )
}

export function MyLeavesPage() {
  return <MyLeavesList />
}

function DetailFact({
  label,
  value,
  icon: Icon,
}: {
  label: string
  value: ReactNode
  icon: LucideIcon
}) {
  return (
    <div className="bg-surface-muted/70 rounded-control border-border-subtle tablet:p-4 min-w-0 border p-3">
      <div className="text-text-secondary flex items-center gap-2">
        <Icon className="text-primary tablet:size-4 size-3.5 shrink-0" aria-hidden="true" />
        <p className="text-caption min-w-0 truncate font-medium">{label}</p>
      </div>
      <div className="text-body-sm text-text-primary tablet:text-body-md mt-2 font-semibold break-words">
        {value}
      </div>
    </div>
  )
}

export function LeaveRequestDetailPage() {
  const params = useParams({ strict: false }) as { requestId?: string }
  const search = useSearch({ strict: false }) as MyLeavesSearch
  const requestId = Number(params.requestId)
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const toast = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const permissions = session?.permissions ?? {}
  const canView =
    hasPermission(permissions, 'leave_requests', 'view_own') ||
    hasPermission(permissions, 'leave_requests', 'view')
  const canCreate = hasPermission(permissions, 'leave_requests', 'create')
  const canUpdate =
    hasPermission(permissions, 'leave_requests', 'update_own') ||
    hasPermission(permissions, 'leave_requests', 'update')
  const canDelete =
    hasPermission(permissions, 'leave_requests', 'delete_own') ||
    hasPermission(permissions, 'leave_requests', 'delete')
  const requestQuery = useQuery({
    ...leaveRequestDetailQueryOptions(userId, employeeId, requestId),
    enabled: Boolean(session && canView && Number.isSafeInteger(requestId) && requestId > 0),
  })
  const [formConfig, setFormConfig] = useState<{
    mode: 'create' | 'edit'
    request?: LeaveRequest | null
  } | null>(null)
  const [confirmCancel, setConfirmCancel] = useState(false)
  const [actionError, setActionError] = useState<string | null>(null)
  const updateMutation = useMutation({
    mutationFn: ({ id, input }: { id: number; input: Partial<LeaveRequestInput> }) =>
      leaveRequestsApi.update(id, input),
  })
  const createMutation = useMutation({ mutationFn: leaveRequestsApi.create })
  const cancelMutation = useMutation({ mutationFn: leaveRequestsApi.cancel })
  const request = requestQuery.data

  async function invalidateAfterChange() {
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: leaveRequestsQueryKeys.scoped(userId, employeeId),
      }),
      queryClient.invalidateQueries({
        queryKey: personalWorkQueryKeys.leaveRequests(userId, employeeId),
      }),
      queryClient.invalidateQueries({ queryKey: personalOverviewQueryKey(userId, employeeId) }),
      queryClient.invalidateQueries({ queryKey: hrOverviewQueryKey(userId, employeeId) }),
    ])
  }

  async function saveRequest(input: LeaveRequestInput) {
    setActionError(null)
    if (formConfig?.mode === 'edit' && request) {
      const updated = await updateMutation.mutateAsync({
        id: request.id,
        input:
          request.requestKind === 'running_late'
            ? { reason: input.reason }
            : {
                leave_type: input.leave_type,
                start_date: input.start_date,
                end_date: input.end_date,
                reason: input.reason,
              },
      })
      queryClient.setQueryData(
        leaveRequestsQueryKeys.detail(userId, employeeId, updated.id),
        updated,
      )
      await invalidateAfterChange()
      toast.showToast({
        title: 'Request updated',
        description: 'Your pending request has been updated.',
        tone: 'success',
      })
      setFormConfig(null)
      return
    }
    const created = await createMutation.mutateAsync(input)
    queryClient.setQueryData(leaveRequestsQueryKeys.detail(userId, employeeId, created.id), created)
    await invalidateAfterChange()
    toast.showToast({
      title: 'New request submitted',
      description: 'Your corrected request has been sent for review.',
      tone: 'success',
    })
    setFormConfig(null)
    await navigate({
      to: '/hr/leaves/$requestId',
      params: { requestId: String(created.id) },
      search,
    })
  }

  async function cancelRequest() {
    if (!request) return
    setActionError(null)
    try {
      await cancelMutation.mutateAsync(request.id)
      queryClient.setQueryData(leaveRequestsQueryKeys.detail(userId, employeeId, request.id), {
        ...request,
        status: 'cancelled',
        updatedAt: new Date().toISOString(),
      })
      await invalidateAfterChange()
      toast.showToast({
        title: 'Request cancelled',
        description: 'The pending request has been cancelled.',
        tone: 'success',
      })
      setConfirmCancel(false)
    } catch (error) {
      setActionError(presentError(error, 'form-submit').message)
    }
  }

  if (sessionQuery.isPending) {
    return (
      <PageLayout title="Request details" subtitle="Loading your request.">
        <Card aria-label="Loading request" aria-busy="true" className="space-y-3">
          <Skeleton variant="title" />
          <Skeleton variant="row" />
          <Skeleton variant="row" />
        </Card>
      </PageLayout>
    )
  }
  if (sessionQuery.isError || !session) {
    return (
      <PageLayout title="Request details" subtitle="Your leave and attendance request.">
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )
  }
  if (!canView) {
    return (
      <PageLayout title="Request details" subtitle="Your leave and attendance request.">
        <Card>
          <ErrorState
            title="You can’t view this request"
            description="Your account does not have access to leave request details."
          />
        </Card>
      </PageLayout>
    )
  }
  if (!Number.isSafeInteger(requestId) || requestId < 1) {
    return (
      <PageLayout title="Request details" subtitle="Your leave and attendance request.">
        <Card>
          <ErrorState
            title="Request not found"
            description="The request link is invalid."
            action={
              <Link
                to="/hr/leaves"
                search={search}
                className="text-label text-primary rounded-control focus-visible:shadow-focus-ring inline-flex min-h-11 items-center px-4 font-semibold focus-visible:outline-none"
              >
                Back to My Leaves
              </Link>
            }
          />
        </Card>
      </PageLayout>
    )
  }

  if (requestQuery.isPending) {
    return (
      <PageLayout
        title="Request details"
        subtitle="Loading your request."
        backLink={
          <Link to="/hr/leaves" search={search} className={pageBackLinkClassName}>
            <PageBackLinkContent>My Leaves</PageBackLinkContent>
          </Link>
        }
      >
        <Card aria-label="Loading request" aria-busy="true" className="space-y-3">
          <Skeleton variant="title" />
          <Skeleton variant="row" />
          <Skeleton variant="row" />
        </Card>
      </PageLayout>
    )
  }
  if (requestQuery.isError && !request) {
    return (
      <PageLayout
        title="Request details"
        subtitle="Your leave and attendance request."
        backLink={
          <Link to="/hr/leaves" search={search} className={pageBackLinkClassName}>
            <PageBackLinkContent>My Leaves</PageBackLinkContent>
          </Link>
        }
      >
        <Card>
          <ErrorState
            title="Request could not load"
            description="The request may have been removed or is outside your access."
            error={requestQuery.error}
            action={
              <Button variant="outline" onClick={() => void requestQuery.refetch()}>
                Try again
              </Button>
            }
          />
        </Card>
      </PageLayout>
    )
  }
  if (!request) return null

  const status = statusPresentation(request.status)
  const StatusIcon = status.icon
  const RequestIcon = request.requestKind === 'running_late' ? Clock3 : CalendarDays
  const statusDetailTone =
    status.tone === 'danger'
      ? 'border-danger/20 bg-danger-subtle/60 text-danger-foreground'
      : status.tone === 'success'
        ? 'border-success/20 bg-success-subtle/60 text-success-foreground'
        : status.tone === 'info'
          ? 'border-info/20 bg-info-subtle/60 text-info-foreground'
          : 'border-border-subtle bg-surface-muted text-text-secondary'
  const pending = request.status === 'pending'
  const todayInLagos = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Africa/Lagos',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date())
  const canEdit =
    pending &&
    canUpdate &&
    !(request.requestKind === 'running_late' && request.startDate !== todayInLagos)
  const canCancelRequest = pending && canDelete

  return (
    <PageLayout
      title="Request details"
      subtitle="Review the request, decision, and available actions."
      backLink={
        <Link to="/hr/leaves" search={search} className={pageBackLinkClassName}>
          <PageBackLinkContent>My Leaves</PageBackLinkContent>
        </Link>
      }
      actions={
        <div className="flex flex-wrap gap-2">
          {canEdit ? (
            <Button
              variant="outline"
              onClick={() => setFormConfig({ mode: 'edit', request })}
              leadingIcon={<RotateCcw className="size-4" />}
            >
              Edit request
            </Button>
          ) : null}
          {canCancelRequest ? (
            <Button
              variant="danger"
              onClick={() => setConfirmCancel(true)}
              leadingIcon={<Trash2 className="size-4" />}
            >
              Cancel request
            </Button>
          ) : null}
          {request.status === 'rejected' && canCreate ? (
            <Button
              onClick={() => setFormConfig({ mode: 'create', request })}
              leadingIcon={<FilePlus2 className="size-4" />}
            >
              Request again
            </Button>
          ) : null}
        </div>
      }
      contentClassName="space-y-5"
    >
      {requestQuery.isError && requestQuery.data ? (
        <Alert tone="warning" title="Showing saved request details">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <span>The latest refresh failed; the saved request is still available.</span>
            <Button variant="outline" size="sm" onClick={() => void requestQuery.refetch()}>
              Retry
            </Button>
          </div>
        </Alert>
      ) : null}
      {actionError ? (
        <Alert tone="danger" role="alert" title="Action not completed">
          {actionError}
        </Alert>
      ) : null}
      <Card className="space-y-5">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div className="flex min-w-0 items-start gap-3">
            <span className="bg-primary-subtle text-primary rounded-control flex size-10 shrink-0 items-center justify-center">
              <RequestIcon className="size-5" aria-hidden="true" />
            </span>
            <div className="min-w-0">
              <p className="text-caption text-text-secondary">{requestType(request)}</p>
              <h2 className="text-h3 text-text-primary tablet:text-h2 mt-1 font-semibold">
                {dateRange(request)}
              </h2>
            </div>
          </div>
          <StatusChip
            label={status.label}
            tone={status.tone}
            icon={<StatusIcon className="size-4" />}
          />
        </div>
        <div
          className={`rounded-control flex items-start gap-2.5 border px-3 py-2.5 ${statusDetailTone}`}
        >
          <StatusIcon className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
          <p className="text-body-sm">{status.detail}</p>
        </div>
        <div className="tablet:gap-3 desktop:grid-cols-3 grid grid-cols-2 gap-2.5">
          <DetailFact label="Request type" value={requestType(request)} icon={CalendarDays} />
          <DetailFact label="Requested period" value={dateRange(request)} icon={CalendarDays} />
          <DetailFact
            label="Duration"
            value={
              request.requestKind === 'running_late'
                ? 'Late-arrival report'
                : `${request.durationDays} ${request.durationDays === 1 ? 'calendar day' : 'calendar days'}`
            }
            icon={Clock3}
          />
          <DetailFact
            label="Submitted"
            value={formatDate(request.createdAt.slice(0, 10))}
            icon={FileClock}
          />
          {request.approverName ? (
            <DetailFact label="Reviewed by" value={request.approverName} icon={CheckCircle2} />
          ) : null}
          {request.approvalDate ? (
            <DetailFact
              label="Decision date"
              value={formatDate(request.approvalDate)}
              icon={CalendarDays}
            />
          ) : null}
        </div>
        <div className="border-border-subtle border-t pt-4">
          <h3 className="text-label text-text-primary font-semibold">Reason</h3>
          <p className="text-body-md text-text-secondary mt-2 whitespace-pre-wrap">
            {request.reason}
          </p>
        </div>
        {request.status === 'rejected' && request.rejectionReason ? (
          <Alert tone="danger" title="Reviewer feedback">
            {request.rejectionReason}
          </Alert>
        ) : null}
        {pending && !canEdit && !canCancelRequest ? (
          <Alert tone="info" title="Waiting for review">
            This request is pending. Your account does not have permission to edit or cancel it.
          </Alert>
        ) : null}
        {request.status === 'rejected' && !canCreate ? (
          <Alert tone="info" title="A new request is required">
            Rejected requests stay in your history. You do not have permission to submit a
            replacement request.
          </Alert>
        ) : null}
        {request.requestKind === 'running_late' &&
        request.status === 'pending' &&
        request.startDate !== todayInLagos ? (
          <Alert tone="info" title="This request is read-only">
            Late-arrival requests can only be edited on the day they were submitted.
          </Alert>
        ) : null}
      </Card>

      <LeaveRequestFormDialog
        open={Boolean(formConfig)}
        onOpenChange={(open) => {
          if (!open) setFormConfig(null)
        }}
        request={formConfig?.request}
        mode={formConfig?.mode}
        title={formConfig?.mode === 'edit' ? 'Edit pending request' : 'Request again'}
        onSave={saveRequest}
        saving={updateMutation.isPending || createMutation.isPending}
      />

      <Dialog
        open={confirmCancel}
        onOpenChange={setConfirmCancel}
        title="Cancel this request?"
        description="The request will remain in your history with Cancelled status."
        size="sm"
        fitContent
        compactOnMobile
        footer={
          <>
            <Button
              variant="outline"
              onClick={() => setConfirmCancel(false)}
              disabled={cancelMutation.isPending}
            >
              Keep request
            </Button>
            <Button
              variant="danger"
              onClick={() => void cancelRequest()}
              isLoading={cancelMutation.isPending}
            >
              Cancel request
            </Button>
          </>
        }
      >
        <p className="text-body-sm text-text-secondary">
          You can’t undo this action. If you still need leave or attendance accommodation, submit a
          new request.
        </p>
      </Dialog>
    </PageLayout>
  )
}
