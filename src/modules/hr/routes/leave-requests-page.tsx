import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import {
  Building2,
  CalendarDays,
  CalendarRange,
  Check,
  CheckCircle2,
  ChevronLeft,
  ChevronRight,
  Clock3,
  FilePlus2,
  MapPin,
  Pencil,
  Search,
  ShieldAlert,
  Users,
  X,
} from 'lucide-react'
import { useEffect, useState, type FormEvent, type ReactNode } from 'react'

import { hrOverviewQueryKey } from '@/modules/hr/hr-dashboard.api'
import { LeaveRequestFormDialog } from '@/modules/leaves/components/leave-request-form-dialog'
import { type LeaveRequestInput } from '@/modules/leaves/leaves.api'
import { authSessionQueryOptions, hasPermission } from '@/shared/auth/session'
import { presentError } from '@/shared/errors'
import { useToast } from '@/shared/feedback/use-toast'
import { Alert } from '@/shared/ui/alert'
import { Button } from '@/shared/ui/button'
import { Card } from '@/shared/ui/card'
import { Dialog } from '@/shared/ui/dialog'
import { DropdownSelect } from '@/shared/ui/dropdown-select'
import { EmptyState, ErrorState, Skeleton } from '@/shared/ui/feedback-states'
import { FormControl, TextArea, TextInput } from '@/shared/ui/form-control'
import { PageLayout } from '@/shared/ui/page-layout'
import { StatusChip, type StatusTone } from '@/shared/ui/status-chip'

import { RecruitmentRowActions, type RecruitmentMenuAction } from './recruitment-row-actions'
import { hrLeaveRequestsApi, type HRLeaveRequest } from '../leave-requests.api'
import {
  hrLeaveRequestDetailOptions,
  hrLeaveRequestListOptions,
  hrLeaveRequestQueryKeys,
  hrLeaveRequestSummaryOptions,
} from '../leave-requests.queries'
import {
  DEFAULT_HR_LEAVE_REQUEST_STATUS,
  type HRLeaveRequestsSearch,
} from '../leave-requests.search'

const PAGE_SIZES = [10, 20, 50] as const
const STATUS_OPTIONS = [
  { value: 'all', label: 'All statuses' },
  { value: 'pending', label: 'Pending review' },
  { value: 'history', label: 'Decision history' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'cancelled', label: 'Cancelled' },
]
const KIND_OPTIONS = [
  { value: 'all', label: 'All request types' },
  { value: 'leave', label: 'Leave' },
  { value: 'absence', label: 'Absence' },
  { value: 'running_late', label: 'Running late' },
  { value: 'attendance_exception', label: 'Attendance exceptions' },
]

function date(value: string) {
  const [year, month, day] = value.slice(0, 10).split('-').map(Number)
  if (!year || !month || !day) return value
  return new Intl.DateTimeFormat(undefined, {
    day: 'numeric',
    month: 'short',
    year: 'numeric',
  }).format(new Date(year, month - 1, day))
}

function requestKind(request: Pick<HRLeaveRequest, 'requestKind' | 'leaveType'>) {
  if (request.requestKind === 'running_late') return 'Running late'
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

function statusTone(status: string): StatusTone {
  if (status === 'approved') return 'success'
  if (status === 'pending') return 'info'
  if (status === 'rejected') return 'danger'
  return 'neutral'
}

function statusLabel(status: string) {
  const labels: Record<string, string> = {
    pending: 'Pending review',
    approved: 'Approved',
    rejected: 'Rejected',
    cancelled: 'Cancelled',
  }
  return labels[status] ?? status.replaceAll('_', ' ')
}

function RequestFact({ icon, label, value }: { icon: ReactNode; label: string; value: string }) {
  return (
    <div className="bg-surface border-border-subtle rounded-control min-w-0 border p-3">
      <dt className="text-caption text-text-secondary flex items-center gap-1.5">
        <span aria-hidden="true" className="text-primary">
          {icon}
        </span>
        {label}
      </dt>
      <dd className="text-body-sm text-text-primary mt-1.5 font-semibold break-words">{value}</dd>
    </div>
  )
}

function SummaryCard({
  label,
  value,
  icon,
  tone,
}: {
  label: string
  value: number
  icon: ReactNode
  tone: string
}) {
  return (
    <Card className="flex min-w-0 items-center gap-3 p-3.5">
      <span
        className={`bg-surface-muted rounded-control flex size-10 shrink-0 items-center justify-center ${tone}`}
      >
        {icon}
      </span>
      <span className="min-w-0">
        <span className="text-h3 text-text-primary block font-semibold tabular-nums">{value}</span>
        <span className="text-caption text-text-secondary block leading-snug">{label}</span>
      </span>
    </Card>
  )
}

function RequestDetails({
  request,
  currentEmployeeId,
  onClose,
  onDecide,
  deciding,
  canApprove,
  canReject,
}: {
  request: HRLeaveRequest | null
  currentEmployeeId?: number
  onClose: () => void
  onDecide: (status: 'approved' | 'rejected') => void
  deciding: boolean
  canApprove: boolean
  canReject: boolean
}) {
  const canReview = Boolean(
    request?.status === 'pending' && request.employeeId !== currentEmployeeId,
  )
  return (
    <Dialog
      open={Boolean(request)}
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
      title={request ? `${requestKind(request)} request` : 'Request details'}
      description={
        request ? `Request #${request.id} · Submitted ${date(request.createdAt)}` : undefined
      }
      size="lg"
      fitContent
      compactOnMobile
      bodyClassName="space-y-4"
      footer={
        <>
          <Button variant="outline" onClick={onClose}>
            Close
          </Button>
          {canReview && canReject ? (
            <Button variant="outline" disabled={deciding} onClick={() => onDecide('rejected')}>
              Reject
            </Button>
          ) : null}
          {canReview && canApprove ? (
            <Button disabled={deciding} isLoading={deciding} onClick={() => onDecide('approved')}>
              Approve
            </Button>
          ) : null}
        </>
      }
    >
      {request ? (
        <div className="space-y-4">
          <div className="from-primary-subtle/65 via-primary-subtle/25 to-surface border-border-subtle rounded-surface phone:grid-cols-2 grid grid-cols-1 items-center gap-3 border bg-gradient-to-r p-3">
            <div className="flex min-w-0 items-center gap-2">
              <span className="bg-surface text-primary rounded-control flex size-9 shrink-0 items-center justify-center shadow-sm">
                <CalendarDays className="size-4.5" />
              </span>
              <div className="min-w-0">
                <p className="text-overline text-text-secondary mb-1">Request status</p>
                <StatusChip
                  dense
                  label={statusLabel(request.status)}
                  tone={statusTone(request.status)}
                />
              </div>
            </div>
            <div className="min-w-0">
              <p className="text-overline text-text-secondary mb-1">Requested duration</p>
              <p className="text-body-sm text-text-primary font-semibold">
                {request.requestKind === 'running_late'
                  ? 'One arrival'
                  : `${request.durationDays} ${request.durationDays === 1 ? 'day' : 'days'}`}
              </p>
            </div>
          </div>
          <section aria-labelledby="leave-request-detail-heading">
            <h3
              id="leave-request-detail-heading"
              className="text-label text-text-primary flex items-center gap-2 font-semibold"
            >
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <CalendarRange className="size-4" />
              </span>
              Request overview
            </h3>
            <dl className="tablet:grid-cols-3 phone:grid-cols-2 mt-2.5 grid grid-cols-1 gap-2.5">
              <RequestFact
                icon={<Users className="size-3.5" />}
                label="Employee"
                value={request.employeeName}
              />
              <RequestFact
                icon={<Building2 className="size-3.5" />}
                label="Employee ID"
                value={request.employeeCode || `Employee #${request.employeeId}`}
              />
              <RequestFact
                icon={<MapPin className="size-3.5" />}
                label="Branch"
                value={request.branchName || 'Not assigned'}
              />
              <RequestFact
                icon={<CalendarRange className="size-3.5" />}
                label="Requested dates"
                value={
                  request.requestKind === 'running_late' || request.startDate === request.endDate
                    ? date(request.startDate)
                    : `${date(request.startDate)} – ${date(request.endDate)}`
                }
              />
              <RequestFact
                icon={<CalendarDays className="size-3.5" />}
                label="Submitted"
                value={date(request.createdAt)}
              />
              <RequestFact
                icon={<Users className="size-3.5" />}
                label="Reviewed by"
                value={request.approverName || 'Not reviewed'}
              />
              {request.approvalDate ? (
                <RequestFact
                  icon={<CalendarDays className="size-3.5" />}
                  label="Decision date"
                  value={date(request.approvalDate)}
                />
              ) : null}
            </dl>
          </section>
          <section className="border-border-subtle rounded-control border p-3.5">
            <h3 className="text-label text-text-primary flex items-center gap-2 font-semibold">
              <span className="bg-primary-subtle text-primary rounded-control flex size-8 items-center justify-center">
                <FilePlus2 className="size-4" />
              </span>
              Employee reason
            </h3>
            <p className="text-body-sm text-text-secondary mt-2 break-words whitespace-pre-wrap">
              {request.reason}
            </p>
          </section>
          {request.rejectionReason ? (
            <Alert tone="danger" title="Rejection reason">
              {request.rejectionReason}
            </Alert>
          ) : null}
          {request.status === 'pending' && request.employeeId === currentEmployeeId ? (
            <Alert tone="info" title="Self-review is not allowed">
              You cannot approve or reject your own request.
            </Alert>
          ) : null}
        </div>
      ) : null}
    </Dialog>
  )
}

export function LeaveRequestsPage() {
  const search = useSearch({ from: '/_protected/hr/leave-request' }) as HRLeaveRequestsSearch
  const navigate = useNavigate({ from: '/hr/leave-request' })
  const queryClient = useQueryClient()
  const { showToast } = useToast()
  const sessionQuery = useQuery(authSessionQueryOptions())
  const session = sessionQuery.data
  const userId = session?.user.id ?? 0
  const employeeId = session?.employee.employee_id ?? ''
  const employeePk = session?.employee.id
  const permissions = session?.permissions ?? {}
  const canList = hasPermission(permissions, 'leave_requests', 'list')
  const canView = hasPermission(permissions, 'leave_requests', 'view')
  const canUpdate = hasPermission(permissions, 'leave_requests', 'update')
  const canApprove = hasPermission(permissions, 'leave_requests', 'approve')
  const canReject = hasPermission(permissions, 'leave_requests', 'reject')
  const [searchDraftState, setSearchDraftState] = useState({
    routeValue: search.search,
    value: search.search,
  })
  const searchDraft =
    searchDraftState.routeValue === search.search ? searchDraftState.value : search.search
  const selectedRequestId = search.request_id ?? null
  const [formRequest, setFormRequest] = useState<HRLeaveRequest | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [decision, setDecision] = useState<{
    request: HRLeaveRequest
    status: 'approved' | 'rejected'
  } | null>(null)
  const [rejectionReason, setRejectionReason] = useState('')
  const [decisionError, setDecisionError] = useState('')
  useEffect(() => {
    if (!search.request_id || !session || canView) return
    void navigate({
      search: (previous: HRLeaveRequestsSearch) => ({ ...previous, request_id: undefined }),
      resetScroll: false,
    })
  }, [search.request_id, session, canView, navigate])

  function updateSearch(updates: Partial<HRLeaveRequestsSearch>) {
    void navigate({
      search: (previous: HRLeaveRequestsSearch) => ({ ...previous, ...updates }),
      resetScroll: false,
    })
  }
  function commitSearch(event: FormEvent) {
    event.preventDefault()
    updateSearch({ search: searchDraft.trim(), page: 1 })
  }
  function setSearchDraft(value: string) {
    setSearchDraftState({ routeValue: search.search, value })
  }
  const listParams = {
    limit: search.pageSize,
    offset: (search.page - 1) * search.pageSize,
    search: search.search,
    status: search.status,
    kind: search.kind,
  }
  const listQuery = useQuery({
    ...hrLeaveRequestListOptions(userId, employeeId, listParams),
    enabled: Boolean(session && canList),
    placeholderData: (previous) => previous,
  })
  const summaryQuery = useQuery({
    ...hrLeaveRequestSummaryOptions(userId, employeeId),
    enabled: Boolean(session && canList),
  })
  const detailQuery = useQuery({
    ...hrLeaveRequestDetailOptions(userId, employeeId, selectedRequestId ?? 0),
    enabled: Boolean(selectedRequestId && canView),
  })
  const updateMutation = useMutation({
    mutationFn: ({
      id,
      input,
    }: {
      id: number
      input: Partial<Pick<LeaveRequestInput, 'leave_type' | 'start_date' | 'end_date' | 'reason'>>
    }) => hrLeaveRequestsApi.update(id, input),
  })
  const reviewMutation = useMutation({
    mutationFn: ({
      id,
      status,
      reason,
    }: {
      id: number
      status: 'approved' | 'rejected'
      reason?: string
    }) => hrLeaveRequestsApi.review(id, status, reason),
  })

  async function refreshRequestData(requestId: number, updatedRequest: HRLeaveRequest) {
    queryClient.setQueryData(
      hrLeaveRequestQueryKeys.detail(userId, employeeId, requestId),
      updatedRequest,
    )
    await Promise.all([
      queryClient.invalidateQueries({
        queryKey: hrLeaveRequestQueryKeys.lists(userId, employeeId),
      }),
      queryClient.invalidateQueries({
        queryKey: hrLeaveRequestQueryKeys.summary(userId, employeeId),
      }),
      queryClient.invalidateQueries({ queryKey: hrOverviewQueryKey(userId, employeeId) }),
    ])
  }
  async function saveRequest(input: LeaveRequestInput) {
    if (!formRequest) return
    const updatedRequest = await updateMutation.mutateAsync({
      id: formRequest.id,
      input: {
        leave_type: input.leave_type,
        start_date: input.start_date,
        end_date: input.end_date,
        reason: input.reason,
      },
    })
    await refreshRequestData(formRequest.id, updatedRequest)
    showToast({
      title: 'Request updated',
      description: 'The employee’s pending request was updated.',
      tone: 'success',
    })
    setFormOpen(false)
    setFormRequest(null)
  }
  function startDecision(request: HRLeaveRequest, status: 'approved' | 'rejected') {
    setDecision({ request, status })
    setRejectionReason('')
    setDecisionError('')
  }
  async function submitDecision() {
    if (!decision) return
    if (decision.status === 'rejected' && rejectionReason.trim().length < 3) {
      setDecisionError('Enter a rejection reason of at least 3 characters.')
      return
    }
    try {
      const updatedRequest = await reviewMutation.mutateAsync({
        id: decision.request.id,
        status: decision.status,
        reason: decision.status === 'rejected' ? rejectionReason.trim() : undefined,
      })
      await refreshRequestData(decision.request.id, updatedRequest)
      showToast({
        title: decision.status === 'approved' ? 'Request approved' : 'Request rejected',
        description: 'The employee’s request has been updated.',
        tone: 'success',
      })
      setDecision(null)
      setDecisionError('')
    } catch (error) {
      setDecisionError(presentError(error, 'background-action').message)
    }
  }
  function closeDetails() {
    updateSearch({ request_id: undefined })
  }

  const requests = listQuery.data?.items ?? []
  const total = listQuery.data?.count ?? 0
  const pageCount = Math.max(1, Math.ceil(total / search.pageSize))
  const selectedRequest =
    detailQuery.data ?? requests.find((request) => request.id === selectedRequestId) ?? null

  if (sessionQuery.isPending)
    return (
      <PageLayout
        title="Leave Requests"
        subtitle="Review and manage employee leave and attendance requests."
      >
        <Card className="space-y-4" aria-busy="true">
          {Array.from({ length: 4 }, (_, index) => (
            <Skeleton key={index} variant="row" />
          ))}
        </Card>
      </PageLayout>
    )
  if (sessionQuery.isError || !session)
    return (
      <PageLayout title="Leave Requests">
        <Card>
          <ErrorState
            title="Your access could not be confirmed"
            description="Reload the page and try again."
            error={sessionQuery.error}
          />
        </Card>
      </PageLayout>
    )

  return (
    <PageLayout
      title="Leave Requests"
      subtitle="Review and manage employee leave and attendance requests."
      leading={<CalendarDays className="size-[18px]" />}
      actionsInline
      contentClassName="space-y-5"
    >
      {!canList ? (
        <Card>
          <ErrorState
            title="You cannot review leave requests"
            description="Your account does not have permission to list employee requests."
          />
        </Card>
      ) : (
        <>
          <section
            aria-label="Leave request overview"
            className="desktop:grid-cols-4 grid grid-cols-2 gap-2.5"
          >
            {summaryQuery.isPending ? (
              Array.from({ length: 4 }, (_, index) => (
                <Skeleton key={index} className="h-[4.6rem]" />
              ))
            ) : summaryQuery.isError ? (
              <Card className="col-span-full">
                <Alert tone="warning" title="Summary unavailable">
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <span>
                      Request records remain available; summary counts could not be refreshed.
                    </span>
                    <Button size="sm" variant="outline" onClick={() => void summaryQuery.refetch()}>
                      Retry
                    </Button>
                  </div>
                </Alert>
              </Card>
            ) : summaryQuery.data ? (
              <>
                <SummaryCard
                  label="Awaiting review"
                  value={summaryQuery.data.pending}
                  icon={<Clock3 className="size-5" />}
                  tone="text-info-foreground"
                />
                <SummaryCard
                  label="On leave today"
                  value={summaryQuery.data.on_leave}
                  icon={<Users className="size-5" />}
                  tone="text-primary"
                />
                <SummaryCard
                  label="Approved this month"
                  value={summaryQuery.data.approved_this_month}
                  icon={<CheckCircle2 className="size-5" />}
                  tone="text-success-foreground"
                />
                <SummaryCard
                  label="Rejected"
                  value={summaryQuery.data.rejected}
                  icon={<ShieldAlert className="size-5" />}
                  tone="text-danger-foreground"
                />
              </>
            ) : null}
          </section>
          <Card className="tablet:p-5 space-y-4 p-4">
            <div className="flex flex-wrap items-end justify-between gap-2">
              <div>
                <p className="text-overline text-primary font-semibold">HR operations</p>
                <h2 className="text-h3 text-text-primary mt-1 font-semibold">Request register</h2>
                <p className="text-body-sm text-text-secondary mt-1">
                  Search by employee name, employee code, or email.
                </p>
              </div>
              <p
                className="bg-surface-muted border-border-subtle text-caption text-text-secondary rounded-full border px-2.5 py-1 tabular-nums"
                aria-live="polite"
              >
                {listQuery.isPending && !listQuery.data
                  ? 'Loading requests'
                  : `${total} ${total === 1 ? 'request' : 'requests'}`}
              </p>
            </div>
            <form
              onSubmit={commitSearch}
              className="grid grid-cols-[minmax(0,1fr)_auto] items-end gap-3"
            >
              <FormControl id="leave-employee-search" label="Find employee" className="min-w-0">
                <span className="relative block">
                  <Search className="text-text-muted absolute top-1/2 left-3 size-4 -translate-y-1/2" />
                  <TextInput
                    className="pl-10"
                    type="search"
                    aria-label="Find employee"
                    maxLength={200}
                    value={searchDraft}
                    placeholder="Name, employee code, or email"
                    onChange={(event) => setSearchDraft(event.currentTarget.value)}
                  />
                </span>
              </FormControl>
              <div className="flex items-end gap-2">
                <Button
                  type="submit"
                  aria-label="Search"
                  size="icon"
                  leadingIcon={<Search className="size-4" />}
                  className="phone:h-11 phone:w-auto phone:px-4 shrink-0"
                >
                  <span className="phone:inline hidden">Search</span>
                </Button>
                {search.search ||
                search.kind !== 'all' ||
                search.status !== DEFAULT_HR_LEAVE_REQUEST_STATUS ? (
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-11 shrink-0"
                    onClick={() => {
                      setSearchDraft('')
                      updateSearch({
                        search: '',
                        kind: 'all',
                        status: DEFAULT_HR_LEAVE_REQUEST_STATUS,
                        page: 1,
                      })
                    }}
                  >
                    Clear
                  </Button>
                ) : null}
              </div>
            </form>
            <div className="phone:grid-cols-2 grid gap-3">
              <FormControl id="leave-kind-filter" label="Request type">
                <DropdownSelect
                  value={search.kind}
                  options={KIND_OPTIONS}
                  onChange={(value) =>
                    updateSearch({ kind: value as HRLeaveRequestsSearch['kind'], page: 1 })
                  }
                />
              </FormControl>
              <FormControl id="leave-status-filter" label="Status">
                <DropdownSelect
                  value={search.status}
                  options={STATUS_OPTIONS}
                  onChange={(value) =>
                    updateSearch({ status: value as HRLeaveRequestsSearch['status'], page: 1 })
                  }
                />
              </FormControl>
            </div>
          </Card>
          {listQuery.isError && listQuery.data ? (
            <Alert tone="warning" title="Showing saved requests">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>The latest refresh failed. Previously loaded requests remain available.</span>
                <Button size="sm" variant="outline" onClick={() => void listQuery.refetch()}>
                  Retry refresh
                </Button>
              </div>
            </Alert>
          ) : null}
          {listQuery.isPending ? (
            <Card className="space-y-3" aria-busy="true" aria-label="Loading leave requests">
              {Array.from({ length: 4 }, (_, index) => (
                <Skeleton key={index} variant="row" />
              ))}
            </Card>
          ) : listQuery.isError && !listQuery.data ? (
            <Card>
              <ErrorState
                title="Requests could not load"
                description="Try reloading the register."
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
                icon={<CalendarDays className="size-6" />}
                title={
                  search.search ||
                  search.kind !== 'all' ||
                  search.status !== DEFAULT_HR_LEAVE_REQUEST_STATUS
                    ? 'No requests match these filters'
                    : 'No requests awaiting review'
                }
                description={
                  search.search ||
                  search.kind !== 'all' ||
                  search.status !== DEFAULT_HR_LEAVE_REQUEST_STATUS
                    ? 'Adjust the search or filters to see more requests.'
                    : 'Pending requests within your assigned review scope will appear here.'
                }
                action={
                  search.search ||
                  search.kind !== 'all' ||
                  search.status !== DEFAULT_HR_LEAVE_REQUEST_STATUS ? (
                    <Button
                      variant="outline"
                      onClick={() => {
                        setSearchDraft('')
                        updateSearch({
                          search: '',
                          kind: 'all',
                          status: DEFAULT_HR_LEAVE_REQUEST_STATUS,
                          page: 1,
                        })
                      }}
                    >
                      Clear filters
                    </Button>
                  ) : undefined
                }
              />
            </Card>
          ) : (
            <div className="space-y-3">
              {requests.map((request) => {
                const isOwn = request.employeeId === employeePk
                const canReview =
                  request.status === 'pending' && !isOwn && (canApprove || canReject)
                const canEditRequest =
                  request.status === 'pending' &&
                  !isOwn &&
                  request.requestKind !== 'running_late' &&
                  canUpdate
                const typeLabel = requestKind(request)
                const mobileActions: RecruitmentMenuAction[] = []
                if (canReview && canApprove) {
                  mobileActions.push({
                    id: 'approve',
                    label: 'Approve',
                    icon: Check,
                    onSelect: () => startDecision(request, 'approved'),
                  })
                }
                if (canReview && canReject) {
                  mobileActions.push({
                    id: 'reject',
                    label: 'Reject',
                    icon: X,
                    onSelect: () => startDecision(request, 'rejected'),
                    danger: true,
                  })
                }
                if (canEditRequest) {
                  mobileActions.push({
                    id: 'edit',
                    label: 'Edit',
                    icon: Pencil,
                    onSelect: () => {
                      setFormRequest(request)
                      setFormOpen(true)
                    },
                  })
                }
                const range =
                  request.requestKind === 'running_late' || request.startDate === request.endDate
                    ? date(request.startDate)
                    : `${date(request.startDate)} – ${date(request.endDate)}`
                return (
                  <article
                    key={request.id}
                    className="border-border-subtle bg-surface hover:border-primary/25 hover:shadow-elevation-sm rounded-control shadow-elevation-sm min-w-0 overflow-hidden border transition-colors"
                  >
                    <header className="phone:p-5 flex min-w-0 items-start gap-3 p-4">
                      <span className="bg-primary-subtle text-primary rounded-control flex size-11 shrink-0 items-center justify-center">
                        <CalendarDays className="size-5" aria-hidden="true" />
                      </span>
                      <div className="flex min-w-0 flex-1 flex-wrap items-start justify-between gap-2">
                        <div className="min-w-0">
                          <h3 className="text-label text-text-primary font-semibold break-words">
                            {typeLabel}
                          </h3>
                          <p className="text-caption text-text-secondary mt-1 break-words">
                            {request.employeeName}
                          </p>
                        </div>
                        <div className="flex shrink-0 flex-wrap items-center gap-1.5">
                          <StatusChip
                            label={statusLabel(request.status)}
                            tone={statusTone(request.status)}
                            dense
                          />
                          {isOwn ? <StatusChip label="You" tone="neutral" dense /> : null}
                        </div>
                      </div>
                    </header>
                    <dl className="border-border-subtle phone:grid-cols-2 desktop:grid-cols-4 phone:px-5 grid min-w-0 grid-cols-1 gap-x-5 gap-y-3 border-t px-4 py-4">
                      <div className="min-w-0">
                        <dt className="text-overline text-text-muted">Employee code</dt>
                        <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
                          {request.employeeCode || `Employee #${request.employeeId}`}
                        </dd>
                      </div>
                      <div className="min-w-0">
                        <dt className="text-overline text-text-muted">Branch</dt>
                        <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
                          {request.branchName || 'Not assigned'}
                        </dd>
                      </div>
                      <div className="min-w-0">
                        <dt className="text-overline text-text-muted">Requested dates</dt>
                        <dd className="text-body-sm text-text-primary mt-1 font-medium break-words">
                          {range}
                        </dd>
                      </div>
                      {request.requestKind !== 'running_late' ? (
                        <div className="min-w-0">
                          <dt className="text-overline text-text-muted">Duration</dt>
                          <dd className="text-body-sm text-text-primary mt-1 font-medium">
                            {request.durationDays} {request.durationDays === 1 ? 'day' : 'days'}
                          </dd>
                        </div>
                      ) : null}
                      <div className="min-w-0">
                        <dt className="text-overline text-text-muted">Submitted</dt>
                        <dd className="text-body-sm text-text-primary mt-1 font-medium">
                          {date(request.createdAt)}
                        </dd>
                      </div>
                    </dl>
                    <section className="border-border-subtle phone:px-5 border-t px-4 py-3">
                      <p className="text-overline text-text-muted">Employee reason</p>
                      <p className="text-body-sm text-text-secondary mt-1 line-clamp-2 break-words">
                        {request.reason}
                      </p>
                    </section>
                    <footer className="border-border-subtle phone:flex-row phone:items-center phone:justify-between phone:px-5 flex min-w-0 flex-col gap-3 border-t px-4 py-3">
                      <p className="text-overline text-text-muted min-w-0 break-all">
                        Request ID · #{request.id}
                      </p>
                      <div className="phone:justify-end flex min-w-0 flex-wrap items-center justify-end gap-2">
                        {canView ? (
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => {
                              updateSearch({ request_id: request.id })
                            }}
                          >
                            Details
                          </Button>
                        ) : null}
                        {mobileActions.length ? (
                          <div className="tablet:hidden">
                            <RecruitmentRowActions
                              recordLabel={`request #${request.id}`}
                              actions={mobileActions}
                            />
                          </div>
                        ) : null}
                        <div className="tablet:flex hidden flex-wrap items-center gap-2">
                          {canReview && canApprove ? (
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => startDecision(request, 'approved')}
                            >
                              Approve
                            </Button>
                          ) : null}
                          {canReview && canReject ? (
                            <Button
                              size="sm"
                              variant="danger"
                              onClick={() => startDecision(request, 'rejected')}
                            >
                              Reject
                            </Button>
                          ) : null}
                          {canEditRequest ? (
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => {
                                setFormRequest(request)
                                setFormOpen(true)
                              }}
                            >
                              Edit
                            </Button>
                          ) : null}
                        </div>
                      </div>
                    </footer>
                  </article>
                )
              })}
            </div>
          )}
          {requests.length > 0 ? (
            <Card className="overflow-hidden p-0">
              <div className="border-border-subtle tablet:px-5 flex flex-wrap items-center justify-between gap-3 border-t px-4 py-3">
                <p className="text-caption text-text-secondary" aria-live="polite">
                  {total === 0
                    ? '0'
                    : `${(search.page - 1) * search.pageSize + 1}–${Math.min(search.page * search.pageSize, total)}`}{' '}
                  of {total}
                </p>
                <div className="flex items-center gap-2">
                  <DropdownSelect
                    aria-label="Requests per page"
                    value={String(search.pageSize)}
                    options={PAGE_SIZES.map((size) => ({
                      value: String(size),
                      label: `${size} per page`,
                    }))}
                    onChange={(value) =>
                      updateSearch({
                        pageSize: Number(value) as HRLeaveRequestsSearch['pageSize'],
                        page: 1,
                      })
                    }
                  />
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={search.page <= 1}
                    onClick={() => updateSearch({ page: search.page - 1 })}
                  >
                    <ChevronLeft className="size-4" />
                    <span className="tablet:inline hidden">Previous</span>
                  </Button>
                  <span className="text-caption text-text-secondary tabular-nums">
                    {search.page}/{pageCount}
                  </span>
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={search.page >= pageCount}
                    onClick={() => updateSearch({ page: search.page + 1 })}
                  >
                    <span className="tablet:inline hidden">Next</span>
                    <ChevronRight className="size-4" />
                  </Button>
                </div>
              </div>
            </Card>
          ) : null}
        </>
      )}
      <RequestDetails
        request={selectedRequestId && canView ? selectedRequest : null}
        currentEmployeeId={employeePk}
        onClose={closeDetails}
        onDecide={(status) => {
          if (selectedRequest) startDecision(selectedRequest, status)
        }}
        deciding={reviewMutation.isPending}
        canApprove={canApprove}
        canReject={canReject}
      />
      {selectedRequestId && detailQuery.isError && canView ? (
        <Dialog
          open
          onOpenChange={(open) => {
            if (!open) closeDetails()
          }}
          title="Request details unavailable"
          description="The request could not be loaded."
          size="sm"
          fitContent
          compactOnMobile
          footer={
            <Button variant="outline" onClick={() => void detailQuery.refetch()}>
              Retry
            </Button>
          }
        >
          <Alert tone="danger" title="Unable to open request">
            {presentError(detailQuery.error, 'page-load').message}
          </Alert>
        </Dialog>
      ) : null}
      <Dialog
        open={Boolean(decision)}
        onOpenChange={(open) => {
          if (!open) {
            setDecision(null)
            setDecisionError('')
          }
        }}
        title={decision?.status === 'approved' ? 'Approve request?' : 'Reject request?'}
        description={
          decision
            ? `${decision.request.employeeName} · ${requestKind(decision.request)}`
            : undefined
        }
        size="sm"
        fitContent
        compactOnMobile
        bodyClassName="space-y-4"
        dismissDisabled={reviewMutation.isPending}
        footer={
          <>
            <Button
              variant="outline"
              disabled={reviewMutation.isPending}
              onClick={() => setDecision(null)}
            >
              Cancel
            </Button>
            <Button
              variant={decision?.status === 'rejected' ? 'danger' : 'primary'}
              isLoading={reviewMutation.isPending}
              onClick={() => void submitDecision()}
            >
              {decision?.status === 'approved' ? 'Confirm approval' : 'Confirm rejection'}
            </Button>
          </>
        }
      >
        <div className="space-y-3">
          <p className="text-body-sm text-text-secondary">
            {decision?.status === 'approved'
              ? 'This records your approval and updates the employee’s request.'
              : 'A clear reason is required and will be recorded with the decision.'}
          </p>
          {decision?.status === 'rejected' ? (
            <FormControl
              id="leave-rejection-reason"
              label="Reason for rejection"
              required
              error={decisionError}
            >
              <TextArea
                rows={4}
                maxLength={1000}
                value={rejectionReason}
                onChange={(event) => {
                  setRejectionReason(event.currentTarget.value)
                  setDecisionError('')
                }}
              />
            </FormControl>
          ) : null}
          {decisionError && decision?.status === 'approved' ? (
            <Alert tone="danger" title="Decision not saved">
              {decisionError}
            </Alert>
          ) : null}
        </div>
      </Dialog>
      <LeaveRequestFormDialog
        open={formOpen}
        onOpenChange={setFormOpen}
        request={formRequest}
        mode="edit"
        title="Edit employee request"
        description={
          formRequest
            ? `Update ${formRequest.employeeName}’s pending ${requestKind(formRequest).toLowerCase()} request.`
            : undefined
        }
        onSave={saveRequest}
        saving={updateMutation.isPending}
      />
    </PageLayout>
  )
}
